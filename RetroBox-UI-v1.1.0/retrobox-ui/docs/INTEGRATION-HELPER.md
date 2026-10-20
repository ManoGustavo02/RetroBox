# Helper opcional de integração — 2.1.0

`Library:CreateIntegration(options)` reduz a repetição na montagem e limpeza de uma janela. Não altera a instalação da library nem substitui CallbackExecutor, CreateWindow, scopes ou perfis.

```lua
local integration,reason=RetroBox:CreateIntegration({
    Window={Id="integration",Title="Meu script"},
    Required={"HttpGet","loadstring"},
    Initialize=function(owner)
        local section=owner.Window:CreateTab("Principal"):CreateSection("Controles")
        section:AddLabel({Title="Pronto"})
        owner:Manage(function() -- limpeza dos recursos do desenvolvedor
        end)
    end,
})
assert(integration,reason)
```

Opções: Window (CreateWindow options), Required (até 16 capacidades), CallbackExecutor, Initialize e OnError. CallbackExecutor fornecido diretamente tem prioridade sobre Window.CallbackExecutor e é repassado sem modificação. Sua assinatura continua `(callback,args,context)`.

O controller contém Window, Scope, Capabilities e Destroyed. `Manage(resource,method?,key?)` usa seu scope; `Run(callback,...)` usa o tratamento de erros existente e retorna success,...; `Destroy()` encerra a janela e é idempotente. Destruição externa da janela também limpa o controller. Falha na inicialização libera a janela e seus recursos antes de retornar nil,erro. Erros de argumentos inválidos seguem o uso de assert das demais factories.

Capabilities informa a presença de HttpGet, loadstring, readfile, writefile, setclipboard e SharedEnvironment (getgenv). Presença não comprova permissão ou funcionamento de toda operação. Required é verificado antes de criar a janela. Capacidades opcionais não são inventadas nem emuladas.

O helper não seleciona executor, não define identidade de thread, não modifica permissões e não contorna restrições. Sem HTTP/loadstring, o bootstrap ainda depende de um ambiente que realmente os ofereça. Arquivos e ambiente compartilhado são opcionais e continuam com suas limitações reais. OnError usa o diagnóstico existente.

Veja [integration-helper.lua](../examples/integration-helper.lua).
