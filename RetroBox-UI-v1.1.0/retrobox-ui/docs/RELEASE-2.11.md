# RetroBox 2.11.0 — Movimento refinado e novos componentes

## Comportamento

Cinco componentes nativos: `AddSegmented` (2–8 escolhas com indicador deslizante), `AddRangeSlider` (intervalo `{Min,Max}` com dois polos), `AddNumber` (`-`/`+`, digitação e repetição ao segurar), `AddCallout` (painel Info/Tip/Success/Warning/Danger com altura automática) e `AddCodeBlock` (código monoespaçado, números de linha e Copiar). Funcionam em linhas, busca, temas, perfis, `DependsOn`, `State`, componentes reutilizáveis e formulários (Segmented/RangeSlider/Number).

O animador central passa a aceitar curvas por transição, mantendo Quad/Out como padrão. A janela abre com uma linha CRT e escala elástica; botões emitem um pulso ao ativar; o check do Toggle desce com salto; marcadores de seleção entram com elasticidade. Notificações ganham barra de tempo restante com a duração real (`Timer=false` oculta).

Preferências existentes continuam valendo: Reduced Motion, Enabled=false e Intensity Off aplicam os valores finais; Subtle remove linha CRT, pulso e curvas elásticas; `Animated=false` desliga um controle. Os efeitos não mudam áreas clicáveis nem disparam callbacks.

## Detalhes de implementação

- `Window:_animate`/`_motion` recebem um estilo opcional (`Easing`, `Direction`, `Exact`). `Exact` ignora `Speed` e Subtle para cronômetros de parede, como a barra das notificações.
- Novo `src/RefinedControls.lua`, incorporado em `-- BEGIN RETRO211 REFINED CONTROLS`. As opções são validadas antes de registrar o controle, para que uma configuração inválida não deixe um Id órfão.
- `DevelopmentComponents.lua` libera os novos tipos em `RegisterComponent` e `CreateForm`.
- Novidades recebe a entrada oficial 2.11.0.

## Arquivos e distribuição

- `src/RefinedControls.lua`, animador central em `RetroBox.lua`, `tools/build_distribution.py`.
- `tests/refined-controls.lua`, `examples/refined-controls.lua`, `tests/prompt-runtime.lua`.
- Release imutável `dist/releases/2.11.0`, aliases Stable/Preview e manifesto SHA-256.
- [Guia dos componentes](REFINED-CONTROLS.md), API, changelog, READMEs, validação e prompt integral `docs/Prompt-RetroBox-IA-v2.11.0.md`.

API 2 e bootstrap permanente preservados. Consumidores em Stable/Preview recebem a mudança ao executar novamente; para chamar os métodos novos use `MinVersion="2.11.0"`. Pinned e fontes fixas continuam na edição escolhida. O Designer HTML ainda não oferece os cinco tipos novos.

## Verificação

[Validação](VALIDATION.md). Serviços, tweens e geometria são simulados; não há renderer Roblox neste ambiente. Os testes não substituem a inspeção visual e de entrada no executor alvo.
