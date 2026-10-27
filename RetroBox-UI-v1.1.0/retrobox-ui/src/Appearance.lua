-- Shared appearance effects: bounded, observable and owned by window scopes.
do
    local function within(object,root)
        while object do if object==root then return true end;object=object.Parent end
        return false
    end
    function Window:_paletteFor(object)
        while object do
            local colors=self._paletteScopes and self._paletteScopes[object]
            if colors then return colors end
            object=object.Parent
        end
        return self.Palette
    end
    function Window:_reskin(root)
        for object,roles in pairs(self._skin) do
            if object.Parent and within(object,root) then
                for property,role in pairs(roles) do object[property]=self:_paletteFor(object)[role] end
                self:_refreshInk(object)
            end
        end
    end
    function Window:_revealPage(tab)
        if not self:_motionAllowed(tab.Container) then return end
        local count,seen=0,{}
        for _,section in ipairs(tab.Sections) do
            for _,control in ipairs(section.Controls) do
                if not control.Destroyed and not seen[control] then
                    seen[control]=true
                    for _,object in ipairs({control.TitleLabel,control.DescriptionLabel}) do
                        if object and object.Visible and self:_motionAllowed(object) then
                            self:_revealText(object,control,'page-enter');count=count+1
                            if count>=48 then return end
                        end
                    end
                end
            end
        end
    end
    -- Overlays live outside clipped pages, but inherit the palette of their
    -- anchor. Keep their original bounds, keyboard behavior and disposal scope.
    local contextMenu=Window.ContextMenu
    function Window:ContextMenu(options,anchor)
        local owner,err=contextMenu(self,options,anchor)
        if owner and typeof(anchor)=='Instance' then
            self._paletteScopes=self._paletteScopes or {}
            local root=owner.Frame;local colors=self:_paletteFor(anchor)
            self._paletteScopes[root]=colors~=self.Palette and colors or nil
            owner.Scope:Add(function() self._paletteScopes[root]=nil end)
            self:_reskin(root)
        end
        return owner,err
    end
    local showTooltip=Window._showTooltip
    function Window:_showTooltip(control,...)
        local result=showTooltip(self,control,...)
        if result and self.TooltipFrame then
            self._paletteScopes=self._paletteScopes or {}
            local colors=self:_paletteFor(control.Frame)
            self._paletteScopes[self.TooltipFrame]=colors~=self.Palette and colors or nil
            self:_reskin(self.TooltipFrame)
        end
        return result
    end
    local forget=Window._forgetSkin
    function Window:_forgetSkin(root)
        if self._paletteScopes then
            for object in pairs(self._paletteScopes) do if within(object,root) then self._paletteScopes[object]=nil end end
        end
        forget(self,root)
    end
    local function visible(window,object)
        if window.Destroyed or window._closing or not object or not object.Parent then return false end
        while object and object~=window.Gui do
            if object==window.Main and (window._shown==false or window.Minimized) then return false end
            if object:IsA('GuiObject') and object.Visible==false then return false end
            object=object.Parent
        end
        return object==window.Gui
    end
    -- Ancestor visibility is observed only for mounted effects. No polling is
    -- needed to discover a hidden tab/window, and idle effects release Heartbeat.
    function Window:_watchEffect(object,scope,refresh)
        local ancestry=scope:Child()
        local function watch()
            ancestry:Clean()
            if not object.Parent then refresh();return end
            local parent=object
            while parent and parent~=self.Gui do
                if parent:IsA('GuiObject') then ancestry:Add(parent:GetPropertyChangedSignal('Visible'):Connect(refresh),'Disconnect') end
                if parent~=object then ancestry:Add(parent:GetPropertyChangedSignal('Parent'):Connect(watch),'Disconnect') end
                parent=parent.Parent
            end
            refresh()
        end
        scope:Add(object:GetPropertyChangedSignal('Parent'):Connect(watch),'Disconnect')
        watch()
    end
    local defaults={Enabled=true,Speed=.15,Phase=0,Saturation=.82,Brightness=1,Contrast=4.5}
    local function rgbOptions(value,current)
        if value==true then value={} elseif value==false then value={Enabled=false} end
        assert(type(value)=='table','RGB must be boolean or an options table')
        local result=copy(current or defaults)
        for name,item in pairs(value) do assert(defaults[name]~=nil,'Unknown RGB option: '..tostring(name));result[name]=item end
        assert(type(result.Enabled)=='boolean','RGB Enabled must be boolean')
        for name,range in pairs({Speed={.01,4},Phase={0,1},Saturation={0,1},Brightness={.25,1},Contrast={1,7}}) do
            assert(finite(result[name]) and result[name]>=range[1] and result[name]<=range[2],'Invalid RGB '..name)
        end
        return result
    end
    Library._validateTextRGB=rgbOptions
    local function restore(window,effect)
        local object=effect.Target
        if not object or not object.Parent or effect._engineDestroying then return end
        local role=(window._skin[object] or {}).TextColor3
        object.TextColor3=role and window:_ink(role,object) or effect.Original
    end
    function Window:_paintTextRGB(effect)
        if not effect.Target or not effect.Target.Parent then return end
        if not effect.Options.Enabled or not self:_motionAllowed(effect.Target) then restore(self,effect);return end
        local o=effect.Options
        local color=Color3.fromHSV((effect.Hue+o.Phase)%1,o.Saturation,o.Brightness)
        effect.Target.TextColor3=Library:ReadableColor(color,self:_surfaceColor(effect.Target),o.Contrast)
    end
    function Window:SetRGB(target,options)
        assert(not self.Destroyed and typeof(target)=='Instance' and
            (target:IsA('TextLabel') or target:IsA('TextButton') or target:IsA('TextBox')),'RGB target must be a live text Instance')
        assert(target.Parent and within(target,self.Gui),'RGB target must belong to this window')
        local settings=rgbOptions(options==nil and true or options)
        self._textRGB=self._textRGB or {}
        local old=self._textRGB[target]
        if old then old:SetOptions(settings);return old end
        local count=0;for _ in pairs(self._textRGB) do count=count+1 end
        assert(count<128,'A window supports at most 128 RGB text effects')
        local window=self
        local effect={Target=target,Options=settings,Hue=0,Original=target.TextColor3,Scope=self:CreateScope()}
        function effect:GetOptions() return copy(self.Options) end
        function effect:SetOptions(value)
            assert(not self.Destroyed,'RGB effect has been destroyed');self.Options=rgbOptions(value,self.Options)
            window:_paintTextRGB(self);window:_updateRGB();return self
        end
        function effect:SetEnabled(value) return self:SetOptions({Enabled=value}) end
        function effect:Destroy()
            if self.Destroyed then return end;self.Destroyed=true
            local object=self.Target;window._textRGB[object]=nil;restore(window,self)
            self.Scope:Destroy();self.Target=nil;self.Original=nil
            window:_updateRGB()
        end
        self._textRGB[target]=effect
        effect.Scope:Add(function() effect:Destroy() end)
        effect.Scope:Add(target.Destroying:Connect(function() effect._engineDestroying=true;effect:Destroy() end),'Disconnect')
        self:_watchEffect(target,effect.Scope,function()
            if effect.Destroyed then return end
            if not target.Parent or not within(target,window.Gui) then effect:Destroy();return end
            window:_paintTextRGB(effect);window:_updateRGB()
        end)
        return effect
    end
    local ink=Window._refreshInk
    function Window:_refreshInk(object)
        ink(self,object)
        local effect=self._textRGB and self._textRGB[object]
        if effect then self:_paintTextRGB(effect) end
    end
    function Control:SetRGB(options,part)
        assert(not self.Destroyed,'Control has been destroyed');part=part or 'Title'
        local target=({Title=self.TitleLabel,Description=self.DescriptionLabel,Value=self.ValueLabel,Button=self.Button})[part]
        assert(target,'This control has no text part: '..tostring(part))
        if options==false then
            local effect=self._window._textRGB and self._window._textRGB[target];if effect then effect:Destroy() end
        else self._window:SetRGB(target,options) end
        return self
    end
    function Window:SetTitleRGB(options)
        if options==false then local e=self._textRGB and self._textRGB[self.TitleLabel];if e then e:Destroy() end
        else self:SetRGB(self.TitleLabel,options) end
        return self
    end
    function Window:SetSubtitleRGB(options)
        if options==false then local e=self._textRGB and self._textRGB[self.SubtitleLabel];if e then e:Destroy() end
        else self:SetRGB(self.SubtitleLabel,options) end
        return self
    end
    function Window:_hasAppearanceWork()
        for object,effect in pairs(self._textRGB or {}) do
            if not effect.Destroyed and effect.Options.Enabled and visible(self,object) and self:_motionAllowed(object) then return true end
        end
        for effect in pairs(self._busyVisuals or {}) do
            if not effect.Destroyed and visible(self,effect.Frame) and self:_motionAllowed(effect.Frame) then return true end
        end
        return false
    end
    function Window:_stepAppearance(dt)
        for object,effect in pairs(self._textRGB or {}) do
            if not effect.Destroyed and effect.Options.Enabled and visible(self,object) and self:_motionAllowed(object) then
                effect.Hue=(effect.Hue+dt*effect.Options.Speed*self.Animations.Speed)%1;self:_paintTextRGB(effect)
            end
        end
        for effect in pairs(self._busyVisuals or {}) do
            if not effect.Destroyed and visible(self,effect.Frame) and self:_motionAllowed(effect.Frame) then
                effect.Elapsed=(effect.Elapsed+dt*self.Animations.Speed)%8
                local alpha=.38+(self.Animations.Intensity=='Subtle' and .06 or .15)*math.sin(effect.Elapsed*3)
                for index,bar in ipairs(effect.Bars) do if bar.Parent then bar.BackgroundTransparency=clamp(alpha+(index-1)*.06,0,1) end end
            end
        end
    end
    function Window:CreateSkeleton(options)
        options=options or {};assert(type(options)=='table','Skeleton options must be a table')
        local parent=options.Parent
        assert(not self.Destroyed and typeof(parent)=='Instance' and parent:IsA('GuiObject') and parent.Parent and within(parent,self.Gui),'Skeleton Parent must be a GUI object in this window')
        assert(options.Position==nil or typeof(options.Position)=='UDim2','Skeleton Position must be UDim2')
        assert(options.Size==nil or typeof(options.Size)=='UDim2','Skeleton Size must be UDim2')
        assert(options.Cover==nil or type(options.Cover)=='boolean','Skeleton Cover must be boolean')
        assert(options.ZIndex==nil or finite(options.ZIndex) and options.ZIndex%1==0 and options.ZIndex>=0 and options.ZIndex<=10000,'Invalid skeleton ZIndex')
        local lines=options.Lines==nil and 3 or options.Lines
        assert(finite(lines) and lines%1==0 and lines>=1 and lines<=8,'Skeleton Lines must be 1–8')
        self._busyVisuals=self._busyVisuals or {};local count=0;for _ in pairs(self._busyVisuals) do count=count+1 end
        assert(count<128,'A window supports at most 128 skeletons')
        local window=self;local effect={Scope=self:CreateScope(),Bars={},Elapsed=0}
        effect.Frame=frame(self,parent,{Name='LoadingSkeleton',Position=options.Position or U2(0,0),Size=options.Size or UDim2.fromScale(1,1),
            Active=false,ClipsDescendants=true,ZIndex=options.ZIndex or parent.ZIndex+2},options.Cover and 'Inset' or nil)
        for index=1,lines do
            effect.Bars[index]=frame(self,effect.Frame,{Name='SkeletonLine',Size=U2(0,0),BackgroundTransparency=.42,ZIndex=effect.Frame.ZIndex+1},'Border')
        end
        local function layout()
            if effect.Destroyed or not effect.Frame.Parent then return end
            local size=effect.Frame.AbsoluteSize;local scale=math.max(.01,window._actualScale or 1)
            local height=math.max(0,size.Y/scale);local inset=math.min(12,math.max(0,size.X/scale)*.08)
            local barHeight=math.min(12,height/lines*.5)
            for index,bar in ipairs(effect.Bars) do
                bar.Position=UDim2.new(0,inset,(index-.5)/lines,-barHeight/2)
                bar.Size=UDim2.new(index==lines and .62 or 1,index==lines and -inset or -2*inset,0,barHeight)
            end
        end
        layout();effect.Scope:Add(effect.Frame:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout),'Disconnect')
        function effect:SetVisible(value)
            if not self.Destroyed then self.Frame.Visible=value~=false;window:_updateRGB() end;return self
        end
        function effect:Destroy()
            if self.Destroyed then return end;self.Destroyed=true;window._busyVisuals[self]=nil
            local object=self.Frame;self.Scope:Destroy()
            if object then window:_forgetSkin(object);if not self._engineDestroying and object.Parent then object:Destroy() end end
            self.Frame=nil;self.Bars={};window:_updateRGB()
        end
        self._busyVisuals[effect]=true
        effect.Scope:Add(function() effect:Destroy() end)
        effect.Scope:Add(effect.Frame.Destroying:Connect(function() effect._engineDestroying=true;effect:Destroy() end),'Disconnect')
        self:_watchEffect(effect.Frame,effect.Scope,function()
            if effect.Destroyed then return end
            if not effect.Frame.Parent or not within(effect.Frame,window.Gui) then effect:Destroy();return end
            window:_updateRGB()
        end)
        return effect
    end
    function Section:AddSkeleton(options)
        options=options or {};local height=options.Height or 100
        assert(finite(height) and height>=48 and height<=500,'Skeleton Height must be 48–500')
        local lines=options.Lines==nil and 3 or options.Lines
        assert(finite(lines) and lines%1==0 and lines>=1 and lines<=8,'Skeleton Lines must be 1–8')
        local count=0;for _ in pairs(self._window._busyVisuals or {}) do count=count+1 end
        assert(count<128,'A window supports at most 128 skeletons')
        local self=base(self,'Skeleton',options,height);self.Persist=false
        self.Skeleton=self._window:CreateSkeleton({Parent=self.Frame,Lines=lines,Position=U2(0,26),Size=UDim2.new(1,0,1,-26)})
        function self:_normalize(value) assert(type(value)=='boolean','Skeleton state must be boolean');return value end
        function self:_render() self.Skeleton:SetVisible(self.Value) end
        function self:SetLoading(value) return self:SetValue(value,true) end
        self:Manage(self.Skeleton,'Destroy');return init(self,options,true)
    end
    function Control:SetLoading(value)
        assert(type(value)=='boolean' and not self.Destroyed,'Loading must be boolean on a live control')
        if value and not self._loadingSkeleton then
            self._loadingSkeleton=self._window:CreateSkeleton({Parent=self.Frame,Cover=true})
            self:Manage(self._loadingSkeleton,'Destroy','loading-skeleton')
        elseif not value and self._loadingSkeleton then
            self._loadingSkeleton:Destroy();self._resources:Remove('loading-skeleton',true);self._loadingSkeleton=nil
            for _,object in ipairs({self.TitleLabel,self.DescriptionLabel}) do self._window:_revealText(object,self,'loaded') end
        end
        self.Frame:SetAttribute('RetroBoxLoading',value)
        return self
    end
    local function loadingOptions(options)
        options=options or {};assert(type(options)=='table','LoadingScreen must be a table or boolean')
        for _,key in ipairs({'Title','Message'}) do assert(options[key]==nil or type(options[key])=='string' and #options[key]<=2048,'Invalid loading '..key) end
        assert(options.Blocking==nil or type(options.Blocking)=='boolean','Loading Blocking must be boolean')
        assert(options.Timeout==nil or finite(options.Timeout) and options.Timeout>=1 and options.Timeout<=120,'Loading Timeout must be 1–120 seconds')
        return options
    end
    function Window:ShowLoading(options)
        assert(not self.Destroyed,'Window has been destroyed');options=loadingOptions(options)
        if self._loading then self._loading:Destroy() end
        local count=0;for _ in pairs(self._busyVisuals or {}) do count=count+1 end
        assert(count<128,'A window supports at most 128 skeletons')
        self:_closeOverlay('loading');self:_hideTooltip();self:_hideSearchResults();self:_releaseBindings()
        local window=self;local owner={Scope=self:CreateScope(),Blocking=options.Blocking~=false,Progress=nil}
        owner.Frame=frame(self,self.Main,{Name='LoadingScreen',Position=U2(0,42),Size=UDim2.new(1,0,1,-42),ZIndex=180,Active=owner.Blocking,ClipsDescendants=true},'Background')
        local card=frame(self,owner.Frame,{Name='LoadingCard',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.45,0),Size=UDim2.new(.86,0,0,184),BorderSizePixel=1,ZIndex=181},'Surface')
        owner.Card=card
        self:_bind(card,{BorderColor3='Border'})
        owner.TitleLabel=label(self,card,options.Title or self.Title,{Position=U2(18,14),Size=UDim2.new(1,-36,0,32),TextSize=20,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=182})
        owner.MessageLabel=label(self,card,options.Message or self:_t17('Preparando interface…','Preparing interface…'),{Position=U2(18,51),Size=UDim2.new(1,-36,0,38),TextSize=12,TextWrapped=true,ZIndex=182},'Muted')
        local track=frame(self,card,{Position=UDim2.new(0,18,1,-21),Size=UDim2.new(1,-36,0,3),ZIndex=182},'Border')
        owner.Track=track
        owner.Fill=frame(self,track,{Size=UDim2.new(0,0,1,0),ZIndex=183},'Accent')
        owner.Skeleton=self:CreateSkeleton({Parent=card,Lines=2,Position=U2(6,93),Size=UDim2.new(1,-12,1,-126),ZIndex=182})
        owner.Scope:Add(owner.Skeleton,'Destroy')
        function owner:SetMessage(value)
            assert(not self.Destroyed and type(value)=='string' and #value<=2048,'Loading message must contain at most 2048 bytes')
            self.MessageLabel.Text=value;return self
        end
        function owner:SetProgress(value)
            assert(not self.Destroyed and (value==nil or finite(value) and value>=0 and value<=1),'Loading progress must be nil or 0–1')
            if self.Finishing then return self end
            self.Progress=value;self.Skeleton:SetVisible(value==nil)
            window:_motion(self.Fill,{Size=UDim2.new(value or 0,0,1,0)},.18,'loading-progress',self);return self
        end
        function owner:Destroy()
            if self.Destroyed then return end;self.Destroyed=true
            if window._loading==self then window._loading=nil end
            local object=self.Frame;self.Scope:Destroy()
            if object then window:_forgetSkin(object);if not self._engineDestroying and object.Parent then object:Destroy() end end
            self.Frame=nil;self.Fill=nil;self.TitleLabel=nil;self.MessageLabel=nil;self.Skeleton=nil;self.Card=nil;self.Track=nil
        end
        function owner:Finish(message)
            if self.Destroyed or self.Finishing then return self end
            if message then self:SetMessage(message) end
            self:SetProgress(1);self.Finishing=true
            window:_motion(self.Fill,{Size=UDim2.fromScale(1,1)},.16,'loading-progress',self,function()
                if self.Destroyed then return end
                for _,object in ipairs({self.TitleLabel,self.MessageLabel}) do window:_motion(object,{TextTransparency=1},.1,'loading-exit',self) end
                for _,object in ipairs({self.Card,self.Track,self.Fill}) do window:_motion(object,{BackgroundTransparency=1},.1,'loading-exit',self) end
                window:_motion(self.Frame,{BackgroundTransparency=1},.1,'loading-exit',self,function() self:Destroy() end)
            end)
            return self
        end
        self._loading=owner
        owner.Scope:Add(function() owner:Destroy() end)
        owner.Scope:Add(owner.Frame.Destroying:Connect(function() owner._engineDestroying=true;owner:Destroy() end),'Disconnect')
        -- A developer/network failure cannot leave the application behind an
        -- unbounded loading barrier. Timeout releases the overlay, no fake 100%.
        local timer=task.delay(options.Timeout or 20,function()
            owner.Scope:Remove('timeout',true);owner:Destroy()
        end)
        owner.Scope:Add(timer,function(thread) if coroutine.status(thread)=='suspended' then task.cancel(thread) end end,'timeout')
        self:_revealText(owner.TitleLabel,owner,'loading-enter')
        self:_revealText(owner.MessageLabel,owner,'loading-enter')
        return owner
    end
    local applyTheme=Window._applyTheme
    function Window:_applyTheme(...)
        applyTheme(self,...)
        self:_reskin(self.Gui)
    end
    for _,name in ipairs({'SetAnimations','SetReducedMotion','Show','Hide','Minimize'}) do
        local method=Window[name]
        Window[name]=function(self,...)
            local result=method(self,...)
            for _,effect in pairs(self._textRGB or {}) do self:_paintTextRGB(effect) end
            self:_updateRGB();return result
        end
    end
    local createWindow=Library.CreateWindow
    function Library:CreateWindow(options)
        options=options or {}
        assert(options.LoadingScreen==nil or type(options.LoadingScreen)=='boolean' or type(options.LoadingScreen)=='table','LoadingScreen must be boolean or table')
        if type(options.LoadingScreen)=='table' then loadingOptions(options.LoadingScreen) end
        for _,key in ipairs({'TitleRGB','SubtitleRGB'}) do if options[key]~=nil then rgbOptions(options[key]) end end
        local window=createWindow(self,options)
        if options.TitleRGB then window:SetTitleRGB(options.TitleRGB) end
        if options.SubtitleRGB then window:SetSubtitleRGB(options.SubtitleRGB) end
        if options.LoadingScreen~=false and (options.LoadingScreen~=nil or window:_motionAllowed(window.Main)) then
            local startup=copy(type(options.LoadingScreen)=='table' and options.LoadingScreen or {})
            if startup.Blocking==nil then startup.Blocking=false end
            local loading=window:ShowLoading(startup)
            local pending=task.defer(function()
                loading.Scope:Remove('ready',true)
                if not loading.Destroyed then loading:Finish(window:_t17('Interface pronta','Interface ready')) end
            end)
            loading.Scope:Add(pending,function(thread) if coroutine.status(thread)=='suspended' then task.cancel(thread) end end,'ready')
        end
        return window
    end
end
