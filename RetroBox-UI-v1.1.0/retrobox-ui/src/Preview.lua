-- Previews own copies of model content and disposable custom-render scopes.
do
    local function alive(self) return not self.Destroyed and self.Frame and self.Frame.Parent and not self._window.Destroyed end
    local function asset(value)
        assert(type(value)=='string' and #value<=2048,'Image must be an asset string of at most 2048 bytes')
        assert(value=='' or value:match('^rbxassetid://%d+$') or value:match('^rbxthumb://') or value:match('^rbxasset://'),'Use a Roblox image asset, thumbnail or built-in asset')
        return value
    end
    local function animationAsset(value)
        if finite(value) then assert(value>=1 and value<=9007199254740991 and value%1==0,'Animation Id must be a positive integer'); value='rbxassetid://'..string.format('%.0f',value) end
        assert(type(value)=='string' and value:match('^rbxassetid://%d+$'),'Animation must be a Roblox asset Id'); return value
    end
    local function view(value)
        value=value or {}; assert(type(value)=='table','View must be a table')
        local zoom,yaw,pitch=value.Zoom,value.Yaw,value.Pitch
        if zoom==nil then zoom=1 end; if yaw==nil then yaw=0 end; if pitch==nil then pitch=0 end
        assert(finite(zoom) and zoom>=.5 and zoom<=4,'Preview Zoom must be .5–4')
        assert(finite(yaw) and finite(pitch),'Preview angles must be finite')
        return {Zoom=zoom,Yaw=yaw%(math.pi*2),Pitch=clamp(pitch,-1.35,1.35)}
    end
    function Section:AddPreview(options)
        options=options or {}; local mode=options.Mode or (options.Model and 'Model' or options.Render and 'Custom' or 'Image')
        assert(mode=='Image' or mode=='Model' or mode=='Custom','Preview Mode must be Image, Model or Custom')
        assert(options.OnApply==nil or type(options.OnApply)=='function','OnApply must be a function')
        assert(options.OnCancel==nil or type(options.OnCancel)=='function','OnCancel must be a function')
        assert(options.Render==nil or type(options.Render)=='function','Render must be a function')
        if mode=='Image' then asset(options.Image or '') end
        if mode=='Model' then assert(typeof(options.Model)=='Instance' and (options.Model:IsA('Model') or options.Model:IsA('BasePart')),'Model preview needs a Model or BasePart') end
        if mode=='Custom' then assert(type(options.Render)=='function','Custom preview needs Render(container,scope,preview)') end
        local initial=view(options.View); local height=options.Height or 280
        assert(finite(height) and height>=180 and height<=800,'Preview Height must be 180–800')
        local self=base(self,'Preview',options,height); self.Persist=false; self.Mode=mode; self._view=initial; self._initialView=copy(initial)
        local window=self._window
        local top=#self.Description>0 and 48 or 28
        self.Container=frame(window,self.Frame,{Name='PreviewContent',Position=U2(0,top),Size=UDim2.new(1,0,1,-top-42),BorderSizePixel=1,ClipsDescendants=true,Active=true},'Inset')
        window:_bind(self.Container,{BorderColor3='Border'})
        self.Toolbar=frame(window,self.Frame,{Position=UDim2.new(0,0,1,-37),Size=UDim2.new(1,0,0,34),BackgroundTransparency=1})
        function self:_normalize(value) assert(type(value)=='string','Preview Value must be text'); if self.Mode=='Image' then asset(value) end; return value end
        function self:_render() if alive(self) and self.Mode=='Image' and self.Image then self.Image.Image=self.Value or ''; self:_drawView() end end
        function self:_clearContent()
            self:StopAnimation()
            if self._contentScope then self._contentScope:Destroy(); self._contentScope=nil end
            local nodes=self.Container and self.Container:GetChildren() or {}
            for _,object in ipairs(nodes) do
                window:_forgetSkin(object); if object.Parent then object:Destroy() end
            end
            self.Image=nil; self.Viewport=nil; self.Camera=nil; self.World=nil; self.Model=nil; self._bounds=nil; self._modelName=nil
        end
        function self:GetView() return copy(self._view) end
        function self:SetView(value) assert(alive(self),'Preview has been destroyed'); self._view=view(value); self:_drawView(); return self end
        function self:SetZoom(value) local nextView=self:GetView(); nextView.Zoom=value; return self:SetView(nextView) end
        function self:Rotate(yaw,pitch) local nextView=self:GetView(); nextView.Yaw=yaw; nextView.Pitch=pitch or nextView.Pitch; return self:SetView(nextView) end
        function self:ResetView() return self:SetView(self._initialView) end
        function self:_drawView()
            if not alive(self) or not self.Container or not self.Container.Parent then return end
            local v=self._view
            if self.Image and self.Image.Parent then
                self.Image.Size=UDim2.fromScale(v.Zoom,v.Zoom); self.Image.Position=UDim2.fromScale(.5,.5); self.Image.Rotation=math.deg(v.Yaw)
            elseif self.Camera and self.Camera.Parent and self.Viewport and self.Viewport.Parent and self._bounds then
                local size=self.Viewport.AbsoluteSize; local aspect=math.max(.01,size.X/math.max(1,size.Y))
                local angle=math.min(math.rad(35),math.atan(math.tan(math.rad(35))*aspect))
                local distance=math.max(.1,self._bounds.Radius/math.sin(angle)*1.15/v.Zoom)
                local cp=math.cos(v.Pitch); local offset=Vector3.new(math.sin(v.Yaw)*cp,math.sin(v.Pitch),math.cos(v.Yaw)*cp)*distance
                self.Camera.CFrame=CFrame.new(self._bounds.Center+offset,self._bounds.Center)
                self.Camera.Focus=CFrame.new(self._bounds.Center)
            end
        end
        function self:SetImage(value)
            assert(alive(self),'Preview has been destroyed'); asset(value)
            self:_clearContent(); self.Mode='Image'
            self.Image=ui(window,'ImageLabel',{Parent=self.Container,Name='PreviewImage',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
                Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Image=value,ScaleType=Enum.ScaleType.Fit})
            self:SetValue(value,true); self:_drawView(); return self
        end
        function self:SetModel(source)
            assert(alive(self),'Preview has been destroyed')
            assert(typeof(source)=='Instance' and (source:IsA('Model') or source:IsA('BasePart')),'Model must be a Model or BasePart')
            assert(source.Archivable~=false,'Model must be Archivable; the source is never changed')
            local descendants=source:GetDescendants(); assert(#descendants<=1024,'Preview model limit is 1024 descendants')
            -- Engine cloning can fail on an inaccessible/destroyed source. Keep the
            -- old preview until the replacement has been cloned and measured.
            local ok,clone=pcall(source.Clone,source)
            assert(ok and clone,'Could not clone preview model: '..tostring(clone))
            local valid,bounds,size=pcall(function()
                if clone:IsA('Model') then return clone:GetBoundingBox() end
                return clone.CFrame,clone.Size
            end)
            if not valid then clone:Destroy(); error('Could not measure preview model: '..tostring(bounds),2) end
            local radius=size.Magnitude/2
            if not finite(bounds.Position.X) or not finite(bounds.Position.Y) or not finite(bounds.Position.Z) or not finite(radius) or radius<=0 then clone:Destroy(); error('Preview model needs finite, nonempty bounds',2) end
            for _,object in ipairs(clone:GetDescendants()) do if object:IsA('LuaSourceContainer') then object:Destroy() end end
            self:_clearContent(); self.Mode='Model'; self._modelName=source.Name
            self.Viewport=ui(window,'ViewportFrame',{Parent=self.Container,Name='ModelViewport',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
                Ambient=RGB(200,200,200),LightColor=RGB(220,220,220),LightDirection=Vector3.new(-1,-1,-1)})
            self.World=ui(window,'WorldModel',{Parent=self.Viewport,Name='PreviewWorld'})
            self.Camera=ui(window,'Camera',{Parent=self.Viewport,FieldOfView=70})
            self.Viewport.CurrentCamera=self.Camera; clone.Parent=self.World; self.Model=clone
            self._bounds={Center=bounds.Position,Radius=radius}
            self:SetValue(tostring(source.Name or 'Model'),true); self:_drawView(); return self
        end
        function self:SetRenderer(renderer)
            assert(alive(self) and type(renderer)=='function','SetRenderer requires a live preview and a function')
            self:_clearContent(); self.Mode='Custom'; local scope=self:CreateScope(); self._contentScope=scope
            local ok,resource=window:_protected(renderer,{Phase='Preview',ControlId=self.Id},self.Container,scope,self)
            if not ok then
                self:_clearContent(); self:SetValue('',true); return false,resource
            end
            if resource and alive(self) and not scope.Destroyed then scope:Add(resource) end
            if alive(self) then self:SetValue('Custom',true) end
            return true
        end
        function self:StopAnimation()
            if self._animationScope then self._animationScope:Destroy(); self._animationScope=nil end
            self.AnimationTrack=nil; return self
        end
        function self:PlayAnimation(id,settings)
            assert(alive(self) and self.Mode=='Model' and self.Model,'PlayAnimation needs a model preview')
            id=animationAsset(id); settings=settings or {}
            local speed=settings.Speed or 1; assert(finite(speed) and speed>=0 and speed<=8,'Animation Speed must be 0–8')
            assert(settings.Looped==nil or type(settings.Looped)=='boolean','Animation Looped must be boolean')
            local host=self.Model:FindFirstChildWhichIsA('Humanoid',true) or self.Model:FindFirstChildWhichIsA('AnimationController',true)
            if not host then return false,'The preview model has no Humanoid or AnimationController' end
            local animator=host:FindFirstChildWhichIsA('Animator')
            if not animator then animator=ui(window,'Animator',{Parent=host}) end
            local animation=ui(window,'Animation',{AnimationId=id})
            local ok,track=pcall(animator.LoadAnimation,animator,animation)
            if not ok then animation:Destroy(); return false,tostring(track) end
            self:StopAnimation(); local scope=self:CreateScope(); self._animationScope=scope
            scope:Add(animation,'Destroy'); scope:Add(function() track:Stop(0); track:Destroy() end)
            local started,reason=pcall(function() track.Looped=settings.Looped==true; track:Play(0,1,speed) end)
            if not started then self:StopAnimation(); return false,tostring(reason) end
            self.AnimationTrack=track; return true,track
        end
        function self:GetPreview()
            return {Mode=self.Mode,Image=self.Mode=='Image' and self:GetValue() or nil,ModelName=self._modelName,View=self:GetView()}
        end
        local function dispatch(callback)
            local epoch=self._callbackEpoch; local snapshot=self:GetPreview()
            window:_dispatch(function() if alive(self) and self._callbackEpoch==epoch then callback(snapshot,self) end end,{Phase='Preview',ControlId=self.Id},snapshot)
        end
        function self:Apply() if alive(self) and not self.Disabled and options.OnApply then dispatch(options.OnApply) end; return self end
        function self:Cancel() if alive(self) then self:ResetView(); if options.OnCancel then dispatch(options.OnCancel) end end; return self end
        local buttons={
            {'-',function() self:SetZoom(clamp(self._view.Zoom/1.25,.5,4)) end},
            {'+',function() self:SetZoom(clamp(self._view.Zoom*1.25,.5,4)) end},
            {window:_t17('Repor','Reset'),function() self:ResetView() end},
            {window:_t17('Aplicar','Apply'),function() self:Apply() end},
            {window:_t17('Voltar','Cancel'),function() self:Cancel() end},
        }
        for i,entry in ipairs(buttons) do
            local object=button(window,self,self.Toolbar,entry[1],{Position=UDim2.new((i-1)/5,2,0,0),Size=UDim2.new(1/5,-4,1,0),TextSize=10},entry[2])
            if i==4 then self.ApplyButton=object; object.Visible=options.OnApply~=nil elseif i==5 then self.CancelButton=object end
        end
        connect(self,self.Container.InputBegan,function(input)
            if not pointer(input) or self.Disabled then return end
            local start=point(input); local old=self:GetView()
            window:_beginDrag(self,input,function(current)
                if not alive(self) then return end
                local delta=current-start
                self:Rotate(old.Yaw+delta.X*.012,self.Mode=='Model' and old.Pitch+delta.Y*.012 or 0)
            end)
        end)
        connect(self,self.Container.InputChanged,function(input)
            if input.UserInputType==Enum.UserInputType.MouseWheel and not self.Disabled and window._shown~=false and not window._dialog then self:SetZoom(clamp(self._view.Zoom*(input.Position.Z>0 and 1.15 or 1/1.15),.5,4)) end
        end)
        connect(self,self.Container:GetPropertyChangedSignal('AbsoluteSize'),function() self:_drawView() end)
        self:Manage(function() self:_clearContent(); self.Container=nil; self.Toolbar=nil; self.ApplyButton=nil; self.CancelButton=nil end,nil,'preview-content')
        local initialOptions={}; for k,v in pairs(options) do if k~='State' and k~='Default' then initialOptions[k]=v end end
        init(self,initialOptions,'')
        local ok,reason=pcall(function()
            if mode=='Image' then self:SetImage(options.Image or '') elseif mode=='Model' then self:SetModel(options.Model) else assert(self:SetRenderer(options.Render)) end
            if options.State then self:BindState(options.State,{TwoWay=false}) end
        end)
        if not ok then self:Destroy(); error(reason,2) end
        return self
    end
end
