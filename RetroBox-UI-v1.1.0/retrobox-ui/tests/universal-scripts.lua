return function(Mock,Library,test)
    local oldHTTP,oldLoad=game.HttpGet,loadstring
    local oldViewport=Mock.Viewport
    local function localScript(id,callback)
        return {Id=id or 'tool',Name='Universal tool',Description='Tools independent of a game',Callback=callback or function()return true end}
    end
    local function gameRecord(id)
        return {Id=id or 'game',Name='Registered game',PlaceId=game.PlaceId,Scripts={{Id='tool',Title='Game tool',Callback=function()return true end}}}
    end
    local function fixture(options)
        Mock.Geometry=true;Mock.StrictIconLifecycle=true;Mock.ParentLockErrors=0;Mock.DestroyedIconWrites=0;Mock.Warnings={}
        options=options or {};options.Id=options.Id or 'universal-test';options.FileStorage=false;options.ReducedMotion=true
        if options.Games==nil then options.Games={gameRecord()} end
        if options.UniversalScripts==nil then options.UniversalScripts={localScript()} end
        local h=Library:CreateScriptHub(options);Mock.pump();return h,h.Launcher
    end
    local function finish(h)
        h.Window:Destroy();Mock.pump(100)
        assert(Mock.Connections==0,'Universal Hub leaked connections')
        assert(Mock.ParentLockErrors==0 and Mock.DestroyedIconWrites==0,'Destroyed PixelIcon was modified')
        assert(#Mock.Warnings==0,table.concat(Mock.Warnings,'\n'))
        game.HttpGet,loadstring=oldHTTP,oldLoad;Mock.Geometry=false;Mock.StrictIconLifecycle=false;Mock.DeferDestroying=false;Mock.YieldingTasks=false
    end
    test('universal scripts have their own catalog without fabricated games or metadata requests',function()
        local queries=0;Mock.ThumbnailRequests={};Mock.TeleportRequests={}
        local h,l=fixture({Games={},GameMetadata={Provider=function()queries=queries+1;return {Name='Unexpected'} end}})
        assert(#h:GetGames()==0 and #h:GetUniversalScripts()==1 and queries==0 and #Mock.ThumbnailRequests==0 and #Mock.TeleportRequests==0)
        assert(h:GetSelectedCategory()=='Universal' and h.SelectedGameId==nil and h:GetSelectedGame()==nil)
        assert(l.UI.Universal.Frame.Visible and l.UI.GameTitle.Text=='Scripts universais' and l.UI.Source.Text=='UNIVERSAL')
        assert(not l.UI.GameActions.Visible and h.TeleportButton.Disabled and h.FavoriteButton.Disabled);finish(h)
    end)
    test('ordinary hubs keep their default game selection and do not show an unconfigured universal category',function()
        local h=Library:CreateScriptHub({Id='ordinary-hub',FileStorage=false,Games={gameRecord()}});Mock.pump()
        assert(h:GetSelectedCategory()=='Games' and h.SelectedGameId=='game' and #h:GetUniversalScripts()==0)
        assert(not h.Launcher.UI.Universal.Frame.Visible);h.Window:Destroy();Mock.pump(100);assert(Mock.Connections==0)
    end)
    test('switching categories restores independent selected scripts and recycled badges',function()
        local h=fixture({UniversalScripts={localScript('first'),localScript('second')}})
        assert(h:SelectUniversalScript('second'));Mock.pump()
        assert(h:GetSelectedScript().Id=='second' and h:GetSelectedScript().Universal and h.ScriptList._pool[1].UniversalTag.Visible)
        assert(h:SelectGame('game'));Mock.pump();assert(h:GetSelectedScript().Id=='tool' and not h.ScriptList._pool[1].UniversalTag.Visible)
        assert(h:SelectUniversalScripts());Mock.pump();assert(h:GetSelectedScript().Id=='second')
        h.Launcher.UI.All:Press();Mock.pump();assert(h:GetSelectedCategory()=='Games' and h.SelectedGameId=='game');finish(h)
    end)
    test('universal selection and searches never run callbacks and game filters remain independent',function()
        local calls=0;local h=fixture({UniversalScripts={localScript('notice',function()calls=calls+1 end)}})
        h.Launcher.UI.Universal:Press();h:SelectScript('notice');h:SetScriptQuery('independent');h:SetGameQuery('missing');h:SetSort('Alphabetical');Mock.pump()
        assert(h:GetSelectedCategory()=='Universal' and h.ScriptList:GetViewStats().Filtered==1 and h.GameList:GetViewStats().Filtered==0 and calls==0)
        h.PlayButton:Press();Mock.pump();assert(calls==1 and h:GetUniversalScriptStatus('notice').Status=='Completed');finish(h)
    end)
    test('universal callbacks receive script metadata without a fake game and getters return copies',function()
        local got;local h=fixture({UniversalScripts={localScript('notice',function(ctx,hub,spec)got=spec;assert(hub:GetSelectedGame()==nil);return {Done=true} end)}})
        h:SelectUniversalScripts();local a=h:GetUniversalScript('notice');a.Name='mutated';a.Requires[1]='readfile'
        assert(h:GetUniversalScript('notice').Name=='Universal tool' and #h:GetUniversalScript('notice').Requires==0)
        assert(h:RunUniversalScript('notice'));Mock.pump();assert(got.Id=='notice' and got.Name=='Universal tool' and got.Universal and got.Callback==nil and got._definition==nil)
        assert(h:RemoveGame('@universal')==false and #h:GetGames()==1);finish(h)
    end)
    test('a Pastefy raw URL is downloaded only on explicit run and compiles the returned source',function()
        local requests={};_G.__universalRuns=0;loadstring=load
        game.HttpGet=function(_,url)requests[#requests+1]=url;return '_G.__universalRuns=_G.__universalRuns+1;return "done"' end
        local h=fixture({Games={},UniversalScripts={{Id='pastefy',Name='Pastefy tool',Description='Remote source',URL='https://pastefy.app/ExampleID/raw'}}})
        assert(#requests==0 and _G.__universalRuns==0 and h:IsUniversalScriptAvailable('pastefy'))
        h.PlayButton:Press();Mock.pump();assert(#requests==1 and requests[1]=='https://pastefy.app/ExampleID/raw' and _G.__universalRuns==1)
        assert(h:GetUniversalScriptStatus('pastefy').Status=='Completed');finish(h);_G.__universalRuns=nil
    end)
    test('missing remote capabilities disable the universal script without a request',function()
        game.HttpGet=nil;loadstring=nil
        local h=fixture({Games={},UniversalScripts={{Id='remote',Name='Remote',URL='https://pastefy.app/ExampleID/raw'}}})
        assert(not h:IsUniversalScriptAvailable('remote') and h.PlayButton.Disabled and not h:RunUniversalScript('remote'))
        finish(h)
    end)
    test('the minimal universal definition accepts only Name Description and URL and generates a stable ID',function()
        loadstring=load;game.HttpGet=function()return 'return true' end
        local h=fixture({Games={},UniversalScripts={{Name='Minimal Pastefy tool',Description='Three fields',URL='https://pastefy.app/ExampleID/raw'}}})
        local spec=h:GetUniversalScripts()[1];assert(spec.Id:match('^universal%-%w+$') and spec.Name=='Minimal Pastefy tool')
        h:UpdateUniversalScript(spec.Id,{Name='Renamed',URL='https://pastefy.app/AnotherID/raw'})
        assert(h:GetUniversalScript(spec.Id).Name=='Renamed' and h:GetUniversalScript(spec.Id).Id==spec.Id)
        h.PlayButton:Press();Mock.pump();assert(h:GetUniversalScriptStatus(spec.Id).Status=='Completed');finish(h)
    end)
    test('universal URL download, empty source and compile failures produce Failed statuses',function()
        loadstring=load
        for i,fetch in ipairs({function()error('offline') end,function()return '' end,function()return '<html>not Lua</html>' end}) do
            game.HttpGet=fetch;local h=fixture({Games={},UniversalScripts={{Id='remote',Name='Remote',URL='https://pastefy.app/ExampleID/raw'}}})
            assert(h:RunUniversalScript('remote'));Mock.pump();local status=h:GetUniversalScriptStatus('remote');assert(status.Status=='Failed' and status.Error)
            local expected=({'offline','source is empty','compilation failed'})[i]
            assert(tostring(status.Error):find(expected,1,true) and #Mock.Warnings==1 and Mock.Warnings[1]:find(expected,1,true))
            Mock.Warnings={};finish(h);loadstring=load
        end
    end)
    test('cancelling a universal download prevents source execution after the download returns',function()
        Mock.YieldingTasks=true;loadstring=load;_G.__universalRuns=0
        game.HttpGet=function()task.wait(.5);return '_G.__universalRuns=_G.__universalRuns+1' end
        local h=fixture({Games={},UniversalScripts={{Id='slow',Name='Slow download',URL='https://pastefy.app/ExampleID/raw'}}})
        assert(h:RunUniversalScript('slow'));Mock.pump();assert(h:CancelUniversalScript('slow'));Mock.pump(.6)
        assert(_G.__universalRuns==0 and h:GetUniversalScriptStatus('slow').Status=='Cancelled');finish(h);_G.__universalRuns=nil
    end)
    test('universal and game scripts with matching IDs use independent actions and reject duplicate runs',function()
        Mock.YieldingTasks=true;local calls=0
        local h=fixture({UniversalScripts={localScript('tool',function(ctx)calls=calls+1;task.wait(.5);ctx:ThrowIfCancelled();return true end)}})
        h:SelectUniversalScripts();assert(h:RunUniversalScript('tool'));Mock.pump();assert(not h:RunUniversalScript('tool'))
        assert(h:RunScript('game','tool'));Mock.pump();assert(h:GetScriptStatus('game','tool').Status=='Completed' and calls==1)
        assert(h:GetUniversalScriptStatus('tool').Status=='Running');Mock.pump(.6);assert(h:GetUniversalScriptStatus('tool').Status=='Completed');finish(h)
    end)
    test('universal registration validates atomically before creating a window',function()
        local count=0;for _ in pairs(Library.Windows)do count=count+1 end
        local malformed={{Id='x',Name='X'},{Id='bad id',Name='X',Callback=function()end},{Id='x',Name='X',URL='http://example.test/script'},
            {Id='x',Name='X',URL='https://example.test/script',Callback=function()end},{Id='x',Name='X',CurrentGameOnly=true,Callback=function()end},
            {Id='x',Name='X',PlaceId=1,Callback=function()end},{Id='x',Name='X',Description=false,Callback=function()end}}
        for _,value in ipairs(malformed)do assert(not pcall(Library.CreateScriptHub,Library,{Id='invalid-universal',UniversalScripts={value}})) end
        assert(not pcall(Library.CreateScriptHub,Library,{Id='invalid-universal',UniversalScripts={localScript('x'),localScript('x')}}))
        local after=0;for _ in pairs(Library.Windows)do after=after+1 end;assert(count==after and Mock.Connections==0)
    end)
    test('universal catalog limits include both collections and preserve valid maximum IDs',function()
        local scripts={};for i=1,129 do scripts[i]=localScript('u'..i) end
        assert(not pcall(Library.CreateScriptHub,Library,{Id='too-many-universal',UniversalScripts=scripts}))
        table.remove(scripts);local games={};for i=1,32 do games[i]={Id='g'..i,Name='Game',Scripts={}};for j=1,128 do games[i].Scripts[j]={Id='s'..j,Title='Script'} end end
        assert(not pcall(Library.CreateScriptHub,Library,{Id='total-limit',Games=games,UniversalScripts={localScript()}}))
        local id=('u'):rep(64);local h=fixture({Id=('h'):rep(64),Games={},UniversalScripts={localScript(id)}})
        assert(h:RunUniversalScript(id));Mock.pump();assert(h:GetUniversalScriptStatus(id).Status=='Completed');finish(h)
    end)
    test('universal edits preserve trusted URL definitions and reject invalid patches atomically',function()
        loadstring=load;local url
        game.HttpGet=function(_,value)url=value;return 'return true' end
        local h=fixture({Games={},UniversalScripts={{Id='remote',Name='Before',URL='https://pastefy.app/ExampleID/raw'}}})
        assert(h:UpdateUniversalScript('remote',{Name='After',Description='New description'}));assert(h:GetUniversalScript('remote').Name=='After')
        assert(not pcall(h.UpdateUniversalScript,h,'remote',{URL='javascript:test'}));assert(h:GetUniversalScript('remote').Name=='After')
        assert(h:RunUniversalScript('remote'));Mock.pump();assert(url=='https://pastefy.app/ExampleID/raw')
        local calls=0;h:UpdateUniversalScript('remote',{URL=false,Callback=function()calls=calls+1 end});assert(h:RunUniversalScript('remote'));Mock.pump();assert(calls==1)
        assert(h:RemoveUniversalScript('remote') and not h:RemoveUniversalScript('remote') and #h:GetUniversalScripts()==0)
        assert(h:GetSelectedCategory()=='Universal' and h.PlayButton.Disabled and #h:GetGames()==0);finish(h)
    end)
    test('removing or replacing a running universal script cancels stale completion without running a replacement',function()
        Mock.YieldingTasks=true;local calls=0
        local h=fixture({Games={},UniversalScripts={localScript('slow',function(ctx)task.wait(.5);ctx:ThrowIfCancelled();calls=calls+1 end)}})
        assert(h:RunUniversalScript('slow'));Mock.pump();h:UpdateUniversalScript('slow',{Callback=function()calls=calls+10 end});Mock.pump(.6)
        assert(calls==0 and h:GetUniversalScriptStatus('slow').Status=='Available')
        assert(h:RunUniversalScript('slow'));Mock.pump();assert(calls==10)
        h:AddUniversalScript(localScript('second'));assert(h:RemoveUniversalScript('second'));finish(h)
    end)
    test('universal category profiles restore silently and accept older profiles without the new flag',function()
        local calls=0;local h=fixture({UniversalScripts={localScript('first',function()calls=calls+1 end),localScript('second')}})
        h:SelectUniversalScript('second');assert(h.Window:SaveConfig('universal-profile'))
        h:SelectGame('game');assert(h.Window:LoadConfig('universal-profile',{Silent=true}));Mock.pump()
        assert(h:GetSelectedCategory()=='Universal' and h.SelectedGameId==nil and calls==0)
        local profile=h.Window:ExportConfig(true);profile.Flags['hub/'..h.Id..'/catalog-category']=nil
        assert(h.Window:ImportConfig(profile,{Silent=true}));Mock.pump();assert(calls==0);finish(h)
    end)
    test('universal badges and controls support every theme, text scale, icons and small layouts',function()
        Mock.Viewport=Vector2.new(420,760);local h,l=fixture({Games={}})
        for _,theme in ipairs(Library:GetThemeNames())do h.Window:SetTheme(theme);h:SetTheme(theme);Mock.pump()
            local row=h.ScriptList._pool[1];assert(row.UniversalTag.Visible)
            assert(Library:ContrastRatio(row.UniversalTag.TextColor3,h.Window:_surfaceColor(row.UniversalTag))>=4.49999,theme)
        end
        for _,scale in ipairs({.8,1,1.4})do h.Window:SetTextScale(scale);Mock.pump()
            local row=h.ScriptList._pool[1];assert(row.LauncherTitle.Position.X.Offset+row.LauncherTitle.Size.X.Offset<=row.UniversalTag.Position.X.Offset)
        end
        h.Window:SetPixelIcons(false);h.Window:SetPixelIcons(true);Mock.pump();assert(l.UI.Universal.Frame.Visible)
        finish(h);Mock.Viewport=oldViewport
    end)
    test('universal details use English captions and keep normal game actions hidden',function()
        local h,l=fixture({Games={},Locale='en-US'});assert(l.UI.ScriptHeading.Text=='UNIVERSAL SCRIPTS' and l.UI.GameTitle.Text=='Universal scripts')
        assert(not l.UI.GameActions.Visible and l.UI.Source.Text=='UNIVERSAL');finish(h)
    end)
    test('universal actions remain visible in activity when another game is selected',function()
        Mock.YieldingTasks=true;local h,l=fixture({UniversalScripts={localScript('slow',function(ctx)task.wait(.5);ctx:ThrowIfCancelled();return true end)}})
        assert(h:RunUniversalScript('slow'));Mock.pump();h:SelectGame('game');Mock.pump()
        assert(l.UI.Activity.Text:find('1 ',1,true) and h:GetSelectedCategory()=='Games');Mock.pump(.6);finish(h)
    end)
    test('destroying and reexecuting universal hubs cleans deferred PixelIcons and previous actions',function()
        for _,deferred in ipairs({false,true})do
            Mock.DeferDestroying=deferred
            local h=fixture({Id='universal-reexecute',Games={}});h:SelectUniversalScripts()
            local nextHub=fixture({Id='universal-reexecute',Games={}});assert(h.Destroyed)
            nextHub.Launcher.UI.Root:Destroy();Mock.pump(100);assert(nextHub.Destroyed)
            nextHub:Destroy();finish(nextHub)
        end
    end)
end
