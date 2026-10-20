local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.5.0'})
local window=Library:CreateWindow({Id='card-grid',Title='Catálogo de ferramentas',Theme='Hacker'})
local section=window:CreateTab({Title='Ferramentas',Icon='grid'}):CreateSection('Escolha uma ferramenta')
local items={}
for i=1,1000 do items[i]={Id='tool-'..i,Title='Ferramenta '..i,Description='Card de demonstração com pool reciclado.',Icon='settings',Category=i%2==0 and 'Utilitários' or 'Dados',Badges={'Demo'}} end
section:AddCardGrid({Id='tools',Items=items,Height=320,Searchable=true,OnActivate=function(item)
    window:Notify({Title=item.Title,Content='Seleção explícita: '..item.Id})
end})
