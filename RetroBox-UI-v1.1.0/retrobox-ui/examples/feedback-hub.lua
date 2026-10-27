-- Central de Ideias: configure your own Discord webhook before distributing.
-- A webhook in a client script is extractable. Use Transport for a server relay.
local WEBHOOK_URL = '' -- Paste the Discord webhook URL here. Never commit a real token.

local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.8.0'})
local feedback=Library:CreateFeedbackHub({
    Id='feedback-demo',Theme='Hacker',Locale='auto',
    WebhookURL=WEBHOOK_URL,
    -- Optional: ThreadId='your Discord thread ID', for a forum/thread destination.
    Categories={'ScriptRequest','Suggestion','Feedback','BugReport'},
    DefaultCategory='ScriptRequest',Game='current',
    MinLength=10,MaxLength=2000,Cooldown=30,Timeout=20,
    IncludeAvatar=true,ClearOnSuccess=false,
})
-- Opening this screen never sends a message. Sending requires a user's click.
-- Empty URL: screen opens in unconfigured mode; the Submit button is disabled.
-- Existing window: window:CreateFeedbackHub({...}) attaches this same component.
return feedback
