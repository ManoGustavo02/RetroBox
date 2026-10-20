-- First-class universal catalog. Embedded in the existing Hub lexical scope.
normalizeUniversalScript=function(value,allowUnavailable)
    assert(type(value)=='table','Universal script must be a record')
    assert(value.PlaceId==nil and value.UniverseId==nil and value.GameId==nil,'Universal scripts do not take Roblox game identifiers')
    assert(value.CurrentGameOnly==nil or value.CurrentGameOnly==false,'Universal scripts cannot use CurrentGameOnly')
    assert(value.Name==nil or value.Title==nil or value.Name==value.Title,'Universal Name and Title must agree')
    local name=text(value.Name or value.Title,128,'Universal script Name',true)
    local url=value.URL
    if url==false or url=='' then url=nil end
    assert(url==nil or type(url)=='string' and #url<=2048 and url:match('^https://[%w%.%-]+[^%s]*$') and not url:find('[%c]'),'Universal URL must be a direct HTTPS source URL')
    assert(not (url and value.Callback~=nil),'Use URL or Callback for a universal script, not both')
    assert(allowUnavailable or url or type(value.Callback)=='function','Universal script needs a URL or Callback')
    local scriptId=value.Id==nil and ('universal-'..UpdateCore.SHA256(name):sub(1,16)) or key(value.Id,'Universal script Id')
    local definition={Id=scriptId,Name=name,Description=value.Description,Icon=value.Icon,Author=value.Author,Version=value.Version,
        Status=value.Status,Enabled=value.Enabled,Requires=copy(array(value.Requires or {},16,'Requires')),Confirm=value.Confirm,URL=url,Callback=value.Callback}
    local prepared={}; for k,v in pairs(definition) do prepared[k]=v end; prepared.Title=name
    if url then
        prepared.Requires={};for _,cap in ipairs(definition.Requires) do if not table.find(prepared.Requires,cap) then prepared.Requires[#prepared.Requires+1]=cap end end
        for _,cap in ipairs({'HttpGet','loadstring'}) do if not table.find(prepared.Requires,cap) then prepared.Requires[#prepared.Requires+1]=cap end end
        prepared.Callback=function(ctx,activeHub)
            ctx:ThrowIfCancelled(); ctx:SetProgress(1,10,activeHub.Window:_t17('Baixando script universal…','Downloading universal script…'))
            local source=game:HttpGet(url)
            ctx:ThrowIfCancelled()
            assert(type(source)=='string' and #source>0,'Universal script source is empty')
            assert(#source<=2097152,'Universal script source exceeds 2 MiB')
            local chunk,reason=loadstring(source,'@RetroBox-Universal-'..scriptId)
            assert(chunk,'Universal script compilation failed: '..tostring(reason))
            ctx:ThrowIfCancelled(); ctx:SetProgress(8,10,activeHub.Window:_t17('Executando script universal…','Running universal script…'))
            return chunk()
        end
    end
    local result=normalizeScript(prepared)
    result.Name=name; result.URL=url; result.Universal=true; result.Kind='Universal'; result._definition=definition
    return result
end
normalizeUniversalScripts=function(values,allowUnavailable)
    local records,ids={},{}
    for _,value in ipairs(array(values or {},128,'UniversalScripts')) do
        local spec=normalizeUniversalScript(value,allowUnavailable)
        assert(not ids[spec.Id],'Duplicate universal script Id: '..spec.Id)
        ids[spec.Id]=true;records[#records+1]=spec
    end
    return records
end
newUniversalRecord=function(hub,scripts)
    return {Id=UNIVERSAL_KEY,Name=hub.Window:_t17('Scripts universais','Universal scripts'),
        Description=hub.Window:_t17('Scripts cadastrados sem vínculo com um jogo. Escolha um script para ler os detalhes e executar.','Scripts registered independently of a game. Select a script to read its details and run it.'),
        FallbackName='',Notes='',Scripts=scripts,Universal=true,Kind='Universal',_universal=true,
        _metadataManual={Name=true,Description=true}}
end
function Hub:GetSelectedCategory() return self.SelectedCategory or 'Games' end
function Hub:GetUniversalScripts()
    local result={};for _,spec in ipairs(self._universal and self._universal.Scripts or {}) do result[#result+1]=metadata(spec) end;return result
end
function Hub:GetUniversalScript(id) return self:GetScript(UNIVERSAL_KEY,id) end
function Hub:IsUniversalScriptAvailable(id) return self:IsScriptAvailable(UNIVERSAL_KEY,id) end
function Hub:GetUniversalScriptStatus(id) return self:GetScriptStatus(UNIVERSAL_KEY,id) end
function Hub:RunUniversalScript(id,options) return self:RunScript(UNIVERSAL_KEY,id,options) end
function Hub:CancelUniversalScript(id)
    local handle=self._pendingScripts[UNIVERSAL_KEY..'/'..tostring(id)]
    if not handle then return false end
    return handle:Cancel('user cancelled')
end
function Hub:SelectUniversalScripts()
    if self.Destroyed then return false,'Hub has been destroyed' end
    if self._selecting then return true end
    self._selecting=true
    local previous=self:_selectedKey()
    if previous and previous~=UNIVERSAL_KEY then self._selectedScripts[previous]=self.ScriptList:GetValue();self.ScriptList:SetValue(nil,true) end
    self.SelectedCategory='Universal';self.SelectedGameId=nil;self._universalConfigured=true
    self.GameList:SetValue(nil,true)
    if self.Launcher and self.Launcher.Category then self.Launcher.Category:SetValue('Universal',true) end
    self.FavoriteButton:SetDisabled(true);self.TeleportButton:SetDisabled(true)
    self.GameDetails:SetText(self._universal.Name..'\n'..self._universal.Description)
    self:_refreshImages();self:RefreshScripts();self._selecting=false
    if self.Launcher then self.Launcher:SelectionChanged(previous,UNIVERSAL_KEY) end
    return true
end
function Hub:SelectUniversalScript(id)
    if not self:_script(UNIVERSAL_KEY,id) then return false,'Script is unavailable' end
    local ok,reason=self:SelectUniversalScripts();if not ok then return ok,reason end
    return self:SelectScript(id)
end
function Hub:AddUniversalScript(value)
    assert(not self.Destroyed,'Hub has been destroyed')
    local spec=normalizeUniversalScript(value)
    assert(not self:_script(UNIVERSAL_KEY,spec.Id),'Duplicate universal script Id')
    assert(#self._universal.Scripts<128,'Universal script catalog limit is 128')
    self:_checkUniversalCount(#self._universal.Scripts+1)
    self._universal.Scripts[#self._universal.Scripts+1]=spec;self._universalConfigured=true
    self:_afterCatalog();return spec.Id
end
function Hub:UpdateUniversalScript(id,patch)
    assert(not self.Destroyed,'Hub has been destroyed')
    local old=assert(self:_script(UNIVERSAL_KEY,id),'Unknown universal script')
    assert(type(patch)=='table','Universal script patch must be a table')
    local value={};for k,v in pairs(old._definition) do value[k]=k=='Requires' and copy(v) or v end
    for k,v in pairs(patch) do value[k]=v end
    if patch.Title~=nil and patch.Name==nil then value.Name=nil end
    assert(value.Id==id,'Universal script Id cannot be renamed')
    local spec=normalizeUniversalScript(value)
    self:_cancelScripts(UNIVERSAL_KEY,id)
    for index,item in ipairs(self._universal.Scripts) do if item.Id==id then self._universal.Scripts[index]=spec;break end end
    self._scriptStatus[UNIVERSAL_KEY..'/'..id]=nil;self:_afterCatalog();return self
end
function Hub:RemoveUniversalScript(id)
    assert(not self.Destroyed,'Hub has been destroyed')
    for index,item in ipairs(self._universal.Scripts) do if item.Id==id then
        self:_cancelScripts(UNIVERSAL_KEY,id);table.remove(self._universal.Scripts,index)
        self._scriptStatus[UNIVERSAL_KEY..'/'..id]=nil;self:_afterCatalog();return true
    end end
    return false
end
function Hub:_checkUniversalCount(count,games)
    local total=count;for _,rec in pairs(games or self._games) do total=total+#rec.Scripts end
    assert(total<=4096,'Script catalog limit is 4096 entries')
end
