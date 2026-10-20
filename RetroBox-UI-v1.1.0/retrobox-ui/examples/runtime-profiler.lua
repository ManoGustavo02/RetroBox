local RetroBox=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.1.0'})
local window=RetroBox:CreateWindow({Id='profiler-demo',Title='RetroBox / Profiler por tarefa',Locale='pt-BR'})
local section=window:CreateTab({Title='Demonstração',Icon='clock'}):CreateSection({Title='Tempos e cancelamento'})
local slow=false
local job=window:CreateTask({Id='profiled-work',Interval=.5,Callback=function(ctx)
    ctx:Wait(slow and .8 or .1); return {Slow=slow}
end})
section:AddToggle({Id='slow',Title='Demonstrar intervalo excedido',Callback=function(value) slow=value end})
section:AddButton({Title='Iniciar tarefa',Icon='play',Callback=function() return job:Start() end})
section:AddButton({Title='Parar tarefa',Icon='close',Callback=function() job:Stop('Solicitado pela demonstração') end})
section:AddLabel({Title='Medições',Description='LastElapsed e médias são tempo decorrido. ctx:Wait e ctx:AwaitAction medem espera instrumentada. O restante não é uma medição de CPU.'})
window:OpenRuntimeInspector()
return window
