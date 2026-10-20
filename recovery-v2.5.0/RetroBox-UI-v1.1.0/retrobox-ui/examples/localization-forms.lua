local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.5.0'})
local window=Library:CreateWindow({Id='localization-forms',Title='Configurações',Theme='Hacker',Locale='auto',Translations={
    title={Source='Configurações',Values={['en-US']='Settings'}},
    name={Source='Nome',Values={['en-US']='Name'}},
    saved={Source='Configuração aplicada.',Values={['en-US']='Settings applied.'}},
}})
local section=window:CreateTab({Title='Principal',Icon='settings'}):CreateSection('Preferências')
local form=section:CreateForm({Id='preferences',Title='Configurações',Fields={
    {Id='name',Type='Input',Title='Nome',Default='Dev',Required=true},
    {Id='enabled',Type='Toggle',Title='Ativar recurso',Default=false},
    {Id='amount',Type='Slider',Title='Quantidade',Min=1,Max=100,Default=25},
},OnApply=function(values)
    window:Notify({Content=window:Translate('saved'),Kind='success'})
end})
-- Configure your application from committed values, never from unconfirmed drafts.
form:Manage(form:OnChanged(function(values) print('Applied',values.name,values.enabled,values.amount) end),'Disconnect')
