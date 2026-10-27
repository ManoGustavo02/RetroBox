return function(Mock,Library,test)
    local index=0
    local function tick(dt) Mock.pump(dt or 0);Mock.Services.RunService.RenderStepped:Fire(.1);Mock.pump() end
    local function fixture(options)
        index=index+1;Mock.Warnings={};Mock.StrictIconLifecycle=true;Mock.ParentLockErrors=0;Mock.DestroyedIconWrites=0
        local old=Mock.Services.LogService
        local service={History={},Reads=0,MessageOut=Mock.signal()}
        function service:GetLogHistory() self.Reads=self.Reads+1;return self.History end
        Mock.Services.LogService=service
        local calls={};local config={Id='diagnostic-'..index,Settings=false,LoadingScreen=false,FileStorage=false,Locale='pt-BR',Cooldown=0,
            WebhookURL='https://discord.com/api/webhooks/'..tostring(300000000000000000+index)..'/'..('fake_diagnostic_token_'):rep(3),
            MetadataProvider=function() return {Name='Jogo de Teste'} end,AvatarProvider=function() return nil end,
            Request=function(spec) calls[#calls+1]=spec;return {StatusCode=200,Body='{"id":"345678901234567890"}'} end}
        for k,v in pairs(options or {}) do config[k]=v end
        local h=Library:CreateFeedbackHub(config);tick();h:SetMessage('O botão não funciona como esperado.')
        local function finish()
            h.Window:Destroy();tick(120);Mock.Services.LogService=old;Mock.StrictIconLifecycle=false;Mock.YieldingTasks=false;Mock.DeferDestroying=false
            assert(Mock.Connections==0,'Leaked diagnostic/news connections: '..Mock.Connections)
            assert(Mock.ParentLockErrors==0 and Mock.DestroyedIconWrites==0)
            assert(#Mock.Warnings==0,table.concat(Mock.Warnings,'\n'))
        end
        return h,calls,service,finish
    end
    local function attach(h,text)
        h:SetDraft({Category='BugReport',Diagnostics={Include=true,Text=text,Code='E_BUTTON'}})
    end
    test('diagnostics default to no attachment and no console or webhook access',function()
        local h,calls,logs,finish=fixture()
        assert(h.Diagnostics and not h:GetDraft().Diagnostics.Include and logs.Reads==0 and #calls==0)
        assert(not h:GetPreview().Diagnostics and #h:BuildPayload().embeds[1].fields==5);finish()
    end)
    test('manual diagnostic attaches a bug tag version trace and exact preview only on submit',function()
        local h,calls,logs,finish=fixture({ScriptVersion='4.1.0'});attach(h,'Exception: button\nStack Begin\nScript Test, line 42\nStack End')
        local p=assert(h:GetPreview());assert(p.Diagnostics.Code=='E_BUTTON' and p.Diagnostics.ScriptVersion=='4.1.0' and p.Diagnostics.LibraryVersion==Library.Version)
        local payload=h:BuildPayload();assert(payload.embeds[1].title:find('[BUG]',1,true) and #calls==0 and logs.Reads==0)
        h:Submit();tick();assert(#calls==1 and calls[1].Body:find('Stack Begin',1,true) and h:GetStatus().State=='Sent');finish()
    end)
    test('typed diagnostic stays excluded while the attachment toggle is off',function()
        local h,calls,_,finish=fixture();h:SetDiagnosticText('Private diagnostic not selected for sending')
        assert(not h:GetPreview().Diagnostics);h:Submit();tick()
        assert(not calls[1].Body:find('Private diagnostic',1,true));finish()
    end)
    test('explicit history import filters errors warnings and leaves all entries unselected',function()
        local h,calls,logs,finish=fixture()
        logs.History={{message='An error occurred',messageType='MessageError'},{message='A warning occurred',messageType='MessageWarning'},{message='Informational output',messageType='MessageOutput'}}
        assert(h:CollectDiagnostics());tick();local records=h:GetDiagnosticRecords()
        assert(logs.Reads==1 and #records==2 and #h:GetDraft().Diagnostics.Selected==0 and #calls==0)
        h:SetDraft({Diagnostics={Include=true,Selected={records[1].Id,records[2].Id}}})
        local p=h:GetPreview();assert(#p.Diagnostics.Records==2 and p.Diagnostics.Records[2].Level=='Warning');finish()
    end)
    test('repeated history import deduplicates and record getters return copies',function()
        local h,_,logs,finish=fixture();logs.History={{message='Repeated error',messageType='MessageError'}}
        h:CollectDiagnostics();h:CollectDiagnostics();tick()
        local r=h:GetDiagnosticRecords();assert(#r==1 and not r[1].Key);r[1].Message='altered'
        assert(h:GetDiagnosticRecords()[1].Message=='Repeated error');finish()
    end)
    test('denied console access keeps manual diagnostics and local window reports functional',function()
        local h,_,logs,finish=fixture()
        logs.GetLogHistory=function() error('permission denied') end
        h.Window._diagnostics={{Message='Local callback failed',Traceback='Local stack'}}
        assert(not h:CollectDiagnostics());tick();assert(#h:GetDiagnosticRecords()==1)
        attach(h,'Manual fallback trace');assert(h:Validate());assert(h.Diagnostics.Controls.CollectionStatus.TitleLabel.Text:find('indisponível',1,true));finish()
    end)
    test('live capture is explicit filtered visible only and stops when disabled',function()
        local h,_,logs,finish=fixture();h:SetDraft({Diagnostics={Include=true}})
        logs.MessageOut:Fire('Before opt in','MessageError');assert(#h:GetDiagnosticRecords()==0)
        assert(h:SetDiagnosticCapture(true));logs.MessageOut:Fire('Captured error','MessageError');logs.MessageOut:Fire('Not an error','MessageOutput');tick()
        assert(#h:GetDiagnosticRecords()==1)
        h:Hide();logs.MessageOut:Fire('Hidden error','MessageError');tick();assert(#h:GetDiagnosticRecords()==1)
        h:Show();h:SetDiagnosticCapture(false);logs.MessageOut:Fire('After stop','MessageError');tick();assert(#h:GetDiagnosticRecords()==1);finish()
    end)
    test('disabling attachment stops active capture without deleting the draft',function()
        local h,_,logs,finish=fixture();attach(h,'Keep this pasted error');h:SetDiagnosticCapture(true)
        h:SetDraft({Diagnostics={Include=false}});assert(not h.Diagnostics.Capturing)
        logs.MessageOut:Fire('After disable','MessageError');tick()
        assert(#h:GetDiagnosticRecords()==0 and h:GetDraft().Diagnostics.Text=='Keep this pasted error');finish()
    end)
    test('deferred console signal and pending refresh cannot touch a destroyed hub',function()
        local h,_,logs,finish=fixture();h:SetDraft({Diagnostics={Include=true}});h:SetDiagnosticCapture(true)
        logs.MessageOut:Fire('Queued error','MessageError');logs.MessageOut:FireDeferred('Late error','MessageError')
        finish()
    end)
    test('recognized webhook bearer cookie and token secrets are removed from preview and payload',function()
        local h,_,_,finish=fixture()
        local token=h.Options.URL:match('/webhooks/[^/]+/([^?]+)')
        attach(h,'Request failed '..h.Options.URL..'\nAuthorization: Bearer abc.DEF-123\napi_key="sensitive key value"\n.ROBLOSECURITY=private_cookie\nToken='..token)
        local p=h:GetPreview();local text=h.Diagnostics:Format(p.Diagnostics)
        for _,secret in ipairs({token,'abc.DEF-123','sensitive key value','private_cookie'}) do assert(not text:find(secret,1,true)) end
        assert(p.Diagnostics.Redacted);local body=Mock.Services.HttpService:JSONEncode(h:BuildPayload())
        assert(not body:find(token,1,true));finish()
    end)
    test('diagnostic selection survives locale changes and source text stays literal',function()
        local h,_,logs,finish=fixture();logs.History={{message='Erro no botão 💎',messageType='MessageError'}}
        h:CollectDiagnostics();tick();local id=h:GetDiagnosticRecords()[1].Id
        h:SetDraft({Diagnostics={Include=true,Selected={id}}});h.Window:SetLocale('en-US')
        assert(h:GetDraft().Diagnostics.Selected[1]==id and h:GetPreview().Diagnostics.Records[1].Message=='Erro no botão 💎')
        assert(h.Controls.DiagnosticInclude.Title=='Attach diagnostics to submission');finish()
    end)
    test('invalid diagnostic draft is rejected before any other draft field changes',function()
        local h,_,_,finish=fixture();local old=h:GetDraft().Message
        for _,d in ipairs({{Text=string.char(255)},{Code=('a'):rep(65)},{Steps=('a'):rep(401)},{Selected={'not-a-record'}},{Include='yes'},{Unknown=true}}) do
            assert(not pcall(h.SetDraft,h,{Message='Replacement message',Diagnostics=d}) and h:GetDraft().Message==old)
        end
        finish()
    end)
    test('an enabled empty diagnostic prevents submission until filled or disabled',function()
        local h,calls,_,finish=fixture();h:SetDraft({Diagnostics={Include=true}})
        assert(select(2,h:GetPreview())=='DiagnosticEmpty' and not h:Submit() and #calls==0)
        h:SetDraft({Diagnostics={Include=false}});assert(h:Validate());finish()
    end)
    test('Discord aggregate limit is checked before transport and emoji chunks stay valid',function()
        local h,calls,_,finish=fixture();h:SetMessage(('💎'):rep(2000));attach(h,('💎'):rep(1500))
        assert(select(2,h:Validate())=='DiagnosticPayloadLarge' and not h:Submit() and #calls==0)
        h:SetMessage('Teste com emoji no diagnóstico.');h:SetDiagnosticText(('💎'):rep(800),true)
        local payload=assert(h:BuildPayload());local count=0
        local function units(s) local n=0;for _,v in utf8.codes(s) do n=n+(v>65535 and 2 or 1) end;return n end
        local e=payload.embeds[1];count=units(e.title)+units(e.description)+units(e.author.name)
        for _,field in ipairs(e.fields) do assert(utf8.len(field.value) and units(field.value)<=1024);count=count+units(field.name)+units(field.value) end
        assert(count<=6000);finish()
    end)
    test('diagnostic attachment participates in duplicate detection independently of locale',function()
        local h,calls,_,finish=fixture();attach(h,'First trace');h:Submit();tick()
        h.Window:SetLocale('en-US');assert(select(2,h:Validate())=='Duplicate')
        h:SetDiagnosticText('Second trace',true);assert(h:Validate());h:Submit();tick();assert(#calls==2);finish()
    end)
    test('failed delivery preserves manual diagnostic and selection',function()
        local h,calls,_,finish=fixture({Request=function() return {StatusCode=403,Body='{}'} end})
        attach(h,'Keep this diagnostic after rejection');h:Submit();tick()
        assert(h:GetStatus().State=='Rejected' and h:GetDraft().Diagnostics.Text=='Keep this diagnostic after rejection');finish()
    end)
    test('clear diagnostics leaves the feedback message and disables the attachment',function()
        local h,_,_,finish=fixture();attach(h,'Clear just this trace');local message=h:GetDraft().Message
        h:ClearDiagnostics();assert(h:GetDraft().Message==message and h:GetDraft().Diagnostics.Text=='' and not h:GetDraft().Diagnostics.Include);finish()
    end)
    test('diagnostic drafts records and credentials never enter saved profiles',function()
        local h,_,_,finish=fixture();attach(h,'Unique error text not for profiles')
        local encoded=h.Window:ExportConfig()
        assert(not encoded:find('Unique error text',1,true) and not encoded:find('fake_diagnostic_token_',1,true) and not encoded:find('E_BUTTON',1,true))
        assert(h.Window:ImportConfig(encoded,{Silent=true}) and h:GetDraft().Diagnostics.Text=='Unique error text not for profiles');finish()
    end)
    test('diagnostics can be disabled through the public factory option',function()
        local h,_,_,finish=fixture({Diagnostics=false});assert(not h.Diagnostics and not h.Controls.DiagnosticInclude)
        assert(not pcall(h.SetDiagnosticText,h,'Unavailable') and h:Validate());finish()
    end)
    test('selected records stay available while unselected captured history is evicted',function()
        local h,_,logs,finish=fixture();h:SetDraft({Diagnostics={Include=true}});h:SetDiagnosticCapture(true)
        logs.MessageOut:Fire('Pinned initial error','MessageError');tick();local id=h:GetDiagnosticRecords()[1].Id
        h:SetDraft({Diagnostics={Selected={id}}})
        for i=1,120 do logs.MessageOut:Fire('New error '..i,'MessageError') end;tick()
        assert(#h:GetDiagnosticRecords()==80 and h:GetPreview().Diagnostics.Records[1].Id==id);finish()
    end)
    test('copy preview only copies the reviewed sanitized diagnostic',function()
        local h,_,_,finish=fixture();attach(h,'password="private value"\nA useful error')
        local old=setclipboard;local copied;setclipboard=function(value) copied=value end
        h.Diagnostics:CopyPreview();setclipboard=old
        assert(copied and copied:find('A useful error',1,true) and not copied:find('private value',1,true));finish()
    end)
    test('new diagnostic edits during a pending request are not cleared by old success',function()
        Mock.YieldingTasks=true
        local h,_,_,finish=fixture({ClearOnSuccess=true,Request=function() task.wait(2);return {StatusCode=200,Body='{"id":"345678901234567890"}'} end})
        attach(h,'Original trace');h:Submit();tick()
        h:SetDiagnosticText('Edited trace while waiting',true);tick(3)
        assert(h:GetStatus().State=='Sent' and h:GetDraft().Diagnostics.Text=='Edited trace while waiting' and h:GetStatus().Message:find('rascunho',1,true));finish()
    end)

    test('editing diagnostic fields keeps existing console option rows stable',function()
        local h,_,logs,finish=fixture();logs.History={{message='Stable option row',messageType='MessageError'}}
        h:CollectDiagnostics();tick();local d=h.Diagnostics;local label=d.Controls.Records.Options[1];local row=d.Controls.Records._rows[label]
        attach(h,'First pasted trace');h:SetDiagnosticText('Second pasted trace',true);h:SetMessage('Changed feedback message.')
        assert(row and d.Controls.Records._rows[label]==row);finish()
    end)

    local newsIndex=0
    local function news(options)
        newsIndex=newsIndex+1;Mock.Warnings={}
        local config={Id='news-'..newsIndex,Settings=false,LoadingScreen=false,FileStorage=false,Locale='pt-BR'}
        for k,v in pairs(options or {}) do config[k]=v end
        return Library:CreateWindow(config)
    end
    local function close(w) w:Destroy();tick(120);assert(Mock.Connections==0 and #Mock.Warnings==0) end
    local item={Id='script-1',Version='1.0.0',Date='2026-10-27',Title={['pt-BR']='Meu update',['en-US']='My update'},Description={['pt-BR']='Novo recurso do script.',['en-US']='New script feature.'}}
    test('all windows receive a news category without selecting it over consumer tabs',function()
        local w=news();assert(w.NewsTab and w.NewsTab._internal and not w.ActiveTab)
        local tab=w:CreateTab('Principal');assert(w.ActiveTab==tab)
        w:OpenUpdates('Library');assert(w.ActiveTab==w.NewsTab and w._news.Title.Text~='');close(w)
    end)
    test('official feed includes current and historical releases and is returned by copy',function()
        local w=news();local notes=w:GetLibraryUpdates();assert(#notes>=13 and notes[1].Version==Library.Version)
        notes[1].Title['pt-BR']='Forged';table.remove(notes)
        assert(w:GetLibraryUpdates()[1].Title['pt-BR']~='Forged' and #Library:GetReleaseNotes()>=13);close(w)
    end)
    test('consumer update content never replaces or merges into the library namespace',function()
        local w=news({ScriptUpdates={item}});assert(#w:GetScriptUpdates()==1 and w:GetLibraryUpdates()[1].Id~=item.Id)
        local n=w:GetUnreadUpdateCount('Library');w:MarkUpdateRead('Script',item.Id)
        assert(w:GetUnreadUpdateCount('Script')==0 and w:GetUnreadUpdateCount('Library')==n)
        assert(not pcall(Library.CreateWindow,Library,{LibraryUpdates={item}}));close(w)
    end)
    test('script feed is optional and its empty state is useful',function()
        local w=news();w:OpenUpdates('Script')
        assert(#w:GetScriptUpdates()==0 and w._news.Body.Text:find('ainda não cadastrou',1,true) and w._news.Controls.Read.Disabled);close(w)
    end)
    test('script updates are isolated per window and input tables are not retained',function()
        local a=news({ScriptUpdates={item}});local b=news()
        local feed=a:GetScriptUpdates();feed[1].Description['pt-BR']='changed copy'
        assert(#b:GetScriptUpdates()==0 and a:GetScriptUpdates()[1].Description['pt-BR']~='changed copy')
        a:Destroy();close(b)
    end)
    test('news locale refresh preserves source and selected update',function()
        local w=news({ScriptUpdates={item}});w:OpenUpdates('Script');assert(w._news.Title.Text=='Meu update')
        w:SetLocale('en-US');assert(w._news.Title.Text=='My update' and w._news.Body.Text=='New script feature.' and w._news.Selected==item.Id)
        w:SetLocale('pt-BR');assert(w._news.Title.Text=='Meu update');close(w)
    end)
    test('mark read survives profile round trip and only stores bounded hashes',function()
        local w=news({ScriptUpdates={item}});local library=w:GetLibraryUpdates()[1]
        w:MarkUpdateRead('Library',library.Id);w:MarkUpdateRead('Script',item.Id)
        local config=w:ExportConfig();assert(not config:find('Novo recurso do script.',1,true))
        local b=news({ScriptUpdates={item}});assert(b:ImportConfig(config,{Silent=true}))
        assert(b:GetUnreadUpdateCount('Script')==0 and b:GetUnreadUpdateCount('Library')==#b:GetLibraryUpdates()-1)
        w:Destroy();close(b)
    end)
    test('editing a previously read script entry makes that entry unread again',function()
        local w=news({ScriptUpdates={item}});w:MarkUpdateRead('Script',item.Id);assert(w:GetUnreadUpdateCount('Script')==0)
        local feed=w:GetScriptUpdates();feed[1].Description['en-US']='Changed behavior';w:SetScriptUpdates(feed)
        assert(w:GetUnreadUpdateCount('Script')==1);close(w)
    end)
    test('invalid script feed rejects atomically without changing official or previous content',function()
        local w=news({ScriptUpdates={item}});local official=w:GetLibraryUpdates()[1].Id
        for _,bad in ipairs({{item,item},{{Id='bad id',Title='Bad',Description='Bad'}},{{Id='id',Title='Title',Description='Text',Callback=function() end}}}) do
            assert(not pcall(w.SetScriptUpdates,w,bad) and #w:GetScriptUpdates()==1 and w:GetLibraryUpdates()[1].Id==official)
        end
        close(w)
    end)
    test('invalid read markers reject config import before appearance changes',function()
        local w=news({ScriptUpdates={item}});w:MarkUpdateRead('Script',item.Id)
        local data=Mock.Services.HttpService:JSONDecode(w:ExportConfig());data.Appearance.Theme='Paper';data.Appearance.Advanced.NewsRead={Library={bad='not-a-hash'}}
        assert(not w:ImportConfig(Mock.Services.HttpService:JSONEncode(data)) and w.Theme~='Paper' and w:GetUnreadUpdateCount('Script')==0);close(w)
    end)
    test('destroying a window with either news source open releases all view resources',function()
        for _,source in ipairs({'Library','Script'}) do local w=news({ScriptUpdates={item}});w:OpenUpdates(source);close(w) end
    end)
    test('news tab can be recreated after explicit destruction without losing read markers',function()
        local w=news({ScriptUpdates={item}});w:MarkUpdateRead('Script',item.Id);w:OpenUpdates('Script')
        w.NewsTab:Destroy();w:OpenUpdates('Script');assert(w:GetUnreadUpdateCount('Script')==0 and w._news.Title.Text=='Meu update');close(w)
    end)
end
