# Session Snapshots — 2.1.0

Snapshots guardam estados transitórios selecionados: contadores, estatísticas e resultados locais. Perfis continuam guardando preferências, aparência e controles. Um snapshot não é salvo em arquivo/perfil automaticamente e não transfere tarefas em execução.

```lua
local window=RetroBox:CreateWindow({Id="o-mesmo-id"})
local count=window:CreateState(0,{Name="counter"})
window:RegisterSessionState("counter",count)
local snapshot,reason=window:CreateSessionSnapshot()
-- Capture antes de destruir a janela.
window:Destroy()

local nextWindow=RetroBox:CreateWindow({Id="o-mesmo-id"})
local nextCount=nextWindow:CreateState(0)
nextWindow:RegisterSessionState("counter",nextCount)
local restored,report=nextWindow:RestoreSessionSnapshot(snapshot)
```

Use o mesmo Id nas duas janelas.

| Método | Retorno |
| --- | --- |
| RegisterSessionState(key,state) | A janela. Registra/substitui a chave. |
| UnregisterSessionState(key) | A janela. Não destrói um State externo. |
| CreateSessionSnapshot() | Snapshot independente ou nil,erro. |
| RestoreSessionSnapshot(snapshot) | true,relatório ou false,erro. |

Até 128 chaves, com 1–64 letras/números/pontos/hífens/sublinhados. O State precisa ser gravável e estar vivo, criado pela mesma janela ou ser um State externo sem outra janela proprietária. Estados computados/read-only são rejeitados.

O envelope é `{Kind="RetroBoxSession",SchemaVersion=1,APIVersion=2,WindowId,States}`. Cada entrada é `{Value=...}`, inclusive para preservar valores nil. Kind, schema, API e WindowId são validados. Chaves ausentes não são inventadas: o relatório contém Restored, Missing e Unknown. Entradas não registradas na nova janela são ignoradas e relatadas; estados registrados sem entrada preservam seu valor atual.

Somente dados simples são aceitos: nil, bool, números finitos, strings e tabelas sem metatable. Há limites globais de 8192 valores, 12 níveis, 1024 entradas por tabela e 256 KiB de strings. Funções, Instances, conexões, threads, scopes, ações/tarefas e ciclos são rejeitados. As cópias não conservam referências aos objetos originais.

Todas as entradas e os validators dos estados são conferidos antes da aplicação; validators devem ser puros. A restauração usa Batch e suprime callbacks dos controles. Bindings e observadores de State recebem os novos valores para atualizar a interface; código escrito pelo desenvolvedor nesses observadores continua sob responsabilidade dele. A biblioteca não executa botões, retoma ações nem inicia tarefas por conter esses dados no snapshot.

Destruir a janela solta o registro e seus estados próprios. O snapshot já criado é apenas uma tabela de dados e pode sobreviver no armazenamento compartilhado escolhido pelo desenvolvedor. Sem ambiente compartilhado, não há transferência automática entre execuções isoladas. Não capture somente em OnDestroy: nesse ponto os States já foram limpos; capture antes de chamar Destroy.

Veja [session-snapshots.lua](../examples/session-snapshots.lua), com contador, captura explícita e reexecução.
