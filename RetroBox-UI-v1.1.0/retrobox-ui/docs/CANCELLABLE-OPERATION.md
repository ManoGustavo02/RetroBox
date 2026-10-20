# Operação cancelável em seis etapas — 2.1.0

[cancellable-operation.lua](../examples/cancellable-operation.lua) é uma demonstração completa e genérica: **Buscar → Calcular → Animar → Executar → Confirmar → Limpar**. A entrada é local e simulada; não há remotes, lógica de jogo ou downloads de scripts de terceiros.

A janela oferece iniciar/cancelar, progresso, etapa, estado, tempo decorrido e resultado. O exemplo usa RunAction, CreateTask, CreateScope, ThrowIfCancelled, IsCancelled, Manage, SetProgress, AwaitAction e o novo Wait instrumentado. Todos esses métodos existem na 2.1.0; não há ctx:Sleep ou dependência externa presumida.

A busca usa uma ação filha e aguarda seu handle com timeout. Cálculo, animação e execução consultam cancelamento. Frame e tween temporários pertencem a um scope registrado no contexto. A etapa final e a limpeza do contexto usam o mesmo scope idempotente, portanto o recurso é liberado uma vez.

Um pedido de cancelamento libera recursos temporários e bloqueia as próximas etapas. O estado só muda para Cancelled quando o callback efetivamente termina. Os controles são restaurados no OnComplete, também em falhas. O grupo Reject e a referência do handle impedem duplicação. A tarefa de atualização visual usa .25 s e só fica ativa durante a operação.

Cancelar não desfaz efeitos externos já concluídos: uma integração real precisa definir compensação, confirmação ou transação própria. Nesta demonstração, os efeitos são apenas contadores locais. As funções de Steps são operações do exemplo, não métodos adicionais da library.

Os testes cancelam e provocam falha em cada uma das seis etapas, verificam sucesso, reinicialização, duplicação, destruição da janela e task.spawn imediato. A criação do exemplo não inicia a operação automaticamente.
