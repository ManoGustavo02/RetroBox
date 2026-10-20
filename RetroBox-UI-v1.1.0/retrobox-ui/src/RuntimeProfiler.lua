-- Constant-cost counters and at most 16 settlement records per task/action.
-- Elapsed time is wall-clock time. Unattributed time is never labelled CPU time.
local function newRuntimeProfile()
    return {Attempts=0,Executions=0,Completed=0,Failures=0,Cancelled=0,CancelRequests=0,Skipped=0,
        Samples=0,LastElapsed=0,AverageElapsed=0,MinElapsed=0,MaxElapsed=0,TotalElapsed=0,
        LastInstrumentedWait=0,TotalInstrumentedWait=0,LastUnattributedElapsed=0,
        SlowExecutions=0,LastSlow=false,History={}}
end
local function beginRuntimeProfile(profile,context)
    profile.Executions=profile.Executions+1; context._profileWait=0; return os.clock()
end
local function finishRuntimeProfile(profile,started,context,outcome,interval)
    if outcome=='Completed' then profile.Completed=profile.Completed+1
    elseif outcome=='Cancelled' then profile.Cancelled=profile.Cancelled+1
    elseif outcome=='Skipped' then profile.Skipped=profile.Skipped+1
    elseif outcome=='Failed' or outcome=='Rejected' then profile.Failures=profile.Failures+1 end
    local elapsed,waiting
    if started then
        elapsed=math.max(0,os.clock()-started); waiting=math.min(elapsed,context and context._profileWait or 0)
        profile.Samples=profile.Samples+1; profile.LastElapsed=elapsed
        profile.TotalElapsed=profile.TotalElapsed+elapsed; profile.AverageElapsed=profile.TotalElapsed/profile.Samples
        profile.MinElapsed=profile.Samples==1 and elapsed or math.min(profile.MinElapsed,elapsed)
        profile.MaxElapsed=math.max(profile.MaxElapsed,elapsed)
        profile.LastInstrumentedWait=waiting; profile.TotalInstrumentedWait=profile.TotalInstrumentedWait+waiting
        profile.LastUnattributedElapsed=math.max(0,elapsed-waiting)
        profile.LastSlow=interval~=nil and elapsed>interval or false
        if profile.LastSlow then profile.SlowExecutions=profile.SlowExecutions+1 end
    end
    profile.History[#profile.History+1]={Outcome=outcome,StartedAt=started,FinishedAt=os.clock(),Elapsed=elapsed,InstrumentedWait=waiting}
    while #profile.History>16 do table.remove(profile.History,1) end
end
