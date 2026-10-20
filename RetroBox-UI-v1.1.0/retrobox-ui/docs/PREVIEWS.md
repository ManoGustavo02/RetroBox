# Preview contextual · 2.2.0

`section:AddPreview(options) -> control` acrescenta imagem, objeto 3D ou conteúdo personalizado. Carregue a API 2 com MinVersion="2.2.0". A visualização é local; só os callbacks explícitos do desenvolvedor aplicam mudanças ao jogo.

```lua
local preview=section:AddPreview({Id="preview",Title="Objeto",Model=myModel,
    Description="Arraste para girar; + e - ajustam o zoom.",
    OnApply=function(snapshot,control) print(snapshot.Mode,snapshot.View.Zoom) end,
    OnCancel=function(snapshot,control) print("Preview reposto") end})
```

Mode é Image/Model/Custom, inferido de Model, Render ou Image (nesta ordem). Height 180–800, padrão 280; opções comuns de controle, Description/Tooltip/Icon são preservadas. Persist=false. View={Zoom?,Yaw?,Pitch?} define o estado inicial. Zoom .5–4, yaw/pitch em radianos, pitch limitado a ±1.35; yaw é normalizado a uma volta.

| Conteúdo | Opções e comportamento |
| --- | --- |
| Image | Image string até 2048 bytes: `rbxassetid://<id>`, `rbxthumb://...`, `rbxasset://...` ou vazia; State opcional observa uma string de imagem |
| Model | Model Instance de Model ou BasePart, Archivable, com bounds não vazios; até 1024 descendentes |
| Custom | Render(container,scope,preview) cria conteúdo e registra recursos temporários; pode retornar um recurso gerenciável |

Métodos: `SetImage(asset)`, `SetModel(instance)`, `SetRenderer(callback) -> success,reason?`, `GetView() -> copy`, `SetView({Zoom?,Yaw?,Pitch?})`, `SetZoom(number)`, `Rotate(yaw,pitch?)`, `ResetView()`, `GetPreview() -> snapshot`, `Apply()`, `Cancel()`, `PlayAnimation(assetId,options?) -> success,trackOrReason`, `StopAnimation()` e os métodos comuns de Control. Setters retornam o controle, exceto SetRenderer. SetView preenche campos ausentes com os padrões; Rotate conserva pitch quando omitido. GetPreview retorna `{Mode,Image?,ModelName?,View={Zoom,Yaw,Pitch}}`, sem Instances/callbacks.

Mouse/toque arrastam rotação, roda do mouse e botões +/- ajustam zoom. A barra também oferece Repor, Aplicar (quando OnApply existe) e Voltar. Apply chama OnApply(snapshot,control); Cancel restaura a View inicial e chama OnCancel(snapshot,control). Nenhum dos dois modifica remotes/modelos do jogo por conta própria. Callbacks enfileirados não sobrevivem à destruição do controle. Para conteúdo customizado, o desenvolvedor implementa o comportamento específico de visualização.

## Cópias, câmera e animação

SetModel clona a fonte e mede os bounds antes de substituir a visualização anterior. Nunca move/destroi a fonte nem altera Archivable para forçar uma cópia. Remove Script/LocalScript/ModuleScript da cópia, que fica em WorldModel dentro de um ViewportFrame com sua própria Camera. Enquadramento considera bounds/aspecto, zoom e órbita. Não usa nem modifica Workspace.CurrentCamera. Trocar conteúdo/destruir libera o clone, câmera, world e animação.

`PlayAnimation(123,{Looped=true,Speed=1})` aceita número inteiro positivo ou `rbxassetid://<id>`. Speed 0–8. O clone precisa de Humanoid ou AnimationController; o Animator é criado nele se necessário. A engine e o acesso à animação determinam o resultado. Falha retorna false,motivo; não promete que qualquer ID/rig/ambiente permita carregar uma animação. Só uma track do helper por preview; StopAnimation libera a track e Animation. Uma nova track só substitui a anterior depois de carregar. Não chama StepAnimations ou APIs privilegiadas, não move temporariamente o modelo ao Workspace e não tenta contornar permissões.

Animações rodam apenas por chamada explícita. Imagens/modelos estáticos usam atualização por evento/gesto, sem loop por frame. Para Render custom, registre tween/track/conexões/tarefas no scope. O exemplo respeita ReducedMotion na construção da animação. Troca de Render/SetImage/SetModel destrói o scope anterior uma vez. Erros do callback passam pelo diagnóstico existente; SetRenderer retorna false,motivo e limpa o conteúdo parcial. Valide acesso e aparência em executor real.

```lua
preview:SetRenderer(function(container,scope,owner)
    local sample=Instance.new("Frame")
    sample.Size=UDim2.fromOffset(64,64)
    sample.Parent=container
    -- scope:Add(connection,"Disconnect") / scope:Add(tween,"Cancel")
end)
```

Referências oficiais: [ViewportFrame](https://create.roblox.com/docs/reference/engine/classes/ViewportFrame), [configuração de viewport](https://create.roblox.com/docs/ui/viewport-frames), [Animator](https://create.roblox.com/docs/reference/engine/classes/Animator). Exemplo completo: [context-preview.lua](../examples/context-preview.lua). Os testes de dados/ownership não comprovam renderização ou carregamento real de animações.
