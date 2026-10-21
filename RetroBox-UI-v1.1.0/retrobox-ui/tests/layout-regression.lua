-- Layout contracts use mock geometry, not a Roblox renderer or pixel screenshots.
return function(Mock,Library,test)
    local sequence=0
    local function settings(extra)
        sequence=sequence+1; Mock.Geometry=true; Mock.StrictIconLifecycle=true
        Mock.ParentLockErrors=0; Mock.DestroyedIconWrites=0; Mock.Warnings={}
        local options={Id='layout-regression-'..sequence,Settings=false,FileStorage=false,ReducedMotion=true}
        for key,value in pairs(extra or {}) do options[key]=value end
        return options
    end
    local function window(extra)
        local w=Library:CreateWindow(settings(extra)); local s=w:CreateTab('Controls'):CreateSection('Accessories')
        Mock.pump(); return w,s
    end
    local function hub(extra)
        local options=settings(extra)
        options.Games={{Id='one',Name='A long game name for the existing launcher',Description=('Description. '):rep(50),PlaceId=game.PlaceId,
            Scripts={{Id='main',Title='A long script name',Description=('Instructions. '):rep(40),Callback=function() return true end}}},
            {Id='two',Name='Second',Description='Second game',PlaceId=222,Scripts={}}}
        local h=Library:CreateScriptHub(options); Mock.pump(); return h,h.Launcher
    end
    local function finish(w)
        w:Destroy(); Mock.pump(100)
        assert(Mock.Connections==0,'Layout leaked connections')
        assert(Mock.ParentLockErrors==0 and Mock.DestroyedIconWrites==0,'Layout wrote to a destroyed icon')
        assert(#Mock.Warnings==0,table.concat(Mock.Warnings,'\n'))
        Mock.Geometry=false; Mock.StrictIconLifecycle=false; Mock.MousePosition=nil
        Mock.Services.UserInputService.TouchEnabled=false; Mock.Viewport=Vector2.new(1280,720)
    end
    local function bounds(object)
        local p,s=object.AbsolutePosition,object.AbsoluteSize
        return p.X,p.Y,p.X+s.X,p.Y+s.Y
    end
    local function contains(parent,child)
        local a,b,c,d=bounds(parent); local x,y,r,t=bounds(child)
        return x>=a-.1 and y>=b-.1 and r<=c+.1 and t<=d+.1
    end
    local function separate(a,b)
        local ax,ay,ar,ab=bounds(a); local bx,by,br,bb=bounds(b)
        assert(ar<=bx+.1 or br<=ax+.1 or ab<=by+.1 or bb<=ay+.1,'Visible/clickable rectangles overlap')
    end
    local function fitsCaption(control)
        local caption=control._hubCaption
        local text=Mock.Services.TextService:GetTextSize(caption.Text,caption.TextSize,caption.Font,Vector2.new(100000,100000))
        local scale=control._window._actualScale or 1
        assert(caption.AbsoluteSize.X/scale>=text.X-.1,'Caption is unnecessarily truncated: '..caption.Text)
    end
    local function fitsControl(control,object)
        assert(contains(control.Frame,object))
        local scale=control._window._actualScale or 1
        local bottom=(object.AbsolutePosition.Y-control.Frame.AbsolutePosition.Y+object.AbsoluteSize.Y)/scale
        assert(bottom<=control.Frame.Size.Y.Offset+.1,'Control height clips its contents')
    end
    test('sort popup escapes clipped catalog ancestors without moving search',function()
        local h,l=hub(); local y=h.GameSearch.Frame.Position.Y.Offset
        h.Sort:SetOpen(true); Mock.pump()
        local owner=h.Window._overlay
        assert(owner and owner.Frame.Parent==h.Window.Root,'Sort menu is trapped in the clipped catalog')
        assert(h.Sort.Open and h.GameSearch.Frame.Position.Y.Offset==y)
        assert(contains(h.Window.Main,owner.Panels[1].Frame))
        for _,row in pairs(owner.Panels[1].Rows) do assert(h.Window:_interactionAllowed(row)) end
        finish(h.Window)
    end)
    test('sort options, toggle, outside click and Escape preserve state',function()
        local h=hub(); local w=h.Window
        for _,choice in ipairs({'Order','Alphabetical','Favorites'}) do
            h.Sort:SetOpen(true); local owner=w._overlay
            local index=table.find(h.Sort.Options,choice); owner:Select(index); Mock.pump()
            assert(h.Sort:GetValue()==choice and not h.Sort.Open and not w._overlay)
        end
        h.Sort:SetOpen(true); h.Sort:SetOpen(not h.Sort.Open); assert(not h.Sort.Open and not w._overlay)
        h.Sort:SetOpen(true); w._overlay.Backdrop.Activated:Fire(); assert(not h.Sort.Open and not w._overlay)
        h.Sort:SetOpen(true); w._overlay:OnKey('Escape'); assert(not h.Sort.Open and not w._overlay)
        finish(w)
    end)
    test('pointer down on a popup row does not close it before selection',function()
        local h=hub(); local w=h.Window; h.Sort:SetOpen(true)
        local owner=w._overlay; local row=owner.Panels[1].Rows[2]
        Mock.MousePosition=row.AbsolutePosition+Vector2.new(5,5)
        w:_inputBegan({UserInputType=Enum.UserInputType.MouseButton1},true)
        assert(w._overlay==owner and not owner.Destroyed)
        row.Activated:Fire(); Mock.pump(); assert(h.Sort:GetValue()==h.Sort.Options[2] and not h.Sort.Open)
        finish(w)
    end)
    test('sort popup stays inside the window at the lower viewport edge',function()
        local h,l=hub({Size=Vector2.new(800,520)}); local w=h.Window
        h.Sort.Frame.Position=UDim2.fromOffset(8,w.Main.AbsoluteSize.Y/(w._actualScale or 1)-60)
        h.Sort:SetOpen(true); local panel=w._overlay.Panels[1].Frame
        assert(contains(w.Main,panel) and panel.AbsolutePosition.Y<h.Sort.Button.AbsolutePosition.Y)
        w:SetScale(.85); Mock.pump(); assert(not h.Sort.Open and not w._overlay)
        h.Sort:SetOpen(true); w:Hide(); assert(not h.Sort.Open); w:Show()
        h.Sort:SetOpen(true); h:Destroy(); Mock.pump(); assert(not w._overlay)
        finish(w)
    end)
    test('wide dock fits complete translated action labels and running cancel',function()
        for _,locale in ipairs({'pt-BR','en-US'}) do
            local h,l=hub({Locale=locale,Size=Vector2.new(1080,720)})
            fitsCaption(h.PlayButton); fitsCaption(l.UI.More)
            assert(l.UI.More.Button.Text==(locale=='pt-BR' and 'Informações' or 'Information'))
            h.CancelButton.Frame.Visible=true; l:Layout()
            for _,control in ipairs({h.PlayButton,h.CancelButton,l.UI.More}) do
                fitsCaption(control); assert(contains(l.UI.Dock,control.Frame))
            end
            separate(h.PlayButton.Frame,h.CancelButton.Frame); separate(h.CancelButton.Frame,l.UI.More.Frame)
            separate(l.UI.SelectedScript,h.PlayButton.Frame); finish(h.Window)
        end
    end)
    test('small mobile dock wraps actions instead of shrinking their text',function()
        Mock.Services.UserInputService.TouchEnabled=true; Mock.Viewport=Vector2.new(390,844)
        local h,l=hub({Size=Vector2.new(390,760),TextScale=1.4})
        h.CancelButton.Frame.Visible=true; l:Layout()
        local controls={h.PlayButton,h.CancelButton,l.UI.More}
        for i,control in ipairs(controls) do
            fitsCaption(control); assert(contains(l.UI.Dock,control.Frame))
            assert(control.Frame.Size.Y.Offset>=42)
            for j=i+1,#controls do separate(control.Frame,controls[j].Frame) end
        end
        separate(l.UI.Status,h.PlayButton.Frame); finish(h.Window)
    end)
    test('toggle tooltip, inline binding and toggle have separate hit rectangles',function()
        local w,s=window(); local c=s:AddToggle({Title='Pausar',Tooltip='Pause help',Keybind=Enum.KeyCode.F6})
        c.Frame.AbsoluteSize=Vector2.new(500,100); c:_layoutDescription()
        separate(c.InfoButton,c.Keybind.Frame); separate(c.InfoButton,c.Button); separate(c.Keybind.Frame,c.Button)
        assert(contains(c.Frame,c.InfoButton) and contains(c.Frame,c.Keybind.Frame))
        c.InfoButton.Activated:Fire(); assert(w._tooltipOwner==c and not w._binding)
        c.Keybind.Button.Activated:Fire(); assert(w._binding==c.Keybind and not w._tooltipOwner)
        w:_inputBegan({UserInputType=Enum.UserInputType.Keyboard,KeyCode=Enum.KeyCode.RightShift},false)
        assert(c.Keybind:GetValue()==Enum.KeyCode.RightShift and not c:GetValue())
        finish(w)
    end)
    test('narrow accessory rows grow and shrink without cumulative offsets',function()
        local w,s=window(); local c=s:AddToggle({Title='Ativar IA',Tooltip='Help',Description=('A useful description. '):rep(8),Keybind=Enum.KeyCode.RightControl,Icon='target'})
        for _,width in ipairs({500,180,120,500,180,500}) do
            c.Frame.AbsoluteSize=Vector2.new(width,500); c:_layoutDescription()
            for _,object in ipairs({c.TitleLabel,c.InfoButton,c.Keybind.Frame,c.Button,c.DescriptionLabel}) do fitsControl(c,object) end
            separate(c.TitleLabel,c.InfoButton); separate(c.InfoButton,c.Keybind.Frame); separate(c.Keybind.Frame,c.Button)
            separate(c.DescriptionLabel,c.Keybind.Frame); separate(c.DescriptionLabel,c.Button)
            if width==500 then assert(c.Keybind.Frame.Position.Y.Offset<30) else assert(c.Frame.Size.Y.Offset>40) end
        end
        local before=c.TitleLabel.Size.X.Offset
        for _=1,8 do c:SetTooltip(nil); c:SetTooltip('Help') end
        assert(c.TitleLabel.Size.X.Offset==before); finish(w)
    end)
    test('all standard controls reserve help beside their own header accessories',function()
        local w,s=window(); local controls={s:AddToggle({Title='Toggle',Tooltip='Help'}),s:AddButton({Title='Button',Tooltip='Help'}),
            s:AddKeybind({Title='Binding',Tooltip='Help',Default=Enum.KeyCode.RightControl}),s:AddSlider({Title='Slider',Tooltip='Help'}),
            s:AddDropdown({Title='Dropdown',Tooltip='Help',Options={'A','B'}}),s:AddInput({Title='Input',Tooltip='Help'}),
            s:AddColorPicker({Title='Color',Tooltip='Help'})}
        for _,c in ipairs(controls) do
            for _,width in ipairs({400,160,400}) do
                c.Frame.AbsoluteSize=Vector2.new(width,500); c:_layoutDescription()
                fitsControl(c,c.InfoButton); separate(c.TitleLabel,c.InfoButton)
                local main=c.Type=='Slider' and c.Input or (c.Type=='Toggle' or c.Type=='Keybind') and c.Button
                if main then separate(c.InfoButton,main); separate(c.TitleLabel,main) end
            end
        end
        local pin=s:AddProgress({Title='Pinned metric',Tooltip='Help',Pinnable=true})
        pin.Frame.AbsoluteSize=Vector2.new(250,500); pin:_layoutDescription(); separate(pin.PinButton,pin.InfoButton)
        pin:SetPinnable(false); pin:SetTooltip(nil); pin:SetPinnable(true); pin:SetTooltip('Help'); separate(pin.PinButton,pin.InfoButton)
        finish(w)
    end)
    test('theme, UI scale and text scale retain independent accessory hit areas',function()
        local w,s=window(); local c=s:AddToggle({Title='Ativar IA',Tooltip='Help',Keybind=Enum.KeyCode.RightControl})
        for _,theme in ipairs({'Hacker','Retro98','Paper','Midnight'}) do
            w:SetTheme(theme)
            for _,scale in ipairs({.75,1,1.5}) do
                w:SetScale(scale)
                for _,ts in ipairs({.8,1,1.4}) do
                    w:SetTextScale(ts); c.Frame.AbsoluteSize=Vector2.new(260,500); c:_layoutDescription()
                    separate(c.InfoButton,c.Keybind.Frame); separate(c.Keybind.Frame,c.Button)
                    assert(contains(c.Frame,c.InfoButton) and contains(c.Frame,c.Button))
                end
            end
        end
        finish(w)
    end)
    test('help preferences and saved bindings reflow without firing callbacks',function()
        local w,s=window(); local calls=0
        local c=s:AddToggle({Id='pause',Title='Pause',Tooltip='Help',Keybind=Enum.KeyCode.F6,Callback=function() calls=calls+1 end})
        c.Frame.AbsoluteSize=Vector2.new(300,100); c:_layoutDescription(); local saved=w:ExportConfig()
        c.Keybind:SetValue(Enum.KeyCode.RightControl,true); w:SetTooltips({Enabled=false}); assert(not c.InfoButton.Visible)
        w:SetTooltips({Enabled=true}); w:ImportConfig(saved,{Silent=true}); Mock.pump()
        assert(c.Keybind:GetValue()==Enum.KeyCode.F6 and calls==0); separate(c.InfoButton,c.Keybind.Frame)
        finish(w)
    end)
    test('numeric header indicators share reservations with help and pinning',function()
        local w,s=window(); local c=s:AddProgress({Title='Collected materials',Tooltip='Explanation',Pinnable=true})
        for _,width in ipairs({500,220,150,500}) do
            c.Frame.AbsoluteSize=Vector2.new(width,500); c:_layoutDescription()
            local value
            for _,entry in ipairs(c._descriptionLayout.HeaderFields) do if entry.Object:IsA('TextLabel') then value=entry.Object end end
            assert(value); separate(c.TitleLabel,value); separate(c.InfoButton,value); separate(c.PinButton,value)
            fitsControl(c,value); c:SetValue(100); assert(value.Text=='100%')
        end
        finish(w)
    end)
    test('Hub translated captions fit across palettes and supported scale limits',function()
        for _,locale in ipairs({'pt-BR','en-US'}) do
            local h,l=hub({Locale=locale,Size=Vector2.new(1080,720)}); local w=h.Window
            for _,theme in ipairs({'Hacker','Retro98','Paper','Midnight'}) do
                w:SetTheme(theme)
                for _,scale in ipairs({.75,1,1.5}) do
                    w:SetScale(scale)
                    for _,ts in ipairs({.8,1,1.4}) do
                        w:SetTextScale(ts); Mock.pump(); h.CancelButton.Frame.Visible=true; l:Layout()
                        for _,control in ipairs({h.PlayButton,h.CancelButton,l.UI.More,l.UI.All,l.UI.Favorites,l.UI.Current,h.FavoriteButton,h.TeleportButton,l.UI.Retry,l.UI.Expand}) do
                            if control.Frame.Visible then fitsCaption(control) end
                        end
                        assert(contains(l.UI.Dock,h.PlayButton.Frame) and contains(l.UI.Dock,l.UI.More.Frame))
                        separate(h.PlayButton.Frame,h.CancelButton.Frame); separate(h.CancelButton.Frame,l.UI.More.Frame)
                        h.Sort:SetOpen(true); assert(contains(w.Main,w._overlay.Panels[1].Frame)); h.Sort:SetOpen(false)
                    end
                end
            end
            finish(w)
        end
    end)
    test('launcher tabs reserve their own label and pixel icon width',function()
        local h,l=hub({Title='Mano Gustavo Hub',TextScale=1.4})
        for _,page in ipairs(h.Window.Tabs) do
            local measured=Mock.Services.TextService:GetTextSize(page.Label.Text,page.Label.TextSize,page.Label.Font,Vector2.new(100000,100000))
            assert(page.Label.AbsoluteSize.X/(h.Window._actualScale or 1)>=measured.X)
        end
        finish(h.Window)
    end)
    test('sort selection preserves search favorites and explicit-only script execution',function()
        local h,l=hub(); local w=h.Window
        h:SetFavorite('two',true); h:SetCatalogFilter('Favorites'); h:SetGameQuery('Second'); Mock.pump()
        h.Sort:SetOpen(true); w._overlay:Select(2); Mock.pump()
        assert(h.GameList:GetViewStats().Filtered==1 and h.Sort:GetValue()=='Alphabetical')
        h:SetCatalogFilter('All'); h:SetGameQuery(''); h:SelectGame('one'); Mock.pump()
        l.UI.More.Button.Activated:Fire(); Mock.pump()
        assert(w._dialog.Content.Text:find(('Instructions. '):rep(10),1,true)); w._dialog:Close('test')
        assert(h:GetScriptStatus('one','main').Status=='Available')
        h.PlayButton.Button.Activated:Fire(); Mock.pump(); assert(h:GetScriptStatus('one','main').Status=='Completed')
        finish(w)
    end)
    test('popup cleanup, icon preferences and recreation release every connection',function()
        for _=1,3 do
            local h=hub(); h.Sort:SetOpen(true); h.Window:SetPixelIcons(false); h.Window:SetPixelIcons(true)
            h.Window:SetTheme('Hacker'); finish(h.Window)
        end
    end)
end
