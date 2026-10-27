-- Mid-transition values use a generic tween double; no renderer is emulated.
return function(Mock,Library,test)
    local sequence=0;local cache
    local function tick(dt)
        Mock.pump(dt or .5);Mock.Services.RunService.RenderStepped:Fire(dt or .5);Mock.pump(dt or .5)
    end
    local function fixture(options)
        sequence=sequence+1;Mock.AnimatedTweens=true;Mock.StrictIconLifecycle=true;Mock.ParentLockErrors=0;Mock.DestroyedIconWrites=0;Mock.Warnings={}
        cache=Library._thumbnails;Library._thumbnails={[Mock.Services.Players.LocalPlayer.UserId]='mock://avatar'}
        local passed={Id='motion-'..sequence,Settings=false,FileStorage=false,Theme='Hacker',LoadingScreen=false}
        for key,value in pairs(options or {}) do passed[key]=value end
        local w=Library:CreateWindow(passed);local s=w:CreateTab('Motion'):CreateSection({Title='Controls',Collapsible=true})
        tick();return w,s
    end
    local function finish(w)
        w:Destroy();Mock.pump(100);Mock.AnimatedTweens=false;Mock.StrictIconLifecycle=false;Mock.Geometry=false;Mock.MousePosition=nil;Mock.DeferDestroying=false
        Library._thumbnails=cache
        assert(Mock.Connections==0,'Motion leaked connections')
        assert(Mock.ParentLockErrors==0 and Mock.DestroyedIconWrites==0,'Motion touched a dead icon')
        assert(#Mock.Warnings==0,table.concat(Mock.Warnings,'\n'))
    end
    local function frameTracks(w)
        local n=0;for _,tracks in pairs(w._tweens) do for _ in pairs(tracks) do n=n+1 end end;return n
    end
    test('button hover press and activation animate decoration without moving hit boxes',function()
        local w,s=fixture();local calls=0;local c=s:AddButton({Title='Action',Callback=function() calls=calls+1 end})
        local position,size=c.Button.Position,c.Button.Size
        c.Button.MouseEnter:Fire();local line=assert(c.Button:FindFirstChild('MotionAccent'));assert(w._tweens[line])
        c.Button.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton1});c.Button.InputEnded:Fire({UserInputType=Enum.UserInputType.MouseButton1})
        assert(calls==0 and c.Button.Position==position and c.Button.Size==size)
        c.Button.Activated:Fire();Mock.pump();assert(calls==1)
        c.Button.MouseLeave:Fire();tick();assert(line.Size.X.Scale==0 and line.BackgroundTransparency==1)
        assert(c.Button.Position==position and c.Button.Size==size);finish(w)
    end)
    test('motion preferences disable decoration and settle existing effects immediately',function()
        local w,s=fixture();local c=s:AddButton({})
        c.Button.MouseEnter:Fire();w:SetReducedMotion(true)
        assert(frameTracks(w)==0 and c.Button:FindFirstChild('MotionAccent').BackgroundTransparency==1)
        w:SetReducedMotion(false);w:SetAnimations({Enabled=false});local b=s:AddButton({});b.Button.MouseEnter:Fire()
        assert(not b.Button:FindFirstChild('MotionAccent') and frameTracks(w)==0)
        w:SetAnimations({Enabled=true,Intensity='Off'});b.Button.Activated:Fire();tick();assert(frameTracks(w)==0)
        finish(w)
    end)
    test('field focus transitions preserve text and release their own subscriptions',function()
        local w,s=fixture();local baseline=Mock.Connections;local c=s:AddInput({Default='Exact value'})
        c.Input:CaptureFocus();assert(w._tweens[c.Input]);tick();assert(c.Input.BorderColor3==w.Palette.Accent and c:GetValue()=='Exact value')
        c.Input:ReleaseFocus();tick();assert(c.Input.BorderColor3==w.Palette.Border)
        c:Destroy();assert(Mock.Connections==baseline);finish(w)
    end)
    test('slider programmatic motion follows the target while dragging stays exact',function()
        local w,s=fixture();local c=s:AddSlider({Min=0,Max=100,Default=0});tick()
        c:SetValue(80);assert(c:GetValue()==80 and frameTracks(w)>0)
        w._drag={Owner=c};c:SetValue(30);w._drag=nil
        local track
        for _,child in ipairs(c.Frame:GetChildren()) do if child:IsA('Frame') and child.Size.Y.Offset==10 then track=child end end
        local fill
        for _,child in ipairs(track:GetChildren()) do if child:IsA('Frame') and child.Size.Y.Scale==1 then fill=child end end
        assert(fill.Size.X.Scale==.3);tick();assert(fill.Size.X.Scale==.3);finish(w)
    end)
    test('stat counters interpolate only their presentation and handle rapid reversals',function()
        local w,s=fixture();local c=s:AddStatCard({Value=0});tick();c:SetValue(100);tick(.06)
        assert(c:GetValue()==100 and w._tweens[c._counter])
        local tween=w._tweens[c._counter]['stat-count'].Tween;tween:Step(.5)
        assert(tonumber(c.ValueLabel.Text)==50 and c:GetValue()==100)
        c:SetValue(200);tick(.06);c:SetValue(-20);tick()
        assert(c:GetValue()==-20 and tonumber(c.ValueLabel.Text)==-20)
        c:SetLoading(true);tick();assert(c.ValueLabel.Text==w:_text('loading'))
        c:SetLoading(false);c:SetValue('Custom result');tick();assert(c.ValueLabel.Text=='Custom result');finish(w)
    end)
    test('bar charts grow from the zero baseline and remain bounded at the target',function()
        local w,s=fixture();local c=s:AddBarChart({Data={10,-5,20},Min=-10,Max=30})
        assert(#c._pool==3 and c._pool[1].Size.Y.Offset==0 and frameTracks(w)>0)
        tick();for _,bar in ipairs(c._pool) do assert(bar.Size.Y.Offset>0) end
        c:SetData({20,10,-5});tick();assert(c:GetValue()[1].Value==20 and c._pool[3].Size.Y.Offset>0)
        c:Clear();tick();for _,bar in ipairs(c._pool) do assert(not bar.Visible and not w._tweens[bar]) end
        finish(w)
    end)
    test('line and sparkline updates retain exact data while morphing pooled segments',function()
        local w,s=fixture();local c=s:AddLineChart({Data={1,4,2}});local spark=s:AddSparkline({Data={1,2,3}})
        tick();local node=c._pool[1];local old=node.Position
        c:SetData({8,2,6});Mock.Services.RunService.RenderStepped:Fire(.1)
        assert(c:GetValue()[1].Value==8 and c._pool[1]==node)
        assert(w._tweens[node] or node.Position~=old);tick()
        c:SetData({7});tick();assert(c._pool[1].Size.X.Offset==3 and not c._pool[2].Visible)
        spark:SetData({5,1,8});tick();assert(spark:GetValue()[3].Value==8);finish(w)
    end)
    test('progress chart fill and contrast masks share intermediate positions',function()
        local w,s=fixture();local c=s:AddProgressChart({Value=20});tick();c:SetValue(80)
        Mock.Services.RunService.RenderStepped:Fire(.1)
        for _,object in ipairs({c._pool[1],c._progressInkLeft,c._progressInkRight,c.ProgressLabel}) do
            local tracks=assert(w._tweens[object]);for _,record in pairs(tracks) do record.Tween:Step(.5) end
        end
        assert(math.abs(c._pool[1].Size.X.Scale-.5)<.001)
        assert(math.abs(c._progressInkLeft.Size.X.Scale-.5)<.001 and math.abs(c._progressInkRight.Position.X.Scale-.5)<.001)
        assert(c:GetValue()==80 and c.ProgressLabel.Text=='80%');tick();assert(c._pool[1].Size.X.Scale==.8)
        finish(w)
    end)
    test('Animated false and reduced motion keep every numeric display immediate',function()
        local w,s=fixture();local c=s:AddStatCard({Value=0,Animated=false});local bar=s:AddBarChart({Data={1,2},Animated=false});local p=s:AddProgressChart({Value=0,Animated=false})
        tick();c:SetValue(42);bar:SetData({3,2});p:SetValue(75);tick(.06)
        assert(tonumber(c.ValueLabel.Text)==42 and p._pool[1].Size.X.Scale==.75 and frameTracks(w)==0)
        w:SetReducedMotion(true);local line=s:AddLineChart({Data={1,2}});line:SetData({3,1});tick();assert(frameTracks(w)==0)
        finish(w)
    end)
    test('per-control motion opt-out includes fields buttons and composite children',function()
        local w,s=fixture();local button=s:AddButton({Animated=false});local input=s:AddInput({Animated=false});local toggle=s:AddToggle({Animated=false})
        tick();button.Button.MouseEnter:Fire();input.Input:CaptureFocus();toggle:SetValue(true);tick()
        assert(not button.Button:FindFirstChild('MotionAccent') and frameTracks(w)==0)
        input.Input:ReleaseFocus();finish(w)
    end)
    test('large chart budgets limit animated segments without dropping data',function()
        local w,s=fixture();local data={};for i=1,512 do data[i]=i%31 end
        local c=s:AddBarChart({Data=data,MaxPoints=512});assert(#c:GetValue()==512 and #c._pool==512)
        assert(frameTracks(w)<=96,'A large chart created unbounded motion tracks')
        tick();assert(frameTracks(w)==0 and not w:GetRuntimeStats().FrameConnection);finish(w)
    end)
    test('chart geometry uses logical coordinates at every supported UI scale',function()
        for _,scale in ipairs({.75,1,1.5}) do
            Mock.Geometry=true;local w,s=fixture({Scale=scale});local c=s:AddBarChart({Data={1,9,2},Min=0,Max=10,Animated=false});tick()
            local p,size=c.Plot.AbsolutePosition,c.Plot.AbsoluteSize
            for _,bar in ipairs(c._pool) do
                local b,bs=bar.AbsolutePosition,bar.AbsoluteSize
                assert(b.X>=p.X-.1 and b.Y>=p.Y-.1 and b.X+bs.X<=p.X+size.X+.1 and b.Y+bs.Y<=p.Y+size.Y+.1,'Scaled chart escaped the plot')
            end
            finish(w)
        end
    end)
    test('list selection and grid recycling finish the current record rather than an old one',function()
        local w,s=fixture();local list=s:AddVirtualList({Items={{Id='one',Text='One'},{Id='two',Text='Two'}}})
        list:SetValue('one');local grid=s:AddCardGrid({Items={{Id='a',Title='Alpha'},{Id='b',Title='Beta'}}});grid:SetValue('a');tick()
        assert(list._pool[1].Button:FindFirstChild('SelectionMotion'))
        grid:SetQuery('Beta');tick();assert(grid._cards[1].Record.Id=='b' and grid._cards[1].Title.Text=='Beta' and grid._cards[1].Title.TextTransparency==0)
        grid:SetQuery('');grid:SetValue('b');list:SetValue('two');tick()
        assert(list:GetValue()=='two' and grid:GetValue()=='b');finish(w)
    end)
    test('rapid tab selection ends on the current page with settled geometry',function()
        local w,s=fixture();local first=w.ActiveTab;local second=w:CreateTab('Other');second:CreateSection('Other'):AddToggle({})
        for _=1,4 do second:Select();first:Select() end
        tick();assert(w.ActiveTab==first and first.Frame.Visible and not second.Frame.Visible and first.Container.Position.Y.Offset==0)
        assert(first._motionMark.Size.X.Scale==1 and second._motionMark.Size.X.Scale==0);finish(w)
    end)
    test('tooltip and context menu exits cancel entry tracks and preserve selection',function()
        local w,s=fixture();local c=s:AddToggle({Tooltip='Help'});c:ShowTooltip();assert(w.TooltipFrame.Visible)
        c:HideTooltip();assert(not w.TooltipFrame.Visible)
        local calls=0;local menu=w:ContextMenu({Items={{Text='One',Callback=function() calls=calls+1 end}}},Vector2.new(100,100))
        assert(frameTracks(w)>0);menu:Select(1);tick();assert(calls==1 and not w._overlay and frameTracks(w)==0);finish(w)
    end)
    test('compact progress and step changes animate without changing their logical state',function()
        local w,s=fixture();local hud=w:CreateHUD();local p=hud:AddProgress({Value=0});local steps=s:AddStepper({Steps={{Id='a',Title='Download'},{Id='b',Title='Run'}}})
        tick();p:SetValue(60);steps:SetStep('a','Running','Waiting')
        assert(p:GetValue()==60 and w._tweens[p.Fill] and steps:GetSteps()[1].Status=='Running')
        tick();assert(p.Fill.Size.X.Scale==.6);finish(w)
    end)
    test('hidden data updates do not keep presentation animations running',function()
        local w,s=fixture();local c=s:AddLineChart({Data={1,2}});local stat=s:AddStatCard({Value=0});tick()
        w:Hide();tick();c:SetData({8,1});stat:SetValue(20);tick()
        assert(c:GetValue()[1].Value==8 and stat:GetValue()==20 and frameTracks(w)==0)
        w:Show();tick();assert(w.Main.Visible and frameTracks(w)==0);finish(w)
    end)
    test('new motion obeys speed intensity and survives theme changes',function()
        local w,s=fixture();w:SetAnimations({Speed=2,Intensity='Subtle'});local c=s:AddButton({})
        c.Button.MouseEnter:Fire();local line=c.Button:FindFirstChild('MotionAccent');local record=w._tweens[line].feedback
        assert(record and record.Tween.PlaybackState==Enum.PlaybackState.Playing)
        w:SetTheme('Paper');tick();assert(c.Button.TextColor3==w:_ink('Text',c.Button) and frameTracks(w)==0)
        c.Button.MouseEnter:Fire();w:SetAnimations({Intensity='Off'});assert(frameTracks(w)==0);finish(w)
    end)
    test('actual header drag uses smoothing and disabling motion settles the target',function()
        local w=fixture();local header=w.TitleLabel.Parent
        local start=w.Main.Position;Mock.MousePosition=Vector2.new(300,100)
        header.InputBegan:Fire({UserInputType=Enum.UserInputType.MouseButton1})
        Mock.MousePosition=Vector2.new(340,120)
        Mock.Services.UserInputService.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseMovement})
        assert(w._dragRender and w.Main.Position.X.Offset==start.X.Offset)
        Mock.Services.RunService.RenderStepped:Fire(1/60);assert(w.Main.Position.X.Offset>start.X.Offset)
        w:SetAnimations({Enabled=false});assert(not w._dragRender and not w:GetRuntimeStats().FrameConnection)
        Mock.Services.UserInputService.InputEnded:Fire({UserInputType=Enum.UserInputType.MouseButton1})
        finish(w)
    end)
    test('destroying a moving graph grid HUD and parent leaves no work or locked icons',function()
        local w,s=fixture();local c=s:AddLineChart({Data={1,2,3}});local grid=s:AddCardGrid({Items={{Id='one',Title='One',Icon='diamond'}}})
        local hud=w:CreateHUD();hud:AddProgress({Value=20});c:SetData({3,2,1});grid:SetValue('one')
        Mock.DeferDestroying=true;grid.Frame:Destroy();c.Frame:Destroy();hud.Frame:Destroy();tick()
        assert(c.Destroyed and grid.Destroyed and hud.Destroyed);finish(w)
    end)
end
