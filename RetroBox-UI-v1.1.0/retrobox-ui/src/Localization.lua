-- Text localization is owned by each window. Input values and code identifiers
-- are never translated; providers receive only explicitly registered messages.
do
    local builtinPairs={}
    local function locale(value)
        assert(type(value)=='string' and #value<=24,'Locale must be a language code or auto')
        value=value:lower():gsub('_','-')
        if value=='auto' then return 'auto' end
        if value=='pt' or value:match('^pt%-') then return 'pt-BR' end
        if value=='en' or value:match('^en%-') then return 'en-US' end
        assert(value:match('^[a-z][a-z]%-[%w%-]+$'),'Invalid locale code')
        return value:sub(1,3)..value:sub(4):upper()
    end
    local function detected()
        local player=Players.LocalPlayer
        if player then
            local ok,value=pcall(function() return player.LocaleId end)
            if ok and type(value)=='string' and value~='' then local parsed,code=pcall(locale,value);if parsed then return code,'Player.LocaleId' end end
        end
        local ok,service=pcall(function() return game:GetService('LocalizationService') end)
        if ok and service then
            for _,key in ipairs({'RobloxLocaleId','SystemLocaleId'}) do
                local read,value=pcall(function() return service[key] end)
                if read and type(value)=='string' and value~='' then
                    local parsed,code=pcall(locale,value);if parsed then return code,key end
                end
            end
        end
        return 'en-US','fallback'
    end
    local function placeholders(value)
        local keys={};for key in value:gmatch('{([%w_]+)}') do keys[key]=true end;return keys
    end
    local function validTranslation(source,target)
        assert(type(target)=='string' and #target<=8192,'Translation must contain at most 8192 bytes')
        assert(same(placeholders(source),placeholders(target)),'Translation must preserve every placeholder')
        return target
    end
    local function interpolate(value,args)
        return (value:gsub('{([%w_]+)}',function(key)
            local item=args and args[key];return item==nil and ('{'..key..'}') or tostring(item)
        end))
    end
    local function dictionary(value)
        assert(type(value)=='table','Translations must be a table')
        local result,count={},0
        for key,entry in pairs(value) do
            count=count+1;assert(count<=4096 and type(key)=='string' and #key>=1 and #key<=256,'Translation key limit exceeded')
            assert(type(entry)=='table' and type(entry.Source)=='string' and #entry.Source<=8192,'Translation entry needs Source')
            local record={Source=entry.Source,Context=entry.Context,Values={}}
            assert(entry.Context==nil or type(entry.Context)=='string' and #entry.Context<=512,'Invalid translation context')
            for code,text in pairs(entry.Values or {}) do
                local normalized=locale(code);assert(normalized~='auto','A translation cannot target auto')
                record.Values[normalized]=validTranslation(entry.Source,text)
            end
            result[key]=record
        end
        return result
    end
    function Library:DetectLocale() return detected() end
    function Library:ValidateTranslations(value) return dictionary(value) end
    for key,pt in pairs(translations['pt-BR']) do
        local en=translations['en-US'][key]
        if type(pt)=='string' and type(en)=='string' then builtinPairs[pt]={['pt-BR']=pt,['en-US']=en};builtinPairs[en]=builtinPairs[pt] end
    end
    function Window:_t17(pt,en)
        if type(pt)=='string' and type(en)=='string' then
            self._builtinTextPairs=self._builtinTextPairs or {}
            local pairsForWindow=self._builtinTextPairs
            local pair={['pt-BR']=pt,['en-US']=en};pairsForWindow[pt]=pair;pairsForWindow[en]=pair
            local upper={['pt-BR']=pt:upper(),['en-US']=en:upper()};pairsForWindow[pt:upper()]=upper;pairsForWindow[en:upper()]=upper
        end
        return self._locale==translations['en-US'] and en or pt
    end
    function Window:_translateLiteral(source)
        local entry=self._literalMessages and self._literalMessages[source]
        if type(entry)=='table' then return self:Translate(entry.Key):upper() end
        if entry then return self:Translate(entry) end
        local pair=self._builtinTextPairs and self._builtinTextPairs[source] or builtinPairs[source]
        local code=self.Locale or (self._locale==translations['pt-BR'] and 'pt-BR' or 'en-US')
        return pair and (pair[code] or pair['en-US']) or source
    end
    function Window:_watchLocalizedText(object,property,source)
        if not self._localizationEnabled or type(source)~='string' then return end
        self._localizedText=self._localizedText or {}
        local properties=self._localizedText[object]
        if not properties then
            properties={};self._localizedText[object]=properties
            local destroy
            destroy=object.Destroying:Connect(function()
                local fields=self._localizedText and self._localizedText[object]
                if fields then
                    for _,slot in pairs(fields) do if slot.Connection then slot.Connection:Disconnect() end end
                    self._localizedText[object]=nil
                end
                if destroy then destroy:Disconnect();destroy=nil end
            end)
            properties._destroy={Connection=destroy}
        end
        if properties[property] then return end
        local slot={Source=source,Ignore=false};properties[property]=slot
        local function render()
            if self.Destroyed or self._closing or not object.Parent or slot.Ignore or slot.Writing then return end
            local value=slot.Key and self:Translate(slot.Key,slot.Args) or self:_translateLiteral(slot.Source)
            if object[property]~=value then slot.Writing=true;object[property]=value;slot.Writing=false end
        end
        slot.Render=render
        slot.Connection=object:GetPropertyChangedSignal(property):Connect(function()
            if not slot.Writing then slot.Source=object[property];slot.Key=nil;slot.Args=nil;render() end
        end)
        render()
    end
    function Window:SetTextTranslation(object,enabled)
        assert(type(enabled)=='boolean','Translation visibility must be boolean')
        for candidate,properties in pairs(self._localizedText or {}) do
            local current=candidate
            while current and current~=object do current=current.Parent end
            if current==object then
                for property,slot in pairs(properties) do
                    if property~='_destroy' then
                        slot.Ignore=not enabled
                        if candidate.Parent and not self.Destroyed then
                            if enabled then slot.Render() else slot.Writing=true;candidate[property]=slot.Source;slot.Writing=false end
                        end
                    end
                end
            end
        end
        return self
    end
    function Window:RegisterTranslations(value)
        assert(not self.Destroyed,'Window has been destroyed')
        local prepared=dictionary(value);self._messages=self._messages or {};self._literalMessages=self._literalMessages or {}
        for key,entry in pairs(prepared) do
            local old=self._messages[key]
            if old then self._literalMessages[old.Source]=nil;self._literalMessages[old.Source:upper()]=nil;for _,text in pairs(old.Values) do self._literalMessages[text]=nil;self._literalMessages[text:upper()]=nil end end
            self._messages[key]=entry;self._literalMessages[entry.Source]=key
            if entry.Source:upper()~=entry.Source then self._literalMessages[entry.Source:upper()]={Key=key,Upper=true} end
            for code,text in pairs(entry.Values) do
                self._literalMessages[text]=key
                if text:upper()~=text then self._literalMessages[text:upper()]={Key=key,Upper=true} end
                if self._supportedLocales then self._supportedLocales[code]=true end
            end
        end
        self:_refreshLocalizedText();return self
    end
    function Window:Translate(key,args)
        assert(type(key)=='string','Translation key must be a string')
        local entry=self._messages and self._messages[key]
        if not entry then return interpolate(key,args) end
        local text=entry.Values[self.Locale]
        if text then
            if self._missingTranslations then self._missingTranslations[key]=nil end
        else
            if self.Locale==self.SourceLocale then text=entry.Source
            else
                self._missingTranslations=self._missingTranslations or {};self._missingTranslations[key]=true
                text=entry.Values[self.FallbackLocale] or entry.Source
            end
        end
        return interpolate(text,args)
    end
    function Window:GetMissingTranslations()
        local result={};for key in pairs(self._missingTranslations or {}) do result[#result+1]=key end;table.sort(result);return result
    end
    function Window:_refreshLocalizedText()
        if self.Destroyed then return end
        for object,properties in pairs(self._localizedText or {}) do
            if object.Parent then for name,slot in pairs(properties) do if name~='_destroy' and not slot.Ignore then slot.Render() end end end
        end
    end
    function Window:BindText(object,property,key,args)
        assert(property=='Text' and not object:IsA('TextBox') or property=='PlaceholderText' and object:IsA('TextBox'),'BindText accepts display text or placeholders')
        assert(self._messages and self._messages[key],'Unknown translation key')
        self:_watchLocalizedText(object,property,object[property])
        local slot=assert(self._localizedText[object][property]);slot.Key=key;slot.Args=copy(args);slot.Ignore=false;slot.Render()
        return self
    end
    function Window:GetLocale() return self.Locale,self.LocalePolicy end
    function Window:SetLocale(value)
        assert(not self.Destroyed,'Window has been destroyed')
        local policy=locale(value);local resolved,origin=policy,'manual'
        if policy=='auto' then resolved,origin=detected() end
        if resolved~='pt-BR' and resolved~='en-US' and not self._supportedLocales[resolved] then resolved=self.FallbackLocale end
        self.LocalePolicy,self.Locale,self.LocaleOrigin=policy,resolved,origin
        self._locale=translations[resolved] or translations['en-US'];self._missingTranslations={}
        if self._refreshProfile then self._refreshProfile(false) end
        self:_refreshLocalizedText()
        for _,flow in pairs(self._flows or {}) do if not flow.Destroyed then flow:Refresh() end end
        if self._localePicker then
            local codes={'auto'};for code in pairs(self._supportedLocales) do codes[#codes+1]=code end
            if not table.find(codes,policy) then codes[#codes+1]=policy end
            self._localePicker:SetOptions(codes,true);self._localePicker:SetValue(policy,true)
        end
        self:_scheduleSave();return self
    end
    function Window:RequestTranslation(key)
        assert(not self.Destroyed and self._messages and self._messages[key],'Unknown translation key')
        if type(self.TranslationProvider)~='function' then return nil,'No translation provider configured' end
        local entry=self._messages[key];local target=self.Locale
        if entry.Values[target] or target==self.SourceLocale then return nil,'Translation already available' end
        return self:RunAction({Id='translate/'..UpdateCore.SHA256(key..target):sub(1,20),Group='translations',Policy='Queue',Callback=function(ctx)
            ctx:ThrowIfCancelled()
            local translated=self.TranslationProvider({Key=key,Text=entry.Source,SourceLocale=self.SourceLocale,TargetLocale=target,Context=entry.Context},ctx)
            ctx:ThrowIfCancelled();validTranslation(entry.Source,translated)
            if self.Destroyed or self._messages[key]~=entry then return {Skipped=true,Reason='Translation entry was replaced'} end
            entry.Values[target]=translated;self._literalMessages[translated]=key;self._missingTranslations[key]=nil
            self:_refreshLocalizedText();return translated
        end})
    end
    local create=Library.CreateWindow
    function Library:CreateWindow(options)
        options=options or {};local passed={};for key,value in pairs(options) do passed[key]=value end
        local policy=locale(options.Locale or 'auto');local resolved=policy=='auto' and detected() or policy
        local sourceLocale=locale(options.SourceLocale or 'pt-BR');local fallbackLocale=locale(options.FallbackLocale or 'en-US')
        assert(sourceLocale~='auto' and fallbackLocale~='auto','Source and fallback locales cannot be auto')
        local messages=dictionary(options.Translations or {})
        assert(options.TranslationProvider==nil or type(options.TranslationProvider)=='function','TranslationProvider must be a developer callback')
        passed.Locale=resolved=='pt-BR' and 'pt-BR' or 'en-US';passed._LocalizationEnabled=true
        local window=create(self,passed)
        window.SourceLocale=sourceLocale;window.FallbackLocale=fallbackLocale
        window._supportedLocales={['pt-BR']=true,['en-US']=true}
        window._supportedLocales[sourceLocale]=true;window._supportedLocales[fallbackLocale]=true
        for _,entry in pairs(messages) do for code in pairs(entry.Values) do window._supportedLocales[code]=true end end
        window._messages={};window._literalMessages={};window._missingTranslations={};window.TranslationProvider=options.TranslationProvider
        window:RegisterTranslations(messages);window:SetLocale(policy)
        window:Manage(function()
            for _,properties in pairs(window._localizedText or {}) do for _,slot in pairs(properties) do if slot.Connection then slot.Connection:Disconnect() end end end
            window._localizedText={};window._messages={};window._literalMessages={};window._builtinTextPairs={};window.TranslationProvider=nil
        end,nil,'localization')
        if window._settingsTab then
            local section=window._settingsTab:CreateSection({Title='Idioma / Language',Icon='settings'})
            local codes={'auto'};for code in pairs(window._supportedLocales) do codes[#codes+1]=code end
            if not table.find(codes,policy) then codes[#codes+1]=policy end
            window._localePicker=section:AddDropdown({Id='__retrobox/locale',Internal=true,Title='Idioma / Language',Options=codes,Default=policy,Callback=function(value) window:SetLocale(value) end})
        end
        return window
    end
    for _,kind in ipairs({'Toggle','Slider','Button','Input','Dropdown','Keybind','ColorPicker','Label','Separator','Progress','Console','Image','StatCard','Chart','VirtualList','DataTable','TreeView','Preview','Stepper','CardGrid'}) do
        local method=Section['Add'..kind]
        if method then
            Section['Add'..kind]=function(section,options)
                local control=method(section,options)
                if options and options.Translate==false then section._window:SetTextTranslation(control.Frame,false) end
                return control
            end
        end
    end
    local export=Window._exportProfileExtras
    function Window:_exportProfileExtras(profile)
        export(self,profile);profile.Appearance.Locale=self.LocalePolicy;return profile
    end
    local prepare=Window._prepareProfile
    function Window:_prepareProfile(source,options)
        local profile,extras,policy=prepare(self,source,options)
        if profile.Appearance and profile.Appearance.Locale~=nil then locale(profile.Appearance.Locale) end
        return profile,extras,policy
    end
    local import=Window.ImportConfig
    function Window:ImportConfig(source,options)
        local ok,reason=import(self,source,options)
        if ok then
            local profile=type(source)=='string' and HttpService:JSONDecode(source) or source
            if profile.Appearance and profile.Appearance.Locale then self:SetLocale(profile.Appearance.Locale) end
        end
        return ok,reason
    end
end
