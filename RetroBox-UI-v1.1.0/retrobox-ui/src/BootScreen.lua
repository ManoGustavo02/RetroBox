-- RetroBox 2.12 boot screen: a short, skippable startup sequence that plays
-- over the window while the script finishes building it. It never delays the
-- script itself; only the presentation waits. Every timer is owned by a scope.
do
    local styles={Boot=true,Card=true}
    local function bootOptions(options)
        options=options or {}
        assert(type(options)=='table','BootScreen options must be a table')
        assert(options.Style==nil or styles[options.Style],'LoadingScreen Style must be Boot or Card')
        for _,key in ipairs({'Title','Subtitle','Message'}) do
            assert(options[key]==nil or type(options[key])=='string' and #options[key]<=256,'Boot '..key..' must contain at most 256 bytes')
        end
        assert(options.Duration==nil or finite(options.Duration) and options.Duration>=.6 and options.Duration<=8,'Boot Duration must be .6–8 seconds')
        assert(options.Skippable==nil or type(options.Skippable)=='boolean','Boot Skippable must be boolean')
        assert(options.OnComplete==nil or type(options.OnComplete)=='function','Boot OnComplete must be a function')
        if options.Steps~=nil then
            assert(type(options.Steps)=='table' and #options.Steps>=1 and #options.Steps<=8,'Boot Steps must contain 1–8 texts')
            for _,step in ipairs(options.Steps) do assert(type(step)=='string' and #step>=1 and #step<=96,'Each boot step must contain 1–96 bytes') end
        end
        return options
    end
    Library._bootOptions=bootOptions
    local function prefix(text,count)
        local ok,offset=pcall(utf8.offset,text,count+1)
        if ok and offset then return text:sub(1,offset-1) end
        return text
    end
    local function length(text)
        local ok,size=pcall(utf8.len,text)
        return ok and size or #text
    end
    function Window:_bootStats()
        local tabs,controls=0,0
        for _,tab in ipairs(self.Tabs or {}) do if not tab.Hidden and tab~=self._settingsTab and tab~=self.NewsTab then tabs=tabs+1 end end
        for _,control in pairs(self.Controls) do if not control._internal and not control.Destroyed then controls=controls+1 end end
        return tabs,controls
    end
    function Window:ShowBootScreen(options)
        assert(not self.Destroyed,'Window has been destroyed')
        options=bootOptions(options)
        if self._boot then self._boot:Destroy() end
        local window=self
        local animated=self:_motionAllowed(self.Main)
        local duration=options.Duration or 2
        local cells=24
        local owner={Scope=self:CreateScope(),Blocking=true,Progress=0,Animated=animated,Duration=duration,Lines={},Cells={}}
        -- Root covers the whole window, title bar included, like a monitor warming up.
        owner.Frame=frame(self,self.Main,{Name='BootScreen',Size=UDim2.fromScale(1,1),ZIndex=300,Active=true,ClipsDescendants=true},'Background')
        owner.Frame:SetAttribute('RetroBoxMotion',true)
        owner.Backdrop=ui(self,'TextButton',{Parent=owner.Frame,Name='BootSkip',Size=UDim2.fromScale(1,1),Text='',BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Active=true,ZIndex=300})
        local stage=frame(self,owner.Frame,{Name='BootStage',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(1,-48,0,300),BackgroundTransparency=1,ZIndex=301})
        local constraint=ui(self,'UISizeConstraint',{Parent=stage,MaxSize=Vector2.new(560,300)})
        owner.Stage=stage; owner.Constraint=constraint
        -- Emblem: the window's pixel icon, inflated from a small seed.
        local emblem=frame(self,stage,{Name='BootEmblem',AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,0),Size=U2(56,56),BackgroundTransparency=1,ZIndex=302})
        local emblemScale=ui(self,'UIScale',{Parent=emblem,Scale=animated and .35 or 1})
        local spec=self._titleIcon and self._titleIcon.Spec
        owner.Icon=iconSlot(self,emblem,spec,'retrobox',48,U2(4,4),'Accent')
        owner.Emblem=emblem; owner.EmblemScale=emblemScale
        local title=tostring(options.Title or self.Title or 'RetroBox')
        owner.TitleText=title
        owner.TitleLabel=label(self,stage,animated and '' or title,{Name='BootTitle',Position=U2(0,64),Size=UDim2.new(1,0,0,30),TextSize=22,
            TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=302})
        local subtitle=options.Subtitle or (self.Subtitle~='' and self.Subtitle) or ('RetroBox UI v'..Library.Version)
        owner.SubtitleLabel=label(self,stage,subtitle,{Name='BootSubtitle',Position=U2(0,95),Size=UDim2.new(1,0,0,18),TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd,TextTransparency=animated and 1 or 0,ZIndex=302},'Muted')
        -- Boot log: a sunken terminal with one row per step and an [ OK ] stamp.
        local log=frame(self,stage,{Name='BootLog',Position=U2(0,124),Size=UDim2.new(1,0,0,112),ZIndex=302},'Inset')
        bevel(self,log,true)
        owner.Log=log
        local tabs,controls=self:_bootStats()
        local steps=options.Steps or {
            'RetroBox UI v'..Library.Version..' · API 2',
            self:_t17('Tema ','Theme ')..tostring(self.Theme)..' · '..#Library:GetIconNames()..self:_t17(' ícones',' icons'),
            '__layout',
            self:_t17('Preferências e perfis','Preferences and profiles'),
        }
        owner.Steps={}
        for index,text in ipairs(steps) do
            local row=frame(self,log,{Name='BootLine',Position=U2(10,8+(index-1)*(96/#steps)),Size=UDim2.new(1,-20,0,math.min(22,96/#steps)),BackgroundTransparency=1,Visible=not animated,ZIndex=303})
            local caption=label(self,row,'',{Name='Text',Size=UDim2.new(1,-60,1,0),TextSize=12,Font=Enum.Font.Code,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=303})
            local status=label(self,row,animated and '' or '[ OK ]',{Name='Status',Position=UDim2.new(1,-56,0,0),Size=UDim2.new(0,56,1,0),TextSize=12,Font=Enum.Font.Code,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=303},'Success')
            owner.Lines[index]={Row=row,Text=caption,Status=status,Source=text}
            owner.Steps[index]=text
        end
        local function stepText(source)
            if source=='__layout' then
                tabs,controls=window:_bootStats()
                return window:_t17('Montando ','Building ')..tabs..window:_t17(' abas · ',' tabs · ')..controls..window:_t17(' controles',' controls')
            end
            return source
        end
        for _,line in ipairs(owner.Lines) do line.Text.Text='> '..stepText(line.Source) end
        owner.Cursor=frame(self,log,{Name='BootCursor',Size=U2(7,12),Visible=false,ZIndex=304},'Accent')
        -- Progress: discrete cells, filled in order, plus a three-digit percent.
        local bar=frame(self,stage,{Name='BootProgress',Position=U2(0,248),Size=UDim2.new(1,-52,0,12),BackgroundTransparency=1,ZIndex=302})
        owner.Bar=bar
        for index=1,cells do
            owner.Cells[index]=frame(self,bar,{Name='BootCell',Position=UDim2.new((index-1)/cells,1,0,0),Size=UDim2.new(1/cells,-2,1,0),ZIndex=303},'Border')
        end
        owner.PercentLabel=label(self,stage,animated and '000%' or '100%',{Name='BootPercent',Position=UDim2.new(1,-48,0,244),Size=U2(48,20),TextSize=12,Font=Enum.Font.Code,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=302},'Muted')
        owner.HintLabel=label(self,stage,options.Skippable~=false and self:_t17('Clique para pular','Click to skip') or (options.Message or ''),{Name='BootHint',Position=U2(0,272),Size=UDim2.new(1,0,0,18),TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Center,TextTransparency=animated and 1 or .2,ZIndex=302},'Muted')
        if options.Message and options.Skippable~=false then owner.HintLabel.Text=options.Message..'  ·  '..owner.HintLabel.Text end
        -- Scan line sweeping the screen; one tween at a time, owned by the boot.
        owner.Scan=frame(self,owner.Frame,{Name='BootScan',Size=UDim2.new(1,0,0,2),BackgroundTransparency=.82,Visible=animated,ZIndex=305},'Highlight')

        local function paint(progress)
            if owner.Destroyed then return end
            owner.Progress=progress
            local filled=math.floor(progress*cells+.5)
            for index,cell in ipairs(owner.Cells) do
                local on=index<=filled
                if cell:GetAttribute('On')~=on then
                    cell:SetAttribute('On',on)
                    window:_bind(cell,{BackgroundColor3=on and 'Accent' or 'Border'})
                    if on and animated then cell.BackgroundTransparency=.6; window:_motion(cell,{BackgroundTransparency=0},.12,'boot-cell',owner) end
                end
            end
            owner.PercentLabel.Text=string.format('%03d%%',math.floor(progress*100+.5))
        end
        local timers={}
        local function later(delay,callback)
            local thread=task.delay(delay,function()
                if owner.Destroyed or window.Destroyed then return end
                callback()
            end)
            timers[#timers+1]=thread
            return thread
        end
        owner.Scope:Add(function()
            for _,thread in ipairs(timers) do if coroutine.status(thread)=='suspended' then pcall(task.cancel,thread) end end
            timers={}
        end)
        function owner:SetProgress(value)
            assert(not self.Destroyed and finite(value) and value>=0 and value<=1,'Boot progress must be 0–1')
            if not self.Finishing then paint(math.max(self.Progress,value)) end
            return self
        end
        function owner:Destroy()
            if self.Destroyed then return end
            self.Destroyed=true
            if window._boot==self then window._boot=nil end
            local object=self.Frame
            self.Scope:Destroy()
            if object then window:_forgetSkin(object); if not self._engineDestroying and object.Parent then object:Destroy() end end
            self.Frame=nil;self.Stage=nil;self.Log=nil;self.Bar=nil;self.Cells={};self.Lines={};self.Icon=nil
            if not self.Completed and not window.Destroyed then
                self.Completed=true
                if type(options.OnComplete)=='function' then call(window,options.OnComplete,self.Skipped==true) end
            end
        end
        local function reveal()
            if window.Destroyed then return end
            if window._powerOn and window._shown~=false then window:_powerOn() end
            if window.ActiveTab and window._revealPage then window:_revealPage(window.ActiveTab) end
        end
        function owner:Finish(skipped)
            if self.Destroyed or self.Finishing then return self end
            self.Finishing=true; self.Skipped=skipped==true
            paint(1)
            for _,line in ipairs(self.Lines) do line.Row.Visible=true; line.Status.Text='[ OK ]' end
            if self.Cursor then self.Cursor.Visible=false end
            if not animated or not window:_motionAllowed(self.Frame) then self:Destroy(); reveal(); return self end
            -- CRT power-off: fade the content, fold the screen into a line, then a dot.
            for _,object in ipairs(self.Frame:GetDescendants()) do
                if object:IsA('TextLabel') then window:_motion(object,{TextTransparency=1},.14,'boot-exit',self) end
            end
            self.Frame.AnchorPoint=Vector2.new(.5,.5); self.Frame.Position=UDim2.fromScale(.5,.5)
            window:_animate(self.Stage,{Position=UDim2.new(.5,0,.5,-6)},.14,'boot-stage',self,nil,{Easing='Quint'})
            window:_animate(self.Frame,{Size=UDim2.new(1,0,0,2)},.2,'boot-fold',self,function()
                if self.Destroyed then return end
                window:_bind(self.Frame,{BackgroundColor3='Accent'})
                window:_animate(self.Frame,{Size=UDim2.new(0,6,0,2),BackgroundTransparency=.2},.12,'boot-fold',self,function()
                    self:Destroy(); reveal()
                end,{Easing='Quint',Direction='In'})
            end,{Easing='Quint',Direction='In'})
            return self
        end
        function owner:Skip()
            if self.Destroyed or self.Finishing then return self end
            if options.Skippable==false then return self end
            return self:Finish(true)
        end
        self._boot=owner
        owner.Scope:Add(function() owner:Destroy() end)
        owner.Scope:Add(owner.Frame.Destroying:Connect(function() owner._engineDestroying=true; owner:Destroy() end),'Disconnect')
        owner.Scope:Add(owner.Backdrop.Activated:Connect(function() owner:Skip() end),'Disconnect')
        owner.Scope:Add(UserInputService.InputBegan:Connect(function(input,processed)
            if not processed and input.UserInputType==Enum.UserInputType.Keyboard and window._shown~=false and (input.KeyCode==Enum.KeyCode.Return or input.KeyCode==Enum.KeyCode.Space or input.KeyCode==Enum.KeyCode.Escape) then owner:Skip() end
        end),'Disconnect')
        -- Hiding the window ends the presentation; it never replays on Show.
        owner.Scope:Add(self.Main:GetPropertyChangedSignal('Visible'):Connect(function() if not window.Main.Visible then owner:Finish(true) end end),'Disconnect')

        if not animated then
            paint(1)
            later(math.min(duration,.8),function() owner:Finish(false) end)
            return owner
        end
        -- Choreography: emblem → typed title → subtitle → log rows → full bar.
        window:_animate(emblemScale,{Scale=1},.42,'boot-emblem',owner,nil,{Easing='Back'})
        local typing=math.min(.5,duration*.22); local total=length(title)
        local count=math.min(total,32); local stride=total/math.max(1,count)
        for index=1,count do
            later(.12+typing*index/count,function() owner.TitleLabel.Text=prefix(title,math.min(total,math.floor(index*stride+.5))) end)
        end
        later(.12+typing+.02,function()
            owner.TitleLabel.Text=title
            window:_motion(owner.SubtitleLabel,{TextTransparency=0},.2,'boot-subtitle',owner)
            window:_motion(owner.HintLabel,{TextTransparency=.2},.3,'boot-hint',owner)
        end)
        local start=.12+typing+.08; local span=math.max(.3,duration-start-.25)
        for index,line in ipairs(owner.Lines) do
            local at=start+span*(index-1)/#owner.Lines
            later(at,function()
                line.Text.Text='> '..stepText(line.Source)
                line.Row.Visible=true; line.Text.TextTransparency=.6
                window:_motion(line.Text,{TextTransparency=0},.14,'boot-line',owner)
                owner.Cursor.Visible=true
                owner.Cursor.Position=U2(10+math.min(line.Row.AbsoluteSize.X-70,(length(line.Text.Text)*7)),line.Row.Position.Y.Offset+5)
                paint(math.max(owner.Progress,(index-.5)/#owner.Lines))
            end)
            later(at+span/#owner.Lines*.7,function()
                line.Status.Text='[ OK ]'; line.Status.TextTransparency=.5
                window:_motion(line.Status,{TextTransparency=0},.12,'boot-ok',owner)
                paint(math.max(owner.Progress,index/#owner.Lines))
            end)
        end
        -- Cursor blink and scan sweep are bounded by the boot's own lifetime.
        local function blink()
            later(.38,function()
                if owner.Finishing then return end
                if owner.Cursor and owner.Lines[1].Row.Visible then owner.Cursor.BackgroundTransparency=owner.Cursor.BackgroundTransparency==0 and 1 or 0 end
                blink()
            end)
        end
        blink()
        local function sweep()
            if owner.Destroyed or owner.Finishing or not owner.Scan then return end
            owner.Scan.Position=UDim2.new(0,0,0,0)
            window:_animate(owner.Scan,{Position=UDim2.new(0,0,1,0)},1.1,'boot-scan',owner,function() later(.25,sweep) end,{Easing='Linear',Exact=true})
        end
        sweep()
        later(duration,function() owner:Finish(false) end)
        return owner
    end
    function Window:GetBootScreen() return self._boot end
end
