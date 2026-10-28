# Central de Ideias · Feedback Hub · RetroBox 2.10

Componente opt-in separado do Script Hub. Permite pedir scripts para jogos, sugerir melhorias, compartilhar feedback e relatar problemas. Cria uma janela própria com `Library:CreateFeedbackHub` ou uma guia em uma janela existente com `window:CreateFeedbackHub`. Janelas normais e Script Hubs não recebem uma categoria extra automaticamente.

## Começar

```lua
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.10.0'})
local feedback=Library:CreateFeedbackHub({
    Id='minha-central',Theme='Hacker',Locale='auto',
    WebhookURL='', -- coloque aqui seu webhook real; vazio mantém o envio desativado
    Categories={'ScriptRequest','Suggestion','Feedback','BugReport'},
    Game='current',IncludeAvatar=true,
})
```

[Exemplo completo](../examples/feedback-hub.lua). Crie o webhook na integração do canal do Discord e coloque a URL no script consumidor, não na fonte da RetroBox. Prefira um canal de texto; para um tópico existente ou destino em fórum, informe `ThreadId` com o ID do tópico.

**Um webhook no cliente pode ser extraído.** A library não pode esconder um segredo entregue ao executor. O modo direto é uma conveniência para uso controlado; distribuir um webhook público exige aceitar esse risco. Para proteger o token, use `Transport` conectado a um servidor sob seu controle, com validação/autenticação e limitação de taxa no servidor. Não há servidor de relay embutido nem implantação automática de backend.

## Tela e dados

A apresentação padrão é uma interface própria de comunicação, Layout='Launcher'. O cabeçalho, os cartões de categoria e as etapas Mensagem, Diagnóstico e Revisar organizam o formulário. Dados de jogo/jogador e status ficam ao lado no desktop e abaixo em telas menores. Nomes e descrições quebram em linhas com altura medida; categorias e navegação se reorganizam conforme a largura e a escala de texto.

Mensagem contém o jogo atual ou outro por ID/link, campo de texto e contador. Diagnóstico é opcional e não captura nem anexa registros ao navegar. Revisar mostra o texto completo e o diagnóstico preparado, quando incluído. Enviar, limpar e reenviar aparecem na revisão; cancelar uma espera em andamento permanece disponível nas outras etapas. A prévia do diagnóstico é selecionável e somente leitura, inclusive após atualizar texto, tema, idioma, escala ou perfil.

Na janela independente, a navegação principal é horizontal e a Central ocupa a área útil, sem a pesquisa global do formulário. Ao abrir Novidades ou outras abas, o layout normal da janela é restaurado. Em uma janela existente, a Central não altera a navegação ou a pesquisa das outras abas. Layout='Classic' preserva a apresentação anterior em seções. Ambas usam os controles, temas, acessibilidade, animações, scopes e rolagem nativos.

O jogo é consultado por PlaceId. Um link deve ser o HTTPS oficial `https://www.roblox.com/games/ID/...` ou `https://roblox.com/games/ID/...`. Links de compartilhamento sem `/games/ID` precisam ser convertidos para o link do jogo/ID. Se o nome não puder ser consultado, o ID e o link continuam disponíveis; a prévia informa a limitação.

O payload do Discord contém um embed com categoria, mensagem, nome do jogo, link, PlaceId, DisplayName e @Name. O avatar aparece como miniatura quando a API retorna HTTPS de um domínio Roblox/CDN permitido. Conteúdo `rbxthumb://` é válido para a interface Roblox, mas não é enviado como URL de imagem ao Discord. `IncludeAvatar=false` dispensa a consulta e o campo da imagem. Falha na imagem não impede enviar texto.

Identidade é lida do LocalPlayer real, com observação da chegada e de Name/DisplayName/UserId. O envio aguarda campos reais; não usa Player/@Player fictício ou a identidade de outro jogador. Dados do cliente não são autenticação: um executor alterado pode forjá-los, e um relay precisa tratar esse conteúdo como entrada não confiável.

Não há envio ao abrir a tela, mudar categoria/idioma, carregar perfil ou editar texto. A etapa Revisar mostra a mensagem completa; a apresentação Classic mantém a prévia resumida com aviso de texto completo no envio. Quebras de linha são normalizadas e espaços externos são removidos; o restante da mensagem não é reescrito nem traduzido. O payload não inclui JobId, dispositivo, HWID, identificação do executor ou coleta extra de IP. `allowed_mentions.parse` é vazio para impedir menções em massa.

## Opções

| Opção | Padrão e contrato |
| --- | --- |
| `Id` | `feedback`; 1–64 letras/números/ponto/underscore/hífen, único na janela. |
| `WindowId` | Somente no factory da Library; padrão `RetroBox-Feedback-<Id>`, usado para reexecução. |
| `Title`, `Subtitle`, `Theme`, `Locale` | Opções normais da janela standalone. Sem títulos customizados, o cabeçalho também acompanha PT/EN. Tema padrão Hacker; locale padrão auto. |
| `WebhookURL` | URL HTTPS oficial Discord `/api/webhooks/id/token` ou `/api/vN/webhooks/id/token`; vazia/nil desativa o envio. Não aceita query/fragmento no segredo. O executor usa o endpoint v10 com `wait=true`. |
| `ThreadId` | String numérica com o ID do tópico de destino; adicionada como parâmetro separado. |
| `Categories` | Array de 1–4 IDs: ScriptRequest, Suggestion, Feedback, BugReport. O texto mostrado é traduzido. |
| `DefaultCategory` | Primeiro ID habilitado. |
| `Layout` | `Launcher`; `Classic` mantém a apresentação anterior. Opção independente do Script Hub. |
| `Size` | Na janela standalone Launcher, 940×680 quando omitido; uma dimensão fornecida pelo consumidor é preservada e o layout respeita os limites da janela. |
| `Game` | `current`, número/ID numérico ou link oficial do jogo. Pode ser alterado pelo usuário. |
| `MinLength`, `MaxLength` | 10 e 2000; inteiros entre 1 e 2000, medidos por caracteres Unicode. |
| `Cooldown` | 30 segundos; 0–3600, intervalo local entre tentativas. |
| `DuplicateWindow` | 600 segundos; 30–3600, janela local de detecção de duplicatas. |
| `Timeout` | 20 segundos; 1–120, prazo da espera pela confirmação. Não consegue desfazer um POST já iniciado. |
| `IncludeAvatar` | true; pode ser false. |
| `ClearOnSuccess` | false; true só limpa se o rascunho inteiro continuar igual ao enviado. |
| `Request(spec)` | Adaptador HTTP opcional. Sem ele, tenta request, http_request, syn.request ou http.request, quando realmente disponíveis. |
| `Transport(payload)` | Alternativa independente de WebhookURL/Request para um relay. Não recebe a janela ou callbacks de GUI. |
| `MetadataProvider(placeId)` | Opcional; retorna `{Name='...'}`. Padrão usa MarketplaceService do cliente. |
| `AvatarProvider(userId)` | Opcional; retorna URL HTTPS Roblox/CDN. Padrão usa GetUserThumbnailAsync. |
| `CooldownKey` | Id lógico usado pelo transporte customizado; padrão Id. |
| `OnSent(preview, receipt)` | Executado somente após confirmação válida; não recebe o webhook. |

`Request` recebe `{Url,Method='POST',Headers,Body,Timeout}` e retorna `{StatusCode,Body,Headers?}`. Timeout também é uma indicação ao adaptador; alguns executores não o implementam no HTTP. O retorno deve ser uma tabela simples. Body é texto JSON. Não se tenta outro adaptador depois de um erro, pois o primeiro já pode ter enviado a mensagem.

`Transport` recebe uma cópia do payload do embed, não o segredo do Discord. Retorne o mesmo formato de resposta, por exemplo status 200 e Body com `{ "id": "ID_DA_MENSAGEM_CONFIRMADA" }` quando seu servidor confirmar a criação no Discord. Não retorne sucesso antes de a entrega real ser confirmada. O backend precisa ser construído/configurado pelo desenvolvedor.

## API

| Método/propriedade | Resultado |
| --- | --- |
| `GetDraft()` | `{Category,Message,Game}`; Game é current ou o texto/ID do outro jogo. Sem identidade nem webhook. |
| `SetDraft({Category?,Message?,Game?})` | Valida os campos antes de aplicar, preservando o restante do formulário. |
| `SetCategory(id)`, `SetMessage(text)`, `SetGame(value)` | Atalhos de edição; não enviam nada. |
| `ClearDraft()` | Limpa somente a mensagem. |
| `GetPreview()` | Snapshot público completo, ou nil/código de validação. Inclui Game e Player com nomes e avatar disponível. |
| `BuildPayload()` | Payload do Discord e preview, ou nil/código. Não faz HTTP. |
| `Validate(options?)` | bool, preview/código, dados internos adicionais; use os dois primeiros valores. |
| `Submit({RetryUnconfirmed?})` | Handle nativo de RunAction ou nil/código. Só esse método e o clique explícito iniciam o POST. |
| `CancelSubmission()` | Cancela a espera; se já iniciou o POST, a entrega pode ter ocorrido. |
| `GetStatus()` | State, Message, CanSubmit, Validation, RetryAfter, HTTPStatus e MessageId quando disponíveis. |
| `Status:Subscribe(callback)` | Estado observável da tela, liberado com o Hub. |
| `Show()`, `Hide()`, `Destroy()` | Ciclo de vida nativo; Destroy é idempotente. |
| `Window`, `Tab`, `Controls` | Janela, guia e controles existentes, para integração explícita. |
| `GetPage()` | `Compose`, `Diagnostics` ou `Review` no Launcher; `Compose` no Classic. |
| `SetPage(page)` | Seleciona uma etapa disponível no Launcher. Diagnostics=false remove a etapa Diagnostics. Não envia nem coleta logs. |

Os handles e callbacks dos controles existentes permanecem disponíveis. Controls.ReviewDiagnostic acrescenta a prévia exata do diagnóstico na revisão. Window:FocusControl encaminha os campos da Central para sua etapa; trocar de etapa fecha dropdowns e conserva o rascunho. Não há envio por navegação.

Categorias permanecem com IDs estáveis após trocar idioma. `Locale='auto'` usa o sistema existente da RetroBox, baseado no idioma configurado, não em nacionalidade/geolocalização. A interface, mensagens de erro, contador, ações, opções e prévia acompanham PT/EN. Texto enviado, nome do jogador e nome do jogo permanecem literais.

## Entrega, falhas e limpeza

Somente HTTP 200 com um ID de mensagem válido confirma `Sent`. Resposta vazia/204 inesperado, erro de rede, timeout, resposta inválida ou erro de servidor produzem `Unconfirmed`, mantendo o rascunho. Uma resposta 4xx recusada produz `Rejected`; 429 produz `RateLimited` e respeita Retry-After/retry_after em segundos. Não há reenvio automático.

O handle nativo pode terminar Completed quando o fluxo tratou uma recusa normalmente: confira `handle.Result.Code` ou `feedback:GetStatus().State`, não apenas a conclusão da ação. Apenas Code/State Sent é confirmação de entrega; OnSent segue essa regra.

Em uma entrega incerta, o botão de reenvio explica a incerteza e pede confirmação. Ele continua respeitando a pausa local e a do servidor. Programaticamente, `RetryUnconfirmed=true` é uma decisão explícita do consumidor. Alterar texto/categoria/jogo durante o envio não muda o snapshot já submetido nem apaga um novo rascunho ao concluir.

Há um ledger transitório compartilhado quando o executor permite, com até 64 destinos/usuários e 32 hashes por entrada. Ele contém somente hashes, status e tempos, e ajuda a impedir duplicação entre janelas/reexecuções. Não é proteção contra um cliente adulterado ou spam de várias pessoas; os limites do Discord continuam globais por destino, e proteção real depende do backend. Em globais somente leitura há fallback local.

Rascunho, webhook, função de transporte e identidade não são salvos nos perfis da janela. O texto só fica na memória daquela tela; fechar/reexecutar não promete recuperação do rascunho. Consultas antigas são invalidadas por geração. O worker HTTP recebe um pedido congelado e uma caixa de resposta destacável; timeout/destruição remove a ligação com a GUI. Uma resposta tardia não atualiza um formulário novo nem chama OnSent de uma janela destruída.

## Fontes e limites de verificação

- [Discord: Execute Webhook](https://docs.discord.com/developers/resources/webhook#execute-webhook)
- [Discord: limites e Retry-After](https://docs.discord.com/developers/topics/rate-limits)
- [Roblox: GetUserThumbnailAsync](https://create.roblox.com/docs/reference/engine/classes/Players#GetUserThumbnailAsync)
- [Validação da RetroBox](VALIDATION.md)

Os testes de transporte usam respostas simuladas e não publicam mensagens no Discord. Este ambiente não possui renderer Roblox. Um webhook e executor reais precisam ser conferidos pelo responsável pela distribuição; nenhuma credencial real acompanha os exemplos.

## Diagnóstico opcional · 2.9

Diagnostics=true é o padrão nas novas versões; cria uma seção opcional que inicia com o anexo e a captura desativados. Diagnostics=false mantém a tela sem essa seção. ScriptVersion é uma string opcional (até 64 bytes) incluída somente com o diagnóstico anexado. O nome, idioma e demais opções da janela permanecem compatíveis.

O jogador pode colar até 2000 caracteres de erro/stack trace, informar Code (até 64 caracteres), Steps (até 400) e marcar até 5 registros. O diagnóstico tem sua própria prévia selecionável e botão de cópia. Um envio de BugReport recebe [BUG]; outros relatos com diagnóstico recebem [DIAGNOSTIC]. A tag de erro é incluída como campo do embed.

Carregar erros disponíveis consulta explicitamente os diagnósticos das janelas desta instância da RetroBox (até 16 janelas) e o histórico local de LogService quando permitido (até as 160 entradas mais recentes). Somente erros e avisos são importados, com deduplicação, até 80 registros retidos e tamanho limitado por registro. Mensagens muito longas são resumidas na captura e sinalizadas na prévia. Nenhum registro vem marcado. A integração não promete acesso ao console privado de um executor nem a logs do servidor.

Acompanhar novos erros é opt-in e usa LogService.MessageOut quando disponível. Apenas a tela visível captura registros. Desativar o anexo ou destruir a tela encerra a conexão; eventos tardios não tocam na UI. Falhas de permissão são tratadas em sondagens específicas; não há hook de print/warn/error nem varredura de scripts ou clipboard.

O preparo remove padrões reconhecidos de webhook, token do destino, Bearer, cookies e campos de segredo. Isso não garante identificar todo dado sensível: o jogador deve revisar a prévia. A cópia usa somente o diagnóstico preparado; sem acesso ao clipboard, a prévia permanece selecionável. Não se lê o clipboard automaticamente.

O envio confere o embed inteiro antes de chamar o transporte: até 25 fields, até 1024 unidades por valor e 6000 no total, medindo emoji de forma conservadora como UTF-16. O diagnóstico é dividido em fields de até 900 unidades sem quebrar Unicode. Se não couber, a UI pede reduzir o texto ou selecionar menos registros; não há truncamento silencioso no envio nem upload de arquivo externo.

### API de diagnóstico

- hub:GetDraft().Diagnostics retorna Include, Text, Code, Steps e Selected (IDs locais).
- hub:SetDraft({Diagnostics={Include=true,Text='erro copiado',Code='E_BUTTON',Steps='Clique no botão',Selected={}}}) valida os campos antes de aplicar o restante do rascunho.
- hub:SetDiagnosticText(text, include?) preenche o texto; não envia.
- hub:CollectDiagnostics() importa registros disponíveis somente quando chamado.
- hub:GetDiagnosticRecords() retorna cópias saneadas e IDs locais de seleção.
- hub:SetDiagnosticCapture(true|false) altera a captura explícita.
- hub:ClearDiagnostics() limpa texto, tag, passos e seleção, e desativa o anexo; preserva a mensagem de feedback.
- hub:GetPreview().Diagnostics existe somente quando o usuário incluiu um diagnóstico válido.

Nenhuma dessas ações chama Submit automaticamente. Dados de diagnóstico não entram nos perfis. A detecção de duplicatas considera o conteúdo anexado e independe do idioma da interface. Falhas e respostas incertas preservam o diagnóstico; ClearOnSuccess só limpa se o rascunho completo ainda for igual ao enviado.

[Notas da versão](RELEASE-2.10.md) · [Novidades por origem](NEWS.md)
