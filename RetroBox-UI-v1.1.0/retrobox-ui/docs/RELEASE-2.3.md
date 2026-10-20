# RetroBox 2.3.0 · Script Hub launcher nativo

O launcher passa a ser a apresentação padrão de `Library:CreateScriptHub` e `window:CreateScriptHub`. Não depende do Mano Gustavo Hub nem de um adaptador copiado pelo desenvolvedor. O modo tradicional `CreateWindow → CreateTab → CreateSection → controles` continua disponível.

## Apresentação compartilhada

- Navegação horizontal na janela que contém hubs; biblioteca com miniaturas, busca, ordenação e filtros Todos/Favoritos/Jogo atual.
- Jogo selecionado com imagem, nome, descrição expansível, origem dos metadados, favoritos, atualização e teleporte com confirmação. Em largura suficiente, imagem e informações dividem o destaque.
- Cards de scripts reciclados com descrição, autor, versão e estado real. Um único comando Executar e Cancelar enquanto a operação estiver ativa.
- Barra de execução fixa, com progresso, erro/resultado, atividade em segundo plano e Info para texto completo e notas. Falhas de teleporte aparecem junto do jogo.
- Colunas no desktop e conteúdo empilhado em telas menores; a barra continua acessível. Touch, Scale e TextScale participam do layout.
- Temas, cores personalizadas e idioma pertencem ao desenvolvedor. Retro98 continua padrão; Hacker é a escolha do Mano Gustavo Hub.

## API e dados

As referências existentes `GameList`, `ScriptList`, `GameDetails`, `ScriptDetails`, `PlayButton`, `CancelButton` e os demais controles mantêm seus IDs e comportamento. Os métodos de execução, favoritos, catálogo e atualização continuam os mesmos. As views usam os scopes, perfis, miniaturas e runtime existentes, sem polling de apresentação.

Novos campos opcionais de jogo: `FallbackName` (até 128 bytes) e `Notes` (até 2048). São aceitos em Games, AddGame, UpdateGame e CatalogUpdate; não marcam Name/Description como personalizados. Nome manual e nome retornado pela consulta sempre prevalecem sobre fallback, mesmo que coincidam com o texto provisório. Notas aparecem em Info.

`hub:SetCatalogFilter("All" | "Favorites" | "Current")` retorna o hub; `hub:GetCatalogFilter()` retorna o filtro. A flag persistida é `hub/<HubId>/catalog-filter`. Buscar/filtrar/restaurar perfis não executa scripts nem teleporta. A pesquisa global continua encontrando e focando os detalhes nativos.

NavigationRatio aceita .3–.55, agora padrão .31; StackAt aceita 480–1000, agora padrão 700. ScriptListMaxRows continua 1–12, padrão 4; GameListMaxRows 2–16, padrão 7. A lista de jogos também respeita o espaço disponível. Não há exigência de mudar os scripts que já chamam CreateScriptHub.

## Lifecycle

Os testes estritos reproduziram uma limpeza diferida de ScreenGui com um atalho Hold ativo: a destruição do desenho apagava `_checkIcon.Frame` antes de a liberação do atalho alterar o toggle e pedir outro render. O render agora verifica a vida do controle, a hierarquia e o fechamento da janela antes de tocar no desenho. A liberação lógica do Hold e dos recursos continua acontecendo; a referência do ícone é conferida antes da animação. Não foi adicionado pcall para suprimir essa falha.

A limpeza idempotente dos PixelIcons da 2.1 continua preservada. O launcher libera seus observadores, atualização diferida, referências de foco e registros de tema quando o hub é destruído.

## Distribuição deste pacote

API 2 e o bootstrap permanente permanecem. Para exigir a nova apresentação, use `MinVersion="2.3.0"` com Stable depois da publicação. Os artefatos históricos 2.0.0, 2.1.0 e 2.2.0 permanecem imutáveis.

**Publicação bloqueada:** nesta entrega, o GitHub retornou HTTP 403 com `Your account was suspended` para ambos os repositórios. Este é um pacote local completo e testado; não foi enviado ao GitHub. Os canais contidos no pacote apontam para 2.3.0, mas os canais públicos não foram atualizados. Restaure/publique o repositório antes de exigir essa versão no loader remoto.

Veja [SCRIPT-HUB.md](SCRIPT-HUB.md), [VALIDATION.md](VALIDATION.md) e [native-hub-launcher.lua](../examples/native-hub-launcher.lua).
