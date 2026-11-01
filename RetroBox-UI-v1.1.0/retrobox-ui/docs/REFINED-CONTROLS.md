# Componentes refinados e movimento · RetroBox 2.11 / API 2

Cinco componentes nativos para casos comuns em scripts e um animador central com curvas próprias. Tudo usa o mesmo ciclo de vida, temas, busca, perfis e preferências de movimento dos controles anteriores.

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua"
))({Channel = "stable", MinVersion = "2.11.0"})
```

[Exemplo completo](../examples/refined-controls.lua) · [Release](RELEASE-2.11.md) · [API](API.md)

## Segmented

Escolha exclusiva entre 2 e 8 opções curtas, com indicador que desliza até a opção selecionada.

```lua
local mode = section:AddSegmented({
    Id = "mode", Title = "Modo",
    Options = {"Próximo", "Aleatório", "Menor vida"},
    Default = "Próximo",
    Callback = function(value) print(value) end,
})
mode:SetOptions({"Perto", "Longe"}) -- mantém o valor se existir; senão seleciona o primeiro
```

| Membro | Descrição |
| --- | --- |
| `Options` | 2–8 textos/números únicos. O valor é sempre uma string. |
| `SetValue(value, silent?)` / `GetValue()` | Valor inexistente gera erro. |
| `SetOptions(array)` / `GetOptions()` | Recria os segmentos; dispara `Callback` só se o valor mudar. |
| `GetIndex()` | Posição da opção atual. |

Use `AddDropdown` para listas longas, pesquisa ou múltipla escolha.

## RangeSlider

Um intervalo `{Min, Max}` com dois polos no mesmo trilho.

```lua
local delay = section:AddRangeSlider({
    Id = "delay", Title = "Intervalo", Min = 0, Max = 5, Step = .1, MinGap = .2,
    Default = {Min = .5, Max = 1.5}, Suffix = "s",
})
local low, high = delay:GetRange()
delay:SetRange(1, 2)
```

Os dois valores seguem `Step`; `Min` nunca passa de `Max` e a distância respeita `MinGap` (use um múltiplo de `Step`). Clicar no trilho move o polo mais próximo; arrastar um polo o mantém selecionado. `GetValue()` retorna uma cópia.

## Number

Valor numérico exato com `-`/`+`, digitação e repetição ao segurar (espera de .45 s, depois a cada .07 s).

```lua
local amount = section:AddNumber({Id = "amount", Title = "Quantidade", Min = 1, Max = 50, Step = 1, Default = 5, Suffix = " un."})
amount:Increment(1)   -- true quando o valor mudou
amount:Increment(-1)  -- false no limite ou desabilitado
```

`Min`/`Max` são opcionais. `Precision` (0–6) é deduzida de `Step` se omitida. Texto inválido restaura o valor anterior. Os botões ficam inativos nos limites.

## Callout

Painel informativo com faixa e ícone da cor do tema. A altura acompanha o texto, a largura e a escala.

```lua
local note = section:AddCallout({Title = "Modo educativo", Content = "Valores apenas locais.", Kind = "Tip"})
note:SetKind("Warning"); note:SetContent("Esta opção reinicia a demonstração.")
section:AddCallout("Atalho simples só com texto")
```

`Kind`: `Info`, `Tip`, `Success`, `Warning` ou `Danger`. Métodos `SetContent`, `GetContent`, `SetTitle`, `SetKind`, `GetKind`, `SetIcon`. Não entra nos perfis.

## CodeBlock

Trecho monoespaçado somente leitura, com números de linha, rolagem e botão Copiar.

```lua
local block = section:AddCodeBlock({Title = "Config", Language = "lua", Code = "return {speed = 16}", Height = 120})
block:SetCode(window:ExportConfig())
local ok, reason = block:Copy()
```

CRLF vira LF, tabulação vira quatro espaços, limite de 65536 bytes e `RichText` desligado. `Copy` usa `setclipboard`/`toclipboard` quando o executor oferece; sem eles retorna `false, "unavailable"` e mostra um aviso. `OnCopy(code)` roda só após a cópia. `Copy=false` e `LineNumbers=false` removem botão e numeração. Não entra nos perfis; para logs ao vivo use `AddConsole`.

## Integração

- Todos aceitam `Id`, `Title`, `Description`, `Tooltip`, `Icon`, `Disabled`, `Visible`, `DependsOn`, `State`/`TwoWay`, `FireOnInit`, `Callback`, `Animated=false` e funcionam em `CreateRow`.
- `Library:RegisterComponent` aceita os cinco tipos em `ctx:Add`. `CreateForm` aceita `Segmented`, `RangeSlider` e `Number` como campos.
- `ExportConfig` grava `Segmented` (string), `RangeSlider` (`{Min,Max}`) e `Number` (número); `ImportConfig` valida antes de aplicar.
- O Designer HTML ainda não oferece estes cinco tipos.

## Movimento

O animador central aceita curvas por transição (Quad/Out continua o padrão):

- Abertura da janela: linha de varredura CRT que se expande e some; escala com leve elasticidade.
- Botões: pulso quadrado a partir do centro ao ativar, sem mudar a área clicável.
- Toggle: check desce com salto. Marcadores de seleção (abas, listas) entram com elasticidade.
- Segmented: indicador desliza; Number: o texto dá um pequeno salto na direção do passo; RangeSlider: polos com Quint.
- Notificações: barra de tempo restante na cor do tipo, com a duração real (não muda com `Speed`). `Timer=false` oculta.

`ReducedMotion`, `Animations.Enabled=false` e `Intensity="Off"` aplicam os valores finais imediatamente. `Intensity="Subtle"` mantém transições curtas e remove linha CRT, pulso e curvas elásticas. `Animated=false` desliga só aquele controle. Não recrie esses efeitos com `TweenService` no script nem altere os filhos internos `PressPulse`, `PowerOnLine`, `NoticeTimer` e `SegmentIndicator`.

Os testes são de lógica e geometria simulada; confira a aparência final no executor.
