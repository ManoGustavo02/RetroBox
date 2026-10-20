-- Universal scripts are a separate native catalog, with no PlaceId or teleport.
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.4.0'})
local hub=Library:CreateScriptHub({
    Id='universal-demo',Title='Universal scripts',Theme='Hacker',Games={},
    UniversalScripts={{
        Id='local-notice',Name='Aviso universal',Description='Mostra uma notificação local sem depender de um jogo específico.',Icon='code',
        Callback=function(ctx,activeHub,script)
            ctx:ThrowIfCancelled();activeHub.Window:Notify({Title=script.Name,Content='Categoria Universal pronta.'});return true
        end,
        -- To load your Pastefy source, replace Callback with URL = your raw HTTPS link.
        -- Use either URL or Callback, not both. A missing Id is generated from Name.
    }},
})
hub:SelectUniversalScripts()
return hub
