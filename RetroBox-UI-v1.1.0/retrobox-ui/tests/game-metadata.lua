return function(Mock,Library,test)
    local calls=0
    local function fixture(options)
        calls=0
        Mock.Services.MarketplaceService={GetProductInfoAsync=function(_,id)
            calls=calls+1; return {Name='Official '..id,Description='Description '..id}
        end}
        options=options or {}; options.Id='metadata-test'; options.FileStorage=false; options.Settings=false; options.ReducedMotion=true
        options.Games=options.Games or {{Id='one',PlaceId=100,Scripts={{Id='run',Title='Run',Callback=function() end}}}}
        return Library:CreateScriptHub(options)
    end
    local function finish(h)
        h.Window:Destroy(); Mock.pump(100); Mock.YieldingTasks=false; Mock.Services.MarketplaceService=nil
        assert(Mock.Connections==0 and #Mock.Warnings==0)
    end
    test('metadata inserts a PlaceId-only game immediately and hydrates name and description asynchronously',function()
        local h=fixture(); assert(h:GetGame('one').Name=='Game 100' and calls==0)
        Mock.pump(); assert(calls==1 and h:GetGame('one').Name=='Official 100' and h:GetGame('one').Description=='Description 100')
        assert(h:GetGameMetadataStatus('one').State=='Ready' and h:GetThumbnailStatus('one'))
        assert(h:GetScript('one','run').Title=='Run'); finish(h)
    end)
    test('metadata preserves custom name and fills only the absent description',function()
        local h=fixture({Games={{Id='one',PlaceId=100,Name='Custom',Scripts={}}}})
        Mock.pump(); assert(h:GetGame('one').Name=='Custom' and h:GetGame('one').Description=='Description 100'); finish(h)
    end)
    test('metadata preserves custom description and fills only the absent name',function()
        local h=fixture({Games={{Id='one',PlaceId=100,Description='Custom description',Scripts={}}}})
        Mock.pump(); assert(h:GetGame('one').Name=='Official 100' and h:GetGame('one').Description=='Custom description'); finish(h)
    end)
    test('metadata keeps fully manual legacy entries and avoids unnecessary queries',function()
        local h=fixture({Games={{Id='one',Name='Legacy',Description='',PlaceId=100,Scripts={}}}})
        Mock.pump(); assert(calls==0 and h:GetGame('one').Description=='' and h:GetGameMetadataStatus('one').State=='Preserved'); finish(h)
    end)
    test('metadata rejects invalid identifiers and keeps the internal Id mandatory',function()
        for _,id in ipairs({0,-1,1.5,math.huge,'100'}) do
            assert(not pcall(Library.CreateScriptHub,Library,{Id='bad-metadata',Games={{Id='one',PlaceId=id}}}))
        end
        assert(not pcall(Library.CreateScriptHub,Library,{Id='bad-metadata',Games={{PlaceId=100}}}))
        assert(next(Library.Windows)==nil and Mock.Connections==0)
    end)
    test('metadata network failure leaves scripts usable with fallback and observable status',function()
        local h=fixture(); Mock.Services.MarketplaceService.GetProductInfoAsync=function() calls=calls+1; error('offline') end
        Mock.pump(); assert(h:GetGame('one').Name=='Game 100' and h:GetGameMetadataStatus('one').State=='Unavailable')
        assert(h:IsScriptAvailable('one','run')); finish(h)
    end)
    test('metadata accepts a partial official response without inventing missing fields',function()
        local h=fixture(); Mock.Services.MarketplaceService.GetProductInfoAsync=function() return {Name='Partial'} end
        Mock.pump(); assert(h:GetGame('one').Name=='Partial' and h:GetGame('one').Description=='')
        assert(h:GetGameMetadataStatus('one').State=='Partial' and h:GetGame('one').UniverseId==nil); finish(h)
    end)
    test('metadata refresh bypasses cache and preserves customized values',function()
        local h=fixture({Games={{Id='one',Name='Custom',PlaceId=100}}}); Mock.pump()
        Mock.Services.MarketplaceService.GetProductInfoAsync=function() calls=calls+1; return {Name='Changed',Description='New description'} end
        assert(h:RefreshGameMetadata('one')); Mock.pump()
        assert(calls==2 and h:GetGame('one').Name=='Custom' and h:GetGame('one').Description=='New description')
        assert(not h:RefreshGameMetadata('missing')); finish(h)
    end)
    test('metadata deduplicates simultaneous requests and reuses a bounded TTL cache',function()
        local h=fixture({Games={{Id='one',PlaceId=100},{Id='two',PlaceId=100}},GameMetadata={CacheTTL=1}})
        Mock.pump(); assert(calls==1 and h:GetGame('two').Name=='Official 100')
        h:AddGame({Id='three',PlaceId=100}); Mock.pump(); assert(calls==1 and h:GetGameMetadataStatus('three').Cached)
        Mock.pump(2); h:AddGame({Id='four',PlaceId=100}); Mock.pump(); assert(calls==2); finish(h)
    end)
    test('metadata caches failures briefly and retries only on a later explicit request or new record',function()
        local h=fixture({GameMetadata={FailureTTL=1}})
        Mock.Services.MarketplaceService.GetProductInfoAsync=function() calls=calls+1; error('offline') end
        Mock.pump(); h:AddGame({Id='two',PlaceId=100}); Mock.pump(); assert(calls==1)
        Mock.pump(2); h:AddGame({Id='three',PlaceId=100}); Mock.pump(); assert(calls==2); finish(h)
    end)
    test('metadata limits concurrency and never polls once hydration settles',function()
        Mock.YieldingTasks=true; local h=fixture({Games={{Id='one',PlaceId=1},{Id='two',PlaceId=2},{Id='three',PlaceId=3},{Id='four',PlaceId=4}},GameMetadata={MaxConcurrent=2}})
        local active,maximum=0,0
        Mock.Services.MarketplaceService.GetProductInfoAsync=function(_,id)
            calls=calls+1; active=active+1; maximum=math.max(maximum,active); task.wait(1); active=active-1
            return {Name='Game '..id,Description='Hydrated'}
        end
        Mock.pump(); assert(calls==2 and maximum==2); Mock.pump(1); Mock.pump(1); Mock.pump(50)
        assert(calls==4 and maximum==2 and h._metadata.Active==0); finish(h)
    end)
    test('metadata ignores results for a removed record and cleans the pending manager',function()
        Mock.YieldingTasks=true; local h=fixture()
        Mock.Services.MarketplaceService.GetProductInfoAsync=function() task.wait(1); return {Name='Late',Description='Late'} end
        Mock.pump(); assert(h:RemoveGame('one')); Mock.pump(2); assert(not h:GetGame('one'))
        local manager=h._metadata; finish(h); assert(manager.Owner==nil and next(manager.Requests)==nil)
    end)
    test('metadata invalidates stale results when the Roblox identifier changes',function()
        Mock.YieldingTasks=true; local h=fixture()
        Mock.Services.MarketplaceService.GetProductInfoAsync=function(_,id) task.wait(id==100 and 2 or 1); return {Name='Game '..id,Description='ID '..id} end
        Mock.pump(); h:UpdateGame('one',{PlaceId=200}); Mock.pump(); Mock.pump(1); Mock.pump(2)
        assert(h:GetGame('one').Name=='Game 200' and h:GetGame('one').Description=='ID 200'); finish(h)
    end)
    test('metadata edits during loading keep the new custom name',function()
        Mock.YieldingTasks=true; local h=fixture()
        Mock.Services.MarketplaceService.GetProductInfoAsync=function() task.wait(1); return {Name='Late official',Description='Late description'} end
        Mock.pump(); h:UpdateGame('one',{Name='Manual during load'}); Mock.pump(); Mock.pump(1)
        assert(h:GetGame('one').Name=='Manual during load' and h:GetGame('one').Description=='Late description'); finish(h)
    end)
    test('metadata preserves the latest selection favorites query sorting and both scroll positions',function()
        local h=fixture({Games={{Id='one',PlaceId=100},{Id='two',PlaceId=200}}})
        h:SetFavorite('one',true); h:SetSort('Favorites'); h:SetGameQuery('Official'); h:SelectGame('two')
        h.GameList.Viewport.CanvasPosition=Vector2.new(0,18); h.ScriptList.Viewport.CanvasPosition=Vector2.new(0,7)
        Mock.pump(); assert(h.SelectedGameId=='two' and h:IsFavorite('one') and h.Sort:GetValue()=='Favorites' and h.GameSearch:GetValue()=='Official')
        assert(h.GameList.Viewport.CanvasPosition.Y==18 and h.ScriptList.Viewport.CanvasPosition.Y==7); finish(h)
    end)
    test('metadata providers can supply UniverseId and valid image identifiers without changing callbacks',function()
        local ran=0
        local h=fixture({GameMetadata={Provider=function(query,official)
            assert(query.PlaceId==100 and official.Name=='Official 100')
            return {Name='Experience',Description='Experience description',UniverseId=900,Image='rbxassetid://123'}
        end},Games={{Id='one',PlaceId=100,Scripts={{Id='run',Title='Run',Callback=function() ran=ran+1 end}}}}})
        Mock.pump(); local rec=h:GetGame('one'); assert(rec.UniverseId==900 and rec.Image=='rbxassetid://123' and rec.Name=='Experience' and ran==0)
        local action=h:RunScript('one','run'); Mock.pump(); assert(action.Finished and ran==1); finish(h)
    end)
    test('metadata rejects executable provider fields and preserves catalog execution bindings',function()
        local h=fixture({GameMetadata={Provider=function() return {Callback=function() error('injected') end} end}})
        Mock.pump(); assert(h:GetGameMetadataStatus('one').Error:find('Unknown metadata field',1,true))
        assert(h:IsScriptAvailable('one','run')); finish(h)
    end)
    test('metadata uses the current session mapping but does not confuse PlaceId and UniverseId',function()
        local h=fixture({Games={{Id='one',PlaceId=game.PlaceId}}}); Mock.pump()
        assert(h:GetGame('one').UniverseId==game.GameId and h:GetGame('one').PlaceId==game.PlaceId); finish(h)
    end)
    test('metadata supports UniverseId-only records with an explicit authorized provider',function()
        local h=fixture({Games={{Id='one',UniverseId=900}},GameMetadata={Provider=function(query)
            assert(query.PlaceId==nil and query.UniverseId==900); return {Name='Universe',Description='Provider description'}
        end}})
        Mock.pump(); assert(h:GetGame('one').Name=='Universe' and h:GetGameMetadataStatus('one').State=='Ready'); finish(h)
    end)
    test('metadata truncates external text on UTF-8 boundaries and returns copied statuses',function()
        local h=fixture({GameMetadata={Provider=function() return {Name=('á'):rep(100),Description=('ç'):rep(2000)} end}})
        Mock.pump(); assert(utf8.len(h:GetGame('one').Name)==64 and utf8.len(h:GetGame('one').Description)==1024)
        local status=h:GetGameMetadataStatus('one'); status.State='mutated'; assert(h:GetGameMetadataStatus('one').State=='Ready'); finish(h)
    end)
    test('metadata can be disabled while legacy entries remain compatible',function()
        local h=fixture({GameMetadata=false,Games={{Id='one',Name='Manual',PlaceId=100}}}); Mock.pump()
        assert(calls==0 and h:GetGameMetadataStatus('one').State=='Disabled' and not h:RefreshGameMetadata('one'))
        assert(not pcall(h.AddGame,h,{Id='bad',PlaceId=1})); finish(h)
    end)
    test('metadata refresh deduplication bounds listeners while a request is still loading',function()
        Mock.YieldingTasks=true; local h=fixture()
        Mock.Services.MarketplaceService.GetProductInfoAsync=function() calls=calls+1; task.wait(1); return {Name='Once',Description='One request'} end
        Mock.pump(); for _=1,200 do assert(h:RefreshGameMetadata('one')) end
        local request=next(h._metadata.Requests) and select(2,next(h._metadata.Requests)); local count=0
        for _ in pairs(request.Listeners) do count=count+1 end
        assert(count==1 and h:GetGameMetadataStatus('one').State=='Loading')
        Mock.pump(1); assert(calls==1 and h:GetGame('one').Name=='Once'); finish(h)
    end)
    test('metadata cache remains bounded across a large catalog',function()
        local games={}; for i=1,132 do games[i]={Id='game-'..i,PlaceId=i} end
        local h=fixture({Games=games}); Mock.pump()
        local count=0; for _ in pairs(h._metadata.Cache) do count=count+1 end
        assert(calls==132 and count==128); finish(h)
    end)
    test('metadata destruction ignores late results and clears owner queue cache and listeners',function()
        Mock.YieldingTasks=true; local h=fixture()
        Mock.Services.MarketplaceService.GetProductInfoAsync=function() task.wait(1); return {Name='Late',Description='Late'} end
        Mock.pump(); local manager=h._metadata; h.Window:Destroy(); Mock.pump(2)
        assert(manager.Destroyed and manager.Owner==nil and next(manager.Cache)==nil and next(manager.States)==nil and next(manager.Requests)==nil)
        finish(h)
    end)
    test('versioned catalogs may omit metadata but still reject executable fields',function()
        local ran=0; local doc={SchemaVersion=1,Kind='HubCatalog',HubId='metadata-test',Version='1.1.0',Games={{Id='remote',PlaceId=100,Scripts={{Id='run',Title='Run',Action='local-action'}}}}}
        local h=fixture({Games={},Actions={['local-action']=function() ran=ran+1 end},CatalogUpdate={Root='https://metadata.test/catalog',AutoLoad=false,Fetch=function(url)
            local bytes=Mock.Services.HttpService:JSONEncode(doc)
            if url:find('catalog.json',1,true) then return bytes end
            return Mock.Services.HttpService:JSONEncode({SchemaVersion=1,Kind='HubCatalog',HubId='metadata-test',Version=doc.Version,APIVersion=1,Channel='stable',Build='metadata-'..doc.Version,Library={MinVersion='2.0.0',APIVersion=2},
                Artifact={Path='dist/releases/'..doc.Version..'/catalog.json',SHA256=Library:SHA256(bytes),Bytes=#bytes}})
        end}})
        assert(h:ReloadCatalog()); Mock.pump(); assert(h:GetGame('remote').Name=='Official 100' and ran==0)
        doc.Games[1].Callback='injected'; assert(not h:ReloadCatalog()); assert(h:GetGame('remote').Name=='Official 100')
        local action=h:RunScript('remote','run'); Mock.pump(); assert(action.Finished and ran==1); finish(h)
    end)
end
