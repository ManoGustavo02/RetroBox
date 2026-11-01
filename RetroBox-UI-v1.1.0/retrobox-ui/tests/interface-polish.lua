-- RetroBox 2.13 Ideas Center and Script Hub presentation. Logic and simulated geometry only.
return function(Mock,Library,test)
    local index=0
    local function tick(dt) Mock.pump(dt or 0);Mock.Services.RunService.RenderStepped:Fire(.1);Mock.pump() end
    local function feedback(options)
        index=index+1;Mock.Warnings={};Mock.StrictIconLifecycle=true;Mock.ParentLockErrors=0;Mock.DestroyedIconWrites=0
        local calls={}
        local opts={Id='polish-'..index,Settings=false,LoadingScreen=false,FileStorage=false,Locale='pt-BR',Cooldown=0,MinLength=10,MaxLength=40,
            WebhookURL='https://discord.com/api/webhooks/'..tostring(710000000000000000+index)..'/'..('fixture_token_'):rep(5),
            MetadataProvider=function() return {Name='Jogo de teste'} end,AvatarProvider=function() return 'https://tr.rbxcdn.com/avatar.png' end,
            Request=function(spec) calls[#calls+1]=spec;return {StatusCode=200,Body='{"id":"345678901234567890"}'} end}
        for key,value in pairs(options or {}) do opts[key]=value end
        local hub=Library:CreateFeedbackHub(opts);tick()
        return hub,calls
    end
    local function close(window)
        window:Destroy();tick(100);Mock.StrictIconLifecycle=false;Mock.Geometry=false
        assert(Mock.Connections==0,'Interface polish leaked '..Mock.Connections..' connections')
        assert(Mock.ParentLockErrors==0 and Mock.DestroyedIconWrites==0)
        assert(#Mock.Warnings==0,table.concat(Mock.Warnings,'\n'))
    end

    test('ideas center header, category cards and stepper reflect the current choice',function()
        local h=feedback();local v=h.Launcher;local w=h.Window
        assert(v.HeroBar.BackgroundColor3==w.Palette.Accent and v.HeroTile.Visible and v.HeroIcon.Frame)
        assert(Library:ContrastRatio(v.HeroTitle.TextColor3,v.Hero.BackgroundColor3)>=4.5)
        h:SetCategory('BugReport');tick()
        for _,card in ipairs(v.Cards) do
            local selected=card.Id=='BugReport'
            assert((card.Button.BorderSizePixel==2)==selected and card.Bar.Visible==selected,'selected card frame')
            assert((card.Check.Frame~=nil and card.Check.Frame.Visible)==selected or not selected,'selected card check')
            assert(card.Tile.BackgroundColor3==w.Palette[selected and 'Accent' or 'Inset'])
            assert(Library:ContrastRatio(card.Title.TextColor3,card.Button.BackgroundColor3)>=4.5)
        end
        assert(v.Badges.Compose.Digit.Text=='1' and v.Badges.Review.Digit.Text==tostring(#v.PageOrder))
        h:SetPage('Review');tick()
        assert(v.Badges.Compose.Digit.Text=='' and v.Badges.Compose.Frame.BackgroundColor3==w.Palette.Success)
        assert(v.Pages.Review.BackgroundColor3==w.Palette.Accent and v.Rail.BackgroundColor3==w.Palette.Accent)
        for _,key in ipairs(v.PageOrder) do assert(Library:ContrastRatio(v.Pages[key].TextColor3,v.Pages[key].BackgroundColor3)>=4.5,key) end
        assert(v.Next.BackgroundColor3==w.Palette.Accent or not v.Next.Visible)
        close(w)
    end)

    test('message length bar follows the minimum and maximum limits',function()
        local h=feedback();local v=h.Launcher;local w=h.Window
        h:SetMessage('curto');tick();assert(v.CounterFill.BackgroundColor3==w.Palette.Muted)
        h:SetMessage('Uma mensagem dentro do limite.');tick()
        assert(v.CounterFill.BackgroundColor3==w.Palette.Accent and v.CounterFill.Size.X.Scale>0 and v.CounterFill.Size.X.Scale<1)
        h:SetMessage(('x'):rep(60));tick();assert(v.CounterFill.BackgroundColor3==w.Palette.Danger and v.CounterFill.Size.X.Scale==1)
        close(w)
    end)

    test('confirmed delivery shows the success panel and writing another resets it',function()
        local h,calls=feedback();local v=h.Launcher
        assert(not v.Success.Visible)
        h:SetMessage('Mensagem enviada com sucesso.');h:SetPage('Review');h:Submit();tick()
        assert(#calls==1 and h:GetStatus().State=='Sent' and v.Success.Visible and v.SuccessTitle.Text=='Mensagem enviada!')
        assert(v.Again.Text=='Escrever outra')
        v.Again.Activated:Fire();tick()
        assert(h:GetDraft().Message=='' and h:GetPage()=='Compose' and not v.Success.Visible and #calls==1)
        close(h.Window)
    end)

    test('success panel and stepper fit narrow scaled windows in both locales',function()
        local oldView=Mock.Viewport
        local function inside(a,b)
            return a.AbsolutePosition.X>=b.AbsolutePosition.X-.5 and a.AbsolutePosition.X+a.AbsoluteSize.X<=b.AbsolutePosition.X+b.AbsoluteSize.X+1
        end
        for _,size in ipairs({Vector2.new(1280,720),Vector2.new(320,600)}) do
            Mock.Viewport=size;Mock.Geometry=true
            local h=feedback({Scale=.75});h.Window:SetTextScale(1.4)
            h:SetMessage('Uma mensagem para confirmar.');h:SetPage('Review');h:Submit();tick()
            for _,locale in ipairs({'pt-BR','en-US'}) do
                h.Window:SetLocale(locale);h.Launcher:Layout();local v=h.Launcher
                for _,object in ipairs({v.SuccessTitle,v.SuccessMessage,v.Again,v.SuccessTile}) do assert(inside(object,v.Success),'success overflow '..object.Name) end
                for _,key in ipairs(v.PageOrder) do assert(inside(v.Pages[key],v.Navigation),'step overflow') end
            end
            close(h.Window)
        end
        Mock.Viewport=oldView
    end)

    local function record(id,place,callback)
        return {Id=id,Name='Game '..id,Description='Description '..id,PlaceId=place,
            Scripts={{Id='main',Title='Script '..id,Description='Instructions '..id,Author='Developer',Version='1.0',Callback=callback or function() return true end}}}
    end
    test('script hub shows status pills, the current-game tag and a dock status light',function()
        Mock.Geometry=true;Mock.Warnings={}
        local hub=Library:CreateScriptHub({Id='polish-hub',FileStorage=false,Settings=false,ReducedMotion=true,Games={record('one',game.PlaceId),record('two',222)}})
        Mock.pump();local l=hub.Launcher;local w=hub.Window
        local current
        for _,row in ipairs(hub.GameList._pool) do if row.Button.Visible and row.HereTag and row.HereTag.Visible then current=row end end
        assert(current,'current game is tagged')
        assert(current.LauncherTitle.Position.X.Offset+current.LauncherTitle.Size.X.Offset<=current.HereTag.Position.X.Offset)
        assert(Library:ContrastRatio(current.HereTag.TextColor3,current.HereTag.BackgroundColor3)>=4.49999)
        local row=hub.ScriptList._pool[1]
        assert(row.LauncherState.BackgroundTransparency==0 and row.LauncherState.Size.X.Offset<=126)
        assert(l.UI.StatusLed.BackgroundColor3==w:_paletteFor(l.UI.StatusLed).Success,'available script lights the dock')
        assert(hub.PlayButton:Press());Mock.pump()
        assert(hub:GetScriptStatus('one','main').Status=='Completed' and row.LauncherState.BackgroundColor3==w:_paletteFor(row.LauncherState).Success)
        for _,name in ipairs(Library:GetThemeNames()) do
            w:SetTheme(name);hub:SetTheme(name);Mock.pump()
            assert(Library:ContrastRatio(row.LauncherState.TextColor3,row.LauncherState.BackgroundColor3)>=4.49999,name)
        end
        close(w)
    end)
end
