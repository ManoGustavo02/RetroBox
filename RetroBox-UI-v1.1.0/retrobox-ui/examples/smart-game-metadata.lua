local RetroBox=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.1.0'})
local hub=RetroBox:CreateScriptHub({Id='metadata-demo',Title='RetroBox / Metadados do jogo',Locale='pt-BR',
    GameMetadata={CacheTTL=300,FailureTTL=30,MaxConcurrent=2},
    Games={{Id='current',PlaceId=game.PlaceId,Scripts={{Id='example',Title='Exemplo local',Callback=function(ctx)
        ctx:ThrowIfCancelled(); return {Message='A seleção não executa; este callback depende do botão Executar.'}
    end}}}}})
local section=hub.Window:CreateTab({Title='Metadados',Icon='info'}):CreateSection({Title='Consulta assíncrona'})
section:AddButton({Title='Atualizar metadados',Icon='refresh',Callback=function() return hub:RefreshGameMetadata('current') end})
section:AddButton({Title='Ver status',Icon='info',Callback=function()
    local state=hub:GetGameMetadataStatus('current')
    hub.Window:Notify({Title=state.State,Content=state.Error or state.Source or 'Consulta pendente'})
end})
-- A provider can supply experience-level fields from an authorized data source.
-- GameMetadata.Provider(query, official) -> {Name, Description, UniverseId, Image}
-- It cannot supply code or callbacks. Manually filled fields always win.
return hub
