return function(Mock,Library,test)
    local index=0
    local function tick(dt) Mock.pump(dt or 0);Mock.Services.RunService.RenderStepped:Fire(.1);Mock.pump() end
    local function fixture(options)
        index=index+1;Mock.Warnings={};Mock.StrictIconLifecycle=true;Mock.ParentLockErrors=0;Mock.DestroyedIconWrites=0
        local calls={};local opts={Id='feedback-launcher-'..index,Settings=false,LoadingScreen=false,FileStorage=false,Locale='pt-BR',Cooldown=0,
            WebhookURL='https://discord.com/api/webhooks/'..tostring(700000000000000000+index)..'/'..('fixture_token_'):rep(5),
            MetadataProvider=function() return {Name='Jogo de teste'} end,AvatarProvider=function() return 'https://tr.rbxcdn.com/avatar.png' end,
            Request=function(spec) calls[#calls+1]=spec;return {StatusCode=200,Body='{"id":"345678901234567890"}'} end}
        for key,value in pairs(options or {}) do opts[key]=value end
        local hub=Library:CreateFeedbackHub(opts);tick()
        return hub,calls
    end
    local function finish(h)
        h.Window:Destroy();tick(100);Mock.StrictIconLifecycle=false;Mock.Geometry=false;Mock.YieldingTasks=false;Mock.DeferDestroying=false
        assert(Mock.Connections==0,'Feedback launcher leaked '..Mock.Connections..' connections')
        assert(Mock.ParentLockErrors==0 and Mock.DestroyedIconWrites==0)
        assert(#Mock.Warnings==0,table.concat(Mock.Warnings,'\n'))
    end
    test('feedback defaults to a dedicated launcher with native controls and a compose page',function()
        local h,calls=fixture();local v=h.Launcher
        assert(v and v.Root.Parent==h.Tab.Frame and not h.Tab.Container.Visible and h:GetPage()=='Compose')
        assert(#v.Cards==4 and not h.Controls.Category.Frame.Visible and #calls==0)
        assert(h.Window.PageHost.Position.X.Offset==12 and not h.Window.SearchContainer.Visible);finish(h)
    end)
    test('classic feedback remains available and launcher options validate before allocation',function()
        local h=fixture({Layout='Classic'});assert(not h.Launcher and h.Tab.Container.Visible and h:GetPage()=='Compose');finish(h)
        assert(not pcall(Library.CreateFeedbackHub,Library,{Layout='unknown'}) and next(Library.Windows)==nil)
    end)
    test('category cards select stable IDs without changing message or posting',function()
        local h,calls=fixture();h:SetMessage('Uma mensagem que deve ser mantida.')
        for _,card in ipairs(h.Launcher.Cards) do card.Button.Activated:Fire();tick();assert(h:GetDraft().Category==card.Id) end
        assert(h:GetDraft().Message=='Uma mensagem que deve ser mantida.' and #calls==0)
        h.Window:SetLocale('en-US');assert(h.Launcher.Cards[1].Title.Text=='Request script');finish(h)
    end)
    test('launcher pages preserve draft and never collect console data or submit automatically',function()
        local h,calls=fixture();h:SetDraft({Message='Um relato completo para revisar.',Diagnostics={Include=true,Text='Erro copiado',Code='E_TEST'}})
        for _,page in ipairs({'Diagnostics','Review','Compose','Review'}) do h:SetPage(page);assert(h:GetPage()==page) end
        assert(h:GetDraft().Diagnostics.Text=='Erro copiado' and #h:GetDiagnosticRecords()==0 and not h.Diagnostics.Capturing and #calls==0);finish(h)
    end)
    test('review displays the entire message and exact prepared diagnostic',function()
        local h,calls=fixture();local message=('Texto com detalhes. '):rep(80)
        h:SetDraft({Message=message,Diagnostics={Include=true,Text='stack trace literal\nline 42'}});h:SetPage('Review')
        local preview=h:GetPreview()
        assert(h.Controls.MessagePreview:GetValue()==preview.Message and h.Controls.MessagePreview.Description=='')
        assert(h.Controls.ReviewDiagnostic:GetValue()==h.Diagnostics:Format(preview.Diagnostics) and #calls==0);finish(h)
    end)
    test('diagnostic preview stays read-only after values theme locale scale and profile refresh',function()
        local h=fixture();h:SetDraft({Diagnostics={Include=true,Text='An error trace'}});h:SetPage('Diagnostics')
        for _,name in ipairs({'Paper','Terminal','Hacker'}) do
            h.Window:SetTheme(name);h.Window:SetLocale('en-US');h.Window:SetTextScale(1.4);h:Refresh()
            assert(not h.Controls.DiagnosticPreview.Input.TextEditable)
        end
        assert(h.Window:ImportConfig(h.Window:ExportConfig(),{Silent=true}))
        h:Refresh();assert(not h.Controls.DiagnosticPreview.Input.TextEditable);finish(h)
    end)
    test('native send button in the review page posts exactly once with aligned caption',function()
        local h,calls=fixture();h:SetMessage('Relato enviado pelo botão nativo.');h:SetPage('Review')
        local c=h.Controls.Submit
        assert(c.Frame.Visible and c.Button.Size.Y.Offset>=42 and not c.TitleLabel.Visible and c.Button.Position.Y.Offset==0)
        c.Button.Activated:Fire();tick();assert(#calls==1 and h:GetStatus().State=='Sent');finish(h)
    end)
    test('page navigation closes dropdown overlays and leaves diagnostic consent untouched',function()
        local h=fixture();h:SetDraft({Diagnostics={Include=true,Text='Trace'}});h:SetPage('Diagnostics')
        h.Controls.DiagnosticRecords:SetOpen(true);assert(h.Controls.DiagnosticRecords.Open)
        h:SetPage('Review');assert(not h.Controls.DiagnosticRecords.Open and h:GetDraft().Diagnostics.Include);finish(h)
    end)
    test('focusing a control routes to its launcher page',function()
        local h=fixture();h:SetDraft({Diagnostics={Include=true,Text='Trace'}});h:SetPage('Review')
        assert(h.Window:FocusControl(h.Controls.Message) and h:GetPage()=='Compose')
        assert(h.Window:FocusControl(h.Controls.DiagnosticText) and h:GetPage()=='Diagnostics');finish(h)
    end)
    test('attached feedback launcher preserves the existing window chrome and controls',function()
        local w=Library:CreateWindow({Id='feedback-attached-launcher',Settings=false,LoadingScreen=false,FileStorage=false})
        local tab=w:CreateTab('Original');local button=tab:CreateSection('Original'):AddButton({Title='Original'})
        local before=w.PageHost.Position.X.Offset
        local h=w:CreateFeedbackHub({Id='attached',Layout='Launcher'});tick()
        assert(h.Launcher and not h.OwnsWindow and w.PageHost.Position.X.Offset==before and not button.Destroyed)
        h:Destroy();assert(not w.Destroyed and not button.Destroyed);w:Destroy();tick(100);assert(Mock.Connections==0 and #Mock.Warnings==0)
    end)
    test('opening normal tools restores native chrome and returning restores feedback chrome',function()
        local h=fixture();assert(h.Window.PageHost.Position.X.Offset==12)
        h.Window:OpenUpdates('Library');assert(h.Window.PageHost.Position.X.Offset==184 and h.Window.SearchContainer.Visible)
        h:Show();assert(h.Window.PageHost.Position.X.Offset==12 and not h.Window.SearchContainer.Visible);finish(h)
    end)
    test('diagnostics-disabled launcher has two pages and no inactive diagnostics form',function()
        local h,calls=fixture({Diagnostics=false});assert(#h.Launcher.PageOrder==2 and not h.Diagnostics)
        assert(not pcall(h.SetPage,h,'Diagnostics'));h:SetPage('Review');assert(#calls==0);finish(h)
    end)
    test('changing themes icons and scale retains valid launcher colors and action ownership',function()
        local h=fixture();h:SetCategory('Feedback');h:SetPage('Review')
        for _,name in ipairs({'Hacker','Terminal','Paper','Dracula'}) do
            h.Window:SetTheme(name);h.Window:SetPixelIcons(false);h.Window:SetPixelIcons(true);h.Window:SetTextScale(1.4);h:Refresh()
            h.Controls.Submit:SetIcon('diamond');h.Controls.Submit:SetIcon('chevron-right');h.Launcher:Layout()
            for _,card in ipairs(h.Launcher.Cards) do if card.Id=='Feedback' then assert(Library:ContrastRatio(card.Title.TextColor3,card.Button.BackgroundColor3)>=4.5) end end
            assert(h.Controls.Submit._titleIcon.Frame.Parent==h.Controls.Submit.Button)
        end
        finish(h)
    end)
    test('cancelling a pending send remains available outside the review page',function()
        Mock.YieldingTasks=true
        local h,calls=fixture({Request=function() task.wait(3);return {StatusCode=200,Body='{"id":"345678901234567890"}'} end})
        h:SetMessage('A pending report for cancellation.');h:SetPage('Review');h:Submit();tick()
        h:SetPage('Compose');assert(h.Controls.Cancel.Frame.Visible and h.Launcher.Sections.Actions.Frame.Visible)
        h.Controls.Cancel:Press();tick();assert(h:GetDraft().Message=='A pending report for cancellation.');finish(h)
    end)
    test('closing and reexecuting a launcher releases cards navigation and icons',function()
        local h,calls=fixture();local id=h.Window.Id;h:SetMessage('Mensagem não enviada');h:SetPage('Review')
        local b=Library:CreateFeedbackHub({Id='reopened',WindowId=id,Settings=false,LoadingScreen=false,FileStorage=false})
        tick();assert(h.Destroyed and b.Launcher and #calls==0)
        b:Destroy();finish(h)
    end)
    test('launcher cards and navigation fit desktop and narrow scaled mobile bounds',function()
        local oldView=Mock.Viewport;Mock.Geometry=true
        local function inside(a,b)
            return a.AbsolutePosition.X>=b.AbsolutePosition.X-.5 and a.AbsolutePosition.Y>=b.AbsolutePosition.Y-.5
                and a.AbsolutePosition.X+a.AbsoluteSize.X<=b.AbsolutePosition.X+b.AbsoluteSize.X+1
                and a.AbsolutePosition.Y+a.AbsoluteSize.Y<=b.AbsolutePosition.Y+b.AbsoluteSize.Y+1
        end
        for _,size in ipairs({Vector2.new(1280,720),Vector2.new(390,844),Vector2.new(320,600)}) do
            for _,scale in ipairs({.75,1.5}) do
                Mock.Viewport=size;Mock.Geometry=true
                local h=fixture({Scale=scale});h.Window:SetTextScale(1.4)
                for _,locale in ipairs({'pt-BR','en-US'}) do
                    h.Window:SetLocale(locale);h.Launcher:Layout();local v=h.Launcher
                    assert(inside(v.HeroTitle,v.Hero) and inside(v.HeroDescription,v.Hero),'Feedback hero overflow')
                    for _,card in ipairs(v.Cards) do assert(inside(card.Title,card.Button) and inside(card.Description,card.Button),'Feedback category caption overflow') end
                    for _,button in pairs(v.Pages) do assert(inside(button,v.Navigation),'Feedback page button overflow') end
                    for _,page in ipairs(v.PageOrder) do h:SetPage(page);assert(v.Root.AbsoluteSize.X<=h.Tab.Frame.AbsoluteSize.X+1) end
                end
                finish(h)
            end
        end
        Mock.Viewport=oldView;Mock.Geometry=false
    end)
    test('news has no unread UI or alerts after edits locales profile import and reexecution',function()
        local count=0
        local function create()
            return Library:CreateWindow({Id='passive-news',Settings=false,LoadingScreen=false,FileStorage=false,ScriptUpdates={{Id='s1',Title='Atualização',Description='Texto do script'}}})
        end
        local w=create();w.Notify=function() count=count+1 end
        w:OpenUpdates('Library');assert(w.NewsTab.Title=='Novidades' and not w._news.Controls.Read)
        w:MarkUpdateRead('Library',w:GetLibraryUpdates()[1].Id)
        w:OpenUpdates('Script');w:SetScriptUpdates({{Id='s1',Title='Atualização revisada',Description='Outro texto'}})
        for _,value in ipairs(w._news.Controls.List.Options) do assert(not value:find('[NOVA]',1,true) and not value:find('[NEW]',1,true)) end
        local profile=Mock.Services.HttpService:JSONDecode(w:ExportConfig());profile.Appearance.Advanced.NewsRead={Library={old=('a'):rep(64)},Script={s1=('b'):rep(64)}}
        assert(w:ImportConfig(Mock.Services.HttpService:JSONEncode(profile),{Silent=true}))
        w:SetLocale('en-US');assert(w.NewsTab.Title=='Updates' and w:GetUnreadUpdateCount('Script')==0 and count==0 and not w:ExportConfig():find('NewsRead',1,true))
        w:Destroy();tick(100);w=create();w:OpenUpdates('Library');assert(w.NewsTab.Title=='Novidades' and w:GetUnreadUpdateCount('Library')==0);w:Destroy();tick(100)
        assert(Mock.Connections==0 and #Mock.Warnings==0)
    end)
end
