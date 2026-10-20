-- Compact views share the window's States, tasks, palette and resource scopes.
do
    local Overlay={}; Overlay.__index=Overlay
    local Item={}; Item.__index=Item
    local compatible={StatCard=true,Progress=true,ProgressChart=true,Label=true,Stepper=true}
    local function identifier(value)
        assert(type(value)=='string' and #value>=1 and #value<=128 and not value:find('%c'),'Id must contain 1–128 bytes without control characters')
        return value
    end
    local function live(owner)
        return not owner.Destroyed and owner.Frame and owner.Frame.Parent and not owner._window.Destroyed
    end
    local function boolean(value,name) assert(type(value)=='boolean',name..' must be boolean'); return value end
    local function checkedLayout(value,kind)
        assert(type(value)=='table','Layout must be a table')
        local result={}
        for key,v in pairs(value) do
            if key=='Position' then
                if typeof(v)=='Vector2' then result.Position=normalizedPosition(v)
                else assert(type(v)=='table','Invalid Position'); result.Position=normalizedPosition(Vector2.new(v.X,v.Y)) end
            elseif key=='Scale' then assert(finite(v) and v>=.65 and v<=1.5,'Scale must be .65–1.5'); result.Scale=v
            elseif key=='Opacity' then assert(finite(v) and v>=.2 and v<=1,'Opacity must be .2–1'); result.Opacity=v
            elseif key=='Width' then assert(finite(v) and v>=220 and v<=800,'Width must be 220–800'); result.Width=v
            elseif key=='MaxHeight' then assert(finite(v) and v>=100 and v<=800,'MaxHeight must be 100–800'); result.MaxHeight=v
            elseif key=='Orientation' then assert(v=='Vertical' or v=='Horizontal','Orientation must be Vertical or Horizontal'); result.Orientation=v
            elseif key=='Visible' or key=='Collapsed' or key=='Pinned' or key=='VisibleWithMenu' then result[key]=boolean(v,key)
            elseif key=='Pins' and kind=='HUD' then
                assert(type(v)=='table','Pins must be a map'); result.Pins={}; local n=0
                for source,record in pairs(v) do
                    n=n+1; assert(n<=32,'HUD pin limit is 32'); identifier(source)
                    assert(type(record)=='table','Invalid pin record'); result.Pins[source]={Id=identifier(record.Id)}
                end
            else error('Unknown compact layout field: '..tostring(key)) end
        end
        return result
    end
    local function checkPins(hud,pins)
        local ids,n={},0
        for source,record in pairs(pins) do
            assert(not ids[record.Id],'Duplicate pin item Id'); ids[record.Id]=true; n=n+1
            local item=hud._items[record.Id]
            assert(not item or item.Source and item.Source.Id==source,'Pin Id collides with another widget')
            local control=hud._window.Controls[source]
            assert(not control or compatible[control.Type],'This control cannot be pinned')
        end
        for _,item in ipairs(hud.Items) do if not item.Destroyed and not item.Source then n=n+1 end end
        assert(n<=32,'HUD pin and widget limit is 32')
    end
    local function place(owner,height)
        if not live(owner) then return end
        local window=owner._window; local view=window.Root.AbsoluteSize
        local width=owner.Width
        local scale=math.max(.01,math.min(owner.Scale,math.max(1,view.X-16)/width,math.max(1,view.Y-32)/40))
        local available=math.max(40,(view.Y-32)/scale)
        local logicalHeight=owner.Collapsed and 40 or math.min(height,owner.MaxHeight,available)
        owner.ActualScale=scale; owner.ScaleObject.Scale=scale
        owner.Frame.Size=U2(width,logicalHeight)
        owner.Frame.Position=U2(clamp(owner.Position.X*view.X,8,math.max(8,view.X-width*scale-8)),clamp(owner.Position.Y*view.Y,16,math.max(16,view.Y-logicalHeight*scale-8)))
        owner.Frame.Visible=owner.Visible and (owner.VisibleWithMenu or window._shown==false or window.Minimized==true)
            and (owner.Kind~='ActionBar' or window.QuickActionsEnabled)
        owner.Frame.BackgroundTransparency=1-owner.Opacity; owner.Body.BackgroundTransparency=1-owner.Opacity
        owner.Body.Visible=not owner.Collapsed
        owner.CollapseButton.Text=owner.Collapsed and '+' or '-'
        owner.LockButton.Text=owner.Pinned and 'L' or '::'
    end
    function Overlay:_layout()
        if not live(self) or self._layingOut then return end
        self._layingOut=true
        local items={}
        for _,item in ipairs(self.Items) do if not item.Destroyed and item.Visible then items[#items+1]=item end end
        local columns=self.Orientation=='Horizontal' and math.max(1,math.floor((self.Width-16)/152)) or 1
        local cell=(self.Width-16-(columns-1)*6)/columns
        local rowHeight=self.Kind=='ActionBar' and 60 or 68
        local rows=math.ceil(#items/columns)
        for index,item in ipairs(items) do
            local object=item.Frame
            if object and object.Parent then
                object.Position=U2(8+((index-1)%columns)*(cell+6),6+math.floor((index-1)/columns)*(rowHeight+6))
                object.Size=U2(cell,rowHeight)
                if self.Kind=='ActionBar' then
                    object.Visible=not self.Collapsed and self._window.QuickActionsEnabled and item.Visible
                    local drag=object:FindFirstChild('DockDrag'); if drag then drag.Visible=false end
                    item.Button.Position=U2(0,0); item.Button.Size=UDim2.fromScale(1,1)
                    item.Button.BackgroundTransparency=1-self.Opacity
                else object.Visible=true end
            end
        end
        for _,item in ipairs(self.Items) do if not item.Destroyed and not item.Visible and item.Frame and item.Frame.Parent then item.Frame.Visible=false end end
        self.Body.CanvasSize=U2(0,rows*(rowHeight+6)+8)
        self.TitleLabel.Text=self.Title
        if self.Collapsed and self.Kind=='HUD' and items[1] then self.TitleLabel.Text=self.Title..' · '..items[1].ValueLabel.Text end
        place(self,48+rows*(rowHeight+6))
        self._layingOut=false
    end
    function Overlay:GetLayout()
        local result={Position={X=self.Position.X,Y=self.Position.Y},Scale=self.Scale,Opacity=self.Opacity,Width=self.Width,MaxHeight=self.MaxHeight,
            Orientation=self.Orientation,Visible=self.Visible,VisibleWithMenu=self.VisibleWithMenu,Collapsed=self.Collapsed,Pinned=self.Pinned}
        if self.Kind=='HUD' then result.Pins=copy(self._pendingPins or {}); for _,item in ipairs(self.Items) do
            if not item.Destroyed and item.Source and not item.Source.Destroyed then result.Pins[item.Source.Id]={Id=item.Id} end
        end end
        return result
    end
    function Overlay:SetLayout(value)
        assert(live(self),'Compact view has been destroyed')
        local nextLayout=checkedLayout(value,self.Kind)
        if nextLayout.Pins then checkPins(self,nextLayout.Pins) end
        for key,v in pairs(nextLayout) do if key~='Pins' then self[key]=v end end
        if nextLayout.Pins then
            local items={table.unpack(self.Items)}
            for _,item in ipairs(items) do if item.Source and (not nextLayout.Pins[item.Source.Id] or nextLayout.Pins[item.Source.Id].Id~=item.Id) then item:Destroy() end end
            self._pendingPins=copy(nextLayout.Pins); self._window:_restoreHUDPins()
        end
        if self.Pinned and self._window._drag and self._window._drag.Owner==self then self._window:_endDrag() end
        self:_layout(); self._window:_scheduleSave(); return self
    end
    function Overlay:SetPosition(value) return self:SetLayout({Position=value}) end
    function Overlay:SetVisible(value) return self:SetLayout({Visible=value}) end
    function Overlay:SetCollapsed(value) return self:SetLayout({Collapsed=value}) end
    function Overlay:SetPinned(value) return self:SetLayout({Pinned=value}) end
    function Overlay:SetScale(value) return self:SetLayout({Scale=value}) end
    function Overlay:SetOpacity(value) return self:SetLayout({Opacity=value}) end
    function Overlay:SetOrientation(value) return self:SetLayout({Orientation=value}) end
    function Overlay:SetTitle(value) self.Title=tostring(value); self:_layout(); return self end
    local function release(owner,destroyFrame)
        if owner.Destroyed then return end
        owner.Destroyed=true; local window=owner._window; local object=owner.Frame
        cleanup(owner)
        if window._drag and window._drag.Owner==owner then window:_endDrag() end
        local items={table.unpack(owner.Items)}; for _,item in ipairs(items) do item:Destroy() end
        owner.Resources:Destroy(); window._overlays[owner._key]=nil
        window._resources:Remove('compact:'..owner._key,true)
        if object then window:_forgetSkin(object) end
        owner.Frame=nil; owner.Body=nil; owner.Items={}; owner._items={}; owner._pendingPins={}
        owner.TitleLabel=nil; owner.CollapseButton=nil; owner.LockButton=nil; owner.CloseButton=nil; owner.ScaleObject=nil
        if destroyFrame and object and object.Parent then object:Destroy() end
    end
    function Overlay:Destroy() release(self,true) end
    local function create(window,kind,options)
        options=options or {}; assert(type(options)=='table' and not window.Destroyed,'Options and a live window are required')
        local id=identifier(options.Id or (kind=='HUD' and 'hud' or 'actions')); assert(#id<=116,'Compact view Id limit is 116 bytes')
        window._overlays=window._overlays or {}; local key=kind..'/'..id
        assert(not window._overlays[key],'Duplicate compact view Id: '..id)
        local count=0; for _ in pairs(window._overlays) do count=count+1 end; assert(count<64,'Compact view limit is 64')
        local layout={}
        for _,name in ipairs({'Position','Scale','Opacity','Width','MaxHeight','Orientation','Visible','VisibleWithMenu','Collapsed','Pinned'}) do if options[name]~=nil then layout[name]=options[name] end end
        layout=checkedLayout(layout,kind)
        local owner=setmetatable({_window=window,_connections={},Id=id,_key=key,Kind=kind,Items={},_items={},_pendingPins={},
            Title=tostring(options.Title or (kind=='HUD' and 'Mini HUD' or window:_t17('Ações','Actions'))),Position=Vector2.new(.03,.2),
            Scale=1,Opacity=.95,Width=kind=='HUD' and 270 or 330,MaxHeight=360,Orientation=kind=='HUD' and 'Vertical' or 'Horizontal',
            Visible=true,VisibleWithMenu=true,Collapsed=false,Pinned=false,Resources=window:CreateScope()},Overlay)
        for k,v in pairs(layout) do owner[k]=v end
        window._overlays[key]=owner; window:Manage(owner,'Destroy','compact:'..key)
        owner.Frame=frame(window,window.Root,{Name='Compact/'..key,Size=U2(owner.Width,100),BorderSizePixel=1,ZIndex=55,ClipsDescendants=true},'Background')
        window:_bind(owner.Frame,{BorderColor3='Border'}); bevel(window,owner.Frame,false)
        owner.ScaleObject=ui(window,'UIScale',{Parent=owner.Frame,Scale=owner.Scale})
        local header=frame(window,owner.Frame,{Position=U2(3,3),Size=UDim2.new(1,-6,0,34),Active=true,ZIndex=56},'Surface')
        owner.TitleLabel=label(window,header,owner.Title,{Position=U2(8,0),Size=UDim2.new(1,-112,1,0),TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=57})
        owner.CollapseButton=button(window,owner,header,'-',{Position=UDim2.new(1,-99,0,1),Size=U2(32,32),ZIndex=57},function() owner:SetCollapsed(not owner.Collapsed) end)
        owner.LockButton=button(window,owner,header,'::',{Position=UDim2.new(1,-66,0,1),Size=U2(32,32),TextSize=11,ZIndex=57},function() owner:SetPinned(not owner.Pinned) end)
        owner.CloseButton=button(window,owner,header,'X',{Position=UDim2.new(1,-33,0,1),Size=U2(32,32),TextSize=11,ZIndex=57},function() owner:SetVisible(false) end)
        owner.Body=ui(window,'ScrollingFrame',{Parent=owner.Frame,Name='Widgets',Position=U2(0,40),Size=UDim2.new(1,0,1,-40),BorderSizePixel=0,
            CanvasSize=U2(0,0),ScrollBarThickness=4,ScrollingDirection=Enum.ScrollingDirection.Y,ClipsDescendants=true,ZIndex=56},{BackgroundColor3='Background',ScrollBarImageColor3='Accent'})
        connect(owner,header.InputBegan,function(input)
            if owner.Pinned or not live(owner) or not pointer(input) then return end
            local start=point(input); local origin=owner.Frame.AbsolutePosition-window.Root.AbsolutePosition
            window:_beginDrag(owner,input,function(current)
                if not live(owner) then return end
                local view=window.Root.AbsoluteSize; local p=origin+(current-start)
                owner.Position=Vector2.new(clamp(p.X/math.max(1,view.X),0,1),clamp(p.Y/math.max(1,view.Y),0,1)); owner:_layout()
            end,function() if not owner.Destroyed then window:_scheduleSave() end end)
        end)
        connect(owner,owner.Frame.Destroying,function() release(owner,false) end)
        owner._initialLayout=owner:GetLayout()
        local saved=window._compactLayouts and window._compactLayouts[key]
        if saved then owner:SetLayout(saved) else owner:_layout() end
        return owner
    end
    function Window:CreateHUD(options) return create(self,'HUD',options) end
    function Window:GetHUD(id) return self._overlays and self._overlays['HUD/'..(id or 'hud')] end
    function Window:_restoreHUDPins(control)
        for _,hud in pairs(self._overlays or {}) do if hud.Kind=='HUD' and not hud.Destroyed then
            local pending=copy(hud._pendingPins)
            for id,record in pairs(pending) do
                local target=control and control.Id==id and control or not control and self.Controls[id]
                if target and compatible[target.Type] and not target.Destroyed then
                    hud._pendingPins[id]=nil; target:PinToHUD(hud,{Id=record.Id})
                end
            end
        end end
    end
    local function releaseItem(item,destroyFrame)
        if item.Destroyed then return end
        item.Destroyed=true; local hud=item.HUD; local window=item._window; local object=item.Frame
        cleanup(item); item.Resources:Destroy()
        if item._icon then item._icon:Destroy(); item._icon=nil end
        if item.Source then
            local source=item.Source
            if source._hudPins then source._hudPins[hud]=nil end
            source._resources:Remove('hud-pin:'..hud.Id,true)
            hud._pendingPins[source.Id]=nil; item.Source=nil
            if source._syncPinButton and not source.Destroyed and source.Frame.Parent then source:_syncPinButton() end
        end
        hud._items[item.Id]=nil; local index=table.find(hud.Items,item); if index then table.remove(hud.Items,index) end
        if object then window:_forgetSkin(object) end
        item.Frame=nil; item.ValueLabel=nil; item.TitleLabel=nil; item.SubtitleLabel=nil; item.Track=nil; item.Fill=nil
        if destroyFrame and object and object.Parent then object:Destroy() end
        hud:_layout()
    end
    function Item:Destroy() releaseItem(self,true) end
    function Item:GetValue() return copy(self.Value) end
    function Item:SetValue(value)
        if not live(self) then return self end
        assert(value==nil or type(value)=='string' and #value<=2048 or type(value)=='boolean' or finite(value),'Widget Value must be text, boolean, finite number or nil')
        if self.Kind=='Progress' then assert(finite(value),'Progress Value must be finite'); value=clamp(value,self.Min,self.Max) end
        self.Value=value
        local ok,text=self._window:_protected(function() if value==nil then return '—' end; return Library:FormatValue(value,self.Format,self.Precision) end,{Phase='HUD',Operation=self.Id})
        if not live(self) then return self end
        self.ValueLabel.Text=ok and tostring(text)..(self.Unit~='' and ' '..self.Unit or '') or '—'
        self.TitleLabel.Text=self.Title; self.SubtitleLabel.Text=self.Subtitle
        if self.Fill then self.Fill.Size=UDim2.new((value-self.Min)/(self.Max-self.Min),0,1,0) end
        if self.HUD.Collapsed then self.HUD:_layout() end
        return self
    end
    function Item:SetTitle(value) self.Title=tostring(value); return self:SetValue(self.Value) end
    function Item:SetSubtitle(value) self.Subtitle=tostring(value or ''); return self:SetValue(self.Value) end
    function Item:SetVisible(value) self.Visible=boolean(value,'Visible'); self.HUD:_layout(); self._window:_scheduleSave(); return self end
    function Item:SetIcon(value) if self._icon then self._icon:Set(value) end; return self end
    function Item:BindState(state,options)
        assert(live(self) and Library:_isState(state) and not state.Destroyed and (not state._window or state._window==self._window),'Binding requires a live State from this window or an external State')
        options=options or {}; assert(options.Transform==nil or type(options.Transform)=='function','Transform must be a function')
        self.Resources:Remove('binding')
        local subscription=state:Subscribe(function(value)
            if not live(self) then return end
            local ok,result=self._window:_protected(function() if options.Transform then return options.Transform(value) end; return value end,{Phase='HUD',Operation=self.Id})
            if ok and live(self) then self:SetValue(result) end
        end,true)
        self.Resources:Add(subscription,'Disconnect','binding'); return self
    end
    local function add(hud,kind,options)
        options=options or {}; assert(live(hud) and hud.Kind=='HUD','Add widget requires a live HUD')
        local id=options.Id
        if id==nil then
            repeat hud._nextWidget=(hud._nextWidget or 0)+1; id='widget-'..hud._nextWidget until not hud._items[id]
        end
        id=identifier(id)
        local pending=0; for _,record in pairs(hud._pendingPins) do pending=pending+1; assert(record.Id~=id,'Widget Id is reserved by a saved pin') end
        assert(not hud._items[id] and #hud.Items+pending<32,'Duplicate widget Id or HUD limit of 32 reached')
        local format=options.Format or 'Raw'
        assert(type(format)=='function' or format=='Raw' or format=='Compact' or format=='Percent' or format=='Time','Unknown widget Format')
        assert(options.Precision==nil or finite(options.Precision) and options.Precision%1==0 and options.Precision>=0 and options.Precision<=6,'Precision must be 0–6')
        local min,max=options.Min or 0,options.Max or 100
        assert(options.Transform==nil or type(options.Transform)=='function','Transform must be a function')
        assert(finite(min) and finite(max) and max>min,'Progress requires finite Min < Max')
        if options.State then assert(Library:_isState(options.State) and not options.State.Destroyed and (not options.State._window or options.State._window==hud._window),'Invalid widget State') end
        resolveIcon(options.Icon)
        local initial=options.Value; if initial==nil and kind=='Progress' then initial=min end
        assert(initial==nil or type(initial)=='string' and #initial<=2048 or type(initial)=='boolean' or finite(initial),'Widget Value must be simple, finite and bounded')
        assert(kind~='Progress' or finite(initial),'Progress Value must be finite')
        local item=setmetatable({HUD=hud,_window=hud._window,_connections={},Id=id,Kind=kind,Resources=hud.Resources:Child(),
            Title=tostring(options.Title or id),Subtitle=tostring(options.Subtitle or ''),Unit=tostring(options.Unit or ''),Format=format,
            Precision=options.Precision or 1,Min=min,Max=max,Visible=options.Visible~=false},Item)
        local window=hud._window
        item.Frame=frame(window,hud.Body,{Name='Widget/'..id,Size=U2(250,68),BorderSizePixel=1,ZIndex=57,ClipsDescendants=true},'Inset'); window:_bind(item.Frame,{BorderColor3='Border'})
        item.TitleLabel=label(window,item.Frame,item.Title,{Position=U2(8,4),Size=UDim2.new(1,-16,0,17),TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=58},'Muted')
        item.ValueLabel=label(window,item.Frame,'',{Position=U2(8,23),Size=UDim2.new(1,-16,0,23),TextSize=18,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=58})
        item.SubtitleLabel=label(window,item.Frame,item.Subtitle,{Position=U2(8,47),Size=UDim2.new(1,-16,0,16),TextSize=10,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=58},'Muted')
        item._icon=iconSlot(window,item.Frame,options.Icon,nil,14,U2(8,5),'Muted',function(shown)
            if not item.TitleLabel then return end
            item.TitleLabel.Position=U2(shown and 27 or 8,4); item.TitleLabel.Size=UDim2.new(1,shown and -35 or -16,0,17)
        end)
        if kind=='Progress' then
            item.Track=frame(window,item.Frame,{Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,4),ZIndex=58},'Border')
            item.Fill=frame(window,item.Track,{Size=UDim2.fromScale(0,1),ZIndex=59},'Accent'); item.SubtitleLabel.Visible=false
        end
        hud.Items[#hud.Items+1]=item; hud._items[id]=item
        item.Resources:Add(function() if not item.Destroyed then releaseItem(item,true) end end)
        connect(item,item.Frame.Destroying,function() releaseItem(item,false) end)
        item:SetValue(initial)
        if options.State then item:BindState(options.State,{Transform=options.Transform}) end
        hud:_layout(); return item
    end
    function Overlay:AddValue(options) return add(self,'Value',options) end
    function Overlay:AddProgress(options) return add(self,'Progress',options) end
    function Overlay:AddTask(options)
        options=options or {}; local job=options.Task or options.Action
        assert(job and job._window==self._window and not job.Destroyed and job.Status and not job.Status.Destroyed,'Task/Action must belong to this window')
        local passed={}; for k,v in pairs(options) do passed[k]=v end
        passed.State=job.Status; passed.Transform=options.Transform or function(status)
            local message=status.Message and status.Message~='' and ' · '..status.Message or ''
            return tostring(status.Status)..message
        end
        return add(self,'Value',passed)
    end
    function Overlay:AddTimer(options)
        options=options or {}; assert(options.Value==nil or finite(options.Value) and options.Value>=0,'Timer Value must be nonnegative')
        local passed={}; for k,v in pairs(options) do passed[k]=v end; passed.State=nil; passed.Format='Time'; passed.Value=options.Value or 0
        local item=add(self,'Timer',passed); local elapsed=passed.Value; local started
        local job=self._window:CreateTask({Id='__retrobox/hud-timer/'..self.Id..'/'..item.Id,Interval=.25,Scope=item.Resources,Callback=function()
            if live(item) and started then item:SetValue(elapsed+math.max(0,os.clock()-started)) end
        end})
        item.Resources:Add(job,'Destroy')
        function item:Start() if not live(self) or started then return self end; started=os.clock(); job:Start(); return self end
        function item:Pause() if started then elapsed=elapsed+math.max(0,os.clock()-started); started=nil; job:Stop('paused'); self:SetValue(elapsed) end; return self end
        function item:Reset(value) assert(value==nil or finite(value) and value>=0,'Timer reset must be nonnegative'); elapsed=value or 0; if started then started=os.clock() end; self:SetValue(elapsed); return self end
        if options.Start then item:Start() end
        return item
    end
    function Control:PinToHUD(hud,options)
        assert(not self.Destroyed and compatible[self.Type],'PinToHUD supports StatCard, Progress, ProgressChart, Label and Stepper')
        identifier(self.Id)
        hud=hud or self._window:GetHUD('pinned') or self._window:CreateHUD({Id='pinned',Title=self._window:_t17('Fixados','Pinned')})
        assert(hud.Kind=='HUD' and live(hud) and hud._window==self._window,'HUD must belong to this window')
        self._hudPins=self._hudPins or {}; if self._hudPins[hud] and not self._hudPins[hud].Destroyed then return self._hudPins[hud] end
        options=options or {}; local passed={}; for k,v in pairs(options) do passed[k]=v end
        passed.Id=options.Id or ('pin/'..self.Id); passed.Title=options.Title or self.Title; passed.Value=nil; passed.State=nil
        passed.Min=self.Min; passed.Max=self.Max; passed.Format=options.Format or self.Format or 'Raw'; passed.Precision=options.Precision or self.Precision
        passed.Unit=options.Unit or self.Unit; passed.Subtitle=options.Subtitle or self.Subtitle or self.Description
        passed.Icon=options.Icon or self._titleIcon and self._titleIcon.Spec
        local item=add(hud,(self.Type=='Progress' or self.Type=='ProgressChart') and 'Progress' or 'Value',passed)
        item.Source=self; self._hudPins[hud]=item; self:Manage(item,'Destroy','hud-pin:'..hud.Id)
        local function update(value)
            if not live(item) or self.Destroyed then return end
            item.Title=options.Title or self.Title; item.Subtitle=options.Subtitle or self.Subtitle or self.Description or ''; item.Unit=options.Unit or self.Unit or ''
            if self.Type=='Stepper' then value=self:GetSummary()
            elseif self.Type=='StatCard' and self.Loading then value=self._window:_text('loading')
            elseif self.Type=='StatCard' and self.Unavailable then value=self.UnavailableText or self._window:_text('unavailable') end
            item:SetValue(value)
        end
        item.Resources:Add(self._window:GetFlagState(self.Id):Subscribe(update,true),'Disconnect')
        item.Resources:Add(self.TitleLabel:GetPropertyChangedSignal('Text'):Connect(function() update(self:GetValue()) end),'Disconnect')
        item.Resources:Add(self.DescriptionLabel:GetPropertyChangedSignal('Text'):Connect(function() update(self:GetValue()) end),'Disconnect')
        if self.SubtitleLabel then item.Resources:Add(self.SubtitleLabel:GetPropertyChangedSignal('Text'):Connect(function() update(self:GetValue()) end),'Disconnect') end
        if self.ValueLabel then item.Resources:Add(self.ValueLabel:GetPropertyChangedSignal('Text'):Connect(function() update(self:GetValue()) end),'Disconnect') end
        if self.UnitLabel then item.Resources:Add(self.UnitLabel:GetPropertyChangedSignal('Text'):Connect(function() update(self:GetValue()) end),'Disconnect') end
        self:_syncPinButton(); self._window:_scheduleSave(); return item
    end
    function Control:UnpinFromHUD(hud)
        local pins={}; for target,item in pairs(self._hudPins or {}) do if not hud or target==hud then pins[#pins+1]=item end end
        for _,item in ipairs(pins) do item:Destroy() end
        self._window:_scheduleSave(); return self
    end
    function Control:_syncPinButton()
        if self.PinButton and self.PinButton.Parent then self.PinButton.Text=next(self._hudPins or {}) and self._window:_t17('Soltar','Unpin') or self._window:_t17('Fixar','Pin') end
    end
    function Control:SetPinnable(options)
        assert(not self.Destroyed and compatible[self.Type],'This control cannot offer pinning')
        if options==false then
            self._resources:Remove('pin-button')
            self:_syncHelpBadge(); return self
        end
        assert(options==true or type(options)=='table','Pinnable must be boolean or options')
        self._pinOptions=type(options)=='table' and options or {}
        if not self.PinButton then
            local pinOwner=setmetatable({_connections={}},{__index=function(_,key) return self[key] end})
            self.TitleLabel.Size=UDim2.new(self.TitleLabel.Size.X.Scale,self.TitleLabel.Size.X.Offset-62,self.TitleLabel.Size.Y.Scale,self.TitleLabel.Size.Y.Offset)
            self.PinButton=button(self._window,pinOwner,self.Frame,'',{Size=U2(60,21),TextSize=10,ZIndex=self.TitleLabel.ZIndex+3},function()
                if next(self._hudPins or {}) then self:UnpinFromHUD() else self:PinToHUD(self._pinOptions.HUD,self._pinOptions) end
            end)
            self:Manage(function()
                pinOwner.Destroyed=true; cleanup(pinOwner)
                local object=self.PinButton; self.PinButton=nil
                if self.TitleLabel and self.TitleLabel.Parent then
                    local size=self.TitleLabel.Size; self.TitleLabel.Size=UDim2.new(size.X.Scale,size.X.Offset+62,size.Y.Scale,size.Y.Offset)
                end
                if object then self._window:_forgetSkin(object); if object.Parent then object:Destroy() end end
            end,nil,'pin-button')
        end
        self:_syncPinButton(); self:_syncHelpBadge(); return self
    end
    local syncHelp=Control._syncHelpBadge
    function Control:_syncHelpBadge()
        syncHelp(self)
        if self.PinButton and self.PinButton.Parent then
            local p,s=self.TitleLabel.Position,self.TitleLabel.Size
            self.PinButton.Position=UDim2.new(p.X.Scale+s.X.Scale,p.X.Offset+s.X.Offset+2,0,1)
            if self.InfoButton and self.InfoButton.Parent then self.InfoButton.Position=UDim2.new(p.X.Scale+s.X.Scale,p.X.Offset+s.X.Offset+64,0,1) end
        end
    end
    local setIcon=Control.SetIcon
    function Control:SetIcon(value)
        local result=setIcon(self,value)
        for _,item in pairs(self._hudPins or {}) do if not item.Destroyed then item:SetIcon(value) end end
        return result
    end
    function Window:CreateActionBar(options) return create(self,'ActionBar',options) end
    function Overlay:AddAction(options)
        assert(live(self) and self.Kind=='ActionBar','AddAction requires a live ActionBar')
        options=options or {}; assert(#self.Items<32,'ActionBar limit is 32')
        local passed={}; for k,v in pairs(options) do passed[k]=v end
        local id=options.Id or options.Control and options.Control.Id
        if not id then self._nextAction=(self._nextAction or 0)+1; id='action-'..self._nextAction end
        passed.Id='__retrobox/bar/'..self.Id..'/'..identifier(id)
        passed.MobileOnly=false; passed.VisibleWithMenu=true
        local item=self._window:AddFloatingButton(passed)
        item._actionBar=self; item.Frame.Parent=self.Body
        self.Items[#self.Items+1]=item; self._items[item.Id]=item
        self.Resources:Add(item,'Destroy',item.Id); self:_layout(); return item
    end
    local layoutFloating=Window._layoutFloating
    function Window:_layoutFloating(...)
        layoutFloating(self,...)
        for _,owner in pairs(self._overlays or {}) do owner:_layout() end
    end
    local syncFloating=Window._syncFloating
    function Window:_syncFloating(control)
        syncFloating(self,control)
        for _,bar in pairs(self._overlays or {}) do if bar.Kind=='ActionBar' and not bar.Destroyed then bar:_layout() end end
    end
    local advancedExport,advancedPrepare,advancedApply=Window._exportAdvanced,Window._prepareAdvanced,Window._applyAdvanced
    function Window:_exportAdvanced()
        local result=advancedExport(self); result.CompactViews={}; local count=0
        for key,owner in pairs(self._overlays or {}) do if not owner.Destroyed then result.CompactViews[key]=owner:GetLayout(); count=count+1 end end
        local saved={}; for key in pairs(self._compactLayouts or {}) do saved[#saved+1]=key end; table.sort(saved)
        for _,key in ipairs(saved) do if not result.CompactViews[key] and count<64 then result.CompactViews[key]=copy(self._compactLayouts[key]); count=count+1 end end
        return result
    end
    function Window:_prepareAdvanced(value)
        local result=advancedPrepare(self,value); if not result then return result end
        if value.CompactViews~=nil then
            assert(type(value.CompactViews)=='table','CompactViews must be a map'); result.CompactViews={}; local n=0
            for key,layout in pairs(value.CompactViews) do
                n=n+1; assert(n<=64,'Compact view layout limit is 64'); identifier(key)
                local kind=key:match('^(HUD)/') or key:match('^(ActionBar)/'); assert(kind,'Invalid compact view kind')
                local checked=checkedLayout(layout,kind)
                local owner=self._overlays and self._overlays[key]
                if checked.Pins and owner then checkPins(owner,checked.Pins) end
                local encoded={}; for name,item in pairs(checked) do encoded[name]=name=='Position' and {X=item.X,Y=item.Y} or item end
                result.CompactViews[key]=encoded
            end
        end
        return result
    end
    function Window:_applyAdvanced(value,deferUI)
        advancedApply(self,value,deferUI)
        if value and value.CompactViews then
            self._compactLayouts=copy(value.CompactViews)
            for key,layout in pairs(value.CompactViews) do local owner=self._overlays and self._overlays[key]; if owner and not owner.Destroyed then owner:SetLayout(layout) end end
        end
    end
    local reset=Window.Reset
    function Window:Reset(...)
        local result=reset(self,...)
        self._compactLayouts={}
        for _,owner in pairs(self._overlays or {}) do if owner._initialLayout then owner:SetLayout(owner._initialLayout) end end
        return result
    end
    -- Save the constructor's layout separately from subsequent profile restores.
    local createHUD,createBar=Window.CreateHUD,Window.CreateActionBar
    function Window:CreateHUD(options)
        return createHUD(self,options)
    end
    function Window:CreateActionBar(options)
        return createBar(self,options)
    end
end
