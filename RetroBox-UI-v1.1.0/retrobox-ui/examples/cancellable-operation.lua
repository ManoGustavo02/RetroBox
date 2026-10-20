-- Generic operation with local simulated input and effects. No game remotes.
local RetroBox=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.1.0'})
local window=RetroBox:CreateWindow({Id='cancellable-operation',Title='RetroBox / Operação cancelável',Subtitle='Buscar → Calcular → Animar → Executar → Confirmar → Limpar',Locale='pt-BR'})
local scope=window:CreateScope()
local stage=window:CreateState('Aguardando')
local status=window:CreateState('Inativa')
local progress=window:CreateState(0)
local result=window:CreateState('Nenhum resultado')
local elapsed=window:CreateState(0)
local demo={Window=window,Stage=stage,Status=status,Progress=progress,Result=result,Stats={Executed=0,Confirmed=0,Cleaned=0},Generation=0}
local section=window:CreateTab({Title='Operação',Icon='tools'}):CreateSection({Title='Processamento em etapas',Icon='refresh'})
section:AddLabel({Title='Etapa atual',State=stage,TwoWay=false})
section:AddLabel({Title='Estado real',State=status,TwoWay=false})
section:AddProgressChart({Title='Progresso',State=progress,TwoWay=false})
section:AddLabel({Title='Resultado',State=result,TwoWay=false})
section:AddStatCard({Title='Tempo decorrido',State=elapsed,TwoWay=false,Precision=2,Unit='s'})
local startingAt=0
local clock=window:CreateTask({Id='operation-clock',Interval=.25,Callback=function(ctx)
    ctx:ThrowIfCancelled(); elapsed:Set(math.max(0,os.clock()-startingAt))
end})
scope:Add(clock,'Destroy')
demo.Steps={
    {Name='Buscar',Run=function(ctx,run)
        local lookup=assert(window:RunAction({Group='operation-lookup',Policy='Reject',Callback=function(child)
            child:Wait(.2); return {2,4,6,8}
        end}))
        ctx:Manage(lookup,'Cancel')
        local ok,value=ctx:AwaitAction(lookup,{Timeout=3,CancelAction=true})
        if not ok then ctx:ThrowIfCancelled(); error(tostring(value)) end
        run.Values=value
    end},
    {Name='Calcular',Run=function(ctx,run)
        run.Total=0
        for _,value in ipairs(run.Values) do ctx:ThrowIfCancelled(); run.Total=run.Total+value end
        ctx:Wait(.1)
    end},
    {Name='Animar',Run=function(ctx,run)
        local tween=game:GetService('TweenService'):Create(run.Preview,TweenInfo.new(.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(.6,0,1,-30)})
        run.Scope:Add(function() tween:Cancel(); tween:Destroy() end)
        tween:Play(); ctx:Wait(.3)
    end},
    {Name='Executar',Run=function(ctx,run)
        ctx:ThrowIfCancelled(); run.Executed=run.Total; demo.Stats.Executed=demo.Stats.Executed+1
        ctx:Wait(.1)
    end},
    {Name='Confirmar',Run=function(ctx,run)
        ctx:Wait(.1); assert(run.Executed==run.Total,'O resultado não foi confirmado')
        demo.Stats.Confirmed=demo.Stats.Confirmed+1; result:Set('Total confirmado: '..run.Total)
    end},
    {Name='Limpar',Run=function(ctx,run)
        ctx:ThrowIfCancelled(); run.Scope:Destroy()
    end},
}
local startButton,cancelButton
function demo:Start()
    if window.Destroyed then return nil,'Janela encerrada' end
    if self.Action and not self.Action.Finished then return nil,'Já existe uma operação em andamento' end
    self.Generation=self.Generation+1; local generation=self.Generation
    startingAt=os.clock(); progress:Set(0); elapsed:Set(0); result:Set('Processando'); status:Set('Executando')
    startButton:SetDisabled(true); cancelButton:SetDisabled(false)
    local action,reason=window:RunAction({Group='operation',Policy='Reject',Callback=function(ctx)
        self.Action=ctx.Action
        local temporary=window:CreateScope(); ctx:Manage(temporary,'Destroy')
        local run={Scope=temporary}
        temporary:Add(function() demo.Stats.Cleaned=demo.Stats.Cleaned+1 end)
        local preview=Instance.new('Frame'); preview.Name='OperationPreview'; preview.Size=UDim2.fromOffset(20,20)
        preview.Position=UDim2.new(.1,0,1,-30); preview.BackgroundColor3=window.Palette.Accent; preview.ZIndex=20; preview.Parent=window.Root
        temporary:Add(preview); run.Preview=preview
        for index,step in ipairs(self.Steps) do
            ctx:ThrowIfCancelled(); stage:Set(step.Name); ctx:ThrowIfCancelled()
            step.Run(ctx,run); ctx:ThrowIfCancelled(); ctx:SetProgress(index,#self.Steps,step.Name)
        end
        return {Total=run.Total}
    end,OnProgress=function(value,handle)
        if not window.Destroyed and generation==demo.Generation and not handle.Context:IsCancelled() then progress:Set(value.Progress*100) end
    end,OnComplete=function(handle)
        if window.Destroyed or generation~=demo.Generation then return end
        clock:Stop('operation settled'); elapsed:Set(math.max(0,os.clock()-startingAt))
        local final=handle:GetStatus().Status
        status:Set(final); if final=='Completed' then progress:Set(100)
        elseif final=='Failed' then result:Set('Falhou: '..tostring(handle.Error))
        else result:Set('Cancelada; recursos temporários liberados') end
        startButton:SetDisabled(false); cancelButton:SetDisabled(true)
    end})
    self.Action=action
    if not action then
        status:Set('Failed'); result:Set(tostring(reason)); startButton:SetDisabled(false); cancelButton:SetDisabled(true)
        return nil,reason
    end
    if not action.Finished then clock:Start() end
    return action
end
function demo:Cancel()
    if not self.Action or self.Action.Finished then return false end
    status:Set('Cancelamento solicitado'); self.Action:Cancel('Cancelado pelo usuário'); return true
end
startButton=section:AddButton({Id='operation-start',Title='Iniciar operação',Icon='play',Callback=function() return demo:Start()~=nil end})
cancelButton=section:AddButton({Id='operation-cancel',Title='Cancelar',Icon='close',Disabled=true,Callback=function() return demo:Cancel() end})
demo.StartButton=startButton; demo.CancelButton=cancelButton
section:AddLabel({Title='Cancelamento cooperativo',Description='Os recursos são limpos ao solicitar cancelamento. O estado só vira Cancelled quando o callback termina. Efeitos externos já concluídos exigem compensação própria.'})
return window,demo
