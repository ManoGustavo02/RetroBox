-- Hub-specific visual profiles. Catalog IDs, callbacks and data are untouched.
Library.HubThemes=Library.HubThemes or {
    Launcher=palette({
        {7,12,10},{17,26,21},{11,18,15},{228,245,233},{155,184,165},{41,65,51},
        {38,66,49},{2,5,3},{68,231,132},{5,25,13},{116,237,166},{255,151,159},
    }),
}
local function hubProfile(window,value)
    if value==nil then value={Theme='Launcher'} end
    if type(value)=='string' then value={Theme=value} end
    assert(type(value)=='table','HubTheme must be a theme name or profile table')
    for field in pairs(value) do assert(field=='Theme' or field=='Accent' or field=='Colors','Unknown Hub theme field: '..tostring(field)) end
    local name=value.Theme or 'Launcher'
    assert(type(name)=='string' and #name>=1 and #name<=64 and not name:find('%c'),'Invalid Hub theme name')
    local base=Library.HubThemes[name] or window._themeOverrides[name] or Library.Themes[name]
    local result={Theme=name,Colors={}}
    assert(value.Colors==nil or type(value.Colors)=='table','Hub theme Colors must be a role map')
    for role,color in pairs(base or {}) do result.Colors[role]=hex(color) end
    for role,color in pairs(value.Colors or {}) do assert(table.find(roleNames,role),'Unknown Hub color role: '..tostring(role));result.Colors[role]=hex(parseColor(color)) end
    for _,role in ipairs(roleNames) do assert(result.Colors[role],'Unknown Hub theme or incomplete palette: '..name) end
    if value.Accent~=nil then result.Accent=hex(parseColor(value.Accent)) end
    return result
end
function Hub:GetThemeProfile() return copy(self.ThemeProfile) end
function Hub:GetThemeNames()
    local result=self.Window:GetThemeNames()
    for name in pairs(Library.HubThemes) do if not table.find(result,name) then result[#result+1]=name end end
    for _,profile in ipairs({self.ThemeProfile,self._initialThemeProfile}) do if profile and not table.find(result,profile.Theme) then result[#result+1]=profile.Theme end end
    table.sort(result);return result
end
function Hub:SetThemeProfile(value)
    assert(not self.Destroyed,'Hub has been destroyed')
    local profile=hubProfile(self.Window,value);local window=self.Window
    local colors=copy(Library.HubThemes[profile.Theme] or window._themeOverrides[profile.Theme] or Library.Themes[profile.Theme] or {})
    for role,color in pairs(profile.Colors) do colors[role]=parseColor(color) end
    if profile.Accent then colors.Accent=parseColor(profile.Accent);colors.AccentText=Library:ReadableColor(colors.AccentText,colors.Accent,4.5) end
    window._hubThemeProfiles=window._hubThemeProfiles or {}
    local count=0;for _ in pairs(window._hubThemeProfiles) do count=count+1 end
    assert(window._hubThemeProfiles[self.Id] or count<128,'Hub profile limit is 128')
    local previous=self.HubPalette
    self.ThemeProfile=profile;self.HubPalette=colors
    window._hubThemeProfiles[self.Id]=copy(profile)
    window._paletteScopes=window._paletteScopes or {}
    for root,palette in pairs(window._paletteScopes) do
        if previous and palette==previous then window._paletteScopes[root]=colors;window:_cancelAnimations(root,false);window:_reskin(root) end
    end
    window._paletteScopes[self.Tab.Frame]=colors
    if self._themeTab and not self._themeTab.Destroyed then window._paletteScopes[self._themeTab.Frame]=colors end
    window:_cancelAnimations(self.Tab.Frame,false);window:_reskin(self.Tab.Frame)
    if self.Launcher then self.Launcher:Refresh() end
    if self._themeTab then
        window:_reskin(self._themeTab.Frame)
        if self._themeSelect then self._themeSelect:SetValue(profile.Theme,true) end
        for role,picker in pairs(self._themePickers or {}) do if not picker.Destroyed then picker:SetColor(colors[role],true) end end
    end
    window:_scheduleSave();return self
end
function Hub:SetTheme(name)
    if not (Library.HubThemes[name] or Library.Themes[name] or self.Window._themeOverrides[name]) then
        if self.ThemeProfile.Theme==name then return self:SetThemeProfile(self.ThemeProfile) end
        if self._initialThemeProfile.Theme==name then return self:SetThemeProfile(self._initialThemeProfile) end
    end
    return self:SetThemeProfile({Theme=name})
end
function Hub:SetAccent(color)
    local profile=self:GetThemeProfile();profile.Accent=color and hex(parseColor(color)) or nil
    return self:SetThemeProfile(profile)
end
function Hub:ResetThemeProfile() return self:SetThemeProfile(self._initialThemeProfile) end
function Hub:_setupAppearance(options)
    local window=self.Window
    local initial=hubProfile(window,options.HubTheme)
    self._initialThemeProfile=copy(initial)
    self:SetThemeProfile(window._hubThemeProfiles and window._hubThemeProfiles[self.Id] or initial)
    self.Scope:Add(function()
        for root,colors in pairs(window._paletteScopes) do if colors==self.HubPalette then window._paletteScopes[root]=nil end end
        if self._themeTab then
            window._paletteScopes[self._themeTab.Frame]=nil
            local tab=self._themeTab;self._themeTab=nil
            if not tab.Destroyed then tab:Destroy() end
            self._themePickers=nil
        end
    end)
end
function Hub:ShowThemeSettings()
    assert(not self.Destroyed,'Hub has been destroyed')
    if self._themeTab and not self._themeTab.Destroyed then self._themeTab:Select();return self._themeTab end
    local hub=self;local window=self.Window
    local tab=window:CreateTab({Title=window:_t17('Tema do Hub','Hub appearance'),Icon='palette',Columns=2})
    self._themeTab=tab;window._paletteScopes[tab.Frame]=self.HubPalette
    local scope=self.Scope:Child()
    scope:Add(tab.Frame.Destroying:Connect(function()
        window._paletteScopes[tab.Frame]=nil
        if hub._themeTab==tab then hub._themeTab=nil;hub._themePickers=nil;hub._themeSelect=nil end
        scope:Destroy()
    end),'Disconnect')
    local section=tab:CreateSection({Title=window:_t17('Perfil de aparência independente','Independent appearance profile'),Icon='palette'})
    section:AddLabel({Id='hub/'..hub.Id..'/appearance/explanation',Title=window:_t17('Estas cores pertencem a este Hub.','These colors belong to this Hub.'),Description=window:_t17('O tema da janela e dos outros Hubs continua com suas próprias configurações.','The window and other Hubs keep their own settings.'),Height=84})
    local choose=section:AddDropdown({Id='hub/'..hub.Id..'/appearance/theme',Title=window:_t17('Tema','Theme'),Options=self:GetThemeNames(),Default=self.ThemeProfile.Theme,Persist=false,Callback=function(name)
        hub:SetTheme(name)
        for role,picker in pairs(hub._themePickers or {}) do picker:SetColor(hub.HubPalette[role],true) end
    end})
    self._themeSelect=choose
    section:AddButton({Id='hub/'..hub.Id..'/appearance/reset',Title=window:_t17('Restaurar perfil do Hub','Reset Hub profile'),Icon='restore',Callback=function()
        hub:ResetThemeProfile();choose:SetValue(hub.ThemeProfile.Theme,true)
        for role,picker in pairs(hub._themePickers or {}) do picker:SetColor(hub.HubPalette[role],true) end
    end})
    section:AddButton({Id='hub/'..hub.Id..'/appearance/back',Title=window:_t17('Voltar ao Hub','Back to Hub'),Icon='gamepad',Callback=function() hub.Tab:Select() end})
    local colors=tab:CreateSection({Title=window:_t17('Personalizar cores','Customize colors'),Icon='sliders',Side='Right'})
    self._themePickers={}
    local labels={Background={'Fundo','Background'},Surface={'Painéis','Panels'},Inset={'Áreas internas','Inset surfaces'},Text={'Texto principal','Primary text'},Muted={'Texto secundário','Secondary text'},Border={'Bordas','Borders'},Highlight={'Realce ao passar o mouse','Hover highlight'},Shadow={'Sombras','Shadows'},Accent={'Destaque','Accent'},AccentText={'Texto sobre destaque','Accent text'},Success={'Sucesso','Success'},Danger={'Erro e alerta','Errors and alerts'}}
    for _,role in ipairs(roleNames) do
        self._themePickers[role]=colors:AddColorPicker({Id='hub/'..hub.Id..'/appearance/color-'..role,Title=window:_t17(labels[role][1],labels[role][2]),Default=self.HubPalette[role],AllowRainbow=false,AllowOpacity=false,Persist=false,Callback=function(color)
            local profile=hub:GetThemeProfile();profile.Colors[role]=hex(color)
            if role=='Accent' then profile.Accent=nil end
            hub:SetThemeProfile(profile)
        end})
    end
    window:_reskin(tab.Frame);tab:Select();return tab
end
function Hub:SetRGB(options,part)
    assert(not self.Destroyed and self.Launcher,'Hub has been destroyed');part=part or 'Title'
    local target=({Title=self.Launcher.UI.GameTitle,Description=self.Launcher.UI.Description,SelectedScript=self.Launcher.UI.SelectedScript})[part]
    assert(target,'Unknown Hub RGB part: '..tostring(part))
    if options==false then local effect=self.Window._textRGB and self.Window._textRGB[target];if effect then effect:Destroy() end
    else self.Window:SetRGB(target,options) end
    return self
end
function Hub:_finishAppearance(options)
    if options.HubTitleRGB then self:SetRGB(options.HubTitleRGB,'Title') end
    if options.HubDescriptionRGB then self:SetRGB(options.HubDescriptionRGB,'Description') end
    if options.LoadingScreen~=false and (options.LoadingScreen~=nil or self.Window:_motionAllowed(self.Tab.Frame)) then
        local startup=copy(type(options.LoadingScreen)=='table' and options.LoadingScreen or {Message=self.Window:_t17('Preparando catálogo…','Preparing catalog…')})
        if startup.Blocking==nil then startup.Blocking=false end
        local loading=self.Window:ShowLoading(startup)
        self.Scope:Add(loading,'Destroy','startup-loading')
        self.Window._paletteScopes[loading.Frame]=self.HubPalette;self.Window:_reskin(loading.Frame)
        local object=loading.Frame
        loading.Scope:Add(function() self.Window._paletteScopes[object]=nil end)
        local pending=task.defer(function()
            loading.Scope:Remove('ready',true)
            if not loading.Destroyed then loading:Finish(self.Window:_t17('Catálogo pronto','Catalog ready')) end
        end)
        loading.Scope:Add(pending,function(thread) if coroutine.status(thread)=='suspended' then task.cancel(thread) end end,'ready')
    end
    self.Window:_reskin(self.Tab.Frame)
end
-- Profiles are validated alongside the rest of an atomic config import. They
-- can be loaded before the developer creates a Hub; the profile is then applied.
do
    local export=Window._exportAdvanced
    function Window:_exportAdvanced()
        local result=export(self);result.HubThemes=copy(self._hubThemeProfiles or {});return result
    end
    local prepare=Window._prepareAdvanced
    function Window:_prepareAdvanced(value)
        local result=prepare(self,value)
        if value and value.HubThemes~=nil then
            assert(type(value.HubThemes)=='table','HubThemes must be a profile map');result.HubThemes={};local count=0
            for id,profile in pairs(value.HubThemes) do
                key(id,'Hub profile Id');count=count+1;assert(count<=128,'Hub profile limit is 128')
                -- Profiles may refer to a custom palette imported in the same
                -- transaction; validate against that prepared palette too.
                local proxy={_themeOverrides=copy(self._themeOverrides)}
                for name,theme in pairs(result.Themes or {}) do proxy._themeOverrides[name]=theme.Colors end
                result.HubThemes[id]=hubProfile(proxy,profile)
            end
        end
        return result
    end
    local apply=Window._applyAdvanced
    function Window:_applyAdvanced(value,deferUI)
        apply(self,value,deferUI)
        if value and value.HubThemes then
            self._hubThemeProfiles=copy(value.HubThemes)
            for id,hub in pairs(self._scriptHubs or {}) do if not hub.Destroyed then hub:SetThemeProfile(value.HubThemes[id] or hub._initialThemeProfile) end end
        end
    end
    local reset=Window.ResetConfig
    function Window:ResetConfig(...)
        local result=reset(self,...)
        for _,hub in pairs(self._scriptHubs or {}) do if not hub.Destroyed then hub:ResetThemeProfile() end end
        return result
    end
end
