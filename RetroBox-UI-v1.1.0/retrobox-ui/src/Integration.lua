-- Small opt-in lifecycle helper. Capability checks never change identity or permissions.
do
    function Library:CreateIntegration(options)
        options=options or {}; assert(type(options)=='table','Integration options must be a table')
        assert(options.Window==nil or type(options.Window)=='table','Integration Window must be a table')
        assert(options.Required==nil or type(options.Required)=='table','Integration Required must be an array')
        assert(options.Initialize==nil or type(options.Initialize)=='function','Initialize must be a developer callback')
        assert(options.OnError==nil or type(options.OnError)=='function','OnError must be a developer callback')
        assert(options.CallbackExecutor==nil or type(options.CallbackExecutor)=='function','CallbackExecutor must be a developer callback')
        local caps={loadstring=type(loadstring)=='function',readfile=type(readfile)=='function',writefile=type(writefile)=='function',
            setclipboard=type(setclipboard)=='function',SharedEnvironment=type(getgenv)=='function'}
        local readable,getter=pcall(function() return game.HttpGet end); caps.HttpGet=readable and type(getter)=='function'
        local required=options.Required or {}; local count=0
        for index in pairs(required) do count=count+1; assert(type(index)=='number' and index%1==0 and index>=1 and index<=16,'Required must be a dense array of at most 16 capabilities') end
        assert(count==#required,'Required must be a dense array')
        for _,name in ipairs(required) do
            assert(caps[name]~=nil,'Unknown integration capability: '..tostring(name))
            if not caps[name] then return nil,'Required capability is unavailable: '..name end
        end
        local settings={}; for key,value in pairs(options.Window or {}) do settings[key]=value end
        if options.CallbackExecutor then settings.CallbackExecutor=options.CallbackExecutor end
        local ok,window=pcall(self.CreateWindow,self,settings)
        if not ok then return nil,tostring(window) end
        local owner={Window=window,Scope=window:CreateScope(),Capabilities=caps}
        function owner:Manage(resource,method,key) return self.Scope:Add(resource,method,key) end
        function owner:Run(callback,...)
            if self.Destroyed or self.Window.Destroyed then return false,'Integration has been destroyed' end
            assert(type(callback)=='function','Run needs a callback')
            return self.Window:_protected(callback,{Phase='Integration'},...)
        end
        function owner:Destroy()
            if self.Destroyed then return end; self.Destroyed=true; self.Window:Destroy()
        end
        owner.Scope:Add(function() owner.Destroyed=true end)
        if options.OnError then owner.Scope:Add(window:OnError(options.OnError),'Disconnect') end
        if options.Initialize then
            local initialized,result,reason=owner:Run(options.Initialize,owner)
            if not initialized or result==false then owner:Destroy(); return nil,tostring(initialized and reason or result) end
        end
        return owner
    end
end
