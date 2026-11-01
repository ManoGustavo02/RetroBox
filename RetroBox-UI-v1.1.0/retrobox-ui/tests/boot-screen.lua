-- RetroBox 2.12 boot screen. Timers and tweens are simulated; no renderer.
return function(Mock,Library,test)
    local sequence=0
    local function create(options)
        sequence=sequence+1; Mock.Warnings={}; Mock.AnimatedTweens=true
        local passed={Id='boot-'..sequence,Title='Meu Script',Settings=false,FileStorage=false}
        for key,value in pairs(options or {}) do passed[key]=value end
        return Library:CreateWindow(passed)
    end
    local function finish(w)
        w:Destroy(); Mock.pump(100); Mock.AnimatedTweens=false
        assert(Mock.Connections==0,'Boot leaked connections: '..Mock.Connections)
        assert(#Mock.Warnings==0,table.concat(Mock.Warnings,'\n'))
    end
    local function advance(seconds) for _=1,math.ceil(seconds/.05) do Mock.pump(.05) end end

    test('boot screen plays by default, types the title and fills progress in order',function()
        local completed
        local w=create({LoadingScreen={Duration=2,OnComplete=function(skipped) completed=skipped end}})
        local s=w:CreateTab('Main'):CreateSection('S'); s:AddToggle({Id='a'}); s:AddSlider({Id='b'})
        local boot=assert(w:GetBootScreen()); assert(boot.Frame.Parent==w.Main and boot.Frame.Size==UDim2.fromScale(1,1))
        assert(boot.TitleLabel.Text=='' and boot.PercentLabel.Text=='000%' and not boot.Lines[1].Row.Visible)
        advance(.3); local partial=boot.TitleLabel.Text; assert(#partial>0 and #partial<#'Meu Script','title is typed')
        assert(boot.Backdrop.Active and boot.Backdrop.ZIndex>=300 and boot.Frame.ZIndex>=300,'the boot sits above the window and captures pointer input')
        local last=0
        for _=1,24 do
            advance(.05)
            local percent=tonumber(boot.PercentLabel.Text:match('%d+')); assert(percent>=last,'progress never moves back'); last=percent
        end
        assert(boot.TitleLabel.Text=='Meu Script' and boot.Lines[1].Row.Visible)
        assert(boot.Lines[3].Text.Text:find('1',1,true) and boot.Lines[3].Text.Text:find('2',1,true),'layout step counts tabs and controls')
        advance(1.5); assert(w:GetBootScreen()==nil and completed==false and boot.Destroyed)
        assert(w.Main:FindFirstChild('BootScreen')==nil)
        finish(w)
    end)

    test('click, Enter and hide skip the boot; Skippable=false keeps it running',function()
        local result
        local w=create({LoadingScreen={OnComplete=function(skipped) result=skipped end}})
        local boot=w:GetBootScreen(); advance(.2); boot.Backdrop.Activated:Fire(); assert(boot.Finishing)
        advance(1); assert(boot.Destroyed and result==true); finish(w)
        w=create(); boot=w:GetBootScreen()
        Mock.Services.UserInputService.InputBegan:Fire({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.Return},false)
        advance(1); assert(boot.Destroyed); finish(w)
        w=create({LoadingScreen={Skippable=false,Duration=1}}); boot=w:GetBootScreen()
        boot.Backdrop.Activated:Fire(); assert(not boot.Finishing and boot.HintLabel.Text=='')
        advance(2); assert(boot.Destroyed); finish(w)
        w=create(); boot=w:GetBootScreen(); w:Hide(); advance(1)
        assert(boot.Destroyed and w:GetBootScreen()==nil); w:Show(); advance(1); assert(w:GetBootScreen()==nil,'boot never replays on Show')
        finish(w)
    end)

    test('motion preferences, Card style and validation keep earlier contracts',function()
        local w=create({ReducedMotion=true}); assert(w:GetBootScreen()==nil); finish(w)
        w=create({LoadingScreen=false}); assert(w:GetBootScreen()==nil and w._loading==nil); finish(w)
        w=create({LoadingScreen={Style='Card'}}); assert(w:GetBootScreen()==nil and w._loading); advance(1); assert(w._loading==nil); finish(w)
        w=create({ReducedMotion=true,LoadingScreen={Steps={'Conectando'},Subtitle='Demo'}})
        local boot=assert(w:GetBootScreen(),'explicit request still shows a static boot')
        assert(boot.TitleLabel.Text=='Meu Script' and boot.PercentLabel.Text=='100%' and boot.Lines[1].Row.Visible and boot.SubtitleLabel.Text=='Demo')
        assert(#boot.Lines==1 and boot.Lines[1].Text.Text=='> Conectando')
        advance(.9); assert(boot.Destroyed); finish(w)
        for _,bad in ipairs({{Duration=20},{Steps={}},{Style='Fancy'},{Steps={string.rep('x',97)}},{Skippable='no'}}) do
            assert(not pcall(function() create({LoadingScreen=bad}) end))
        end
        Mock.AnimatedTweens=false
    end)

    test('boot follows theme changes and releases everything when destroyed mid-sequence',function()
        local called=false
        local w=create({Theme='Hacker',LoadingScreen={OnComplete=function() called=true end}})
        local boot=w:GetBootScreen(); advance(1.2)
        local lit; for _,cell in ipairs(boot.Cells) do if cell:GetAttribute('On') then lit=cell; break end end
        assert(lit and lit.BackgroundColor3==w.Palette.Accent)
        w:SetTheme('Amber'); assert(lit.BackgroundColor3==w.Palette.Accent,'cell accent'); assert(boot.Frame.BackgroundColor3==w.Palette.Background,'frame background')
        local replay=w:ShowBootScreen({Duration=1}); assert(boot.Destroyed and w:GetBootScreen()==replay); Mock.pump()
        finish(w); assert(replay.Destroyed)
        assert(called,'replacing a boot completes the previous one')
    end)
end
