# RetroBox 2.7.0 — acabamento, carregamento e RGB

O acabamento é compartilhado por toda a library: entrada de textos nas páginas, tela de preparação de janelas, placeholders reutilizáveis e RGB opcional. O Script Hub recebe também uma paleta própria, editor de aparência, capa com transição e estados de carregamento. API 2, bootstrap HTTP, catálogos, IDs, favoritos, callbacks e pins anteriores são preservados.

## Interface geral

- Ao mudar de aba, títulos e descrições entram junto da transição do conteúdo. Há no máximo 48 entradas de texto por página; dados e callbacks não são atrasados.
- Janelas animadas mostram uma preparação curta até a montagem inicial concluir. Não há espera mínima artificial, porcentagens inventadas nem dependência da miniatura ou do avatar para liberar a interface.
- `LoadingScreen=false` desliga a apresentação inicial. O padrão automático é não bloqueante; movimento reduzido/animações desligadas dispensam essa apresentação quando não foi pedida explicitamente.
- `ShowLoading` permite que o desenvolvedor mostre trabalho real com mensagem, progresso e prazo máximo. Encerrar a janela, reexecutar ou substituir a tela libera seus recursos.
- Componentes comuns podem mostrar um skeleton com `SetLoading`. O StatCard mantém seu próprio método e conserva o valor durante o carregamento.
- Cores de texto continuam passando pelo ajuste de contraste. Entradas de aba, esqueletos e RGB respeitam preferências globais, intensidade, velocidade e `Animated=false` quando associados a um controle.

```lua
local window = RetroBox:CreateWindow({
    Id="meu-menu", Title="Meu menu", Theme="Hacker",
    TitleRGB={Speed=.12}, -- opcional; sem RGB por padrão
})
local section = window:CreateTab("Principal"):CreateSection("Dados")
local label = section:AddLabel({
    Title="Meu título", Description="Descrição independente",
    RGB=true, DescriptionRGB={Speed=.08, Phase=.4},
})
local skeleton = section:AddSkeleton({Title="Carregando dados", Lines=3, Height=100})
-- Quando o trabalho real estiver pronto:
skeleton:SetLoading(false)
label:SetRGB(false, "Description")
```

## RGB para textos

| API | Uso |
| --- | --- |
| `window:SetRGB(textInstance, options?)` | Retorna um handle para TextLabel, TextButton ou TextBox da janela. |
| `window:SetTitleRGB(options)` / `SetSubtitleRGB(options)` | Texto do cabeçalho; false remove o efeito. |
| `control:SetRGB(options, part?)` | Partes Title (padrão), Description, Value ou Button, conforme o componente. Retorna o controle. |
| Opções de criação `RGB` / `TitleRGB` / `DescriptionRGB` | Ativação declarativa nos controles padrão; RGB é atalho para o título. |
| Handle `SetEnabled`, `SetOptions`, `GetOptions`, `Destroy` | Alterar ou remover um efeito sem recriar o texto. Destroy é idempotente. |

`options` aceita true, false ou tabela. Padrões: `{Enabled=true, Speed=.15, Phase=0, Saturation=.82, Brightness=1, Contrast=4.5}`. Speed: .01–4 ciclos/segundo antes do multiplicador global; Phase: 0–1; Saturation: 0–1; Brightness: .25–1; Contrast: 1–7. Há até 128 efeitos por janela.

O efeito troca a cor do texto inteiro, preservando conteúdo, Unicode, tradução e RichText. Não insere marcações em nomes ou descrições. O contraste pode clarear/escurecer a cor para manter a leitura sobre o fundo efetivo. Remover o RGB restaura a cor do tema atual. Não há mudança de flags, valores, configurações de jogo ou callbacks durante os ciclos.

Os efeitos de texto e skeletons compartilham o Heartbeat de RGB existente, limitado a 30 atualizações/segundo. A conexão é liberada quando não há efeito visível e ativo nem ColorPicker em modo rainbow. Abas, controles, ancestrais e janelas ocultos pausam os efeitos; alterações de preferência são aplicadas imediatamente. Os ColorPickers mantêm sua API anterior. Não existe um loop por texto ou por pixel.

## Carregamento e placeholders

```lua
local loading = window:ShowLoading({
    Title="Atualizando dados", Message="Consultando o serviço…",
    Blocking=true, Timeout=20,
})
-- Atualize apenas com progresso conhecido do trabalho real:
loading:SetMessage("Processando resultados"):SetProgress(.5)
-- Ao terminar:
loading:Finish("Pronto")
```

`SetProgress(nil)` representa progresso desconhecido com skeleton; números de 0 a 1 mostram preenchimento proporcional. `Finish` conclui e libera a tela; chamadas repetidas e atualizações de progresso posteriores não reabrem a tela. `Destroy` cancela a apresentação e libera a barreira sem declarar conclusão do trabalho. O timeout padrão é 20 segundos, configurável entre 1 e 120, e também libera a tela sem inventar 100%.

A tela usa o espaço da janela abaixo do cabeçalho e respeita a escala. Sua vida é independente do trabalho: o desenvolvedor continua responsável por tratar o resultado, erro ou cancelamento da tarefa. Uma tarefa que falhe deve chamar Destroy; o prazo máximo evita uma barreira permanente se isso não acontecer.

- `section:AddSkeleton({Title, Lines=1..8, Height=48..500, Default=true})`: componente nativo, sem persistência; `SetLoading(bool)` ou `SetValue(bool)` alterna a apresentação.
- `window:CreateSkeleton({Parent=guiObject, Lines=3, Cover=false, Position?, Size?, ZIndex?})`: handle reutilizável para uma região existente, com `SetVisible(bool)` e `Destroy()`.
- `control:SetLoading(true/false)`: skeleton sobre um controle comum sem alterar seu valor. Enquanto ativo, interações com esse controle são bloqueadas. StatCards conservam seu estado nativo de Loading.
- Até 128 skeletons por janela; visual estático com movimento reduzido. Destruir o pai ou a janela libera conexões, bindings e referências.

## Tema exclusivo do Hub

```lua
local hub = window:CreateScriptHub({
    Id="meu-hub", Title="Meu Hub",
    HubTheme={Theme="Launcher", Accent="#44E784"},
    HubTitleRGB={Speed=.1}, HubDescriptionRGB=false,
    Games=games, -- mantenha seus jogos/IDs e scripts atuais
})
hub:SetTheme("Hacker")
hub:SetAccent("#7FDFFF")
hub:SetRGB({Speed=.08}, "Description")
hub:ShowThemeSettings()
```

O preset **Launcher** é próprio do Hub: fundo escuro, superfícies separadas, textos claros e verde concentrado em ações e seleções. As 12 paletas gerais continuam disponíveis. `HubTheme` aceita um nome ou `{Theme, Accent?, Colors?}`, com os mesmos 12 papéis de cor da library.

O botão **Tema** fica no rodapé do catálogo. Abre uma guia com escolha de preset, edição dos 12 papéis, restauração e retorno ao Hub. Filtros, capa, detalhes, cards, ícones, barra de execução, menus e tooltips usam a paleta local. O cabeçalho da janela, suas configurações gerais e outros Hubs mantêm os próprios temas. Botões e fontes conservam as dimensões acessíveis e as quebras em linhas dos layouts anteriores; a área de rodapé reserva espaço para a nova ação no desktop e no touch.

`GetThemeProfile`, `SetThemeProfile`, `GetThemeNames`, `SetTheme`, `SetAccent` e `ResetThemeProfile` operam sobre esse Hub. As cores são salvas como snapshot em `Appearance.Advanced.HubThemes[hubId]`; não alteram paletas globais. A importação é validada antes de alterar cores ou flags. Os perfis podem ser carregados antes de criar o Hub e sobrevivem à remoção de um tema customizado que foi usado como base. Até 128 perfis por janela. A preferência participa do save/autosave existente.

RGB é opt-in por texto. `hub:SetRGB(options, part?)` aceita Title (nome do jogo selecionado), Description e SelectedScript. `HubTitleRGB` e `HubDescriptionRGB` são atalhos de criação; nenhum nome cadastrado é modificado. O comportamento continua válido ao selecionar outro jogo ou catálogo universal.

O Hub mostra skeletons enquanto miniatura e descrição estão sendo consultadas. Dados manuais são preservados; falhas terminam o placeholder e mantêm o estado de indisponibilidade, com atualização disponível. Imagens carregadas entram com fade; o catálogo e os scripts não aguardam esses downloads para funcionar. A tela inicial indica a montagem do catálogo, não a conclusão de todas as consultas remotas.

## Arquivos e validação

- `src/Appearance.lua`: RGB de textos, skeletons, loading, entrada de páginas e herança de cores dos overlays.
- `src/HubAppearance.lua`: preset Launcher, perfis e editor exclusivo do Hub, persistência e atalhos RGB.
- `src/HubLauncher.lua`: hierarquia, faixa da capa, ação Tema, placeholders e entrada de imagem.
- `RetroBox.lua`: integração dos recursos compartilhados, paleta contextual, interações de loading e animação com conclusão garantida mesmo quando o destino já está em transição.
- `tools/build_distribution.py`: incorpora os novos módulos ao mesmo arquivo standalone.
- `tests/appearance.lua`: regressões de efeitos, isolamento, importação atômica, carregamento, preferências, limites e ciclo de vida. Os fixtures de animações isoladas usam LoadingScreen=false para medir somente os tracks daquela funcionalidade.
- [appearance-and-rgb.lua](../examples/appearance-and-rgb.lua): exemplo nativo executável com componentes comuns e Hub. Não depende de arquivo local da library.

Resultados em [VALIDATION.md](VALIDATION.md). Os testes são de lógica, geometria e eventos simulados; este ambiente não oferece renderer/cliente Roblox. A conferência visual na engine deve usar a demonstração. O Designer HTML e o bootstrap permanecem preservados; os novos recursos também podem ser usados por código após um export do Designer.
