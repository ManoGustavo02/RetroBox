-- RetroBox API 2: library-wide updates, optional script feed and reviewed diagnostic reports.
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({
    Channel='stable',MinVersion='2.9.0',
})
assert(type(Library)=='table' and Library.APIVersion==2,'RetroBox API 2 required')
local window=Library:CreateWindow({
    Id='updates-diagnostics-demo',Title='Meu script',Theme='Hacker',Locale='auto',
    ScriptUpdates={{
        Id='script-1.0.0',Version='1.0.0',Date='2026-10-27',
        Title={['pt-BR']='Primeira versão',['en-US']='First release'},
        Description={['pt-BR']='Interface, novidades e relatos de problema.',['en-US']='Interface, updates and bug reports.'},
    }},
})
local main=window:CreateTab({Title='Principal'})
local section=main:CreateSection({Title='Ajuda e novidades',Icon='info'})
section:AddButton({Id='show-script-updates',Title='Novidades deste script',Callback=function() window:OpenUpdates('Script') end})
section:AddButton({Id='show-library-updates',Title='Novidades da RetroBox',Callback=function() window:OpenUpdates('Library') end})
local feedback=window:CreateFeedbackHub({
    Id='feedback',WebhookURL='', -- configure in the consumer; empty keeps submission disabled.
    Categories={'ScriptRequest','Suggestion','Feedback','BugReport'},
    Diagnostics=true,ScriptVersion='1.0.0',Game='current',
})
-- Opening or editing does not post, import console history or enable capture.
-- The user chooses whether to attach diagnostics and reviews them before sending.
main:Select()
return window,feedback
