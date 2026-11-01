-- RetroBox 2.11 refined controls: Segmented, RangeSlider, Number, Callout and
-- CodeBlock. They reuse base/init, the palette registry, the focus order and
-- the central animator, so themes, profiles, search and Reduced Motion apply.
do
    local function canActivate(control,object)
        local window=control._window
        if window.Destroyed or control.Destroyed or control.Disabled or window._shown==false then return false end
        local section=control._section and (control._section._parentSection or control._section)
        if section and (section._collapsed or not section._visible) then return false end
        if window._dialog or window._binding then return false end
        if window._interactionAllowed and not window:_interactionAllowed(object) then return false end
        return true
    end
    local function decimals(step)
        local text=string.format('%.10g',step); local dot=text:find('%.')
        return dot and math.min(6,#text-dot) or 0
    end
    local function snap(value,base,step)
        local result=base+math.floor((value-base)/step+.5)*step
        return tonumber(string.format('%.10g',result))
    end
    local function numberText(value,precision)
        if precision then return string.format('%.'..precision..'f',value) end
        return string.format('%.6g',value)
    end

    -- Segmented: 2–8 exclusive choices with a sliding accent indicator.
    function Section:AddSegmented(options)
        options=options or {}
        local choices=names(options.Options or {})
        assert(#choices>=2 and #choices<=8,'Segmented needs 2–8 Options')
        local self=base(self,'Segmented',options,78)
        local window=self._window
        self.Options=choices; self.Segments={}
        local track=frame(window,self.Frame,{Name='SegmentTrack',Position=U2(0,44),Size=UDim2.new(1,0,0,30),Active=false},'Inset')
        bevel(window,track,true)
        local indicator=frame(window,track,{Name='SegmentIndicator',Position=U2(2,2),Size=UDim2.new(0,0,1,-4),ZIndex=track.ZIndex+1},'Accent')
        bevel(window,indicator,false)
        self.Track=track; self.Indicator=indicator
        local function clear()
            for _,segment in ipairs(self.Segments) do window:_forgetSkin(segment); if segment.Parent then segment:Destroy() end end
            self.Segments={}
        end
        local function build()
            clear()
            local count=#self.Options
            for index,name in ipairs(self.Options) do
                local segment=ui(window,'TextButton',{Parent=track,Name='Segment',Text=name,Font=window.Font,TextSize=13,BorderSizePixel=0,AutoButtonColor=false,
                    BackgroundTransparency=1,Active=true,Selectable=true,RichText=false,TextTruncate=Enum.TextTruncate.AtEnd,
                    Position=UDim2.new((index-1)/count,0,0,0),Size=UDim2.new(1/count,0,1,0),ZIndex=track.ZIndex+3},{TextColor3='Text',BackgroundColor3='Surface'})
                local function activate()
                    if canActivate(self,segment) then window:_pressPulse(segment,self);self:SetValue(name) end
                end
                connect(self,segment.Activated,activate)
                connect(self,segment.MouseEnter,function()
                    if not self.Disabled and self.Value~=name then window:_motion(segment,{BackgroundTransparency=.55},.1,'segment-hover',self) end
                end)
                connect(self,segment.MouseLeave,function() window:_motion(segment,{BackgroundTransparency=1},.12,'segment-hover',self) end)
                window:_registerFocus(segment,activate)
                self.Segments[index]=segment
            end
        end
        function self:_normalize(value)
            assert(type(value)=='string' or type(value)=='number','Segmented value must be one of its Options')
            value=tostring(value); assert(table.find(self.Options,value),'Unknown segmented option: '..value)
            return value
        end
        function self:_render()
            if self.Destroyed or not self.Frame.Parent then return end
            local count=#self.Options; local index=table.find(self.Options,self.Value) or 1
            local goals={Position=UDim2.new((index-1)/count,2,0,2),Size=UDim2.new(1/count,-4,1,-4)}
            if self._hasDefault then window:_motion(indicator,goals,.24,'segment',self,nil,{Easing='Back'})
            else window:_cancelTrack(indicator,'segment',false); indicator.Position=goals.Position; indicator.Size=goals.Size end
            for i,segment in ipairs(self.Segments) do
                local selected=i==index
                window._inkSurfaces[segment]=selected and 'Accent' or nil
                window:_bind(segment,{TextColor3=selected and 'AccentText' or 'Text'})
                if selected then window:_cancelTrack(segment,'segment-hover',false); segment.BackgroundTransparency=1 end
                segment.Active=not self.Disabled; segment.TextTransparency=self.Disabled and .45 or 0
            end
            indicator.BackgroundTransparency=self.Disabled and .45 or 0
        end
        function self:SetOptions(list)
            assert(not self.Destroyed,'This control has been destroyed')
            local nextChoices=names(list or {}); assert(#nextChoices>=2 and #nextChoices<=8,'Segmented needs 2–8 Options')
            self.Options=nextChoices; build()
            if table.find(nextChoices,self.Value) then self:_render() else self:SetValue(nextChoices[1]) end
            return self
        end
        function self:GetOptions() return copy(self.Options) end
        function self:GetIndex() return table.find(self.Options,self.Value) end
        build()
        return init(self,options,choices[1])
    end

    -- RangeSlider: one {Min,Max} value with two thumbs on a shared track.
    function Section:AddRangeSlider(options)
        options=options or {}
        local minimum,maximum,step,gap=options.Min or 0,options.Max or 100,options.Step or 1,options.MinGap or 0
        assert(finite(minimum) and finite(maximum) and maximum>minimum,'RangeSlider requires finite Min < Max')
        assert(finite(step) and step>0,'RangeSlider Step must be positive')
        assert(finite(gap) and gap>=0 and gap<=maximum-minimum,'RangeSlider MinGap must be between 0 and Max-Min')
        local self=base(self,'RangeSlider',options,78)
        local window=self._window
        self.Min,self.Max,self.Step,self.MinGap=minimum,maximum,step,gap
        self.TitleLabel.Size=UDim2.new(1,-128,0,21)
        local valueLabel=label(window,self.Frame,'',{Name='RangeValue',Position=UDim2.new(1,-120,0,0),Size=U2(120,25),TextSize=12,TextXAlignment=Enum.TextXAlignment.Right},'Muted')
        local track=frame(window,self.Frame,{Name='RangeTrack',Position=U2(0,49),Size=UDim2.new(1,0,0,10),Active=true},'Inset')
        bevel(window,track,true)
        local fill=frame(window,track,{Name='RangeFill',Size=UDim2.new(0,0,1,0)},'Accent')
        local function thumb(name)
            local object=frame(window,track,{Name=name,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,0,.5,0),Size=U2(12,22),Active=true,ZIndex=track.ZIndex+2},'Surface')
            bevel(window,object,false); return object
        end
        local low,high=thumb('LowThumb'),thumb('HighThumb')
        local function round(value) return clamp(snap(clamp(value,self.Min,self.Max),self.Min,self.Step),self.Min,self.Max) end
        function self:_normalize(value)
            assert(type(value)=='table' and finite(value.Min) and finite(value.Max),'RangeSlider value must be {Min=number,Max=number}')
            local a,b=round(value.Min),round(value.Max)
            assert(a<=b,'RangeSlider Min must not exceed Max')
            assert(b-a>=self.MinGap-1e-9,'RangeSlider range is narrower than MinGap')
            return {Min=a,Max=b}
        end
        function self:_render()
            local span=self.Max-self.Min
            local a,b=(self.Value.Min-self.Min)/span,(self.Value.Max-self.Min)/span
            local dragging=window._drag and window._drag.Owner==self
            local targets={[low]=UDim2.new(a,0,.5,0),[high]=UDim2.new(b,0,.5,0)}
            local fillGoals={Position=UDim2.new(a,0,0,0),Size=UDim2.new(b-a,0,1,0)}
            if self._hasDefault and not dragging then
                for object,goal in pairs(targets) do window:_motion(object,{Position=goal},.1,'range-thumb',self,nil,{Easing='Quint'}) end
                window:_motion(fill,fillGoals,.1,'range-fill',self,nil,{Easing='Quint'})
            else
                for object,goal in pairs(targets) do window:_cancelTrack(object,'range-thumb',false); object.Position=goal end
                window:_cancelTrack(fill,'range-fill',false); fill.Position=fillGoals.Position; fill.Size=fillGoals.Size
            end
            local suffix=options.Suffix or ''
            valueLabel.Text=numberText(self.Value.Min,options.Precision)..suffix..' – '..numberText(self.Value.Max,options.Precision)..suffix
            fill.BackgroundTransparency=self.Disabled and .45 or 0
        end
        function self:SetRange(minimum,maximum,silent) return self:SetValue({Min=minimum,Max=maximum},silent) end
        function self:GetRange() return self.Value.Min,self.Value.Max end
        local function start(input,which)
            local active=which
            window:_beginDrag(self,input,function(p)
                local width=track.AbsoluteSize.X; if width<=0 or self.Destroyed then return end
                local value=round(self.Min+clamp((p.X-track.AbsolutePosition.X)/width,0,1)*(self.Max-self.Min))
                local a,b=self.Value.Min,self.Value.Max
                if not active then
                    if value<=a then active='Min' elseif value>=b then active='Max'
                    else active=math.abs(value-a)<=math.abs(value-b) and 'Min' or 'Max' end
                end
                if active=='Min' then a=math.max(self.Min,math.min(value,b-self.MinGap)) else b=math.min(self.Max,math.max(value,a+self.MinGap)) end
                local ok,normalized=pcall(self._normalize,self,{Min=a,Max=b})
                if ok then self:SetValue(normalized) end
            end)
        end
        connect(self,track.InputBegan,function(input) start(input,nil) end)
        connect(self,low.InputBegan,function(input) start(input,'Min') end)
        connect(self,high.InputBegan,function(input) start(input,'Max') end)
        self.Track=track; self.LowThumb=low; self.HighThumb=high; self.ValueLabel=valueLabel
        local default=options.Default or {Min=self.Min,Max=self.Max}
        return init(self,options,default)
    end

    -- Number: precise numeric entry with -/+ steps and hold-to-repeat.
    function Section:AddNumber(options)
        options=options or {}
        local minimum,maximum,step=options.Min or -math.huge,options.Max or math.huge,options.Step or 1
        assert(type(minimum)=='number' and type(maximum)=='number' and minimum==minimum and maximum==maximum and maximum>minimum,'Number requires Min < Max')
        assert(finite(step) and step>0,'Number Step must be positive')
        assert(options.Precision==nil or finite(options.Precision) and options.Precision%1==0 and options.Precision>=0 and options.Precision<=6,'Number Precision must be 0–6')
        local self=base(self,'Number',options,80)
        local window=self._window
        self.Min,self.Max,self.Step=minimum,maximum,step
        self.Precision=options.Precision or decimals(self.Step)
        local origin=finite(self.Min) and self.Min or 0
        local minus=button(window,self,self.Frame,'-',{Name='Decrement',Position=U2(0,44),Size=U2(32,32),TextSize=16},function() self:Increment(-1) end)
        local plus=button(window,self,self.Frame,'+',{Name='Increment',Position=UDim2.new(1,-32,0,44),Size=U2(32,32),TextSize=16},function() self:Increment(1) end)
        local box=textbox(window,self.Frame,'',{Name='NumberValue',Position=U2(38,44),Size=UDim2.new(1,-76,0,32),TextXAlignment=Enum.TextXAlignment.Center})
        local padding=box:FindFirstChild('TextPadding')
        function self:_normalize(value)
            if type(value)=='string' then value=tonumber(value) end
            assert(finite(value),'Number value must be a finite number')
            return clamp(snap(clamp(value,self.Min,self.Max),origin,self.Step),self.Min,self.Max)
        end
        function self:_render()
            if not box:IsFocused() then box.Text=numberText(self.Value,self.Precision)..(options.Suffix or '') end
            box.TextEditable=not self.Disabled
            minus.Active=not self.Disabled and self.Value>self.Min; plus.Active=not self.Disabled and self.Value<self.Max
            minus.TextTransparency=minus.Active and 0 or .45; plus.TextTransparency=plus.Active and 0 or .45
        end
        function self:Increment(direction,silent)
            assert(not self.Destroyed,'This control has been destroyed')
            direction=direction or 1; assert(finite(direction),'Increment needs a finite multiplier')
            if self.Disabled then return false end
            local before=self.Value; self:SetValue(self.Value+self.Step*direction,silent)
            if self.Value==before then return false end
            if padding and window:_motionAllowed(box) then
                local up=direction>0
                padding.PaddingTop=UDim.new(0,up and 0 or 5); padding.PaddingBottom=UDim.new(0,up and 5 or 0)
                window:_motion(padding,{PaddingTop=UDim.new(0,0),PaddingBottom=UDim.new(0,0)},.16,'number-bump',self,nil,{Easing='Back'})
            end
            return true
        end
        local holdToken=0
        local function stopHold() holdToken=holdToken+1 end
        local function hold(direction)
            stopHold(); local token=holdToken
            local function step(delay)
                task.delay(delay,function()
                    if token~=holdToken or self.Destroyed or self.Disabled or window.Destroyed or window._shown==false then return end
                    if self:Increment(direction) then step(.07) else stopHold() end
                end)
            end
            step(.45)
        end
        for object,direction in pairs({[minus]=-1,[plus]=1}) do
            connect(self,object.InputBegan,function(input) if pointer(input) and canActivate(self,object) then hold(direction) end end)
            connect(self,object.InputEnded,function(input) if pointer(input) then stopHold() end end)
            connect(self,object.MouseLeave,stopHold)
        end
        connect(self,box.Focused,function() box.Text=numberText(self.Value,self.Precision) end)
        connect(self,box.FocusLost,function()
            local value=tonumber((box.Text:gsub('[^%d%.%-eE+]','')))
            if finite(value) and not self.Disabled then self:SetValue(value) end
            self:_render()
        end)
        self:Manage(stopHold)
        self.Input=box; self.DecrementButton=minus; self.IncrementButton=plus
        local default=options.Default
        if default==nil then default=finite(self.Min) and self.Min or 0 end
        return init(self,options,default)
    end

    -- Callout: informative panel with a kind stripe, icon and wrapped body.
    local kinds={
        Info={Role='Accent',Icon='info',PT='Informação',EN='Information'},
        Tip={Role='Accent',Icon='spark',PT='Dica',EN='Tip'},
        Success={Role='Success',Icon='success',PT='Sucesso',EN='Success'},
        Warning={Role='Danger',Icon='warning',PT='Atenção',EN='Warning'},
        Danger={Role='Danger',Icon='error',PT='Perigo',EN='Danger'},
    }
    function Section:AddCallout(options)
        if type(options)=='string' then options={Content=options} end
        options=options or {}
        local kind=options.Kind or 'Info'; assert(kinds[kind],'Callout Kind is Info, Tip, Success, Warning or Danger')
        assert(options.Content==nil or type(options.Content)=='string' and #options.Content<=4096,'Callout Content must contain at most 4096 bytes')
        local passed={}; for key,value in pairs(options) do passed[key]=value end
        passed.ShowDescription=false; passed.Tooltip=nil; passed.Tip=nil
        if passed.Title==nil then passed.Title='' end
        local self=base(self,'Callout',passed,64)
        local window=self._window
        self.Persist=false; self.Kind=kind; self._descriptionLayout={Height=64,Children={},HeaderFields={},Reserve=0}
        self.TitleLabel.Visible=false; self.DescriptionLabel.Visible=false
        local panel=frame(window,self.Frame,{Name='CalloutPanel',Size=UDim2.fromScale(1,1),BorderSizePixel=1},'Inset')
        window:_bind(panel,{BackgroundColor3='Inset',BorderColor3='Border'})
        local stripe=frame(window,panel,{Name='CalloutStripe',Size=UDim2.new(0,4,1,0),ZIndex=panel.ZIndex+1},kinds[kind].Role)
        local heading=label(window,panel,'',{Name='CalloutTitle',Position=U2(36,8),Size=UDim2.new(1,-46,0,20),TextSize=14,TextTruncate=Enum.TextTruncate.AtEnd})
        local body=label(window,panel,'',{Name='CalloutBody',Position=U2(36,30),Size=UDim2.new(1,-46,0,18),TextSize=12,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top},'Muted')
        local icon=iconSlot(window,panel,options.Icon,kinds[kind].Icon,16,U2(13,10),kinds[kind].Role)
        self.Panel=panel; self.Stripe=stripe; self.Heading=heading; self.Body=body; self.Icon=icon.Frame
        local function measure(object,width)
            local ok,size=pcall(TextService.GetTextSize,TextService,object.Text,object.TextSize,object.Font,Vector2.new(math.max(1,width),100000))
            if ok and finite(size.Y) then return size.Y end
            local lines=0
            for line in (object.Text..'\n'):gmatch('(.-)\n') do lines=lines+math.max(1,math.ceil(#line*object.TextSize*.6/math.max(1,width))) end
            return lines*(object.TextSize+3)
        end
        function self:_layoutDescription()
            if self.Destroyed or self._layingCallout then return end
            self._layingCallout=true
            local width=self.Frame.AbsoluteSize.X/math.max(.01,window._actualScale or 1)-46
            local hasTitle=#heading.Text>0; local hasBody=#body.Text>0
            body.Position=U2(36,hasTitle and 30 or 9)
            local bodyHeight=hasBody and math.max(16,measure(body,width)+3) or 0
            body.Size=UDim2.new(1,-46,0,bodyHeight); body.Visible=hasBody; heading.Visible=hasTitle
            local total=(hasTitle and 30 or 9)+bodyHeight+(hasBody and 9 or 0)
            self.Frame.Size=UDim2.new(self.Frame.Size.X.Scale,self.Frame.Size.X.Offset,0,math.max(36,total))
            self._layingCallout=false
        end
        local function reveal()
            if window:_motionAllowed(stripe) then
                stripe.Size=UDim2.new(0,4,0,0)
                window:_motion(stripe,{Size=UDim2.new(0,4,1,0)},.3,'callout',self,nil,{Easing='Quint'})
            else window:_cancelTrack(stripe,'callout',false); stripe.Size=UDim2.new(0,4,1,0) end
        end
        function self:_normalize(value)
            value=tostring(value or ''); assert(#value<=4096,'Callout Content must contain at most 4096 bytes'); return value
        end
        function self:_render()
            heading.Text=self.Title; body.Text=self.Value
            heading.TextTransparency=self.Disabled and .15 or 0; body.TextTransparency=self.Disabled and .15 or 0
            self:_layoutDescription()
        end
        function self:SetTitle(text)
            self.Title=tostring(text or ''); self.TitleLabel.Text=self.Title; heading.Text=self.Title
            self:_layoutDescription(); window:SetSearch(window._query); return self
        end
        function self:SetContent(text) return self:SetValue(text,true) end
        function self:GetContent() return self.Value end
        function self:SetKind(nextKind)
            assert(kinds[nextKind],'Callout Kind is Info, Tip, Success, Warning or Danger')
            self.Kind=nextKind; window:_bind(stripe,{BackgroundColor3=kinds[nextKind].Role})
            icon.Default=kinds[nextKind].Icon; icon:SetRole(kinds[nextKind].Role); icon:Set(options.Icon)
            reveal(); return self
        end
        function self:GetKind() return self.Kind end
        function self:SetIcon(value) icon:Set(value); return self end
        connect(self,self.Frame:GetPropertyChangedSignal('AbsoluteSize'),function() self:_layoutDescription() end)
        connect(self,body:GetPropertyChangedSignal('TextSize'),function() self:_layoutDescription() end)
        self.Description=self.Description..' '..tostring(options.Content or '')
        local control=init(self,passed,options.Content or '')
        reveal()
        return control
    end

    -- CodeBlock: read-only monospace snippet with line numbers and Copy.
    function Section:AddCodeBlock(options)
        options=options or {}
        assert(options.Height==nil or finite(options.Height) and options.Height>=48 and options.Height<=600,'CodeBlock Height must be 48–600')
        assert(options.Code==nil or type(options.Code)=='string','CodeBlock Code must be a string')
        local self=base(self,'CodeBlock',options,(options.Height or 150)+44)
        local window=self._window
        self.Persist=false; self.Language=options.Language and tostring(options.Language):sub(1,16) or nil
        self.TitleLabel.Size=UDim2.new(1,-170,0,21)
        local copyText=window:_t17('Copiar','Copy')
        local copyButton
        if options.Copy~=false then
            copyButton=button(window,self,self.Frame,copyText,{Name='CopyCode',Position=UDim2.new(1,-78,0,0),Size=U2(78,22),TextSize=12},function() self:Copy() end)
        end
        if self.Language then
            label(window,self.Frame,self.Language:upper(),{Name='CodeLanguage',Position=UDim2.new(1,copyButton and -164 or -80,0,0),Size=U2(80,22),TextSize=11,TextXAlignment=Enum.TextXAlignment.Right},'Muted')
        end
        local scroll=ui(window,'ScrollingFrame',{Parent=self.Frame,Name='CodeScroll',Position=U2(0,42),Size=UDim2.new(1,0,1,-42),BorderSizePixel=1,
            ScrollBarThickness=4,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.XY,ScrollingDirection=Enum.ScrollingDirection.XY},
            {BackgroundColor3='Inset',BorderColor3='Border',ScrollBarImageColor3='Border'})
        local gutter=label(window,scroll,'',{Name='LineNumbers',Position=U2(6,6),Size=U2(28,0),AutomaticSize=Enum.AutomaticSize.Y,Font=Enum.Font.Code,
            TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,TextYAlignment=Enum.TextYAlignment.Top,Visible=options.LineNumbers~=false},'Muted')
        local code=label(window,scroll,'',{Name='Code',Position=U2(options.LineNumbers==false and 8 or 42,6),Size=U2(0,0),AutomaticSize=Enum.AutomaticSize.XY,
            Font=Enum.Font.Code,TextSize=12,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=false})
        function self:_normalize(value)
            value=tostring(value or ''):gsub('\r\n','\n'):gsub('\t','    ')
            assert(#value<=65536,'CodeBlock accepts at most 65536 bytes')
            return value
        end
        function self:_render()
            code.Text=self.Value
            local count=1; for _ in self.Value:gmatch('\n') do count=count+1 end
            local numbers={}; for i=1,math.min(count,4000) do numbers[i]=tostring(i) end
            gutter.Text=table.concat(numbers,'\n')
            code.TextTransparency=self.Disabled and .15 or 0
        end
        function self:SetCode(text) return self:SetValue(text,true) end
        function self:GetCode() return self.Value end
        function self:Copy()
            assert(not self.Destroyed,'This control has been destroyed')
            if self.Disabled then return false,'disabled' end
            local clip=type(setclipboard)=='function' and setclipboard or type(toclipboard)=='function' and toclipboard or nil
            local ok=false
            if clip then ok=pcall(clip,self.Value) end
            if copyButton then
                self._copyToken=(self._copyToken or 0)+1; local token=self._copyToken
                copyButton.Text=ok and window:_t17('Copiado!','Copied!') or window:_t17('Indisponível','Unavailable')
                task.delay(1.6,function() if not self.Destroyed and self._copyToken==token and copyButton.Parent then copyButton.Text=copyText end end)
            end
            if not ok and not clip then window:Notify({Title=self.Title,Content=window:_t17('Este executor não oferece setclipboard.','This executor does not provide setclipboard.'),Kind='warning'}) end
            if ok and type(options.OnCopy)=='function' then call(window,options.OnCopy,self.Value) end
            return ok,ok and nil or 'unavailable'
        end
        self.Scroll=scroll; self.CodeLabel=code; self.CopyButton=copyButton
        return init(self,options,options.Code or '')
    end
end
