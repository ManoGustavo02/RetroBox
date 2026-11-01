-- RetroBox 2.11 refined controls. Local demonstration values only.
local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.11.0'})
assert(Library.APIVersion==2,'RetroBox API 2 is required')
local window=Library:CreateWindow({Id='refined-controls',Title='RetroBox · componentes refinados',Subtitle='Segmented, Range, Number, Callout e CodeBlock',Theme='Hacker'})
local tab=window:CreateTab({Title='Componentes',Icon='sliders'})
local section=tab:CreateSection({Title='Escolhas e valores',Icon='settings'})
section:AddCallout({Title='Modo educativo',Content='Os valores abaixo só alteram esta interface. Nenhuma lógica de jogo é executada.',Kind='Tip'})
local mode=section:AddSegmented({Id='mode',Title='Modo de seleção',Options={'Próximo','Aleatório','Menor vida'},Default='Próximo',
    Callback=function(value) window:Notify({Title='Modo',Content='Selecionado: '..value}) end})
local range=section:AddRangeSlider({Id='delay',Title='Intervalo aleatório',Description='Mínimo e máximo, em segundos.',Min=0,Max=5,Step=.1,MinGap=.2,Default={Min=.5,Max=1.5},Suffix='s'})
local amount=section:AddNumber({Id='amount',Title='Quantidade',Min=1,Max=50,Step=1,Default=5,Suffix=' un.'})
local code=tab:CreateSection({Title='Snippet',Icon='code'}):AddCodeBlock({Id='snippet',Title='Valores atuais',Language='lua',Height=110})
local function refresh()
    local low,high=range:GetRange()
    code:SetCode(string.format('local mode = %q\nlocal delay = {%.1f, %.1f}\nlocal amount = %d',mode:GetValue(),low,high,amount:GetValue()))
end
for _,control in ipairs({mode,range,amount}) do control:OnChanged(refresh) end
refresh()
