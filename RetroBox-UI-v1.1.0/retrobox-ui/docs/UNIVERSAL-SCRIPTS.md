# Scripts universais · RetroBox 2.4.0

`UniversalScripts` é uma coleção própria do Script Hub nativo. Funciona em `Library:CreateScriptHub` e `window:CreateScriptHub`, ao lado de `Games`, sem cadastrar um jogo fictício. Cada script recebe a tag **UNIVERSAL** no card. O launcher oferece um botão de categoria, título e pesquisa próprios; favoritos de jogos, metadados Roblox e teleporte continuam ligados aos jogos.

## Estrutura mínima

Carregue o bootstrap permanente da conta nova com `MinVersion="2.4.0"`. No modelo abaixo, substitua o texto de URL pelo link Raw que você copiou do Pastefy:

```lua
local Library=loadstring(game:HttpGet("https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua"))({Channel="stable",MinVersion="2.4.0"})
local hub=Library:CreateScriptHub({
    Id="meu-hub",Title="Meu Hub",Theme="Hacker",
    Games={},
    UniversalScripts={{
        Name="Meu script universal",
        Description="Explique o que o script faz.",
        URL="COLE_AQUI_O_LINK_RAW_DO_PASTEFY",
    }},
})
```

O modelo requer a sua URL real. O [exemplo executável](../examples/universal-scripts.lua) usa um callback local de notificação e não depende de um paste de demonstração.

| Campo | Uso |
| --- | --- |
| `Name` | Nome obrigatório, até 128 bytes. `Title` também é aceito; quando ambos são informados, devem ser iguais. |
| `Description` | Descrição de até 2048 bytes, exibida no card e nos detalhes. |
| `URL` | Link HTTPS direto do código, até 2048 bytes. Pode ser Raw do Pastefy ou outra origem HTTPS escolhida pelo desenvolvedor. |
| `Id` | Opcional. Sem ele, a library gera um Id a partir do nome. Informe Ids únicos e estáveis quando houver nomes repetidos ou integrações externas. |
| `Callback` | Alternativa à URL: `function(ctx, hub, script)`. Use URL ou Callback, nunca os dois. |
| `Icon`, `Author`, `Version`, `Status` | Personalização compatível com os cards de scripts existentes. |
| `Enabled`, `Requires`, `Confirm` | Disponibilidade, capacidades e confirmação opcional. Um predicado Enabled recebe `(hub, script)`. |

Scripts universais não recebem PlaceId, UniverseId, GameId ou CurrentGameOnly=true. A tag indica ausência de vínculo com um jogo; o comportamento real do código é definido pelo desenvolvedor.

## GitHub para a library, Pastefy para os scripts

O endereço da RetroBox continua no GitHub. Nos campos URL dos seus scripts, use o link **Raw**, que retorna o código diretamente. O Pastefy oferece links Raw; copiar o endereço da página de visualização pode retornar HTML no lugar de Lua. Um paste com login, criptografia ou expiração não é uma fonte pública permanente para o executor.

Não é necessário instalar uma integração Pastefy nem colocar uma chave de publicação no script cliente. A library só acessa a URL que você cadastrou, ao solicitar a execução. Atualizar um paste mantendo seu Raw estável permite obter o conteúdo novo na próxima execução desse script. A disponibilidade da hospedagem não é controlada pela RetroBox.

No **Mano Gustavo Hub 2.2.0**, os registros universais ficam em `CONFIG.UniversalScripts`. Os scripts de jogos continuam em `CONFIG.Games[n].Scripts` e também aceitam URL do Pastefy pelo carregador do consumidor. As sete URLs antigas do backup foram preservadas; substitua-as pelos seus novos Raw quando publicar os scripts no Pastefy.

## Execução e cancelamento

Selecionar categoria, pesquisar, restaurar perfil e receber metadados não executa scripts. O botão Executar e `RunUniversalScript` usam as ações existentes: bloqueio de duplicatas, progresso, falhas e cancelamento cooperativo. As execuções de jogo e universais têm identidades independentes, inclusive quando os scripts usam o mesmo Id.

Para URL, a library confere HttpGet/loadstring, baixa o texto ao executar, rejeita conteúdo vazio ou maior que 2 MiB e relata erros de compilação/execução. Há verificações de cancelamento antes do download, após o retorno e antes de iniciar o código. Cancelar não interrompe à força um HttpGet já em andamento nem reverte efeitos de código já executado.

```lua
hub:SelectUniversalScripts()
hub:SelectUniversalScript("meu-id")
local handle,reason=hub:RunUniversalScript("meu-id")
local status=hub:GetUniversalScriptStatus("meu-id")
hub:CancelUniversalScript("meu-id")
```

## APIs de catálogo

`GetUniversalScripts()`, `GetUniversalScript(id)`, `AddUniversalScript(record)`, `UpdateUniversalScript(id, patch)`, `RemoveUniversalScript(id)`, `IsUniversalScriptAvailable(id)`, `GetUniversalScriptStatus(id)`, `RunUniversalScript(id, options)`, `CancelUniversalScript(id)`, `SelectUniversalScripts()` e `SelectUniversalScript(id)`.

`GetSelectedCategory()` retorna `Games` ou `Universal`. Em Universal, `SelectedGameId` e `GetSelectedGame()` são nil; `GetSelectedScript()` e `SelectScript(id)` trabalham na categoria selecionada. `GetGames()` contém somente jogos reais. Volte com `SelectGame(gameId)` ou pelos filtros/jogos da navegação.

Os getters devolvem cópias, sem callbacks, predicados ou definições privadas. As alterações validam antes de modificar o catálogo. Ao mudar o nome por UpdateUniversalScript, o Id atual é preservado. Para trocar uma URL por Callback, use `{URL=false, Callback=function(...) ... end}`. Há até 128 scripts universais, dentro do limite total de 4096 scripts do Hub.

## Catálogos JSON

Um HubCatalog pode incluir `UniversalScripts` para atualizar textos, estado e associação a uma Action registrada localmente. URL, Source e Callback continuam proibidos em JSON. Um Id já registrado conserva sua URL/callback local quando Action não é informada; uma Action desconhecida fica indisponível. Omitir UniversalScripts preserva a coleção local; um array vazio explícito remove os universais e solicita cancelamento das execuções anteriores.

Os catálogos com esse recurso devem exigir RetroBox 2.4.0/API 2 em seu manifesto. A aplicação de jogos e universais é atômica. A categoria entra no perfil por uma flag nova; perfis antigos continuam válidos, sem execução automática.

Fonte sobre Raw do Pastefy: [documentação oficial de recursos](https://docs.pastefy.app/features/index.html). Veja também [Script Hub](SCRIPT-HUB.md), [auto update](AUTO-UPDATE.md) e [release 2.4.0](RELEASE-2.4.md).
