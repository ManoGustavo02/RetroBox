-- RetroBox 2.11 refined controls and motion. Logic and simulated geometry only.
return function(Mock,Library,test)
    local sequence=0
    local function fixture(options)
        sequence=sequence+1; Mock.Warnings={}
        local passed={Id='refined-'..sequence,Settings=false,FileStorage=false,LoadingScreen=false,ReducedMotion=true}
        for key,value in pairs(options or {}) do passed[key]=value end
        local w=Library:CreateWindow(passed)
        local s=w:CreateTab('Refined'):CreateSection({Title='Controls',Collapsible=true})
        Mock.pump(); return w,s
    end
    local function finish(w)
        w:Destroy(); Mock.pump(100); Mock.AnimatedTweens=false
        assert(Mock.Connections==0,'Refined controls leaked connections: '..Mock.Connections)
        assert(#Mock.Warnings==0,table.concat(Mock.Warnings,'\n'))
    end
    local function tick(dt) Mock.pump(dt or .5); Mock.Services.RunService.RenderStepped:Fire(dt or .5); Mock.pump(dt or .5) end

    test('segmented validates options, selects by click and keeps its indicator in place',function()
        local w,s=fixture(); local seen={}
        assert(not pcall(function() s:AddSegmented({Options={'Solo'}}) end))
        assert(not pcall(function() s:AddSegmented({Options={'A','A'}}) end))
        local c=s:AddSegmented({Id='mode',Title='Mode',Options={'Closest','Random','Lowest'},Callback=function(v) seen[#seen+1]=v end})
        Mock.pump(); assert(c:GetValue()=='Closest' and #seen==0 and #c.Segments==3 and c:GetIndex()==1)
        c.Segments[3].Activated:Fire(); Mock.pump()
        assert(c:GetValue()=='Lowest' and seen[1]=='Lowest' and w:GetFlag('mode')=='Lowest')
        assert(math.abs(c.Indicator.Position.X.Scale-2/3)<1e-9 and math.abs(c.Indicator.Size.X.Scale-1/3)<1e-9)
        assert(c.Segments[3].TextColor3==w:_ink('AccentText',c.Segments[3],4.5,w.Palette.Accent))
        assert(not pcall(function() c:SetValue('Missing') end) and c:GetValue()=='Lowest')
        c:SetDisabled(true); c.Segments[1].Activated:Fire(); Mock.pump(); assert(c:GetValue()=='Lowest' and #seen==1)
        c:SetDisabled(false); w:SetTheme('Hacker'); assert(c.Indicator.BackgroundColor3==w.Palette.Accent)
        c:SetOptions({'Near','Far'}); Mock.pump(); assert(#c.Segments==2 and c:GetValue()=='Near' and seen[2]=='Near')
        c:SetOptions({'Far','Near','Mid'}); assert(c:GetValue()=='Near' and c:GetIndex()==2)
        local exported=w:ExportConfig(true); assert(exported.Flags.mode.Type=='Segmented' and exported.Flags.mode.Value=='Near')
        c:SetValue('Far',true); assert(w:ImportConfig(exported,{Silent=true}) and c:GetValue()=='Near')
        finish(w)
    end)

    test('range slider steps, orders, respects MinGap and drags the nearest thumb',function()
        local w,s=fixture()
        assert(not pcall(function() s:AddRangeSlider({Min=5,Max=5}) end))
        local c=s:AddRangeSlider({Id='delay',Min=0,Max=10,Step=.5,MinGap=1,Default={Min=2,Max=6},Suffix='s'})
        assert(c:GetValue().Min==2 and c:GetValue().Max==6 and c.ValueLabel.Text=='2s – 6s')
        c:SetRange(1.3,8.8); local a,b=c:GetRange(); assert(a==1.5 and b==9)
        assert(not pcall(function() c:SetRange(7,3) end))
        assert(not pcall(function() c:SetRange(4,4.5) end))
        local value=c:GetValue(); value.Min=-1; assert(c:GetValue().Min==1.5)
        assert(math.abs(c.LowThumb.Position.X.Scale-.15)<1e-9 and math.abs(c.HighThumb.Position.X.Scale-.9)<1e-9)
        local width=c.Track.AbsoluteSize.X
        Mock.MousePosition=Vector2.new(width*.2,0); c.Track.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton1}); w:_endDrag()
        assert(c:GetValue().Min==2 and c:GetValue().Max==9,'nearest thumb moved')
        Mock.MousePosition=Vector2.new(width*.95,0); c.LowThumb.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton1}); w:_endDrag()
        assert(c:GetValue().Min==8 and c:GetValue().Max==9,'MinGap keeps the low thumb below the high thumb')
        Mock.MousePosition=nil
        local exported=w:ExportConfig(true); assert(exported.Flags.delay.Value.Min==8)
        c:SetRange(0,10,true); local imported,why=w:ImportConfig(exported,{Silent=true}); assert(imported,why); assert(c:GetValue().Min==8 and c:GetValue().Max==9,c:GetValue().Min..","..c:GetValue().Max)
        finish(w)
    end)

    test('number steps with precision, clamps and repeats only while held',function()
        local w,s=fixture(); local values={}
        local c=s:AddNumber({Id='speed',Min=0,Max=2,Step=.25,Default=1,Suffix=' x',Callback=function(v) values[#values+1]=v end})
        assert(c.Precision==2 and c.Input.Text=='1.00 x')
        assert(c:Increment(1) and c:GetValue()==1.25); Mock.pump(); assert(values[1]==1.25)
        c:SetValue(1.9); assert(c:GetValue()==2 and not c:Increment(1) and not c.IncrementButton.Active)
        c.DecrementButton.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton1})
        Mock.pump(.3); assert(c:GetValue()==2,'no repeat before the hold delay')
        Mock.pump(.2); Mock.pump(.07); Mock.pump(.07); local held=c:GetValue(); assert(held<2)
        c.DecrementButton.InputEnded:Fire({UserInputType=Enum.UserInputType.MouseButton1}); Mock.pump(1)
        assert(c:GetValue()==held,'release stops repetition')
        c.Input:CaptureFocus(); c.Input.Text='0.6 x'; c.Input:ReleaseFocus(); assert(c:GetValue()==.5)
        c.Input:CaptureFocus(); c.Input.Text='abc'; c.Input:ReleaseFocus(); assert(c:GetValue()==.5 and c.Input.Text=='0.50 x')
        local free=s:AddNumber({Id='free',Step=10}); assert(free:GetValue()==0 and free:Increment(-3) and free:GetValue()==-30)
        assert(not pcall(function() s:AddNumber({Min=1,Max=0}) end))
        c:SetDisabled(true); assert(not c:Increment(-1) and c:GetValue()==.5)
        finish(w)
    end)

    test('callout grows with content, changes kind and stays out of profiles',function()
        local w,s=fixture()
        assert(not pcall(function() s:AddCallout({Kind='Loud'}) end))
        local c=s:AddCallout({Id='note',Title='Modo educativo',Content='Curto.',Kind='Tip'})
        Mock.pump(); local short=c.Frame.Size.Y.Offset
        assert(c:GetKind()=='Tip' and c.Heading.Text=='Modo educativo' and c.Body.Text=='Curto.' and not c.TitleLabel.Visible)
        c:SetContent(string.rep('Uma linha longa de explicação. ',30)); assert(c.Frame.Size.Y.Offset>short)
        c:SetKind('Danger'); assert(c.Stripe.BackgroundColor3==w.Palette.Danger and c:GetKind()=='Danger')
        assert(not pcall(function() c:SetKind('Nope') end))
        c:SetTitle(''); assert(not c.Heading.Visible and c.Body.Position.Y.Offset==9)
        w:SetSearch('modo'); w:SetSearch('')
        assert(w:ExportConfig(true).Flags.note==nil)
        local plain=s:AddCallout('Somente texto'); assert(plain:GetContent()=='Somente texto' and plain:GetKind()=='Info')
        finish(w)
    end)

    test('code block normalizes text, numbers lines and copies explicitly',function()
        local w,s=fixture(); local copied,events=nil,0
        local c=s:AddCodeBlock({Id='snippet',Title='Exemplo',Language='lua',Code='local a = 1\r\n\tprint(a)\nreturn a',OnCopy=function() events=events+1 end})
        assert(c:GetCode()=='local a = 1\n    print(a)\nreturn a' and c.Scroll:FindFirstChild('LineNumbers').Text=='1\n2\n3')
        assert(c.CodeLabel.RichText==false and w:ExportConfig(true).Flags.snippet==nil)
        local ok,reason=c:Copy(); Mock.pump(); assert(not ok and reason=='unavailable' and events==0)
        setclipboard=function(text) copied=text end
        ok=c:Copy(); Mock.pump(); assert(ok and copied==c:GetCode() and events==1 and c.CopyButton.Text==w:_t17('Copiado!','Copied!'))
        Mock.pump(2); assert(c.CopyButton.Text==w:_t17('Copiar','Copy'))
        setclipboard=nil
        assert(not pcall(function() c:SetCode(string.rep('x',65537)) end))
        local bare=s:AddCodeBlock({Copy=false,LineNumbers=false}); assert(bare.CopyButton==nil)
        finish(w)
    end)

    test('refined controls work in reusable components and transactional forms',function()
        local w,s=fixture()
        Library:RegisterComponent('refined-aim',function(ctx)
            ctx:Add('Segmented',{Id='target',Options={'Head','Torso'}})
            ctx:Add('Number',{Id='fov',Min=10,Max=120,Default=70})
            ctx:Add('RangeSlider',{Id='delay',Min=0,Max=1,Step=.1,Default={Min=.2,Max=.4}})
            ctx:Add('Callout',{Id='note',Content='Demonstração local.'})
        end,{Replace=true})
        local group=s:AddComponent('refined-aim',{Id='aim'})
        assert(group:GetValue().target=='Head' and group:GetValue().fov==70 and group:GetValue().delay.Max==.4)
        group:SetValue({target='Torso',fov=90})
        assert(group:Get('target'):GetValue()=='Torso' and group:Get('fov'):GetValue()==90)
        local form=s:CreateForm({Id='prefs',Fields={{Id='mode',Type='Segmented',Options={'A','B'}},{Id='count',Type='Number',Min=0,Max=5}}})
        form.Fields.mode:SetValue('B'); assert(form:IsDirty()); form:Apply(); Mock.pump(); assert(form:GetValue().mode=='B' and form:GetValue().count==0)
        finish(w)
    end)

    test('press pulse, power-on line, check bounce and notice timer follow motion preferences',function()
        local created={}; local create=Mock.Services.TweenService.Create
        Mock.Services.TweenService.Create=function(service,object,info,goals) created[#created+1]={Object=object,Info=info}; return create(service,object,info,goals) end
        Mock.AnimatedTweens=true
        local w,s=fixture({ReducedMotion=false,Theme='Hacker'})
        local line=w.Main:FindFirstChild('PowerOnLine'); assert(line and line.Visible,'power-on line plays on first show')
        tick(); assert(not line.Visible)
        local b=s:AddButton({Title='Pulse'}); b.Button.Activated:Fire()
        local pulse=assert(b.Button:FindFirstChild('PressPulse')); assert(pulse.Visible and pulse.Size.X.Scale<1)
        tick(); assert(not pulse.Visible and b.Button.Size==UDim2.new(1,0,0,30))
        w:SetAnimations({Speed=2}); created={}
        local notice=w:Notify({Title='Hi',Duration=3}); local timer=assert(notice.Timer)
        local timed; for _,entry in ipairs(created) do if entry.Object==timer then timed=entry end end
        assert(timed and timed.Info.Time==3,'countdown keeps wall-clock duration')
        local silent=w:Notify({Title='Quiet',Timer=false}); assert(not silent.Timer.Visible)
        w:SetAnimations({Speed=1,Intensity='Subtle'}); w:Hide(); w:Show(); assert(not line.Visible,'subtle skips the power-on line')
        b.Button.Activated:Fire(); assert(not pulse.Visible)
        w:SetAnimations({Intensity='Normal'}); w:SetReducedMotion(true); b.Button.Activated:Fire(); assert(not pulse.Visible)
        local n=s:AddNumber({Default=1}); assert(n:Increment(1))
        Mock.Services.TweenService.Create=create
        finish(w)
    end)
end
