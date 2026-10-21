# RetroBox 2.5.2 — correções de layout compartilhadas

Esta versão patch corrige o Script Hub padrão e os controles tradicionais dentro da própria biblioteca. `CreateScriptHub` recebe as correções em qualquer consumidor. Mantém API 2, temas, ícones, callbacks, perfis, favoritos, IDs e a estrutura da distribuição. O bootstrap permanente continua em `dist/bootstrap/v2.lua`. O Designer 2.5.1 e seus projetos/exportações continuam compatíveis e não foram modificados.

## Causas confirmadas

1. **Menu Cadastro/ordenação:** `Section:AddDropdown` monta o painel de opções como filho do controle. O launcher reparentava esse controle para `GameCatalog`, dentro de `LibraryBody`; ambos possuem recorte. Com `ZIndexBehavior.Sibling`, elevar apenas os descendentes não evita a ordem entre ancestrais nem o recorte do catálogo. A abertura também aumentava a altura do controle em 192 unidades e deslocava a pesquisa.
2. **Informações:** a barra de execução reservava 60 unidades no desktop e 58 no modo compacto. O ícone e o padding deixavam apenas cerca de 22 unidades para a legenda. Nem o texto traduzido nem `TextScale` participavam da distribuição. O botão principal e Cancelar também usavam larguras fixas.
3. **Informação e Keybind:** `_syncHelpBadge` calculava a posição com base na borda do título. `AddToggle` anexava o Keybind depois de `init`, trocava essa borda por offsets fixos e não recalculava a ajuda. Fixação e ajuda ainda mantinham reservas e deslocamentos separados, sem conhecer a largura real dos outros acessórios.

## Correções

- A ordenação usa o `ContextMenu` existente na camada da janela, com escopo e limpeza próprios, fora dos painéis com recorte. Os três valores/filtros originais são preservados. Seleção, clique fora, Escape e abertura/fechamento pelo seletor continuam funcionando. O menu respeita a parte visível da janela e pode abrir para cima. Mover/redimensionar a âncora fecha o menu, evitando uma posição desatualizada. A pesquisa e a lista não mudam de lugar durante a abertura.
- O launcher mede as legendas usando fonte, tamanho e ícone atuais. Ações, filtros e botões do jogo compartilham o cálculo de linhas; a barra inferior ganha altura quando precisa quebrar. Informações exibe o rótulo completo. As abas também reservam espaço para texto e ícone mantendo a navegação horizontal existente.
- Os cabeçalhos tradicionais compartilham a reserva de ajuda, fixação, Keybind integrado, controle principal e indicadores numéricos. Em pouco espaço, os acessórios passam para linhas adicionais; título, descrição, conteúdo e altura acompanham essa mudança. Adicionar/remover ajuda ou fixação não acumula offsets. O layout atualiza ao mudar texto, tecla, ícone, largura, preferências ou escala.
- O sistema de Tooltip e a lógica de captura/acionamento de teclas permanecem os existentes. Os consumidores não recebem ajustes de apresentação.

## Arquivos e funções

| Arquivo | Responsabilidade alterada |
| --- | --- |
| `RetroBox.lua` | `Control:_captureDescriptionLayout`, `_layoutAccessories`, `_layoutDescription`, `_syncHelpBadge`, `SetTooltip`, `SetIcon`, `Section:AddToggle` e atualização das preferências de ajuda. Contém também os módulos incorporados pelo build. |
| `src/HubUpdates.lua` | `Hub:_installResponsiveLayout`, `Sort:SetOpen` e destruição do menu de ordenação. |
| `src/HubLauncher.lua` | Medição/linhas de botões, `LayoutChrome`, `Layout`, legenda de Informações e observação de ícones/textos. |
| `src/CompactViews.lua` | `SetPinnable` passa a usar a reserva compartilhada; texto do botão recalcula o layout. |
| `tests/layout-regression.lua` | Regressões de geometria, interação, escalas, idiomas e ciclo de vida. |
| `tests/mock_roblox.lua`, `tests/icons.lua`, `tests/headless.lua` | Medição aproximada de largura no mock, contrato de espaço dos ícones e inclusão das novas regressões. |
| Distribuição e documentação | Release 2.5.2 gerada, manifests/canais, changelog, README, badge e validação. Releases históricas permanecem intactas. |

## Validação e limites

Os resultados finais ficam em [VALIDATION.md](VALIDATION.md) e no [relatório de publicação](../../../docs/PREPARATION-REPORT.md). A matriz automatizada cobre PT/EN, Hacker/Retro98/Paper/Midnight, `Scale` .75/1/1.5, `TextScale` .8/1/1.4, modo mobile, quebra de linhas, texto longo, clique nas opções, ajuda, captura de teclas, perfis, pesquisa, favoritos, execução explícita e limpeza sem erros de PixelIcon.

Esses testes verificam lógica e retângulos calculados com doubles de Roblox. Não constituem uma inspeção visual no cliente Roblox. As três capturas enviadas foram inspecionadas como referência; o ambiente de implementação não dispõe do renderer/cliente Roblox. A conferência final de fontes, toque e composição nativa continua necessária. O HTML do Designer é um preview próprio e não foi usado como prova do layout nativo.

Ao reexecutar um consumidor que usa o bootstrap permanente no canal Stable, ele pode receber a versão nova. Uma janela já aberta não troca de biblioteca em tempo real. Consumidores fixados em versões anteriores mantêm o pin escolhido.
