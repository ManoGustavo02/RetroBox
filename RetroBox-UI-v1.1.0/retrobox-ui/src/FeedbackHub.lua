-- Explicit opt-in communication UI. No network request is sent on construction.
do
    local Feedback={};Feedback.__index=Feedback
    local kinds={ScriptRequest={'Pedir script para um jogo','Request a game script'},Suggestion={'Sugerir melhoria','Suggest an improvement'},Feedback={'Enviar feedback','Share feedback'},BugReport={'Relatar problema','Report a problem'}}
    local order={'ScriptRequest','Suggestion','Feedback','BugReport'}
    local messages={
        Destroyed={'A Central de Ideias foi encerrada.','The Ideas Center has been closed.'},
        Idle={'Escreva sua ideia e confira a prévia antes de enviar.','Write your idea and review the preview before sending.'},
        Empty={'Escreva uma mensagem antes de enviar.','Write a message before sending.'},
        Short={'Sua mensagem precisa de mais detalhes.','Please add more detail to your message.'},
        Long={'Sua mensagem ultrapassa o limite de caracteres.','Your message exceeds the character limit.'},
        InvalidText={'A mensagem contém texto inválido.','The message contains invalid text.'},
        InvalidGame={'Informe um ID de jogo ou link oficial válido do Roblox.','Enter a valid game ID or official Roblox game link.'},
        Identity={'Aguardando o nome e o usuário reais desta sessão…','Waiting for this session’s real player name and username…'},
        NotConfigured={'O responsável ainda não configurou o envio.','The owner has not configured submissions yet.'},
        Unavailable={'Este executor não disponibiliza o transporte de envio configurado.','This executor does not provide the configured submission transport.'},
        Busy={'Há um envio em andamento.','A submission is already in progress.'},
        Cooldown={'Aguarde antes de enviar outra mensagem.','Please wait before submitting another message.'},
        Duplicate={'Esta mensagem já foi enviada recentemente.','This message was already sent recently.'},
        Sending={'Enviando para o Discord…','Sending to Discord…'},
        SentDraft={'A mensagem anterior foi enviada. Seu novo rascunho foi mantido.','The previous message was sent. Your new draft was kept.'},
        Sent={'Mensagem enviada. Obrigado por compartilhar sua ideia!','Message sent. Thank you for sharing your idea!'},
        Unconfirmed={'Não foi possível confirmar a entrega. Confira o canal antes de reenviar.','Delivery could not be confirmed. Check the channel before resending.'},
        RateLimited={'O Discord pediu uma pausa. Aguarde o tempo informado.','Discord requested a pause. Wait for the indicated time.'},
        Rejected={'O Discord recusou o envio. O responsável deve conferir o webhook e o canal.','Discord rejected the submission. The owner should check the webhook and channel.'},
        Cancelled={'Envio cancelado antes de iniciar. Sua mensagem foi mantida.','Submission cancelled before starting. Your message was kept.'},
    }
    local function default(value,fallback) if value==nil then return fallback end;return value end
    local function trim(value) return (value:gsub('^%s+',''):gsub('%s+$','')) end
    local function count(value) return utf8.len(value) end
    local function excerpt(value,limit)
        local n=count(value);if not n then return '' end
        if n<=limit then return value end
        return value:sub(1,utf8.offset(value,limit+1)-1)..'…'
    end
    local function validId(value)
        local n=type(value)=='string' and value:match('^%d+$') and tonumber(value) or value
        return finite(n) and n%1==0 and n>0 and n<=9007199254740991 and n or nil
    end
    local function gameId(value)
        if validId(value) then return validId(value) end
        if type(value)~='string' then return nil end
        local host,path=trim(value):match('^https://([^/%?#]+)(/[^?#]*)')
        if host~='www.roblox.com' and host~='roblox.com' then return nil end
        return validId(path:match('^/games/(%d+)/') or path:match('^/games/(%d+)$'))
    end
    local function webhook(value,thread)
        if value==nil or value=='' then return nil end
        assert(type(value)=='string' and #value<=1024,'WebhookURL must be a Discord webhook URL')
        local host,path=value:match('^https://([^/%?#]+)(/[^?#]+)$')
        assert(host=='discord.com' or host=='discordapp.com' or host=='canary.discord.com' or host=='ptb.discord.com','WebhookURL must use an official Discord HTTPS host')
        local id,token=path:match('^/api/webhooks/(%d+)/([%w_%-]+)$')
        if not id then id,token=path:match('^/api/v%d+/webhooks/(%d+)/([%w_%-]+)$') end
        assert(id and #id<=24 and #id>=6 and #token>=16 and #token<=256,'WebhookURL has an invalid webhook ID or token')
        local url='https://discord.com/api/v10/webhooks/'..id..'/'..token..'?wait=true'
        if thread then url=url..'&thread_id='..thread end
        return url
    end
    local function httpsImage(value)
        if type(value)~='string' or #value>2048 then return nil end
        local host=value:match('^https://([^/%?#]+)/')
        if host and host:match('^[%w%.%-]+$') and (host=='rbxcdn.com' or host:match('%.rbxcdn%.com$') or host=='www.roblox.com') then return value end
    end
    local function checked(options)
        assert(type(options)=='table','Feedback Hub options must be a table')
        local result={Id=options.Id or 'feedback',Categories={},Cooldown=options.Cooldown==nil and 30 or options.Cooldown,
            DuplicateWindow=default(options.DuplicateWindow,600),Timeout=default(options.Timeout,20),MinLength=default(options.MinLength,10),MaxLength=default(options.MaxLength,2000),
            IncludeAvatar=options.IncludeAvatar~=false,ClearOnSuccess=options.ClearOnSuccess==true}
        assert(type(result.Id)=='string' and result.Id:match('^[%w_.%-]+$') and #result.Id<=64,'Feedback Id must contain 1–64 letters, numbers, dots, underscores or hyphens')
        for name,range in pairs({Cooldown={0,3600},DuplicateWindow={30,3600},Timeout={1,120},MinLength={1,2000},MaxLength={1,2000}}) do
            assert(finite(result[name]) and result[name]>=range[1] and result[name]<=range[2], 'Invalid feedback '..name)
        end
        assert(result.MinLength%1==0 and result.MaxLength%1==0 and result.MinLength<=result.MaxLength,'Feedback text limits must be integer and ordered')
        for _,name in ipairs({'IncludeAvatar','ClearOnSuccess'}) do assert(options[name]==nil or type(options[name])=='boolean',name..' must be boolean') end
        for _,name in ipairs({'Request','Transport','MetadataProvider','AvatarProvider','OnSent'}) do assert(options[name]==nil or type(options[name])=='function',name..' must be a function');result[name]=options[name] end
        assert(not options.Transport or not options.WebhookURL and not options.Request,'Use Transport independently from WebhookURL/Request')
        if options.ThreadId~=nil then assert(type(options.ThreadId)=='string' and options.ThreadId:match('^%d+$') and #options.ThreadId<=24,'ThreadId must be a Discord ID') end
        result.URL=webhook(options.WebhookURL,options.ThreadId)
        result.CooldownKey=options.CooldownKey or result.Id
        assert(type(result.CooldownKey)=='string' and #result.CooldownKey>=1 and #result.CooldownKey<=128,'Invalid CooldownKey')
        local supplied=options.Categories or order
        assert(type(supplied)=='table' and #supplied>=1 and #supplied<=4,'Categories must contain 1–4 known category IDs')
        local total=0;for key in pairs(supplied) do total=total+1;assert(type(key)=='number' and key%1==0 and key>=1 and key<=#supplied,'Categories must be a dense array') end
        assert(total==#supplied,'Categories must be a dense array')
        local seen={};for _,kind in ipairs(supplied) do assert(kinds[kind] and not seen[kind],'Unknown or duplicate feedback category');seen[kind]=true;result.Categories[#result.Categories+1]=kind end
        result.DefaultCategory=default(options.DefaultCategory,result.Categories[1])
        assert(seen[result.DefaultCategory],'DefaultCategory must be enabled')
        if options.Game~=nil then assert(options.Game=='current' or gameId(options.Game),'Invalid feedback Game') end
        result.Game=options.Game or 'current'
        return result
    end
    -- Session-only bounded ledger contains hashes/timing, never drafts or URLs.
    local ledger={}
    do
        local env=_G
        if type(getgenv)=='function' then local ok,result=pcall(getgenv);if ok and type(result)=='table' then env=result end end
        if type(env)=='table' then
            local ok,value=pcall(function()
                if type(env.__RetroBoxFeedbackLedger)~='table' then env.__RetroBoxFeedbackLedger={} end
                return env.__RetroBoxFeedbackLedger
            end)
            if ok then ledger=value end
        end
    end
    local function entry(key)
        local now=os.clock();local result=ledger[key]
        if not result then
            local n,oldest,age=0,nil,math.huge
            for id,item in pairs(ledger) do n=n+1;if (item.PendingUntil or 0)<=now and (item.Use or 0)<age then oldest=id;age=item.Use or 0 end end
            if n>=64 then if not oldest then return nil end;ledger[oldest]=nil end
            result={Next=0,PendingUntil=0,Seen={}};ledger[key]=result
        end
        result.Use=now
        for hash,item in pairs(result.Seen) do if item.Until<=now then result.Seen[hash]=nil end end
        return result
    end
    local function requester(explicit)
        if explicit then return explicit end
        if type(request)=='function' then return request end
        if type(http_request)=='function' then return http_request end
        if type(syn)=='table' and type(syn.request)=='function' then return syn.request end
        if type(http)=='table' and type(http.request)=='function' then return http.request end
    end
    local function normalized(response)
        if type(response)~='table' or getmetatable(response)~=nil then return {Code='Unconfirmed'} end
        local status=response.StatusCode or response.status_code
        if not finite(status) or status%1~=0 or status<100 or status>599 then return {Code='Unconfirmed'} end
        local body=response.Body or response.body
        local decoded
        if type(body)=='string' and #body<=262144 then local ok,value=pcall(HttpService.JSONDecode,HttpService,body);if ok and type(value)=='table' then decoded=value end end
        if status==200 and decoded and type(decoded.id)=='string' and #decoded.id>=6 and #decoded.id<=24 and decoded.id:match('^%d+$') then return {Code='Sent',HTTPStatus=status,MessageId=decoded.id} end
        if status==429 then
            local seconds=decoded and decoded.retry_after
            for key,value in pairs(type(response.Headers)=='table' and response.Headers or type(response.headers)=='table' and response.headers or {}) do
                if type(key)=='string' and key:lower()=='retry-after' and (type(value)=='string' or type(value)=='number') then seconds=tonumber(value) or seconds end
            end
            return {Code='RateLimited',HTTPStatus=status,RetryAfter=finite(seconds) and seconds>=0 and seconds<=86400 and seconds or 60}
        end
        return {Code=status>=400 and status<500 and 'Rejected' or 'Unconfirmed',HTTPStatus=status}
    end
    -- The HTTP worker holds only an immutable request and a mailbox; timing out
    -- or destroying UI detaches that mailbox, so late results cannot retain GUI.
    local function dispatch(operation,transport,requestFunction,spec,payload)
        operation.Posted=true
        local ok,response
        if transport then ok,response=pcall(transport,copy(payload)) else ok,response=pcall(requestFunction,spec) end
        local result=ok and normalized(response) or {Code='Unconfirmed'}
        local item=operation.Entry
        if item.Token==operation.Token then item.PendingUntil=0 end
        if result.Code=='RateLimited' then item.Next=math.max(item.Next,os.clock()+result.RetryAfter) end
        item.Seen[operation.Fingerprint]={Code=result.Code,Until=os.clock()+operation.DuplicateWindow}
        if operation.Mailbox and not operation.Mailbox.Destroyed then operation.Mailbox:Set({Done=true,Result=result}) end
    end
    local function await(operation,ctx,timeout)
        local scope=ctx.Resources:Child();local outcome,parked,settled
        local thread=coroutine.running()
        local function resolve(value)
            if settled then return end;settled=true;outcome=value;scope:Destroy()
            if parked and coroutine.status(thread)=='suspended' then task.defer(thread,value) end
        end
        scope:Add(operation.Mailbox:Subscribe(function(value) if value.Done then resolve(value.Result) end end),'Disconnect')
        scope:Add(ctx:OnCancel(function() resolve({Code=operation.Posted and 'Unconfirmed' or 'Cancelled'}) end),'Disconnect')
        local timer=task.delay(timeout,function() scope:Remove('timeout',true);resolve({Code='Unconfirmed'}) end)
        scope:Add(timer,function(t) if t~=coroutine.running() and coroutine.status(t)=='suspended' then task.cancel(t) end end,'timeout')
        local current=operation.Mailbox:Get();if current.Done then resolve(current.Result) end
        if settled then return outcome end
        parked=true;return coroutine.yield()
    end
    function Feedback:_tr(pt,en) return self.Window:_t17(pt,en) end
    function Feedback:_message(code) local pair=messages[code] or messages.Idle;return self:_tr(pair[1],pair[2]) end
    function Feedback:_identity()
        local player=Players.LocalPlayer
        if not player or not validId(player.UserId) or type(player.Name)~='string' or trim(player.Name)=='' or type(player.DisplayName)~='string' or trim(player.DisplayName)=='' or not count(player.Name) or not count(player.DisplayName) or count(player.Name)>128 or count(player.DisplayName)>128 then return nil end
        return {UserId=player.UserId,Name=player.Name,DisplayName=player.DisplayName}
    end
    function Feedback:_entry(identity)
        return entry(Library:SHA256((self.Options.URL or 'adapter:'..self.Options.CooldownKey)..'/'..tostring(identity.UserId)))
    end
    function Feedback:GetDraft()
        return {Category=self.Category,Message=self.Controls.Message.Input.Text,Game=self.Controls.CurrentGame:GetValue() and 'current' or self.Controls.Target.Input.Text}
    end
    function Feedback:SetDraft(value)
        assert(not self.Destroyed and type(value)=='table','Draft must be a table on a live Feedback Hub')
        for key in pairs(value) do assert(key=='Category' or key=='Message' or key=='Game','Unknown feedback draft field') end
        if value.Category~=nil then assert(table.find(self.Options.Categories,value.Category),'Unknown feedback category') end
        if value.Message~=nil then assert(type(value.Message)=='string' and #value.Message<=self.Options.MaxLength*4 and count(value.Message),'Invalid draft text') end
        if value.Game~=nil then assert(value.Game=='current' or gameId(value.Game),'Invalid feedback game') end
        self._syncing=true
        if value.Category then self.Category=value.Category end
        if value.Message then self.Controls.Message:SetValue(value.Message,true) end
        if value.Game then
            self.Controls.CurrentGame:SetValue(value.Game=='current',true)
            self.Controls.Target:SetValue(value.Game=='current' and '' or tostring(gameId(value.Game)),true)
        end
        self._syncing=false;self._last=nil;self:_refreshLocale();return self
    end
    function Feedback:SetMessage(value) return self:SetDraft({Message=value}) end
    function Feedback:SetCategory(value) return self:SetDraft({Category=value}) end
    function Feedback:SetGame(value) return self:SetDraft({Game=value}) end
    function Feedback:ClearDraft() self:SetMessage('');return self end
    function Feedback:GetPreview()
        if self.Destroyed then return nil,'Destroyed' end
        local draft=self:GetDraft();local message=trim(draft.Message:gsub('\r\n','\n'):gsub('\r','\n'))
        local length=count(message)
        if not length or message:find('[%z\1-\8\11\12\14-\31]') then return nil,'InvalidText' end
        if length==0 then return nil,'Empty' end
        if length<self.Options.MinLength then return nil,'Short' end
        if length>self.Options.MaxLength then return nil,'Long' end
        local id=draft.Game=='current' and validId(game.PlaceId) or gameId(draft.Game)
        if not id then return nil,'InvalidGame' end
        local identity=self:_identity();if not identity then return nil,'Identity' end
        return {Category=self.Category,Message=message,Game={PlaceId=id,Name=self._game and self._game.Id==id and self._game.Name or 'Game '..string.format('%.0f',id),URL='https://www.roblox.com/games/'..string.format('%.0f',id)},
            Player={Name=identity.Name,DisplayName=identity.DisplayName,AvatarURL=self.Options.IncludeAvatar and self._avatar and self._avatar.UserId==identity.UserId and self._avatar.URL or nil}}
    end
    function Feedback:BuildPayload()
        local preview,reason=self:GetPreview();if not preview then return nil,reason end
        local pair=kinds[preview.Category]
        local function field(pt,en,value,inline) return {name=self:_tr(pt,en),value=value,inline=inline==true} end
        local embed={title=self:_tr(pair[1],pair[2]),description=preview.Message,url=preview.Game.URL,color=4505476,
            author={name=excerpt(preview.Player.DisplayName..' (@'..preview.Player.Name..')',120)},
            fields={field('Jogo','Game',preview.Game.Name),field('Link do jogo','Game link',preview.Game.URL),field('ID do jogo','Place ID',string.format('%.0f',preview.Game.PlaceId),true),
                field('Nome do jogador','Player display name',preview.Player.DisplayName,true),field('Usuário','Username','@'..preview.Player.Name,true)}}
        if preview.Player.AvatarURL then embed.thumbnail={url=preview.Player.AvatarURL} end
        return {embeds={embed},allowed_mentions={parse={}}},preview
    end
    function Feedback:Validate(options)
        options=options or {}
        if self.Destroyed then return false,'Destroyed' end
        if self._operation then return false,'Busy' end
        local preview,reason=self:GetPreview();if not preview then return false,reason end
        if not self.Options.Transport and not self.Options.URL then return false,'NotConfigured' end
        if not self.Options.Transport and not requester(self.Options.Request) then return false,'Unavailable' end
        local item=self:_entry(self:_identity());if not item then return false,'Busy' end
        local now=os.clock()
        if item.PendingUntil>now then return false,'Busy' end
        if item.Next>now then return false,'Cooldown',math.ceil(item.Next-now) end
        local hash=Library:SHA256(preview.Category..'/'..tostring(preview.Game.PlaceId)..'/'..preview.Message)
        local previous=item.Seen[hash]
        if previous and (previous.Code=='Sent' or previous.Code=='Unconfirmed' and options.RetryUnconfirmed~=true) then return false,previous.Code=='Sent' and 'Duplicate' or 'Unconfirmed' end
        return true,preview,hash,item
    end
    function Feedback:GetStatus()
        local ok,reason,extra=self:Validate()
        local code=self._operation and 'Sending' or self._last and self._last.Code or ok and 'Idle' or reason
        return {State=code,Message=self:_message(code=='Sent' and self._last and self._last.NewDraft and 'SentDraft' or code),CanSubmit=ok,Validation=not ok and reason or nil,RetryAfter=not ok and reason=='Cooldown' and extra or nil,
            HTTPStatus=self._last and self._last.HTTPStatus,MessageId=self._last and self._last.MessageId}
    end
    function Feedback:_settle(operation,result)
        if self.Destroyed or self._operation~=operation then return end
        self._operation=nil;self._last=copy(result)
        if result.Code=='Sent' then
            self._last.NewDraft=not same(self:GetDraft(),operation.Draft)
            if self.Options.ClearOnSuccess and same(self:GetDraft(),operation.Draft) then self.Controls.Message:SetValue('',true) end
            if self.Options.OnSent then self.Window:_dispatch(self.Options.OnSent,{Phase='FeedbackSent'},copy(operation.Preview),copy(result)) end
        end
        self:Refresh()
    end
    function Feedback:Submit(options)
        options=options or {};assert(type(options)=='table' and (options.RetryUnconfirmed==nil or type(options.RetryUnconfirmed)=='boolean'),'Submit options must contain a boolean RetryUnconfirmed')
        for name in pairs(options) do assert(name=='RetryUnconfirmed','Unknown Submit option') end
        local ok,preview,hash,item=self:Validate(options)
        if not ok then self:Refresh();return nil,preview end
        local payload=assert(self:BuildPayload());local body=HttpService:JSONEncode(payload):gsub('"parse":%s*{}','"parse":[]')
        local wire={Entry=item,Fingerprint=hash,Token={},DuplicateWindow=self.Options.DuplicateWindow,Mailbox=Library:CreateState({Done=false})}
        local operation={Wire=wire,Preview=preview,Draft=self:GetDraft(),Scope=self.Scope:Child()}
        operation.Scope:Add(function()
            local mailbox=wire.Mailbox;wire.Mailbox=nil;if mailbox then mailbox:Destroy() end
            if not wire.Posted then
                if item.Token==wire.Token then item.PendingUntil=0;item.Next=0 end
                item.Seen[hash]=nil
            end
        end)
        local n=0;for _ in pairs(item.Seen) do n=n+1 end;if n>=32 then local oldest,age;for key,value in pairs(item.Seen) do if not age or value.Until<age then oldest,age=key,value.Until end end;item.Seen[oldest]=nil end
        item.Token=wire.Token;item.Next=os.clock()+self.Options.Cooldown;item.PendingUntil=os.clock()+self.Options.Timeout
        item.Seen[hash]={Code='Unconfirmed',Until=os.clock()+self.Options.DuplicateWindow}
        self._operation=operation;self._last=nil
        local transport=self.Options.Transport;local send=requester(self.Options.Request)
        local spec={Url=self.Options.URL,Method='POST',Headers={['Content-Type']='application/json'},Body=body,Timeout=self.Options.Timeout}
        local hub=self;local timeout=self.Options.Timeout
        local handle,reason=self.Window:RunAction({Group='feedback/'..self.Id,Policy='Reject',Callback=function(ctx)
            ctx:ThrowIfCancelled()
            task.defer(function() if wire.Mailbox then dispatch(wire,transport,send,spec,payload) end end)
            local result=await(wire,ctx,timeout)
            hub:_settle(operation,result)
            if ctx:IsCancelled() then ctx:ThrowIfCancelled() end
            return result
        end,OnComplete=function(handle)
            if not hub.Destroyed and hub._operation==operation then hub:_settle(operation,{Code=wire.Posted and 'Unconfirmed' or 'Cancelled'}) end
            operation.Scope:Destroy()
        end})
        if not handle then operation.Scope:Destroy();self._operation=nil;return nil,reason end
        operation.Handle=handle
        self:Refresh();return handle
    end
    function Feedback:CancelSubmission()
        if self._operation and self._operation.Handle then self._operation.Handle:Cancel('feedback cancelled');return true end
        return false
    end
    function Feedback:_loadContext()
        local state=self._context;local identity=self:_identity()
        if identity and state.UserId~=identity.UserId then
            state.UserId=identity.UserId;self._avatar=nil
            if self.Options.IncludeAvatar then
                local id=identity.UserId;local provider=self.Options.AvatarProvider
                task.defer(function()
                    if not state.Owner then return end
                    local ok,url,ready=pcall(function() if provider then return provider(id) end;return Players:GetUserThumbnailAsync(id,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end)
                    local owner=state.Owner
                    if owner and state.UserId==id then owner._avatar={UserId=id,URL=ok and ready~=false and httpsImage(url) or nil};owner:Refresh() end
                end)
            end
        end
        local draft=self:GetDraft();local id=draft.Game=='current' and validId(game.PlaceId) or gameId(draft.Game)
        if id~=state.GameId then
            state.GameId=id;state.Generation=state.Generation+1;self._game=nil
            if id then
                local generation=state.Generation;local provider=self.Options.MetadataProvider
                task.defer(function()
                    if not state.Owner then return end
                    local ok,data=pcall(function()
                        if provider then return provider(id) end
                        local service=game:GetService('MarketplaceService');local found,method=pcall(function() return service.GetProductInfoAsync end)
                        if not found or type(method)~='function' then method=service.GetProductInfo end
                        return method(service,id,Enum.InfoType.Asset)
                    end)
                    local owner=state.Owner
                    if owner and state.Generation==generation then
                        local name=ok and type(data)=='table' and data.Name
                        owner._game={Id=id,Name=type(name)=='string' and count(name) and trim(name)~='' and excerpt(name,128) or 'Game '..string.format('%.0f',id),Available=ok and type(name)=='string' and count(name)~=nil and trim(name)~=''}
                        owner:Refresh()
                    end
                end)
            end
        end
    end
    function Feedback:_refreshLocale()
        if self.Destroyed or not self._ready then return end
        self._syncing=true
        local captions={};self._categoryLabels={}
        for _,id in ipairs(self.Options.Categories) do local pair=kinds[id];local caption=self:_tr(pair[1],pair[2]);captions[#captions+1]=caption;self._categoryLabels[caption]=id end
        self.Controls.Category:SetOptions(captions,false);self.Controls.Category:SetValue(self:_tr(kinds[self.Category][1],kinds[self.Category][2]),true)
        for control,pair in pairs(self._captions) do control:SetTitle(self:_tr(pair[1],pair[2])) end
        self.Tab:SetTitle(self:_tr('Central de Ideias','Ideas Center'))
        if self._defaultTitle and self.OwnsWindow then self.Window:SetTitle(self:_tr('Central de Ideias','Ideas Center')) end
        if self._defaultSubtitle and self.OwnsWindow then self.Window:SetSubtitle(self:_tr('Feedback e sugestões de scripts','Feedback and script suggestions')) end
        self.Controls.Message:SetDescription(self:_tr('De '..self.Options.MinLength..' a '..self.Options.MaxLength..' caracteres.','Between '..self.Options.MinLength..' and '..self.Options.MaxLength..' characters.'))
        self.Controls.Target.Input.PlaceholderText=self:_tr('ID ou https://www.roblox.com/games/…','ID or https://www.roblox.com/games/…')
        self.Controls.Message.Input.PlaceholderText=self:_tr('Conte sua ideia, o que você precisa ou o que poderia melhorar…','Tell us your idea, what you need or what could improve…')
        self.Controls.Submit.Button.Text=self:_tr('Enviar para o Discord','Send to Discord')
        self.Controls.Clear.Button.Text=self:_tr('Limpar mensagem','Clear message')
        self.Controls.Cancel.Button.Text=self:_tr('Parar espera','Stop waiting')
        self.Controls.Retry.Button.Text=self:_tr('Reenviar com confirmação','Resend with confirmation')
        self._syncing=false;self:Refresh()
    end
    function Feedback:Refresh()
        if self.Destroyed or not self._ready or self._refreshing or self._syncing then return end
        self._refreshing=true;self:_loadContext()
        local c=self.Controls;local draft=self:GetDraft();local preview,why=self:GetPreview();local status=self:GetStatus()
        local normalizedMessage=trim(draft.Message:gsub('\r\n','\n'):gsub('\r','\n'))
        local identity=self:_identity();local id=draft.Game=='current' and validId(game.PlaceId) or gameId(draft.Game)
        c.Target:SetVisible(not c.CurrentGame:GetValue())
        c.Counter:SetText(tostring(count(normalizedMessage) or 0)..' / '..self.Options.MaxLength..self:_tr(' caracteres',' characters'))
        c.GamePreview:SetText(self._game and self._game.Name or id and ('Game '..string.format('%.0f',id)) or self:_tr('Nenhum jogo válido','No valid game'))
        c.GameLink:SetText(id and 'https://www.roblox.com/games/'..string.format('%.0f',id) or '')
        c.PlaceId:SetText(id and self:_tr('ID do jogo: ','Place ID: ')..string.format('%.0f',id) or '')
        c.Identity:SetText(identity and identity.DisplayName..' (@'..identity.Name..')' or self:_message('Identity'))
        c.MessagePreview:SetText(excerpt(normalizedMessage,320))
        c.MessagePreview:SetDescription((count(normalizedMessage) or 0)>320 and self:_tr('Prévia resumida; a mensagem completa será enviada.','Short preview; your complete message will be sent.') or '')
        c.Notice:SetText(self:_tr('Ao enviar, você compartilha o jogo, o link e ID, sua mensagem, nome, @usuário e avatar disponível com o responsável no Discord.','Sending shares the game, link and ID, your message, display name, @username and available avatar with the owner on Discord.'))
        local label=status.Message
        if status.RetryAfter then label=label..' '..status.RetryAfter..'s' end
        c.Status:SetText(label);c.Submit:SetDisabled(not status.CanSubmit)
        self.Window:_bind(c.Status.TitleLabel,{TextColor3=status.State=='Sent' and 'Success' or (status.State=='Rejected' or status.State=='Unconfirmed') and 'Danger' or status.State=='Sending' and 'Accent' or 'Muted'})
        c.Cancel:SetVisible(self._operation~=nil);c.Clear:SetDisabled(self._operation~=nil)
        c.Retry:SetVisible(not self._operation and (self._last and self._last.Code=='Unconfirmed' or why=='Unconfirmed' or status.Validation=='Unconfirmed') or false)
        c.Retry:SetDisabled(status.Validation=='Cooldown' or status.Validation=='Busy')
        local avatar=identity and self._avatar and self._avatar.UserId==identity.UserId and self._avatar.URL
        c.Avatar:SetVisible(avatar~=nil and avatar~=false);if avatar and c.Avatar:GetValue()~=avatar then c.Avatar:SetValue(avatar,true) end
        c.Metadata:SetText(id and not self._game and self:_tr('Consultando o nome do jogo…','Fetching the game name…') or self._game and not self._game.Available and self:_tr('Nome indisponível; o ID e o link continuam válidos.','Game name unavailable; the ID and link remain valid.') or '')
        local remaining=status.RetryAfter or 0
        if not self._operation and identity then local item=self:_entry(identity);if item then remaining=math.max(remaining,item.PendingUntil-os.clock()) end end
        if remaining>0 and self.Window._shown~=false and not self.Window.Minimized and self.Tab.Frame.Visible and not self._tick then
            self._tick=task.delay(math.min(1,remaining),function() self.Scope:Remove('tick',true);self._tick=nil;self:Refresh() end)
            self.Scope:Add(self._tick,function(t) if coroutine.status(t)=='suspended' then task.cancel(t) end end,'tick')
        end
        if not same(self.Status:Get(),status) then self.Status:Set(status) end
        self._refreshing=false
    end
    function Feedback:Destroy()
        if self.Destroyed then return end;self.Destroyed=true
        if self._context then self._context.Owner=nil end
        if self._retryDialog and not self.Window.Destroyed and not self.Window._closing then self._retryDialog:Close('feedback destroyed') end
        self._retryDialog=nil
        if self._operation and self._operation.Handle then self._operation.Handle:Cancel('feedback destroyed') end
        self.Scope:Destroy();self.Window._feedbackHubs[self.Id]=nil;self.Window._resources:Remove('feedback-hub:'..self.Id,true)
        if self.Tab and not self.Tab.Destroyed then self.Tab:Destroy() end
        self.Controls={};self._captions={};self._last=nil;self._operation=nil;self.Options={};self._avatar=nil;self._game=nil
        if self.OwnsWindow and not self.Window.Destroyed then self.Window:Destroy() end
    end
    function Feedback:Show() self.Window:Show();self.Tab:Select();self:Refresh();return self end
    function Feedback:Hide() self.Window:Hide();return self end
    function Window:CreateFeedbackHub(options)
        local settings=checked(options);assert(not self.Destroyed,'Window has been destroyed')
        self._feedbackHubs=self._feedbackHubs or {};assert(not self._feedbackHubs[settings.Id],'Feedback Id already exists')
        local hub=setmetatable({Id=settings.Id,Window=self,Scope=self:CreateScope(),Options=settings,Controls={},Category=settings.DefaultCategory,_captions={}},Feedback)
        hub._context={Owner=hub,Generation=0};hub.Status=Library:CreateState({State='Idle'});hub.Scope:Add(hub.Status,'Destroy')
        self._feedbackHubs[hub.Id]=hub
        local ok,err=pcall(function()
            hub.Tab=self:CreateTab({Title=hub:_tr('Central de Ideias','Ideas Center'),Icon='notification',Columns=2})
            local form=hub.Tab:CreateSection({Title=hub:_tr('Compartilhe sua ideia','Share your idea'),Icon='spark'})
            local review=hub.Tab:CreateSection({Title=hub:_tr('Prévia do envio','Submission preview'),Icon='eye',Side='Right'})
            local function add(section,method,name,pt,en,extra)
                local opts={Id='feedback/'..hub.Id..'/'..name,Title=hub:_tr(pt,en),Persist=false}
                for key,value in pairs(extra or {}) do opts[key]=value end
                local control=section[method](section,opts);hub.Controls[name]=control;hub._captions[control]={pt,en};return control
            end
            add(form,'AddLabel','Intro','Feedback, melhorias e pedidos de scripts em um só lugar.','Feedback, improvements and script requests in one place.',{Height=72})
            add(form,'AddDropdown','Category','O que você quer compartilhar?','What would you like to share?',{Options={'initial'},Default='initial',Callback=function(value)
                if not hub._syncing and hub._categoryLabels[value] then hub.Category=hub._categoryLabels[value];hub._last=nil;hub:Refresh() end
            end})
            add(form,'AddToggle','CurrentGame','Usar o jogo desta sessão','Use this session’s game',{Default=settings.Game=='current'})
            add(form,'AddInput','Target','Outro jogo','Another game',{Default=settings.Game=='current' and '' or tostring(gameId(settings.Game)),MaxLength=512,Live=true})
            add(form,'AddInput','Message','Sua mensagem','Your message',{Multiline=true,Live=true,MaxLength=settings.MaxLength*4})
            add(form,'AddLabel','Counter','','',{Height=24})
            add(form,'AddLabel','Notice','','',{Height=112})
            add(form,'AddButton','Submit','Enviar para o Discord','Send to Discord',{Icon='chevron-right',Callback=function() hub:Submit() end})
            add(form,'AddButton','Cancel','Parar espera','Stop waiting',{Icon='close',Visible=false,Callback=function() hub:CancelSubmission() end})
            add(form,'AddButton','Retry','Reenviar com confirmação','Resend with confirmation',{Icon='refresh',Visible=false,Callback=function()
                hub._retryDialog=hub.Window:Confirm({Title=hub:_tr('Reenviar mensagem?','Resend message?'),Content=hub:_message('Unconfirmed'),OnConfirm=function() if not hub.Destroyed then hub:Submit({RetryUnconfirmed=true}) end end})
            end})
            add(form,'AddButton','Clear','Limpar mensagem','Clear message',{Icon='reset',Callback=function() hub:ClearDraft() end})
            add(review,'AddLabel','GamePreview','','',{Height=64})
            add(review,'AddLabel','GameLink','','',{Height=56})
            add(review,'AddLabel','PlaceId','','',{Height=32})
            add(review,'AddLabel','Metadata','','',{Height=48})
            add(review,'AddLabel','Identity','','',{Height=64})
            add(review,'AddImage','Avatar','','',{Image='',Height=96,Visible=false})
            add(review,'AddLabel','MessagePreview','','',{Height=220})
            add(review,'AddLabel','Status','','',{Height=112})
            for _,name in ipairs({'GamePreview','GameLink','PlaceId','Identity','MessagePreview','Counter'}) do self:SetTextTranslation(hub.Controls[name].Frame,false) end
            for _,name in ipairs({'Message','Target','CurrentGame'}) do hub.Scope:Add(hub.Controls[name]:OnChanged(function() if not hub._syncing then hub._last=nil;hub:Refresh() end end),'Disconnect') end
            local identityScope=hub.Scope:Child()
            local function identity()
                identityScope:Clean();local player=Players.LocalPlayer
                if player then for _,name in ipairs({'Name','DisplayName','UserId'}) do identityScope:Add(player:GetPropertyChangedSignal(name):Connect(function() hub:Refresh() end),'Disconnect') end end
                hub:Refresh()
            end
            hub.Scope:Add(Players:GetPropertyChangedSignal('LocalPlayer'):Connect(identity),'Disconnect')
            hub.Scope:Add(Players.PlayerAdded:Connect(identity),'Disconnect')
            hub.Scope:Add(hub.Tab.Frame:GetPropertyChangedSignal('Visible'):Connect(function() hub:Refresh() end),'Disconnect')
            hub.Scope:Add(hub.Tab.Frame.Destroying:Connect(function() if not hub.Destroyed then hub:Destroy() end end),'Disconnect')
            hub.Scope:Add(function() if not hub.Destroyed then hub:Destroy() end end)
            self:_bind(hub.Controls.Submit.Button,{BackgroundColor3='Accent',TextColor3='AccentText'})
            hub._ready=true;identity();hub:_refreshLocale();hub.Tab:Select()
        end)
        if not ok then hub:Destroy();error(err,2) end
        self:Manage(hub,'Destroy','feedback-hub:'..hub.Id)
        return hub
    end
    function Library:CreateFeedbackHub(options)
        checked(options)
        local settings={};for key,value in pairs(options) do settings[key]=value end
        settings.Id=options.WindowId or 'RetroBox-Feedback-'..(options.Id or 'feedback');settings.Title=options.Title or 'Central de Ideias';settings.Theme=options.Theme or 'Hacker';settings.Icon=options.Icon or 'notification';settings.Subtitle=options.Subtitle or 'Feedback e sugestões de scripts'
        local window=self:CreateWindow(settings)
        local ok,hub=pcall(window.CreateFeedbackHub,window,options)
        if not ok then window:Destroy();error(hub,2) end
        hub.OwnsWindow=true;hub._defaultTitle=options.Title==nil;hub._defaultSubtitle=options.Subtitle==nil;hub:_refreshLocale();return hub
    end
    for _,name in ipairs({'SetLocale','Show','Minimize'}) do
        local method=Window[name]
        Window[name]=function(self,...)
            local result=method(self,...)
            for _,hub in pairs(self._feedbackHubs or {}) do if hub._ready and not hub.Destroyed then if name=='SetLocale' then hub:_refreshLocale() else hub:Refresh() end end end
            return result
        end
    end
end
