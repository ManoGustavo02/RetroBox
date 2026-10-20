-- Typed finite graphs connect public controls, States and developer actions.
-- No node evaluates source code. Execution starts only from explicit events.
do
    local types=Library:GetDesignerCatalog().FlowNodes
    local function plain(value,seen,depth,budget)
        local kind=type(value);budget.Count=budget.Count+1;assert(budget.Count<=32768,'Graph data exceeds its budget')
        if kind=='nil' or kind=='boolean' then return value end
        if kind=='number' then assert(finite(value),'Graph numbers must be finite');return value end
        if kind=='string' then budget.Bytes=budget.Bytes+#value;assert(budget.Bytes<=2097152,'Graph strings exceed 2 MiB');return value end
        assert(kind=='table' and getmetatable(value)==nil and depth<16 and not seen[value],'Graph must be acyclic plain data')
        seen[value]=true;local result={}
        for key,item in pairs(value) do
            assert(type(key)=='string' or type(key)=='number' and finite(key),'Invalid graph key')
            assert(key~='__proto__' and key~='constructor' and key~='prototype','Reserved graph key')
            result[key]=plain(item,seen,depth+1,budget)
        end
        seen[value]=nil;return result
    end
    function Library:CloneDesignerData(value) return plain(value,{},0,{Count=0,Bytes=0}) end
    local function array(value,maximum,name)
        assert(type(value)=='table' and #value<=maximum,name..' exceeds its limit')
        for key in pairs(value) do assert(type(key)=='number' and key%1==0 and key>=1 and key<=#value,name..' must be a dense array') end
        return value
    end
    local function key(value)
        assert(type(value)=='string' and #value>=1 and #value<=128 and value:match('^[%w_./%-]+$'),'Graph Id must contain 1–128 portable characters')
        return value
    end
    local function controlType(control)
        return ({Toggle='boolean',Slider='number',Input='string',Label='string',Separator='string',CardGrid='string',Progress='number',Console='string',VirtualList='string',DataTable='string',TreeView='string'})[control.Type] or 'any'
    end
    local function prepare(definition,bindings)
        local graph=Library:CloneDesignerData(definition);bindings=bindings or {}
        assert(type(graph)=='table','Flow graph must be a record');key(graph.Id or 'flow')
        local controls,states,actions=bindings.Controls or {},bindings.States or {},bindings.Actions or {}
        local nodes,incoming,outgoing={}, {},{}
        for _,node in ipairs(array(graph.Nodes or {},256,'Nodes')) do
            key(node.Id);assert(not nodes[node.Id] and types[node.Type],'Duplicate node or unknown Type')
            nodes[node.Id]=node;incoming[node.Id]={};outgoing[node.Id]={}
            if node.Control then assert(type(node.Control)=='string' and controls[node.Control] and not controls[node.Control].Destroyed,'Unknown control: '..tostring(node.Control)) end
            if node.State then assert(states[node.State] and Library:_isState(states[node.State]) and not states[node.State].Destroyed,'Unknown State') end
            local spec=types[node.Type]
            for field,choices in pairs(spec.Fields) do
                if type(choices)=='table' then assert(node[field]~=nil and table.find(choices,node[field]),'Invalid '..field..' in '..node.Id) end
            end
            local kind=node.Type
            if kind=='Value' or kind=='Binding' or kind=='SetValue' then
                assert((node.Control~=nil)~=(node.State~=nil),'Node needs exactly one Control or State')
            end
            if kind=='Click' then assert(node.Control and controls[node.Control].Type=='Button','Click needs a Button')
            elseif kind=='Change' then assert(node.Control and type(controls[node.Control].OnChanged)=='function','Change needs a value control')
            elseif kind=='Apply' or kind=='ApplyForm' or kind=='CancelForm' then assert(node.Control and controls[node.Control].Type=='Form','Node needs a Form')
            elseif kind=='Call' then assert(type(node.Action)=='string' and type(actions[node.Action])=='function','Action is not connected: '..tostring(node.Action))
            elseif kind=='SetVisible' or kind=='SetDisabled' or kind=='SetText' then assert(node.Control,'Node needs a Control')
            elseif kind=='Format' or kind=='Notify' then assert(type(node.Text)=='string' and #node.Text<=8192,'Node needs Text') end
            if node.State and (kind=='Binding' or kind=='SetValue') then assert(not states[node.State].ReadOnly,'Cannot write a read-only State') end
        end
        local edgeKeys={}
        for _,edge in ipairs(array(graph.Edges or {},512,'Edges')) do
            assert(type(edge)=='table' and nodes[edge.From] and nodes[edge.To],'Edge refers to an unknown node')
            local source,target=types[nodes[edge.From].Type],types[nodes[edge.To].Type]
            local output,input=source.Outputs[edge.Out],target.Inputs[edge.Input]
            assert(output and input,'Edge refers to an unknown port')
            assert((output=='exec')==(input=='exec'),'Execution and data ports cannot be connected')
            local signature=edge.From..'/'..edge.Out..'/'..edge.To..'/'..edge.Input
            assert(not edgeKeys[signature],'Duplicate edge');edgeKeys[signature]=true
            if input~='exec' then assert(not incoming[edge.To][edge.Input],'Input already has a connection');incoming[edge.To][edge.Input]=edge end
            outgoing[edge.From][edge.Out]=outgoing[edge.From][edge.Out] or {};table.insert(outgoing[edge.From][edge.Out],edge)
        end
        local marks={}
        local function visit(name)
            assert(marks[name]~=1,'Flow graph contains a cycle')
            if marks[name]==2 then return end
            marks[name]=1
            for _,edges in pairs(outgoing[name]) do for _,edge in ipairs(edges) do visit(edge.To) end end
            marks[name]=2
        end
        for name in pairs(nodes) do visit(name) end
        local inferred={}
        local function outputType(name,port)
            local cache=name..'/'..port;if inferred[cache] then return inferred[cache] end
            local node=nodes[name];local result=types[node.Type].Outputs[port]
            if result=='any' then
                if node.Type=='Constant' then result=type(node.Value);if result=='nil' or result=='table' then result='any' end
                elseif node.Control then result=controlType(controls[node.Control])
                elseif node.State then result=type(states[node.State]:Get());if result=='nil' or result=='table' then result='any' end end
            end
            inferred[cache]=result;return result
        end
        for name,node in pairs(nodes) do
            for port,inputType in pairs(types[node.Type].Inputs) do
                if inputType~='exec' then
                    local edge=incoming[name][port]
                    local optional=node.Type=='Notify' and port=='Message' or node.Type=='Call' and port=='Value'
                    assert(edge or optional,'Missing data input '..name..'.'..port)
                    if edge then
                        local sourceType=outputType(edge.From,edge.Out)
                        local expected=inputType
                        if node.Type=='Binding' or node.Type=='SetValue' then
                            local property=node.Property or 'Value'
                            if property=='Visible' or property=='Disabled' then expected='boolean'
                            elseif property~='Value' then expected='string'
                            elseif node.Control then expected=controlType(controls[node.Control])
                            elseif node.State then expected=type(states[node.State]:Get());if expected=='table' or expected=='nil' then expected='any' end end
                        end
                        assert(expected=='any' or sourceType=='any' or expected==sourceType,'Incompatible port types at '..name..'.'..port)
                    end
                end
            end
        end
        local dependency,bindingsByTarget,bindingProperties={}, {},{}
        local function sources(name,found,seen)
            seen=seen or {};if seen[name] then return end;seen[name]=true
            local node=nodes[name]
            if node.Type=='Value' or node.Type=='Change' or node.Type=='Apply' then
                found[(node.Control and 'control/'..node.Control) or 'state/'..node.State]=true
            end
            for _,edge in pairs(incoming[name]) do sources(edge.From,found,seen) end
        end
        for name,node in pairs(nodes) do
            if node.Type=='Binding' then
                local target=node.Control and 'control/'..node.Control or 'state/'..node.State
                assert(not node.State or node.Property=='Value','State bindings write the Value property')
                local property=target..'/'..node.Property
                assert(not bindingProperties[property],'A property cannot have multiple bindings');bindingProperties[property]=true
                if node.State or node.Property=='Value' or node.Property=='Text' then
                    dependency[target]=dependency[target] or {};sources(name,dependency[target])
                    bindingsByTarget[target]=bindingsByTarget[target] or {};table.insert(bindingsByTarget[target],name)
                end
            end
        end
        local seen={}
        local function feedback(name)
            assert(seen[name]~=1,'Bindings contain a value feedback cycle')
            if seen[name]==2 then return end;seen[name]=1
            for source in pairs(dependency[name] or {}) do feedback(source) end
            seen[name]=2
        end
        for name in pairs(dependency) do feedback(name) end
        local bindingOrder,bindingMarks={},{}
        local function orderBinding(name)
            if bindingMarks[name] then return end;bindingMarks[name]=true
            local found={};sources(name,found)
            for source in pairs(found) do for _,upstream in ipairs(bindingsByTarget[source] or {}) do orderBinding(upstream) end end
            bindingOrder[#bindingOrder+1]=nodes[name]
        end
        for _,node in ipairs(graph.Nodes or {}) do if node.Type=='Binding' then orderBinding(node.Id) end end
        return graph,nodes,incoming,outgoing,bindingOrder
    end
    function Library:ValidateFlowGraph(definition,bindings)
        local ok,value=pcall(prepare,definition,bindings)
        if not ok then return false,tostring(value) end
        return true,value
    end
    function Control:OnActivated(callback)
        assert(not self.Destroyed and type(callback)=='function','OnActivated needs a live control and callback')
        if not self._activationListeners then
            self._activationListeners={};self:Manage(function() for listener in pairs(self._activationListeners) do listener.Connected=false end;self._activationListeners={} end)
        end
        local control=self;local listener={Connected=true,Callback=callback}
        function listener:Disconnect() self.Connected=false;control._activationListeners[self]=nil end
        self._activationListeners[listener]=true;return listener
    end
    local addButton=Section.AddButton
    function Section:AddButton(options)
        local control=addButton(self,options);local press=control.Press
        function control:Press(...)
            local accepted,reason=press(self,...)
            if accepted then for listener in pairs(self._activationListeners or {}) do if listener.Connected then call(self._window,listener.Callback,self) end end end
            return accepted,reason
        end
        return control
    end
    function Window:CreateFlowGraph(definition,bindings)
        assert(not self.Destroyed,'Window has been destroyed')
        bindings=bindings or {};local controls=bindings.Controls or self.Controls;local states=bindings.States or {};local actions=bindings.Actions or {}
        for _,control in pairs(controls) do assert(control._window==self,'Flow control belongs to another window') end
        for _,state in pairs(states) do assert(state._window==nil or state._window==self,'Flow State belongs to another window') end
        local graph,nodes,incoming,outgoing,bindingOrder=prepare(definition,{Controls=controls,States=states,Actions=actions})
        self._flows=self._flows or {};local name=graph.Id or 'flow';assert(not self._flows[name],'Duplicate flow Id')
        local window=self;local flow={Id=name,Scope=self:CreateScope(),Definition=graph,Controls=controls,States=states,Actions=actions,Executed=0,Events=0}
        self._flows[name]=flow
        local function readTarget(node)
            if node.State then return assert(not states[node.State].Destroyed and states[node.State],'State was destroyed'):Get() end
            local control=assert(not controls[node.Control].Destroyed and controls[node.Control],'Control was destroyed')
            return control:GetValue()
        end
        local evaluate,uncached
        local function input(node,port,cache)
            local edge=incoming[node.Id][port];if not edge then return nil end;return evaluate(edge.From,edge.Out,cache or {})
        end
        evaluate=function(name,port,cache)
            local key=name..'/'..port
            local stored=cache[key];if stored then return stored.Value end
            local value=uncached(name,port,cache);cache[key]={Value=value};return value
        end
        uncached=function(name,port,cache)
            local node=nodes[name];local kind=node.Type
            if kind=='Constant' then return copy(node.Value) end
            if kind=='Value' or kind=='Change' or kind=='Apply' then return readTarget(node) end
            if kind=='Not' then return not input(node,'Value',cache) end
            if kind=='Format' then return (window:Translate(node.Text):gsub('{value}',function() return tostring(input(node,'Value',cache)) end)) end
            local a,b=input(node,'A',cache),input(node,'B',cache)
            if kind=='And' then return a and b elseif kind=='Or' then return a or b end
            if kind=='Compare' then
                local op=node.Operator
                if op=='==' then return same(a,b) elseif op=='~=' then return not same(a,b)
                elseif op=='>' then return a>b elseif op=='>=' then return a>=b elseif op=='<' then return a<b else return a<=b end
            end
            assert(kind=='Math' and finite(a) and finite(b),'Math inputs must be finite numbers')
            local op=node.Operator;local result
            if op=='+' then result=a+b elseif op=='-' then result=a-b elseif op=='*' then result=a*b
            elseif op=='/' then assert(b~=0,'Division by zero');result=a/b elseif op=='min' then result=math.min(a,b) else result=math.max(a,b) end
            assert(finite(result),'Math result must be finite');return result
        end
        local function write(node,value,property)
            if node.State then assert(not states[node.State].Destroyed,'State was destroyed');states[node.State]:Set(value);return end
            local control=assert(not controls[node.Control].Destroyed and controls[node.Control],'Control was destroyed')
            if property=='Value' then control:SetValue(value,true)
            elseif property=='Visible' then assert(type(value)=='boolean','Visible requires boolean');control:SetVisible(value)
            elseif property=='Disabled' then assert(type(value)=='boolean','Disabled requires boolean');control:SetDisabled(value)
            elseif property=='Description' then control:SetDescription(tostring(value))
            elseif property=='Text' and control.Type=='Button' then control._normalText=tostring(value);control:_render()
            elseif property=='Text' and control.SetText then control:SetText(tostring(value))
            else control:SetTitle(tostring(value)) end
        end
        function flow:Refresh()
            if self.Destroyed or window.Destroyed or window._closing or self._refreshing then return end
            self._refreshing=true
            local ok,reason=window:_protected(function()
                for _,node in ipairs(bindingOrder) do write(node,input(node,'Value'),node.Property) end
            end,{Phase='FlowBinding',Operation=self.Id})
            self._refreshing=false;self.LastError=not ok and tostring(reason) or nil
        end
        local execute
        local function nextNodes(node,port,ctx,budget)
            for _,edge in ipairs(outgoing[node.Id][port] or {}) do execute(nodes[edge.To],ctx,budget) end
        end
        execute=function(node,ctx,budget)
            ctx:ThrowIfCancelled();assert(not flow.Destroyed and not window.Destroyed,'Flow was destroyed')
            budget.Count=budget.Count+1;assert(budget.Count<=512,'Flow execution budget exceeded');flow.Executed=flow.Executed+1
            local kind=node.Type
            if kind=='Branch' then nextNodes(node,input(node,'Condition') and 'True' or 'False',ctx,budget);return
            elseif kind=='SetValue' then write(node,input(node,'Value'),'Value')
            elseif kind=='SetVisible' then write(node,input(node,'Value'),'Visible')
            elseif kind=='SetDisabled' then write(node,input(node,'Value'),'Disabled')
            elseif kind=='SetText' then write(node,input(node,'Value'),'Text')
            elseif kind=='Notify' then window:Notify({Title=window:Translate(node.Title or 'RetroBox'),Content=input(node,'Message') or window:Translate(node.Text),Kind=node.Kind})
            elseif kind=='Call' then local result,reason=actions[node.Action](ctx,input(node,'Value'),flow);assert(result~=false,reason or 'Developer action failed')
            elseif kind=='SetLocale' then window:SetLocale(node.Locale)
            elseif kind=='ApplyForm' then local ok,reason=controls[node.Control]:Apply();assert(ok or reason=='unchanged','Form validation failed')
            elseif kind=='CancelForm' then controls[node.Control]:Cancel()
            else error('Invalid executable node: '..kind) end
            ctx:ThrowIfCancelled();nextNodes(node,'Then',ctx,budget)
        end
        function flow:Trigger(nodeId)
            if self.Destroyed or window.Destroyed then return nil,'Flow has been destroyed' end
            local node=nodes[nodeId];if not node or types[node.Type].Category~='Event' then return nil,'Unknown event node' end
            self.Events=self.Events+1
            local handle,reason=window:RunAction({Group='flow/'..UpdateCore.SHA256(self.Id):sub(1,24),Policy='Reject',Callback=function(ctx)
                nextNodes(node,'Then',ctx,{Count=0});return true
            end})
            if handle then self.Scope:Add(handle,'Cancel','flow-action') end
            return handle,reason
        end
        function flow:Destroy()
            if self.Destroyed then return end;self.Destroyed=true;self.Scope:Destroy()
        end
        function flow:GetDefinition() return self.Definition and copy(self.Definition) or nil end
        flow.Scope:Add(function() flow.Destroyed=true;window._flows[name]=nil;flow.Controls={};flow.States={};flow.Actions={};flow.Definition=nil;controls={};states={};actions={};nodes={};incoming={};outgoing={};bindingOrder={} end)
        local observed={}
        for _,node in ipairs(graph.Nodes or {}) do
            if node.Type=='Click' then flow.Scope:Add(controls[node.Control]:OnActivated(function() if not flow.Destroyed then flow:Trigger(node.Id) end end),'Disconnect')
            elseif node.Type=='Change' or node.Type=='Apply' then flow.Scope:Add(controls[node.Control]:OnChanged(function() if not flow.Destroyed and not window._importing then flow:Trigger(node.Id) end end),'Disconnect') end
            if node.Type=='Value' or node.Type=='Change' or node.Type=='Apply' then
                local source
                if node.State then source=states[node.State]
                elseif controls[node.Control].Type=='Form' or controls[node.Control].Type=='Component' then source=controls[node.Control].State
                else source=window:GetFlagState(controls[node.Control].Id) end
                if not observed[source] then observed[source]=true;flow.Scope:Add(source:Subscribe(function() flow:Refresh() end),'Disconnect') end
            end
        end
        flow:Refresh();return flow
    end
end
