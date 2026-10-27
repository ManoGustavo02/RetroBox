A partir desta mensagem, use a RetroBox UI como library de interface nos scripts Roblox que eu solicitar nesta conversa.

Desenvolva em Luau para execução no cliente por um executor compatível. A RetroBox é carregada por HTTP e loadstring; este projeto não usa instalação no Roblox Studio. Em cada pedido, implemente as funcionalidades que eu descrever e conecte-as aos componentes da library.


Estado desta entrega em 27/10/2026: RetroBox 2.9.0/API 2, publicada nos canais Stable e Preview. Esta edição acrescenta Novidades por origem em todas as janelas e diagnóstico opcional nos relatos, preservando a Central de Ideias (Feedback Hub), um módulo opt-in de comunicação separado do Script Hub, com prévia, PT/EN e webhook/transporte configurável. Este é o prompt integral atualizado; mantém a estrutura de carregamento remoto, montagem da interface, APIs anteriores e seus exemplos. Inclui as correções de layout da 2.5.2, identidade e movimento da 2.6.0, e acabamento compartilhado, RGB de textos, carregamento e perfis independentes do Hub da 2.7.0. Designer HTML/blocos, idiomas, Form, Component, CardGrid, FlowGraph, diagnóstico, tarefas, HUD e scripts universais continuam disponíveis. O GitHub é a origem da library; fontes dos scripts podem ficar no Pastefy. As seções identificadas por versões anteriores registram a introdução dos recursos e continuam compatíveis; não indicam a versão atual do canal. Não prometa tradução arbitrária sem dicionário/provider, nem execução visual nativa quando houver somente testes simulados.

Fontes atuais da 2.9.0:
- Novidades: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/NEWS.md
- Release 2.9.0: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.9.md

Referências mantidas de versões anteriores:
- Central de Ideias / Feedback Hub: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/FEEDBACK-HUB.md
- Release 2.8.0: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.8.md
- Exemplo independente de Feedback Hub: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/feedback-hub.lua
- Acabamento, loading, RGB e tema próprio do Hub (2.7.0): https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.7.md
- Identidade do jogador e animações (2.6.0): https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.6.md
- Layout de Hub/ajuda/teclas e menus (2.5.2): https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.5.2.md
- Exemplo atual de acabamento e RGB: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/appearance-and-rgb.lua
- Exemplo de identidade, gráficos e movimento: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/motion-and-profile.lua
- Validação e limites de verificação: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md
- Designer offline: https://github.com/ManoGustavo02/RetroBox/tree/main/designer
- APIs 2.5: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/DEVELOPMENT-TOOLS.md
- Release 2.5: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.5.md
- Scripts universais nativos: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/UNIVERSAL-SCRIPTS.md
- Release 2.4.0: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.4.md
- Migração de origem: docs/RELEASE-2.3.1.md no pacote completo.
- Launcher nativo da 2.3.0: docs/RELEASE-2.3.md e docs/SCRIPT-HUB.md no pacote completo. Disponíveis no mesmo caminho histórico do repositório.
- Adições compatíveis da 2.2.0: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.2.md
- Mini HUD, fixação e barra de ações: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/COMPACT-VIEWS.md
- Preview de imagens, modelos e animações: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/PREVIEWS.md
- Visualizador de etapas: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/STEPPER.md
- Adições compatíveis da 2.1.0: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.1.md
- Smart Game Metadata: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/GAME-METADATA.md
- Runtime Profiler: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RUNTIME-PROFILER.md
- Session Snapshots: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/SESSION-SNAPSHOTS.md
- Repositório: https://github.com/ManoGustavo02/RetroBox
- Bootstrap permanente da RetroBox API 2: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua
- Documentação completa da mesma versão: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/API.md
- Guia de Script Hub Mode: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/SCRIPT-HUB.md
- Contrato de distribuição remota: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/DISTRIBUTION.md
- Exemplo de hub: https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/script-hub.lua
- Guia dos doze temas e das seis paletas novas: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/THEMES.md
- Componentes e ferramentas: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/ADVANCED.md
- Runtime: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RUNTIME.md
- Integração de tarefas e migrações: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/INTEGRATION.md
- Identidade em pixel art: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/ICONS.md
- Galeria das seis paletas novas: https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/themes-gallery.lua
- Exemplo completo de workflows: https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/workflows.lua
- Integração de tarefas e grupos: https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/runtime-integration.lua
- Dashboard com dados simulados: https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/dashboard.lua

O bootstrap acima resolve a distribuição Stable da API 2, com metadados, integridade e compatibilidade. Use-o nas próximas integrações; versões fixadas continuam disponíveis pelo canal Pinned. A pasta RetroBox-UI-v1.1.0 é parte do caminho histórico real da fonte; não a renomeie para v2.0.0. Receber correções do código de um hub exige seu próprio bootstrap/módulo versionado, além do auto-update da library.

Antes de escrever o script, consulte a documentação e, quando necessário, o código-fonte. Use apenas métodos existentes nessa versão. Se não puder acessar os links, use a API resumida abaixo; peça o trecho relevante se faltar alguma informação essencial. Não invente métodos, objetos do jogo, caminhos de remotes ou nomes de funções do executor.

Contrato permanente de distribuição:
- O modelo principal é URL raw confirmada -> game:HttpGet -> loadstring -> Library:CreateWindow -> window:CreateTab -> tab:CreateSection -> controles.
- Não exija readfile("RetroBox.lua"), ModuleScript no Workspace ou instalação no Studio. Funções de arquivo são opcionais para os perfis; não são pré-requisito do loader.
- Preserve essa sequência nas próximas alterações. Mudanças internas não devem gerar novas exigências de instalação.
- Verifique HTTP/loadstring, conteúdo, compilação, retorno e versão. Não use um raw antigo como se fosse a versão atual; não substitua uma falha de rede por um loader local obrigatório.

Regras de interface:
- Use Library:CreateWindow, window:CreateTab e tab:CreateSection. Organize as funções em abas e categorias coerentes com meu pedido.
- Use Title e Subtitle com o nome do script; tema Retro98 como padrão e Locale = "pt-BR". A library também oferece Terminal, GameBoy, Paper, Midnight, Monokai, Hacker, Dracula, Nord, Sakura, Ocean e Amber. Use os nomes exatos na opção Theme ou em window:SetTheme(name).
- Mantenha Settings = true, ShowProfile = true, Launcher = true e ToggleKey = Enum.KeyCode.RightShift. A aba Configurações já inclui aparência, perfis de salvamento e personalização do botão de reabrir.
- Use DestroyOnClose = false: o X oculta o menu e o Shift direito ou botão de reabrir o abre novamente. Destrua a janela apenas quando houver uma ação explícita para encerrar o script.
- Use Tooltip para explicar funções, valores e atalhos. Description é o texto fixo abaixo do título; Tooltip é a dica ao passar o mouse ou segurar o título no celular.
- Use IDs explícitos, únicos e estáveis nos controles. Não use o prefixo reservado __retrobox/.
- Hide/Show e minimizar/restaurar preservam a última aba, Configurações e rolagem. O launcher UI já aceita arraste pelo corpo ou por :: com mouse/toque, diferencia clique/arrasto e salva sua posição. Use esses comportamentos existentes.
- Aproveite a busca, o perfil e a aba de configurações existentes. Use os componentes necessários ao pedido, sem duplicar esses sistemas.

Experiência e contraste da 1.9:
- Description tem layout medido e compacto quando ausente/oculta. Use ShowDescription=false por controle, control:SetDescriptionVisible(bool) e window:SetDescriptions(bool). ShowDescriptions=true é o padrão global e a preferência já está em Configurações/saves. Tooltip continua disponível mesmo com descrição oculta.
- Tooltips têm atraso padrão .2 s, regiões informativas compartilhadas e botão de informação; toque longo continua funcionando. Use Tooltips=true/TooltipDelay=.2 em CreateWindow e SetTooltips({Enabled?,Delay?,MaxWidth?}). Delay 0–3 e MaxWidth 160–640. Não duplique o sistema de ajuda.
- TextScale=1 e SetTextScale(value) ajustam texto de .8–1.4 separadamente de Scale. A library já oferece foco visível, Tab/Shift+Tab/Enter/Espaço e teclas de listas/árvores. Preserve digitação/captura de teclas e ReducedMotion.
- Cards, gráficos, legendas, escalas, consoles, tabelas e ajuda resolvem tinta sobre a superfície real. Não aplique Text global manualmente a um fundo diferente nem force preto/fundo escuro em todos os temas. Use os componentes nativos, que atualizam sem recriação. Library:ContrastRatio e ReadableColor ajudam em conteúdo visual próprio.
- Campos, bordas e hover já são gerenciados. Não altere as dimensões de linhas internas do Dropdown nem crie uma GUI paralela para corrigir margens.

Identidade visual da versão 2.4.0:
- Preserve o estilo retrô da RetroBox e use o catálogo embutido em títulos, abas, categorias e controles. Escolha ícones de acordo com a função: "home" para início, "eye" para visual, "palette" para cores, "sliders" para ajustes, "save"/"load" para perfis, "target" para mira/campo de visão, "keyboard"/"mouse" para atalhos e "notification" para avisos.
- Window, Tab, Section e os controles de Section aceitam Icon e SetIcon. Notify, Dialog e Confirm também aceitam Icon. Use nomes reais, não métodos inventados como AddIcon ou CreatePixelIcon.
- Library:GetIconNames() retorna o catálogo ordenado, incluindo desenhos registrados; Library:GetIcon(name) retorna uma cópia das linhas ou nil. Há 76 ícones padrão.
- Ícones adicionados na 1.9.1 e disponíveis na 2.3.0: diamond, coins, money, wallet, bank, credit-card; tools, wrench, hammer, screwdriver, pickaxe, axe, shovel, toolbox; sword, bow, chest, backpack, potion, key; crown, trophy, gift; rocket, fish, magnet; clock, map, skull, leaf. Use-os nos controles e no campo Icon dos scripts do hub conforme a função. Todos são embutidos, em grade 12×12, e acompanham os temas.
- Icon = "nome" usa um desenho conhecido. Icon = "pixel:nome" exige que ele exista e informa erro se faltar. Imagens Roblox por rbxassetid://, ID numérico positivo e texto curto/emoji continuam aceitos.
- Omitir Icon na criação usa o padrão na janela, nas abas e categorias. Controles só recebem ícone de título quando o dev escolher um. Icon = false remove; SetIcon(nil) ou SetIcon(false) remove depois.
- Deixe PixelIcons = true e PixelDecorations = true por padrão. A aba Configurações já permite alterar essas preferências; elas entram no save. window:SetPixelIcons(false) desliga os ícones automáticos, mantendo os escolhidos explicitamente pelo dev. window:SetPixelDecorations(false) remove os enfeites estáticos.
- Se o pedido justificar um desenho exclusivo, use Library:RegisterIcon("nome", rows). O nome deve começar com letra minúscula e ter 1–48 caracteres entre letras minúsculas, números, "_" e "-". Use 4–16 linhas e colunas, com largura igual e ao menos um pixel visível. Os caracteres permitidos são "." transparente, "#" cor contextual, "a" Accent, "h" Highlight, "s" Shadow, "m" Muted, "g" Success e "r" Danger.
- Registre desenhos no código do script. Ícones e padrões são metadados do desenvolvedor, não flags do jogador. Registrar novamente um nome atualiza os desenhos montados dessa instância da library.
- AddLabel e SetText aceitam texto com várias linhas; Height é a altura mínima. A library calcula a altura do texto, respeitando largura, ícones, dicas e escala do texto. No hub, Description aparece no destaque do jogo ou card do script; expansão e Info dão acesso ao conteúdo completo.
- Os ícones padrão já são renderizados pela RetroBox sem novos downloads. Os SVGs do repositório são para documentação/design; não tente carregar SVG diretamente em ImageLabel.

Runtime, visualizações e execução herdados da versão 1.9:
- Crie estados com window:CreateState(value, {Name?, Validate?}) ou Library:CreateState para estados independentes. Use state:Get(), Set(value), Update(fn), Subscribe(fn, immediate?) e Destroy(). A janela limpa seus estados. Dados devem ser acíclicos; Subscribe retorna listener com Disconnect.
- Use window:Computed({state1, state2}, function(value1, value2) ... end) para valores derivados. window:GetFlagState(id) observa uma flag já criada. Estados derivados, flags, handle.Status e job.Status são somente leitura.
- Use State=state, TwoWay=false em visualizações. Em controles de entrada, State usa TwoWay=true por padrão; normalização e mudanças silenciosas do controle também atualizam a fonte. FireOnState=true opta por callbacks nas mudanças da fonte.
- control:BindState(state, {Property="Value"/"Text"/"Subtitle"/"Visible"/"Enabled"/"Disabled", Transform=fn, TwoWay=false, FireCallback=false, Reason?}) retorna um scope que pode ser destruído para desfazer a ligação. Um binding novo da mesma Property substitui o anterior. Text requer SetText e Subtitle requer SetSubtitle. Use Transform com TwoWay=false quando não tiver conversão inversa.
- section:AddStatCard({Id, Title, Icon, Value, State?, TwoWay=false, Format="Compact", Unit, Subtitle, Trend, TrendText, Loading, Unavailable, Sparkline, MaxPoints, Animated}). Valores: número finito, texto ou nil. Formatos Raw/Compact/Percent/Time ou function(value); Percent recebe 45 para 45%, Time recebe segundos. Métodos: SetValue, SetUnit, SetSubtitle, SetTrend(number,text?), SetLoading(bool), SetUnavailable(bool,text?), SetHistory, GetHistory e AddPoint.
- section:AddChart({Type="Line"/"Bar"/"Progress"/"Sparkline", Data, MaxPoints=60, Min?, Max?, RefreshRate=20, ShowGrid, ShowLabels, ShowLegend, Legend, Color?, Animated=true}); aliases AddLineChart, AddBarChart, AddProgressChart e AddSparkline.
- Gráficos de histórico usam array de números ou {Value,Label?,Time?}. Use SetData, AddPoint(value,label?,time?), SetRange(min?,max?), SetMaxPoints e Clear. O máximo é 512 pontos, e o padrão 60; o histórico mantém os mais recentes. Tempo é metadado; a distribuição X segue a ordem, não intervalos reais. ProgressChart usa SetValue numérico, limites padrão 0–100 e não aceita AddPoint. Não crie Frames/loops novos para redesenhar esses gráficos.
- Cards/gráficos são transitórios, mesmo se Persist=true for informado. Não salve histórico, ações ou recursos de sessão em perfis. Para State de séries criada pelo script, limite o array também na fonte.
- Use window:CreateScope() ou control:CreateScope(), scope:Add(resource, method?, key?), Clean(), Destroy(), Remove(key, keep?) e Child(options?). Window e Control têm Manage(resource, method?, key?). Conexões, Instances, funções de cleanup e handles com Destroy/Disconnect/Cancel/Stop são aceitos; uma chave repetida limpa o recurso antigo.
- Scopes opcionais aceitam CancelOnHide, CancelOnDisable e CancelOnFalse; Disable/False valem para controle. Limpeza é em ordem inversa e protegida. Scopes da janela/controle já são limpos no Destroy; Library:CreateScope cria um independente que você deve limpar.
- Para trabalho periódico, use window:CreateTask({Id, Interval=.5, Callback=function(ctx) ... end, Start=false, Immediate=true, OnError="Stop"}) ou control:CreateTask. Métodos Start, Stop/Cancel, SetInterval, IsRunning e Destroy. A janela tem StartTask(id), StopTask(id) e StopAll(reason).
- Start é idempotente. Callbacks periódicos não se sobrepõem, mesmo com yield; reiniciar espera a execução antiga retornar. Interval aceita .03–86400 s, máximo 128 tarefas por janela. OnError pode ser Continue; padrão Stop.
- ctx:IsCancelled(), ThrowIfCancelled(), Cancel(reason) e Manage(resource, method?, key?) controlam uma iteração/operação. Verifique cancelamento antes dos efeitos e depois de waits. Cleanup não encerra à força código bloqueante ou um yield que nunca retorna; não dependa de task.cancel ou API específica de executor.
- Ocultar, fechar com X, minimizar e trocar aba mantêm o trabalho ativo por padrão. Destroy encerra os recursos gerenciados; StopAll cancela tarefas e ações, sem destruir conexões/Instances avulsas. Opte por CancelOnHide apenas quando o pedido exigir; tarefas do Control podem usar CancelOnDisable/CancelOnFalse.
- window:RunAction({Id?, Group, Policy="Reject"/"Ignore"/"Queue"/"Replace", Callback=function(ctx) ... end, OnProgress?, OnComplete?, CancelOnHide?}) retorna handle ou nil, reason. Reject recusa; Ignore retorna "ignored"; Queue espera; Replace cancela ativa/fila e espera a ativa retornar antes da substituta.
- Use handle:GetStatus(), Subscribe(fn, immediate?), Cancel(reason), Result e Error. Status contém Status, Step, Total, Progress (0–1), Message e resultado/erro final. Estados: Queued/Running/Cancelling/Cancelled/Completed/Failed. O histórico terminal retém até 32 handles: guarde resultados se precisar deles depois.
- ctx:SetProgress(step,total,message?) e SetMessage(text) atualizam a ação; ctx.Action expõe o handle para bindings. AddButton({Group?,Policy?,Cancelable=true,Callback=function(control,ctx) ... end}) integra o runtime e permite button:GetAction()/Cancel(). Um botão ocupado evita outro Press; use grupos entre botões ou RunAction para filas/substituição.
- Use DependsOn={Visible=rule, Enabled=rule, Reason="Explicação"} ou control:DependsOn. Regras: {Flag="id",Equals=value}, {State=state,Test=fn}, {All={...}}, {Any={...}}, {Not=...}, State ou boolean. All/Any/Not correspondem a AND/OR/NOT. Window:Condition(rule) retorna estado booleano somente leitura. Mantenha Test/Computed/Transform sem efeitos colaterais.
- window:SetFlags({id=value,...}, {Silent=false}) valida todas as flags primeiro. Erro retorna false, reason sem aplicar nenhuma. Valores alterados são aplicados antes dos callbacks/observadores; callbacks pendentes antigos são descartados. Silent evita callbacks/OnChanged, mas mantém observadores, bindings e UI.
- Library:Batch(function() ... end) agrupa notificações de State. Não dê yield dentro de Batch e não use como rollback de código arbitrário: escritas anteriores a um erro permanecem.

Integração de tarefas e ações na 1.6:
- window:AwaitAction(handle, options), handle:Await(options) e ctx:AwaitAction(handle, options) retornam (ok, resultOrReason, status). Completed retorna true e o resultado original; Failed, Cancelled, TimedOut e Rejected retornam false e um motivo. Throw=true propaga erros. Conclusões anteriores à espera são reconhecidas, inclusive depois de remover um handle do histórico.
- Options aceita Timeout (0–86400 s), Context (token da mesma janela), CancelAction=false e Throw=false. A forma ctx fornece Context automaticamente. Cancelar o contexto/atingir timeout encerra só a espera por padrão; CancelAction=true também solicita cancelamento da operação original. Não cancele uma ação compartilhada por outros workers sem decidir sua propriedade. Falhas normais da ação não disparam outro cancelamento.
- Espere apenas em worker/callback que possa dar yield. Não crie polling por frame. Uma espera pendente fora de worker, na própria ação ou em uma fila do grupo ocupado pelo próprio ctx é rejeitada. Timers/listeners são limpos na conclusão/cancelamento/Destroy. Há até 256 esperas por janela; GetRuntimeStats().WaitingActions conta esperas, não a fila de grupos.
- ctx:OnCancel(fn) é opcional; recebe motivo e retorna listener com Disconnect. Use Manage para outros recursos. Cancelamento de código longo permanece cooperativo: verifique ThrowIfCancelled após waits e antes dos efeitos.
- CreateTask aceita Group="nome" e Policy="Queue"/"Ignore"/"Reject"/"Replace". Com Group, Queue é o padrão e a iteração utiliza o mesmo gerente de RunAction. Policy sem Group é inválida. Não recrie mutex ou loop de fila no script.
- Queue aguarda; Ignore pula a tentativa (LastOutcome=Skipped); Reject falha segundo OnError; Replace cancela ativa/fila cooperativamente e aguarda a ativa retornar. A tarefa mantém uma única iteração em fila/execução, sem acumular períodos atrasados. Interval é contado após conclusão inteira, incluindo tempo de fila. Limites: 32 grupos e 32 ações em fila por grupo.
- Stop de uma tarefa agrupada cancela sua própria ação, inclusive na fila, sem cancelar outro dono do grupo. Restart aguarda o worker antigo. Em callback agrupado, ctx.Task é a tarefa e ctx.Action fornece progresso. return false, reason segue o contrato de falha de RunAction; em tarefa sem Group, lance error para OnError.
- job.Status é State somente leitura; job:GetStatus() copia o snapshot e calcula Remaining, e job:Subscribe(fn, immediate?) observa fases/dados. Fases: Inactive, Waiting, WaitingForGroup, Running, Cancelling, Stopped, Failed, Destroyed. Campos: Id, Requested, Active, Running, InFlight, Interval, Iterations, NextRun, StartedAt, FinishedAt, LastResult, LastError, LastOutcome, StopReason e Group.
- Requested mostra a intenção; Active é Requested ou InFlight, Running indica callback e IsRunning mantém o sentido amplo de solicitado/retornando. LastResult guarda o último sucesso, LastError permanece até sucesso/restart. Status só armazena resultados representáveis em State; job.LastResult retém o original. Remaining é derivado do prazo monotônico; leia em frequência moderada (.5 s, por exemplo), sem tentar observar uma contagem por frame.
- toggle:BindTask(job, {Initial="Control", OnStop="TurnOff", FireCallback=false, StopOnUnbind=true}) retorna scope e substitui a associação anterior. Initial="Task" espelha Requested; OnStop="KeepRequested" mantém intenção visual após parada externa. O toggle inicia/para a tarefa e reflete erros/paradas/restarts sem duplicação ou recursão. Evite outro callback manual iniciando a mesma tarefa.
- O toggle representa solicitação. Desligado pode coexistir com Cancelling enquanto o callback sai. OnError="Continue" mantém o toggle ligado entre tentativas; KeepRequested após parada não significa que existe execução. Mostre o status efetivo quando essa distinção importar. Destruir o scope desfaz a ligação e solicita parada por padrão; StopOnUnbind=false mantém a tarefa da janela.

Migrações de perfis do script:
- CreateWindow aceita ConfigVersion=1, Migrations={[1]=function(profile, from, to) ... end} e UnknownFlags="Ignore"/"Preserve"/"Reject". ConfigVersion é o esquema das configurações do script, independente de Library.Version=2.4.0 e Schema=1. Perfis antigos sem ConfigVersion são tratados como 1.
- Ao renomear IDs/tipos, incremente ConfigVersion e registre cada passo de from para from+1. Também há window:SetConfigVersion(integer) e RegisterMigration(fromVersion, callback). Versões são inteiros 1–65535, até 32 passos por importação.
- Migrações trabalham numa cópia: podem editar Flags, converter valores/tipos, definir novos padrões ou remover campos; retornam nil após editar ou uma tabela substituta. São síncronas, sem yield/remotes/efeitos externos. Não execute código vindo de dados importados e não mantenha controles obsoletos só para converter saves.
- O runtime migra antes de validar e aplicar o lote. Versão futura, etapa ausente, erro/yield e dados inválidos retornam false, motivo sem aplicar controles nem sobrescrever o original. Load converte a cópia; SaveConfig grava a versão atual. Carregar uma versão já convertida não repete passos; um arquivo antigo não salvo continua precisando de conversão a cada load.
- ImportConfig/LoadConfig aceitam Migrate=false e UnknownFlags por chamada; Strict=true força Reject. Ignore é o padrão compatível; Preserve reexporta flags de IDs desconhecidos e não salva controles conhecidos transitórios/internos. Metadados desconhecidos do topo e campos diretos de Appearance são preservados; opções aninhadas conhecidas não têm promessa de retenção.
- Crie controles, tarefas, bindings e registre migrações antes do load. Todas as flags/aparência são aplicadas antes dos observadores/callbacks. Silent=true mantém BindTask: carregar um toggle ativo explicitamente vinculado pode iniciar a tarefa após o lote. Não execute ações momentâneas só por restaurar um perfil.

Componentes de dados da 1.9:
- section:AddVirtualList({Id,Title,Items,Height=280,RowHeight=32,Searchable=true,Format?,GetKey?,OnSelect?,DataState?,State?,Persist=false}) exibe apenas um pool de linhas. Items é array denso de texto/records; records usam Id/Key ou GetKey(item,index). Chaves únicas viram texto de 1–128 bytes. Sem chave explícita usa índice: prefira IDs estáveis para refresh/seleção/rolagem.
- Métodos: SetItems/GetItems, GetSelected() -> item,chave, SetQuery(text), SetFilter(predicate ou nil), SetLoading(bool), ScrollToKey(key) -> bool e GetViewStats(). Callback(key,control) é mudança de seleção; OnSelect(item,key,index) detalha a linha. DataState observa dados; State vincula a seleção. Dados/copias são limitados e sem funções/Instances/ciclos.
- Limites de listas: até 20.000 itens, sujeitos ao orçamento de 32.768 chaves/16 níveis; pool máximo 64, overscan 2; Height 120–900 e RowHeight 28–80. Só seleção pode persistir quando Persist=true; dados/históricos não entram automaticamente no perfil. Crie dados compatíveis antes de carregar seleção salva.
- section:AddDataTable({Id,Title,Rows,Columns,Height?}) reutiliza a lista. Columns: 1–16 registros {Key,Title?,Width?,Weight?,MinWidth?,Sortable=true,Format?}. Width explícita 48–1200 px; Weight padrão 1 (até 100); MinWidth padrão 88 (48–600). Colunas flexíveis distribuem espaço; rolagem horizontal mantém colunas legíveis.
- Tabela aceita SetRows (alias SetItems), Sort(key,descending=false), pesquisa, filtros, loading, seleção, dados/bindings e menu de linha. Format(value,row,index) deve ser puro; nil aparece como travessão. Atualizar dados não deve reconstruir controles. Use IDs estáveis e fontes de dados limitadas.
- section:AddTreeView({Id,Title,Nodes,Height?,Default?,NodesState?,State?}) usa nós {Id,Text?,Title?,Icon?,Children?}; IDs únicos, até 5.000 nós/profundidade 16 e o mesmo orçamento de cópia. SetNodes, SetExpanded(id,bool), IsExpanded, ExpandAll(bool=true), SetQuery. Busca mantém ancestrais; clique/Enter alterna; Left/Right recolhe/expande. A lista de nós visíveis é reciclada.
- Controles/listas aceitam SetContextMenu(itemsOrProvider). Em lista/tabela, provider(item,key,control) corresponde à linha atual; não capture um índice de row reciclada. Menu: window:ContextMenu({Items,Width?},pointOrGuiObject?) -> handle; Items admite {Text,Icon?,Disabled?,Callback?,Confirm?,Items?} e {Separator=true}. Confirm é texto; submenus usam Items. Até 64 itens/nível, quatro níveis, 256 totais. Clique fora/Escape fecha; teclado e toque longo disponíveis.
- section:CreateDashboard({Id,Title,Columns=2,Gap=12,StackAt=480,Editable=false}) organiza os próprios AddStatCard/AddChart/aliases/AddProgress/AddLabel. Widgets têm Id, Span e Height. Até 256 widgets, 1–4 colunas. Não recrie um sistema de gráficos: use os mesmos componentes e bindings.
- Dashboard: GetLayout, ValidateLayout, SetLayout({Order={ids},Widgets={[id]={Span,Height}}}), SetOrder(ids), SetWidgetLayout(id,{Span?,Height?}), ResetLayout. Editable=true oferece menu para ordem, span, altura e reset. Grid empilha quando estreita. Só layout é salvo; não persista dados de sessão. Defina IDs estáveis e monte todos os widgets antes do load.

Temas e ferramentas da 1.9:
- O Theme Studio tem Fechar editor. Use window:CloseThemeStudio() ou studio:Close(); quando sujo, oferece Save/Discard/Cancel. APIs explícitas: Close("Save", profileName), Close("Discard"), Close("Cancel"), IsDirty(), Destroy(). Fechar remove a view temporária e retorna à aba anterior, preservando catálogo/tema em fechamento normal. Descartar volta ao catálogo da abertura/último save; uma variação descartada deixa de existir. Não recrie o editor.
- Seis temas novos: Hacker (preto/verde), Dracula (roxo/lilás), Nord (azul gelo), Sakura (claro/rosa), Ocean (azul/turquesa) e Amber (âmbar escuro). Todos são paletas oficiais completas. GetThemeNames lista os temas registrados; não invente nomes e não recrie o seletor já disponível nas Configurações. Mantenha Retro98 como padrão, exceto quando eu solicitar outro tema.
- Theme Studio já está em Configurações; window:OpenThemeStudio() ou ThemeStudio=true abre/reutiliza. Preview usa componentes reais. Oficiais ficam protegidos no editor: crie uma variação antes de editar. Não monte um editor paralelo.
- APIs: GetThemeRoles/GetThemeColors(name), CreateTheme(name,base?), DuplicateTheme(source,name), SetThemeColor(name,role,color), RestoreTheme(name), DeleteTheme(name), ExportTheme(name?), ImportTheme(source,{Name?,Replace=false}), CheckThemeContrast(name?). Até 32 temas locais; nomes de 1–48 bytes; JSON até 16 KiB, sem executar código. ImportTheme retorna ok,nome ou false,erro.
- Tokens reais: Background, Surface, Inset, Text, Muted, Border, Highlight, Shadow, Accent, AccentText, Success, Danger. Hover usa Highlight, seleção Accent/AccentText e plots Inset/Accent. A resolução contextual protege o texto sem mudar os valores originais da paleta exportada.
- Catálogos/layouts/preferências usam Appearance.Advanced no perfil normal. SaveConfig salva catálogo junto com configurações. LoadThemeCatalog(profileName) carrega só catálogo de temas, sem reativar flags do script. LoadConfig continua carregando as configurações completas e bindings conforme as regras anteriores.
- Runtime Inspector é opcional e para desenvolvimento: OpenRuntimeInspector({AllowCancel=false,Interval=1}), ou RuntimeInspector=true/opções em CreateWindow. Debug oferece acesso, sem abrir automaticamente. Evite expor para todos os jogadores sem motivo.
- GetRuntimeSnapshot retorna Stats/Tasks/Actions/Groups/Resources/Diagnostics com resumos, sem Instances dos recursos. Inspector observa fases por Subscribe e usa relógio .25–10 s para prazos/recursos, sem polling visual por frame. Recursos detalhados até 256; diagnósticos 64; histórico de ações 32. Refresh e Destroy são métodos do painel.
- Cancelamento pelo inspector exige AllowCancel=true e confirmação. Preserve isso no fluxo do usuário. Cópia usa setclipboard somente quando disponível; o campo de texto permite copiar manualmente sem essa função. Não prometa capacidades de executor que não verificou.
- Command Palette usa F4 por padrão; CommandKey, SetCommandKey(Enum.KeyCode) e Configurações trocam o atalho; Unknown desativa. OpenCommandPalette reúne busca de componentes, abas e comandos. Navegar ao controle não executa seu callback.
- RegisterCommand({Id,Title,Description?,Icon?,Enabled?,Confirm?,Group?,Policy?,Callback=function(ctx,window,command) ... end}) registra até 128 ações explícitas. Id 1–128, Title 1–256. Enabled é bool/predicate; Confirm é texto. Retorna registration:Destroy. ExecuteCommand(id) usa RunAction: handle/erro, ou nil,"confirmation pending". Grupo padrão é Id e Policy padrão Reject. Preserve cancelamento cooperativo.
- GetCommandResults(query) retorna até 100 resultados Kind/TargetId/Title/Description/Id/Text. Digitar ou destacar um resultado não executa nada; seleção explícita aciona navegação/comando. Não use a pesquisa para disparar automaticamente funcionalidades do script.

Script Hub Mode opcional da 1.9:
- Library:CreateScriptHub(options) cria hub/janela. window:CreateScriptHub(options) anexa à mesma janela. Retornam manager com Window, Tab, Id. O modo tradicional continua sendo o padrão; use o hub apenas quando eu solicitar um catálogo de jogos/scripts.
- Opções: Id, Title, Theme, Locale, ConfigFolder e demais opções normais da janela na factory; WindowId/HubId se quiser IDs separados; AutoDetectGame=true, ConfirmTeleport=true e Teleporter opcional.
- Games é array de {Id,Name?,PlaceId?,UniverseId?,Description?,FallbackName?,Notes?,Image?,Order?,Scripts={...}}. Id continua obrigatório; Name pode ser omitido com PlaceId/UniverseId válido e GameMetadata habilitado desde a 2.1.0. IDs internos têm 1–64 letras/números/ponto/hífen/sublinhado. Até 512 jogos/4096 scripts no total/128 por jogo. PlaceId é o lugar; UniverseId é game.GameId, usado para GameIcon. Não confunda esses IDs, nem invente IDs reais. Use somente dados fornecidos ou verificados.
- Scripts: {Id,Title,Description?,Icon?,Author?,Version?,Status?,Enabled?,CurrentGameOnly?,Requires?,Confirm?,Callback?}. Callback(ctx,hub,gameMetadata,scriptMetadata) é registrado pelo dev em código. Enabled aceita bool/predicate(hub,gameMetadata,scriptMetadata). Requires aceita HttpGet/loadstring/readfile/writefile/setclipboard para a ação. Sem callback fica indisponível. Perfis não contêm código executável; o catálogo não interpreta URLs como scripts.
- Métodos reais: AddGame(record), UpdateGame(id,patch), RemoveGame(id), GetGame(id), GetGames(), SelectGame(id), GetSelectedGame(), DetectCurrentGame(), IsCurrentGame(id), SetGameQuery(text), SetScriptQuery(text), SetSort("Order"/"Alphabetical"/"Favorites"), IsFavorite(id), SetFavorite(id,bool), AddScript(gameId,record), UpdateScript(gameId,scriptId,patch), RemoveScript(gameId,scriptId), GetScript(gameId,scriptId), IsScriptAvailable(gameId,scriptId), GetScriptStatus(gameId,scriptId), RefreshScripts(), RunScript(gameId,scriptId,{Confirmed?}), GetThumbnailStatus(gameId), RetryThumbnail(gameId), TeleportToGame(gameId,{Confirmed?}), Show(), Hide(), Destroy().
- Cadastros/patches invalidam antes de mutar e rejeitam IDs duplicados; UpdateGame/UpdateScript cancelam a execução da versão anterior do cadastro. GetGame/GetScript retornam metadados, sem callbacks. Executar script usa RunAction e grupo exclusivo por entrada. Resultado real define Completed/Failed; retornar false,motivo falha. Coopere com ctx:ThrowIfCancelled/IsCancelled/AwaitAction/Manage; ctx:Wait(seconds) está implementado na 2.1.0 para espera instrumentada; não invente ctx:Sleep.
- AutoDetectGame prioriza PlaceId exato; depois UniverseId. Se não houver correspondência, mantém navegação normal. Detecção/seleção/carregamento de save não executam scripts nem teleporte. Favoritos, ordenação e seleção são flags estáveis hub/<HubId>/favorites, /sort, /games. Construa o catálogo antes do load. Dados, callbacks, imagens e histórico de execução não são salvos.
- Miniaturas: Image personalizado é ID numérico ou conteúdo Roblox rbxassetid/rbxthumb/rbxasset; URLs web não são colocadas no ImageLabel. UniverseId -> GameIcon 150x150; PlaceId sem UniverseId -> GameThumbnail 256x144. Carregamento não bloqueante via ContentProvider, quatro pedidos simultâneos/cache máximo 128, fallback pixel art. Não prometa que um asset será permitido em todos os ambientes.
- Teleporte é explícito e confirmado por padrão; usa PlaceId. TeleportToGame retorna handle/erro ou nil,"confirmation pending". Uma solicitação não confirma a chegada e não inicia scripts automaticamente. Captura falhas síncronas/TeleportInitFailed e encerra espera local não confirmada após 30s.
- O caminho nativo cliente usa TeleportService:Teleport, legado e sujeito às restrições do ambiente. TeleportAsync é de servidor; nunca o chame no cliente. Teleporter(placeId,player,gameMetadata,ctx) integra uma implementação autorizada da experiência; retorne false,motivo quando rejeitar. Não invente remotes nem tente contornar proteções.
- O hub acompanha temas, viewport responsivo, pesquisa e teclado da RetroBox. Use o layout nativo 2.0 e preserve os scopes. Destroy limpa o hub; quando a factory criou a janela, limpa a janela também. Não construa uma segunda library de interface para o hub.

Distribuição e atualizações da 2.3.1:
- O bootstrap permanente é https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua. Ele retorna a Library após resolver, conferir tamanho/SHA-256, compilar e validar uma versão compatível. Stable é o padrão; Preview é independente e Pinned usa {Channel="pinned",Version="2.3.1"} após publicar a release. Passe as opções ao chunk do bootstrap, como loadstring(game:HttpGet(URL))({Channel="stable"}).
- Stable usa dist/channels/stable/v2.json; Preview usa dist/channels/preview/v2.json. O bootstrap aceita somente major 2/API 2 e, por padrão, o intervalo >=2.0.0 e <3.0.0. Uma futura API 3 terá outro bootstrap. Versões são comparadas semanticamente; não compare strings nem restrinja todos os scripts a Version=="2.0.0" quando optaram por Stable.
- O mesmo loader recebe a próxima release compatível na próxima execução. A janela atual não é substituída. Scripts que ainda usam o commit da 1.9.2 precisam migrar o loader uma vez; um commit histórico continua imutável.
- Cache=true é opcional e usa arquivo quando as capacidades existem, ou sessão quando não existem. Fallback validado retorna State="Fallback", a versão usada e o erro original, com aviso; Fallback=false proíbe a recuperação. O cache não elimina o download inicial do bootstrap. Sem HTTP/loadstring/bit32 necessários, informe a falha; não exija arquivo local ou tente contornar restrições.
- Library:GetVersion(), CheckForUpdates(options?) -> status,error?, GetUpdateStatus(), ParseVersion(text), CompareVersions(a,b) -> -1/0/1 e SHA256(bytes) estão implementados. Check consulta metadados sem aplicar código, destruir janelas ou alterar perfis. Relatórios mostram canal, versão em execução/disponível, build, compatibilidade, estado, última verificação e erros quando aplicáveis.
- Library:CreateUpdater(options) é o cliente de distribuição explícita: Root HTTPS, Kind RetroBox/Hub/HubCatalog, Major, Channel, Version para pinning, APIVersion, MinVersion, MaxVersion exclusivo, CurrentVersion, Cache, Fallback e ManifestPath relativo opcionais. Métodos Check(), Load("json"?), GetStatus() e SetChannel(channel,version?). Não invente uma origem nem extraia instruções de atualização de perfis.
- Library, módulo de código do Hub, catálogo e ConfigVersion são versões diferentes. Atualizar a library não publica o código de um hub local. Use o bootstrap do hub e LoadHub para receber correções do código; CatalogUpdate serve para dados. APIs e publicação estão em docs/AUTO-UPDATE.md, HUB-AUTO-UPDATE.md e MIGRATION-2.0.md.
- SHA-256 confirma bytes; não é assinatura contra conta do publicador ou host comprometido. O código só vem da origem explicitamente configurada. Manifestos contêm paths relativos; catálogo JSON não pode fornecer Callback, URL, Source, loadstring ou mudança de origem.

Script Hub 2.3 — launcher nativo e atualizações:
- O launcher é a apresentação nativa padrão de Library:CreateScriptHub e window:CreateScriptHub, compartilhada por qualquer desenvolvedor. O destaque usa imagem em Crop, dividida com as informações quando há largura e como capa quando estreito, sem rótulo Miniatura. Image personalizado tem prioridade; com PlaceId, a imagem principal usa GameThumbnail, enquanto as linhas continuam usando GameIcon por UniverseId quando disponível. Sem imagem carregada, há placeholder pixel art; campos de status vazios não ocupam painel.
- Desktop utiliza colunas com rolagem independente e proporção padrão .31/.69; telas estreitas empilham. NavigationRatio aceita .3–.55, StackAt 480–1000 (padrão 700), ScriptListMaxRows 1–12 (padrão 4) e GameListMaxRows 2–16 (padrão 7). Respeite Scale, TextScale e ReducedMotion. Não desenhe uma GUI paralela para alterar esse componente.
- Linhas compactas e recicladas mostram seleção também com marcador. A lista de scripts serve para seleção, sem botão Play interno. Um único botão principal se chama Executar script / Run Script; hub.PlayButton conserva o nome de referência por compatibilidade. Entrar no jogo / Join game continua separado. Seleção, pesquisa, detecção, load de perfil ou de catálogo não executam nem teleportam.
- SelectScript(id) -> bool,motivo e GetSelectedScript() foram adicionados. Um único script é selecionado; a última escolha válida por jogo é lembrada na sessão. Listas crescem de 1 a 4 linhas no padrão e depois usam rolagem interna. Pesquisas têm limpeza e usam os métodos SetGameQuery/SetScriptQuery existentes. A pesquisa global também navega ao painel certo.
- A execução continua usando RunScript e RunAction; cliques duplicados são bloqueados. ExecutionStatus mostra estado/progresso/resultado real; CancelButton solicita cancelamento cooperativo quando há ação ativa. Não informe Concluído antes de o callback terminar. A descrição do jogo é expansível; cards resumem a descrição do script e Info mostra os textos completos e Notes. GameDetails/ScriptDetails continuam atualizados para compatibilidade e foco.
- Um hub aceita Version="1.0.0", CatalogVersion opcional, Actions={nome=function(...) ... end}, CatalogUpdate={Root,Major=1,Channel="stable",AutoLoad=true,Cache?} e CodeUpdate opcional. AutoLoad só existe após optar por CatalogUpdate; faz uma operação de startup sem polling e sem executar scripts. AutoLoad=false exige ReloadCatalog manual.
- O catálogo versionado é JSON com SchemaVersion=1, Kind="HubCatalog", HubId, Version e Games. Os registros usam os campos documentados; um script pode usar Action="nome" para ligar a uma função registrada em Actions. Unknown Action deixa indisponível. Enabled é boolean e Icon é texto no JSON. Callbacks, URLs executáveis e campos desconhecidos nas entradas são rejeitados. Se Action for omitida para um ID existente, os callbacks e requisitos locais anteriores podem ser preservados; o JSON nunca cria uma função.
- hub:GetVersion() retorna o código do hub, enquanto hub.CatalogVersion retorna a versão dos dados. CheckForUpdates() -> status,error?, GetUpdateStatus(), SetUpdateChannel(channel,version?) e ReloadCatalog(context?) -> ok,reportOrError estão implementados. Status separa Catalog/Code, inclui Version/CatalogVersion/LibraryVersion e reporta falhas. Reload valida todo o catálogo antes de aplicar e reutiliza janela/listas/IDs; mantém favoritos e seleções ainda válidos, perfis, tema e posições.
- Library:LoadHub({Root,HubId?,Major=1,Channel="stable",APIVersion=1,Settings={...},Cache?}) -> hub,reportOrError carrega um módulo autorizado que retorna {Version,Start=function(Library,settings) ... end}. Manifesto do Hub inclui compatibilidade com RetroBox. Start retorna um Script Hub. Correções de código são aplicadas na próxima inicialização, sem hot swap ou destruição inesperada da janela ativa. CodeUpdate em um hub local só oferece consultas, não publica nem substitui o script consumidor.
- Publique novas releases com tools/build_distribution.py (library) ou tools/build_hub_release.py (Hub/catalog). O mantenedor promove Stable após testes e verifica os RAWs. Rollback muda o apontamento do canal para uma release histórica válida; não edita artefatos anteriores. Estes arquivos pertencem ao checkout do publicador, não ao executor do usuário.

Exemplo adicional de Script Hub 2.0, após carregar Library. Os dados e ações abaixo são de demonstração, não scripts reais de um jogo:

```lua
local hub=Library:CreateScriptHub({
    Id="meu-hub",Title="Meu Hub",Version="1.0.0",Theme="Hacker",Locale="pt-BR",
    Games={{Id="sessao",Name="Jogo desta sessão",PlaceId=game.PlaceId>0 and game.PlaceId or nil,
        Description="Demonstração de seleção e execução explícita.",Scripts={{Id="aviso",Title="Mostrar aviso",
            Description="Um callback local cadastrado pelo desenvolvedor.",Icon="info",Callback=function(ctx,activeHub)
                ctx:ThrowIfCancelled();activeHub.Window:Notify({Content="Aviso de demonstração."});return {Shown=true}
            end}}}},
})
hub:SelectScript("aviso") -- seleciona; não executa
-- Execução somente por uma ação explícita do usuário: hub:RunScript("sessao","aviso")
```

Exemplo de bootstrap do hub usando as origens de demonstração incluídas no pacote (publique-as antes de usar por HTTP). Ao adaptar, publique a própria origem antes de substituí-la; não invente URLs funcionais:

```lua
local base="https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/hub-distribution/"
local updatedHub,report=Library:LoadHub({Root=base.."code",HubId="hub-update-demo",Major=1,APIVersion=1,
    Settings={CatalogRoot=base.."catalog"}})
if not updatedHub then error(report) end
updatedHub:Show()
```


Animações, aparência e diagnóstico:
- A janela aceita Animations={Enabled=true,Speed=1,Intensity="Normal"}, SmoothDragging=true e DragResponsiveness=24. Desde a 2.6.0 o arraste manual também é suavizado por padrão; ao soltar, a posição final é aplicada sem inércia pendente. SmoothDragging=false/SetDragOptions({Smooth=false}) preserva movimento direto. Speed .25–4, Intensity Normal/Subtle/Off e resposta 8–80. Use SetAnimations/GetAnimations e SetDragOptions({Smooth?,Responsiveness?}); as preferências existentes continuam salvas/restauradas.
- ReducedMotion=true elimina transições; respeite a preferência. Charts e StatCards animam por padrão desde a 2.6.0. Animated=false desliga os efeitos de um controle e seus componentes internos; não recrie animações paralelas para recursos já cobertos pela library.
- tab:CreateSection({Title,Icon,Collapsible=true,Collapsed=false}) oferece SetCollapsed(bool,instant?) e IsCollapsed(). A busca expande o destino antes de navegar.
- O ColorPicker mantém título externo e HEX separado da amostra. Use o componente nativo em vez de recriar campos que possam se sobrepor.
- Notify também aceita Kind="warning" e "loading"; loading usa ícone estático. Diálogos bloqueiam interação até terminar a saída.
- Debug=true ou window:SetDebug(true) acrescenta traceback/estado quando disponível. GetDiagnostics() retorna os últimos 64 registros; OnError(fn) retorna listener. GetRuntimeStats() oferece contagens de tarefas/ações/recursos/animações.
- CallbackExecutor(callback,args,context) é um adaptador opcional, configurado por CreateWindow ou SetCallbackExecutor. Ele precisa executar e retornar o resultado do callback dentro da própria chamada; não agende outra execução. Sem necessidade real, use a execução padrão.

API essencial:
- section:AddToggle({Id, Title, Default, Callback}): Callback(enabled).
- section:AddSlider({Id, Title, Min, Max, Step, Default, Suffix, Callback}): Callback(value).
- section:AddInput({Id, Title, Default, Placeholder, Live, MaxLength, Validate, Callback}): Callback(text). Validate(text) retorna true ou false, reason.
- section:AddDropdown({Id, Title, Options, Default, Searchable, Multi, Callback}): valor único string/nil ou array de strings com Multi = true.
- section:AddButton({Title, Text, Feedback, Callback}): o callback recebe o controle. Feedback = true mostra andamento e resultado; return false, "motivo" informa falha. Não retorne sucesso antes de a ação terminar.
- section:AddKeybind({Id, Title, Default, Mode, Callback}): Callback(active, binding); binding é o EnumItem atribuído. Mode aceita "Press", "Toggle" ou "Hold". Default aceita Enum.KeyCode ou Enum.UserInputType.MouseButton1, MouseButton2 e MouseButton3.
- Um toggle pode receber Keybind = {Default = Enum.UserInputType.MouseButton2, Mode = "Toggle"} para exibir a captura ao lado. A library permite clicar no campo e escolher teclado ou mouse; toggle.Keybind expõe esse controle. OnChanged observa a mudança da tecla, enquanto Callback executa a ação do atalho.
- Toggle, Button e Keybind aceitam Floating = {Text = "AÇÃO", MobileOnly = true, Position = Vector2.new(0.04, 0.65)}. Por padrão, o atalho aparece em dispositivos com toque quando o menu está oculto ou minimizado.
- section:AddColorPicker({Id, Title, Default, AllowRainbow, AllowOpacity, Callback}): Callback(currentColor, opacity, manualState). Default pode ser {Color = "#00AA88", Opacity = 1, Rainbow = false, Speed = 6}. Speed é o número de segundos por ciclo. Opacity é inversa de Transparency. O RGB já é animado pela library; não crie outro loop de cores.
- section:CreateRow({Gap = 10, StackAt = 440}) retorna uma linha que aceita os mesmos AddToggle, AddSlider, AddButton e demais componentes. A linha se adapta à tela.
- Também existem AddLabel, AddSeparator, AddProgress, AddConsole e AddImage; consulte as opções na documentação.
- control:GetValue(), control:SetValue(value, silent?), control:OnChanged(callback), control:SetDisabled(bool) e control:SetTooltip(text).
- Default não executa o callback por padrão. Inicialize a lógica com os mesmos valores ou use FireOnInit = true quando o callback puder aplicar o estado inicial.
- window:GetFlag(id) e window:SetFlag(id, value, silent?): use esses métodos para alterar controles; escrever diretamente em window.Flags não atualiza a interface.
- window:Notify({Title, Content, Icon, Kind = "normal"/"success"/"error"/"warning"/"loading", Duration}).
- window:Confirm({Title, Content, Icon, ConfirmText, CancelText, OnConfirm, OnCancel}) para uma ação que exige confirmação.
- window:Dialog({Title, Content, Icon, Buttons = {{Text, Callback}}, ...}) para diálogos personalizados; admite de um a três botões.
- window:SearchControls(text) lista resultados; window:FocusControl(id) navega ao componente sem executar sua função.
- window:OnDestroy(callback) permite limpar recursos próprios do script.

Exemplo funcional de montagem da interface. Ele demonstra controles que personalizam a própria janela; adapte os componentes e callbacks às funções reais do meu pedido:

```lua
local RETROBOX_URL = "https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua"

local ok, Library = pcall(function()
    assert(type(loadstring) == "function", "Este executor não expõe loadstring.")
    local hasHTTP, getter = pcall(function() return game.HttpGet end)
    assert(hasHTTP and type(getter) == "function", "Este executor não expõe game:HttpGet.")
    local source = game:HttpGet(RETROBOX_URL)
    assert(type(source) == "string" and #source > 0, "O raw retornou uma fonte vazia.")
    local chunk, compileError = loadstring(source)
    if not chunk then error(compileError) end
    return chunk({Channel="stable", MinVersion="2.9.0"})
end)

if not ok then
    warn("Falha ao carregar RetroBox: " .. tostring(Library))
    return
end
if type(Library) ~= "table" or Library.APIVersion ~= 2 then
    warn("O endereço não retornou uma RetroBox compatível com a API 2.")
    return
end

local window = Library:CreateWindow({
    Id = "MeuScript-" .. tostring(game.PlaceId),
    Title = "Meu Script",
    Subtitle = "RetroBox UI",
    Icon = "retrobox",
    PixelIcons = true,
    PixelDecorations = true,
    Theme = "Retro98",
    Locale = "pt-BR",
    ToggleKey = Enum.KeyCode.RightShift,
    Settings = true,
    ShowProfile = true,
    Launcher = true,
    DestroyOnClose = false,
    ConfigFolder = "RetroBox/MeuScript/" .. tostring(game.PlaceId),
    ConfigVersion = 1, -- versão das configurações DESTE script
    SmoothDragging = true,
})

local tab = window:CreateTab({Title = "Exemplo", Icon = "grid", Columns = 1})
local section = tab:CreateSection({Title = "Componentes", Icon = "folder"})

section:AddToggle({
    Id = "example_profile",
    Title = "Mostrar perfil",
    Icon = "user",
    Default = true,
    Tooltip = "Exibe seu avatar e nome no rodapé.",
    Keybind = {
        Default = Enum.UserInputType.MouseButton2,
        Mode = "Toggle",
    },
    Floating = {
        Text = "PERFIL",
        MobileOnly = true,
        Position = Vector2.new(0.04, 0.65),
    },
    Callback = function(enabled)
        window:SetProfileVisible(enabled)
    end,
})

section:AddSlider({
    Id = "example_scale",
    Title = "Escala",
    Icon = "sliders",
    Min = 0.75, Max = 1.5, Step = 0.05, Default = 1,
    Callback = function(value)
        window:SetScale(value)
    end,
})

section:AddColorPicker({
    Id = "example_accent",
    Title = "Cor de destaque",
    Icon = "palette",
    Default = {
        Color = "#00AA88", Opacity = 1,
        Rainbow = false, Speed = 6,
    },
    AllowRainbow = true,
    AllowOpacity = false,
    FireOnInit = true,
    Callback = function(color)
        window:SetAccent(color)
    end,
})

-- Dados simulados para mostrar a integração; substitua pela lógica do pedido.
local total = window:CreateState(0)
section:AddStatCard({Id="example_total",Title="Contagem",Icon="star",State=total,TwoWay=false})
local job = window:CreateTask({Id="demo-task",Interval=.5,Group="demo-work",Policy="Queue",Callback=function(ctx)
    ctx:ThrowIfCancelled()
    total:Update(function(value) return value+1 end)
    return total:Get()
end})
local sampling = section:AddToggle({Id="example_sampling",Title="Amostras simuladas",Default=false,
    Tooltip="Inicia/para a tarefa; paradas externas também desligam este controle."})
sampling:BindTask(job)
local status = section:AddLabel({Id="example_status",Title="Estado da tarefa",Text="Inactive"})
status:BindState(job.Status,{Property="Text",Transform=function(value) return value.Status end})
section:AddButton({Id="example_action",Title="Operação única",Feedback=true,Callback=function()
    local action,reason = window:RunAction({Group="demo-work",Policy="Queue",Callback=function(ctx)
        ctx:ThrowIfCancelled(); total:Update(function(value) return value+1 end); return total:Get()
    end})
    if not action then return false,reason end
    local completed,result = action:Await({Timeout=3,CancelAction=true})
    if not completed then return false,result end
    return true
end})
```

Salvamento e restauração:
- Defina Id da janela, ConfigFolder e IDs dos controles de forma estável e específica para o script/jogo. A aba Configurações permite criar perfis com nomes escolhidos pelo jogador, listar e carregar.
- A API oferece window:SaveConfig(name), window:LoadConfig(name, {Silent = false}), window:DeleteConfig(name), window:GetConfigNames(), window:ExportConfig() e window:ImportConfig(source, options). SaveConfig e LoadConfig retornam sucesso e um segundo valor com resultado ou erro.
- Crie todos os controles, callbacks, tarefas, bindings e migrações necessários antes de carregar um perfil. Com Silent = false, os valores persistentes carregados chamam seus callbacks, inclusive quando o valor salvo é igual ao atual. Os callbacks devem conseguir reaplicar configurações sem duplicar eventos. Observadores de State/bindings atualizam mesmo com Silent=true. BindTask é uma associação explícita: um toggle ativo carregado inicia sua tarefa após o lote, inclusive silent. O perfil não armazena execução, tokens ou status de tarefas/ações. Use observadores de flags para intervalos e opções que precisem acompanhar cargas silenciosas.
- Restaurar um keybind recupera sua atribuição, sem simular uma tecla pressionada. Não confunda carregar o estado de um toggle com executar uma ação momentânea.
- AutoSave = "nome do perfil" é opcional e só deve ser usado quando fizer sentido no meu pedido. Ele salva após mudanças, mas não carrega sozinho.
- Arquivos persistentes dependem de readfile, writefile e makefolder disponíveis e autorizadas no executor. Sem essas funções, a library usa memória durante a vida da janela. Não prometa persistência entre execuções nesse modo.
- As preferências PixelIcons, PixelDecorations, Animations, Drag, LauncherPosition, ajuda/texto/CommandKey, catálogos locais e layouts também acompanham o save; saves anteriores sem esses campos continuam aceitos. Preserve essa compatibilidade.
- DeleteConfig retorna ok/erro, atualiza a lista e exige exclusão do backend real. Configurações confirma o nome antes da exclusão. Arquivos exigem delfile; adapter próprio precisa de Delete(name) -> true ou false,reason. Sem Delete, a library mantém dados e informa indisponibilidade. Excluir o perfil de AutoSave interrompe seu debounce para não recriar o arquivo.
- Trate erros de leitura, escrita e exclusão. Não substitua a implementação de saves da library sem necessidade.

Lógica e qualidade:
- Cada controle precisa acionar a funcionalidade real solicitada. Centralize a lógica para que clique, atalho, botão mobile e restauração de save produzam o mesmo comportamento.
- Use callbacks idempotentes: ativar algo já ativo não deve criar outra conexão ou loop. Ao desativar, encerre o trabalho correspondente.
- Registre conexões, tarefas, objetos e funções de restauração com Manage/CreateScope. Use tarefas e ações do runtime quando forem adequadas, e window:OnDestroy para outras finalizações necessárias. Reexecutar o script não pode deixar a lógica anterior funcionando em duplicidade.
- Evite loops sem limite, criação repetida de conexões e buscas pesadas a cada frame. Use eventos, cache e intervalos adequados.
- Valide valores e dependências. Trate falhas de carregamento e callbacks com mensagens claras. Não declare compatibilidade com todos os executores sem evidência.
- Se uma função depender de dados específicos do jogo que eu não forneci e que você não consiga verificar, peça somente a informação indispensável. Não entregue nomes ou caminhos inventados.
- Entregue o script completo em um bloco Lua, com o bootstrap permanente da API 2, com {Channel="stable", MinVersion="2.7.0"}, aceitando releases futuras compatíveis da API 2, pronto para copiar. Não deixe TODOs, funções vazias ou exemplos no lugar das funcionalidades pedidas. Explique brevemente como executar e quais dependências reais existem.
- Seja transparente sobre a verificação: revisão de código ou testes simulados não equivalem a execução em um cliente Roblox.
- Nas próximas alterações, preserve os IDs e os perfis compatíveis sempre que possível; use ConfigVersion/migrações quando uma conversão for necessária.

Adições compatíveis da 2.1.0 — preservar a estrutura da 2.0 e os scripts consumidores:

Smart Game Metadata no Hub existente:
- CreateScriptHub aceita GameMetadata=false ou {Enabled?,Provider?,CacheTTL?,FailureTTL?,MaxConcurrent?}; padrão habilitado, CacheTTL=300 s, FailureTTL=30 s e MaxConcurrent=2 (aceita 1–4). Não crie outro painel, lista ou gerenciador de miniaturas.
- Games/AddGame/UpdateGame/CatalogUpdate podem omitir Name e Description com PlaceId/UniverseId válido. Id interno continua obrigatório. Um registro mínimo é {Id="atual",PlaceId=game.PlaceId,Scripts={{Id="principal",Title="Script principal",Callback=function(ctx) ctx:ThrowIfCancelled(); return true end}}}. Não invente IDs de jogos. O nome inicial é Game <ID>; a interface aparece antes da consulta.
- Campos manuais têm prioridade: Name não vazio, Description informada (inclusive ""), UniverseId e Image não são sobrescritos. Omita Description para preenchê-la automaticamente. Atualizar os IDs invalida campos automáticos; não renomeia o Id interno nem altera os callbacks/favoritos.
- O caminho padrão usa MarketplaceService:GetProductInfoAsync(PlaceId,Enum.InfoType.Asset), com GetProductInfo legado apenas se Async não estiver disponível. Obtém Name/Description do asset Place quando retornados. Não prometa que esses dados correspondam à experiência principal nem que retornem UniverseId arbitrário. Para o Place da sessão, game.GameId fornece a correspondência conhecida. Miniaturas continuam no sistema nativo existente.
- Provider(query,official) é um callback opcional registrado pelo desenvolvedor. Recebe cópias de {PlaceId?,UniverseId?} e dados oficiais parciais; retorna nil ou somente {Name?,Description?,UniverseId?,Image?}, por uma fonte autorizada. Metadados não podem fornecer Callback, código, URLs de scripts ou mudança de origem. Não invente endpoints, não use proxies de contorno nem credenciais embutidas. Erros do provider conservam os dados oficiais válidos.
- hub:RefreshGameMetadata(gameId) -> accepted,reason? aceita consulta assíncrona, ignorando cache ainda válido. hub:GetGameMetadataStatus(gameId) -> status?,reason? retorna cópia com State, Cached, UpdatedAt, Error, Fields e Source quando disponíveis. Estados: Idle/Queued/Loading/Ready/Partial/Unavailable/Preserved/Disabled. Refresh aceito não significa rede concluída.
- Cache por Hub de até 128 respostas; deduplicação de consultas simultâneas e refreshes; fila limitada pelo catálogo; falhas têm TTL curto. Sem polling contínuo. Respostas de registros substituídos/removidos são ignoradas e o manager solta referências ao destruir. Rede nativa já iniciada pode terminar depois; seu resultado não ressuscita a interface.
- Nome/descrição externos respeitam 128/2048 bytes com limite UTF-8. Seleção mais recente, favoritos, query, critério de ordenação, scripts e rolagens são preservados. Name continua obrigatório quando GameMetadata está desabilitado. Não reduza a validação declarativa de CatalogUpdate.

Runtime Profiler no inspetor atual:
- job:GetStatus().Profile e action:GetStatus().Profile existem; GetRuntimeSnapshot mantém Stats/Tasks/Actions/Groups/Resources/Diagnostics e acrescenta Profile às entradas. O Runtime Inspector existente mostra durações e aviso de intervalo excedido; detalhes da tarefa incluem todas as métricas.
- Profile contém Attempts, Executions, Completed, Failures, Cancelled, CancelRequests, Skipped, Samples, LastElapsed, AverageElapsed, MinElapsed, MaxElapsed, TotalElapsed, LastInstrumentedWait, TotalInstrumentedWait, LastUnattributedElapsed, LastSlow, SlowExecutions e History (até 16 registros). Durações são segundos. CancelRequests é pedido; Cancelled só cresce no desfecho efetivo. Skips não fabricam execução/duração.
- ctx:Wait(seconds) é uma API real nova (0–86400 s), mede espera e verifica cancelamento antes/depois. ctx:AwaitAction mantém a assinatura e mede o intervalo aguardado. Não substitua task.wait globalmente. Chamadas diretas a task.wait, rede e yields não instrumentados não permitem separar CPU de espera com confiabilidade. LastUnattributedElapsed não é tempo ativo/CPU exato; não apresente essa inferência como medição.
- Duração acima do Interval liga LastSlow e o aviso no inspetor, sem mudar intervalo ou permitir sobreposição. Reiniciar a mesma tarefa preserva os acumulados. O profiler não adiciona loop por frame; o histórico é limitado.

Session Snapshots opcionais:
- window:RegisterSessionState(key,state) -> window e UnregisterSessionState(key) -> window registram somente States graváveis/vivos da mesma janela ou externos sem outro dono. Computed/read-only e States de outra janela são rejeitados. Até 128 chaves de 1–64 letras/números/pontos/hífens/sublinhados.
- window:CreateSessionSnapshot() -> snapshot?,reason? captura cópias somente dos registrados. window:RestoreSessionSnapshot(snapshot) -> success,reportOrReason valida Kind="RetroBoxSession", SchemaVersion=1, APIVersion=2, WindowId e dados; aplica em Batch. O relatório tem Restored/Missing/Unknown. Chaves não registradas não criam States.
- Capture antes de Destroy, crie os novos States e registre as mesmas chaves na janela de mesmo Id, depois restaure. Um estado nil usa entrada {Value=nil}. Snapshots não são perfis nem são gravados automaticamente em arquivo. Sem armazenamento compartilhado escolhido pelo desenvolvedor não há transferência automática entre execuções isoladas.
- Apenas dados simples, finitos, acíclicos, sem metatables; até 8192 valores, 12 níveis, 1024 entradas/tabela e 256 KiB de strings. Não serialize funções, Instances, conexões, threads, scopes, tarefas ou ações. Validators devem ser puros e são conferidos antes da aplicação.
- Restaurar suprime callbacks de controles, mantém bindings/observadores de State e não executa botões ou retoma tarefas por conta própria. Efeitos colocados pelo desenvolvedor nos observadores continuam sob responsabilidade dele. Destruição remove o registro e recursos associados.

Helper de integração opcional:
- Library:CreateIntegration({Window?,Required?,CallbackExecutor?,Initialize?,OnError?}) -> controller?,reason?. Window recebe opções normais de CreateWindow; Required é array de até 16 capacidades. O controller contém Window, Scope, Capabilities e Destroyed; Manage(resource,method?,key?), Run(callback,...) -> success,... e Destroy() idempotente reutilizam o runtime.
- Capabilities indica presença de HttpGet/loadstring/readfile/writefile/setclipboard/SharedEnvironment (getgenv), não comprova permissão. CallbackExecutor fornecido é repassado sem alteração e continua (callback,args,context). Initialize(owner) pode registrar recursos; falha libera a interface. Não selecione executor automaticamente, não altere identidade/permissões e não implemente bypass.

PixelIcons e exemplo de operação cancelável:
- Na 2.0.0, Frame.Destroying chamava handle:Destroy(), que voltava a chamar Frame:Destroy(). A 2.1.0 separa liberação de referências de destruição explícita: o sinal apenas libera o handle; chamadas repetidas são idempotentes; o Frame só é destruído explicitamente quando ainda montado. Não use pcall como substituto da correção. SetIcon, padrões personalizados, temas e SetPixelIcons preservam a renderização existente.
- Exemplos oficiais novos: smart-game-metadata.lua, runtime-profiler.lua, session-snapshots.lua, integration-helper.lua e cancellable-operation.lua, na pasta examples existente. O último demonstra Buscar → Calcular → Animar → Executar → Confirmar → Limpar com iniciar/cancelar, progresso, etapa, estado, resultado, falhas e cleanup. Usa APIs implementadas, grupo Reject, ação filha/AwaitAction, scopes e uma tarefa visual de .25 s, sem lógica de jogo.
- Cada etapa verifica cancelamento; controles são restaurados no desfecho real e recursos temporários são liberados uma vez. Efeitos externos já concluídos precisam de compensação própria; cancelar não é rollback universal. Não inicie operações automaticamente ao construir a interface.
- O bootstrap permanente continua exatamente no mesmo endereço. Novos exemplos que exigem estas adições passam {Channel="stable",MinVersion="2.1.0"}; o bootstrap padrão ainda aceita >=2.0.0 e <3.0.0 na API 2. Releases Pinned antigas continuam imutáveis. Não reescreva loaders já migrados nem mude a estrutura visual do Hub.

Adições compatíveis da 2.2.0 — Mini HUD, previews e operações visíveis fora do menu:

Contrato e organização:
- São extensões opcionais, já implementadas na API 2. Preserve a sequência bootstrap -> window -> tab -> section -> controles e a estrutura visual do Script Hub. A library continua um standalone Luau para executor cliente. Não recrie o menu, perfis, sistema de atalhos ou runtime para usar os novos componentes.
- Quando o script usar estas APIs, chame o bootstrap permanente com {Channel="stable",MinVersion="2.2.0"}. O bootstrap padrão permanece compatível com >=2.0.0 e <3.0.0; não fixe Version=="2.2.0" para auto update. Os consumidores existentes já usam o caminho certo e não precisam de outra migração.
- Reutilize os mesmos States/Tasks/Actions do menu nos widgets. Hide preserva views configuradas como visíveis; Destroy da janela remove todas as views/itens, conexões, timers, clones e scopes. Não deixe um ScreenGui ou loop órfão depois de reexecutar o mesmo Id de janela.

Mini HUD e barra compacta:
- window:CreateHUD(options?) -> hud, window:GetHUD(id?="hud") -> hud? e window:CreateActionBar(options?) -> bar são APIs reais. Até 64 views por janela; Id estável com 1–116 bytes sem caracteres de controle. HUD e ActionBar têm namespaces separados.
- Opções: Id, Title, Position=Vector2.new(x,y) normalizado 0–1, Width=220–800, MaxHeight=100–800, Scale=.65–1.5, Opacity=.2–1, Orientation="Vertical"/"Horizontal", Visible, VisibleWithMenu, Collapsed e Pinned (booleanos). Padrão HUD: Id="hud", Width=270, vertical; barra: Id="actions", Width=330, horizontal com quebra. Ambos: Position=(.03,.2), MaxHeight=360, Scale=1, Opacity=.95, Visible=true, VisibleWithMenu=true, Collapsed=false, Pinned=false.
- Pinned trava arraste; não significa fixação de controle. Cabeçalho arrastável por mouse/toque; +/- recolhe, ::/L trava, X oculta. Reabra com SetVisible(true). O HUD recolhido pode mostrar título e primeiro valor. O layout reduz a escala efetiva para caber na tela e limita posição/altura, com rolagem quando necessário.
- Métodos de ambas as views: SetPosition(Vector2), SetVisible(bool), SetCollapsed(bool), SetPinned(bool), SetScale(number), SetOpacity(number), SetOrientation(string), SetTitle(text), GetLayout() -> copy, SetLayout(layout), Destroy(). Setters retornam a view; Destroy é idempotente.
- hud:AddValue(options?) -> item, hud:AddProgress(options?) -> item, hud:AddTask({Task=job,...}|{Action=action,...}) -> item e hud:AddTimer(options?) -> timer. Até 32 itens por HUD, incluindo vagas reservadas para pins do perfil. Id estável de 1–128 bytes sem caracteres de controle; não duplique IDs.
- Value aceita nil/boolean/texto até 2048 bytes/número finito. Opções comuns: Id, Title, Subtitle, Unit, Value, Visible, Icon, Format (Raw/Compact/Percent/Time ou função), Precision 0–6, State e Transform. Progress acrescenta Min/Max finitos, padrão 0/100, com clamp. AddTask observa Status da tarefa/ação desta janela, não a inicia/cancela/muda intervalo; Transform(status) retorna um valor simples; padrão mostra Status/Message.
- Item: GetValue() -> copy, SetValue(value), SetTitle(text), SetSubtitle(text), SetVisible(bool), SetIcon(spec), BindState(state,{Transform?}), Destroy(). BindState é uma via e desconecta o anterior; aceita State vivo desta janela ou externo sem outro dono. Alterações silenciosas do original também devem atualizar o HUD. Não execute callbacks de controles novamente só para atualizar um widget.
- Timer usa os.clock na sessão, Format="Time", Value inicial não negativo (padrão 0) e Start opcional false. Métodos Start(), Pause(), Reset(seconds?=0). Usa uma tarefa .25 s no scheduler existente somente enquanto iniciado. Pause conserva o acumulado; Reset não muda se está rodando. Não é relógio de parede, não recebe State e não persiste tempo automaticamente.

Fixar na tela:
- control:PinToHUD(hud?,options?) -> item suporta StatCard, Progress, ProgressChart, Label e Stepper. HUD da mesma janela; sem HUD cria/reusa Id="pinned", título Fixados. Uma fixação por controle/HUD; repetir devolve o mesmo item. Destruir a origem remove a fixação sem afetar as outras views.
- Pin options: Id (padrão "pin/"..control.Id), Title, Subtitle, Unit, Format, Precision e Icon. Campos não sobrescritos acompanham o original. Use IDs menores se o prefixo exceder 128 bytes; controles que persistem pins precisam de Id de 1–128 bytes sem caracteres de controle.
- control:UnpinFromHUD(hud?) remove de um HUD ou de todos. Pinnable=true ou Pinnable={HUD=hud,...} no construtor oferece Fixar/Soltar; control:SetPinnable(true|options|false) altera esse botão. false remove a oferta, sem desfazer pins; para isso use UnpinFromHUD. Dicas e valores à direita mantêm seu espaço.
- StatCard fixado acompanha valor/unidade/subtítulo/ícone e estado loading/unavailable. Progress acompanha barra/valor. Label acompanha texto. Stepper mostra resumo. Não duplique a State, o callback ou uma tarefa da lógica do jogo para a versão compacta.

Barra de ações:
- bar:AddAction({Id?,Control?,Callback?,Text?,Mode?}) -> floating reutiliza AddFloatingButton, sincronização, disabled/busy e Press/Toggle/Hold existentes. Até 32 ações, Id estável recomendado, Text até 64 bytes. Control deve ser Toggle, Button ou Keybind desta janela; sem Control, Callback(active,handle) é obrigatório.
- Button exige Press; Keybind preserva seu Mode. Hold libera ao terminar mouse/toque/perder foco/desabilitar ações. O handle expõe Activate(active), Release e Destroy. A barra controla posição/tamanho de entradas; não use SetPosition de cada botão para organizar o grupo. MobileOnly é false no grupo; funciona em PC e celular.
- QuickActions/SetFloatingOptions.Enabled controla barras como os atalhos existentes. HUD informativo é independente desse switch. Reaproveite o botão de iniciar/cancelar e sua operação real; não registre outra implementação para o atalho.

Previews contextuais:
- section:AddPreview(options) -> control aceita Mode="Image"/"Model"/"Custom" (inferido de Model, Render ou Image), Height=180–800 (padrão 280), opções comuns, View={Zoom?,Yaw?,Pitch?}, OnApply(snapshot,control) e OnCancel(snapshot,control). Não persiste conteúdo como flag de configuração.
- Image aceita string vazia ou rbxassetid://<id>, rbxthumb://..., rbxasset://... até 2048 bytes; State opcional alimenta imagem em uma via. Não trate qualquer URL externa como asset carregável pelo Roblox.
- Model recebe Instance Model/BasePart Archivable com bounds válidos e até 1024 descendentes. A library clona/mede antes de substituir o anterior, remove código da cópia e cria WorldModel/ViewportFrame/Camera próprios. Não move/destroi a fonte, não altera Archivable e não modifica Workspace.CurrentCamera.
- Render(container,scope,preview) cria conteúdo customizado e registra conexões/tweens/tracks/tarefas no scope; pode retornar recurso gerenciável. Cada substituição limpa o scope anterior uma vez. Em falha, o diagnóstico existente registra o erro e SetRenderer retorna false,motivo, limpando conteúdo parcial. Respeite ReducedMotion ao criar animações customizadas.
- Métodos: SetImage(asset), SetModel(instance), SetRenderer(callback) -> success,reason?, GetView() -> copy, SetView({Zoom?,Yaw?,Pitch?}), SetZoom(number), Rotate(yaw,pitch?), ResetView(), GetPreview() -> snapshot, Apply(), Cancel(), PlayAnimation(assetId,options?) -> success,trackOrReason e StopAnimation(). Setters retornam controle, exceto SetRenderer.
- Zoom .5–4; yaw/pitch em radianos; pitch ±1.35, yaw normalizado. SetView preenche omitidos com padrões; Rotate conserva pitch se omitido. Mouse/toque giram; roda e +/- dão zoom. Botão Repor usa View inicial; Apply chama OnApply; Cancel repõe View e chama OnCancel. Nada aplica mudanças ao jogo sem callback explícito. GetPreview retorna só {Mode,Image?,ModelName?,View={Zoom,Yaw,Pitch}}, sem Instances/callbacks.
- PlayAnimation aceita ID inteiro positivo ou rbxassetid://<id>, {Looped=bool?,Speed=0–8?}, padrão Speed=1. O clone precisa de Humanoid/AnimationController. Carregamento depende da engine/acesso ao asset; false,motivo deve ser tratado. Não prometa que todo ID/rig/executor funcione, não use APIs privilegiadas, bypass ou mudanças temporárias no Workspace. StopAnimation/substituição/Destroy limpam a track/Animation.
- Imagens/modelos estáticos não criam loop por frame. Pré-visualizar não executa scripts remotos nem código vindo de metadados.

Visualizador de etapas:
- section:AddStepper({Id?,Title?,Description?,Steps,Height?,Pinnable?,State?,...}) -> control. Steps é array denso de 1–32 descritores {Id,Title}; Id único com 1–64 bytes, Title até 256 bytes. Strings simples recebem IDs step-1 etc.; use IDs explícitos se for alterar por código. Height 100–1800, padrão calculado até 440 e lista com rolagem.
- GetSteps()/GetValue() retornam cópia do array {Id,Status,Message}. SetValue(array,silent?) exige tamanho/ordem/IDs corretos. Status=Pending/Running/Completed/Error/Cancelled; Message até 2048 bytes.
- SetStep(id,status,message?) altera uma etapa; SetCurrent(id,message?) conclui anteriores, marca a escolhida Running e seguintes Pending; Complete(message?) conclui todas; Reset() deixa Pending; GetSummary() retorna etapa/estado atual ou N/Total concluídas.
- BindAction(action) e UnbindAction() observam Status de uma ação da mesma janela, sem executá-la/cancelá-la/repeti-la. Rebinding desconecta anterior. BindAction interpreta ctx:SetProgress(step,total,message) como quantidade de etapas concluídas; use o mesmo total de Steps. Completed conclui tudo; Failed marca Error na atual; Cancelled marca Cancelled. O callback da operação continua responsável por cancelamento cooperativo e cleanup.
- State opcional alimenta registros em uma via. Evite State e BindAction concorrentes escrevendo na mesma visualização. Pinnable/PinToHUD oferecem resumo fora do menu. O visualizador reutiliza linhas/paleta/scopes e não cria outro scheduler.

Perfis, limites e exemplos:
- Appearance.Advanced.CompactViews guarda posição, visibilidade da view, largura/altura máxima, escala/opacidade, orientação, recolhimento/trava e associação controle→pin. GetLayout retorna cópia; SetLayout/import validam antes de aplicar. Perfis antigos continuam válidos. Layouts/pins carregados antes dos componentes aguardam IDs correspondentes; não criam controles nem executam ações.
- Valores, callbacks, modelos, timer acumulado, tarefas e ações não são serializados no layout. Visibilidade individual de widget é da sessão; visibilidade do HUD é salva. Reset volta às opções do construtor e remove pins adicionados depois. Não use snapshot/perfil como serializer de Instances, scopes ou funções.
- Exemplos oficiais novos: mini-hud.lua, compact-action-bar.lua, context-preview.lua e operation-stepper.lua na pasta examples real. O último liga iniciar/cancelar a RunAction e Stepper, com barra compacta e resumo fixado. Os anteriores mostram os mesmos States em menu/HUD, relógio pelo runtime, ações Press/Toggle/Hold e render custom com cleanup.
- Os testes headless validam lógica, ownership, bindings e distribuição. Não equivalem a renderização, animação nativa ou execução em executor Roblox real; não afirme que isso foi testado sem executá-lo.

Exemplo funcional dos componentes da 2.2.0 (opcional, além do exemplo principal preservado acima):
```lua
local Library=loadstring(game:HttpGet("https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua"))({Channel="stable",MinVersion="2.2.0"})
local window=Library:CreateWindow({Id="compact-demo",Title="Meu script",Subtitle="Sessão",Locale="pt-BR",Settings=true,ShowProfile=true,Launcher=true,DestroyOnClose=false,ToggleKey=Enum.KeyCode.RightShift})
local tab=window:CreateTab({Title="Sessão",Icon="grid"})
local section=tab:CreateSection("Dados e operação")
local money=window:CreateState(1250)
local hud=window:CreateHUD({Id="session",Title="Sessão",Position=Vector2.new(.03,.2)})
local card=section:AddStatCard({Id="money",Title="Dinheiro",State=money,TwoWay=false,Format="Compact",Unit="$",Icon="money",Pinnable={HUD=hud}})
card:PinToHUD(hud)
local stepper=section:AddStepper({Id="steps",Title="Etapas",Steps={{Id="search",Title="Buscar"},{Id="run",Title="Executar"},{Id="check",Title="Confirmar"}},Pinnable={HUD=hud}})
local action
local start=section:AddButton({Id="start",Title="Iniciar",Callback=function()
    if action and not action.Finished then return end
    action=window:RunAction({Group="demo",Policy="Reject",Callback=function(ctx)
        for i=1,3 do ctx:ThrowIfCancelled(); ctx:Wait(.3); ctx:SetProgress(i,3,"Etapa "..i) end
        money:Update(function(value) return value+10 end)
        return "Concluído"
    end})
    if action then stepper:BindAction(action) end
end})
local cancel=section:AddButton({Id="cancel",Title="Cancelar",Callback=function() if action and not action.Finished then action:Cancel("Cancelado pelo usuário") end end})
local bar=window:CreateActionBar({Id="actions",Title="Operação",Position=Vector2.new(.03,.7)})
bar:AddAction({Control=start,Text="Iniciar"}); bar:AddAction({Control=cancel,Text="Cancelar"})
section:AddButton({Title="Mostrar Mini HUD",Callback=function() hud:SetVisible(true); bar:SetVisible(true) end})
section:AddPreview({Id="preview",Title="Preview",Image="rbxassetid://0",OnApply=function(snapshot) window:Notify({Content="Zoom: "..snapshot.View.Zoom}) end})
```

Agora aguarde meu pedido com o jogo, o nome do script e as funcionalidades desejadas. Só implemente funcionalidades que eu solicitar.


Adições compatíveis da 2.3.0 — Script Hub launcher nativo para todos os desenvolvedores:

- Library:CreateScriptHub(options) e window:CreateScriptHub(options) já instalam a mesma apresentação. Não copie adaptadores, não substitua métodos privados e não desenhe outro menu no consumidor. Basta fornecer Games/Scripts, callbacks e os temas/opções públicos. O padrão das janelas tradicionais continua CreateWindow -> CreateTab -> CreateSection -> controles; o Hub é usado quando o pedido exige catálogo de jogos/scripts.
- Janela com hubs usa navegação horizontal. A biblioteca de jogos tem miniaturas, pesquisa, ordenação e filtros; o destaque mostra imagem/nome/descrição/origem, favoritos, atualização e teleporte com status. Cards de scripts mostram descrição/autor/versão/estado. A barra fixa mostra script selecionado, progresso/erro/resultado, execução em segundo plano, Executar, Cancelar e Info. Em telas pequenas, o conteúdo empilha e a barra permanece acessível.
- Theme/Locale pertencem ao desenvolvedor. Retro98 continua padrão. Use Theme="Hacker" quando eu solicitar o verde hacker, como no Mano Gustavo Hub. Todos os temas e personalizações continuam funcionando; mantenha contraste sobre as superfícies reais. Não imponha Hacker aos outros desenvolvedores.
- Campos opcionais nativos de jogo: FallbackName até 128 bytes e Notes até 2048 bytes. São aceitos em Games, AddGame, UpdateGame e CatalogUpdate. FallbackName é provisório enquanto não há Name retornado; Notes são observações acessíveis em Info. Eles não bloqueiam a consulta dos dados pelo Roblox e não substituem Name/Description.
- Para nome/descrição automáticos, omita Name e Description tanto na configuração quanto na montagem do catálogo. Em conversores, use Description=entry.Description; não transforme nil em "". Name explícito e Description explícita, inclusive "", são personalizações por campo. O Id interno não é o PlaceId; preserve as regras e limites existentes de PlaceId/UniverseId.
- hub:SetCatalogFilter("All" | "Favorites" | "Current") retorna hub; hub:GetCatalogFilter() retorna o valor atual, padrão All. O filtro usa a flag persistida hub/<HubId>/catalog-filter. As labels são traduzidas conforme Locale. Buscar, selecionar, favoritar, filtrar, carregar perfil ou catálogo não executa scripts nem teleporta.
- Todas as referências anteriores GameSearch, Sort, Favorites, GameList, GameImage, ImageStatus, GameDetails, FavoriteButton, TeleportButton, TeleportStatus, ScriptSearch, ScriptList, ScriptDetails, ExecutionStatus, PlayButton e CancelButton continuam existindo com os mesmos IDs. Use as APIs públicas; os objetos internos da apresentação não são pontos de extensão do consumidor.
- NavigationRatio .3–.55, padrão .31; StackAt 480–1000, padrão 700; ScriptListMaxRows 1–12, padrão 4; GameListMaxRows 2–16, padrão 7 e limitado ao espaço disponível. O layout considera Scale, TextScale, toque e rolagem. O limite de pool das listas continua 64.
- Execução usa RunScript/RunAction existentes: estado real, grupo exclusivo por entrada, cancelamento cooperativo e resultado somente depois do callback terminar. O botão Entrar continua separado e com confirmação por padrão. Os recursos compartilham scopes e são liberados no Destroy; não adicione polling para repintar o launcher.
- A correção adicional de lifecycle evita renderizar toggle/PixelIcon depois que o GUI foi destruído, inclusive quando um Hold ainda precisa ser liberado em sinais diferidos. A liberação lógica e dos recursos permanece. Não use pcall indiscriminado para ocultar falhas de cleanup.
- Para exigir o launcher na conta nova, chame o bootstrap permanente com {Channel="stable",MinVersion="2.3.1"}. Não fixe Version para auto update. Código do consumidor e library continuam tendo versões/distribuições próprias; o export do Mano Gustavo Hub 2.1.1 exige RetroBox 2.3.1 e não contém um adaptador visual.

Exemplo adicional do launcher nativo da 2.3.0, após carregar a Library compatível; o callback abaixo é apenas demonstração local:
```lua
local hub=Library:CreateScriptHub({
    Id="meu-launcher",Title="Meu Hub",Theme="Hacker",Locale="pt-BR",
    AutoDetectGame=true,ConfirmTeleport=true,
    Games={{
        Id="current",PlaceId=game.PlaceId,UniverseId=game.GameId,
        FallbackName="Jogo desta sessão",Notes="Demonstração local; cadastre seus próprios scripts.",
        Scripts={{Id="aviso",Title="Mostrar aviso",Description="Mostra uma notificação sem código remoto.",Icon="info",Author="Dev",Version="1.0",
            Callback=function(ctx,activeHub)
                ctx:ThrowIfCancelled(); activeHub.Window:Notify({Content="Launcher nativo pronto."}); return true
            end}},
    }},
})
hub:SetCatalogFilter("All")
hub:Show()
```


Adições compatíveis da 2.4.0 — scripts universais nativos:
- UniversalScripts é uma coleção ao lado de Games em Library:CreateScriptHub e window:CreateScriptHub. Não crie um jogo fictício para universais nem desenhe um adaptador de interface no consumidor.
- Definição mínima: {Name="Meu script", Description="O que ele faz", URL="COLE_AQUI_O_RAW_REAL"}. A URL precisa ser HTTPS e retornar código, como o link Raw copiado do Pastefy. Id é opcional e gerado a partir do nome; use um Id explícito e estável se repetir nomes ou integrar sistemas externos. Callback=function(ctx,hub,script) é alternativa à URL; nunca forneça ambos.
- Cada universal tem categoria e tag UNIVERSAL próprias. Não recebe PlaceId, UniverseId, GameId ou CurrentGameOnly=true. A categoria não garante que qualquer código seja compatível com todo jogo; ela declara que o cadastro não pertence a um jogo específico.
- GetGames contém apenas jogos. GetSelectedCategory retorna Games ou Universal. Em Universal, SelectedGameId e GetSelectedGame são nil; GetSelectedScript e SelectScript funcionam na categoria selecionada.
- APIs: GetUniversalScripts(), GetUniversalScript(id), AddUniversalScript(record), UpdateUniversalScript(id,patch), RemoveUniversalScript(id), IsUniversalScriptAvailable(id), GetUniversalScriptStatus(id), RunUniversalScript(id,options), CancelUniversalScript(id), SelectUniversalScripts(), SelectUniversalScript(id). Getters são cópias sem callbacks/definições privadas; alterações validam antes de aplicar.
- URL é baixada somente na execução explícita. Não execute ao cadastrar, pesquisar, selecionar categoria, consultar metadados ou carregar perfil. O runtime confere HttpGet/loadstring, texto não vazio e limite de 2 MiB; relata falhas e verifica cancelamento antes/depois do download e antes de iniciar o código. Não prometa interrupção à força de um HttpGet em curso nem reversão de efeitos de callbacks.
- Universais compartilham temas, ícones, perfis e limpeza, mas têm seleção e ações independentes dos jogos, mesmo com IDs iguais. O limite é 128 universais dentro do total de 4096 scripts do hub. Perfis antigos sem a flag da categoria continuam válidos.
- Em HubCatalog JSON, UniversalScripts permite apenas metadados e Actions registradas localmente. URL/Source/Callback continuam proibidos. Omitir preserva o catálogo universal local; array vazio explícito remove e solicita cancelamento. Exija RetroBox 2.4.0/API 2 para esse recurso.
- O Mano Gustavo Hub 2.2.0 usa CONFIG.UniversalScripts e mantém CONFIG.Games para jogos, tema Hacker, IDs e perfis. O usuário vai hospedar scripts no Pastefy; a RetroBox segue no GitHub. Não invente um paste publicado ou altere as sete URLs antigas sem receber as novas.
- Guia: https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/UNIVERSAL-SCRIPTS.md

Exemplo adicional de scripts universais da 2.4.0, após carregar a Library compatível. O callback é uma demonstração local; para fonte remota, substitua Callback por URL com o Raw real:

```lua
local universalHub=Library:CreateScriptHub({
    Id="universal-prompt",Title="Meu Hub universal",Theme="Hacker",Games={},
    UniversalScripts={{
        Id="aviso",Name="Aviso universal",Description="Mostra uma notificação local sem depender de um jogo.",
        Callback=function(ctx,hub,script)
            ctx:ThrowIfCancelled()
            hub.Window:Notify({Title=script.Name,Content="Universal pronto!"})
            return true
        end,
    }},
})
universalHub:SelectUniversalScripts()
```


Adições compatíveis da 2.5.1 — Designer e ferramentas para desenvolvedores:

# Ferramentas de desenvolvimento — RetroBox 2.5.1 / API 2

O [Designer HTML](https://github.com/ManoGustavo02/RetroBox/blob/main/designer/README.md) usa as mesmas APIs documentadas aqui. A sequência continua **loader → janela → aba → seção → controles**; a fonte histórica não mudou de pasta. Os recursos são aditivos à API 2. Os catálogos de jogos, IDs, perfis e bootstrap existentes permanecem compatíveis.

## Localização por janela

`Library:CreateWindow` aceita `Locale="auto"` por padrão. A detecção consulta `Players.LocalPlayer.LocaleId`, depois `LocalizationService.RobloxLocaleId/SystemLocaleId`. Isso representa idioma configurado, não nacionalidade. Português usa `pt-BR`; inglês usa `en-US`; outro idioma usa traduções registradas, quando disponíveis, ou `FallbackLocale` (padrão `en-US`). `SourceLocale` padrão é `pt-BR`. `Locale="pt-BR"` ou `"en-US"` força a preferência. Configurações oferece seleção e o perfil guarda `Appearance.Locale`.

```lua
local window = Library:CreateWindow({
    Id="idiomas", Title="Meu projeto", Locale="auto", SourceLocale="pt-BR",
    Translations={
        collected={Source="Coletados: {count}", Values={['en-US']="Collected: {count}"}},
        enabled={Source="Ativar recurso", Values={['en-US']="Enable feature"}},
    },
})
```

APIs: `Library:DetectLocale()` → código, origem; `Library:ValidateTranslations(table)` → cópia validada; `window:RegisterTranslations(table)`, `Translate(key,args)`, `GetMissingTranslations()`, `SetLocale(code)`, `GetLocale()` → idioma resolvido, política. `BindText(instance,"Text",key,args)` liga um texto exibido; `BindText(input,"PlaceholderText",key)` liga o placeholder. Use novamente BindText ao mudar argumentos. Texto digitado em TextBox, IDs, URLs e callbacks não são traduzidos.

Strings de exibição que correspondem a mensagens registradas são traduzidas automaticamente, inclusive suas formas em caixa alta. Use chaves/BindText para distinguir textos iguais com sentidos diferentes. `Translate=false` em controles visuais e `SetTextTranslation(instance,false)` desativam a tradução daquele conteúdo; é possível reativar. Dicionários validam limites e preservam parâmetros, como `{count}`. Sem tradução, há fallback legível e uma lista de chaves pendentes.

`TranslationProvider=function(request,ctx)` é opcional. Recebe `{Key,Text,SourceLocale,TargetLocale,Context}` e retorna uma string traduzida. `window:RequestTranslation(key)` agenda uma ação cancelável, apenas quando chamada explicitamente. O resultado é validado e armazenado no dicionário da sessão. Não há download/serviço/chave embutido, nem tradução de código. Para persistir traduções, forneça-as em `Translations` na próxima execução. O contexto permite cancelamento cooperativo; uma chamada HTTP em andamento depende do ambiente.

## Formulários transacionais

`section:CreateForm({Id,Title?,Description?,Fields,Values?,Validate?,OnApply?})` aceita 1–64 campos Input, Toggle, Slider, Dropdown ou ColorPicker. Campo: opções normais do controle mais `Id`, `Type`, `Required?`. IDs internos usam `formId/campoId`; `_title`, `_status`, `_apply`, `_cancel` são reservados.

`GetDraft()` lê os campos, incluindo texto ainda sem FocusLost. `GetValue()` retorna somente o último valor confirmado. `SetDraft(record)` altera o rascunho; `SetValue` é alias de SetDraft. `Validate()` retorna validade, erros e valores normalizados. `Apply()` valida e confirma; `Cancel()` restaura o último valor confirmado. `IsDirty()` informa alterações pendentes. `OnChanged(callback)` observa commits; `OnApply(values,form)` é o callback de aplicação. Callbacks individuais fornecidos nos campos não são disparados durante a edição. `Validate(values,form)` pode retornar `false, {campo="Mensagem"}` para validação cruzada.

`Fields[id]`, `ApplyButton`, `CancelButton`, `Header`, `Status` e `State` são expostos. `State` é somente leitura e representa valores confirmados. `SetVisible`, `SetDisabled`, `SetTitle`, `SetDescription`, `Manage` e `Destroy` cuidam do grupo. Perfil guarda apenas `Forms[id]` confirmado; a importação valida os formulários antes de alterar flags. Destruir a seção/janela limpa os campos e listeners.

## Componentes reutilizáveis

`Library:RegisterComponent(name,builder,{Replace=true}?)` registra uma fábrica (até 128 nomes). `section:AddComponent(name,{Id,Props})` cria uma instância com até 32 controles próprios. Por padrão, registrar um nome repetido falha; Replace substitui a fábrica para novas instâncias. `GetComponentNames()` retorna os nomes.

No builder, `ctx:Add("StatCard",{Id="coins",...})` usa o controle público real e namespace `instancia/coins`. `ctx:CreateState` e `ctx:Manage` vinculam recursos ao ciclo de vida. O retorno do builder aparece em `handle.Exports`; controles ficam em `handle.Children` e `Get(id)`. `GetValue`, `SetValue(record,silent)` e `OnChanged` agregam os controles. `State` é calculado a partir dos estados dos filhos. `SetValue` valida todas as alterações antes de aplicar. Formulários ou componentes aninhados não são suportados no builder; use grupos lado a lado.

## CardGrid

`section:AddCardGrid` recebe `Items` com até 5000 registros `{Id,Title?,Description?,Icon?,Image?,Category?,Badges?,Enabled?}`. Badges aceita até quatro strings. `Searchable`, `Height`, `CardHeight`, `MinCardWidth`, `Columns`, `Gap` e `OnActivate(item,control)` configuram o painel. `Actions={{Id,Text,Icon?,Callback=function(item,control)...end}}` adiciona até três ações explícitas por card.

Métodos: `SetItems`, `GetItems`, `SetQuery`, `SetFilter`, `GetSelectedItem`, `GetViewStats`. `SetFilter("categoria-ou-badge")` filtra por categoria ou badge; nil remove. `GetValue/SetValue` trabalham com o Id selecionado, não a lista. O pool recicla até 64 cards; `GetViewStats()` expõe a contagem. Substituir Items valida antes de alterar a vista. Temas, PixelIcons, State/flags e limpeza usam o runtime existente.

## Grafos de ligações

`window:CreateFlowGraph(definition,{Controls?,States?,Actions?})` cria um grafo. `Library:ValidateFlowGraph(definition,bindings)` valida sem criar componentes. `Library:GetDesignerCatalog()` retorna uma cópia do catálogo, incluindo tipos de portas e limites. Definição: `{Id,Nodes={...},Edges={{From,Out,To,Input},...}}`. `Controls` associa IDs a handles da mesma janela; por padrão usa `window.Controls`. Registre explicitamente handles de Form/Component nessa tabela. `States` associa nomes a States. `Actions` associa nomes a funções próprias.

Até 256 nós/512 fios, sem ciclos. Nós e portas constam no catálogo compartilhado. Value lê um Control/State. Binding escreve `Value`, `Text`, `Title`, `Description`, `Visible` ou `Disabled` conforme os métodos do alvo. Click usa Button; Change usa controle de valor; Apply usa Form. `Format.Text` e `Notify.Text/Title` aceitam chave de tradução ou fonte. Compare oferece `== ~= > >= < <=`; Math oferece `+ - * / min max`. Estados somente leitura não podem ser alvo de escrita.

`Call.Action` precisa de `Actions[nome]=function(ctx,value,flow) ... end`. Não há avaliação de código dentro do JSON. O handler roda pelo sistema de ações da janela; `ctx:ThrowIfCancelled()` dá cancelamento cooperativo. Se o grafo for destruído, próximos nós não rodam. Cada evento tem limite de 512 visitas. Binding é silencioso: inicialização, refresh e importação silenciosa de perfil não executam ações de clique. `Control:OnActivated(callback)` observa cliques aceitos sem substituir o Callback já existente do Button.

Handle: `Refresh()`, `Trigger(eventNodeId)`, `GetDefinition()`, `Destroy()`. Destruição remove inscrições e cancela a ação vinculada, preservando os controles externos. Mudança de idioma atualiza Format/Binding. Controle tipos e ciclos também são validados no runtime, além do editor.

## Diagnóstico do catálogo

`hub:DiagnoseCatalog({Fetch?,ValidateSyntax?,MaxEntries?})` inspeciona até 256 entradas por padrão (ajustável dentro do limite do catálogo). Só baixa URLs quando solicitado; nunca executa o código. Universais usam URL; scripts de jogos podem declarar `SourceURL` como metadado de diagnóstico ao lado do Callback existente. Isso não transforma SourceURL em execução automática.

`Fetch(url,ctx)` opcional retorna string ou `{Body=texto,StatusCode=200}`; sem status, não inventamos um status de rede. `ValidateSyntax=true` solicita compilação, quando loadstring existir, mas não chama o resultado. Relatórios distinguem conteúdo disponível, vazio, HTML, erro HTTP, tamanho excedido, sintaxe inválida, Callback local e ausência de fonte. `GetCatalogDiagnosis()` lê o último relatório; `OpenCatalogDiagnostics()` abre a interface de diagnóstico. JSON remoto de catálogos continua proibindo URL/SourceURL/código executável.

Veja os exemplos [localization-forms](https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/localization-forms.lua), [reusable-components](https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/reusable-components.lua), [card-grid](https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/card-grid.lua), [visual-flow](https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/visual-flow.lua) e os [projetos JSON](https://github.com/ManoGustavo02/RetroBox/tree/main/designer/examples/).


Designer HTML: baixe designer/index.html no repositório e abra localmente. O catálogo compartilhado está em designer/schema.json. Exporte Luau ou módulo que recebe Library e actions; salve JSON para reabrir. Custom Call só roda se houver um handler explícito no Luau. Nunca invente Actions, caminhos Roblox ou providers de tradução.

Exemplo funcional de localização e formulários da 2.5.1:

```lua
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.5.1'})
local window=Library:CreateWindow({Id='localization-forms',Title='Configurações',Theme='Hacker',Locale='auto',Translations={
    title={Source='Configurações',Values={['en-US']='Settings'}},
    name={Source='Nome',Values={['en-US']='Name'}},
    saved={Source='Configuração aplicada.',Values={['en-US']='Settings applied.'}},
}})
local section=window:CreateTab({Title='Principal',Icon='settings'}):CreateSection('Preferências')
local form=section:CreateForm({Id='preferences',Title='Configurações',Fields={
    {Id='name',Type='Input',Title='Nome',Default='Dev',Required=true},
    {Id='enabled',Type='Toggle',Title='Ativar recurso',Default=false},
    {Id='amount',Type='Slider',Title='Quantidade',Min=1,Max=100,Default=25},
},OnApply=function(values)
    window:Notify({Content=window:Translate('saved'),Kind='success'})
end})
-- Configure your application from committed values, never from unconfirmed drafts.
form:Manage(form:OnChanged(function(values) print('Applied',values.name,values.enabled,values.amount) end),'Disconnect')
```

Exemplo funcional de componentes reutilizáveis da 2.5.1:

```lua
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.5.1'})
Library:RegisterComponent('balance-panel',function(ctx,props)
    ctx:Add('StatCard',{Id='balance',Title=props.Title or 'Moedas',Default=props.Value or 0,Icon='coins',Format='Compact'})
    ctx:Add('Button',{Id='refresh',Title='Atualizar',Icon='refresh',Callback=function()
        ctx.Window:Notify({Content='Conecte aqui a atualização dos seus dados.'})
    end})
end)
local window=Library:CreateWindow({Id='reusable-components',Title='Componentes próprios',Theme='Hacker'})
local section=window:CreateTab('Principal'):CreateSection('Saldos independentes')
local first=section:AddComponent('balance-panel',{Id='wallet',Props={Title='Carteira',Value=1250}})
section:AddComponent('balance-panel',{Id='bank',Props={Title='Banco',Value=5000}})
first:Get('balance'):SetValue(1500,true)
```

Exemplo funcional de grade de cards da 2.5.1:

```lua
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.5.1'})
local window=Library:CreateWindow({Id='card-grid',Title='Catálogo de ferramentas',Theme='Hacker'})
local section=window:CreateTab({Title='Ferramentas',Icon='grid'}):CreateSection('Escolha uma ferramenta')
local items={}
for i=1,1000 do items[i]={Id='tool-'..i,Title='Ferramenta '..i,Description='Card de demonstração com pool reciclado.',Icon='settings',Category=i%2==0 and 'Utilitários' or 'Dados',Badges={'Demo'}} end
section:AddCardGrid({Id='tools',Items=items,Height=320,Searchable=true,OnActivate=function(item)
    window:Notify({Title=item.Title,Content='Seleção explícita: '..item.Id})
end})
```

Exemplo funcional de ligações visuais da 2.5.1:

```lua
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.5.1'})
local window=Library:CreateWindow({Id='visual-flow',Title='Ligações visuais',Theme='Hacker'})
local section=window:CreateTab('Principal'):CreateSection('Dados e eventos')
local controls={
    amount=section:AddSlider({Id='amount',Title='Quantidade',Min=0,Max=100,Default=25}),
    summary=section:AddLabel({Id='summary',Title='Quantidade: 25'}),
    run=section:AddButton({Id='run',Title='Mostrar aviso'}),
}
window:CreateFlowGraph({Id='demo',Nodes={
    {Id='value',Type='Value',Control='amount'},
    {Id='format',Type='Format',Text='Quantidade: {value}'},
    {Id='binding',Type='Binding',Control='summary',Property='Text'},
    {Id='click',Type='Click',Control='run'},
    {Id='notice',Type='Notify',Title='Demo',Text='Evento visual executado.',Kind='success'},
},Edges={
    {From='value',Out='Value',To='format',Input='Value'},
    {From='format',Out='Value',To='binding',Input='Value'},
    {From='click',Out='Then',To='notice',Input='Execute'},
}},{Controls=controls})
```



Registro histórico da correção de avaliação introduzida na 2.5.1 (mantida na 2.7.0):

# RetroBox 2.5.1 — avaliação eficiente de grafos

Inclui todos os recursos da [2.5.0](https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.5.md): Designer HTML, blocos, exportação Luau/JSON, idiomas, formulários, componentes reutilizáveis, CardGrid e diagnóstico.

Um grafo acíclico pode reutilizar a mesma saída em várias entradas. A avaliação anterior recalculava cada subexpressão por caminho: 12 duplicações fizeram 4.097 leituras do controle de origem, incluindo a inicialização. O evaluator agora usa cache local durante a avaliação de uma entrada, compartilhado pela expressão inteira. O mesmo caso faz duas leituras totais.

O cache é novo em cada leitura de entrada; não sobrevive a alterações de valores, bindings ou ações. Isso preserva o resultado após SetValue e evita valores obsoletos. Não houve mudança de API ou formato JSON. A prévia usa a mesma estratégia e compara registros independentemente da ordem das chaves.

Há regressões com 28 operações compartilhadas tanto no runtime quanto no simulador, verificando o número constante de leituras e os valores depois de uma alteração. Os pins publicados, incluindo 2.5.0, permanecem imutáveis. Naquela publicação, Stable/Preview passaram a 2.5.1; a versão atual desta entrega é 2.8.0.

O Designer exporta com MinVersion 2.5.1. Projetos JSON da família 2.5 continuam compatíveis e podem ser reabertos. Veja [VALIDATION.md](https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md), [guia do Designer](https://github.com/ManoGustavo02/RetroBox/blob/main/designer/README.md) e [relatório de publicação](https://github.com/ManoGustavo02/RetroBox/blob/main/docs/PREPARATION-REPORT.md).


# Atualização de integração — RetroBox 2.7.0 / API 2

Aplique estas orientações aos novos scripts e às próximas alterações dos scripts existentes. Elas atualizam os padrões de aparência das seções históricas sem substituir o contrato do loader, o catálogo ou a montagem dos controles.

## Compatibilidade, estrutura e dados existentes

- Continue com URL raw permanente -> HTTP/loadstring -> CreateWindow -> CreateTab -> CreateSection -> controles. CreateScriptHub é o componente nativo para um catálogo; não exija arquivo local da RetroBox nem instalação no Studio.
- Use {Channel="stable",MinVersion="2.7.0"} quando usar as APIs desta entrega; valide APIVersion==2. Não exija Version=="2.7.0", pois isso impediria receber correções futuras compatíveis. Quem optar por Pinned deve entender que não acompanha Stable automaticamente.
- Não substitua o catálogo de um Hub existente por um exemplo vazio. Preserve exatamente os IDs dos jogos e scripts, PlaceId/UniverseId, favoritos, fontes Pastefy e callbacks já cadastrados. Crie apenas os novos registros explicitamente pedidos.
- Use o launcher nativo compartilhado. As correções de clipping do filtro/ordenação, dimensões de ações e posição dos acessórios de informação/tecla/fixação já pertencem à library. Evite monkeypatch de Window/Hub/Tab, GUI paralela ou reposicionamento manual de instâncias para corrigir versões antigas.
- A library não atualiza o código de um consumidor por mágica: um Hub que precisa atualizar seu próprio catálogo/código ainda usa a distribuição nativa de Hub/HubCatalog documentada. Trocar a versão da library não autoriza substituir scripts do usuário.
- O Designer offline permanece disponível e compatível. Seu compilador exporta o modelo compatível da família 2.5; ao acrescentar APIs da 2.7 em código, ajuste o MinVersion do bootstrap e conecte callbacks reais. Não prometa que os novos campos já possuem editores no HTML.

## Identidade e movimento compartilhados

- O rodapé é gerenciado pela RetroBox: lê o LocalPlayer atual, observa Name/DisplayName/UserId e confere novamente ao reabrir. Nome/arroba não dependem do download do avatar e não devem ser traduzidos. Não crie um perfil paralelo nem um loop para atualizar nome por frame.
- Enquanto a engine não disponibilizar a identidade, use o estado nativo de carregamento. Não invente Player/@Player e não prometa obter dados que o executor/Roblox nunca entregou; uma conta real chamada Player continua válida.
- Botões, campos, abas, listas/cards, tooltips, menus, StatCards, gráficos, Hub, HUD e Stepper já possuem movimento coordenado. Valores públicos e callbacks continuam imediatos; a interpolação altera a apresentação.
- Charts/StatCards animam por padrão. O orçamento é até 96 segmentos animados por gráfico e até 48 entradas de texto por página; todos os dados continuam representados. Respeite os limites existentes de pontos, pooling e refresh rate.
- Use as configurações globais de velocidade/intensidade e ReducedMotion. Animated=false é o opt-out por controle. Arraste suavizado é padrão; não adicione outro RenderStepped/Heartbeat por componente ou por pixel.

## RGB de textos: opcional e com contraste

- Janela: opções TitleRGB/SubtitleRGB; métodos window:SetTitleRGB(options) e SetSubtitleRGB(options). São os textos do cabeçalho.
- Controles: opções RGB (atalho do título), TitleRGB e DescriptionRGB; control:SetRGB(options,part?). Partes: Title (padrão), Description, Value ou Button, quando essa parte existir. TitleRGB explícito tem prioridade sobre RGB; false remove o efeito da parte escolhida.
- Instâncias: window:SetRGB(textInstance,options?) aceita TextLabel, TextButton ou TextBox da própria janela e retorna um handle com SetOptions, SetEnabled, GetOptions e Destroy. Destroy é idempotente. Passe uma instância realmente exposta pela API; não invente propriedades de componentes.
- Opções: true, false ou {Enabled=true,Speed=.15,Phase=0,Saturation=.82,Brightness=1,Contrast=4.5}. Speed .01–4 ciclos/segundo; Phase e Saturation 0–1; Brightness .25–1; Contrast 1–7.
- Atenção à unidade: RGB de texto usa ciclos por segundo; ColorPicker.Speed mantém segundos por ciclo. São APIs diferentes.
- O contraste é ajustado sobre o fundo efetivo; remover RGB restaura a cor do tema atual. Não injete tags RichText ou altere nomes/descrições para produzir o efeito. O conteúdo e a tradução continuam separados da cor.
- Há até 128 efeitos de texto por janela. Eles usam o agendador compartilhado de até 30 Hz dos ColorPickers e param quando ficam ocultos ou quando a preferência de movimento exige apresentação estática. Não implemente outro loop de cores.
- RGB deve ser opt-in, aplicado onde contribuir com a interface. Preserve a identidade do tema e a legibilidade de dados importantes.

## Loading e skeletons em qualquer interface

- LoadingScreen=false dispensa a preparação inicial. A apresentação automática de janelas animadas é curta e não bloqueante, termina quando a montagem inicial está pronta e não espera avatar, miniatura ou todos os serviços remotos. Ela é dispensada por padrão quando o movimento está desligado/reduzido.
- window:ShowLoading({Title?,Message?,Blocking=true,Timeout=20}) retorna uma tela gerenciada com SetMessage(text), SetProgress(value), Finish(message?) e Destroy(). Timeout aceita 1–120 segundos.
- SetProgress(nil) representa progresso desconhecido; SetProgress(0..1) usa progresso real informado pelo trabalho. Finish completa e sai suavemente; chamadas repetidas e atualizações tardias não reabrem a tela. Destroy libera a apresentação sem declarar sucesso. Timeout libera a barreira sem inventar 100%.
- A tela é apresentação, não o gerenciador da tarefa. Trate resultado, erro e cancelamento da operação real; registre a limpeza no scope apropriado. Se uma ação já chamou Finish, deixe a animação de saída concluir; em erro/cancelamento, destrua a apresentação.
- section:AddSkeleton({Title,Lines=3,Height=100,Default=true}) cria um componente nativo não persistente: SetLoading(bool) ou SetValue(bool). Lines 1–8; Height 48–500.
- window:CreateSkeleton({Parent=guiObject,Lines=3,Cover=false,Position?,Size?,ZIndex?}) retorna handle com SetVisible(bool) e Destroy(). Parent deve pertencer à janela; Position/Size são UDim2.
- control:SetLoading(bool) mostra um placeholder em controles comuns, preserva o valor e bloqueia interações durante esse estado. O SetLoading próprio de StatCard continua intacto; use o comportamento nativo de cada componente.
- Há até 128 skeletons por janela. Movimento reduzido mantém o desenho estático; esconder/destruir pais, controles e janelas libera o trabalho/recursos correspondentes. Não deixe placeholders ativos após falha ou ausência definitiva de dados.

## Aparência exclusiva de cada Script Hub

- Theme="Hacker" continua sendo o tema da JANELA. HubTheme="Launcher" ou HubTheme={Theme="Launcher",Accent="#44E784",Colors={...}} define o perfil exclusivo do CATÁLOGO. Launcher é um preset de Hub, não um nome de tema aceito por CreateWindow.
- O preset Launcher combina superfícies escuras e verde; o Hub também aceita os temas gerais. A aparência local não altera o cabeçalho/configurações gerais da janela nem os outros Hubs anexados a ela.
- O botão Tema abre o editor nativo: escolha de preset, edição de cores, restauração e retorno ao Hub. Não crie outro editor por cima do componente.
- Métodos: hub:GetThemeProfile(), SetThemeProfile(profile), GetThemeNames(), SetTheme(name), SetAccent(color), ResetThemeProfile() e ShowThemeSettings(). GetThemeProfile retorna uma cópia. Colors usa os 12 papéis da library: Background, Surface, Inset, Text, Muted, Border, Highlight, Shadow, Accent, AccentText, Success e Danger.
- O perfil é um snapshot e participa do save/autosave em Appearance.Advanced.HubThemes[hubId]. Aceita importação anterior à criação do Hub e mantém as cores mesmo se o tema customizado usado como base for removido. Não edite esse campo diretamente nem transforme o perfil em fonte de código. Limite: 128 perfis por janela.
- HubTitleRGB e HubDescriptionRGB são atalhos opcionais. hub:SetRGB(options,part?) aceita Title (nome do JOGO selecionado), Description e SelectedScript. Para deixar o nome principal do HUB em RGB, use a opção TitleRGB da janela ou hub.Window:SetTitleRGB(options). Não confunda essas áreas.
- Metadados/imagens carregam com skeleton e fade, preservando dados manuais, fallback e catálogo universal. Um erro de miniatura ou metadados não impede a execução dos scripts disponíveis. Selecionar, pesquisar ou trocar tema não deve executar scripts.

Os exemplos seguintes são completos, usam apenas dados locais/simulados e demonstram a API. Nos scripts reais, substitua a operação de demonstração pela funcionalidade solicitada e verificada. Não copie IDs de demonstração sobre um catálogo existente.

Exemplo funcional de acabamento geral e RGB da 2.7.0:

```lua
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.7.0'})
local window=Library:CreateWindow({
    Id='prompt-appearance-270',Title='Minha interface',Subtitle='Acabamento compartilhado',
    Theme='Hacker',TitleRGB={Speed=.12},Settings=true,ShowProfile=true,
    Animations={Enabled=true,Speed=1,Intensity='Normal'},SmoothDragging=true,
})
local tab=window:CreateTab({Title='Dados',Icon='grid'})
local section=tab:CreateSection({Title='Apresentação',Icon='palette'})
local label=section:AddLabel({Id='rgb-label',Title='Texto de demonstração',Description='Descrição com cor independente.',
    RGB=true,DescriptionRGB={Speed=.08,Phase=.4}})
local card=section:AddStatCard({Id='rgb-stat',Title='Total de demonstração',Value=125,Unit='pts',Icon='diamond'})
card:SetRGB({Speed=.1},'Value')
local chart=section:AddBarChart({Id='animated-bars',Title='Amostras locais',Data={2,5,3,8},Min=0,Max=10})
local skeleton=section:AddSkeleton({Id='placeholder',Title='Placeholder reutilizável',Lines=3,Height=100})
section:AddToggle({Id='placeholder-visible',Title='Mostrar placeholder',Default=true,Callback=function(value)
    skeleton:SetLoading(value)
end})
section:AddToggle({Id='rgb-enabled',Title='Ativar RGB dos textos',Default=true,Callback=function(value)
    label:SetRGB(value,'Title');label:SetRGB(value,'Description')
end})
section:AddButton({Id='loading-demo',Title='Demonstrar carregamento',Icon='refresh',Callback=function()
    local loading=window:ShowLoading({Title='Demonstração',Message='Processando amostras locais…',Timeout=10})
    local action=window:RunAction({Group='demo-loading',Policy='Reject',Callback=function(ctx)
        ctx:Manage(function() if not loading.Finishing then loading:Destroy() end end)
        for step=1,3 do
            ctx:Wait(.2);ctx:ThrowIfCancelled()
            loading:SetMessage('Etapa '..step..' de 3'):SetProgress(step/3)
        end
        card:SetValue(card:GetValue()+25)
        chart:SetData({4,7,5,9})
        loading:Finish('Amostras prontas')
        return true
    end})
    if not action then loading:Destroy() end
end})
```

Exemplo funcional de perfil do Hub e RGB da 2.7.0:

```lua
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.7.0'})
local hub=Library:CreateScriptHub({
    Id='prompt-hub-270',Title='Meu Hub',Theme='Hacker',
    HubTheme={Theme='Launcher',Accent='#44E784'},
    TitleRGB={Speed=.1},HubDescriptionRGB={Speed=.07},
    Games={{Id='current',PlaceId=game.PlaceId,FallbackName='Jogo desta sessão',
        Notes='Demonstração; preserve os IDs reais ao adaptar um Hub existente.',
        Scripts={{Id='notice',Title='Aviso de demonstração',Description='Mostra uma notificação local.',Icon='info',
            Callback=function(context,activeHub)
                context:ThrowIfCancelled();activeHub.Window:Notify({Title='Demonstração',Content='Ação local concluída.'})
                return true
            end}}}},
    UniversalScripts={{Id='universal-notice',Name='Aviso universal',Description='Exemplo independente do jogo.',
        Callback=function(context,activeHub)
            context:ThrowIfCancelled();activeHub.Window:Notify({Title='Universal',Content='Ação local concluída.'})
            return true
        end}},
})
hub:SetRGB({Speed=.12},'SelectedScript')
-- O botão Tema do catálogo abre o editor. Também pode ser aberto explicitamente:
-- hub:ShowThemeSettings()
-- Para mudar só a aparência do catálogo:
-- hub:SetTheme('Paper')
-- hub:ResetThemeProfile()
local window=hub.Window
```

## Entrega e validação

- Entregue a funcionalidade pedida já conectada aos componentes nativos, com bootstrap remoto compatível. Preserve a estrutura, os perfis e os IDs existentes; não substitua um script funcional por um modelo vazio.
- Confirme que RGB e loading funcionam tanto em interfaces comuns quanto em Hubs, sem conexão/tarefa duplicada ao trocar ícone/tema, ocultar, destruir ou reexecutar. Use os métodos de limpeza; não esconda problemas de ciclo de vida com pcall indiscriminado.
- A release 2.7.0 foi publicada após 539 testes de lógica, 41 exemplos, 37 testes do consumidor, 24 Node, oito Chromium e dois Python. Esses resultados são da library, não prova de execução da lógica de qualquer jogo que você criar a partir deste prompt.
- Os exemplos deste arquivo precisam ser validados separadamente quando alterados. Informe com precisão o que foi executado, simulado ou apenas revisado. Não confunda testes do Designer ou doubles de tween com renderização no cliente Roblox.
- Publicação de referência: https://github.com/ManoGustavo02/RetroBox/pull/3
- CI da árvore publicada: https://github.com/ManoGustavo02/RetroBox/actions/runs/40440645070


# Atualização de integração — Central de Ideias / RetroBox 2.9.0

Use esta API quando eu pedir uma central de feedback, sugestões ou pedidos de scripts. É um sistema separado e opt-in, como o Script Hub: não adicione uma categoria de comunicação a todos os scripts ou Hubs automaticamente.

- Factory standalone: Library:CreateFeedbackHub(options). Para integrar em uma janela existente, window:CreateFeedbackHub(options). A navegação, os temas, os campos e a limpeza pertencem à library; não desenhe uma implementação paralela nem substitua métodos internos.
- Use o bootstrap HTTP permanente com {Channel="stable",MinVersion="2.8.0"}, mantendo API 2 e aceitando versões futuras compatíveis. Não exija arquivo local, Studio ou uma versão exata igual a 2.8.0.
- A pessoa pode escolher ScriptRequest, Suggestion, Feedback ou BugReport; os IDs permanecem estáveis e as legendas acompanham o idioma. O jogo atual é identificado automaticamente; outro jogo pode ser escolhido por ID/link oficial. Não recadastre os jogos do Mano Gustavo Hub para usar a central.
- O usuário revisa o jogo/link/PlaceId, mensagem, nome/@ e imagem disponível e clica para enviar. Abrir, editar, trocar idioma, carregar perfil ou selecionar categoria nunca pode enviar mensagem.
- Configure WebhookURL no script consumidor, não na fonte compartilhada. Não use uma URL inventada/real de outra pessoa nem publique o segredo no repositório. URL vazia abre a tela em modo não configurado, com envio desativado.
- Token entregue ao cliente é extraível. Não prometa esconder o webhook com ofuscação ou cooldown local. Quando houver um servidor próprio, use Transport para manter a credencial lá e validar/autenticar/limitar requisições no backend. O adaptador não cria nem hospeda esse servidor automaticamente.
- Só declare Sent após confirmação com um ID de mensagem válido do Discord. Rejeição, falha, timeout, 429 e entrega incerta têm estados próprios e preservam o rascunho. Não repita um POST automaticamente quando a entrega for incerta. Respeite cooldown/Retry-After; reenvio incerto depende de decisão explícita.
- O idioma da interface é automático PT/EN, com a preferência geral da janela. Não traduza a mensagem digitada, o nome do jogo ou a identidade do jogador. Não detecte nacionalidade por IP ou acrescente telemetria à mensagem.
- Avatar é opcional, usa HTTPS Roblox/CDN quando disponível e não bloqueia o texto. Dados da sessão são lidos do LocalPlayer; não invente Player/@Player e não use a identidade de outro jogador que entrou na sessão.
- GetDraft/SetDraft e os perfis são coisas diferentes: mensagem, webhook, identidade e funções de transporte ficam fora do save da janela. Não adicione salvamento oculto de rascunhos. A proteção contra duplicatas é transitória e limitada; não a apresente como autenticação ou proteção contra clientes alterados.
- Ao usar Submit, confira handle.Result.Code ou feedback:GetStatus().State; Completed na ação significa que o fluxo foi tratado, não necessariamente que o Discord aceitou a mensagem. OnSent só é chamado em confirmação válida.
- Respostas tardias não devem alterar uma GUI nova, apagar um rascunho editado ou continuar chamando eventos de uma janela destruída. Use Destroy/CancelSubmission e os scopes nativos; não tente desfazer HTTP já enviado.

Contrato detalhado da API, limites e transporte:

# Central de Ideias · Feedback Hub · RetroBox 2.8

Componente opt-in separado do Script Hub. Permite pedir scripts para jogos, sugerir melhorias, compartilhar feedback e relatar problemas. Cria uma janela própria com `Library:CreateFeedbackHub` ou uma guia em uma janela existente com `window:CreateFeedbackHub`. Janelas normais e Script Hubs não recebem uma categoria extra automaticamente.

## Começar

```lua
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.8.0'})
local feedback=Library:CreateFeedbackHub({
    Id='minha-central',Theme='Hacker',Locale='auto',
    WebhookURL='', -- coloque aqui seu webhook real; vazio mantém o envio desativado
    Categories={'ScriptRequest','Suggestion','Feedback','BugReport'},
    Game='current',IncludeAvatar=true,
})
```

[Exemplo completo](https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/examples/feedback-hub.lua). Crie o webhook na integração do canal do Discord e coloque a URL no script consumidor, não na fonte da RetroBox. Prefira um canal de texto; para um tópico existente ou destino em fórum, informe `ThreadId` com o ID do tópico.

**Um webhook no cliente pode ser extraído.** A library não pode esconder um segredo entregue ao executor. O modo direto é uma conveniência para uso controlado; distribuir um webhook público exige aceitar esse risco. Para proteger o token, use `Transport` conectado a um servidor sob seu controle, com validação/autenticação e limitação de taxa no servidor. Não há servidor de relay embutido nem implantação automática de backend.

## Tela e dados

A tela tem formulário, escolha de categoria, jogo atual ou outro jogo por ID/link, contador de caracteres, prévia do envio, avatar disponível e status. Ações principais: enviar, parar a espera, limpar e reenviar com confirmação quando a entrega é incerta. Layout em duas colunas no desktop e empilhado em telas menores; usa os componentes, temas, acessibilidade, animações e rolagem da própria library.

O jogo é consultado por PlaceId. Um link deve ser o HTTPS oficial `https://www.roblox.com/games/ID/...` ou `https://roblox.com/games/ID/...`. Links de compartilhamento sem `/games/ID` precisam ser convertidos para o link do jogo/ID. Se o nome não puder ser consultado, o ID e o link continuam disponíveis; a prévia informa a limitação.

O payload do Discord contém um embed com categoria, mensagem, nome do jogo, link, PlaceId, DisplayName e @Name. O avatar aparece como miniatura quando a API retorna HTTPS de um domínio Roblox/CDN permitido. Conteúdo `rbxthumb://` é válido para a interface Roblox, mas não é enviado como URL de imagem ao Discord. `IncludeAvatar=false` dispensa a consulta e o campo da imagem. Falha na imagem não impede enviar texto.

Identidade é lida do LocalPlayer real, com observação da chegada e de Name/DisplayName/UserId. O envio aguarda campos reais; não usa Player/@Player fictício ou a identidade de outro jogador. Dados do cliente não são autenticação: um executor alterado pode forjá-los, e um relay precisa tratar esse conteúdo como entrada não confiável.

Não há envio ao abrir a tela, mudar categoria/idioma, carregar perfil ou editar texto. A prévia resume mensagens longas e avisa que o texto completo será enviado. Quebras de linha são normalizadas e espaços externos são removidos; o restante da mensagem não é reescrito nem traduzido. O payload não inclui JobId, dispositivo, HWID, identificação do executor ou coleta extra de IP. `allowed_mentions.parse` é vazio para impedir menções em massa.

## Opções

| Opção | Padrão e contrato |
| --- | --- |
| `Id` | `feedback`; 1–64 letras/números/ponto/underscore/hífen, único na janela. |
| `WindowId` | Somente no factory da Library; padrão `RetroBox-Feedback-<Id>`, usado para reexecução. |
| `Title`, `Subtitle`, `Theme`, `Locale` | Opções normais da janela standalone. Sem títulos customizados, o cabeçalho também acompanha PT/EN. Tema padrão Hacker; locale padrão auto. |
| `WebhookURL` | URL HTTPS oficial Discord `/api/webhooks/id/token` ou `/api/vN/webhooks/id/token`; vazia/nil desativa o envio. Não aceita query/fragmento no segredo. O executor usa o endpoint v10 com `wait=true`. |
| `ThreadId` | String numérica com o ID do tópico de destino; adicionada como parâmetro separado. |
| `Categories` | Array de 1–4 IDs: ScriptRequest, Suggestion, Feedback, BugReport. O texto mostrado é traduzido. |
| `DefaultCategory` | Primeiro ID habilitado. |
| `Game` | `current`, número/ID numérico ou link oficial do jogo. Pode ser alterado pelo usuário. |
| `MinLength`, `MaxLength` | 10 e 2000; inteiros entre 1 e 2000, medidos por caracteres Unicode. |
| `Cooldown` | 30 segundos; 0–3600, intervalo local entre tentativas. |
| `DuplicateWindow` | 600 segundos; 30–3600, janela local de detecção de duplicatas. |
| `Timeout` | 20 segundos; 1–120, prazo da espera pela confirmação. Não consegue desfazer um POST já iniciado. |
| `IncludeAvatar` | true; pode ser false. |
| `ClearOnSuccess` | false; true só limpa se o rascunho inteiro continuar igual ao enviado. |
| `Request(spec)` | Adaptador HTTP opcional. Sem ele, tenta request, http_request, syn.request ou http.request, quando realmente disponíveis. |
| `Transport(payload)` | Alternativa independente de WebhookURL/Request para um relay. Não recebe a janela ou callbacks de GUI. |
| `MetadataProvider(placeId)` | Opcional; retorna `{Name='...'}`. Padrão usa MarketplaceService do cliente. |
| `AvatarProvider(userId)` | Opcional; retorna URL HTTPS Roblox/CDN. Padrão usa GetUserThumbnailAsync. |
| `CooldownKey` | Id lógico usado pelo transporte customizado; padrão Id. |
| `OnSent(preview, receipt)` | Executado somente após confirmação válida; não recebe o webhook. |

`Request` recebe `{Url,Method='POST',Headers,Body,Timeout}` e retorna `{StatusCode,Body,Headers?}`. Timeout também é uma indicação ao adaptador; alguns executores não o implementam no HTTP. O retorno deve ser uma tabela simples. Body é texto JSON. Não se tenta outro adaptador depois de um erro, pois o primeiro já pode ter enviado a mensagem.

`Transport` recebe uma cópia do payload do embed, não o segredo do Discord. Retorne o mesmo formato de resposta, por exemplo status 200 e Body com `{ "id": "ID_DA_MENSAGEM_CONFIRMADA" }` quando seu servidor confirmar a criação no Discord. Não retorne sucesso antes de a entrega real ser confirmada. O backend precisa ser construído/configurado pelo desenvolvedor.

## API

| Método/propriedade | Resultado |
| --- | --- |
| `GetDraft()` | `{Category,Message,Game}`; Game é current ou o texto/ID do outro jogo. Sem identidade nem webhook. |
| `SetDraft({Category?,Message?,Game?})` | Valida os campos antes de aplicar, preservando o restante do formulário. |
| `SetCategory(id)`, `SetMessage(text)`, `SetGame(value)` | Atalhos de edição; não enviam nada. |
| `ClearDraft()` | Limpa somente a mensagem. |
| `GetPreview()` | Snapshot público completo, ou nil/código de validação. Inclui Game e Player com nomes e avatar disponível. |
| `BuildPayload()` | Payload do Discord e preview, ou nil/código. Não faz HTTP. |
| `Validate(options?)` | bool, preview/código, dados internos adicionais; use os dois primeiros valores. |
| `Submit({RetryUnconfirmed?})` | Handle nativo de RunAction ou nil/código. Só esse método e o clique explícito iniciam o POST. |
| `CancelSubmission()` | Cancela a espera; se já iniciou o POST, a entrega pode ter ocorrido. |
| `GetStatus()` | State, Message, CanSubmit, Validation, RetryAfter, HTTPStatus e MessageId quando disponíveis. |
| `Status:Subscribe(callback)` | Estado observável da tela, liberado com o Hub. |
| `Show()`, `Hide()`, `Destroy()` | Ciclo de vida nativo; Destroy é idempotente. |
| `Window`, `Tab`, `Controls` | Janela, guia e controles existentes, para integração explícita. |

Categorias permanecem com IDs estáveis após trocar idioma. `Locale='auto'` usa o sistema existente da RetroBox, baseado no idioma configurado, não em nacionalidade/geolocalização. A interface, mensagens de erro, contador, ações, opções e prévia acompanham PT/EN. Texto enviado, nome do jogador e nome do jogo permanecem literais.

## Entrega, falhas e limpeza

Somente HTTP 200 com um ID de mensagem válido confirma `Sent`. Resposta vazia/204 inesperado, erro de rede, timeout, resposta inválida ou erro de servidor produzem `Unconfirmed`, mantendo o rascunho. Uma resposta 4xx recusada produz `Rejected`; 429 produz `RateLimited` e respeita Retry-After/retry_after em segundos. Não há reenvio automático.

O handle nativo pode terminar Completed quando o fluxo tratou uma recusa normalmente: confira `handle.Result.Code` ou `feedback:GetStatus().State`, não apenas a conclusão da ação. Apenas Code/State Sent é confirmação de entrega; OnSent segue essa regra.

Em uma entrega incerta, o botão de reenvio explica a incerteza e pede confirmação. Ele continua respeitando a pausa local e a do servidor. Programaticamente, `RetryUnconfirmed=true` é uma decisão explícita do consumidor. Alterar texto/categoria/jogo durante o envio não muda o snapshot já submetido nem apaga um novo rascunho ao concluir.

Há um ledger transitório compartilhado quando o executor permite, com até 64 destinos/usuários e 32 hashes por entrada. Ele contém somente hashes, status e tempos, e ajuda a impedir duplicação entre janelas/reexecuções. Não é proteção contra um cliente adulterado ou spam de várias pessoas; os limites do Discord continuam globais por destino, e proteção real depende do backend. Em globais somente leitura há fallback local.

Rascunho, webhook, função de transporte e identidade não são salvos nos perfis da janela. O texto só fica na memória daquela tela; fechar/reexecutar não promete recuperação do rascunho. Consultas antigas são invalidadas por geração. O worker HTTP recebe um pedido congelado e uma caixa de resposta destacável; timeout/destruição remove a ligação com a GUI. Uma resposta tardia não atualiza um formulário novo nem chama OnSent de uma janela destruída.

## Fontes e limites de verificação

- [Discord: Execute Webhook](https://docs.discord.com/developers/resources/webhook#execute-webhook)
- [Discord: limites e Retry-After](https://docs.discord.com/developers/topics/rate-limits)
- [Roblox: GetUserThumbnailAsync](https://create.roblox.com/docs/reference/engine/classes/Players#GetUserThumbnailAsync)
- [Validação da RetroBox](https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md)

Os testes de transporte usam respostas simuladas e não publicam mensagens no Discord. Este ambiente não possui renderer Roblox. Um webhook e executor reais precisam ser conferidos pelo responsável pela distribuição; nenhuma credencial real acompanha os exemplos.


Exemplo funcional da Central de Ideias da 2.8.0:

```lua
-- Central de Ideias: configure your own Discord webhook before distributing.
-- A webhook in a client script is extractable. Use Transport for a server relay.
local WEBHOOK_URL = '' -- Paste the Discord webhook URL here. Never commit a real token.

local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.8.0'})
local feedback=Library:CreateFeedbackHub({
    Id='feedback-demo',Theme='Hacker',Locale='auto',
    WebhookURL=WEBHOOK_URL,
    -- Optional: ThreadId='your Discord thread ID', for a forum/thread destination.
    Categories={'ScriptRequest','Suggestion','Feedback','BugReport'},
    DefaultCategory='ScriptRequest',Game='current',
    MinLength=10,MaxLength=2000,Cooldown=30,Timeout=20,
    IncludeAvatar=true,ClearOnSuccess=false,
})
-- Opening this screen never sends a message. Sending requires a user's click.
-- Empty URL: screen opens in unconfigured mode; the Submit button is disabled.
-- Existing window: window:CreateFeedbackHub({...}) attaches this same component.
```

Este arquivo mantém os dez exemplos completos anteriores e acrescenta a Central de Ideias. Os exemplos são de interface/API; não são funcionalidades verificadas de um jogo específico. Configure apenas seu destino real e conecte a lógica solicitada, preservando o modelo HTTP da RetroBox.

---

# Adição 2.9.0 — Novidades e diagnóstico revisado

Esta adição integra o contrato acima e preserva a sequência HTTP/bootstrap → Library → Window → Tab → Section → controles. Não substitua a library por uma implementação local, não recrie o launcher e não remova jogos, IDs, ações, temas, perfis ou traduções já cadastrados.

## Novidades disponíveis em todas as janelas

A RetroBox cria sua categoria interna Novidades automaticamente, sem tomar a seleção inicial de abas do consumidor. Existem duas origens independentes:

- Library / RetroBox: notas oficiais da versão carregada, com histórico da API 2. Somente APIs de leitura por cópia; não aceite substituir notas oficiais por opções, feeds ou perfis do script. Não há setter público dessa origem.
- Script / Este script: conteúdo opcional do desenvolvedor em ScriptUpdates ou window:SetScriptUpdates(array). Vazio por padrão. Cada janela mantém seu próprio conteúdo; isso não altera outras janelas nem o histórico da RetroBox.

ScriptUpdates: array denso com até 100 registros. Cada registro tem Id único (1–64 letras/números/ponto/underscore/hífen), Title (até 160 caracteres) e Description (até 2400). Title/Description podem ser string literal ou tabela com pt-BR e en-US. Version é string opcional de até 48 bytes; Date opcional usa YYYY-MM-DD. Não inclua callbacks, código, comandos, downloads ou campos desconhecidos nos registros. Ordene do mais recente para o mais antigo e mantenha IDs estáveis.

Use window:OpenUpdates('Library'|'Script'), window:GetLibraryUpdates(), window:GetScriptUpdates(), window:SetScriptUpdates(array), window:GetUnreadUpdateCount(source), window:MarkUpdateRead(source,id). Library:GetReleaseNotes() retorna uma cópia do histórico oficial. window.NewsTab é a aba interna.

Marcação de leitura depende do hash dos campos estáveis, não do idioma. Conteúdo editado com o mesmo Id volta a ser não lido. Só hashes em Appearance.Advanced.NewsRead são guardados no perfil; notas e conteúdo dos updates não são importados do perfil.

Não prometa notícias em tempo real: o histórico oficial acompanha a versão da RetroBox que está rodando. Bootstrap stable recebe a nova versão na próxima execução. Pinned permanece na versão escolhida.

## Relatos com diagnóstico opcional

CreateFeedbackHub aceita Diagnostics (bool, padrão true) e ScriptVersion opcional (string até 64 bytes). Diagnostics=false remove a seção. Na UI, o anexo e a captura começam desligados. Nenhuma construção, edição, troca de idioma ou importação de perfil consulta/seleciona/anexa/envia logs automaticamente.

O jogador pode colar até 2000 caracteres de erro/stack trace, informar Code/tag de até 64 caracteres e Steps de até 400, carregar explicitamente erros/avisos disponíveis e marcar até 5 registros. Há prévia selecionável do diagnóstico preparado e botão de cópia. A categoria BugReport recebe [BUG]; outras categorias com anexo recebem [DIAGNOSTIC]. O código/tag aparece no embed.

Carregar registros consulta diagnósticos das janelas desta instância da library e LogService:GetLogHistory quando permitido. A captura opt-in usa MessageOut e só aceita novos erros/avisos enquanto a tela está visível. O buffer é limitado a 80 registros; importação considera até 160 mensagens recentes e até 16 janelas. Mensagens longas são resumidas na captura e isso é informado na prévia. Nenhum registro é marcado automaticamente. Permissão negada mantém a colagem manual. Não prometa acesso a logs do servidor ou ao console privado de um executor; não intercepte print, warn ou error.

O preparo remove padrões reconhecidos de credenciais (destino, webhooks, Bearer, tokens, cookies e campos de segredo). Não prometa identificar todo dado sensível. A cópia contém somente a prévia preparada; ausência de clipboard oferece seleção manual. Não leia clipboard automaticamente.

O embed inteiro é validado antes de chamar o transporte, inclusive limites de fields e soma de 6000 unidades, usando UTF-16 de forma conservadora para emoji. Texto do diagnóstico é dividido em fields de até 900 unidades sem quebrar Unicode. Conteúdo que exceda o limite exige redução explícita; não trunque silenciosamente um relatório no envio e não crie serviço de upload externo.

API:
- hub:GetDraft().Diagnostics = {Include,Text,Code,Steps,Selected}; Selected são IDs locais obtidos em GetDiagnosticRecords.
- hub:SetDraft({Diagnostics={...}}) valida antes de alterar o restante do rascunho.
- hub:SetDiagnosticText(text,include?) preenche sem enviar.
- hub:CollectDiagnostics() importa somente quando chamado.
- hub:GetDiagnosticRecords() retorna cópias saneadas.
- hub:SetDiagnosticCapture(true|false) controla captura explícita.
- hub:ClearDiagnostics() limpa campos/seleção e desativa o anexo sem apagar a mensagem principal.
- GetPreview().Diagnostics existe somente quando o anexo foi incluído e é válido.

Preserve cooldown, limitação 429, confirmação real, estados de entrega incerta, cancelamento e limpeza da Central já documentados. A detecção de duplicatas inclui o diagnóstico e independe de idioma. Falhas mantêm o rascunho; sucesso só pode limpar um rascunho ainda idêntico ao enviado. Diagnósticos, seleção, identidade e credenciais não entram nos perfis.

## Exemplo completo — API 2.9, sem envio automático

```lua
-- RetroBox API 2: library-wide updates, optional script feed and reviewed diagnostic reports.
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({
    Channel='stable',MinVersion='2.9.0',
})
assert(type(Library)=='table' and Library.APIVersion==2,'RetroBox API 2 required')
local window=Library:CreateWindow({
    Id='updates-diagnostics-demo',Title='Meu script',Theme='Hacker',Locale='auto',
    ScriptUpdates={{
        Id='script-1.0.0',Version='1.0.0',Date='2026-10-27',
        Title={['pt-BR']='Primeira versão',['en-US']='First release'},
        Description={['pt-BR']='Interface, novidades e relatos de problema.',['en-US']='Interface, updates and bug reports.'},
    }},
})
local main=window:CreateTab({Title='Principal'})
local section=main:CreateSection({Title='Ajuda e novidades',Icon='info'})
section:AddButton({Id='show-script-updates',Title='Novidades deste script',Callback=function() window:OpenUpdates('Script') end})
section:AddButton({Id='show-library-updates',Title='Novidades da RetroBox',Callback=function() window:OpenUpdates('Library') end})
local feedback=window:CreateFeedbackHub({
    Id='feedback',WebhookURL='', -- configure in the consumer; empty keeps submission disabled.
    Categories={'ScriptRequest','Suggestion','Feedback','BugReport'},
    Diagnostics=true,ScriptVersion='1.0.0',Game='current',
})
-- Opening or editing does not post, import console history or enable capture.
-- The user chooses whether to attach diagnostics and reviews them before sending.
main:Select()
return window,feedback
```

Esse exemplo deixa WebhookURL vazio intencionalmente. Ao adaptar para um consumidor, use o destino configurado por ele; nunca copie credenciais privadas para a library, exemplos ou repositórios públicos. O código para webhook no cliente continua extraível; Transport permite um relay próprio quando necessário.

Referências oficiais do projeto: [Novidades](https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/NEWS.md), [Central de Ideias](https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/FEEDBACK-HUB.md) e [release 2.9](https://github.com/ManoGustavo02/RetroBox/blob/main/RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.9.md).
