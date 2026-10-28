-- Built-in release notes are owned by the library; consumers only set ScriptUpdates.
do
    local official=HttpService:JSONDecode([==[[{"Id":"retrobox-2.10.0","Version":"2.10.0","Date":"2026-10-28","Title":{"pt-BR":"Central de Ideias própria e Novidades sem avisos","en-US":"Dedicated Ideas Center and passive update history"},"Description":{"pt-BR":"- Central de Ideias com launcher próprio: cartões de categoria, mensagem, diagnóstico opcional e revisão do envio.\n- Painel de jogo, jogador e status; layout adaptável e nomes alinhados, preservando API, temas e traduções.\n- Novidades fica somente como histórico: sem contadores, etiquetas de não lida, botão de leitura ou avisos.\n- Perfis antigos não reativam indicadores; credenciais e rascunhos continuam fora dos perfis.\n- Prévia de diagnóstico permanece somente para leitura após atualizações da tela.","en-US":"- Dedicated Ideas Center launcher with category cards, message composer, optional diagnostics and submission review.\n- Game/player context and delivery status, adaptive layout and aligned labels; existing API, themes and localization retained.\n- Updates is a passive history: no unread counts, tags, mark-as-read buttons or alerts.\n- Legacy profiles cannot restore update badges; credentials and drafts remain outside profiles.\n- Diagnostic preview stays read-only after refresh."}},{"Id":"retrobox-2.9.0","Version":"2.9.0","Date":"2026-10-27","Title":{"pt-BR":"Novidades e relatos com diagnóstico","en-US":"Updates and diagnostic bug reports"},"Description":{"pt-BR":"- Área Novidades em todas as janelas, com histórico oficial da RetroBox e updates opcionais do script em fontes separadas.\n- Marcação de leitura por conteúdo, idioma PT/EN e persistência no perfil; conteúdo oficial não aceita substituição pela API pública.\n- Diagnóstico opcional na Central de Ideias: erro colado, código/tag, reprodução e seleção de registros disponíveis.\n- Captura de console explícita e limitada, prévia, cópia e remoção de padrões reconhecidos de segredo; anexos não entram nos perfis.\n- Limites do embed conferidos antes do envio, preservação de rascunho e encerramento seguro de captura e respostas tardias.","en-US":"- Updates in every window, with official RetroBox history and optional script updates in separate sources.\n- Content-based read markers, PT/EN and saved read state; public consumer APIs cannot replace official notes.\n- Optional Ideas Center diagnostics: pasted error, error tag, reproduction steps and selected available records.\n- Explicit bounded console capture, preview, copy and recognized-secret redaction; attachments stay out of profiles.\n- Embed limits checked before sending, draft preservation and managed capture/request cleanup."}},{"Id":"retrobox-2.8.0","Version":"2.8.0","Date":"2026-10-27","Title":{"pt-BR":"Central de Ideias","en-US":"Ideas Center"},"Description":{"pt-BR":"- Central de Ideias opt-in e independente do Script Hub, com categorias, formulário, prévia e PT/EN.\n- Jogo atual ou outro por ID/link; nome automático, identidade real e avatar HTTPS opcional.\n- Webhook Discord ou transporte customizado, confirmação, limites e duplicatas; nenhum envio na abertura.\n- Falhas e timeout mantêm o texto; respostas tardias não alteram GUI nova. Rascunho/credencial fora dos perfis.\n- Regressões de comunicação, idioma, ciclo de vida e layouts. API 2, bootstrap, Designer e releases anteriores preservados.","en-US":"- Standalone or attached Ideas Center with requests, suggestions, feedback and bug reports.\n- Current or selected game, real player identity, optional avatar and PT/EN preview.\n- Explicit Discord webhook or custom transport, confirmed delivery, cooldown and duplicate handling.\n- Draft preservation, timeout handling and safe cleanup; no send when opening."}},{"Id":"retrobox-2.7.0","Version":"2.7.0","Date":"2026-10-26","Title":{"pt-BR":"Acabamento visual, RGB e tema do Hub","en-US":"Visual polish, RGB and Hub theme"},"Description":{"pt-BR":"- Acabamento compartilhado: entrada coordenada de textos nas páginas, tela de preparação opcional, skeletons nativos e SetLoading para controles comuns.\n- RGB opt-in para títulos, descrições, valores e botões; contraste contextual, preferências de movimento e agendador compartilhado com ColorPickers.\n- Perfil independente de aparência por Hub, preset Launcher, botão Tema e editor de cores; snapshots persistentes e importação atômica.\n- Capas e metadados com placeholders, falha observável e fade de imagem; menus, tooltips e ícones acompanham a paleta local.\n- Orçamentos de efeitos, encerramento seguro ao ocultar/destruir/reexecutar e regressões adicionais. API 2, consumidores, bootstrap, Designer e releases anteriores preservados.","en-US":"- Shared visual polish, coordinated entrances, optional loading screens and native skeletons.\n- Optional RGB for titles, descriptions, values and buttons, respecting contrast and motion preferences.\n- Independent Hub appearance profiles, Launcher preset and palette editor.\n- Image placeholders and status, local theme integration and bounded managed effects."}},{"Id":"retrobox-2.6.0","Version":"2.6.0","Date":"2026-10-26","Title":{"pt-BR":"Identidade e animações","en-US":"Identity and animations"},"Description":{"pt-BR":"- Perfil observa LocalPlayer e Name/DisplayName/UserId, recupera inicialização tardia e confere identidade ao reabrir; avatar e tradução não bloqueiam nomes.\n- Respostas de avatar antigas são invalidadas; observers e referências da interface são liberados na destruição.\n- Feedback de botões, foco, seleção, abas, listas/cards, menus, tooltips, estatísticas, gráficos, Hub/HUD e etapas usam o animador central.\n- Gráficos/StatCards animam por padrão; Animated=false desliga movimento por controle. Arraste suavizado passa a ser padrão, respeitando saves e acessibilidade.\n- Geometria dos gráficos usa unidades lógicas, máscaras de progresso acompanham a transição e há orçamento de 96 segmentos animados por gráfico.\n- Novas regressões de identidade/movimento e demonstração nativa com dados fictícios. API 2, bootstrap, Designer e releases anteriores preservados.","en-US":"- Player profile follows real LocalPlayer identity, including delayed initialization and changes.\n- Stale avatar responses are discarded and observers are cleaned up.\n- Central animation system covers interactions, charts, statistics, Hubs and compact views.\n- Smooth dragging and animated charts by default, with accessibility and explicit opt-outs."}},{"Id":"retrobox-2.5.2","Version":"2.5.2","Date":"2026-10-21","Title":{"pt-BR":"Layout e interação do launcher","en-US":"Launcher layout and interaction"},"Description":{"pt-BR":"- Ordenação do Hub usa a camada de ContextMenu já existente, fora de ancestrais com recorte; respeita a janela e abre para cima quando necessário.\n- Botões do launcher reservam espaço pelo texto, fonte, escala e ícone reais; ações e filtros quebram em linhas quando necessário.\n- Cabeçalhos tradicionais compartilham o cálculo de informação, fixação, Keybind integrado e controle principal, com altura responsiva.\n- Remoção/recriação de ajuda e fixação não acumula deslocamentos; callbacks, captura de teclas, preferências e IDs preservados.\n- Regressões de geometria/interação e compatibilidade com o Hub anexado. Sem redesign, mudança de API ou modificação dos consumidores.","en-US":"- Launcher sorting uses the existing context-menu overlay without clipping.\n- Action widths use actual text, font, scale and icons; rows wrap when needed.\n- Control headers reserve responsive room for help, pinning and keybinds.\n- Existing callbacks, IDs and saved preferences are preserved."}},{"Id":"retrobox-2.5.1","Version":"2.5.1","Date":"2026-10-20","Title":{"pt-BR":"Desempenho dos grafos","en-US":"Flow graph performance"},"Description":{"pt-BR":"- Avaliação memoizada por expressão nos grafos nativos e na prévia, evitando recálculo exponencial de subexpressões compartilhadas.\n- Cada leitura de entrada usa um cache novo, preservando mudanças de valores entre bindings e ações.\n- Comparação de registros na prévia independe da ordem das chaves, como no runtime.\n- Regressões com 28 operações compartilhadas e refresh; release 2.5.0 preservada por bytes.","en-US":"- Memoized flow expressions prevent exponential recalculation of shared inputs.\n- Every new evaluation gets a fresh cache so state changes remain visible.\n- Preview record comparisons ignore map-key order, matching the native runtime."}},{"Id":"retrobox-2.5.0","Version":"2.5.0","Date":"2026-10-20","Title":{"pt-BR":"Designer e ferramentas de desenvolvimento","en-US":"Designer and developer tools"},"Description":{"pt-BR":"- Designer HTML offline com 21 componentes, Row, 22 blocos tipados, prévia, PT/EN, JSON e compilador Luau real.\n- Localização automática por janela, dicionários, parâmetros, provider explícito e preferência em perfis.\n- Formulários transacionais, componentes reutilizáveis, CardGrid com pool limitado e grafos sem ciclos.\n- Diagnóstico de catálogo por download/compilação explícitos, sem executar o conteúdo.\n- Fontes do editor, catálogo compartilhado, exemplos, testes Chromium e integração contínua.\n- API 2, bootstrap, estrutura histórica, jogos/IDs dos consumidores e pins publicados preservados.","en-US":"- Offline HTML Designer with 21 components, rows, 22 typed blocks, preview and a real Luau compiler.\n- Automatic window localization, dictionaries, parameters and explicit translation provider.\n- Transactional forms, reusable components, bounded CardGrid and acyclic flows.\n- Explicit catalog diagnostics and Chromium tests; existing API 2 consumers preserved."}},{"Id":"retrobox-2.4.0","Version":"2.4.0","Date":"2026-10-20","Title":{"pt-BR":"Scripts universais","en-US":"Universal scripts"},"Description":{"pt-BR":"- UniversalScripts nativo e separado de Games, com categoria, tag UNIVERSAL e nome/descrição/URL ou Callback.\n- Id opcional, APIs de cadastro/edição/execução, perfis e ações independentes por categoria.\n- Raw do Pastefy aceito por URL HTTPS; download apenas na execução, com progresso, erros e cancelamento cooperativo.\n- Catálogos JSON continuam sem URL/código e atualizam universais de forma atômica por metadados/Actions locais.\n- Preserva API 2, estrutura histórica, tema/PixelIcons, jogos e artefatos até 2.3.1.","en-US":"- UniversalScripts live separately from game entries, with a UNIVERSAL tag and their own metadata.\n- Optional IDs, registration/editing APIs, profiles and independent actions.\n- HTTPS Pastefy raw URLs load only on explicit execution, with progress and cancellation.\n- Remote JSON catalogs remain metadata-only."}},{"Id":"retrobox-2.3.1","Version":"2.3.1","Date":"2026-10-20","Title":{"pt-BR":"Nova origem de distribuição","en-US":"New distribution origin"},"Description":{"pt-BR":"- Origem padrão do updater e bootstrap passam a ManoGustavo02/RetroBox.\n- Guias e exemplos ativos apontam para a conta nova; estrutura histórica, API 2 e temas preservados.\n- Nova release, sem reescrever os pins 2.0.0, 2.1.0, 2.2.0 e 2.3.0.\n- README bilíngue, banner e badges locais, guias de contribuição/segurança, formulários e CI de validação.\n- Canais Stable/Preview apontam para 2.3.1; resultados de publicação e acesso remoto ficam no relatório da release.","en-US":"- Default updater and bootstrap origin migrated to ManoGustavo02/RetroBox.\n- Active guides and examples point to the new account; historical releases are preserved.\n- Bilingual README, local artwork, contribution/security guides, issue forms and CI."}},{"Id":"retrobox-2.3.0","Version":"2.3.0","Date":"2026-10-19","Title":{"pt-BR":"Launcher padrão do Script Hub","en-US":"Standard Script Hub launcher"},"Description":{"pt-BR":"- Launcher padrão em CreateScriptHub, com catálogo, filtros, destaque, cards e barra fixa, compartilhado por todos os consumidores.\n- FallbackName/Notes nativos, SetCatalogFilter/GetCatalogFilter e compatibilidade dos IDs/perfis/API 2.\n- Temas, idioma, contraste dos cards, buscas/foco, detalhes completos e status de teleporte integrados.\n- Limpeza de Hold evita render em toggle/PixelIcon já destruído durante sinais diferidos.\n- Novo exemplo e regressões específicas de hubs genéricos e integração do consumidor.\n- GitHub retornou 403 de conta suspensa; este pacote não foi publicado.","en-US":"- Shared launcher layout for CreateScriptHub: filters, featured game, cards and fixed actions.\n- FallbackName, Notes and catalog filter APIs preserve existing IDs and API 2.\n- Improved themes, language, contrast, search, complete details and teleport status.\n- Historical note: publication from the old account was blocked; distribution later migrated in 2.3.1."}},{"Id":"retrobox-2.2.0","Version":"2.2.0","Date":"2026-10-19","Title":{"pt-BR":"Mini HUD, previews e etapas","en-US":"Mini HUD, previews and steppers"},"Description":{"pt-BR":"- Mini HUD com States compartilhados, valores/progresso/timers/status, arraste/trava, escala/opacidade, recolhimento e layout em perfis.\n- Fixar/Soltar de StatCard, Progress, ProgressChart, Label e Stepper; valores silenciosos e cleanup do controle preservados.\n- Barra compacta reutiliza FloatingButton e Press/Toggle/Hold, disabled/busy e liberação ao perder foco.\n- AddPreview com imagem/modelo clonado/WorldModel, câmera própria, zoom/rotação, Apply/Cancel, animações opcionais e renderer com scope.\n- AddStepper acompanha progressos/resultados de RunAction, com transições manuais e resumo fixável.\n- 32 regressões específicas e quatro exemplos novos; distribuição e bootstrap API 2 preservados.","en-US":"- Mini HUD with shared states, values, progress, timers, dragging, locking and profile layouts.\n- Pin/unpin existing components, compact action bar, image/model previews and operation stepper.\n- Scoped resources, explicit callbacks and additional regression examples."}},{"Id":"retrobox-2.1.0","Version":"2.1.0","Title":{"pt-BR":"Ícones, metadados e profiler","en-US":"Icons, metadata and profiler"},"Description":{"pt-BR":"- PixelIcon separa observação de Destroying da destruição explícita, com limpeza idempotente e soltura de referências, sem pcall de supressão.\n- Smart Game Metadata no Hub atual: campos manuais preservados, consulta assíncrona, provider opcional, cache/limite/deduplicação e integração com catálogos.\n- Profiler por tarefa/ação no Runtime Inspector existente, com tempos, contadores, espera instrumentada, histórico limitado e aviso de intervalo excedido.\n- Session Snapshots opcionais de States registrados, validados e independentes dos perfis.\n- CreateIntegration e cinco exemplos novos, incluindo operação cancelável de seis etapas.\n- API 2 e bootstrap permanente preservados; releases anteriores continuam imutáveis.","en-US":"- Idempotent PixelIcon lifecycle fixes and cleanup without suppressing destroyed-parent errors.\n- Smart game metadata with async providers, cache and field-level overrides.\n- Task/action profiler, optional registered session snapshots and integration helpers."}},{"Id":"retrobox-2.0.0","Version":"2.0.0","Title":{"pt-BR":"Bootstrap permanente e API 2","en-US":"Permanent bootstrap and API 2"},"Description":{"pt-BR":"- Bootstrap permanente de API 2; Stable/Preview/Pinned, SemVer, compatibilidade, SHA-256, cache opcional e rollback com histórico imutável.\n- Código do Hub por módulos Version/Start/LoadHub e catálogo JSON por CatalogUpdate/Actions, com origens explícitas e atualizações independentes.\n- Script Hub nativo com imagem ampla, sem rótulo Miniatura, listas adaptativas, seleção por jogo, um Executar script, cancelamento/feedback e panes responsivos.\n- Busca global passa a navegar ao pane correto; APIs, IDs/perfis, temas, ícones e componentes anteriores preservados.\n- Guias, migração, prompt completo, 24 exemplos, builders e verificação de distribuição. 256 testes de lógica e 2 de pipeline aprovados.","en-US":"- Permanent API 2 bootstrap with stable/preview/pinned channels, integrity checks and immutable releases.\n- Independent script hub modules and metadata catalogs.\n- Native Script Hub launcher with responsive lists, search, game selection and execution feedback.\n- Existing IDs, themes, profiles and controls retained."}}]]==])
    local function text(value,limit)
        local function part(s) assert(type(s)=='string' and utf8.len(s) and #s<=limit*4 and utf8.len(s)<=limit and not s:find('[%z\1-\8\11\12\14-\31]'),'Invalid update text');return s end
        if type(value)=='string' then return part(value) end
        assert(type(value)=='table' and value['pt-BR'] and value['en-US'],'Localized update text requires pt-BR and en-US')
        for key in pairs(value) do assert(key=='pt-BR' or key=='en-US','Unsupported update text key') end
        return {['pt-BR']=part(value['pt-BR']),['en-US']=part(value['en-US'])}
    end
    local function entries(value)
        assert(type(value)=='table' and #value<=100,'ScriptUpdates must contain at most 100 entries')
        local result,seen={},{};local total=0
        for key in pairs(value) do total=total+1;assert(type(key)=='number' and key%1==0 and key>=1 and key<=#value,'ScriptUpdates must be a dense array') end
        assert(total==#value,'ScriptUpdates must be a dense array')
        for _,item in ipairs(value) do
            assert(type(item)=='table' and type(item.Id)=='string' and item.Id:match('^[%w_.%-]+$') and #item.Id<=64 and not seen[item.Id],'Update Id must be unique and contain 1-64 safe characters')
            for key in pairs(item) do assert(key=='Id' or key=='Version' or key=='Title' or key=='Description' or key=='Date','Unknown script update field') end
            seen[item.Id]=true
            local e={Id=item.Id,Title=text(item.Title,160),Description=text(item.Description,2400)}
            if item.Version~=nil then assert(type(item.Version)=='string' and #item.Version<=48 and not item.Version:find('[%c]'),'Invalid script update Version');e.Version=item.Version end
            if item.Date~=nil then assert(type(item.Date)=='string' and item.Date:match('^%d%d%d%d%-%d%d%-%d%d$'),'Update Date must use YYYY-MM-DD');e.Date=item.Date end
            result[#result+1]=e
        end
        return result
    end
    local function readState(value)
        assert(type(value)=='table','NewsRead must be a table');local result={Library={},Script={}}
        for source,items in pairs(value) do
            assert(result[source] and type(items)=='table','Invalid news read namespace');local n=0
            for id,hash in pairs(items) do
                n=n+1;assert(n<=256 and type(id)=='string' and id:match('^[%w_.%-]+$') and #id<=64 and type(hash)=='string' and #hash==64 and hash:match('^[a-f0-9]+$'),'Invalid news read marker')
                result[source][id]=hash
            end
        end
        return result
    end
    local function translated(window,value)
        return type(value)=='table' and (window:GetLocale()=='pt-BR' and value['pt-BR'] or value['en-US']) or value
    end
    local function sourceName(value) assert(value=='Library' or value=='Script','Update source must be Library or Script');return value end
    local News={};News.__index=News
    function Library:GetReleaseNotes() return copy(official) end
    function Window:GetLibraryUpdates() return copy(official) end
    function Window:GetScriptUpdates() return copy(self._scriptUpdates or {}) end
    function Window:SetScriptUpdates(value)
        assert(not self.Destroyed,'Window has been destroyed')
        local checked=entries(value);self._scriptUpdates=checked
        if self._news and not self._news.Destroyed then self._news:Refresh() end
        return self
    end
    -- Compatibility-only APIs. News is now a passive history with no unread state.
    function Window:GetUnreadUpdateCount(source) sourceName(source);return 0 end
    function Window:MarkUpdateRead(source,id)
        assert(not self.Destroyed,'Window has been destroyed');source=sourceName(source)
        local found;for _,item in ipairs(source=='Library' and official or self._scriptUpdates or {}) do if item.Id==id then found=item;break end end
        assert(found,'Unknown update Id')
        return self
    end
    function News:_tr(pt,en) return self.Window:_t17(pt,en) end
    function News:_ensureView()
        if self.Controls or self.Destroyed then return end
        local w=self.Window;local choose=self.Tab:CreateSection({Title=self:_tr('Histórico de atualizações','Update history'),Icon='folder'})
        local detail=self.Tab:CreateSection({Title=self:_tr('Detalhes da atualização','Update details'),Icon='info'})
        self.Choose,self.Detail=choose,detail;self.Controls={}
        local function opts(id,title,more)
            local o={Id='__retrobox/news/'..id,Title=title,Internal=true,Persist=false}
            for k,v in pairs(more or {}) do o[k]=v end;return o
        end
        self.Controls.Source=choose:AddDropdown(opts('source','',{Options={'RetroBox','Script'},Default=self.Source=='Library' and 'RetroBox' or 'Script',Callback=function(value)
            if not self.Refreshing then self.Source=value=='RetroBox' and 'Library' or 'Script';self.Selected=nil;self:Refresh() end
        end}))
        self.Controls.List=choose:AddDropdown(opts('list','',{Options={},Callback=function(value)
            if not self.Refreshing then self.Selected=self.LabelIds[value];self:Refresh() end
        end}))
        self.Title=label(w,detail.Content,'',{LayoutOrder=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextSize=15},'Accent')
        self.Meta=label(w,detail.Content,'',{LayoutOrder=2,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextSize=12},'Muted')
        self.Body=label(w,detail.Content,'',{LayoutOrder=3,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextSize=13},'Text')
        for _,object in ipairs({self.Title,self.Meta,self.Body}) do object.RichText=false;w:SetTextTranslation(object,false) end
        self.Controls.Source:SetValue(self.Source=='Library' and 'RetroBox' or 'Script',true)
    end
    function News:Refresh()
        if self.Destroyed or self.Refreshing then return end;self.Refreshing=true
        local w=self.Window
        self.Tab:SetTitle(self:_tr('Novidades','Updates'))
        if self.Controls then
            local c=self.Controls;c.Source:SetTitle(self:_tr('Origem das novidades','Update source'))
            c.Source:SetOptions({'RetroBox',self:_tr('Este script','This script')},false);c.Source:SetValue(self.Source=='Library' and 'RetroBox' or self:_tr('Este script','This script'),true)
            c.List:SetTitle(self:_tr('Escolha uma atualização','Choose an update'))
            self.Choose:SetTitle(self:_tr('Histórico de atualizações','Update history'));self.Detail:SetTitle(self:_tr('Detalhes da atualização','Update details'))
            local items=self.Source=='Library' and official or w._scriptUpdates or {};local selected;local labels={};self.LabelIds={}
            for i,item in ipairs(items) do
                local name=tostring(i)..' · '..(item.Version and item.Version..' · ' or '')..translated(w,item.Title)
                labels[#labels+1]=name;self.LabelIds[name]=item.Id
                if item.Id==self.Selected then selected=item end
            end
            if not selected then selected=items[1];self.Selected=selected and selected.Id or nil end
            c.List:SetOptions(labels,false)
            if selected then
                for name,id in pairs(self.LabelIds) do if id==selected.Id then c.List:SetValue(name,true);break end end
                self.Title.Text=translated(w,selected.Title)
                self.Meta.Text=(self.Source=='Library' and 'RETROBOX' or self:_tr('ESTE SCRIPT','THIS SCRIPT'))..' · '..(selected.Version or selected.Id)..(selected.Date and ' · '..selected.Date or '')
                self.Body.Text=translated(w,selected.Description)
            else
                self.Title.Text=self:_tr('Sem novidades cadastradas','No updates registered')
                self.Meta.Text=self:_tr('ESTE SCRIPT','THIS SCRIPT');self.Body.Text=self:_tr('O desenvolvedor ainda não cadastrou atualizações deste script.','The developer has not registered updates for this script yet.')
            end
        end
        self.Refreshing=false
    end
    function News:Destroy()
        if self.Destroyed then return end;self.Destroyed=true
        self.Scope:Destroy();self.Controls=nil;self.Title=nil;self.Meta=nil;self.Body=nil
        if self.Window._news==self then self.Window._news=nil;self.Window.NewsTab=nil end
    end
    function Window:_installNews()
        if self._news and not self._news.Destroyed then return self._news end
        local n=setmetatable({Window=self,Source='Library',Scope=self:CreateScope()},News)
        n.Tab=self:CreateTab({Title=self:_t17('Novidades','Updates'),Icon='folder',Internal=true});n.Tab._passive=true;self._news=n;self.NewsTab=n.Tab
        n.Tab._toolManager=n
        n.Scope:Add(n.Tab.Frame:GetPropertyChangedSignal('Visible'):Connect(function() if n.Tab.Frame.Visible and not n.Destroyed and not self.Destroyed and not self._closing then n:_ensureView();n:Refresh() end end),'Disconnect')
        self:Manage(n,'Destroy','news');n:Refresh();return n
    end
    function Window:OpenUpdates(source)
        assert(not self.Destroyed,'Window has been destroyed')
        local n=self:_installNews();if source then n.Source=sourceName(source);n.Selected=nil end
        n:_ensureView();n.Tab:Select();n:Refresh();return n.Tab
    end
    local export=Window._exportAdvanced
    function Window:_exportAdvanced()
        local result=export(self);result.NewsRead=nil;return result
    end
    local prepare=Window._prepareAdvanced
    function Window:_prepareAdvanced(value)
        local result=prepare(self,value)
        -- Validate old profiles atomically, then discard their obsolete markers.
        if result and value.NewsRead~=nil then readState(value.NewsRead) end
        return result
    end
    local apply=Window._applyAdvanced
    function Window:_applyAdvanced(value,deferUI)
        apply(self,value,deferUI)
        self._newsRead=nil;if self._news then self._news:Refresh() end
    end
    local locale=Window.SetLocale
    function Window:SetLocale(...)
        local result=locale(self,...);if self._news and not self._news.Destroyed then self._news:Refresh() end;return result
    end
    local create=Library.CreateWindow
    function Library:CreateWindow(options)
        options=options or {}
        assert(options.LibraryUpdates==nil and options.ReleaseNotes==nil,'Library release notes cannot be replaced by consumer options')
        local script=entries(options.ScriptUpdates or {})
        local w=create(self,options);w._scriptUpdates=script
        w:_installNews();w._initial.Advanced=w:_exportAdvanced();return w
    end
end
