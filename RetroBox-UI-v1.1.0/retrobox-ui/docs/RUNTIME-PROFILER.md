# Runtime Profiler — 2.1.0

O profiler amplia o Runtime Inspector e o scheduler existentes. Não cria outro inspetor, não altera intervalos/políticas de grupos e não inicia execuções simultâneas. Não adiciona conexão por tarefa ou atualização por frame.

`job:GetStatus().Profile`, `action:GetStatus().Profile` e as entradas Tasks/Actions de `window:GetRuntimeSnapshot()` retornam cópias das métricas.

| Campo | Significado |
| --- | --- |
| Attempts | Iterações admitidas pelo scheduler; uma ação tem uma tentativa. |
| Executions | Callbacks que realmente começaram. Não inclui um Skip de grupo. |
| Completed / Failures / Cancelled / Skipped | Totais de desfechos concluídos; rejeição de grupo conta como falha. |
| CancelRequests | Pedidos de cancelamento emitidos enquanto a execução ainda não havia recebido esse pedido. Não significa que o callback já terminou. |
| Samples | Execuções que terminaram e possuem duração medida. |
| LastElapsed / AverageElapsed / MinElapsed / MaxElapsed | Última, média, mínima e máxima duração, em segundos. |
| TotalElapsed | Soma das durações medidas. |
| LastInstrumentedWait / TotalInstrumentedWait | Espera medida pelos pontos instrumentados do contexto. |
| LastUnattributedElapsed | Parte da última duração que não pertence aos pontos de espera instrumentados. |
| LastSlow / SlowExecutions | Última execução excedeu o intervalo / total de ocorrências. |
| History | Até 16 desfechos, com Outcome, StartedAt, FinishedAt, Elapsed e InstrumentedWait quando houve execução. |

Os contadores acumulam ao parar/reiniciar a mesma tarefa. Destruir a tarefa/ação não reinicia outras tarefas nem seus grupos. Uma tentativa cancelada antes do callback pode ter Cancelled incrementado sem Executions ou Samples. Tarefas agrupadas medem o callback, excluindo a fila anterior ao início dele. O tempo até a retomada do callback está incluído no tempo decorrido.

## Medição e limites

```lua
local job=window:CreateTask({Id="work",Interval=.5,Callback=function(ctx)
    ctx:Wait(.1) -- novo ponto instrumentado, com verificação de cancelamento
    -- cálculo ou operação do desenvolvedor
end})
```

`ctx:Wait(seconds)` aceita 0–86400 segundos, verifica cancelamento antes/depois e mede a espera. `ctx:AwaitAction(handle,options?)` mede o intervalo aguardado, mantendo seus retornos/políticas existentes. A espera é cooperativa; um pedido de cancelamento não interrompe imediatamente task.wait, chamadas externas ou efeitos já concluídos.

`os.clock()` mede tempo decorrido. Chamadas diretas a task.wait, yields e rede não instrumentada não podem ser separadas de modo confiável de trabalho ativo. Portanto LastUnattributedElapsed **não é CPU**, não é tempo ativo exato e não recebe esse rótulo. Não há substituição global de task.wait. Esperas instrumentadas são contadas uma vez no contexto de cada execução; uma ação/tarefa agrupada pode descrever o mesmo trabalho em dois registros independentes, que não devem ser somados como CPU.

Uma tarefa de intervalo .5 s que termina em 1.7 s apresenta LastSlow=true e aviso no mesmo Runtime Inspector. O intervalo continua .5 s e o scheduler continua sem sobreposição. O aviso aparece como dado do inspetor, sem gerar uma sequência de warnings no console.

As tabelas existentes mostram duração e avisos; o botão de detalhes da tarefa inclui o Profile completo. O relógio de atualização do inspetor continua configurável entre .25 e 10 s. Histórico e cópias são limitados; não há coleta de stack a cada frame.

Veja [runtime-profiler.lua](../examples/runtime-profiler.lua) e [cancellable-operation.lua](../examples/cancellable-operation.lua).
