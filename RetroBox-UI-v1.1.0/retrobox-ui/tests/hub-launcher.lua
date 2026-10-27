return function(Mock,Library,test)
    local function record(id,place)
        return {Id=id,Name='Game '..id,Description='Description '..id,PlaceId=place,
            Scripts={{Id='main',Title='Script '..id,Description='Instructions '..id,Author='Developer',Version='1.0',Callback=function() return true end}}}
    end
    local function fixture(options)
        Mock.Geometry=true; Mock.StrictIconLifecycle=true; Mock.ParentLockErrors=0; Mock.DestroyedIconWrites=0; Mock.Warnings={}
        options=options or {}; options.Id=options.Id or 'native-launcher'; options.FileStorage=false; options.Settings=false; options.ReducedMotion=true
        options.Games=options.Games or {record('one',game.PlaceId),record('two',222)}
        local hub=Library:CreateScriptHub(options); Mock.pump(); return hub,hub.Launcher
    end
    local function finish(hub)
        hub.Window:Destroy(); Mock.pump(100)
        assert(Mock.Connections==0,'Native launcher leaked connections')
        assert(Mock.ParentLockErrors==0 and Mock.DestroyedIconWrites==0,'Destroyed PixelIcon write')
        assert(#Mock.Warnings==0,table.concat(Mock.Warnings,'\n'))
        Mock.Geometry=false; Mock.StrictIconLifecycle=false; Mock.DeferDestroying=false; Mock.YieldingTasks=false
        Mock.Services.UserInputService.TouchEnabled=false
        Mock.Viewport=Vector2.new(1280,720)
    end
    test('CreateScriptHub installs the launcher by default for arbitrary developers',function()
        local hub,l=fixture()
        assert(l and l.UI.Root.Name=='RetroBoxScriptHub' and l.UI.Root.Parent==hub.Tab.Frame)
        assert(hub.Window.Theme=='Retro98' and hub.PlayButton.Frame.Parent==l.UI.Dock)
        assert(rawget(hub,'SelectGame')==nil and rawget(hub.Window,'Destroy')==nil and rawget(hub.Window,'_layout')==nil)
        assert(not l._overrides and not l._catalog); finish(hub)
    end)
    test('legacy public controls and profile flag IDs retain their identities',function()
        local hub,l=fixture(); local ids={GameSearch='game-search',Sort='sort',Favorites='favorites',GameList='games',GameImage='image',ImageStatus='image-status',GameDetails='game-details',FavoriteButton='favorite',TeleportButton='teleport',TeleportStatus='teleport-status',ScriptSearch='script-search',ScriptList='scripts',ScriptDetails='script-details',ExecutionStatus='execution-status',PlayButton='play',CancelButton='cancel'}
        for name,id in pairs(ids) do assert(hub[name].Id=='hub/'..hub.Id..'/'..id and hub.Window.Controls[hub[name].Id]==hub[name]) end
        local list=hub.GameList; hub:UpdateGame('one',{Description='New description'}); Mock.pump(); assert(hub.GameList==list)
        finish(hub)
    end)
    test('attaching and removing a native hub preserves other tabs and restores ordinary chrome',function()
        Mock.Geometry=true
        local w=Library:CreateWindow({Id='attached-launcher',Settings=false,FileStorage=false,ReducedMotion=true})
        local tab=w:CreateTab({Title='Existing'}); local control=tab:CreateSection('Controls'):AddToggle({Id='existing',Default=true})
        local h=w:CreateScriptHub({Id='attached',Games={record('one',game.PlaceId)}}); Mock.pump()
        assert(h.Launcher and w.NavLayout.FillDirection==Enum.FillDirection.Horizontal and control:GetValue())
        h:Destroy(); Mock.pump(); assert(not w.Destroyed and w.Controls.existing==control and w.NavLayout.FillDirection==Enum.FillDirection.Vertical)
        assert(w.ActiveTab==tab); w:Destroy(); Mock.pump(100); assert(Mock.Connections==0); Mock.Geometry=false
    end)
    test('multiple hubs in one window have independent filters and owned resources',function()
        local a=fixture(); local w=a.Window; a.OwnsWindow=false
        local b=w:CreateScriptHub({Id='second-launcher',Games={record('three',333)}}); Mock.pump()
        a:SetCatalogFilter('Favorites'); assert(b:GetCatalogFilter()=='All' and a.GameList.Id~=b.GameList.Id)
        local old=a.Launcher; a:Destroy(); Mock.pump(); assert(old.Destroyed and b.Launcher and not b.Destroyed)
        assert(w.NavLayout.FillDirection==Enum.FillDirection.Horizontal); finish(b)
    end)
    test('destroying the launcher root releases an attached hub without retaining dead UI references',function()
        local h,l=fixture(); h.OwnsWindow=false; local w=h.Window
        local tab=w:CreateTab({Title='Keep'}); tab:CreateSection('Controls'):AddLabel({Id='keep',Title='Keep'})
        l.UI.Root:Destroy(); Mock.pump(100)
        assert(h.Destroyed and l.Destroyed and next(l.UI)==nil and not w.Destroyed and w.Controls.keep)
        assert(w._scriptHubs[h.Id]==nil and w.NavLayout.FillDirection==Enum.FillDirection.Vertical)
        for object in pairs(w._skin) do assert(object.Parent,'Dead theme binding retained') end
        finish(h)
    end)
    test('fallback names and notes do not mark Roblox metadata fields as manual',function()
        local queries=0
        local h,l=fixture({Games={{Id='automatic',PlaceId=991,FallbackName='Friendly fallback',Notes='Developer notes',Scripts={}}},
            GameMetadata={Provider=function() queries=queries+1; return {Name='Official name',Description='Official description'} end}})
        assert(queries==1 and h:GetGame('automatic').Name=='Official name' and h:GetGame('automatic').Notes=='Developer notes')
        assert(h:GetGameMetadataStatus('automatic').State=='Ready' and l.UI.GameTitle.Text=='Official name')
        h:SetGameQuery('Friendly fallback'); assert(h.GameList:GetViewStats().Filtered==1)
        h:SetGameQuery('Developer notes'); assert(h.GameList:GetViewStats().Filtered==1); finish(h)
    end)
    test('fallback is visible before a delayed query and after metadata failure',function()
        Mock.YieldingTasks=true
        local h,l=fixture({Games={{Id='automatic',PlaceId=992,FallbackName='Fallback title',Scripts={}}},GameMetadata={Provider=function() task.wait(1); error('Offline') end}})
        assert(l.UI.GameTitle.Text=='Fallback title' and h:GetGameMetadataStatus('automatic').State=='Loading')
        Mock.pump(2); assert(h:GetGameMetadataStatus('automatic').State=='Unavailable' and l.UI.GameTitle.Text=='Fallback title')
        assert(h.GameList._pool[1].LauncherTitle.Text=='Fallback title'); finish(h)
    end)
    test('manual title and intentionally empty description retain their override semantics',function()
        local h,l=fixture({Games={{Id='manual',PlaceId=993,Name='Custom title',Description='',FallbackName='Ignored fallback',Scripts={}}},
            GameMetadata={Provider=function() return {Name='Remote title',Description='Remote description'} end}})
        assert(h:GetGame('manual').Name=='Custom title' and h:GetGame('manual').Description=='' and l.UI.Source.Text=='PERSONALIZADO')
        assert(h:RefreshGameMetadata('manual')); Mock.pump(); assert(h:GetGame('manual').Description==''); finish(h)
    end)
    test('fallback and notes validate atomically on create and patch',function()
        local h=fixture(); local before=h:GetGame('one')
        for _,patch in ipairs({{FallbackName=false},{FallbackName=('x'):rep(129)},{Notes=function() end},{Notes=('x'):rep(2049)}}) do
            assert(not pcall(h.UpdateGame,h,'one',patch)); assert(h:GetGame('one').Name==before.Name)
        end
        h:UpdateGame('one',{FallbackName='Alias',Notes='New notes'}); assert(h:GetGame('one').FallbackName=='Alias')
        local copy=h:GetGame('one'); copy.Notes='Changed'; assert(h:GetGame('one').Notes=='New notes'); finish(h)
    end)
    test('a real or manually supplied name matching the placeholder still wins over fallback',function()
        local h,l=fixture({Games={{Id='official',PlaceId=994,FallbackName='Fallback',Scripts={}},
            {Id='manual',PlaceId=995,Name='Game 995',FallbackName='Fallback',Description='',Scripts={}}},
            GameMetadata={Provider=function() return {Name='Game 994',Description='Description'} end}})
        assert(l.UI.GameTitle.Text=='Game 994'); h:SelectGame('manual'); Mock.pump(); assert(l.UI.GameTitle.Text=='Game 995')
        finish(h)
    end)
    test('public catalog filters round trip silent profiles without running callbacks',function()
        local calls=0; local a=record('one',game.PlaceId); a.Scripts[1].Callback=function() calls=calls+1 end
        local h=fixture({Games={a,record('two',222)}}); h:SetFavorite('two',true); h:SetCatalogFilter('Favorites'); Mock.pump()
        local profile=h.Window:ExportConfig(); h:SetCatalogFilter('All'); h:SetFavorite('two',false)
        assert(h.Window:ImportConfig(profile,{Silent=true})); Mock.pump()
        assert(h:GetCatalogFilter()=='Favorites' and h.GameList:GetViewStats().Filtered==1 and calls==0)
        assert(not pcall(h.SetCatalogFilter,h,'Invalid') and h:GetCatalogFilter()=='Favorites'); finish(h)
    end)
    test('empty filters and empty catalogs retain honest selection and disabled execution',function()
        local h,l=fixture(); local selected=h.SelectedGameId
        h:SetCatalogFilter('Favorites'); Mock.pump(); assert(h.GameList:GetViewStats().Filtered==0 and h.SelectedGameId==selected)
        h:RemoveGame('one'); h:RemoveGame('two'); Mock.pump()
        assert(not h:GetSelectedGame() and h.PlayButton.Disabled and l.UI.ScriptCount.Text=='0'); finish(h)
    end)
    test('responsive options retain their documented bounds and row limits',function()
        local a=record('one',game.PlaceId)
        for i=2,8 do a.Scripts[i]={Id='s'..i,Title='Script '..i,Callback=function() end} end
        local h,l=fixture({NavigationRatio=.5,StackAt=900,ScriptListMaxRows=2,GameListMaxRows=2,Size=Vector2.new(1200,800),Games={a,record('two',222)}})
        assert(h.NavigationRatio==.5 and h.StackAt==900 and h.ScriptList.Frame.Size.Y.Offset==2*h.ScriptList.RowHeight+4)
        h.Window:SetTextScale(1.4); Mock.pump(); assert(l.LayoutMode=='stacked' and h.ScriptList.RowHeight>=142)
        finish(h)
    end)
    test('touch launcher controls remain reachable with an open sort dropdown',function()
        Mock.Viewport=Vector2.new(390,844); Mock.Services.UserInputService.TouchEnabled=true
        local h,l=fixture(); h.Sort:SetOpen(true); Mock.pump()
        assert(l.LayoutMode=='stacked' and h.PlayButton.Frame.Size.Y.Offset>=42 and h.Sort.Button.Size.Y.Offset==42)
        for _,child in ipairs(h.Sort.Frame:GetChildren()) do if child.ClassName=='Frame' and child.Size.Y.Offset==184 then assert(child.Position.Y.Offset>=46) end end
        h.Sort:SetOpen(false); Mock.pump(); finish(h)
    end)
    test('low landscape windows keep the launcher and execution controls inside the tab viewport',function()
        Mock.Viewport=Vector2.new(844,390)
        local h,l=fixture({Size=Vector2.new(1080,300)})
        local function inside(object,parent)
            local a,b=object.AbsolutePosition,parent.AbsolutePosition;local size,bounds=object.AbsoluteSize,parent.AbsoluteSize
            return a.Y>=b.Y-.1 and a.Y+size.Y<=b.Y+bounds.Y+.1
        end
        assert(inside(l.UI.Root,h.Tab.Frame) and inside(l.UI.Dock,l.UI.Root) and inside(h.PlayButton.Frame,l.UI.Dock))
        assert(l.UI.Body.Size.Y.Offset==0 or l.LayoutMode=='stacked'); finish(h)
    end)
    test('English locale and custom themes apply to native launcher labels and captions',function()
        local h,l=fixture({Locale='en-US',Theme='Hacker'})
        assert(l.UI.LibraryTitle.Text=='LIBRARY' and l.UI.All.Button.Text=='All' and h.PlayButton.Button.Text=='Run script')
        assert(l.UI.GameContext.Text:find('script in this hub',1,true)); h.Window:SetTheme('Paper'); Mock.pump()
        assert(l.UI.LibraryTitle.TextColor3==h.Window:_ink('Text',l.UI.LibraryTitle) and h:GetThemeProfile().Theme=='Launcher'); finish(h)
    end)
    test('all palettes retain contrast for the visible game and script card labels',function()
        local h=fixture(); local gameList,scriptList=h.GameList,h.ScriptList
        for _,theme in ipairs(Library:GetThemeNames()) do h.Window:SetTheme(theme);h:SetTheme(theme); Mock.pump()
            for _,view in ipairs({gameList,scriptList}) do for _,row in ipairs(view._pool) do if row.Button.Visible then
                for _,name in ipairs({'LauncherTitle','LauncherMeta','LauncherCredit','LauncherDescription','LauncherState'}) do
                    local label=row[name]; if label then assert(Library:ContrastRatio(label.TextColor3,h.Window:_surfaceColor(label))>=4.49999,theme..' '..name) end
                end
            end end end
        end
        assert(h.GameList==gameList and h.ScriptList==scriptList); finish(h)
    end)
    test('native detail dialog includes full developer notes and script descriptions',function()
        local a=record('one',game.PlaceId); a.Notes='Notes for this game'
        local h,l=fixture({Games={a}}); l.UI.More:Press(); Mock.pump()
        assert(h.Window._dialog and h.Window._dialog.Content.Text:find('Notes for this game',1,true) and h.Window._dialog.Content.Text:find('Instructions one',1,true))
        h.Window._dialog:Close('test'); finish(h)
    end)
    test('teleport status remains visible in the new selected-game layout',function()
        local h,l=fixture({ConfirmTeleport=false,Teleporter=function() return false,'Teleport unavailable' end})
        h:TeleportToGame('two'); Mock.pump()
        assert(l.UI.TeleportMessage.Visible and l.UI.TeleportMessage.Text:find('Teleport unavailable',1,true)); finish(h)
    end)
    test('metadata controls remain addressable through public global search and focus',function()
        local h,l=fixture(); local found=false
        for _,entry in ipairs(h.Window:SearchControls('Description one')) do if entry.Control==h.GameDetails then found=true end end
        assert(found and h.Window:FocusControl(h.GameDetails)); Mock.pump()
        h.Window:SetSearch('no-matching-tool'); assert(h.GameList.Frame.Visible and h.PlayButton.Frame.Visible)
        assert(h.GameDetails._hubFocusTarget==l.UI.GameTitle); finish(h)
    end)
    test('idle native launchers do not add polling jobs or frame connections',function()
        local h=fixture(); assert(next(h.Window.Tasks)==nil and not h.Window._runtimeConnection)
        Mock.pump(60); assert(next(h.Window.Tasks)==nil and not h.Window._runtimeConnection); finish(h)
    end)
    for _,deferred in ipairs({false,true}) do
        test('external GUI destruction releases an active Hold binding without rendering a dead icon '..tostring(deferred),function()
            Mock.DeferDestroying=deferred
            local h,l=fixture(); local section=h.Window:CreateTab({Title='Controls'}):CreateSection('Hold')
            local toggle=section:AddToggle({Id='hold-toggle',Default=true,Keybind={Default=Enum.KeyCode.F,Mode='Hold'}})
            toggle.Keybind:Trigger(true); Mock.pump(); assert(toggle:GetValue() and toggle._checkIcon.Frame)
            local binding=toggle.Keybind; h.Window.Gui:Destroy(); Mock.pump(100)
            assert(h.Window.Destroyed and l.Destroyed and not binding.Active); finish(h)
        end)
    end
end
