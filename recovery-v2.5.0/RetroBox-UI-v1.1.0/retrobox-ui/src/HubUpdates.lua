-- Embedded inside the Script Hub scope, after its existing catalog methods.
local gameFields={Id=true,Name=true,PlaceId=true,UniverseId=true,Description=true,Image=true,Order=true,Scripts=true,FallbackName=true,Notes=true}
local scriptFields={Id=true,Title=true,Description=true,Icon=true,Author=true,Version=true,Status=true,Enabled=true,CurrentGameOnly=true,Requires=true,Confirm=true,Action=true}
local universalFields={Name=true};for name in pairs(scriptFields) do universalFields[name]=true end
local function declarative(record,fields,label)
    assert(type(record)=="table",label.." must be a record")
    for field,value in pairs(record) do
        assert(fields[field],"Unknown "..label.." field: "..tostring(field))
        assert(type(value)~="function" and type(value)~="thread" and typeof(value)~="Instance","Catalogs cannot contain executable values")
    end
end
function Hub:_prepareUniversalCatalog(values)
    local records,ids={},{}
    for _,item in ipairs(array(values,128,'UniversalScripts')) do
        declarative(item,universalFields,'universal script')
        assert(item.Enabled==nil or type(item.Enabled)=='boolean','Catalog Enabled must be boolean')
        assert(item.Icon==nil or type(item.Icon)=='string','Catalog Icon must be text')
        local old=self:_script(UNIVERSAL_KEY,item.Id)
        local value={};for k,v in pairs(old and old._definition or {}) do value[k]=k=='Requires' and copy(v) or v end
        for k,v in pairs(item) do if k~='Action' then value[k]=copy(v) end end
        if item.Title~=nil and item.Name==nil then value.Name=nil end
        if item.Action then key(item.Action,'Action');value.Callback=self._catalogActions[item.Action];value.URL=nil end
        local spec=normalizeUniversalScript(value,true)
        assert(not ids[spec.Id],'Duplicate universal script Id: '..spec.Id)
        ids[spec.Id]=true;records[#records+1]=spec
    end
    return records
end
function Hub:_prepareCatalog(document)
    assert(not self.Destroyed,"Hub has been destroyed")
    assert(document.SchemaVersion==1 and document.Kind=="HubCatalog" and document.HubId==self.Id,"Catalog belongs to a different hub or protocol")
    local fields={SchemaVersion=true,Kind=true,HubId=true,Version=true,Games=true,UniversalScripts=true}
    for name in pairs(document) do assert(fields[name],"Unknown catalog field: "..tostring(name)) end
    UpdateCore.ParseVersion(document.Version)
    local entries={}
    for index,value in ipairs(array(document.Games,512,"Games")) do
        declarative(value,gameFields,"game")
        assert(self._metadata.Settings.Enabled or type(value.Name)=='string' and #value.Name>0,'Catalog Name is required when GameMetadata is disabled')
        local rec={}; for k,v in pairs(value) do if k~="Scripts" then rec[k]=copy(v) end end; rec.Scripts={}
        for _,item in ipairs(array(value.Scripts or {},128,"Scripts")) do
            declarative(item,scriptFields,"script")
            assert(item.Enabled==nil or type(item.Enabled)=="boolean","Catalog Enabled must be boolean")
            assert(item.Icon==nil or type(item.Icon)=="string","Catalog Icon must be text")
            local spec={}; for k,v in pairs(item) do if k~="Action" then spec[k]=copy(v) end end
            local old=self:_script(value.Id,item.Id)
            if item.Action then
                key(item.Action,"Action")
                spec.Callback=self._catalogActions[item.Action]
            elseif old then
                spec.Callback=old.Callback;spec.SourceURL=old.SourceURL
                if item.Enabled==nil then spec.Enabled=old.Enabled end
                if item.Confirm==nil then spec.Confirm=old.Confirm end
                if item.Requires==nil then spec.Requires=old.Requires end
            end
            rec.Scripts[#rec.Scripts+1]=spec
        end
        entries[index]=rec
    end
    local games=normalizeGames(entries)
    local universals=document.UniversalScripts~=nil and self:_prepareUniversalCatalog(document.UniversalScripts) or nil
    self:_checkUniversalCount(universals and #universals or #self._universal.Scripts,games)
    return games,universals
end
function Hub:GetVersion() return self.Version end
function Hub:GetUpdateStatus()
    return {Version=self.Version,CatalogVersion=self.CatalogVersion,LibraryVersion=Library.Version,
        Catalog=self._catalogUpdater and self._catalogUpdater:GetStatus() or {State="Disabled"},
        Code=self._codeUpdater and self._codeUpdater:GetStatus() or {State="Disabled"}}
end
function Hub:CheckForUpdates()
    if self.Destroyed then return nil,"Hub has been destroyed" end
    local errors={}
    for _,updater in ipairs({self._catalogUpdater or false,self._codeUpdater or false}) do
        if updater then local _,reason=updater:Check(); if reason then errors[#errors+1]=reason end end
    end
    return self:GetUpdateStatus(),#errors>0 and table.concat(errors,"\n") or nil
end
function Hub:SetUpdateChannel(value,version)
    assert(not self.Destroyed,"Hub has been destroyed")
    assert(value=="stable" or value=="preview" or value=="pinned","Unknown update channel")
    if version then UpdateCore.ParseVersion(version) end
    for _,updater in ipairs({self._catalogUpdater or false,self._codeUpdater or false}) do assert(not updater or not updater._busy,"Cannot change channel during an update operation") end
    if value=="pinned" then
        for _,updater in ipairs({self._catalogUpdater or false,self._codeUpdater or false}) do assert(not updater or version or updater.Options.Version,"Pinned needs Version") end
    end
    for _,updater in ipairs({self._catalogUpdater or false,self._codeUpdater or false}) do if updater then updater:SetChannel(value,version) end end
    return self
end
function Hub:ReloadCatalog(context)
    if self.Destroyed then return false,"Hub has been destroyed" end
    if not self._catalogUpdater then return false,"Catalog updates are not configured" end
    if self._reloadingCatalog then return false,"Catalog update is already running" end
    self._reloadingCatalog=true
    local ok,reason=pcall(function()
        if context then context:ThrowIfCancelled() end
        self._preparedCatalog=nil;self._preparedUniversals=nil
        local document,report=self._catalogUpdater:Load("json")
        assert(document,report)
        assert(not self.Destroyed,"Hub was destroyed during the update")
        if context then context:ThrowIfCancelled() end
        local initial,universals=self._preparedCatalog,self._preparedUniversals
        if not initial then initial,universals=self:_prepareCatalog(document) end
        local games,order={},{}
        for _,rec in ipairs(initial) do games[rec.Id]=rec; order[#order+1]=rec.Id end
        -- Validation is complete. Mutate the catalog once and keep native controls.
        for id in pairs(self._games) do self:_cancelScripts(id) end
        local statuses={}
        if universals~=nil then
            self:_cancelScripts(UNIVERSAL_KEY);self._universal=newUniversalRecord(self,universals);self._universalConfigured=true
        else
            for name,status in pairs(self._scriptStatus) do if name:sub(1,#UNIVERSAL_KEY+1)==UNIVERSAL_KEY..'/' then statuses[name]=status end end
        end
        self._games,self._order=games,order; self._scriptStatus=statuses; self.CatalogVersion=document.Version
        self:_afterCatalog()
        return report
    end)
    self._preparedCatalog=nil;self._preparedUniversals=nil; self._reloadingCatalog=false
    if not ok then self._catalogUpdater.Report.State="Failed"; self._catalogUpdater.Report.Error=tostring(reason); return false,tostring(reason) end
    return true,reason
end
function Hub:_setupUpdates(options)
    self.Version=options.Version or "1.0.0"; self.CatalogVersion=options.CatalogVersion or self.Version
    self._catalogActions={}
    for name,callback in pairs(options.Actions or {}) do key(name,"Action"); assert(type(callback)=="function","Actions must contain developer callbacks"); self._catalogActions[name]=callback end
    local function configured(value,kind,current)
        assert(type(value)=="table","Update settings must be a table")
        local settings={}; for k,v in pairs(value) do settings[k]=v end
        settings.Kind=kind; settings.Major=value.Major or 1; settings.APIVersion=1; settings.HubId=self.Id
        settings.CurrentVersion=current; settings.LibraryVersion=Library.Version; settings.LibraryAPIVersion=Library.APIVersion
        return settings
    end
    if options.CatalogUpdate then
        local settings=configured(options.CatalogUpdate,"HubCatalog",self.CatalogVersion)
        settings.ValidateData=function(document) self._preparedCatalog,self._preparedUniversals=self:_prepareCatalog(document); return true end
        self._catalogUpdater=UpdateCore.New(settings)
    end
    if options.CodeUpdate then self._codeUpdater=UpdateCore.New(configured(options.CodeUpdate,"Hub",self.Version)) end
end
function Hub:SelectScript(id)
    local selectedKey=self:_selectedKey()
    if not self:_script(selectedKey,id) then return false,"Script is unavailable" end
    self.ScriptList:SetValue(id); self._selectedScripts[selectedKey]=id; self:_refreshScriptDetails(); return true
end
function Hub:GetSelectedScript() return self:GetScript(self:_selectedKey(),self.ScriptList:GetValue()) end
function Hub:_layoutHub()
    if self.Launcher then self.Launcher:QueueRefresh() end
end
local function compact(control,target,kind)
    function control:_layoutDescription()
        if self.Destroyed then return end
        self.TitleLabel.Visible=false; self.DescriptionLabel.Visible=false
        if self._titleIcon and self._titleIcon.Frame then
            if kind=="button" then
                self._titleIcon.Frame.Parent=target; self._titleIcon.Frame.Position=UDim2.new(0,10,.5,-8); self._titleIcon.Frame.Visible=true
            else self._titleIcon.Frame.Visible=false end
        end
        local height=math.ceil((kind=="button" and 36 or 34)*(self._window.TextScale or 1))
        if UserInputService.TouchEnabled then height=math.max(44,height) end
        self.Frame.Size=UDim2.new(self.Frame.Size.X.Scale,self.Frame.Size.X.Offset,0,height)
        self._rowHeight=height; target.Position=U2(0,0); target.Size=UDim2.fromScale(1,1)
        if self._section._isRow then self._section:_layout() end
    end
    control:_layoutDescription()
end
function Hub:_installResponsiveLayout(options)
    local tab,window=self.Tab,self.Window; local hub=self
    self.ScriptListMaxRows=options.ScriptListMaxRows or 4; self.GameListMaxRows=options.GameListMaxRows or 7
    assert(finite(self.ScriptListMaxRows) and self.ScriptListMaxRows%1==0 and self.ScriptListMaxRows>=1 and self.ScriptListMaxRows<=12,"ScriptListMaxRows must be 1–12")
    assert(finite(self.GameListMaxRows) and self.GameListMaxRows%1==0 and self.GameListMaxRows>=2 and self.GameListMaxRows<=16,"GameListMaxRows must be 2–16")
    self.NavigationRatio=options.NavigationRatio or .31; self.StackAt=options.StackAt or 700
    assert(finite(self.NavigationRatio) and self.NavigationRatio>=.3 and self.NavigationRatio<=.55,"NavigationRatio must be .3–.55")
    assert(finite(self.StackAt) and self.StackAt>=480 and self.StackAt<=1000,"Hub StackAt must be 480–1000")
    for _,control in ipairs({self.GameList,self.ScriptList,self.GameImage}) do
        control.TitleLabel.Visible=false; control.DescriptionLabel.Visible=false
        function control:_layoutDescription() if not self.Destroyed then self.TitleLabel.Visible=false; self.DescriptionLabel.Visible=false; hub:_layoutHub() end end
    end
    for _,control in ipairs({self.FavoriteButton,self.TeleportButton,self.PlayButton,self.CancelButton}) do compact(control,control.Button,"button") end
    window:_bind(self.PlayButton.Button,{BackgroundColor3="Accent",TextColor3="AccentText"})
    if self.PlayButton._titleIcon then self.PlayButton._titleIcon:SetRole("AccentText") end
    for _,control in ipairs({self.GameSearch,self.ScriptSearch}) do
        compact(control,control.Input,"input")
        local clear=button(window,control,control.Frame,"×",{Position=UDim2.new(1,-30,0,0),Size=U2(30,30)},function() control:SetValue("") end)
        control.ClearButton=clear
        local layout=control._layoutDescription
        function control:_layoutDescription() layout(self); self.Input.Size=UDim2.new(1,-34,1,0); clear.Size=UDim2.new(0,30,1,0) end
        control:_layoutDescription()
        function control:_syncClear() clear.Visible=self:GetValue()~="" end
        self.Scope:Add(window:GetFlagState(control.Id):Subscribe(function() control:_syncClear() end,true),"Disconnect")
    end
    compact(self.Sort,self.Sort.Button,"input")
    local sortLayout,sortRender=self.Sort._layoutDescription,self.Sort._render
    local sortPanel
    for _,child in ipairs(self.Sort.Frame:GetChildren()) do if child.ClassName=="Frame" and child.Size.Y.Offset==184 then sortPanel=child; break end end
    function self.Sort:_layoutDescription()
        sortLayout(self)
        local height=UserInputService.TouchEnabled and 42 or math.ceil(34*(window.TextScale or 1))
        self.Button.Size=UDim2.new(1,0,0,height)
        if sortPanel then sortPanel.Position=U2(0,height+4) end
        self.Frame.Size=UDim2.new(self.Frame.Size.X.Scale,self.Frame.Size.X.Offset,0,height+(self.Open and 192 or 0))
    end
    function self.Sort:_render()
        sortRender(self)
        local labels={Order=window:_t17("Cadastro","Registration order"),Alphabetical=window:_t17("Nome","Name"),Favorites=window:_t17("Favoritos","Favorites")}
        self.Button.Text=labels[self.Value] or self.Button.Text
        for name,item in pairs(self._rows or {}) do item.Text=(self.Value==name and "[X] " or "[ ] ")..(labels[name] or name) end
    end
    self.Sort:_layoutDescription(); self.Sort:_render()
    local sortOpen=self.Sort.SetOpen
    function self.Sort:SetOpen(value)
        local previous=self.Frame.Size; sortOpen(self,value)
        window:_cancelTrack(self.Frame,"expand",false); self:_layoutDescription()
        local target=self.Frame.Size; self.Frame.Size=previous
        window:_animate(self.Frame,{Size=target},.12,"expand",self)
        return self
    end
    self.GameImage.Title=""; self.GameImage.TitleLabel.Text=""
    window:_bind(self.GameImage.Frame,{BackgroundColor3="Inset",BorderColor3="Border"}); self.GameImage.Frame.BackgroundTransparency=0; self.GameImage.Frame.BorderSizePixel=1
    self.ImageFallback=iconSlot(window,self.GameImage.Frame,"gamepad",nil,48,UDim2.new(.5,-24,.5,-24),"Muted")
end
