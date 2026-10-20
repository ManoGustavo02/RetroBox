return function(Mock,Library,test)
    local function fixture()
        Mock.YieldingTasks=true; Mock.StrictIconLifecycle=true; Mock.ParentLockErrors=0; Mock.DestroyedIconWrites=0
        loadstring=load; game.HttpGet=Mock.distributionHTTP
        return dofile('examples/cancellable-operation.lua')
    end
    local function tick()
        Mock.pump(.25); Mock.Services.RunService.RenderStepped:Fire(.25); Mock.pump()
    end
    local function settled(handle)
        for _=1,60 do if handle.Finished then return end; tick() end
        error('Operation did not settle')
    end
    local function finish(w)
        w:Destroy(); Mock.pump(100); Mock.YieldingTasks=false; Mock.StrictIconLifecycle=false
        loadstring=nil; game.HttpGet=nil; Mock.Warnings={}
        assert(Mock.Connections==0 and Mock.ParentLockErrors==0 and Mock.DestroyedIconWrites==0)
    end
    for _,name in ipairs({'Buscar','Calcular','Animar','Executar','Confirmar','Limpar'}) do
        test('operation cancels during '..name..' and cleans once without starting later stages',function()
            local w,demo=fixture(); local stages={}
            w:Manage(demo.Stage:Subscribe(function(value) stages[#stages+1]=value; if value==name then demo:Cancel() end end),'Disconnect')
            local action=assert(demo:Start()); settled(action); Mock.pump()
            assert(action:GetStatus().Status=='Cancelled' and stages[#stages]==name and demo.Stats.Cleaned==1)
            assert(not demo.StartButton.Disabled and demo.CancelButton.Disabled and demo.Status:Get()=='Cancelled')
            if name=='Buscar' or name=='Calcular' or name=='Animar' or name=='Executar' then assert(demo.Stats.Executed==0) end
            finish(w)
        end)
    end
    for index,name in ipairs({'Buscar','Calcular','Animar','Executar','Confirmar','Limpar'}) do
        test('operation recovers controls and resources after a failure in '..name,function()
            local w,demo=fixture(); demo.Steps[index].Run=function() error('expected '..name..' failure') end
            local action=assert(demo:Start()); settled(action); Mock.pump()
            assert(action:GetStatus().Status=='Failed' and demo.Stats.Cleaned==1 and demo.Status:Get()=='Failed')
            assert(not demo.StartButton.Disabled and demo.CancelButton.Disabled); finish(w)
        end)
    end
    test('operation completes all six steps with progress result and cleanup',function()
        local w,demo=fixture(); local action=assert(demo:Start()); settled(action); Mock.pump()
        assert(action:GetStatus().Status=='Completed' and action.Result.Total==20)
        assert(demo.Progress:Get()==100 and demo.Stats.Executed==1 and demo.Stats.Confirmed==1 and demo.Stats.Cleaned==1)
        assert(demo.Result:Get()=='Total confirmado: 20' and not demo.StartButton.Disabled); finish(w)
    end)
    test('operation rejects duplicates and restarts after cooperative cancellation',function()
        local w,demo=fixture(); local listener=demo.Stage:Subscribe(function(value) if value=='Calcular' then demo:Cancel() end end)
        local first=assert(demo:Start()); assert(not demo:Start()); settled(first); listener:Disconnect()
        local second=assert(demo:Start()); assert(second~=first); settled(second); Mock.pump()
        assert(second:GetStatus().Status=='Completed' and demo.Stats.Cleaned==2 and demo.Stats.Executed==1); finish(w)
    end)
    test('operation destroys its window while running and leaves no temporary resources or late UI writes',function()
        local w,demo=fixture(); local action=assert(demo:Start()); Mock.pump(); w:Destroy(); settled(action)
        assert(action:GetStatus().Status=='Cancelled' and demo.Stats.Cleaned==1); finish(w)
    end)
    test('operation stage cancellation also works when task.spawn starts immediately',function()
        local w,demo=fixture(); Mock.ImmediateSpawns=true
        w:Manage(demo.Stage:Subscribe(function(value) if value=='Buscar' then demo:Cancel() end end),'Disconnect')
        local action=assert(demo:Start()); settled(action); Mock.pump(); Mock.ImmediateSpawns=false
        assert(action:GetStatus().Status=='Cancelled' and demo.Stats.Cleaned==1); finish(w)
    end)
end
