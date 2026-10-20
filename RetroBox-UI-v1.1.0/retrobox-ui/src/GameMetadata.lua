-- Embedded inside the existing Hub scope. This manager only applies declarative metadata.
local metadataFields={Name=true,Description=true,UniverseId=true,Image=true}
local function metadataText(value,limit)
    assert(type(value)=='string','Metadata text must be a string')
    if utf8 then assert(utf8.len(value),'Metadata text must be valid UTF-8') end
    if #value>limit then local boundary=utf8 and utf8.offset(value,0,limit+1) or limit+1; value=value:sub(1,boundary-1) end
    return value
end
local function cleanMetadata(value)
    assert(type(value)=='table' and getmetatable(value)==nil,'Metadata provider must return a plain record')
    local result={}
    for name,item in pairs(value) do
        assert(metadataFields[name],'Unknown metadata field: '..tostring(name))
        if name=='Name' then result.Name=metadataText(item,128); if result.Name=='' then result.Name=nil end
        elseif name=='Description' then result.Description=metadataText(item,2048)
        elseif name=='UniverseId' then result.UniverseId=identifier(item,'Metadata UniverseId')
        elseif name=='Image' then result.Image=imageURI(item) end
    end
    return result
end
local function officialMetadata(query)
    local result={}
    -- The current session supplies a trusted mapping. An arbitrary PlaceId does
    -- not imply an arbitrary UniverseId; the engine method below has no such field.
    if query.PlaceId==game.PlaceId and finite(game.GameId) and game.GameId>0 then result.UniverseId=game.GameId end
    if query.PlaceId then
        local service=optionalService('MarketplaceService')
        if service then
            local available,method=pcall(function() return service.GetProductInfoAsync end)
            if not available or type(method)~='function' then available,method=pcall(function() return service.GetProductInfo end) end
            if available and type(method)=='function' then
                local ok,value=pcall(method,service,query.PlaceId,Enum.InfoType.Asset)
                if ok and type(value)=='table' then
                    if type(value.Name)=='string' then result.Name=metadataText(value.Name,128) end
                    if type(value.Description)=='string' then result.Description=metadataText(value.Description,2048) end
                elseif not ok then return result,tostring(value) end
            else return result,'MarketplaceService product information is unavailable' end
        else return result,'MarketplaceService is unavailable' end
    elseif not query.UniverseId then return result,'Game has no Roblox identifier'
    else return result,'An authorized provider is needed to query an arbitrary UniverseId without a PlaceId' end
    return result
end
function Hub:_setupGameMetadata(options)
    if options==false then options={Enabled=false} end
    options=options or {}; assert(type(options)=='table','GameMetadata must be a table or false')
    assert(options.Enabled==nil or type(options.Enabled)=='boolean','GameMetadata.Enabled must be boolean')
    assert(options.Provider==nil or type(options.Provider)=='function','GameMetadata.Provider must be a developer callback')
    local settings={Enabled=options.Enabled~=false,Provider=options.Provider,CacheTTL=options.CacheTTL or 300,
        FailureTTL=options.FailureTTL or 30,MaxConcurrent=options.MaxConcurrent or 2}
    assert(finite(settings.CacheTTL) and settings.CacheTTL>=0 and settings.CacheTTL<=86400,'Metadata CacheTTL must be 0–86400')
    assert(finite(settings.FailureTTL) and settings.FailureTTL>=0 and settings.FailureTTL<=300,'Metadata FailureTTL must be 0–300')
    assert(finite(settings.MaxConcurrent) and settings.MaxConcurrent%1==0 and settings.MaxConcurrent>=1 and settings.MaxConcurrent<=4,'Metadata MaxConcurrent must be 1–4')
    self._metadata={Owner=self,Settings=settings,Cache={},Requests={},Queue={},States={},Active=0,Clock=0}
    local manager=self._metadata
    self.Scope:Add(function()
        manager.Destroyed=true; manager.Owner=nil; manager.Cache={}; manager.Queue={}; manager.States={}
        for _,request in pairs(manager.Requests) do request.Listeners={} end
        manager.Requests={}
    end)
end
function Hub:GetGameMetadataStatus(id)
    if not self:_game(id) then return nil,'Unknown game' end
    local entry=self._metadata and self._metadata.States[id]
    return entry and copy(entry.Status) or {State='Idle'}
end
function Hub:_metadataChanged()
    if self._metadataUIQueued or self.Destroyed then return end
    self._metadataUIQueued=true
    task.defer(function()
        self._metadataUIQueued=false; if self.Destroyed or self.Window.Destroyed then return end
        local selected=self.SelectedGameId
        local gamesPosition,scriptsPosition=self.GameList.Viewport.CanvasPosition,self.ScriptList.Viewport.CanvasPosition
        self:_refreshGames()
        if selected and self:_game(selected) then self:SelectGame(selected) end
        self.GameList.Viewport.CanvasPosition=gamesPosition; self.ScriptList.Viewport.CanvasPosition=scriptsPosition
    end)
end
function Hub:_applyGameMetadata(listener,result,cached)
    local manager=self._metadata; local rec=self:_game(listener.Id)
    local state=manager.States[listener.Id]
    if self.Destroyed or rec~=listener.Record or state~=listener.State then return end
    local fields={}
    for name in pairs(metadataFields) do
        if not rec._metadataManual[name] and result.Data[name]~=nil then rec[name]=result.Data[name]; fields[name]=true end
    end
    local complete=(rec._metadataManual.Name or result.Data.Name~=nil) and (rec._metadataManual.Description or result.Data.Description~=nil)
    state.Status={State=complete and 'Ready' or next(result.Data) and 'Partial' or 'Unavailable',Cached=cached==true,
        UpdatedAt=os.clock(),Error=result.Error,Fields=fields,Source=manager.Settings.Provider and 'Provider' or 'MarketplaceService'}
    self:_metadataChanged()
end
function Hub:_pumpGameMetadata()
    local manager=self._metadata
    if not manager or manager.Destroyed then return end
    while manager.Active<manager.Settings.MaxConcurrent and #manager.Queue>0 do
        local request=table.remove(manager.Queue,1)
        local listeners={}
        for _,listener in pairs(request.Listeners) do
            local owner=manager.Owner
            if owner and owner:_game(listener.Id)==listener.Record and manager.States[listener.Id]==listener.State then listeners[listener.Id]=listener end
        end
        request.Listeners=listeners
        if not next(listeners) then manager.Requests[request.Key]=nil
        else
            manager.Active=manager.Active+1
            request.Started=true
            for _,listener in pairs(listeners) do listener.State.Status.State='Loading' end
            task.defer(function()
                if manager.Destroyed then manager.Active=manager.Active-1; return end
                local ok,data,reason=pcall(function()
                    local result,why=officialMetadata(request.Query)
                    local providerFailed=false
                    if manager.Settings.Provider then
                        local valid,provided=pcall(function()
                            local value=manager.Settings.Provider(copy(request.Query),copy(result))
                            return value~=nil and cleanMetadata(value) or {}
                        end)
                        if valid then for name,value in pairs(provided) do result[name]=value end
                        else why=tostring(provided); providerFailed=true end
                    end
                    if not providerFailed and result.Name~=nil and result.Description~=nil then why=nil end
                    return cleanMetadata(result),why
                end)
                if not ok then reason=tostring(data); data={} end
                local result={Data=data,Error=reason}
                manager.Active=manager.Active-1; manager.Requests[request.Key]=nil
                if manager.Destroyed or not manager.Owner then request.Listeners={}; return end
                manager.Clock=manager.Clock+1
                manager.Cache[request.Key]={Result=result,Expires=os.clock()+(next(data) and manager.Settings.CacheTTL or manager.Settings.FailureTTL),Use=manager.Clock}
                local count,oldest,age=0,nil,math.huge
                for key,value in pairs(manager.Cache) do count=count+1; if value.Use<age then oldest=key; age=value.Use end end
                if count>128 then manager.Cache[oldest]=nil end
                for _,listener in pairs(request.Listeners) do manager.Owner:_applyGameMetadata(listener,result,false) end
                request.Listeners={}; manager.Owner:_pumpGameMetadata()
            end)
        end
    end
end
function Hub:_requestGameMetadata(id,force)
    local rec=assert(self:_game(id),'Unknown game'); local manager=self._metadata
    if not manager or not manager.Settings.Enabled then
        assert(rec._metadataManual.Name,'Game Name is required when GameMetadata is disabled')
        if manager then manager.States[id]={Record=rec,Status={State='Disabled'}} end
        return false,'Game metadata is disabled'
    end
    local prior=manager.States[id]
    if not force and prior and prior.Record==rec then return true end
    local state={Record=rec,Status={State='Queued'}}; manager.States[id]=state
    if not rec.PlaceId and not rec.UniverseId then state.Status.State='Unavailable'; state.Status.Error='Game has no Roblox identifier'; return false,state.Status.Error end
    local needs=not rec._metadataManual.Name or not rec._metadataManual.Description
        or manager.Settings.Provider and (not rec._metadataManual.UniverseId or not rec._metadataManual.Image)
    if not force and not needs then state.Status.State='Preserved'; return true end
    local key=string.format('p:%s/u:%s',tostring(rec.PlaceId or ''),tostring(rec.UniverseId or ''))
    local listener={Id=id,Record=rec,State=state}
    local cache=manager.Cache[key]
    if not force and cache and cache.Expires>os.clock() then
        manager.Clock=manager.Clock+1; cache.Use=manager.Clock; self:_applyGameMetadata(listener,cache.Result,true); return true
    end
    local request=manager.Requests[key]
    if not request then
        request={Key=key,Query={PlaceId=rec.PlaceId,UniverseId=rec.UniverseId},Listeners={}}
        manager.Requests[key]=request; manager.Queue[#manager.Queue+1]=request
    end
    request.Listeners[id]=listener
    if request.Started then state.Status.State='Loading' end
    self:_pumpGameMetadata(); return true
end
function Hub:RefreshGameMetadata(id)
    if self.Destroyed then return false,'Hub has been destroyed' end
    if not self:_game(id) then return false,'Unknown game' end
    return self:_requestGameMetadata(id,true)
end
function Hub:_scheduleGameMetadata()
    if self.Destroyed or not self._metadata then return end
    for id in pairs(self._metadata.States) do if not self:_game(id) then self._metadata.States[id]=nil end end
    for _,request in pairs(self._metadata.Requests) do
        for id,listener in pairs(request.Listeners) do if self:_game(id)~=listener.Record then request.Listeners[id]=nil end end
    end
    for _,id in ipairs(self._order) do self:_requestGameMetadata(id,false) end
end
