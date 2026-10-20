return function(Mock,Library,test)
    local function fixture() return Library:CreateWindow({Id='profiler',FileStorage=false,Settings=false,ReducedMotion=true,ErrorNotifications=false}) end
    local function tick(dt) Mock.pump(dt or 0); Mock.Services.RunService.RenderStepped:Fire(dt or .01); Mock.pump() end
    local function finish(w) w:Destroy(); Mock.pump(100); Mock.YieldingTasks=false; Mock.Warnings={}; assert(Mock.Connections==0) end
    local function close(a,b) assert(math.abs(a-b)<1e-7,tostring(a)..' ~= '..tostring(b)) end
    test('profiler records fast executions and cumulative durations without changing restart behavior',function()
        local w=fixture(); local calls=0
        local job=w:CreateTask({Id='fast',Interval=.5,Once=true,Callback=function() calls=calls+1; Mock.Time=Mock.Time+.1; return calls end})
        for i=1,3 do job:Start(); tick() end
        local p=job:GetStatus().Profile
        assert(calls==3 and p.Attempts==3 and p.Executions==3 and p.Completed==3)
        close(p.LastElapsed,.1); close(p.AverageElapsed,.1); close(p.TotalElapsed,.3); close(p.MinElapsed,.1); close(p.MaxElapsed,.1)
        assert(not p.LastSlow and p.SlowExecutions==0); finish(w)
    end)
    test('profiler flags slow tasks in the existing inspector without changing the interval',function()
        local w=fixture(); local job=w:CreateTask({Id='slow',Interval=.5,Once=true,Start=true,Callback=function(ctx) ctx:Wait(1.7) end})
        tick(); local p=job:GetStatus().Profile; assert(p.LastSlow and p.SlowExecutions==1 and job.Interval==.5)
        close(p.LastElapsed,1.7); close(p.LastInstrumentedWait,1.7)
        local inspector=w:OpenRuntimeInspector(); inspector:Refresh(); local found
        for _,row in ipairs(inspector.Snapshot.Tasks) do if row.Id=='slow' then found=row end end
        assert(found and found.Warning~='' and found.Profile.LastSlow); finish(w)
    end)
    test('profiler separates requested cancellation from a completed cancelled callback',function()
        Mock.YieldingTasks=true; local w=fixture()
        local job=w:CreateTask({Id='cancel',Interval=.1,Start=true,Callback=function(ctx) ctx:Wait(1) end})
        tick(); job:Stop('test'); job:Stop('again')
        assert(job:GetStatus().Profile.CancelRequests==1 and job:GetStatus().Profile.Cancelled==0 and job.InFlight)
        tick(1); assert(job:GetStatus().Profile.Cancelled==1 and not job.InFlight); finish(w)
    end)
    test('profiler records grouped skips without fabricating callback executions or durations',function()
        Mock.YieldingTasks=true; local w=fixture()
        w:RunAction({Group='shared',Callback=function(ctx) ctx:Wait(1) end}); Mock.pump()
        local job=w:CreateTask({Id='skip',Group='shared',Policy='Ignore',Interval=.5,Once=true,Start=true,Callback=function() error('must not run') end})
        tick(); local p=job:GetStatus().Profile; assert(p.Attempts==1 and p.Executions==0 and p.Skipped==1 and p.Samples==0)
        assert(p.History[1].Outcome=='Skipped'); finish(w)
    end)
    test('profiler counts failures for tasks and actions and keeps scheduler outcomes unchanged',function()
        local w=fixture(); local job=w:CreateTask({Id='error',Start=true,Callback=function() error('expected failure') end})
        tick(); assert(job:GetStatus().Profile.Failures==1 and job.LastOutcome=='Failed' and not job.Requested)
        local action=w:RunAction({Id='failed-action',Callback=function() return false,'declined' end}); Mock.pump()
        assert(action:GetStatus().Profile.Failures==1 and action:GetStatus().Status=='Failed'); finish(w)
    end)
    test('profiler measures instrumented waits and leaves raw task.wait time unattributed',function()
        local w=fixture(); local action=w:RunAction({Callback=function(ctx) ctx:Wait(.2); task.wait(.3) end}); Mock.pump()
        local p=action:GetStatus().Profile; close(p.LastElapsed,.5); close(p.LastInstrumentedWait,.2); close(p.LastUnattributedElapsed,.3)
        assert(p.CPUTime==nil and p.ActiveTime==nil); finish(w)
    end)
    test('profiler measures AwaitAction and grouped tasks without changing execution order',function()
        Mock.YieldingTasks=true; local w=fixture(); local calls=0
        local parent=w:RunAction({Group='parent',Callback=function(ctx)
            local child=w:RunAction({Group='child',Callback=function(inner) inner:Wait(.5); calls=calls+1 end})
            local ok=ctx:AwaitAction(child); assert(ok); calls=calls+1
        end})
        Mock.pump(); tick(.5); assert(parent.Finished and calls==2)
        close(parent:GetStatus().Profile.LastInstrumentedWait,.5)
        local job=w:CreateTask({Id='grouped',Group='work',Once=true,Start=true,Callback=function(ctx) ctx:Wait(.2); calls=calls+1 end})
        tick(); tick(.2); assert(job:GetStatus().Profile.Completed==1 and calls==3)
        close(job:GetStatus().Profile.LastInstrumentedWait,.2); finish(w)
    end)
    test('profiler history and returned snapshots stay bounded and independent of live counters',function()
        local w=fixture(); local job=w:CreateTask({Id='many',Once=true,Callback=function() end})
        for i=1,24 do job:Start(); tick() end
        local p=job:GetStatus().Profile; assert(#p.History==16 and p.Executions==24)
        p.Executions=999; assert(job:GetStatus().Profile.Executions==24)
        local snapshot=w:GetRuntimeSnapshot(); snapshot.Tasks[1].Profile.History[1].Outcome='mutated'
        assert(job:GetStatus().Profile.History[1].Outcome=='Completed'); finish(w)
    end)
end
