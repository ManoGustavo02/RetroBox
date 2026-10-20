# RetroBox UI 2.1.0 — relatório da atualização

## Implementação

A 2.1.0 acrescenta Smart Game Metadata, profiler por tarefa/ação no Runtime Inspector existente, snapshots opcionais de sessão, helper de integração e cinco exemplos oficiais. Corrige o lifecycle dos PixelIcons. A API major continua 2. O bootstrap permanente e a estrutura visual do Script Hub 2.0 permanecem; nenhum script consumidor foi migrado ou reescrito.

## Causa confirmada do erro PixelIcon

Na fonte 2.0.0, linhas 1587–1593, handle:Destroy() terminava em self.Frame:Destroy(), e Frame.Destroying chamava handle:Destroy(). Quando o pai destruía a árvore, o handle ainda podia não estar marcado como destruído. Seu callback tentava destruir novamente o próprio Frame em destruição, ou já destruído no caso de sinal adiado, alcançando uma Instance com Parent bloqueado. Não havia atribuição direta a Parent nessas linhas: a segunda chamada a Instance:Destroy() é que repetia esse caminho interno. A limpeza de controles/janelas expunha o problema; alteração de tema isolada não era sua causa.

Um double de engine mais estrito reproduziu o erro original antes da correção: `The Parent property of Frame.PixelIcon is locked`. A correção separa liberação de referências de destruição explícita. O sinal Destroying só libera; Destroy explícito é idempotente, desconecta primeiro e só chama o engine para um Frame ainda montado. Nós, mapas de skin, referências ao Frame/dono e callback de layout são removidos. Métodos ignoram handles liberados. Não foi acrescentado pcall para suprimir a falha. SetIcon, ícones personalizados, temas e SetPixelIcons mantêm a renderização existente.

## APIs e comportamento

- GameMetadata e RefreshGameMetadata/GetGameMetadataStatus integram CreateScriptHub, AddGame, UpdateGame e CatalogUpdate. Campos manuais vencem; a consulta é adiada, deduplicada, com cache por Hub de 128 respostas, TTL e limite de 1–4 consultas em curso. Seleção, favoritos, pesquisa, ordenação, scripts e rolagens são preservados.
- O provider padrão usa MarketplaceService:GetProductInfoAsync para Name/Description do Place. Usa GetProductInfo legado somente se Async não existir. Esses dados não garantem a experiência principal. A correspondência PlaceId/UniverseId só é obtida automaticamente para o Place da sessão usando game.GameId; outras correspondências e dados de experiência podem vir do provider opcional autorizado. Não há endpoint inventado ou contorno de restrições. Miniaturas continuam no gerenciador original.
- Profile amplia GetStatus e GetRuntimeSnapshot com últimas/médias/mínimas/máximas/somas de duração, execuções, desfechos, cancelamentos pedidos/concluídos, skips e histórico de 16. Tarefas acima do intervalo são sinalizadas no inspetor sem mudar o scheduler. ctx:Wait e ctx:AwaitAction medem espera instrumentada. Tempo restante não é CPU exata; task.wait direto e rede sem instrumentação não são interceptados.
- RegisterSessionState/UnregisterSessionState/CreateSessionSnapshot/RestoreSessionSnapshot capturam somente States registrados e dados simples validados, sem runtime executável ou perfis. O envelope valida schema/API/WindowId. A restauração usa Batch e suprime callbacks de controles, preservando observação reativa de State. Capture antes de Destroy; transferência entre execuções depende de armazenamento compartilhado escolhido pelo desenvolvedor.
- CreateIntegration reutiliza CreateWindow, CallbackExecutor, diagnóstico e scopes, com verificação de capacidades e limpeza de inicialização/destruição. Não altera identidade ou permissões.

Detalhes e limites: [Game Metadata](GAME-METADATA.md), [Profiler](RUNTIME-PROFILER.md), [Snapshots](SESSION-SNAPSHOTS.md), [Helper](INTEGRATION-HELPER.md) e [Operação cancelável](CANCELLABLE-OPERATION.md).

## Testes executados

- **336/336 testes headless** com Lua 5.4 e double de engine; compilação sintática da fonte standalone e arquivos Lua incluídos. Os 256 testes anteriores continuam presentes.
- **20 testes PixelIcon**, dez cenários em cada modo de eventos (imediato/adiado), incluindo Parent já destruído, repetição de Destroy, troca de ícone, customização, temas, PixelIcons off/on, reexecução e Script Hubs. Nenhum Parent bloqueado ou escrita em ícone destruído após a correção.
- **25 testes de metadata**, incluindo falhas, respostas parciais, cache/expiração, deduplicação, concorrência, 132 jogos/cache limitado, 200 refreshes pendentes, remoção/destruição/troca de ID, campos manuais, UTF-8, provider e catálogo remoto seguro.
- **8 testes de profiler**, **8 de snapshots**, **3 do helper** e **16 da operação em seis etapas**, todos incluídos nos 336. A operação foi cancelada e teve falha provocada em cada etapa; também passou em sucesso, duplicação, reinício, destruição e task.spawn imediato.
- Os **29 exemplos oficiais** carregaram pela API pública e retornaram conexões/recursos ao baseline no teste geral.
- **2/2 testes Python de distribuição**, promoção independente de canais, integridade, recusa de sobrescrita e rollback com fonte local alterada.
- Testes privados dos seis loaders atuais obtidos do GitHub e do Mano Gustavo Hub completo com **sete jogos**, sem arquivos locais do executor, alteração de catálogo ou execução automática de código dos jogos. A seleção de jogos/scripts fez somente navegação.
- Prompt completo atual preservado e ampliado de **55355 para 64633 bytes**; contrato HTTP/API 2 validado e exemplo principal executado com bootstrap e runtime 2.1.0.
- **10 manifestos de distribuição** conferidos com hashlib, incluindo canais e exemplos de Hub/catálogo. Aliases, versões, tamanho e SHA-256 conferem. Release 2.0.0 e as três cópias do bootstrap permanente permaneceram byte a byte iguais.

Os testes não equivalem a execução em executor Roblox real. Renderização nativa, disponibilidade da API Roblox no executor e funcionalidades específicas dos jogos não foram testadas em cliente nativo.

## Exemplos criados

- examples/smart-game-metadata.lua
- examples/runtime-profiler.lua
- examples/session-snapshots.lua
- examples/integration-helper.lua
- examples/cancellable-operation.lua

## Distribuição

A publicação usa o builder existente. Stable e Preview da API 2 apontam para 2.1.0; o pin da 2.0.0 foi preservado. Bootstrap: https://raw.githubusercontent.com/ManoGustavo0/RetroBox/main/dist/bootstrap/v2.lua . A próxima execução de um consumidor no canal Stable resolve a nova release sem alterar seu loader; uma janela já aberta não é substituída.

Artefato 2.1.0: **515260 bytes**. SHA-256: `2c8c8f1b008719dd415770dc05cea065cf5b91bf4925fd68a547332e166d1c20`.

A integração em main e a conferência dos endpoints públicos são realizadas antes da entrega final, que identifica PR e commits. O prompt atualizado é mantido como documento separado; não foi introduzida dependência dele no runtime.

## Arquivos modificados ou acrescentados

- `RetroBox-UI-v1.1.0/retrobox-ui/CHANGELOG.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/README.en.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/README.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/RetroBox.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/API.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/AUTO-UPDATE.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/CANCELLABLE-OPERATION.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/GAME-METADATA.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/ICONS.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/INTEGRATION-HELPER.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/INTEGRATION.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.1.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/RUNTIME-PROFILER.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/RUNTIME.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/SCRIPT-HUB.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/SESSION-SNAPSHOTS.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md`
- `RetroBox-UI-v1.1.0/retrobox-ui/examples/cancellable-operation.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/examples/integration-helper.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/examples/runtime-profiler.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/examples/session-snapshots.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/examples/smart-game-metadata.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/src/GameMetadata.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/src/HubUpdates.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/src/Integration.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/src/RuntimeProfiler.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/src/SessionSnapshots.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/cancellable-operation.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/distribution.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/game-metadata.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/headless.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/hub-update.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/mock_roblox.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/pixel-lifecycle.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/profiler.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/session-integration.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/test_release_pipeline.py`
- `RetroBox-UI-v1.1.0/retrobox-ui/tests/update.lua`
- `RetroBox-UI-v1.1.0/retrobox-ui/tools/build_distribution.py`
- `dist/channels/preview/v2.json`
- `dist/channels/stable/v2.json`
- `dist/history.json`
- `dist/preview/v2/RetroBox.lua`
- `dist/releases/2.1.0/RetroBox.lua`
- `dist/releases/2.1.0/manifest.json`
- `dist/stable/v2/RetroBox.lua`
