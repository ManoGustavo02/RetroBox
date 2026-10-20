return function(Mock,Library,test)
    local function fixture()
        local w=Library:CreateWindow({Id='preview-tests',Settings=false,FileStorage=false,ReducedMotion=true})
        return w,w:CreateTab({Title='Visual'}):CreateSection('Preview')
    end
    local function finish(w)
        w:Destroy(); Mock.pump(20); assert(Mock.Connections==0,'Leaked '..Mock.Connections..' connections')
        assert(next(w._icons)==nil and next(w.Tasks)==nil)
    end
    local function model()
        local object=Instance.new('Model'); object.Name='Demo'
        local part=Instance.new('Part'); part.Size=Vector3.new(2,4,3); part.CFrame=CFrame.new(4,3,2); part.Parent=object
        local host=Instance.new('AnimationController'); host.Parent=object
        local script=Instance.new('LocalScript'); script.Parent=part
        return object
    end
    test('image preview zoom, rotation, apply and cancel are explicit',function()
        local w,s=fixture(); local applied,cancelled=0,0
        local preview=s:AddPreview({Id='image',Image='rbxassetid://0',OnApply=function(data,owner)
            assert(data.Mode=='Image' and data.Image=='rbxassetid://0' and data.View.Zoom==2 and owner.Id=='image'); applied=applied+1
        end,OnCancel=function(data) assert(data.View.Zoom==1); cancelled=cancelled+1 end})
        assert(applied==0 and cancelled==0)
        preview:SetView({Zoom=2,Yaw=math.pi}); assert(preview.Image.Size.X.Scale==2 and preview.Image.Rotation==180)
        preview:Apply(); Mock.pump(); assert(applied==1); preview:Cancel(); Mock.pump(); assert(cancelled==1 and preview:GetView().Zoom==1)
        local snapshot=preview:GetPreview(); snapshot.View.Zoom=4; assert(preview:GetView().Zoom==1)
        assert(not pcall(preview.SetZoom,preview,0)); finish(w)
    end)
    test('preview content replacement disposes each custom scope once',function()
        local w,s=fixture(); local clean=0; local previous
        local preview=s:AddPreview({Mode='Custom',Render=function(container,scope)
            previous=Instance.new('Frame'); previous.Parent=container
            scope:Add(function() clean=clean+1 end)
        end})
        assert(clean==0); preview:SetImage('rbxassetid://1'); assert(clean==1 and previous._destroyed)
        for i=1,10 do
            assert(preview:SetRenderer(function(container,scope) scope:Add(function() clean=clean+1 end); local f=Instance.new('Frame'); f.Parent=container end))
            preview:SetImage('rbxassetid://2')
        end
        assert(clean==11); finish(w); assert(clean==11)
    end)
    test('model preview clones and sanitizes its source, frames camera and replaces copies',function()
        local w,s=fixture(); local source=model(); local original=source:GetChildren()[1]
        local preview=s:AddPreview({Mode='Model',Model=source})
        local clone=preview.Model
        assert(clone~=source and source.Parent==nil and original:FindFirstChildWhichIsA('LocalScript'))
        assert(not clone:FindFirstChildWhichIsA('LuaSourceContainer',true) and preview.Viewport.CurrentCamera==preview.Camera)
        assert(preview.Camera.CFrame.Target.X==4 and preview.Camera.CFrame.Target.Y==3)
        local distance=preview.Camera.CFrame.Position.Z
        preview:SetZoom(2); assert(preview.Camera.CFrame.Position.Z<distance)
        preview:Rotate(math.pi/2,.2); assert(preview.Camera.CFrame.Position.X>4)
        preview:SetModel(source); assert(clone._destroyed and not source._destroyed)
        source.Archivable=false; local current=preview.Model
        assert(not pcall(preview.SetModel,preview,source) and preview.Model==current and not current._destroyed)
        finish(w); assert(current._destroyed and not source._destroyed); source:Destroy()
    end)
    test('preview animations are opt in and stop before content replacement',function()
        local w,s=fixture(); local source=model(); local preview=s:AddPreview({Model=source})
        local ok,track=preview:PlayAnimation(123,{Looped=true,Speed=.5})
        assert(ok and track.IsPlaying and track.Looped and track.Speed==.5)
        preview:SetImage('rbxassetid://1'); assert(not track.IsPlaying and track._destroyed and preview.AnimationTrack==nil)
        preview:SetModel(source); Mock.AnimationFailure=true
        local success,reason=preview:PlayAnimation('rbxassetid://123'); Mock.AnimationFailure=false
        assert(not success and reason:find('not permitted'))
        finish(w); source:Destroy()
    end)
    test('preview State binding updates image and cleans on destruction',function()
        local w,s=fixture(); local state=w:CreateState('rbxassetid://10')
        local preview=s:AddPreview({State=state}); assert(preview.Image.Image=='rbxassetid://10')
        state:Set('rbxassetid://11'); assert(preview.Image.Image=='rbxassetid://11')
        preview:Destroy(); state:Set('rbxassetid://12'); finish(w)
    end)
    test('preview rejects invalid constructors without leaked controls',function()
        local w,s=fixture()
        assert(not pcall(s.AddPreview,s,{Id='bad',Mode='Model',Model={}}) and not w.Controls.bad)
        assert(not pcall(s.AddPreview,s,{Id='bad',Image='https://example.com/image.png'}) and not w.Controls.bad)
        local source=model(); source.Archivable=false
        assert(not pcall(s.AddPreview,s,{Id='bad',Model=source}) and not w.Controls.bad)
        finish(w); source:Destroy()
    end)
    test('destroyed preview never dispatches queued Apply callbacks',function()
        local w,s=fixture(); local calls=0; local preview=s:AddPreview({OnApply=function() calls=calls+1 end})
        preview:Apply(); preview:Destroy(); Mock.pump(); assert(calls==0); finish(w)
    end)
    for _,deferred in ipairs({false,true}) do
        test('preview parent cleanup '..(deferred and 'deferred' or 'immediate'),function()
            Mock.DeferDestroying=deferred
            local w,s=fixture(); local clean=0
            local preview=s:AddPreview({Mode='Custom',Render=function(_,scope) scope:Add(function() clean=clean+1 end) end})
            preview.Frame:Destroy(); Mock.pump(); preview:Destroy(); assert(clean==1); finish(w)
            Mock.DeferDestroying=false
        end)
    end
    test('stepper manual transitions, validation and compact pin summary',function()
        local w,s=fixture(); local stepper=s:AddStepper({Id='stages',Pinnable=true,Steps={{Id='search',Title='Buscar'},{Id='run',Title='Executar'},{Id='check',Title='Confirmar'}}})
        local hud=w:CreateHUD(); local item=stepper:PinToHUD(hud)
        assert(stepper:GetSteps()[1].Status=='Pending'); stepper:SetCurrent('run','Trabalhando')
        assert(stepper:GetSteps()[1].Status=='Completed' and stepper:GetSteps()[2].Status=='Running' and item:GetValue():find('Executar'))
        stepper:SetStep('run','Error','Falha'); assert(stepper:GetSummary():find('Error'))
        local before=stepper:GetValue(); assert(not pcall(stepper.SetStep,stepper,'missing','Running')); assert(stepper:GetValue()[2].Status==before[2].Status)
        stepper:Complete(); assert(item:GetValue():find('3/3')); stepper:Reset(); assert(item:GetValue():find('0/3'))
        finish(w)
    end)
    test('stepper follows real action progress and completion without starting work',function()
        local w,s=fixture(); local stepper=s:AddStepper({Steps={'Buscar','Executar','Confirmar'}})
        local calls=0; local action=w:RunAction({Callback=function(ctx)
            calls=calls+1; ctx:SetProgress(1,3,'Encontrado'); ctx:SetProgress(2,3,'Executado'); ctx:SetProgress(3,3,'Confirmado')
        end})
        stepper:BindAction(action); assert(calls==0 and stepper:GetSteps()[1].Status=='Running')
        Mock.pump(); assert(calls==1 and stepper:GetSteps()[3].Status=='Completed')
        stepper:UnbindAction(); finish(w)
    end)
    test('stepper follows failed and cancelled actions and can rebind',function()
        local w,s=fixture(); local stepper=s:AddStepper({Steps={'A','B'}})
        local failed=w:RunAction({Callback=function(ctx) ctx:SetProgress(1,2,'A'); error('expected failure') end})
        stepper:BindAction(failed); Mock.pump(); assert(stepper:GetSteps()[1].Status=='Completed' and stepper:GetSteps()[2].Status=='Error')
        local action=w:RunAction({Callback=function() end}); stepper:BindAction(action); action:Cancel('test'); Mock.pump()
        assert(stepper:GetSteps()[1].Status=='Cancelled')
        Mock.Warnings={}; finish(w)
    end)
    test('preview and stepper descriptions reserve space below their titles',function()
        local w,s=fixture(); local preview=s:AddPreview({Description='Preview description'}); local stepper=s:AddStepper({Steps={'One'},Description='Steps description'})
        assert(preview.Container.Position.Y.Offset>=preview.DescriptionLabel.Position.Y.Offset+preview.DescriptionLabel.Size.Y.Offset)
        assert(stepper.List.Position.Y.Offset>=stepper.DescriptionLabel.Position.Y.Offset+stepper.DescriptionLabel.Size.Y.Offset)
        preview:SetDescription(''); stepper:SetDescription('')
        assert(preview.Container.Position.Y.Offset>=24 and stepper.List.Position.Y.Offset>=24)
        finish(w)
    end)
    test('stepper State binding and theme changes preserve the same rows',function()
        local w,s=fixture(); local state=w:CreateState({{Id='one',Status='Pending'}})
        local stepper=s:AddStepper({Id='state-steps',Steps={{Id='one',Title='One'}},State=state})
        local row=stepper._stepRows[1].Frame; state:Set({{Id='one',Status='Running',Message='Working'}})
        for _,theme in ipairs(Library:GetThemeNames()) do w:SetTheme(theme) end
        assert(stepper._stepRows[1].Frame==row and stepper._stepRows[1].Badge.Text=='>' and stepper._stepRows[1].Message.Text=='Working')
        finish(w)
    end)
end
