-- A bounded visual sequence observes actions; it never runs their callbacks.
do
    local validStatus={Pending=true,Running=true,Completed=true,Error=true,Cancelled=true}
    local symbols={Pending='.',Running='>',Completed='+',Error='!',Cancelled='x'}
    local roles={Pending='Muted',Running='Accent',Completed='Success',Error='Danger',Cancelled='Muted'}
    function Section:AddStepper(options)
        options=options or {}; local steps=options.Steps
        assert(type(steps)=='table' and #steps>=1 and #steps<=32,'Stepper needs 1–32 steps')
        for key in pairs(steps) do assert(type(key)=='number' and key%1==0 and key>=1 and key<=#steps,'Steps must be a dense array') end
        local definitions,ids={},{}
        for index,step in ipairs(steps) do
            if type(step)=='string' then step={Id='step-'..index,Title=step} end
            assert(type(step)=='table' and type(step.Id)=='string' and #step.Id>=1 and #step.Id<=64 and not ids[step.Id],'Step Id must be unique and contain 1–64 bytes')
            assert(type(step.Title)=='string' and #step.Title<=256,'Step Title must contain at most 256 bytes')
            definitions[index]={Id=step.Id,Title=step.Title}; ids[step.Id]=index
        end
        local height=options.Height or math.max(100,math.min(440,46+#steps*52))
        assert(finite(height) and height>=100 and height<=1800,'Stepper Height must be 100–1800')
        local self=base(self,'Stepper',options,height); self.Persist=false; self.Steps=definitions; self._stepIds=ids; self._stepRows={}
        local window=self._window
        local top=#self.Description>0 and 48 or 28
        self.List=ui(window,'ScrollingFrame',{Name='Steps',Parent=self.Frame,Position=U2(0,top),Size=UDim2.new(1,0,1,-top),BorderSizePixel=1,CanvasSize=U2(0,#steps*52),
            ScrollBarThickness=4,ScrollingDirection=Enum.ScrollingDirection.Y,ClipsDescendants=true},{BackgroundColor3='Inset',BorderColor3='Border',ScrollBarImageColor3='Accent'})
        for index,step in ipairs(definitions) do
            local row=frame(window,self.List,{Position=U2(6,6+(index-1)*52),Size=UDim2.new(1,-16,0,46),BackgroundTransparency=1})
            local badge=label(window,row,'.',{Size=U2(24,28),TextXAlignment=Enum.TextXAlignment.Center,TextSize=18},'Muted')
            local title=label(window,row,step.Title,{Position=U2(30,1),Size=UDim2.new(1,-34,0,20),TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd})
            local message=label(window,row,'',{Position=U2(30,23),Size=UDim2.new(1,-34,0,18),TextSize=10,TextTruncate=Enum.TextTruncate.AtEnd},'Muted')
            self._stepRows[index]={Frame=row,Badge=badge,Title=title,Message=message}
        end
        function self:_normalize(value)
            assert(type(value)=='table' and #value==#self.Steps,'Stepper Value must have one record per step')
            for key in pairs(value) do assert(type(key)=='number' and key%1==0 and key>=1 and key<=#value,'Step values must be a dense array') end
            local result={}
            for i,record in ipairs(value) do
                assert(type(record)=='table' and (record.Id==nil or record.Id==self.Steps[i].Id) and validStatus[record.Status],'Invalid step record or Status')
                assert(record.Message==nil or type(record.Message)=='string' and #record.Message<=2048,'Step Message must contain at most 2048 bytes')
                result[i]={Id=self.Steps[i].Id,Status=record.Status,Message=record.Message or ''}
            end
            return result
        end
        function self:_render()
            if self.Destroyed or not self.List or not self.List.Parent then return end
            for i,record in ipairs(self.Value) do local row=self._stepRows[i]
                if row.Frame.Parent then
                    row.Badge.Text=symbols[record.Status]; row.Message.Text=record.Message~='' and record.Message or record.Status
                    window:_bind(row.Badge,{TextColor3=roles[record.Status]}); window:_bind(row.Title,{TextColor3=record.Status=='Running' and 'Accent' or 'Text'})
                    if row._motionStatus~=record.Status then
                        row._motionStatus=record.Status
                        window:_revealText(row.Badge,self,'step-enter');window:_revealText(row.Message,self,'step-enter')
                    end
                end
            end
        end
        function self:GetSteps() return self:GetValue() end
        function self:GetSummary()
            local complete=0; local current
            for i,record in ipairs(self.Value or {}) do
                if record.Status=='Completed' then complete=complete+1
                elseif record.Status=='Running' or record.Status=='Error' or record.Status=='Cancelled' then current=self.Steps[i].Title..' · '..record.Status end
            end
            return current or tostring(complete)..'/'..#self.Steps..' '..window:_t17('concluídas','completed')
        end
        function self:SetStep(id,status,message)
            assert(self._stepIds[id] and validStatus[status],'Unknown step or Status')
            local value=self:GetValue(); value[self._stepIds[id]]={Id=id,Status=status,Message=message}; return self:SetValue(value,true)
        end
        function self:SetCurrent(id,message)
            local index=assert(self._stepIds[id],'Unknown step Id'); local value={}
            for i,step in ipairs(self.Steps) do value[i]={Id=step.Id,Status=i<index and 'Completed' or i==index and 'Running' or 'Pending',Message=i==index and message or ''} end
            return self:SetValue(value,true)
        end
        function self:Reset()
            local value={}; for i,step in ipairs(self.Steps) do value[i]={Id=step.Id,Status='Pending'} end
            return self:SetValue(value,true)
        end
        function self:Complete(message)
            local value={}; for i,step in ipairs(self.Steps) do value[i]={Id=step.Id,Status='Completed',Message=i==#self.Steps and message or ''} end
            return self:SetValue(value,true)
        end
        function self:BindAction(action)
            assert(not self.Destroyed and action and action._window==window and action.Status and not action.Status.Destroyed,'BindAction needs an action from this window')
            self._resources:Remove('stepper-action')
            self._resources:Add(action:Subscribe(function(status)
                if self.Destroyed or not self.Frame.Parent then return end
                local completed=finite(status.Step) and clamp(math.floor(status.Step),0,#self.Steps) or 0
                local index=math.min(#self.Steps,completed+1); local value={}
                for i,step in ipairs(self.Steps) do
                    local state=status.Status=='Completed' and 'Completed' or i<=completed and 'Completed' or 'Pending'
                    if i==index and status.Status~='Completed' then
                        if status.Status=='Failed' then state='Error' elseif status.Status=='Cancelled' then state='Cancelled'
                        elseif status.Status=='Running' or status.Status=='Cancelling' then state='Running' end
                    end
                    value[i]={Id=step.Id,Status=state,Message=i==index and tostring(status.Message or status.Error or ''):sub(1,2048) or ''}
                end
                self:SetValue(value,true)
            end,true),'Disconnect','stepper-action'); return self
        end
        function self:UnbindAction() self._resources:Remove('stepper-action'); return self end
        self:Manage(function() self.List=nil; self._stepRows={}; self._stepIds={} end,nil,'stepper-rows')
        local initial={}; for i,step in ipairs(definitions) do initial[i]={Id=step.Id,Status='Pending'} end
        local passed={}; for k,v in pairs(options) do passed[k]=v end; passed.TwoWay=false
        return init(self,passed,initial)
    end
end
