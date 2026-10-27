-- Optional diagnostic attachments: explicit selection, preview, bounded data and scoped capture.
do
    local Diagnostic={};Diagnostic.__index=Diagnostic
    local function clean(value) return (value:gsub('\r\n','\n'):gsub('\r','\n'):gsub('^%s+',''):gsub('%s+$','')) end
    local function valid(value,limit)
        return type(value)=='string' and #value<=limit*4 and utf8.len(value) and utf8.len(value)<=limit and not value:find('[%z\1-\8\11\12\14-\31]')
    end
    local function excerpt(value,limit)
        local n=utf8.len(value);if not n then return '' end
        return n<=limit and value or value:sub(1,utf8.offset(value,limit+1)-1)..'…'
    end
    local function sensitive(key)
        key=key:lower();return key:find('token',1,true) or key:find('password',1,true) or key:find('secret',1,true) or key:find('cookie',1,true) or key:find('apikey',1,true) or key:find('api_key',1,true) or key:find('api-key',1,true) or key=='authorization' or key=='.roblosecurity'
    end
    function Diagnostic:Sanitize(value)
        local text=clean(value);local before=text
        local token=self.Hub.Options.URL and self.Hub.Options.URL:match('/webhooks/[^/]+/([^?]+)')
        if token then text=text:gsub(token:gsub('([^%w])','%%%1'),'[REDACTED]') end
        text=text:gsub('https://[^/%s]+/api/[^%s]*webhooks/%d+/[%w_%-]+','[WEBHOOK REDACTED]')
        text=text:gsub('[Bb][Ee][Aa][Rr][Ee][Rr]%s+[%w%._~%+/%-=]+','Bearer [REDACTED]')
        text=text:gsub('([%w_.%-]+)(%s*[:=]%s*)(["\'])(.-)%3',function(key,sep,quote,item)
            return key..sep..quote..(sensitive(key) and '[REDACTED]' or item)..quote
        end)
        text=text:gsub('([%w_.%-]+)(%s*[:=]%s*)([^%s,;"\']+)',function(key,sep,item)
            return key..sep..(sensitive(key) and '[REDACTED]' or item)
        end)
        return text,text~=before
    end
    function Diagnostic:GetDraft()
        local c=self.Controls;local selected={}
        for _,label in ipairs(c.Records:GetValue()) do if self.LabelIds[label] then selected[#selected+1]=self.LabelIds[label] end end
        return {Include=c.Include:GetValue(),Text=c.Text.Input.Text,Code=c.Code.Input.Text,Steps=c.Steps.Input.Text,Selected=selected}
    end
    function Diagnostic:CheckDraft(value)
        assert(type(value)=='table','Diagnostic draft must be a table')
        for key in pairs(value) do assert(key=='Include' or key=='Text' or key=='Code' or key=='Steps' or key=='Selected','Unknown diagnostic draft field') end
        if value.Include~=nil then assert(type(value.Include)=='boolean','Diagnostic Include must be boolean') end
        for name,limit in pairs({Text=2000,Code=64,Steps=400}) do if value[name]~=nil then assert(valid(value[name],limit),'Invalid diagnostic '..name) end end
        if value.Selected~=nil then
            assert(type(value.Selected)=='table' and #value.Selected<=5,'Select up to 5 diagnostic records')
            local n,seen=0,{};for key,id in pairs(value.Selected) do n=n+1;assert(type(key)=='number' and key%1==0 and key>=1 and key<=#value.Selected and self.ById[id] and not seen[id],'Invalid diagnostic selection');seen[id]=true end
            assert(n==#value.Selected,'Diagnostic selection must be a dense array')
        end
    end
    function Diagnostic:SetDraft(value)
        self:CheckDraft(value);self.Syncing=true
        for name in pairs({Text=true,Code=true,Steps=true}) do if value[name]~=nil then self.Controls[name]:SetValue(value[name],true) end end
        if value.Include~=nil then self.Controls.Include:SetValue(value.Include,true) end
        if value.Selected then
            local labels={};for label,id in pairs(self.LabelIds) do if table.find(value.Selected,id) then labels[#labels+1]=label end end
            self.Controls.Records:SetValue(labels,true)
        end
        self.Syncing=false;self:Refresh();self.Hub._last=nil;self.Hub:Refresh();return self
    end
    function Diagnostic:Snapshot()
        local draft=self:GetDraft();if not draft.Include then return nil end
        if not valid(draft.Text,2000) or not valid(draft.Code,64) or not valid(draft.Steps,400) then return nil,'DiagnosticInvalid' end
        if #draft.Selected>5 then return nil,'DiagnosticSelection' end
        local text,redacted=self:Sanitize(draft.Text);local code,redactedCode=self:Sanitize(draft.Code);local steps,redactedSteps=self:Sanitize(draft.Steps)
        local records={}
        for _,id in ipairs(draft.Selected) do local record=self.ById[id];if record then local public=copy(record);public.Key=nil;records[#records+1]=public end end
        if text=='' and #records==0 then return nil,'DiagnosticEmpty' end
        local result={Text=text,Code=code,Steps=steps,Records=records,LibraryVersion=Library.Version,ScriptVersion=self.Hub.Options.ScriptVersion,Redacted=redacted or redactedCode or redactedSteps}
        for _,record in ipairs(records) do if record.Redacted then result.Redacted=true end end
        return result
    end
    function Diagnostic:Format(snapshot)
        if not snapshot then return '' end
        local lines={'RetroBox '..snapshot.LibraryVersion}
        if snapshot.ScriptVersion then lines[#lines+1]='Script '..snapshot.ScriptVersion end
        if snapshot.Code~='' then lines[#lines+1]=self:_tr('Código: ','Code: ')..snapshot.Code end
        if snapshot.Text~='' then lines[#lines+1]=snapshot.Text end
        for _,record in ipairs(snapshot.Records) do
            lines[#lines+1]='['..record.Source..' / '..record.Level..'] '..record.Message..(record.Truncated and self:_tr('\n[Registro resumido na captura]','\n[Record shortened during capture]') or '')
        end
        if snapshot.Steps~='' then lines[#lines+1]=self:_tr('Como reproduzir: ','Steps to reproduce: ')..snapshot.Steps end
        return table.concat(lines,'\n\n')
    end
    function Diagnostic:_tr(pt,en) return self.Hub:_tr(pt,en) end
    function Diagnostic:_selected()
        local set={};for _,id in ipairs(self:GetDraft().Selected) do set[id]=true end;return set
    end
    function Diagnostic:Add(message,source,level)
        if self.Destroyed or type(message)~='string' or not utf8.len(message) then return end
        message=message:gsub('[%z\1-\8\11\12\14-\31]','')
        local sanitized,redacted=self:Sanitize(message);if sanitized=='' then return end
        local key=Library:SHA256(source..'/'..level..'/'..sanitized);if self.Seen[key] then return end
        self.Seq=self.Seq+1;local id='record-'..self.Seq
        local r={Id=id,Source=source,Level=level,Message=excerpt(sanitized,2000),Redacted=redacted,Truncated=utf8.len(sanitized)>2000,Key=key}
        self.Records[#self.Records+1]=r;self.ById[id]=r;self.Seen[key]=true
        if #self.Records>80 then
            local selected=self:_selected();local index
            for i,record in ipairs(self.Records) do if not selected[record.Id] then index=i;break end end
            local removed=table.remove(self.Records,index or #self.Records);self.ById[removed.Id]=nil;self.Seen[removed.Key]=nil
        end
        self:_queueRefresh()
    end
    function Diagnostic:_queueRefresh()
        if self.Pending or self.Destroyed then return end
        self.Pending=task.defer(function()
            self.Scope:Remove('diagnostic-refresh',true);self.Pending=nil
            if not self.Destroyed then self:Refresh() end
        end)
        self.Scope:Add(self.Pending,function(thread) if coroutine.status(thread)=='suspended' then task.cancel(thread) end end,'diagnostic-refresh')
    end
    function Diagnostic:Collect()
        if self.Destroyed then return false end
        local windows=0
        for window in pairs(Library.Windows) do
            if not window.Destroyed and windows<16 then
                windows=windows+1
                for _,record in ipairs(window:GetDiagnostics()) do self:Add(record.Message..(record.Traceback and '\n'..record.Traceback or ''),'RetroBox','Error') end
            end
        end
        -- Capability probe only: some client/executor environments deny LogService access.
        local ok,history=pcall(function() return game:GetService('LogService'):GetLogHistory() end)
        if self.Destroyed then return false end
        if ok and type(history)=='table' then
            for i=math.max(1,#history-159),#history do
                local record=history[i];if type(record)=='table' then
                    local kind=tostring(record.messageType)
                    if kind:find('MessageError',1,true) then self:Add(record.message,'Console','Error')
                    elseif kind:find('MessageWarning',1,true) then self:Add(record.message,'Console','Warning') end
                end
            end
        end
        self.Available=ok and type(history)=='table';self:Refresh();return self.Available
    end
    function Diagnostic:SetCapturing(value)
        assert(type(value)=='boolean','Capture must be boolean')
        if self.Destroyed then return false end
        self.Scope:Remove('console-capture');self.Capturing=false
        if value then
            -- A denied event is reported as unavailable; manual attachments remain usable.
            local ok,connection=pcall(function() return game:GetService('LogService').MessageOut:Connect(function(message,messageType)
                if self.Destroyed or self.Hub.Window._shown==false or self.Hub.Window.Minimized or not self.Hub.Tab.Frame.Visible then return end
                local kind=tostring(messageType)
                if kind:find('MessageError',1,true) then self:Add(message,'Console','Error')
                elseif kind:find('MessageWarning',1,true) then self:Add(message,'Console','Warning') end
            end) end)
            if self.Destroyed then if ok and connection then connection:Disconnect() end;return false end
            if ok and connection then self.Scope:Add(connection,'Disconnect','console-capture');self.Capturing=true else self.Available=false end
        end
        self.Controls.Live:SetValue(self.Capturing,true);self:Refresh();return self.Capturing
    end
    function Diagnostic:GetRecords() local result=copy(self.Records);for _,record in ipairs(result) do record.Key=nil end;return result end
    function Diagnostic:Clear()
        self:SetDraft({Include=false,Text='',Code='',Steps='',Selected={}});return self
    end
    function Diagnostic:CopyPreview()
        local snapshot=self:Snapshot();local value=self:Format(snapshot);self.Controls.Preview.Input:CaptureFocus()
        self.Controls.Preview.Input.SelectionStart=1;self.Controls.Preview.Input.CursorPosition=#value+1
        if type(setclipboard)=='function' then
            local ok=pcall(setclipboard,value);self.Copied=ok
        else self.Copied=false end
        self:Refresh();return value,self.Copied
    end
    function Diagnostic:Refresh()
        if self.Destroyed or self.Syncing then return end;self.Syncing=true
        local c=self.Controls;local selected=self:_selected();local labels={};self.LabelIds={}
        for _,record in ipairs(self.Records) do
            local text='#'..record.Id:match('%d+')..' ['..record.Source..' / '..(record.Level=='Error' and self:_tr('ERRO','ERROR') or self:_tr('AVISO','WARNING'))..'] '..excerpt(record.Message:gsub('\n',' '),72)
            labels[#labels+1]=text;self.LabelIds[text]=record.Id
        end
        c.Records:SetOptions(labels,false);local selectedLabels={}
        for _,text in ipairs(labels) do if selected[self.LabelIds[text]] then selectedLabels[#selectedLabels+1]=text end end
        c.Records:SetValue(selectedLabels,true)
        self.Section:SetTitle(self:_tr('Diagnóstico do problema','Problem diagnostics'))
        for name,pair in pairs(self.Captions) do c[name]:SetTitle(self:_tr(pair[1],pair[2]));if c[name].Button then c[name].Button.Text=self:_tr(pair[1],pair[2]) end end
        c.Intro:SetText(self:_tr('Cole o erro e/ou carregue registros para marcar até 5. Nada é anexado sem ativar a opção abaixo.','Paste an error and/or load records to select up to 5. Nothing is attached unless you enable the option below.'))
        local included=c.Include:GetValue()
        for _,name in ipairs({'Text','Code','Steps','Records','Preview','Copy','Clear'}) do c[name]:SetVisible(included) end
        c.Collect:SetVisible(included);c.Live:SetVisible(included)
        if not included and self.Capturing then self.Scope:Remove('console-capture');self.Capturing=false;c.Live:SetValue(false,true) end
        local snapshot,why=self:Snapshot();local formatted=self:Format(snapshot)
        c.Preview:SetValue(formatted,true)
        c.Note:SetText(why and self.Hub:_message(why) or snapshot and (snapshot.Redacted and self:_tr('Padrões de segredo reconhecidos foram removidos. Revise esta prévia antes de enviar.','Recognized secret patterns were removed. Review this preview before sending.') or self:_tr('Somente este diagnóstico será anexado ao envio.','Only this diagnostic preview will be attached.')) or self:_tr('Diagnóstico opcional: desativado.','Optional diagnostics: disabled.'))
        c.CollectionStatus:SetText((self.Available==false and self:_tr('Histórico indisponível neste ambiente. Você pode colar o erro manualmente.','History unavailable in this environment. You can paste the error manually.') or self:_tr('Registros disponíveis: ','Available records: ')..#self.Records)..(self.Capturing and self:_tr(' · Captura ativa',' · Capture active') or '')..(self.Copied==false and self:_tr(' · Selecione e copie o texto da prévia.',' · Select and copy the preview text.') or self.Copied and self:_tr(' · Prévia copiada.',' · Preview copied.') or ''))
        self.Syncing=false
    end
    function Diagnostic:Destroy()
        if self.Destroyed then return end;self.Destroyed=true
        self.Scope:Destroy();self.Records={};self.ById={};self.Seen={};self.LabelIds={};self.Controls={};self.Pending=nil;self.Capturing=false
    end
    function Window:_createFeedbackDiagnostics(hub,add)
        local d=setmetatable({Hub=hub,Scope=hub.Scope:Child(),Controls={},Records={},ById={},Seen={},LabelIds={},Captions={},Seq=0},Diagnostic)
        d.Section=hub.Tab:CreateSection({Title=hub:_tr('Diagnóstico do problema','Problem diagnostics'),Icon='warning'})
        local function control(method,name,pt,en,opts)
            local c=add(d.Section,method,'Diagnostic'..name,pt,en,opts);d.Controls[name]=c;d.Captions[name]={pt,en};return c
        end
        control('AddLabel','Intro','','',{Height=96})
        control('AddToggle','Include','Anexar diagnóstico ao envio','Attach diagnostics to submission',{Default=false})
        control('AddInput','Text','Erro / stack trace copiado','Copied error / stack trace',{Multiline=true,Live=true,MaxLength=8000})
        control('AddInput','Code','Código ou tag do erro (opcional)','Error code or tag (optional)',{Live=true,MaxLength=256})
        control('AddInput','Steps','Como reproduzir (opcional)','Steps to reproduce (optional)',{Multiline=true,Live=true,MaxLength=1600})
        control('AddButton','Collect','Carregar erros disponíveis','Load available errors',{Icon='refresh',Callback=function() d:Collect();hub:Refresh() end})
        control('AddToggle','Live','Acompanhar novos erros nesta tela','Capture new errors while this screen is open',{Default=false,Callback=function(value) d:SetCapturing(value) end})
        control('AddDropdown','Records','Marcar registros para anexar (até 5)','Select records to attach (up to 5)',{Multi=true,Options={},Default={}})
        control('AddInput','Preview','Diagnóstico que será enviado','Diagnostics to be sent',{Multiline=true,MaxLength=65536})
        d.Controls.Preview.Input.TextEditable=false
        control('AddLabel','Note','','',{Height=96})
        control('AddLabel','CollectionStatus','','',{Height=80})
        control('AddButton','Copy','Copiar diagnóstico da prévia','Copy diagnostic preview',{Icon='copy',Callback=function() d:CopyPreview() end})
        control('AddButton','Clear','Limpar diagnóstico','Clear diagnostics',{Icon='reset',Callback=function() d:Clear();hub:Refresh() end})
        for _,name in ipairs({'Include','Text','Code','Steps','Records'}) do
            d.Scope:Add(d.Controls[name]:OnChanged(function()
                if not d.Syncing then hub._last=nil;d:Refresh();hub:Refresh() end
            end),'Disconnect')
        end
        for _,name in ipairs({'Text','Code','Steps','Preview'}) do self:SetTextTranslation(d.Controls[name].Input,false) end
        self:SetTextTranslation(d.Controls.Intro.Frame,false);self:SetTextTranslation(d.Controls.Note.Frame,false);self:SetTextTranslation(d.Controls.CollectionStatus.Frame,false)
        d:Refresh();return d
    end
end
