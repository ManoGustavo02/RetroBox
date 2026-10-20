-- Catalog checks are explicit read-only downloads. Downloaded code is never run.
function Hub:DiagnoseCatalog(options)
    assert(not self.Destroyed,'Hub has been destroyed');options=options or {}
    assert(options.Fetch==nil or type(options.Fetch)=='function','Fetch must be a developer transport')
    assert(options.ValidateSyntax==nil or type(options.ValidateSyntax)=='boolean','ValidateSyntax must be boolean')
    local maximum=options.MaxEntries or 256
    assert(finite(maximum) and maximum%1==0 and maximum>=1 and maximum<=4096,'MaxEntries must be 1–4096')
    local entries={}
    for _,gameId in ipairs(self._order) do
        local gameRecord=self._games[gameId]
        for _,script in ipairs(gameRecord.Scripts) do entries[#entries+1]={GameId=gameId,ScriptId=script.Id,Name=script.Title,Kind='Game',URL=script.SourceURL,Callback=type(script.Callback)=='function'} end
    end
    for _,script in ipairs(self._universal.Scripts) do entries[#entries+1]={ScriptId=script.Id,Name=script.Name,Kind='Universal',URL=script.URL or script.SourceURL,Callback=type(script.Callback)=='function'} end
    local report={LibraryVersion=Library.Version,HubId=self.Id,Started=os.clock(),Entries={},Total=#entries,Skipped=math.max(0,#entries-maximum),Status='Running'}
    local previous=self._catalogDiagnosis;self._catalogDiagnosis=report
    local handle,reason=self.Window:RunAction({Group='catalog-diagnostics/'..self.Id,Policy='Reject',Callback=function(ctx)
        local cache={}
        local function inspect(url)
            if cache[url] then return copy(cache[url]) end
            local ok,response=pcall(function()
                if options.Fetch then return options.Fetch(url,ctx) end
                assert(type(game.HttpGet)=='function','HttpGet is unavailable');return game:HttpGet(url)
            end)
            ctx:ThrowIfCancelled()
            local row={}
            if not ok then row.Status='HTTPError';row.Message=tostring(response):sub(1,512)
            else
                local body=response
                if type(response)=='table' then body=response.Body;row.StatusCode=response.StatusCode end
                if row.StatusCode and (row.StatusCode<200 or row.StatusCode>=300) then row.Status='HTTPError';row.Message='HTTP '..row.StatusCode
                elseif type(body)~='string' or body:match('^%s*$') then row.Status='Empty'
                elseif #body>2097152 then row.Status='TooLarge';row.Bytes=#body
                elseif body:sub(1,512):lower():find('<!doctype',1,true) or body:sub(1,512):lower():find('<html',1,true) then row.Status='HTML';row.Bytes=#body
                else
                    row.Status='Available';row.Bytes=#body
                    if options.ValidateSyntax then
                        if type(loadstring)~='function' then row.Syntax='Unavailable'
                        else
                            local chunk,errorMessage=loadstring(body,'@RetroBox-Catalog-Diagnostic')
                            row.Syntax=chunk and 'Compiled' or 'Invalid';row.Message=errorMessage and tostring(errorMessage):sub(1,512) or nil
                            if not chunk then row.Status='InvalidSyntax' end
                        end
                    end
                end
            end
            cache[url]=copy(row);return row
        end
        for i=1,math.min(maximum,#entries) do
            ctx:ThrowIfCancelled();assert(not self.Destroyed,'Hub was destroyed')
            local entry=entries[i];local row=entry.URL and inspect(entry.URL) or {Status=entry.Callback and 'Callback' or 'NoSource'}
            row.GameId=entry.GameId;row.ScriptId=entry.ScriptId;row.Name=entry.Name;row.Kind=entry.Kind;row.URL=entry.URL
            report.Entries[#report.Entries+1]=row;ctx:SetProgress(i,math.max(1,math.min(maximum,#entries)),entry.Name)
        end
        report.Status='Completed';report.Finished=os.clock();return copy(report)
    end,OnComplete=function(completed)
        if not self.Destroyed and self._catalogDiagnosis==report then
            local status=completed:GetStatus().Status
            if status~='Completed' then report.Status=status;report.Error=completed.Error end
        end
    end})
    if handle then self.Scope:Add(handle,'Cancel','catalog-diagnostics');return handle end
    self._catalogDiagnosis=previous;return nil,reason
end
function Hub:GetCatalogDiagnosis() return self._catalogDiagnosis and copy(self._catalogDiagnosis) or nil end
function Hub:OpenCatalogDiagnostics(options)
    assert(not self.Destroyed,'Hub has been destroyed')
    if self._diagnosticsTab and not self._diagnosticsTab.Destroyed then self._diagnosticsTab:Select();return self._diagnosticsTab end
    local window=self.Window;local tab=window:CreateTab({Title=window:_t17('Diagnóstico do Hub','Hub diagnostics'),Icon='info'})
    self._diagnosticsTab=tab
    local section=tab:CreateSection({Title=window:_t17('Verificar catálogo','Check catalog')})
    local prefix='hub/'..self.Id..'/diagnostics/'
    local status=section:AddLabel({Id=prefix..'status',Title=window:_t17('Downloads e validação opcionais; os scripts não serão executados.','Optional downloads and validation; scripts will not run.'),Height=48})
    local list=section:AddVirtualList({Id=prefix..'results',Title=window:_t17('Resultados','Results'),Items={},Height=300,RowHeight=52})
    local handle
    section:AddButton({Id=prefix..'check',Title=window:_t17('Verificar links','Check links'),Callback=function()
        local started,reason=self:DiagnoseCatalog(options)
        if not started then status:SetText(tostring(reason));return end
        handle=started
        self.Scope:Remove('diagnostic-view')
        self.Scope:Add(handle:Subscribe(function(state)
            if self.Destroyed or tab.Destroyed or status.Destroyed then return end
            status:SetText(state.Status..' · '..tostring(state.Message or ''))
            local items={}
            for index,record in ipairs((self:GetCatalogDiagnosis() or {}).Entries or {}) do
                items[#items+1]={Id=tostring(index),Text=record.Name..' · '..record.Status,Description=record.Message or record.Kind}
            end
            list:SetItems(items)
        end,true),'Disconnect','diagnostic-view')
    end})
    section:AddButton({Id=prefix..'cancel',Title=window:_t17('Cancelar verificação','Cancel check'),Callback=function() if handle then handle:Cancel('user cancelled') end end})
    self.Scope:Add(function() if not tab.Destroyed then tab:Destroy() end;self._diagnosticsTab=nil;self._catalogDiagnosis=nil end)
    tab:Select();return tab
end
