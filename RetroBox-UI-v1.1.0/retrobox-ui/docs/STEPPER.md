# Visualizador de etapas · 2.2.0

`section:AddStepper({Id?,Title?,Description?,Steps,Height?,Pinnable?,State?,...}) -> control`. Até 32 etapas, array denso, mínimo 1. Cada etapa é `{Id="search",Title="Buscar"}` com Id único de 1–64 bytes e Title até 256 bytes. Strings simples também são aceitas e recebem IDs `step-1`, `step-2` etc. Use IDs explícitos se for alterar as etapas manualmente. Height 100–1800, padrão calculado até 440; listas longas rolam.

O componente observa operações existentes; não cria fluxo de execução, scheduler, callbacks de etapas ou políticas de cancelamento.

```lua
local steps=section:AddStepper({Id="operation",Title="Operação",
    Steps={{Id="search",Title="Buscar"},{Id="prepare",Title="Preparar"},
           {Id="run",Title="Executar"},{Id="check",Title="Confirmar"}},Pinnable=true})
steps:SetCurrent("prepare","Preparando dados")
steps:SetStep("prepare","Error","Entrada inválida")
steps:Reset()
-- steps:BindAction(action) acompanha uma RunAction real.
```

- `GetSteps()` / `GetValue()` retornam cópia de `{Id,Status,Message}` por etapa, na ordem declarada.
- `SetValue(array,true?)` valida tamanho, ordem/IDs, Status e Message. Message até 2048 bytes. Status: Pending, Running, Completed, Error, Cancelled.
- `SetStep(id,status,message?)` altera uma etapa.
- `SetCurrent(id,message?)` conclui as anteriores, coloca a escolhida em Running e as seguintes em Pending.
- `Complete(message?)` conclui todas; mensagem fica na última.
- `Reset()` devolve todas a Pending.
- `GetSummary()` retorna título/estado da etapa atual ou N/Total concluídas.
- `BindAction(action)` / `UnbindAction()` observam Status de uma ação da mesma janela. Rebinding desconecta a anterior; não cancela nem repete a operação.
- `PinToHUD(hud?,options?)` mostra o resumo no Mini HUD; `Pinnable` oferece Fixar/Soltar.

BindAction interpreta `ctx:SetProgress(step,total,message)` como quantidade de etapas concluídas. Use o mesmo total de Steps. As anteriores ficam Completed e a próxima Running; Completed conclui tudo, Failed marca Error na atual e Cancelled marca Cancelled. A operação continua responsável por chamar ThrowIfCancelled/Wait/AwaitAction e liberar seus scopes. Nenhuma espera é cancelada pelo visualizador por conta própria.

State opcional alimenta os mesmos registros em uma via com o binding existente. Para usar BindAction, prefira não manter um State concorrente alterando o mesmo valor. Ícones/status usam a paleta existente e as mesmas linhas são reaproveitadas entre atualizações/temas. Destruição limpa assinaturas/linhas e não altera callbacks de outras operações.

Veja [operation-stepper.lua](../examples/operation-stepper.lua) para iniciar/cancelar com barra compacta e resumo fixado; [cancellable-operation.lua](../examples/cancellable-operation.lua) para o fluxo de seis etapas da 2.1.
