# RetroBox 2.6.0 — identidade do jogador e movimento

Esta atualização corrige a identidade no rodapé e amplia as animações na própria library. Todos os consumidores da API 2 podem recebê-la pelo bootstrap existente. O modelo do Hub, jogos/IDs, perfis, callbacks, estilos e arquivos históricos são preservados.

## Perfil: causa confirmada e recuperação

`CreateWindow` capturava `Players.LocalPlayer` uma vez. `_profile` criava `Player/@player` e retornava definitivamente se aquela referência fosse nil. Mesmo com o jogador disponível depois, a janela não observava essa chegada. Quando havia jogador, só `DisplayName` era observado; mudanças em `Name` também podiam deixar o arroba desatualizado.

O perfil agora lê o LocalPlayer atual, observa a disponibilidade do jogador e as propriedades `Name`, `DisplayName` e `UserId`, e confere os dados novamente ao reabrir a janela. Nome e arroba são preenchidos de forma síncrona quando as propriedades reais estão disponíveis. Não há HTTP nem consulta ao avatar para obter o nome. Nome de outro jogador recebido em `PlayerAdded` nunca é adotado como identidade local.

Durante a inicialização sem dados, o rodapé mostra **Carregando perfil…**, sem inventar `Player/@Player`. Quando a engine entrega o jogador/nome, o perfil é preenchido na mesma janela. Se DisplayName ainda estiver vazio, o Name real é uma alternativa provisória válida. Nomes não passam pelo tradutor da interface e preservam Unicode. Uma conta real chamada Player continua sendo aceita; a correção remove o placeholder, não proíbe um nome legítimo.

Avatar tem cache e até três tentativas por solicitação. Falha ou demora da imagem não impede nome/arroba. Uma resposta de avatar obsoleta não pode sobrescrever a identidade atual. Os observers e esperas próprias são limpos na destruição; uma chamada já entregue à engine tem sua resposta invalidada e deixa de reter referências da interface. Não há polling por frame para localizar jogador.

A library não pode inventar os dados se a API do Roblox ou o executor nunca os disponibilizar. A garantia implementada é usar a identidade real disponível e recuperar automaticamente a inicialização tardia, sem ficar presa em um nome fictício.

## Animações

| Região | Movimento |
| --- | --- |
| Botões e controles | Feedback retrô de hover/pressão/clique, sem alterar retângulos clicáveis nem reconstruir pixels. |
| Campos | Transição da borda de foco. |
| Abas, listas e cards | Indicadores de seleção, entrada de textos e reaproveitamento seguro de células. |
| Janelas | Arraste suavizado por padrão; salto final correto ao soltar ou desligar movimento. |
| Tooltips e menus | Entrada de texto sem mover âncoras, alterar clipping ou remover a barreira de modais. |
| Estatísticas | Contagem numérica visual e feedback de aumento/queda; os valores públicos mudam imediatamente. |
| Line/Sparkline | Entrada e ajuste dos segmentos do pool. |
| Bar | Barras crescem da linha zero; atualizações continuam a partir da geometria atual. |
| Progress/ProgressChart | Preenchimento fluido; as máscaras de contraste acompanham o valor visual intermediário. |
| Hub, Mini HUD e Stepper | Seleção de jogo/script, troca de detalhes, execução/progresso e mudança de etapa. |

Charts e StatCards animam por padrão. `Animated=false` permite desligar os efeitos de um controle e seus componentes internos. Continua valendo a configuração global `Animations={Enabled=true, Speed=1, Intensity="Normal"}`, com Speed .25–4 e Intensity Normal/Subtle/Off, além de `ReducedMotion=true`.

`SmoothDragging=true` é o novo padrão. `SetDragOptions({Smooth=false})` preserva o modo direto; preferências já salvas continuam sendo respeitadas. Velocidade/intensidade e movimento reduzido encerram corretamente as transições pendentes. Desligar animações também encerra a interpolação de arraste.

Os efeitos não alteram dados, callbacks, seleção de teclas ou IDs. Formatadores personalizados continuam sendo chamados pelo render normal; não são executados a cada passo da contagem. Trocas de tema aplicam os tokens corretos imediatamente. Gráficos usam coordenadas lógicas para não multiplicar Scale duas vezes.

Há orçamento de até **96 segmentos animados por gráfico**; o restante é desenhado imediatamente, preservando todos os pontos até os limites existentes. Pools ocultos/reciclados cancelam transições antigas. Tweens usam o animador central, cancelam conflitos por propriedade e liberam conexões ao concluir/destruir. Não há loop permanente por botão, card, ícone ou jogador.

## Testar e configurar

Veja [motion-and-profile.lua](../examples/motion-and-profile.lua), um exemplo executável com dados fictícios e botão para atualizar gráficos/cards. A engrenagem da janela expõe as preferências de animação e arraste. O exemplo usa apenas o carregador HTTP permanente e não requer arquivo local da library.

```lua
local window = RetroBox:CreateWindow({
    Id = "meu-menu", Title = "Meu menu", Theme = "Hacker",
    Animations = {Enabled = true, Speed = 1, Intensity = "Normal"},
    SmoothDragging = true,
})
-- Em qualquer controle padrão, quando quiser apresentação imediata:
local section = window:CreateTab("Principal"):CreateSection("Dados")
section:AddStatCard({Title = "Total", Value = 100, Animated = false})
window:SetReducedMotion(true) -- aplica imediatamente os destinos pendentes
```

## Arquivos e validação

- `RetroBox.lua`: gerenciador de identidade, animador central, feedback/foco, contadores, gráficos, arraste, abas, menus, tooltips e limpeza.
- `src/Localization.lua`: atualização do perfil ao mudar locale, com nomes fora da tradução.
- `src/HubLauncher.lua`, `CardGrid.lua`, `CompactViews.lua`, `Stepper.lua`: animações dos componentes compostos.
- `tests/profile-identity.lua`: disponibilidade tardia, dados incompletos, nomes, imagem indisponível/obsoleta, reabertura, Unicode/tradução e destruição durante uma solicitação.
- `tests/motion.lua`: estados intermediários, limites de tracks, entrada/saída, dados imediatos, máscaras, escala, preferências, modal, reciclagem, arraste e descarte.
- `tests/mock_roblox.lua`: serviço Players observável e tween double com interpolação numérica/dimensional. Não emula o renderer.

Resultados em [VALIDATION.md](VALIDATION.md). Não houve inspeção visual no cliente Roblox neste ambiente; os testes validam lógica, geometria e estados intermediários simulados. A demonstração nativa permite conferir a aparência e os gestos no executor. O Designer HTML permanece compatível e inalterado; sua prévia não é apresentada como prova das animações nativas.
