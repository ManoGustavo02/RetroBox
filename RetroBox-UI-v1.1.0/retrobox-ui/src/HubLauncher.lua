-- Native Script Hub launcher. Embedded inside the existing Hub lexical scope.
-- Catalogs, runtime, callbacks and control identities remain owned by Hub.
function Hub:_displayGameName(record)
    if not record then return self.Window:_t17('Escolha um jogo','Choose a game') end
    if record.Universal then return record.Name end
    local native=self:_game(record.Id)
    local status=self:GetGameMetadataStatus(record.Id)
    if native and native._metadataManual.Name or status and status.Fields and status.Fields.Name then return record.Name end
    local placeholder='Game '..string.format('%.0f',record.PlaceId or record.UniverseId or 0)
    if record.Name==placeholder and record.FallbackName and record.FallbackName~='' then return record.FallbackName end
    return record.Name
end
function Hub:_filterGames()
    if self.Destroyed or not self.GameList then return end
    local query=lower(self.GameSearch:GetValue()); local choice=self:GetCatalogFilter()
    local position=self.GameList.Viewport.CanvasPosition
    self.GameList:SetFilter(function(row)
        local rec=self:_game(row.Id); if not rec then return false end
        if choice=='Favorites' and not self:IsFavorite(row.Id) then return false end
        if choice=='Current' and not self:IsCurrentGame(row.Id) then return false end
        return query=='' or lower(rec.Name..' '..rec.Description..' '..rec.FallbackName..' '..rec.Notes):find(query,1,true)~=nil
    end)
    if self._lastGameQuery==query and self._lastCatalogFilter==choice then self.GameList.Viewport.CanvasPosition=position end
    self._lastGameQuery,self._lastCatalogFilter=query,choice
    self:_layoutHub()
end
function Hub:GetCatalogFilter() return self.Launcher and self.Launcher.Filter:GetValue() or 'All' end
function Hub:SetCatalogFilter(value)
    assert(value=='All' or value=='Favorites' or value=='Current','Catalog filter must be All, Favorites or Current')
    assert(not self.Destroyed and self.Launcher,'Hub has been destroyed')
    self.Launcher.Filter:SetValue(value); return self
end
function Hub:_layoutHubChrome() if self.Launcher then self.Launcher:LayoutChrome() end end
function Hub:_installLauncher(options)
    local hub=self
    local window, tab = hub.Window, hub.Tab
    assert(hub.GameList and hub.ScriptList and hub.PlayButton and hub.CancelButton,
        'A RetroBox carregada não oferece os componentes necessários ao launcher.')
    local textService = game:GetService('TextService')
    local inputService = game:GetService('UserInputService')
    local scope = hub.Scope:Child()
    local launcher = {Hub=hub, Window=window, Scope=scope, UI={}, Expanded=false, _nodes={}}
    local ui = launcher.UI
    local function tr(pt,en) return window:_t17(pt,en) end
    local U2 = UDim2.fromOffset
    local function bounded(value, maximum) return math.max(0,math.min(maximum,value)) end
    local function alive() return not launcher.Destroyed and not hub.Destroyed and not window.Destroyed end
    local function listen(signal, callback) return scope:Add(signal:Connect(callback),'Disconnect') end
    local function bind(object, roles) window:_bind(object,roles) end
    local function node(class, parent, properties, roles)
        local object=Instance.new(class)
        for key,value in pairs(properties or {}) do if key~='Parent' then object[key]=value end end
        object.Parent=parent
        if roles then bind(object,roles) end
        launcher._nodes[#launcher._nodes+1]=object
        return object
    end
    local function panel(parent, name, role, border)
        return node('Frame',parent,{Name=name,BorderSizePixel=border and 1 or 0,BackgroundTransparency=role and 0 or 1,Size=U2(100,100),ClipsDescendants=true},
            role and {BackgroundColor3=role,BorderColor3='Border'} or nil)
    end
    local function label(parent,name,text,size,role)
        local object=node('TextLabel',parent,{Name=name,Text=text or '',Font=window.Font,TextSize=size*(window.TextScale or 1),
            TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd,
            BackgroundTransparency=1,BorderSizePixel=0,RichText=false,Size=U2(100,24)}, {TextColor3=role or 'Text'})
        window._textSizes[object]=size
        return object
    end
    local function scroll(parent,name)
        return node('ScrollingFrame',parent,{Name=name,Size=U2(100,100),CanvasSize=U2(0,0),CanvasPosition=Vector2.new(0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.None,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=4,
            BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,Active=true},{ScrollBarImageColor3='Border'})
    end
    local function dimensionsEqual(a,b)
        return a and b and a.X.Scale==b.X.Scale and a.X.Offset==b.X.Offset and a.Y.Scale==b.Y.Scale and a.Y.Offset==b.Y.Offset
    end
    local function assign(object,property,value)
        if not object or not object.Parent then return end
        if not dimensionsEqual(object[property],value) then object[property]=value end
    end
    local function rect(object,x,y,width,height)
        assign(object,'Position',U2(x,y)); assign(object,'Size',U2(math.max(0,width),math.max(0,height)))
    end
    local function lower(value)
        local result=tostring(value or ''):lower()
        local capitals={['Á']='á',['À']='à',['Â']='â',['Ã']='ã',['É']='é',['Ê']='ê',['Í']='í',['Ó']='ó',['Ô']='ô',['Õ']='õ',['Ú']='ú',['Ü']='ü',['Ç']='ç'}
        for upper,small in pairs(capitals) do result=result:gsub(upper,small) end
        return result
    end
    local function cut(value,limit)
        value=tostring(value or '')
        if #value<=limit then return value end
        local boundary=utf8 and utf8.offset(value,0,limit+1) or limit+1
        return value:sub(1,boundary-1)..'…'
    end
    local function textHeight(text,size,width,maximum)
        local measured=textService:GetTextSize(tostring(text),size*(window.TextScale or 1),window.Font,Vector2.new(math.max(40,width),100000))
        return math.min(maximum or 1600,math.max(size*(window.TextScale or 1)+3,measured.Y+3))
    end
    local function displayName(record) return hub:_displayGameName(record) end
    function launcher:QueueRefresh()
        if not alive() or self._queued then return end
        self._queued=true
        local thread=task.defer(function()
            scope:Remove('refresh',true); self._queued=false
            if alive() then self:Refresh() end
        end)
        scope:Add(thread,function(value) if coroutine.status(value)=='suspended' then task.cancel(value) end end,'refresh')
    end

    ui.Root=panel(tab.Frame,'RetroBoxScriptHub',nil)
    ui.Background=panel(ui.Root,'LauncherBackground','Background')
    ui.Body=scroll(ui.Root,'LibraryBody')
    ui.Navigation=panel(ui.Body,'GameCatalog','Inset',true)
    ui.LibraryTitle=label(ui.Navigation,'LibraryTitle',tr('BIBLIOTECA','LIBRARY'),13,'Text')
    ui.CatalogCount=label(ui.Navigation,'CatalogCount','',10,'Muted')
    ui.Filters=panel(ui.Navigation,'CatalogFilters',nil)
    ui.SortLabel=label(ui.Navigation,'SortLabel','ORGANIZAR',9,'Muted')
    ui.CatalogFooter=label(ui.Navigation,'CatalogFooter','',10,'Muted')
    ui.Details=scroll(ui.Body,'GameDetails')
    ui.Hero=panel(ui.Details,'SelectedGame','Inset',true)
    ui.HeroStrip=panel(ui.Hero,'HeroStrip','Surface')
    ui.HeroAccent=panel(ui.Hero,'HeroAccent','Accent')
    ui.HeroEyebrow=label(ui.HeroStrip,'HeroEyebrow',tr('JOGO SELECIONADO','SELECTED GAME'),10,'Accent')
    ui.Source=label(ui.HeroStrip,'MetadataOrigin',tr('CONSULTANDO ROBLOX','FETCHING ROBLOX DATA'),9,'Muted')
    ui.Source.TextXAlignment=Enum.TextXAlignment.Right
    ui.GameTitle=label(ui.Details,'GameTitle','',24,'Text'); ui.GameTitle.TextWrapped=true; ui.GameTitle.TextYAlignment=Enum.TextYAlignment.Top
    ui.GameContext=label(ui.Details,'GameContext','',10,'Muted')
    ui.Description=label(ui.Details,'GameDescription','',12,'Muted'); ui.Description.TextWrapped=true; ui.Description.TextYAlignment=Enum.TextYAlignment.Top
    ui.GameActions=panel(ui.Details,'GameActions',nil)
    ui.TeleportMessage=label(ui.Details,'TeleportStatus','',11,'Muted'); ui.TeleportMessage.TextWrapped=true
    ui.ScriptHeading=label(ui.Details,'ScriptHeading',tr('SCRIPTS DISPONÍVEIS','AVAILABLE SCRIPTS'),12,'Accent')
    ui.ScriptCount=label(ui.Details,'ScriptCount','',10,'Muted'); ui.ScriptCount.TextXAlignment=Enum.TextXAlignment.Right
    ui.Dock=panel(ui.Root,'ExecutionBar','Surface',true); ui.Dock.ZIndex=10
    ui.DockAccent=panel(ui.Dock,'DockAccent','Accent'); ui.DockAccent.ZIndex=11
    ui.SelectedScript=label(ui.Dock,'SelectedScript','',14,'Text'); ui.SelectedScript.ZIndex=11
    ui.Status=label(ui.Dock,'ExecutionStatus','',11,'Muted'); ui.Status.TextWrapped=true; ui.Status.TextYAlignment=Enum.TextYAlignment.Top; ui.Status.ZIndex=11
    ui.ProgressTrack=panel(ui.Dock,'ProgressTrack','Border'); ui.ProgressTrack.ZIndex=11
    ui.ProgressFill=panel(ui.ProgressTrack,'ProgressFill','Accent'); ui.ProgressFill.ZIndex=12
    ui.Activity=label(ui.Dock,'OtherActivity','',9,'Muted'); ui.Activity.ZIndex=11

    local extra=tab:CreateSection({Title='Launcher',Icon='gamepad'})
    local function extraButton(id,title,icon,callback)
        return extra:AddButton({Id='hub/'..hub.Id..'/launcher/'..id,Title=title,Icon=icon,Persist=false,Callback=callback})
    end
    local filter=extra:AddDropdown({Id='hub/'..hub.Id..'/catalog-filter',Title=tr('Filtro do catálogo','Catalog filter'),Options={'All','Favorites','Current'},Default='All',Visible=false})
    launcher.Filter=filter
    local category=extra:AddDropdown({Id='hub/'..hub.Id..'/catalog-category',Title=tr('Categoria','Category'),Options={'Games','Universal'},Default='Games',Visible=false})
    launcher.Category=category
    local function gamesCategory() if hub:GetSelectedCategory()=='Universal' then category:SetValue('Games') end end
    ui.All=extraButton('all',tr('Todos','All'),false,function() gamesCategory(); filter:SetValue('All') end)
    ui.Favorites=extraButton('favorites',tr('Favoritos','Favorites'),'star',function() gamesCategory(); filter:SetValue('Favorites') end)
    ui.Current=extraButton('current',tr('Atual','Current'),'gamepad',function() gamesCategory(); filter:SetValue('Current') end)
    ui.Universal=extraButton('universals',tr('Scripts universais','Universal scripts'),'code',function() hub:SelectUniversalScripts() end)
    ui.Expand=extraButton('description',tr('Ler descrição','Read description'),'info',function() launcher.Expanded=not launcher.Expanded; launcher:Refresh() end)
    ui.Retry=extraButton('refresh',tr('Atualizar','Refresh'),'refresh',function()
        local selected=hub:GetSelectedGame()
        if not selected then return false,tr('Escolha um jogo.','Choose a game.') end
        local accepted,reason=hub:RefreshGameMetadata(selected.Id)
        hub:RetryThumbnail(selected.Id); launcher:QueueRefresh()
        return accepted,reason
    end)
    ui.Appearance=extraButton('appearance',tr('Tema','Theme'),'palette',function() hub:ShowThemeSettings() end)
    ui.More=extraButton('details',tr('Informações','Information'),'info',function()
        local record=hub:_selectedCatalog(); local spec=hub:GetSelectedScript()
        local status=record and spec and hub:GetScriptStatus(record.Id,spec.Id)
        local source=record
        local parts={record and displayName(record) or tr('Nenhum jogo selecionado','No game selected')}
        if record and record.Description~='' then parts[#parts+1]=record.Description end
        if source and source.Notes~='' then parts[#parts+1]=tr('NOTAS DO HUB\n','HUB NOTES\n')..source.Notes end
        if spec then parts[#parts+1]='SCRIPT\n'..spec.Title..'\n'..spec.Description end
        if status and (status.Message or status.Error) then parts[#parts+1]=tr('EXECUÇÃO\n','EXECUTION\n')..tostring(status.Error or status.Message) end
        window:Dialog({Title=tr('Detalhes','Details'),Content=cut(table.concat(parts,'\n\n'),7800),Icon='info'})
    end)
    local moved={hub.GameSearch,hub.Sort,hub.GameList,hub.GameImage,hub.FavoriteButton,hub.TeleportButton,hub.ScriptSearch,hub.ScriptList,
        hub.PlayButton,hub.CancelButton,ui.All,ui.Favorites,ui.Current,ui.Universal,ui.Expand,ui.Retry,ui.More,ui.Appearance}
    for _,control in ipairs(moved) do
        if control~=hub.Sort then
        function control:_layoutDescription()
            if self.Destroyed or not self.Frame.Parent then return end
            if self.TitleLabel and self.Type~='Button' then self.TitleLabel.Visible=false end
            self.DescriptionLabel.Visible=false; launcher:QueueRefresh()
        end
        end
        control.Frame.AutomaticSize=Enum.AutomaticSize.None
        control.DescriptionLabel.Visible=false
    end
    for _,control in ipairs({ui.All,ui.Favorites,ui.Current,ui.Universal,ui.Expand,ui.Retry,ui.More,ui.Appearance}) do
        control.TitleLabel.Visible=false; control.Frame.BackgroundTransparency=1
        control.Button.Position=U2(0,0); control.Button.Size=UDim2.fromScale(1,1)
        if control._titleIcon and control._titleIcon.Frame then
            control._titleIcon.Frame.Parent=control.Button; control._titleIcon.Frame.Position=UDim2.new(0,8,.5,-8)
            control._titleIcon:SetRole('Text')
        end
        control.Button.Text=control.Title
    end
    local function move(control,parent) control.Frame.Parent=parent; control.Frame.Visible=true end
    move(hub.GameSearch,ui.Navigation); move(hub.Sort,ui.Navigation); move(hub.GameList,ui.Navigation)
    move(hub.GameImage,ui.Hero)
    move(hub.FavoriteButton,ui.GameActions); move(hub.TeleportButton,ui.GameActions)
    move(hub.ScriptSearch,ui.Details); move(hub.ScriptList,ui.Details)
    move(hub.PlayButton,ui.Dock); move(hub.CancelButton,ui.Dock)
    move(ui.All,ui.Filters); move(ui.Favorites,ui.Filters); move(ui.Current,ui.Filters)
    move(ui.Universal,ui.Navigation)
    move(ui.Expand,ui.Details); move(ui.Retry,ui.GameActions); move(ui.More,ui.Dock);move(ui.Appearance,ui.Navigation)
    tab.Container.Visible=false
    hub.GameSearch.Input.PlaceholderText=tr('Buscar jogos…','Search games…')
    hub.ScriptSearch.Input.PlaceholderText=tr('Buscar scripts deste jogo…','Search scripts in this game…')
    hub.GameList.EmptyLabel.Text=tr('Nenhum jogo neste filtro.','No games in this filter.')
    hub.ScriptList.EmptyLabel.Text=tr('Nenhum script encontrado.','No scripts found.')
    hub.GameList.Viewport.BorderSizePixel=0; hub.ScriptList.Viewport.BorderSizePixel=0
    hub.GameImage.Image.ScaleType=Enum.ScaleType.Crop
    for _,control in ipairs({hub.GameDetails,hub.ImageStatus,hub.ScriptDetails,hub.ExecutionStatus}) do control:SetVisible(false) end
    launcher.CoverSkeleton=window:CreateSkeleton({Parent=hub.GameImage.Frame,Lines=3,Cover=true})
    launcher.MetadataSkeleton=window:CreateSkeleton({Parent=ui.Description,Lines=1,Cover=true})
    scope:Add(launcher.CoverSkeleton,'Destroy');scope:Add(launcher.MetadataSkeleton,'Destroy')
    local focusTargets={[hub.GameDetails]=ui.GameTitle,[hub.ImageStatus]=hub.GameImage.Frame,[hub.ScriptDetails]=hub.ScriptList.Frame,[hub.ExecutionStatus]=ui.Dock}
    for control,target in pairs(focusTargets) do control._hubFocusTarget=target end

    -- Keep native TextButton semantics/focus, with a separate padded caption so
    -- pixel icons never overlap a centered caption at narrow/mobile widths.
    local captionControls={ui.All,ui.Favorites,ui.Current,ui.Universal,ui.Expand,ui.Retry,ui.More,ui.Appearance,hub.FavoriteButton,hub.TeleportButton,hub.PlayButton,hub.CancelButton}
    local function syncCaption(control)
        local caption=control._hubCaption
        if not alive() or not caption or not caption.Parent or not control.Frame.Parent then return end
        local icon=control._titleIcon and control._titleIcon.Frame
        local left=icon and icon.Parent and icon.Visible and 30 or 10
        caption.Position=UDim2.new(0,left,0,0); caption.Size=UDim2.new(1,-left-8,1,0)
        caption.Text=control.Button.Text; caption.TextTransparency=control.Disabled and .15 or 0
        local role=(window._skin[control.Button] or {}).TextColor3 or 'Text'
        bind(caption,{TextColor3=role})
        if control.Button.TextTransparency~=1 then control.Button.TextTransparency=1 end
    end
    for _,control in ipairs(captionControls) do
        local caption=label(control.Button,'LauncherCaption',control.Button.Text,control==hub.PlayButton and 13 or 11,'Text')
        caption.ZIndex=control.Button.ZIndex+2;control._hubCaption=caption
        listen(control.Button:GetPropertyChangedSignal('Text'),function() syncCaption(control); launcher:QueueRefresh() end)
        listen(control.Button:GetPropertyChangedSignal('TextTransparency'),function() syncCaption(control) end)
        if control._titleIcon and control._titleIcon.Frame then
            listen(control._titleIcon.Frame:GetPropertyChangedSignal('Visible'),function() syncCaption(control); launcher:QueueRefresh() end)
        end
        syncCaption(control)
    end
    local function captionWidth(control)
        local caption=control._hubCaption; local icon=control._titleIcon and control._titleIcon.Frame
        local left=icon and icon.Parent and icon.Visible and 30 or 10
        local measured=textService:GetTextSize(control.Button.Text,caption.TextSize,caption.Font,Vector2.new(100000,100000))
        return math.ceil(measured.X)+left+10
    end
    local function buttonRows(controls,width)
        local rows={}; local row={Items={},Width=0}
        for _,control in ipairs(controls) do
            local wanted=math.min(width,math.max(56,captionWidth(control)))
            local nextWidth=row.Width+(#row.Items>0 and 6 or 0)+wanted
            if #row.Items>0 and nextWidth>width then rows[#rows+1]=row; row={Items={},Width=0}; nextWidth=wanted end
            row.Items[#row.Items+1]={Control=control,Width=wanted}; row.Width=nextWidth
        end
        if #row.Items>0 then rows[#rows+1]=row end
        return rows
    end
    local function placeButtons(rows,x,y,width,height,fill)
        for _,row in ipairs(rows) do
            local extra=fill and math.max(0,width-row.Width)/#row.Items or 0
            local left=x+(fill and 0 or math.max(0,width-row.Width))
            for _,item in ipairs(row.Items) do
                local wanted=item.Width+extra
                rect(item.Control.Frame,left,y,wanted,height); left=left+wanted+6
            end
            y=y+height+6
        end
    end
    function launcher:ApplyFilter() hub:_filterGames() end
    function launcher:SelectionChanged(previous,id)
        if previous~=id then
            self.Expanded=false; ui.Details.CanvasPosition=Vector2.new(0,0)
            if self.LayoutMode=='stacked' then ui.Body.CanvasPosition=Vector2.new(0,self.NavigationHeight+12) end
        end
        self:QueueRefresh()
    end
    function tab:_layout() if alive() then launcher:Refresh() end end
    function hub.GameList:_renderNode(row,index)
        if not row.Thumb then
            row.Thumb=node('ImageLabel',row.Button,{BackgroundTransparency=1,Image='',ScaleType=Enum.ScaleType.Crop})
            row.Fallback=iconSlot(window,row.Button,'gamepad',nil,24,U2(20,20),'Muted')
        end
        local item=self.Items[index]; local native=hub:_game(item.Id)
        hub:_paintThumbnail(row.Thumb,row.Fallback,native and hub:_requestThumbnail(native))
        local record=hub:GetGame(self.Items[index].Id); if not record then return end
        local selected=self:GetValue()==record.Id
        bind(row.Button,{BackgroundColor3=selected and 'Surface' or 'Inset',BorderColor3=selected and 'Accent' or 'Border'})
        if row.Fallback then row.Fallback:SetRole('Muted') end
        if not row.LauncherTitle then
            row.LauncherTitle=label(row.Button,'GameName','',13,'Text')
            row.LauncherMeta=label(row.Button,'GameSummary','',10,'Muted')
            row.LauncherMark=panel(row.Button,'SelectionMark','Accent')
        end
        row.Labels[1].Visible=false
        rect(row.Thumb,12,12,40,40)
        if row.Fallback and row.Fallback.Frame then row.Fallback.Frame.Position=U2(20,20) end
        local width=math.max(100,row.Button.Size.X.Offset)
        rect(row.LauncherTitle,64,10,width-78,23); rect(row.LauncherMeta,64,36,width-78,18)
        row.LauncherMark.Position=U2(0,8)
        if not row._markReady then row.LauncherMark.Size=U2(3,0);row._markReady=true end
        window:_selectionMotion(row.LauncherMark,selected,U2(3,self.RowHeight-18),U2(3,0),self)
        row.LauncherTitle.Text=(hub:IsFavorite(record.Id) and '★ ' or '')..displayName(record)
        row.LauncherMeta.Text=#record.Scripts..(#record.Scripts==1 and ' script' or ' scripts')..(hub:IsCurrentGame(record.Id) and tr(' · VOCÊ ESTÁ AQUI',' · YOU ARE HERE') or '')
        row.Button.BorderSizePixel=1
        bind(row.Button,{BackgroundColor3=selected and 'Surface' or 'Inset',BorderColor3=selected and 'Accent' or 'Border'})
        bind(row.LauncherTitle,{TextColor3=selected and 'Accent' or 'Text'})
        window:_refreshInk(row.LauncherMeta)
    end
    local states={Available='Disponível',Unavailable=tr('Indisponível','Unavailable'),Queued='Na fila',Running='Executando',Cancelling='Cancelando',Completed='Concluído',Failed='Falha',Cancelled='Cancelado'}
    function hub.ScriptList:_renderNode(row,index)
        local record=hub:_selectedCatalog(); local item=self.Items[index]
        local spec=record and hub:GetScript(record.Id,item.Id); if not spec then return end
        local status=hub:GetScriptStatus(record.Id,spec.Id) or {Status='Unavailable'}
        local selected=self:GetValue()==spec.Id
        bind(row.Button,{BackgroundColor3=selected and 'Surface' or 'Inset',BorderColor3=selected and 'Accent' or 'Border'})
        if not row.ScriptIcon then row.ScriptIcon=iconSlot(window,row.Button,false,nil,20,U2(14,12),'Text') end
        row.ScriptIcon:Set(spec.Icon)
        if not row.LauncherTitle then
            row.LauncherTitle=label(row.Button,'ScriptName','',14,'Text')
            row.LauncherCredit=label(row.Button,'ScriptCredit','',10,'Muted')
            row.LauncherDescription=label(row.Button,'ScriptDescription','',11,'Muted'); row.LauncherDescription.TextWrapped=true; row.LauncherDescription.TextYAlignment=Enum.TextYAlignment.Top
            row.LauncherState=label(row.Button,'ScriptState','',10,'Accent'); row.LauncherState.TextXAlignment=Enum.TextXAlignment.Right
            row.LauncherMark=panel(row.Button,'SelectionMark','Accent')
            row.UniversalTag=label(row.Button,'UniversalTag','UNIVERSAL',9,'AccentText')
            row.UniversalTag.TextXAlignment=Enum.TextXAlignment.Center;row.UniversalTag.BackgroundTransparency=0
            bind(row.UniversalTag,{BackgroundColor3='Accent',TextColor3='AccentText'})
        end
        row.Labels[1].Visible=false
        local width=math.max(100,row.Button.Size.X.Offset); local scale=window.TextScale or 1
        local badgeWidth=record.Universal and math.min(94*scale,(width-64)*.5) or 0
        row.UniversalTag.Visible=record.Universal==true
        rect(row.UniversalTag,width-badgeWidth-12,10,badgeWidth,20*scale)
        rect(row.LauncherTitle,44,10,math.max(20,width-56-(badgeWidth>0 and badgeWidth+8 or 0)),22*scale)
        rect(row.LauncherCredit,44,34*scale,width-56,16*scale)
        rect(row.LauncherDescription,14,55*scale,width-28,32*scale)
        rect(row.LauncherState,width-140,34*scale,126,16*scale)
        row.LauncherMark.Position=U2(0,8)
        if not row._markReady then row.LauncherMark.Size=U2(3,0);row._markReady=true end
        window:_selectionMotion(row.LauncherMark,selected,U2(3,self.RowHeight-18),U2(3,0),self)
        if row.ScriptIcon and row.ScriptIcon.Frame then row.ScriptIcon.Frame.Position=U2(14,12); row.ScriptIcon:SetRole(selected and 'Accent' or 'Text') end
        row.LauncherTitle.Text=spec.Title
        row.LauncherCredit.Text=(spec.Version~='' and 'v'..spec.Version or '')..(spec.Author~='' and ' · '..spec.Author or '')
        row.LauncherCredit.Size=UDim2.new(0,math.max(40,width-200),0,16*scale)
        row.LauncherDescription.Text=spec.Description~='' and spec.Description or tr('Selecione para executar este script.','Select to run this script.')
        row.LauncherState.Text=tr(states[status.Status] or status.Status,status.Status)
        local role=status.Status=='Failed' and 'Danger' or (status.Status=='Unavailable' or status.Status=='Cancelled') and 'Muted' or 'Accent'
        bind(row.LauncherState,{TextColor3=role}); bind(row.LauncherTitle,{TextColor3=selected and 'Accent' or 'Text'})
        row.Button.BorderSizePixel=1
        for _,object in ipairs({row.LauncherTitle,row.LauncherCredit,row.LauncherDescription,row.LauncherState,row.UniversalTag}) do window:_refreshInk(object) end
    end

    function launcher:LayoutChrome()
        if not alive() then return end
        local mobile=window.Mobile; local size=window._logicalSize
        if not size then return end
        window.Nav.Position=U2(12,mobile and 76 or 78); window.Nav.Size=UDim2.new(1,-24,0,36)
        window.NavLayout.FillDirection=Enum.FillDirection.Horizontal
        window.Nav.AutomaticCanvasSize=Enum.AutomaticSize.X; window.Nav.ScrollingDirection=Enum.ScrollingDirection.X
        for _,page in ipairs(window.Tabs) do
            local measured=textService:GetTextSize(page.Label.Text,page.Label.TextSize,page.Label.Font,Vector2.new(100000,100000))
            local padding=page.Label.Position.X.Offset+10
            local wanted=math.max(mobile and 132 or 148,math.ceil(measured.X)+padding)
            page.Button.Size=U2(math.min(math.max(132,size.X-24),wanted),34)
        end
        window.SearchContainer.Position=UDim2.new(1,-272,0,43); window.SearchContainer.Size=U2(258,28)
        window.SearchContainer.Visible=not mobile and not window.Minimized
        window.Search.PlaceholderText=tr('Buscar funções e ferramentas…','Search controls and tools…')
        window.SubtitleLabel.Size=UDim2.new(1,mobile and -28 or -300,0,22)
        if window.PixelMotif then window.PixelMotif.Visible=false end
        window.PageHost.Position=U2(12,120); window.PageHost.Size=UDim2.new(1,-24,1,-184)
        tab.Container.Visible=false
    end
    local function fitList(control,x,y,width,height,rowHeight)
        rect(control.Frame,x,y,width,math.max(36,height)); control.RowHeight=rowHeight
        control.TitleLabel.Visible=false; control.DescriptionLabel.Visible=false
        control.Viewport.Position=U2(0,0); control.Viewport.Size=UDim2.fromScale(1,1)
        control:_render()
    end
    function launcher:Layout()
        if not alive() or self._layingOut then return end
        self._layingOut=true
        self:LayoutChrome()
        local scale=math.max(.01,window._actualScale or 1); local ts=window.TextScale or 1
        local size=tab.Frame.AbsoluteSize; local width,height=math.max(240,size.X/scale),math.max(1,size.Y/scale)
        local gap=12; local touch=inputService.TouchEnabled
        local buttonHeight=math.max(touch and 42 or 38,math.ceil(13*ts+20))
        local actions={hub.PlayButton}; if hub.CancelButton.Frame.Visible then actions[#actions+1]=hub.CancelButton end; actions[#actions+1]=ui.More
        local dockRows=buttonRows(actions,width-24)
        local sideBySide=#dockRows==1 and width>=620 and width-dockRows[1].Width-48>=180*math.max(1,ts)
        local actionsHeight=#dockRows*buttonHeight+(#dockRows-1)*6
        local titleHeight,statusHeight=math.ceil(22*ts),math.ceil(26*ts)
        local dockWanted=sideBySide and math.ceil(104*math.max(1,ts)) or 10+titleHeight+4+statusHeight+10+actionsHeight+12
        local dockHeight=math.min(height,dockWanted)
        local bodyHeight=math.max(0,height-dockHeight-gap)
        rect(ui.Root,0,0,width,height); rect(ui.Background,0,0,width,height); rect(ui.Body,0,0,width,bodyHeight)
        ui.Body.Visible=bodyHeight>0
        local columns=width>=hub.StackAt*math.max(1,ts) and bodyHeight>=240*math.max(1,ts); self.LayoutMode=columns and 'columns' or 'stacked'; hub.LayoutMode=self.LayoutMode
        local navWidth=columns and math.max(238,math.floor(width*hub.NavigationRatio)) or width
        local inputHeight=math.max(touch and 42 or 34,math.ceil(20*ts+10)); local filterHeight=math.max(touch and 42 or 30,math.ceil(11*ts+14))
        local sortWidth=math.min(navWidth-24,math.max(110,math.ceil(textService:GetTextSize(hub.Sort.Button.Text,hub.Sort.Button.TextSize,window.Font,Vector2.new(100000,100000)).X)+40))
        local libraryWidth=textService:GetTextSize(ui.LibraryTitle.Text,ui.LibraryTitle.TextSize,window.Font,Vector2.new(100000,100000)).X
        local headerStacked=libraryWidth+sortWidth+40>navWidth
        local sortY=headerStacked and 12+math.ceil(22*ts)+6 or 8
        local searchY=sortY+inputHeight+8
        local filtersY=searchY+inputHeight+8
        local filterRows=buttonRows({ui.All,ui.Favorites,ui.Current},navWidth-24)
        local filtersHeight=#filterRows*filterHeight+(#filterRows-1)*6
        local universalVisible=hub._universalConfigured or #hub:GetUniversalScripts()>0
        ui.Universal.Frame.Visible=universalVisible
        local universalY=filtersY+filtersHeight+8
        local navHeader=filtersY+filtersHeight-6+(universalVisible and filterHeight+10 or 0)
        local rowHeight=math.ceil(60*ts)
        local footerHeight=touch and 56 or 44
        local navHeight=columns and bodyHeight or navHeader+math.min(3,hub.GameListMaxRows,math.max(1,hub.GameList:GetViewStats().Filtered))*rowHeight+footerHeight+16
        navHeight=math.max(navHeader+64,navHeight); self.NavigationHeight=navHeight
        rect(ui.Navigation,0,0,navWidth,navHeight)
        rect(ui.LibraryTitle,14,12,headerStacked and navWidth-28 or navWidth-sortWidth-34,math.ceil(22*ts)); ui.CatalogCount.Visible=false; ui.SortLabel.Visible=false
        rect(hub.GameSearch.Frame,12,searchY,navWidth-24,inputHeight)
        rect(ui.Filters,12,filtersY,navWidth-24,filtersHeight)
        if universalVisible then rect(ui.Universal.Frame,12,universalY,navWidth-24,filterHeight) end
        placeButtons(filterRows,0,0,navWidth-24,filterHeight,true)
        rect(hub.Sort.Frame,navWidth-sortWidth-12,sortY,sortWidth,inputHeight)
        hub.Sort.Button.Size=UDim2.new(1,0,0,inputHeight)
        for _,child in ipairs(hub.Sort.Frame:GetChildren()) do
            if child.ClassName=='Frame' and child.Size.Y.Offset==184 then child.Position=U2(0,inputHeight+4) end
        end
        local gameListHeight=math.min(navHeight-navHeader-footerHeight-16,math.max(1,math.min(hub.GameListMaxRows,hub.GameList:GetViewStats().Filtered))*rowHeight+4)
        fitList(hub.GameList,10,navHeader+14,navWidth-20,gameListHeight,rowHeight)
        rect(ui.CatalogFooter,14,navHeight-footerHeight+8,navWidth-114,footerHeight-14);ui.CatalogFooter.TextWrapped=true
        rect(ui.Appearance.Frame,navWidth-90,navHeight-footerHeight+6,78,footerHeight-12)
        local rightX=columns and navWidth+gap or 0; local rightY=columns and 0 or navHeight+gap
        local rightWidth=columns and width-navWidth-gap or width
        rect(ui.Details,rightX,rightY,rightWidth,columns and bodyHeight or 100)
        local innerWidth=rightWidth-8
        local split=innerWidth>=540
        self.HeroMode=split and 'split' or 'cover'
        local imageWidth=split and math.floor(innerWidth*.39) or innerWidth-2
        local infoWidth=split and innerWidth-imageWidth-28 or innerWidth
        local infoX=split and imageWidth+14 or 0
        local parent=split and ui.Hero or ui.Details
        for _,object in ipairs({ui.GameTitle,ui.GameContext,ui.Description,ui.GameActions,ui.TeleportMessage,ui.Expand.Frame}) do if object.Parent~=parent then object.Parent=parent end end
        local heroHeight=split and 194 or math.floor(math.max(110,math.min(176,bodyHeight*.38,innerWidth/2.75)))
        local y=split and 39 or heroHeight+14
        local nameHeight=textHeight(ui.GameTitle.Text,24,infoWidth,split and 56*ts or 70*ts)
        rect(ui.GameTitle,infoX,y,infoWidth,nameHeight); y=y+nameHeight+3
        rect(ui.GameContext,infoX,y,infoWidth,18*ts); y=y+23*ts
        local fullDescriptionHeight=textHeight(ui.Description.Text,12,infoWidth)
        local needsExpand=fullDescriptionHeight>36*ts
        ui.Expand.Frame.Visible=needsExpand
        local descriptionHeight=self.Expanded and fullDescriptionHeight or math.min(fullDescriptionHeight,36*ts)
        rect(ui.Description,infoX,y,infoWidth,descriptionHeight); y=y+descriptionHeight+6
        if needsExpand then rect(ui.Expand.Frame,infoX,y,math.min(infoWidth,math.max(152,captionWidth(ui.Expand))),math.max(26,math.ceil(11*ts+12))); y=y+ui.Expand.Frame.Size.Y.Offset+4 end
        local actionHeight=touch and 42 or 34
        local universal=hub:GetSelectedCategory()=='Universal'
        ui.GameActions.Visible=not universal
        local gameActionRows=buttonRows({hub.FavoriteButton,hub.TeleportButton,ui.Retry},infoWidth)
        local gameActionsHeight=#gameActionRows*actionHeight+(#gameActionRows-1)*6
        rect(ui.GameActions,infoX,y,infoWidth,universal and 0 or gameActionsHeight)
        placeButtons(gameActionRows,0,0,infoWidth,actionHeight,true)
        if not universal then y=y+gameActionsHeight+8 end
        local teleportText=not universal and hub.TeleportStatus:GetValue() or ''
        ui.TeleportMessage.Visible=teleportText~=''; ui.TeleportMessage.Text=teleportText
        if teleportText~='' then
            local teleportHeight=textHeight(teleportText,11,infoWidth,80*ts)
            rect(ui.TeleportMessage,infoX,y,infoWidth,teleportHeight); y=y+teleportHeight+8
        end
        if split then heroHeight=math.max(heroHeight,y+6); y=heroHeight+16 else y=y+10 end
        rect(ui.Hero,0,0,innerWidth,heroHeight)
        rect(ui.HeroStrip,0,0,innerWidth,28);rect(ui.HeroAccent,0,0,innerWidth,2)
        rect(ui.HeroEyebrow,12,0,math.max(40,innerWidth-208),28)
        rect(ui.Source,innerWidth-184,0,172,28)
        rect(hub.GameImage.Frame,1,28,imageWidth,math.min(heroHeight-29,self.Expanded and 256 or heroHeight-29))
        hub.GameImage.Image.Position=U2(0,0); hub.GameImage.Image.Size=UDim2.fromScale(1,1)
        rect(ui.ScriptHeading,0,y,innerWidth-52,22*ts); rect(ui.ScriptCount,innerWidth-48,y,48,22*ts); y=y+30*ts
        local selected=hub:GetSelectedGame(); local scriptCount=selected and #selected.Scripts or 0
        local search=scriptCount>3 or hub.ScriptSearch:GetValue()~=''
        hub.ScriptSearch.Frame.Visible=search
        if search then rect(hub.ScriptSearch.Frame,0,y,innerWidth,34); y=y+42 end
        local scriptHeight=math.ceil(102*ts); local filtered=math.max(1,hub.ScriptList:GetViewStats().Filtered)
        local listHeight=math.min(filtered,hub.ScriptListMaxRows)*scriptHeight+4
        fitList(hub.ScriptList,0,y,innerWidth,listHeight,scriptHeight); y=y+listHeight+12
        ui.Details.CanvasSize=U2(0,y)
        if not columns then rect(ui.Details,rightX,rightY,rightWidth,y); ui.Details.ScrollingEnabled=false; ui.Details.ScrollBarThickness=0
        else ui.Details.ScrollingEnabled=true; ui.Details.ScrollBarThickness=4 end
        ui.Body.CanvasSize=U2(0,columns and bodyHeight or rightY+y)
        ui.Body.ScrollingEnabled=not columns; ui.Body.ScrollBarThickness=columns and 0 or 4
        if columns then ui.Body.CanvasPosition=Vector2.new(0,0) end
        rect(ui.Dock,0,height-dockHeight,width,dockHeight); rect(ui.DockAccent,0,0,width,2)
        ui.Activity.Visible=sideBySide; ui.Status.Visible=true
        if not sideBySide then
            local yButton=math.max(0,dockHeight-actionsHeight-12)
            rect(ui.SelectedScript,12,8,width-24,math.min(titleHeight,math.max(0,yButton-12)))
            local statusY=12+titleHeight
            rect(ui.Status,12,statusY,width-24,math.max(0,math.min(statusHeight,yButton-statusY-6)))
            ui.Status.Visible=ui.Status.Size.Y.Offset>0
            placeButtons(dockRows,12,yButton,width-24,buttonHeight,true)
        else
            local right=dockRows[1].Width
            rect(ui.SelectedScript,16,12,width-right-48,24*ts)
            rect(ui.Status,16,40*ts,width-right-48,30*ts)
            rect(ui.Activity,16,dockHeight-22,width-right-48,14)
            placeButtons(dockRows,width-right-16,16,right,buttonHeight,false)
        end
        rect(ui.ProgressTrack,12,dockHeight-5,width-24,3)
        self._layingOut=false
    end
    function launcher:Refresh()
        if not alive() or self._refreshing then return end; self._refreshing=true
        local record=hub:_selectedCatalog(); local spec=hub:GetSelectedScript()
        local entries=hub:GetGames(); local universal=hub:GetSelectedCategory()=='Universal'
        local universals=hub:GetUniversalScripts(); local scripts,running=#universals,0
        for _,item in ipairs(universals) do
            local status=hub:GetUniversalScriptStatus(item.Id)
            if status and (status.Status=='Running' or status.Status=='Queued' or status.Status=='Cancelling') then running=running+1 end
        end
        for _,entry in ipairs(entries) do scripts=scripts+#entry.Scripts
            for _,script in ipairs(entry.Scripts) do
                local status=hub:GetScriptStatus(entry.Id,script.Id)
                if status and (status.Status=='Running' or status.Status=='Queued' or status.Status=='Cancelling') then running=running+1 end
            end
        end
        ui.CatalogCount.Text=#entries..' JOGOS / '..scripts..' SCRIPTS'
        local view=hub.GameList:GetViewStats()
        ui.CatalogFooter.Text=view.Filtered..tr(' de ',' of ')..#entries..tr(' jogos',' games')..(filter:GetValue()~='All' and ' · '..({All=tr('Todos','All'),Favorites=tr('Favoritos','Favorites'),Current=tr('Jogo atual','Current game')})[filter:GetValue()] or ' · '..scripts..' scripts')
        for _,entry in ipairs({{ui.All,'All'},{ui.Favorites,'Favorites'},{ui.Current,'Current'}}) do
            local selected=filter:GetValue()==entry[2]
            bind(entry[1].Button,{BackgroundColor3=selected and 'Accent' or 'Surface',TextColor3=selected and 'AccentText' or 'Text'})
            syncCaption(entry[1])
            if entry[1]._titleIcon then entry[1]._titleIcon:SetRole(selected and 'AccentText' or 'Text') end
        end
        ui.Universal.Button.Text=tr('Scripts universais','Universal scripts')..' · '..#universals
        bind(ui.Universal.Button,{BackgroundColor3=universal and 'Accent' or 'Surface',TextColor3=universal and 'AccentText' or 'Text',BorderColor3='Accent'})
        ui.Universal.Button.BorderSizePixel=1
        if ui.Universal._titleIcon then ui.Universal._titleIcon:SetRole(universal and 'AccentText' or 'Text') end
        ui.HeroEyebrow.Text=universal and tr('CATÁLOGO UNIVERSAL','UNIVERSAL CATALOG') or tr('JOGO SELECIONADO','SELECTED GAME')
        ui.ScriptHeading.Text=universal and tr('SCRIPTS UNIVERSAIS','UNIVERSAL SCRIPTS') or tr('SCRIPTS DISPONÍVEIS','AVAILABLE SCRIPTS')
        hub.ScriptSearch.Input.PlaceholderText=universal and tr('Buscar scripts universais…','Search universal scripts…') or tr('Buscar scripts deste jogo…','Search scripts in this game…')
        ui.GameTitle.Text=displayName(record)
        ui.GameContext.Text=record and ((hub:IsCurrentGame(record.Id) and tr('JOGO ATUAL  ·  ','CURRENT GAME  ·  ') or '')..#record.Scripts..(#record.Scripts==1 and tr(' script cadastrado no hub',' script in this hub') or tr(' scripts cadastrados no hub',' scripts in this hub'))) or tr('Explore a biblioteca à esquerda.','Explore the game library.')
        if universal then ui.GameContext.Text=#universals..tr(' scripts · SEM VÍNCULO COM UM JOGO',' scripts · NO GAME ASSOCIATION') end
        local metadata=not universal and record and hub:GetGameMetadataStatus(record.Id) or {State='Idle'}
        local source=record and hub:_game(record.Id) or {}
        local manual=source._metadataManual and (source._metadataManual.Name or source._metadataManual.Description)
        local loading=metadata.State=='Queued' or metadata.State=='Loading'
        local errorState=metadata.State=='Unavailable'
        self.MetadataSkeleton:SetVisible(loading and not (source._metadataManual and source._metadataManual.Description))
        local thumb=record and not universal and hub._thumbs[hub:_thumbnailURI(source,true)]
        self.CoverSkeleton:SetVisible(thumb and thumb.Status=='Loading' or false)
        ui.Source.Text=universal and tr('UNIVERSAL','UNIVERSAL') or manual and tr('PERSONALIZADO','CUSTOMIZED') or loading and tr('CONSULTANDO ROBLOX','FETCHING ROBLOX DATA') or errorState and tr('DADOS INDISPONÍVEIS','DATA UNAVAILABLE') or metadata.State=='Partial' and tr('DADOS PARCIAIS','PARTIAL DATA') or metadata.Source=='Provider' and tr('DADOS DO PROVEDOR','PROVIDER DATA') or record and tr('DADOS DO ROBLOX','ROBLOX DATA') or tr('SEM SELEÇÃO','NO SELECTION')
        bind(ui.Source,{TextColor3=errorState and 'Danger' or loading and 'Muted' or 'Accent'})
        ui.Description.Text=record and record.Description~='' and record.Description or loading and tr('Carregando a descrição do jogo…','Loading game description…')
            or errorState and tr('O Roblox não retornou as informações. Tente atualizar; os scripts continuam disponíveis.','Roblox did not return game details. Try refreshing; scripts are still available.') or tr('Este jogo não possui uma descrição disponível.','This game has no description available.')
        local long=#ui.Description.Text>180 or ui.Description.Text:find('\n',1,true)~=nil
        ui.Expand.Frame.Visible=long; ui.Expand.Button.Text=self.Expanded and tr('Recolher descrição','Collapse description') or tr('Ler descrição','Read description')
        ui.Description.TextTruncate=self.Expanded and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd
        ui.Retry:SetDisabled(universal or not record or loading)
        ui.ScriptCount.Text=record and tostring(#record.Scripts) or '0'
        local status=record and spec and hub:GetScriptStatus(record.Id,spec.Id) or {Status='Unavailable'}
        local busy=status.Status=='Running' or status.Status=='Queued' or status.Status=='Cancelling'
        ui.SelectedScript.Text=spec and spec.Title or tr('Selecione um script','Select a script')
        local message=status.Error or status.Message
        ui.Status.Text=(tr(states[status.Status] or status.Status,status.Status))..(message and message~='' and ' · '..message or '')
        if spec and status.Status=='Available' then ui.Status.Text=tr('Pronto para executar','Ready to run')..(spec.Version~='' and ' · v'..spec.Version or '') end
        if status.Status=='Unavailable' and record and spec then local _,reason=hub:IsScriptAvailable(record.Id,spec.Id); ui.Status.Text=tostring(reason or tr('Indisponível','Unavailable')) end
        bind(ui.Status,{TextColor3=status.Status=='Failed' and 'Danger' or busy and 'Accent' or 'Muted'})
        ui.Activity.Text=running>0 and (running..(running==1 and tr(' execução em andamento',' active run') or tr(' execuções em andamento',' active runs'))) or tr('Selecionar e pesquisar não executa scripts.','Selecting and searching do not run scripts.')
        local progress=(busy or status.Status=='Completed') and status.Progress or 0
        window:_motion(ui.ProgressFill,{Size=UDim2.new(bounded(progress or 0,1),0,1,0)},.16,'execution-progress',hub)
        bind(ui.ProgressFill,{BackgroundColor3=status.Status=='Failed' and 'Danger' or 'Accent'})
        hub.FavoriteButton.Button.Text=record and hub:IsFavorite(record.Id) and tr('Favorito','Favorited') or tr('Favoritar','Favorite')
        hub.TeleportButton.Button.Text=tr('Entrar','Join')
        hub.PlayButton.Button.Text=busy and tr('Executando…','Running…') or tr('Executar script','Run script')
        hub.CancelButton.Button.Text=status.Status=='Cancelling' and tr('Cancelando…','Cancelling…') or tr('Cancelar','Cancel')
        for _,control in ipairs(captionControls) do syncCaption(control) end
        self._refreshing=false
        self:Layout()
        local identity=record and record.Id..'/'..record.Name or ''
        if identity~=self._motionIdentity then
            self._motionIdentity=identity
            for _,text in ipairs({ui.GameTitle,ui.GameContext,ui.Description}) do window:_revealText(text,hub,'game-enter') end
        end
        local scriptIdentity=spec and identity..'/'..spec.Id or ''
        local image=hub.GameImage.Image
        if image.Visible and image.Image~='' and image.Image~=self._motionImage then self._motionImage=image.Image;window:_revealText(image,hub,'cover-enter') end
        if scriptIdentity~=self._motionScript then self._motionScript=scriptIdentity;window:_revealText(ui.SelectedScript,hub,'script-enter') end
    end
    -- Subscriptions are disposable resources; no polling loop is needed.
    scope:Add(window:GetFlagState(filter.Id):Subscribe(function() launcher:ApplyFilter() end),'Disconnect')
    scope:Add(window:GetFlagState(category.Id):Subscribe(function(value)
        if not alive() or hub._selecting then return end
        if value=='Universal' then hub:SelectUniversalScripts()
        elseif hub:GetSelectedCategory()=='Universal' then
            hub._selectedScripts[UNIVERSAL_KEY]=hub.ScriptList:GetValue()
            hub.SelectedCategory='Games';hub.SelectedGameId=hub._lastSelectedGameId
            if hub.SelectedGameId and hub:_game(hub.SelectedGameId) then hub:SelectGame(hub.SelectedGameId) else hub:_afterCatalog() end
        end
    end),'Disconnect')
    listen(ui.Root.Destroying,function() if alive() then hub:Destroy() end end)
    listen(hub.GameDetails.TitleLabel:GetPropertyChangedSignal('Text'),function() launcher:QueueRefresh() end)
    listen(hub.ExecutionStatus.TitleLabel:GetPropertyChangedSignal('Text'),function() launcher:QueueRefresh() end)
    listen(hub.TeleportStatus.TitleLabel:GetPropertyChangedSignal('Text'),function() launcher:QueueRefresh() end)
    listen(hub.Sort.Frame:GetPropertyChangedSignal('Size'),function() launcher:QueueRefresh() end)
    listen(tab.Frame:GetPropertyChangedSignal('AbsoluteSize'),function() launcher:QueueRefresh() end)
    listen(window.TitleLabel:GetPropertyChangedSignal('TextSize'),function() launcher:QueueRefresh() end)
    scope:Add(function()
        if launcher.Destroyed then return end
        launcher.Destroyed=true; launcher._queued=false
        window:_forgetSkin(ui.Root)
        for control in pairs(focusTargets) do control._hubFocusTarget=nil end
        launcher._nodes={}; launcher.Filter=nil;launcher.Category=nil;launcher.CoverSkeleton=nil;launcher.MetadataSkeleton=nil
        if hub.Launcher==launcher then hub.Launcher=nil end
        for _,control in ipairs(captionControls) do control._hubCaption=nil end
        for name in pairs(ui) do ui[name]=nil end
    end,nil,'release')
    hub.Launcher=launcher
    hub.NavigationScroll=ui.Navigation; hub.DetailsScroll=ui.Details
    tab.Frame.CanvasPosition=Vector2.new(0,0); tab.Frame.CanvasSize=U2(0,0)
    tab.Frame.AutomaticCanvasSize=Enum.AutomaticSize.None; tab.Frame.ScrollingEnabled=false; tab.Frame.ScrollBarThickness=0
    launcher:ApplyFilter(); window:_layout(); launcher:Refresh()
    return launcher
end
