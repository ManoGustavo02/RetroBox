# Ferramentas de desenvolvimento — RetroBox 2.5.0 / API 2

O [Designer HTML](../../../designer/README.md) usa as mesmas APIs documentadas aqui. A sequência continua **loader → janela → aba → seção → controles**; a fonte histórica não mudou de pasta. Os recursos são aditivos à API 2. Os catálogos de jogos, IDs, perfis e bootstrap existentes permanecem compatíveis.

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

Veja os exemplos [localization-forms](../examples/localization-forms.lua), [reusable-components](../examples/reusable-components.lua), [card-grid](../examples/card-grid.lua), [visual-flow](../examples/visual-flow.lua) e os [projetos JSON](../../../designer/examples/).
