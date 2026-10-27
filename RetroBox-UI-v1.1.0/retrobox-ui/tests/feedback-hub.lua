return function(Mock,Library,test)
    local index=0;local savedPlayer
    local function fixture(options)
        index=index+1;Mock.Warnings={};Mock.StrictIconLifecycle=true;Mock.ParentLockErrors=0;Mock.DestroyedIconWrites=0
        savedPlayer=Mock.Services.Players.LocalPlayer
        local calls={};local config={Id='feedback-test-'..index,Settings=false,LoadingScreen=false,FileStorage=false,Locale='pt-BR',Cooldown=0,
            WebhookURL='https://discord.com/api/webhooks/'..tostring(100000000000000000+index)..'/'..('test_token_'):rep(5),
            Request=function(spec) calls[#calls+1]=spec;return {StatusCode=200,Body='{"id":"123456789012345678"}'} end,
            MetadataProvider=function(id) return {Name='Jogo '..id} end,
            AvatarProvider=function() return 'https://tr.rbxcdn.com/example/avatar.png' end}
        for name,value in pairs(options or {}) do if value=='__nil' then config[name]=nil else config[name]=value end end
        local h=Library:CreateFeedbackHub(config);Mock.pump();return h,calls
    end
    local function tick(dt) Mock.pump(dt or 0);Mock.Services.RunService.RenderStepped:Fire(.1);Mock.pump() end
    local function finish(h)
        h.Window:Destroy();Mock.pump(200);Mock.DeferDestroying=false;Mock.YieldingTasks=false;Mock.AnimatedTweens=false;Mock.Geometry=false
        Mock.StrictIconLifecycle=false;Mock.Services.Players.LocalPlayer=savedPlayer
        assert(Mock.Connections==0,'Feedback leaked connections: '..Mock.Connections)
        assert(Mock.ParentLockErrors==0 and Mock.DestroyedIconWrites==0,'Feedback wrote a destroyed icon')
        assert(#Mock.Warnings==0,table.concat(Mock.Warnings,'\n'))
    end
    test('feedback is opt-in and construction sends no webhook request',function()
        local h,calls=fixture();assert(#calls==0 and h.Tab and h.Window.Theme=='Hacker')
        assert(h.Controls.Message.Input.MultiLine and h.Controls.Submit.Disabled)
        assert(h:GetDraft().Game=='current' and h:GetDraft().Category=='ScriptRequest');finish(h)
    end)
    test('explicit submit sends only reviewed public data with confirmed Discord delivery',function()
        local h,calls=fixture();h:SetMessage('Quero um script com uma interface organizada.')
        local preview=assert(h:GetPreview());local action=assert(h:Submit());assert(h:Submit()==nil);tick()
        assert(action:GetStatus().Status=='Completed' and h:GetStatus().State=='Sent' and #calls==1)
        local spec=calls[1];assert(spec.Method=='POST' and spec.Url:find('/api/v10/webhooks/',1,true) and spec.Url:find('?wait=true',1,true))
        local payload=Mock.Services.HttpService:JSONDecode(spec.Body);local embed=payload.embeds[1]
        assert(#payload.embeds==1 and #payload.allowed_mentions.parse==0 and embed.description==preview.Message)
        assert(embed.url=='https://www.roblox.com/games/'..game.PlaceId and embed.thumbnail.url=='https://tr.rbxcdn.com/example/avatar.png')
        assert(#embed.fields==5 and embed.author.name:find('@TestUser',1,true))
        assert(not spec.Body:find('JobId',1,true) and not spec.Body:find('executor',1,true) and not spec.Body:find('test_token',1,true))
        assert(h:GetDraft().Message==preview.Message);finish(h)
    end)
    test('all categories use stable IDs while the whole interface changes locale',function()
        local h=fixture();h:SetDraft({Category='Suggestion',Message='Sugestão com português e emoji 💎.'})
        h.Window:SetLocale('en-US');assert(h.Controls.Category:GetValue()=='Suggest an improvement')
        assert(h.Controls.Message.TitleLabel.Text=='Your message' and h.Controls.Submit.Button.Text=='Send to Discord')
        assert(h:GetDraft().Category=='Suggestion' and h:GetDraft().Message=='Sugestão com português e emoji 💎.')
        assert(h:BuildPayload().embeds[1].title=='Suggest an improvement')
        h.Window:SetLocale('pt-BR');assert(h.Controls.Category:GetValue()=='Sugerir melhoria' and h:GetDraft().Category=='Suggestion');finish(h)
    end)
    test('draft validation rejects blank short invalid UTF8 and excessive characters without posting',function()
        local h,calls=fixture({MaxLength=20,MinLength=5})
        for _,spec in ipairs({{'','Empty'},{'    ','Empty'},{'oi','Short'},{('a'):rep(21),'Long'}}) do
            h:SetMessage(spec[1]);local _,reason=h:GetPreview();assert(reason==spec[2]);assert(h:Submit()==nil)
        end
        assert(not pcall(h.SetMessage,h,string.char(255)))
        h:SetMessage(('💎'):rep(20));assert(h:Validate() and h:GetPreview().Message==('💎'):rep(20) and #calls==0);finish(h)
    end)
    test('target game accepts numeric IDs and only canonical official game links',function()
        local h=fixture();h:SetMessage('Pedido para outro jogo.')
        h:SetGame('https://www.roblox.com/games/987654321/Teste');tick();assert(h:GetPreview().Game.PlaceId==987654321)
        assert(h.Controls.Target.Frame.Visible and not h.Controls.CurrentGame:GetValue())
        local prior=h:GetDraft();for _,bad in ipairs({'https://roblox.com.evil.test/games/123','http://roblox.com/games/123','https://www.roblox.com/users/123','0','-1','abc'}) do
            assert(not pcall(h.SetGame,h,bad) and h:GetDraft().Game==prior.Game)
        end
        h:SetGame('current');assert(h:GetPreview().Game.PlaceId==game.PlaceId);finish(h)
    end)
    test('failure to resolve game metadata or avatar never prevents a valid report',function()
        local h,calls=fixture({MetadataProvider=function() error('offline') end,AvatarProvider=function() return 'rbxthumb://avatar' end})
        h:SetMessage('O jogo precisa de novos scripts.');assert(h:GetPreview().Game.Name=='Game '..game.PlaceId)
        assert(not h:BuildPayload().embeds[1].thumbnail and h:Submit());tick();assert(#calls==1 and h:GetStatus().State=='Sent');finish(h)
    end)
    test('missing transport and unconfigured hub show useful status without using HTTP',function()
        local h,calls=fixture({Request='__nil',WebhookURL='__nil'});h:SetMessage('Mensagem de exemplo.')
        local ok,reason=h:Validate();assert(not ok and reason=='NotConfigured' and h:Submit()==nil and #calls==0);finish(h)
        h,calls=fixture({Request='__nil'});h:SetMessage('Mensagem de exemplo.');ok,reason=h:Validate()
        assert(not ok and reason=='Unavailable' and #calls==0);finish(h)
    end)
    test('webhook configuration rejects lookalike hosts unsupported paths query tokens and invalid categories',function()
        for _,bad in ipairs({'http://discord.com/api/webhooks/123456/abc','https://discord.com.evil.test/api/webhooks/123456/abc','https://discord.com/api/webhooks/123456/abc?wait=true','https://example.com/token'}) do
            assert(not pcall(Library.CreateFeedbackHub,Library,{WebhookURL=bad}) and next(Library.Windows)==nil)
        end
        assert(not pcall(Library.CreateFeedbackHub,Library,{Categories={'Unknown'}}))
        assert(not pcall(Library.CreateFeedbackHub,Library,{Transport=function() end,WebhookURL='test'}))
        assert(Mock.Connections==0)
    end)
    test('cooldown and duplicate protection work across attached hubs sharing one webhook',function()
        local h,calls=fixture({Cooldown=3});h:SetMessage('Uma ideia original.');assert(h:Submit());tick()
        h:SetMessage('Outra ideia diferente.');local ok,reason=h:Validate();assert(not ok and reason=='Cooldown')
        tick(4);assert(h:Validate());h:SetMessage('Uma ideia original.');ok,reason=h:Validate();assert(not ok and reason=='Duplicate')
        local b=h.Window:CreateFeedbackHub({Id='attached',WebhookURL=h.Options.URL:match('^(.-)%?'),Request=function() error('must not post') end,MetadataProvider=function() return {Name='Game'} end})
        b:SetMessage('Uma ideia original.');assert(select(2,b:Validate())=='Duplicate' and #calls==1);finish(h)
    end)
    test('HTTP rate limiting uses server seconds and does not automatically resend',function()
        local h,calls=fixture({Request=function(spec) return {StatusCode=429,Body='{"retry_after":4.5}',Headers={}} end})
        h:SetMessage('Ideia com limite de taxa.');assert(h:Submit());tick()
        assert(h:GetStatus().State=='RateLimited' and h:GetStatus().RetryAfter==5)
        tick(5);assert(h:Validate());finish(h)
    end)
    test('failed and ambiguous responses keep draft and require explicit uncertain retry',function()
        local h,calls=fixture({Request=function() error('request failed SECRET_TOKEN') end});h:SetMessage('Esta mensagem precisa ficar salva na tela.')
        assert(h:Submit());tick();assert(h:GetStatus().State=='Unconfirmed' and h:GetDraft().Message~='')
        assert(h:Submit()==nil and not h:GetStatus().Message:find('SECRET_TOKEN',1,true))
        h.Options.Request=function() return {StatusCode=200,Body='{"id":"123456789"}'} end
        assert(h:Submit({RetryUnconfirmed=true}));tick();assert(h:GetStatus().State=='Sent');finish(h)
    end)
    test('custom transport can send a payload without embedding any webhook in client options',function()
        local received
        local h=fixture({WebhookURL='__nil',Request='__nil',Transport=function(payload) received=payload;return {StatusCode=200,Body='{"id":"123456789"}'} end})
        h:SetMessage('Ideia por transporte customizado.');assert(h:Submit());tick()
        assert(received.embeds[1].description==h:GetDraft().Message and h:GetStatus().State=='Sent');finish(h)
    end)
    test('delayed delivery timeout detaches its mailbox and late success cannot overwrite a new report',function()
        Mock.YieldingTasks=true;local count=0
        local h=fixture({Timeout=1,Request=function() count=count+1;if count==1 then task.wait(5) end;return {StatusCode=200,Body='{"id":"987654321"}'} end})
        h:SetMessage('Primeira mensagem, com resposta lenta.');local action=assert(h:Submit());tick()
        tick(1.1);assert(h:GetStatus().State=='Unconfirmed' and action.Finished and not h._operation)
        h:SetMessage('Segunda mensagem, com resposta rápida.');assert(h:Submit());tick();assert(h:GetStatus().State=='Sent' and count==2)
        local status=h:GetStatus();tick(5);assert(h:GetStatus().MessageId==status.MessageId and h:GetDraft().Message:find('Segunda',1,true))
        finish(h)
    end)
    test('cancellation before dispatch sends nothing and releases the local submission lock',function()
        local h,calls=fixture();h:SetMessage('Cancelamento antes de enviar.')
        assert(h:Submit());assert(h:CancelSubmission());tick()
        assert(#calls==0 and h:GetStatus().State=='Cancelled' and h:Validate());finish(h)
    end)
    test('cancellation while HTTP is in flight preserves draft and marks delivery uncertain',function()
        Mock.YieldingTasks=true;local h=fixture({Request=function() task.wait(4);return {StatusCode=200,Body='{"id":"987654321"}'} end})
        h:SetMessage('Não descartar esta mensagem.');local action=assert(h:Submit());tick();assert(h:CancelSubmission());tick()
        assert(action.Finished and h:GetStatus().State=='Unconfirmed' and h:GetDraft().Message~='')
        tick(5);assert(h:GetStatus().State=='Unconfirmed');finish(h)
    end)
    test('editing during a request never changes the submitted snapshot or clears a new draft',function()
        Mock.YieldingTasks=true;local body
        local h=fixture({ClearOnSuccess=true,Request=function(spec) body=spec.Body;task.wait(1);return {StatusCode=200,Body='{"id":"987654321"}'} end})
        h:SetMessage('Mensagem original revisada.');assert(h:Submit());tick()
        h:SetDraft({Message='Uma nova mensagem ainda não enviada.',Category='Feedback'});tick(2)
        assert(h:GetDraft().Message=='Uma nova mensagem ainda não enviada.' and h:GetDraft().Category=='Feedback')
        assert(Mock.Services.HttpService:JSONDecode(body).embeds[1].description=='Mensagem original revisada.');finish(h)
    end)
    test('successful explicit clear removes only the unchanged sent draft',function()
        local h=fixture({ClearOnSuccess=true});h:SetMessage('Mensagem que pode limpar ao enviar.');assert(h:Submit());tick()
        assert(h:GetDraft().Message=='' and h:GetStatus().State=='Sent');finish(h)
    end)
    test('exported configuration excludes webhook tokens drafts identity and transport functions',function()
        local h=fixture();h:SetMessage('TEXTO_PRIVADO_TESTE');local config=h.Window:ExportConfig()
        for _,value in ipairs({'test_token_','TEXTO_PRIVADO_TESTE','TestUser','AvatarProvider','Request','WebhookURL'}) do assert(not config:find(value,1,true),value..' leaked into config') end
        assert(h.Window:ImportConfig(config,{Silent=true}));assert(h:GetDraft().Message=='TEXTO_PRIVADO_TESTE');finish(h)
    end)
    test('non-success HTTP responses and unconfirmed 204 never report sent',function()
        for _,response in ipairs({{StatusCode=204,Body=''}, {StatusCode=200,Body='{}'}, {StatusCode=200,Body='not JSON'}, {Success=true,StatusCode=403,Body='SECRET'}, {StatusCode=500,Body='SECRET'}, {Success=true}}) do
            local h=fixture({Request=function() return response end});h:SetMessage('Mensagem mantida até confirmação.');assert(h:Submit());tick()
            assert(h:GetStatus().State~='Sent' and h:GetDraft().Message~='' and not h:GetStatus().Message:find('SECRET',1,true));finish(h)
        end
    end)
    test('Retry-After headers override fallback delay and never trigger a background resend',function()
        local n=0;local h=fixture({Request=function() n=n+1;return {StatusCode=429,Body='{}',Headers={['rEtRy-AfTeR']='2.5'}} end})
        h:SetMessage('Respeitar a pausa do Discord.');assert(h:Submit());tick();assert(h:GetStatus().RetryAfter==3)
        tick(4);assert(n==1 and h:Validate());finish(h)
    end)
    test('mentions unicode and literal translation-like names stay unchanged in payload and preview',function()
        local h,calls=fixture({MetadataProvider=function() return {Name='Configurações'} end})
        h:SetMessage('@everyone <@123456789> **Ideia** com ç e 💎.');h.Window:SetLocale('en-US')
        assert(h.Controls.GamePreview:GetValue()=='Configurações' and h:Submit());tick()
        local data=Mock.Services.HttpService:JSONDecode(calls[1].Body)
        assert(data.embeds[1].description=='@everyone <@123456789> **Ideia** com ç e 💎.' and #data.allowed_mentions.parse==0)
        assert(data.embeds[1].fields[1].value=='Configurações');finish(h)
    end)
    test('game metadata revisions discard an earlier slow lookup',function()
        Mock.YieldingTasks=true
        local h=fixture({MetadataProvider=function(id) if id==game.PlaceId then task.wait(3) end;return {Name='Resolved '..id} end})
        h:SetGame(7654321);tick();assert(h.Controls.GamePreview:GetValue()=='Resolved 7654321')
        tick(4);assert(h.Controls.GamePreview:GetValue()=='Resolved 7654321');finish(h)
    end)
    test('late LocalPlayer data enables sending without borrowing identity from PlayerAdded',function()
        local player=Mock.Services.Players.LocalPlayer;Mock.Services.Players.LocalPlayer=nil
        local h=fixture({Parent=player:FindFirstChild('PlayerGui')});h:SetMessage('Esperando a identidade real.');assert(select(2,h:Validate())=='Identity')
        local stranger=Instance.new('Player');stranger.Name='Other';stranger.DisplayName='Other';stranger.UserId=900
        Mock.Services.Players.PlayerAdded:Fire(stranger);assert(select(2,h:Validate())=='Identity')
        Mock.Services.Players.LocalPlayer=player;tick();assert(h:Validate() and h.Controls.Identity:GetValue():find('@TestUser',1,true))
        savedPlayer=player;stranger:Destroy();finish(h)
    end)
    test('locale auto follows the session language and translates default window title',function()
        local player=Mock.Services.Players.LocalPlayer;local previous=player.LocaleId;player.LocaleId='en-us'
        local h=fixture({Locale='auto'});assert(h.Window:GetLocale()=='en-US' and h.Window.Title=='Ideas Center')
        h.Window:SetLocale('pt-BR');assert(h.Window.Title=='Central de Ideias' and h.Controls.Category.TitleLabel.Text=='O que você quer compartilhar?')
        player.LocaleId=previous;finish(h)
    end)
    test('attached feedback hub leaves existing controls and script hubs intact',function()
        local h=fixture();local w=h.Window;h.OwnsWindow=false
        local tab=w:CreateTab('Keep');local c=tab:CreateSection('Keep'):AddToggle({Id='keep-existing',Default=true})
        local scripts=w:CreateScriptHub({Id='keep-hub',LoadingScreen=false,Games={}});h:Show();h:Destroy();tick()
        assert(not w.Destroyed and c:GetValue() and not scripts.Destroyed and not w._feedbackHubs[h.Id]);finish(h)
    end)
    test('repeated feedback lifetimes and external frame destruction release owned resources',function()
        local h=fixture();h.OwnsWindow=false;local w=h.Window;h:Destroy();tick()
        local baseline=w:GetRuntimeStats().Resources;local connections=Mock.Connections
        for i=1,3 do
            local next=w:CreateFeedbackHub({Id='repeat-feedback',MetadataProvider=function() return {Name='Game'} end})
            Mock.pump();next:Destroy();tick();assert(w:GetRuntimeStats().Resources==baseline and Mock.Connections==connections)
        end
        local last=w:CreateFeedbackHub({Id='external-feedback'});Mock.pump();Mock.DeferDestroying=true;last.Tab.Frame:Destroy();tick()
        assert(last.Destroyed);finish(h)
    end)
    test('closing or reexecuting during network work detaches late responses from destroyed UI',function()
        Mock.YieldingTasks=true;local called=0
        local h=fixture({WindowId='reexecuted-feedback',OnSent=function() called=called+1 end,Request=function() task.wait(5);return {StatusCode=200,Body='{"id":"987654321"}'} end})
        h:SetMessage('Fechar durante uma requisição.');assert(h:Submit());tick()
        local next=Library:CreateFeedbackHub({Id='replacement',WindowId='reexecuted-feedback',Settings=false,LoadingScreen=false,FileStorage=false})
        tick(6);assert(h.Destroyed and called==0 and next:GetDraft().Message=='')
        next:Destroy();finish(h)
    end)
    test('numeric options and category arrays validate before any window is created',function()
        for _,opts in ipairs({{Timeout=false},{MaxLength=false},{MinLength=0},{Cooldown=-1},{Categories={Feedback=true}},{Categories={'Feedback',Other=true}},{DefaultCategory='missing'},{ThreadId='bad'}}) do
            assert(not pcall(Library.CreateFeedbackHub,Library,opts) and next(Library.Windows)==nil)
        end
        assert(Mock.Connections==0)
    end)
    test('ordinary windows do not acquire a feedback tab or form automatically',function()
        local h=fixture();h:Destroy();tick()
        local w=Library:CreateWindow({Id='ordinary-no-feedback',Settings=false,LoadingScreen=false,FileStorage=false})
        assert(#w.Tabs==1 and w.Tabs[1]==w.NewsTab and not w._feedbackHubs and next(w.Controls)==nil);w:Destroy();finish(h)
    end)
    test('executor request fallback is discovered only when submitting',function()
        local prior=request;local calls=0
        request=function(spec) calls=calls+1;assert(spec.Method=='POST');return {StatusCode=200,Body='{"id":"123456789"}'} end
        local h=fixture({Request='__nil'});assert(calls==0);h:SetMessage('Enviar com o transporte do executor.');assert(h:Submit());tick()
        assert(calls==1 and h:GetStatus().State=='Sent');request=prior;finish(h)
    end)
    test('avatar opt-out avoids lookup and does not add image fields to a payload',function()
        local calls=0;local h=fixture({IncludeAvatar=false,AvatarProvider=function() calls=calls+1 end})
        h:SetMessage('Enviar sem imagem de avatar.');assert(calls==0 and not h:BuildPayload().embeds[1].thumbnail);finish(h)
    end)
    test('read-only executor globals keep the library and local cooldown functional',function()
        local previous=getgenv;getgenv=function() return setmetatable({},{__newindex=function() error('read only') end}) end
        local instance=dofile('RetroBox.lua')
        local h=instance:CreateFeedbackHub({Id='readonly-env-feedback',Settings=false,FileStorage=false,LoadingScreen=false,Transport=function() return {StatusCode=200,Body='{"id":"123456789"}'} end})
        h:SetMessage('Um ambiente com globais protegidas.');assert(h:Submit());tick();assert(h:GetStatus().State=='Sent')
        getgenv=previous;h:Destroy();Mock.pump(200);assert(Mock.Connections==0)
    end)
    test('feedback labels keep readable bounds across desktop mobile text scale and locale',function()
        for _,view in ipairs({Vector2.new(1280,720),Vector2.new(390,844)}) do
            for _,scale in ipairs({.75,1.5}) do for _,locale in ipairs({'pt-BR','en-US'}) do
                Mock.Geometry=true;Mock.Viewport=view
                local h=fixture({Scale=scale,Locale=locale,ReducedMotion=true,Theme=locale=='pt-BR' and 'Hacker' or 'Paper'})
                h.Window:SetTextScale(1.4);h:SetMessage(('Uma mensagem com muitos detalhes. '):rep(15));tick()
                for _,name in ipairs({'Notice','Status','MessagePreview','GamePreview','Identity'}) do
                    local c=h.Controls[name];local label=c.TitleLabel
                    local width=label.AbsoluteSize.X/math.max(.01,h.Window._actualScale)
                    local bounds=Mock.Services.TextService:GetTextSize(label.Text,label.TextSize,label.Font,Vector2.new(math.max(1,width),100000))
                    assert(label.Size.Y.Offset>=bounds.Y,'Clipped feedback label '..name)
                    assert(Library:ContrastRatio(label.TextColor3,h.Window:_surfaceColor(label))>=4.499)
                end
                finish(h)
            end end
        end
        Mock.Viewport=Vector2.new(1280,720)
    end)
    test('destroying an attached hub also closes its uncertain retry confirmation without sending',function()
        local n=0;local h=fixture({Request=function() n=n+1;error('offline') end});h.OwnsWindow=false
        h:SetMessage('Uma mensagem de confirmação incerta.');assert(h:Submit());tick()
        assert(h.Controls.PlaceId:GetValue():find(tostring(game.PlaceId),1,true))
        assert(h.Controls.Retry:Press());tick();assert(h.Window._dialog)
        h:Destroy();tick();assert(not h.Window.Destroyed and not h.Window._dialog and n==1);finish(h)
    end)
end
