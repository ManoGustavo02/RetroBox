local RetroBox=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.1.0'})
local environment=_G
if type(getgenv)=='function' then local ok,value=pcall(getgenv); if ok and type(value)=='table' then environment=value end end
local key='__RetroBoxSessionSnapshotDemo'; local previous=rawget(environment,key); local snapshot
if type(previous)=='table' then
    snapshot=previous.Snapshot
    if previous.Window and not previous.Window.Destroyed then
        snapshot=previous.Window:CreateSessionSnapshot() or snapshot
        previous.Window:Destroy()
    end
end
local window=RetroBox:CreateWindow({Id='session-snapshot-demo',Title='RetroBox / Snapshot da sessão',Locale='pt-BR'})
local counter=window:CreateState(0,{Name='counter'}); window:RegisterSessionState('counter',counter)
local section=window:CreateTab({Title='Sessão',Icon='clock'}):CreateSection({Title='Contador transitório'})
section:AddStatCard({Title='Contador',State=counter,TwoWay=false,Icon='coins'})
section:AddButton({Title='Adicionar 1',Callback=function() counter:Update(function(value) return value+1 end) end})
local saved={Window=window,Snapshot=snapshot}; environment[key]=saved
section:AddButton({Title='Capturar snapshot e fechar',Icon='save',Callback=function()
    local value,reason=window:CreateSessionSnapshot()
    if not value then return false,reason end
    saved.Snapshot=value; window:Destroy(); return true
end})
if snapshot then
    local ok,reason=window:RestoreSessionSnapshot(snapshot)
    if not ok then window:Notify({Title='Snapshot incompatível',Content=tostring(reason),Kind='warning'}) end
end
-- This explicit shared table is optional. Isolated executor environments cannot
-- transfer state automatically. Snapshots are not written to profiles or files.
return window
