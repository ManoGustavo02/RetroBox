-- Optional transient state snapshots. Profiles and live runtime handles are never captured.
do
    local function sessionKey(value)
        assert(type(value)=='string' and #value>=1 and #value<=64 and value:match('^[%w_.%-]+$'),'Session key must be 1–64 letters, numbers, dots, underscores or hyphens')
        return value
    end
    local function plain(value,seen,depth,budget)
        budget.Nodes=budget.Nodes+1; assert(budget.Nodes<=8192,'Session snapshot exceeds 8192 values')
        local kind=typeof(value)
        if kind=='nil' or kind=='boolean' then return value end
        if kind=='number' then assert(finite(value),'Session numbers must be finite'); return value end
        if kind=='string' then budget.Bytes=budget.Bytes+#value; assert(budget.Bytes<=262144,'Session strings exceed 256 KiB'); return value end
        assert(kind=='table' and getmetatable(value)==nil,'Session values must be plain data, without functions, Instances, tasks or connections')
        assert(depth<12 and not seen[value],'Session data must be acyclic and at most 12 levels deep')
        seen[value]=true; local result,count={},0
        for key,item in pairs(value) do
            count=count+1; assert(count<=1024,'Session table exceeds 1024 entries')
            assert(type(key)=='string' or type(key)=='number' and finite(key),'Session keys must be strings or finite numbers')
            if type(key)=='string' then budget.Bytes=budget.Bytes+#key; assert(budget.Bytes<=262144,'Session strings exceed 256 KiB') end
            result[key]=plain(item,seen,depth+1,budget)
        end
        seen[value]=nil; return result
    end
    local function cloneSession(value) return plain(value,{},0,{Nodes=0,Bytes=0}) end
    function Window:RegisterSessionState(name,state)
        assert(not self.Destroyed,'Window has been destroyed'); sessionKey(name)
        assert(Library:_isState(state) and not state.Destroyed and not state.ReadOnly,'Session state must be a live writable State')
        assert(state._window==nil or state._window==self,'Session state belongs to another window')
        if not self._sessionStates then
            self._sessionStates={}
            self:Manage(function() self._sessionStates=nil end,nil,'session-states')
        end
        local count=0; for _ in pairs(self._sessionStates) do count=count+1 end
        assert(self._sessionStates[name] or count<128,'Session state limit is 128')
        self._sessionStates[name]=state; return self
    end
    function Window:UnregisterSessionState(name)
        sessionKey(name); if self._sessionStates then self._sessionStates[name]=nil end; return self
    end
    function Window:CreateSessionSnapshot()
        if self.Destroyed then return nil,'Window has been destroyed' end
        local ok,result=pcall(function()
            local values={}
            for name,state in pairs(self._sessionStates or {}) do
                if not state.Destroyed then values[name]={Value=state:Get()} end
            end
            return cloneSession({Kind='RetroBoxSession',SchemaVersion=1,APIVersion=2,WindowId=self.Id,States=values})
        end)
        if not ok then return nil,tostring(result) end
        return result
    end
    function Window:RestoreSessionSnapshot(snapshot)
        if self.Destroyed then return false,'Window has been destroyed' end
        local ok,prepared,report=pcall(function()
            local data=cloneSession(snapshot)
            assert(type(data)=='table' and data.Kind=='RetroBoxSession' and data.SchemaVersion==1 and data.APIVersion==2,'Incompatible session snapshot')
            for key in pairs(data) do assert(key=='Kind' or key=='SchemaVersion' or key=='APIVersion' or key=='WindowId' or key=='States','Unknown snapshot field') end
            assert(data.WindowId==self.Id and type(data.States)=='table','Snapshot belongs to another window or has no States')
            local changes,summary={}, {Restored=0,Missing={},Unknown={}}
            local count=0
            for name,entry in pairs(data.States) do
                sessionKey(name); count=count+1; assert(count<=128,'Session state limit is 128')
                assert(type(entry)=='table','Session state needs a Value record')
                for key in pairs(entry) do assert(key=='Value','Unknown session state field') end
                local state=(self._sessionStates or {})[name]
                if state and not state.Destroyed then
                    assert(not state.ReadOnly,'Session state became read-only')
                    if state.Validate then local valid,reason=state.Validate(entry.Value); assert(valid,reason or 'Invalid session value') end
                    changes[#changes+1]={State=state,Value=entry.Value}; summary.Restored=summary.Restored+1
                else summary.Unknown[#summary.Unknown+1]=name end
            end
            for name,state in pairs(self._sessionStates or {}) do if not state.Destroyed and data.States[name]==nil then summary.Missing[#summary.Missing+1]=name end end
            table.sort(summary.Missing); table.sort(summary.Unknown)
            return changes,summary
        end)
        if not ok then return false,tostring(prepared) end
        local prior=self._suppressCallbacks; self._suppressCallbacks=true
        local restored,reason=pcall(function() Library:Batch(function() for _,change in ipairs(prepared) do change.State:Set(change.Value) end end) end)
        self._suppressCallbacks=prior
        if not restored then return false,tostring(reason) end
        return true,report
    end
end
