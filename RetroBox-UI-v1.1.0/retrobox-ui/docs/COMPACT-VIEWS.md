# Mini HUD, fixação e barra compacta · 2.2.0

Carregue o bootstrap permanente com `{Channel="stable",MinVersion="2.2.0"}`. São adições opcionais da API 2. Os componentes ficam sob o Root da mesma janela; `Hide()` preserva as views visíveis, `Destroy()` libera todas elas. Não se cria outro ScreenGui, runtime ou coleção de flags para cada widget.

```lua
local hud=window:CreateHUD({Id="session",Title="Sessão",Position=Vector2.new(.03,.2)})
local money=window:CreateState(1250)
hud:AddValue({Id="money",Title="Dinheiro",State=money,Format="Compact",Unit="$",Icon="money"})
hud:AddProgress({Id="progress",Title="Progresso",Value=35,Format="Percent"})
local timer=hud:AddTimer({Id="time",Title="Tempo"})
timer:Start() -- .25 s no scheduler existente; Pause e Destroy interrompem a tarefa.
```

## HUD e barra

`window:CreateHUD(options?) -> hud`, `window:GetHUD(id?="hud") -> hud?` e `window:CreateActionBar(options?) -> bar`.

Até 64 views por janela. Id explícito de 1–116 bytes, sem caracteres de controle; os namespaces HUD/ActionBar são separados. O Id define a identidade do layout nos perfis. Evite o prefixo interno `__retrobox/` em IDs do desenvolvedor.

| Opção | Contrato / padrão |
| --- | --- |
| Id, Title | `hud` / Mini HUD; `actions` / Ações |
| Position | Vector2 normalizado 0–1, padrão (.03,.2); posição do canto superior esquerdo |
| Width | 220–800; HUD 270, barra 330 |
| MaxHeight | 100–800, padrão 360; conteúdo excedente usa rolagem |
| Scale | .65–1.5, padrão 1; o layout reduz a escala efetiva para caber na tela |
| Opacity | .2–1, padrão .95; texto permanece legível |
| Orientation | Vertical ou Horizontal; HUD vertical, barra horizontal com quebra de linha |
| Visible, VisibleWithMenu | boolean, ambos true; false em VisibleWithMenu mostra com menu oculto/minimizado |
| Collapsed, Pinned | boolean, ambos false; Pinned trava o arraste |

Métodos de ambos: `SetPosition(Vector2)`, `SetVisible(bool)`, `SetCollapsed(bool)`, `SetPinned(bool)`, `SetScale(number)`, `SetOpacity(number)`, `SetOrientation(string)`, `SetTitle(text)`, `GetLayout()`, `SetLayout(layout)` e `Destroy()`. GetLayout retorna cópia; SetLayout valida antes de aplicar. Setters retornam a view. Destroy é idempotente.

A barra do título oferece arraste por mouse/toque, +/- para recolher, ::/L para travar e X para ocultar. Reabra por `SetVisible(true)`, por exemplo com um botão do menu. Pinned não controla visibilidade nem as fixações dos controles. O HUD recolhido mostra título e primeiro valor. Botões e rolagem usam GUI nativa; há suporte a toque e foco de teclado existente.

## Widgets do HUD

- `hud:AddValue(options?) -> item`: valor textual/booleano/finito/nil. Até 2048 bytes de texto.
- `hud:AddProgress(options?) -> item`: valor finito limitado a Min/Max, padrão 0/100.
- `hud:AddTask({Task=job,...})` ou `{Action=action,...} -> item`: observa Status da tarefa/ação desta janela; não inicia, cancela ou muda intervalo. Padrão exibe Status e Message. `Transform(status)` personaliza o valor.
- `hud:AddTimer(options?) -> timer`: Value não negativo em segundos (0), Start opcional false. Start/Pause/Reset(seconds?=0). Sem relógio de parede/persistência de tempo; mede os.clock durante a sessão. Pause conserva o acumulado; Reset não muda se está rodando.

Até 32 widgets por HUD, contando vagas reservadas para fixações carregadas do perfil. Use Id estável de 1–128 bytes, sem caracteres de controle. Opções comuns: Id, Title, Subtitle, Unit, Value, Visible, Icon, Format, Precision, State e Transform. Format: Raw/Compact/Percent/Time ou função; Precision 0–6. Progress acrescenta Min/Max. Timer usa Time e não recebe State. State deve ser vivo, desta janela ou externo sem outro dono; é observado em uma via. Campos de status complexos devem virar um valor simples via Transform.

Métodos dos itens: GetValue (cópia), SetValue, SetTitle, SetSubtitle, SetVisible, SetIcon, BindState(state,{Transform?}) e Destroy. O timer acrescenta Start/Pause/Reset. Trocar BindState desconecta o anterior. Os dados não são duplicados em flags de controles e não disparam callbacks de controles. Apenas timers iniciados usam o scheduler; dados estáticos e States não acrescentam loop por frame.

## Fixar na tela

```lua
local card=section:AddStatCard({Id="money-card",Title="Dinheiro",State=money,
    TwoWay=false,Format="Compact",Unit="$",Pinnable={HUD=hud}})
local pin=card:PinToHUD(hud) -- opcional: já fixar na construção
-- card:UnpinFromHUD(hud); card:UnpinFromHUD() remove de todos os HUDs.
```

`control:PinToHUD(hud?,options?) -> item` suporta StatCard, Progress, ProgressChart, Label e Stepper. O HUD deve ser desta janela. Sem HUD, cria/reusa Id `pinned`, título Fixados. Uma fixação por controle/HUD; repetir retorna o mesmo item. Destruir o controle remove suas fixações. Não se executam novamente callbacks nem se cria outra tarefa de gameplay.

Opções do pin incluem Id (padrão `pin/<control.Id>`), Title, Subtitle, Unit, Format, Precision e Icon. Campos não sobrescritos acompanham título, subtítulo/unidade, valor e ícone do original. StatCard também mostra loading/unavailable; Stepper mostra resumo da etapa. Use um Id menor se o prefixo ultrapassar 128 bytes. O Id do controle a persistir também precisa caber em 1–128 bytes sem caracteres de controle.

`Pinnable=true` ou `Pinnable={HUD=hud,...}` no construtor oferece o botão Fixar/Soltar. `control:SetPinnable(true|options|false)` altera a disponibilidade desse botão. false remove o botão sem desfazer fixações existentes; use UnpinFromHUD para removê-las. Tooltips e valores à direita preservam seus espaços.

## Barra compacta de ações

```lua
local bar=window:CreateActionBar({Id="quick",Title="Atalhos",Width=330})
bar:AddAction({Id="collect",Control=collectToggle,Text="Ativar"})
bar:AddAction({Id="run",Control=runButton,Text="Executar"})
bar:AddAction({Id="hold",Control=holdKeybind,Text="Segurar"})
```

`bar:AddAction(options) -> floating` reutiliza `AddFloatingButton`, a sincronização e as regras de Press/Toggle/Hold. Até 32 entradas. Control aceita Toggle, Button ou Keybind desta janela; alternativamente use Callback(active,handle) e Mode. Text até 64 bytes. Id estável recomendado. Button exige Press; Keybind mantém seu Mode; Hold libera ao terminar o toque/clique, perder foco ou desativar ações. Disabled/busy do original são respeitados. Não cria callbacks independentes da operação original.

O handle mantém Activate(active), Release e Destroy. A barra controla posição/tamanho/visibilidade de suas entradas; não use SetPosition individual para organizar a barra. A opção global QuickActions/SetFloatingOptions.Enabled também controla barras. HUDs informativos são independentes desse switch. MobileOnly é false nas ações encaixadas, com PC e celular habilitados.

## Perfis e limpeza

A aparência usa `Appearance.Advanced.CompactViews`, sem mudar Schema/ConfigVersion. ExportConfig/ImportConfig/SaveConfig/LoadConfig conservam posição, visibilidade da view, escala, opacidade, largura, altura máxima, orientação, recolhimento/trava e associação controle→pin. Valores observados, callbacks, modelos, timers e tarefas não entram no layout. A visibilidade individual de um widget é uma preferência da sessão; a visibilidade do HUD é persistida.

Layouts e fixações também podem ser carregados antes da criação dos HUDs/controles; os IDs estáveis resolvem as associações depois. Não criam controles nem executam ações. O perfil é validado antes de alterar tema/flags; conflitos/capacidade inválida rejeitam a importação. Reset retorna as preferências do construtor e remove as fixações adicionadas depois. Cada view/item solta conexões, ícones e scopes em Destroy, incluindo destruição externa do parent e sinais imediatos/diferidos.

Exemplos: [mini-hud.lua](../examples/mini-hud.lua), [compact-action-bar.lua](../examples/compact-action-bar.lua), [operation-stepper.lua](../examples/operation-stepper.lua).
