-- Native shared-library showcase. Only demonstration data; no gameplay logic.
local RetroBox=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.7.0'})
local window=RetroBox:CreateWindow({
    Id='appearance-and-rgb',Title='RetroBox · acabamento',Subtitle='RGB, carregamento e perfil próprio do Hub',
    Theme='Hacker',TitleRGB={Speed=.12},Size=Vector2.new(1000,740),
})
local tab=window:CreateTab({Title='Componentes',Icon='palette'})
local section=tab:CreateSection({Title='Textos e carregamento',Icon='spark'})
local text=section:AddLabel({Title='Texto RGB opcional',Description='A descrição pode ter seu próprio ritmo.',
    RGB={Speed=.15},DescriptionRGB={Speed=.08,Phase=.4}})
local card=section:AddStatCard({Title='Dados de demonstração',Value=125,Unit='pts',Icon='diamond'})
card:SetRGB({Speed=.1},'Value')
local skeleton=section:AddSkeleton({Title='Placeholder reutilizável',Lines=3,Height=110})
section:AddToggle({Title='Mostrar placeholder',Default=true,Callback=function(value) skeleton:SetLoading(value) end})
section:AddToggle({Title='Texto em RGB',Default=true,Callback=function(value)
    text:SetRGB(value);text:SetRGB(value,'Description')
end})
section:AddButton({Title='Demonstrar tela de carregamento',Icon='refresh',Callback=function()
    local loading=window:ShowLoading({Title='Demonstração',Message='Preparando amostras locais…',Timeout=10})
    local action=window:RunAction({Group='appearance-demo',Policy='Reject',Callback=function(ctx)
        ctx:Manage(function() if not loading.Finishing then loading:Destroy() end end)
        for step=1,3 do
            ctx:Wait(.3);ctx:ThrowIfCancelled()
            loading:SetMessage('Amostra '..step..' de 3'):SetProgress(step/3)
        end
        card:SetValue(card:GetValue()+25);loading:Finish('Amostras prontas')
        return true
    end})
    if not action then loading:Destroy() end
end})
local hub=window:CreateScriptHub({
    Id='appearance-hub',Title='Hub de demonstração',HubTheme={Theme='Launcher',Accent='#44E784'},
    HubTitleRGB={Speed=.1},
    Games={{Id='demo-game',Name='Catálogo de demonstração',Description='O botão Tema abre o perfil exclusivo deste Hub.',PlaceId=game.PlaceId,
        Scripts={{Id='local-demo',Title='Ação local de exemplo',Description='Mostra uma notificação. Não baixa nem executa código remoto.',Icon='info',
            Callback=function() window:Notify({Title='Demonstração',Content='Ação local concluída.'});return true end}}}},
    UniversalScripts={{Id='universal-demo',Name='Exemplo universal',Description='Disponível no catálogo universal, independente do jogo.',
        Callback=function() return 'Demonstração concluída' end}},
})
hub:SetRGB({Speed=.07},'Description')
tab:Select()
return {Window=window,Hub=hub}
