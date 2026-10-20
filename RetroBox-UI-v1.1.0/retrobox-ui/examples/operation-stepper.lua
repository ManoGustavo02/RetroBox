-- A Stepper observes a real cancellable operation; no duplicate scheduler.
local RetroBox=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.2.0'})
local window=RetroBox:CreateWindow({Id='stepper-demo',Title='RetroBox / Etapas',Locale='pt-BR'})
local section=window:CreateTab({Title='Operação',Icon='tools'}):CreateSection('Etapas')
local steps={{Id='search',Title='Buscar'},{Id='prepare',Title='Preparar'},{Id='run',Title='Executar'},{Id='check',Title='Confirmar'}}
local stepper=section:AddStepper({Id='steps',Title='Operação local',Steps=steps,Pinnable=true})
local action
local start=section:AddButton({Id='start',Title='Iniciar',Callback=function()
    if action and not action.Finished then return end
    action=window:RunAction({Group='demo',Policy='Reject',Callback=function(ctx)
        for index,step in ipairs(steps) do
            ctx:ThrowIfCancelled(); ctx:Wait(.5); ctx:SetProgress(index,#steps,step.Title)
        end
        return 'Concluído'
    end})
    if action then stepper:BindAction(action) end
end})
local cancel=section:AddButton({Id='cancel',Title='Cancelar',Callback=function() if action and not action.Finished then action:Cancel('Cancelado pelo usuário') end end})
local bar=window:CreateActionBar({Id='operation',Title='Operação',Width=330,Position=Vector2.new(.03,.7)})
bar:AddAction({Control=start,Text='Iniciar'}); bar:AddAction({Control=cancel,Text='Cancelar'})
stepper:PinToHUD()
return window,stepper
