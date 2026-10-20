return function(Mock,Library,test)
    local oldHTTP,oldLoad=game.HttpGet,loadstring
    local function document()
        return {SchemaVersion=1,Kind='HubCatalog',HubId='universal-catalog',Version='1.1.0',
            Games={{Id='game',Name='Updated game',Scripts={{Id='local',Title='Game script'}}}}}
    end
    local function fixture(options)
        options=options or {};local state={Document=document(),Calls=0}
        Mock.StrictIconLifecycle=true;Mock.ParentLockErrors=0;Mock.DestroyedIconWrites=0;Mock.Warnings={}
        loadstring=load;game.HttpGet=function()return 'return true' end
        local function fetch(url)
            local bytes=Mock.Services.HttpService:JSONEncode(state.Document)
            if url:match('%.json$') and url:find('/channels/',1,true) then
                return Mock.Services.HttpService:JSONEncode({SchemaVersion=1,Kind='HubCatalog',HubId='universal-catalog',Version=state.Document.Version,
                    APIVersion=1,Channel='stable',Build='catalog-'..state.Document.Version,Library={MinVersion='2.4.0',MaxVersion='3.0.0',APIVersion=2},
                    Artifact={Path='dist/releases/'..state.Document.Version..'/catalog.json',SHA256=Library:SHA256(bytes),Bytes=#bytes}})
            end
            return bytes
        end
        local h=Library:CreateScriptHub({Id='universal-catalog',FileStorage=false,ReducedMotion=true,
            Actions={notice=function(ctx,hub,spec)assert(spec.Universal);state.Calls=state.Calls+1;return true end},
            CatalogUpdate={Root='https://catalog.test/universal',Fetch=fetch,AutoLoad=false,Cache=false},
            Games={{Id='game',Name='Original game',Scripts={{Id='local',Title='Game script',Callback=function()return true end}}}},
            UniversalScripts=options.UniversalScripts or {{Id='remote',Name='Trusted local URL',URL='https://pastefy.app/ExampleID/raw'}}})
        Mock.pump();return h,state
    end
    local function finish(h)
        h.Window:Destroy();Mock.pump(100)
        assert(Mock.Connections==0 and #Mock.Warnings==0 and Mock.ParentLockErrors==0 and Mock.DestroyedIconWrites==0)
        game.HttpGet,loadstring=oldHTTP,oldLoad;Mock.YieldingTasks=false;Mock.StrictIconLifecycle=false
    end
    test('declarative universal metadata preserves the trusted locally registered Pastefy URL',function()
        local h,s=fixture();s.Document.UniversalScripts={{Id='remote',Name='Updated universal',Description='Updated instructions'}}
        local viewport=h.ScriptList.Viewport;h:SelectUniversalScripts();assert(h:ReloadCatalog());Mock.pump()
        assert(h:GetUniversalScript('remote').URL=='https://pastefy.app/ExampleID/raw' and h:GetUniversalScript('remote').Name=='Updated universal')
        assert(h:GetGame('game').Name=='Updated game' and h.ScriptList.Viewport==viewport and h:GetSelectedCategory()=='Universal' and s.Calls==0)
        assert(h:RunUniversalScript('remote'));Mock.pump();assert(h:GetUniversalScriptStatus('remote').Status=='Completed');finish(h)
    end)
    test('universal catalog entries only execute locally registered Actions and unknown Actions stay unavailable',function()
        local h,s=fixture();s.Document.UniversalScripts={{Id='action',Name='Registered action',Action='notice'}}
        assert(h:ReloadCatalog());Mock.pump();assert(s.Calls==0)
        assert(h:RunUniversalScript('action'));Mock.pump();assert(s.Calls==1)
        s.Document.Version='1.2.0';s.Document.UniversalScripts[1].Action='unregistered'
        assert(h:ReloadCatalog());assert(not h:IsUniversalScriptAvailable('action') and not h:RunUniversalScript('action') and s.Calls==1);finish(h)
    end)
    test('universal executable fields and invalid identifiers reject the whole catalog atomically',function()
        local h,s=fixture();local before=h:GetUniversalScript('remote').Name
        for _,patch in ipairs({{URL='https://other.test/evil'},{Source='return true'},{Callback='return true'},{CurrentGameOnly=true},{Id='invalid id'}})do
            s.Document=document();local item={Id='remote',Name='Unexpected change'};for k,v in pairs(patch)do item[k]=v end
            s.Document.UniversalScripts={item};assert(not h:ReloadCatalog())
            assert(h:GetGame('game').Name=='Original game' and h:GetUniversalScript('remote').Name==before and h.CatalogVersion=='1.0.0' and s.Calls==0)
        end
        finish(h)
    end)
    test('older catalogs omit UniversalScripts without removing or cancelling the local universal collection',function()
        Mock.YieldingTasks=true;local calls=0
        local h=fixture({UniversalScripts={{Id='slow',Name='Slow',Callback=function(ctx)task.wait(.5);ctx:ThrowIfCancelled();calls=calls+1;return true end}}})
        h:SelectUniversalScripts();assert(h:RunUniversalScript('slow'));Mock.pump();assert(h:ReloadCatalog())
        assert(h:GetUniversalScriptStatus('slow').Status=='Running' and #h:GetUniversalScripts()==1 and h:GetSelectedCategory()=='Universal')
        Mock.pump(.6);assert(calls==1 and h:GetUniversalScriptStatus('slow').Status=='Completed');finish(h)
    end)
    test('an explicit empty universal catalog cancels old runs and retains a usable empty category',function()
        Mock.YieldingTasks=true;local calls=0
        local h,s=fixture({UniversalScripts={{Id='slow',Name='Slow',Callback=function(ctx)task.wait(.5);ctx:ThrowIfCancelled();calls=calls+1 end}}})
        h:SelectUniversalScripts();assert(h:RunUniversalScript('slow'));Mock.pump()
        s.Document.UniversalScripts={};assert(h:ReloadCatalog());Mock.pump(.6)
        assert(calls==0 and #h:GetUniversalScripts()==0 and h:GetSelectedCategory()=='Universal' and h.PlayButton.Disabled)
        assert(#h:GetGames()==1 and h:GetGame('game').Name=='Updated game');finish(h)
    end)
end
