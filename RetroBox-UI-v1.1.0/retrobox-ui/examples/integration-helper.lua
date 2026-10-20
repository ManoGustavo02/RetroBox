local RetroBox=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.1.0'})
local integration,reason=RetroBox:CreateIntegration({Window={Id='integration-helper-demo',Title='RetroBox / Integração opcional',Locale='pt-BR'},
    Required={},
    -- CallbackExecutor can be supplied by the developer. This helper does not
    -- select an executor API or change thread identity, permissions or security.
    Initialize=function(owner)
        local section=owner.Window:CreateTab({Title='Integração',Icon='tools'}):CreateSection({Title='Capacidades e recursos'})
        section:AddLabel({Title='HTTP e compilação',Description='HttpGet: '..tostring(owner.Capabilities.HttpGet)..' · loadstring: '..tostring(owner.Capabilities.loadstring)})
        local total=owner.Window:CreateState(0)
        section:AddStatCard({Title='Operações locais',State=total,TwoWay=false})
        section:AddButton({Title='Executar operação local',Callback=function()
            return owner:Run(function() total:Update(function(value) return value+1 end) end)
        end})
    end})
assert(integration,reason)
return integration.Window,integration
