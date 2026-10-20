# RetroBox UI 2.2.0 — componentes compactos e previews

## Resultado

A API 2 agora oferece Mini HUD, fixação de controles, barra compacta de ações, previews e visualizador de etapas. A estrutura Window → Tab → Section → controles e o Script Hub nativo foram preservados. O bootstrap permanente continua em https://raw.githubusercontent.com/ManoGustavo0/RetroBox/main/dist/bootstrap/v2.lua . Stable/Preview da API 2 passam a resolver 2.2.0; consumidores que usam esse endereço recebem a library nova na próxima execução, sem reescrita de seus scripts. Uma janela já aberta não recebe hot swap.

## Componentes adicionados

| Recurso | Integração |
| --- | --- |
| CreateHUD / AddValue / AddProgress / AddTimer / AddTask | Valores e status do mesmo State/Task/Action fora do menu; timers pelo scheduler existente |
| PinToHUD / UnpinFromHUD / Pinnable / SetPinnable | Segunda visualização de StatCard, Progress, ProgressChart, Label e Stepper; alterações silenciosas também chegam ao HUD |
| CreateActionBar / AddAction | Agrupa FloatingButtons existentes e conserva Press/Toggle/Hold, disabled/busy e liberação de segurar |
| AddPreview | Imagem, cópia de Model/BasePart em WorldModel/ViewportFrame, câmera própria, zoom/órbita, renderer com scope e animação de rig opcional |
| AddStepper / BindAction | Mostra Pending/Running/Completed/Error/Cancelled, com resumo fixável e acompanhamento da RunAction real |

HUDs/barras têm arraste por mouse/toque, trava, recolhimento, visibilidade com/sem menu, escala/opacidade, orientação, rolagem e posição limitada à tela. A aparência e as fixações usam os perfis existentes, inclusive quando HUD/controle só é criado depois do load. Não serializam valores de operação, callbacks ou recursos.

Documentação: [COMPACT-VIEWS.md](COMPACT-VIEWS.md), [PREVIEWS.md](PREVIEWS.md), [STEPPER.md](STEPPER.md). Os quatro exemplos são mini-hud.lua, compact-action-bar.lua, context-preview.lua e operation-stepper.lua.

## Ciclo de vida e compatibilidade

Views e itens soltam assinaturas/scopes/ícones sem voltar a destruir o root recebido pelo sinal Destroying. A barra usa a limpeza de FloatingButton, agora também separada em liberação e destruição explícita; remove registros de tema/foco/texto e referências de componentes. O caminho compartilhado de Control ignora a destruição explícita do próprio Frame durante o sinal de destruição, incluindo sinal diferido com Parent já nil. A correção PixelIcon da 2.1 continua intacta.

Fixar não cria outro callback de lógica de jogo. Valores de menu/HUD usam o mesmo Estado. Destruir o controle remove seus pins; destruir a janela remove views, timers, modelos, tracks, renderers e conexões. Alterar/repor temas, ícones e preferências continua usando a paleta e o gerenciador existentes. Não há loop por frame para valores estáticos/previews estáticos.

## Verificações executadas

- **368/368 testes headless** com Lua 5.4: as 336 regressões anteriores e **32 novas** em compact-views.lua e previews-stepper.lua.
- Compartilhamento de States, false/nil e formatação custom, valores silenciosos, fixação/desfixação, IDs gerados após remoção, help badges, carregamento tardio de pins, validação atômica/capacidade, Reset, arraste/toque/trava, limites de tela e ausência de frame loop ocioso.
- Timer iniciar/pausar/repor/destruir, observar tarefa sem iniciá-la, barra Press/Toggle/Hold, perda de foco e destruição do controle. Cleanup com sinais imediatos e diferidos, destruição externa do parent, reexecução, todos os temas e alternância de PixelIcons sem Parent bloqueado no double estrito.
- Preview: zoom/rotação, Apply/Cancel explícitos, callbacks enfileirados descartados na destruição, renderer substituído 10 vezes, modelo clonado/sanitizado sem mutar fonte, câmera/bounds, animação opcional e falha de acesso, binding de imagem e descrição sem sobreposição.
- Stepper: transições, validação, pin/resumo, ação real com sucesso/falha/cancelamento, rebind e State; mesmas linhas nos temas.
- **33 exemplos oficiais** carregados pela API pública e limpos ao baseline de conexões.
- **2/2 testes de pipeline** Python (promoção de Stable/Preview, imutabilidade e rollback) e **11 manifests** com bytes/SHA-256/versões/aliases verificados. Pins publicados 2.0.0/2.1.0 e três cópias do bootstrap permaneceram byte a byte iguais.
- Seis fontes de consumidores relidas do GitHub, iguais às cópias usadas no smoke: Mano Gustavo Hub, muchyohub, GuerraNavalRetro, Dandy-s-World, ComandanteTycoon e 8BallDuelsRetro. Os seis loaders aceitam 2.2.0 sem funções de arquivo do executor. O Hub completo mantém seus sete jogos; seleção não executou scripts externos.
- Prompt completo preservado/ampliado de 64633 para **78842 bytes**. Contrato HTTP/API 2 validado; ambos os exemplos executados. O secundário concluiu a ação, atualizou o StatCard/HUD e o Stepper e liberou todas as views.

Essas verificações exercitam lógica, dados e ownership com um double de engine, sem renderer Roblox. Renderização nativa, câmera/gestos em dispositivos reais, carregamento de imagens/animações e permissões de um executor específico ainda exigem validação no cliente. PlayAnimation retorna false,motivo quando a engine nega o asset; não usa APIs privilegiadas nem bypass.

Reprodução local a partir da pasta histórica do projeto:

```sh
python3 tests/run_headless.py
python3 tests/test_release_pipeline.py
python3 tools/verify_distribution.py
```

## Distribuição

Artefato 2.2.0: **571572 bytes**; SHA-256 `394795a7f5fc0a30b0054f85ed971fa8b7f82cc0b764350c09b051dc67914813`.

## Arquivos modificados ou acrescentados

- `RetroBox-UI-v1.1.0/retrobox-ui/CHANGELOG.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/README.en.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/README.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/RetroBox.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/API.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/COMPACT-VIEWS.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/PREVIEWS.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.2.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/STEPPER.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/examples/compact-action-bar.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/examples/context-preview.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/examples/mini-hud.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/examples/operation-stepper.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/src/CompactViews.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/src/Preview.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/src/Stepper.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/compact-views.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/headless.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/mock_roblox.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/previews-stepper.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tools/build_distribution.py`
- `dist/channels/preview/v2.json`
- `dist/channels/stable/v2.json`
- `dist/history.json`
- `dist/preview/v2/RetroBox.lua`
- `dist/releases/2.2.0/RetroBox.lua`
- `dist/releases/2.2.0/manifest.json`
- `dist/stable/v2/RetroBox.lua`
