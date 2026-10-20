local Library=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.5.0'})
local window=Library:CreateWindow({Id='visual-flow',Title='Ligações visuais',Theme='Hacker'})
local section=window:CreateTab('Principal'):CreateSection('Dados e eventos')
local controls={
    amount=section:AddSlider({Id='amount',Title='Quantidade',Min=0,Max=100,Default=25}),
    summary=section:AddLabel({Id='summary',Title='Quantidade: 25'}),
    run=section:AddButton({Id='run',Title='Mostrar aviso'}),
}
window:CreateFlowGraph({Id='demo',Nodes={
    {Id='value',Type='Value',Control='amount'},
    {Id='format',Type='Format',Text='Quantidade: {value}'},
    {Id='binding',Type='Binding',Control='summary',Property='Text'},
    {Id='click',Type='Click',Control='run'},
    {Id='notice',Type='Notify',Title='Demo',Text='Evento visual executado.',Kind='success'},
},Edges={
    {From='value',Out='Value',To='format',Input='Value'},
    {From='format',Out='Value',To='binding',Input='Value'},
    {From='click',Out='Then',To='notice',Input='Execute'},
}},{Controls=controls})
