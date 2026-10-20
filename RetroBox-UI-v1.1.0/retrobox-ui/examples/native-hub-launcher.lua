-- The launcher is native to RetroBox; no presentation adapter is installed here.
-- The permanent API 2 bootstrap resolves the compatible release from the new account.
local Library=loadstring(game:HttpGet("https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua"))({Channel="stable",MinVersion="2.3.1"})
local hub=Library:CreateScriptHub({
    Id="native-launcher-demo",Title="Meu Hub",Theme="Hacker",Locale="pt-BR",
    ConfigFolder="RetroBox/NativeLauncherDemo",AutoDetectGame=true,ConfirmTeleport=true,
    Games={{Id="current",PlaceId=game.PlaceId>0 and game.PlaceId or nil,
        UniverseId=game.GameId>0 and game.GameId or nil,
        -- No manual Name or Description: Roblox can fill both fields.
        FallbackName="Jogo desta sessão",Notes="Este exemplo executa somente uma notificação local.",
        Scripts={{Id="notice",Title="Mostrar aviso",Description="Uma ação local cadastrada pelo desenvolvedor.",Icon="info",Author="Developer",Version="1.0",
            Callback=function(ctx,activeHub)
                ctx:ThrowIfCancelled(); activeHub.Window:Notify({Content="Launcher nativo pronto!"}); return true
            end}},
    }},
})
hub:SetCatalogFilter("All")
hub:Show()
return hub
