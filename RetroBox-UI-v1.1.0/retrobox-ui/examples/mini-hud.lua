-- RetroBox 2.2: the same State feeds a StatCard and its compact view.
local RetroBox=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.2.0'})
local window=RetroBox:CreateWindow({Id='mini-hud-demo',Title='RetroBox / Mini HUD',Subtitle='Dados visíveis com o menu oculto',Locale='pt-BR'})
local section=window:CreateTab({Title='Sessão',Icon='grid'}):CreateSection('Dados simulados')
local money=window:CreateState(1250)
local hud=window:CreateHUD({Id='session',Title='Sessão',Position=Vector2.new(.03,.2),Width=280})
local card=section:AddStatCard({Id='money',Title='Dinheiro',State=money,TwoWay=false,Format='Compact',Unit='$',Icon='money',Pinnable={HUD=hud}})
card:PinToHUD(hud)
local progress=window:CreateState(35)
hud:AddProgress({Id='progress',Title='Progresso',State=progress,Format='Percent',Icon='diamond'})
local timer=hud:AddTimer({Id='time',Title='Tempo da sessão'})
local job=window:CreateTask({Id='simulation',Interval=1,Callback=function()
    money:Update(function(value) return value+25 end)
    progress:Update(function(value) return (value+5)%101 end)
end})
hud:AddTask({Id='status',Title='Simulação',Task=job})
section:AddToggle({Id='simulate',Title='Simular dados',Default=false,Callback=function(enabled)
    if enabled then job:Start(); timer:Start() else job:Stop(); timer:Pause() end
end})
section:AddButton({Title='Mostrar Mini HUD',Callback=function() hud:SetVisible(true) end})
section:AddButton({Title='Ocultar menu',Callback=function() window:Hide() end})
-- The title bar drags; ::/L locks it, +/- collapses it, X only hides the HUD.
-- Profiles save its position, visibility, scale, opacity, orientation and pins.
return window,hud
