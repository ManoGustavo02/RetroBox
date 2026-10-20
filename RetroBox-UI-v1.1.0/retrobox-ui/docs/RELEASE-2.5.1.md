# RetroBox 2.5.1 — avaliação eficiente de grafos

Inclui todos os recursos da [2.5.0](RELEASE-2.5.md): Designer HTML, blocos, exportação Luau/JSON, idiomas, formulários, componentes reutilizáveis, CardGrid e diagnóstico.

Um grafo acíclico pode reutilizar a mesma saída em várias entradas. A avaliação anterior recalculava cada subexpressão por caminho: 12 duplicações fizeram 4.097 leituras do controle de origem, incluindo a inicialização. O evaluator agora usa cache local durante a avaliação de uma entrada, compartilhado pela expressão inteira. O mesmo caso faz duas leituras totais.

O cache é novo em cada leitura de entrada; não sobrevive a alterações de valores, bindings ou ações. Isso preserva o resultado após SetValue e evita valores obsoletos. Não houve mudança de API ou formato JSON. A prévia usa a mesma estratégia e compara registros independentemente da ordem das chaves.

Há regressões com 28 operações compartilhadas tanto no runtime quanto no simulador, verificando o número constante de leituras e os valores depois de uma alteração. Os pins publicados, incluindo 2.5.0, permanecem imutáveis. Stable/Preview passam a 2.5.1.

O Designer exporta com MinVersion 2.5.1. Projetos JSON da família 2.5 continuam compatíveis e podem ser reabertos. Veja [VALIDATION.md](VALIDATION.md), [guia do Designer](../../../designer/README.md) e [relatório de publicação](../../../docs/PREPARATION-REPORT.md).
