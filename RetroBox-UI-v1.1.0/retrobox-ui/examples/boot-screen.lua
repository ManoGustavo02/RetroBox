-- RetroBox 2.12 boot screen. Local demonstration only; no gameplay logic.
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.12.0'})
assert(Library.APIVersion==2,'RetroBox API 2 is required')
local window=Library:CreateWindow({
    Id='boot-screen-demo',Title='Meu Script',Subtitle='Demonstração da tela de boot',Theme='Hacker',
    LoadingScreen={
        Duration=2.4,
        Steps={'Conectando à library','Lendo preferências locais','Montando a interface','Tudo pronto'},
        OnComplete=function(skipped) print(skipped and 'Boot pulado' or 'Boot concluído') end,
    },
})
local section=window:CreateTab({Title='Início',Icon='home'}):CreateSection({Title='Boot',Icon='rocket'})
section:AddCallout({Title='Tela de inicialização',Content='Ela aparece ao executar o script, sem atrasar sua lógica. Clique, Enter, Espaço ou Esc pulam a sequência.',Kind='Info'})
section:AddSegmented({Id='boot-duration',Title='Duração da prévia',Options={'Curta','Normal','Longa'},Default='Normal'})
section:AddButton({Id='replay-boot',Title='Ver de novo',Icon='refresh',Callback=function()
    local durations={Curta=1.2,Normal=2,Longa=3.5}
    window:ShowBootScreen({Duration=durations[window:GetFlag('boot-duration')],Subtitle='Replay manual'})
end})
