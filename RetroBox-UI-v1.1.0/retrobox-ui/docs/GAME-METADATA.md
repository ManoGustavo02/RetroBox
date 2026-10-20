# Smart Game Metadata — 2.1.0

O Script Hub existente aceita jogos sem Name/Description quando há PlaceId ou UniverseId válido. Id continua obrigatório e não muda: favoritos, perfis, scripts e callbacks mantêm os mesmos identificadores.

```lua
local hub=RetroBox:CreateScriptHub({
    Id="meu-hub",
    GameMetadata={Enabled=true,CacheTTL=300,FailureTTL=30,MaxConcurrent=2},
    Games={{Id="atual",PlaceId=game.PlaceId,Scripts={{
        Id="principal",Title="Script principal",Callback=function(ctx)
            ctx:ThrowIfCancelled(); return "Executado pelo usuário"
        end,
    }}}},
})
```

Enabled=true é o padrão. O jogo aparece imediatamente como `Game <ID>`, com descrição vazia e a miniatura/fallback já existentes. A consulta ocorre em tarefa adiada, sem bloquear a criação da interface. A atualização usa as mesmas listas e detalhes do Script Hub 2.0.

## Prioridade e resultados

- Name preenchido manualmente é preservado. Name vazio é tratado como ausente.
- Description informada, inclusive `""`, é explícita e preservada; omita o campo para preenchimento automático.
- UniverseId e Image personalizados também são preservados.
- Dados automáticos podem mudar em RefreshGameMetadata; valores personalizados nunca são substituídos por esse refresh.
- Name externo é limitado a 128 bytes e Description a 2048, respeitando limites UTF-8. Outros campos seguem a validação de identificadores e imagens já existente.
- Uma falha mantém o jogo e seus callbacks utilizáveis. Nenhuma consulta executa scripts ou teleporte.

```lua
local accepted,reason=hub:RefreshGameMetadata("atual")
local status,reason=hub:GetGameMetadataStatus("atual")
```

Refresh retorna quando o pedido é aceito; não aguarda a rede. GetGameMetadataStatus retorna uma cópia com State, Cached, UpdatedAt, Error, Fields e Source quando disponíveis. Estados: Idle, Queued, Loading, Ready, Partial, Unavailable, Preserved e Disabled. Preserved indica que os campos necessários já foram informados manualmente.

## O que a API oficial permite

A implementação consulta `MarketplaceService:GetProductInfoAsync(PlaceId, Enum.InfoType.Asset)`. Usa o método legado GetProductInfo somente quando o método Async não está disponível. A chamada pode falhar por disponibilidade, capacidades, permissões ou limites da plataforma.

Esse método fornece dados do **asset Place**, incluindo Name e Description quando retornados. Esses dados não garantem o nome/descrição da experiência principal quando o Place pertence a outra experiência. Ele não promete um mapeamento arbitrário de PlaceId para UniverseId. Na sessão atual, a correspondência `PlaceId == game.PlaceId` permite usar `game.GameId`. Para outros casos, UniverseId permanece ausente até ser informado ou resolvido por um provider.

Miniaturas continuam usando o sistema nativo existente: Image explícita tem prioridade; UniverseId permite GameIcon; PlaceId permite GameThumbnail. Não há outro gerenciador de imagens.

Fontes oficiais: [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService#GetProductInfoAsync), [DataModel.GameId](https://create.roblox.com/docs/reference/engine/classes/DataModel#GameId), [DataModel.PlaceId](https://create.roblox.com/docs/reference/engine/classes/DataModel#PlaceId).

## Provider opcional

```lua
GameMetadata={
    Provider=function(query,official)
        -- query é uma cópia de {PlaceId?, UniverseId?}.
        -- Consulte dados próprios ou um serviço autorizado pelo desenvolvedor.
        -- Retorne nil para manter somente os campos oficiais já obtidos.
        return nil
    end,
}
```

O retorno pode conter apenas `{Name?, Description?, UniverseId?, Image?}`. Ele complementa/substitui os dados automáticos, antes da aplicação da prioridade dos campos manuais. Não é um callback de execução de scripts. Campos desconhecidos, funções, URLs de código e imagens web são rejeitados. Uma falha do provider conserva os dados oficiais válidos e aparece no status. Não há endpoint não documentado, proxy de contorno, alteração de identidade, leitura de cookies ou credenciais embutidas.

Um registro com apenas UniverseId pode ser resolvido por esse provider. Sem PlaceId e sem provider, permanece com fallback; não se inventa um PlaceId a partir do UniverseId.

## Cache e ciclo de vida

O cache é por Hub, com até 128 respostas. Sucesso/dados parciais usam CacheTTL, entre 0 e 86400 segundos; ausência de dados usa FailureTTL, entre 0 e 300. MaxConcurrent aceita 1–4 consultas, padrão 2. Pedidos simultâneos para os mesmos identificadores são deduplicados, inclusive refreshes repetidos. Há no máximo um listener por jogo em cada pedido.

CreateScriptHub, AddGame, UpdateGame e CatalogUpdate usam o mesmo fluxo. Mudar PlaceId/UniverseId invalida os campos automáticos derivados; mudar o nome manual durante uma consulta protege o novo nome. Respostas de registros substituídos/removidos não são aplicadas. Destruir o Hub remove dono, fila, cache e listeners. Uma chamada de plataforma/provider já em curso pode terminar depois; seu resultado é descartado. Não se promete abortar uma operação de rede nativa que não ofereça cancelamento.

A consulta não se repete continuamente. Cache expirado é consultado no próximo pedido novo/refresh; não há polling. Seleção atual, favoritos, critérios de busca/ordenação e posições das duas rolagens são preservados na atualização visual.

CatalogUpdate pode omitir Name/Description com identificador válido e GameMetadata habilitado. A validação declarativa original continua ativa: o provider não registra Actions nem modifica callbacks. Com GameMetadata=false ou Enabled=false, Name continua obrigatório.

Veja [smart-game-metadata.lua](../examples/smart-game-metadata.lua).

## Fallback e notas na 2.3.0

`FallbackName` (até 128 bytes) e `Notes` (até 2048) são campos nativos dos registros de jogo, inclusive em catálogos JSON. FallbackName aparece no launcher enquanto falta nome retornado; Notes fica em Info. Ambos permanecem pesquisáveis e não marcam Name/Description como manuais. Para consultar os dois campos pelo PlaceId, omita Name e Description na configuração e também na montagem do catálogo; não use `Description=entry.Description or ""`, pois a string vazia é uma personalização explícita.
