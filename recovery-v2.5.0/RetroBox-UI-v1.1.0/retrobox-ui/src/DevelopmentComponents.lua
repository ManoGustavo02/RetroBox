-- Reusable groups and transactional forms compose the existing public controls.
do
    local allowed={Toggle=true,Slider=true,Button=true,Input=true,Dropdown=true,ColorPicker=true,Label=true,Separator=true,
        StatCard=true,Progress=true,Chart=true,Console=true,Image=true,VirtualList=true,DataTable=true,TreeView=true,
        Preview=true,Stepper=true,CardGrid=true,Keybind=true}
    local function id(value)
        assert(type(value)=='string' and #value>=1 and #value<=64 and value:match('^[%w_.%-]+$'),'Group Id must contain 1–64 letters, numbers, dots, underscores or hyphens')
        return value
    end
    local function owner(section,name,kind)
        local window=section._window
        assert(not section.Destroyed and not window.Destroyed,'Section has been destroyed')
        window._componentGroups=window._componentGroups or {};assert(not window._componentGroups[name],'Duplicate component group Id')
        local result={Id=id(name),Type=kind,_window=window,Section=section,Controls={},Scope=window:CreateScope()}
        window._componentGroups[name]=result
        result.Scope:Add(function() if window._componentGroups[name]==result then window._componentGroups[name]=nil end end)
        function result:Manage(value,method,key) return self.Scope:Add(value,method,key) end
        function result:SetVisible(value)
            assert(type(value)=='boolean','Visible must be boolean')
            for _,control in ipairs(self.Controls) do if not control.Destroyed then control:SetVisible(value) end end;return self
        end
        function result:SetDisabled(value)
            assert(type(value)=='boolean','Disabled must be boolean');self.Disabled=value
            for _,control in ipairs(self.Controls) do if not control.Destroyed then control:SetDisabled(value) end end;return self
        end
        function result:SetTitle(value) if self.Header then self.Header:SetText(tostring(value)) end;return self end
        function result:SetDescription(value) if self.Header then self.Header:SetDescription(tostring(value)) end;return self end
        function result:Destroy()
            if self.Destroyed then return end
            self.Destroyed=true;self.Scope:Destroy();self.Section=nil
        end
        result.Scope:Add(function()
            result.Destroyed=true
            for i=#result.Controls,1,-1 do local control=result.Controls[i];if not control.Destroyed then control:Destroy() end end
            result.Controls={};result.Section=nil
        end,nil,'controls')
        result:Manage(section.Frame.Destroying:Connect(function() result:Destroy() end),'Disconnect')
        return result
    end
    Library._components={}
    function Library:RegisterComponent(name,builder,options)
        id(name);assert(type(builder)=='function','Component builder must be a function')
        assert(not self._components[name] or type(options)=='table' and options.Replace==true,'Component is already registered')
        local count=0;for _ in pairs(self._components) do count=count+1 end;assert(self._components[name] or count<128,'Component registry limit is 128')
        self._components[name]=builder;return self
    end
    function Library:GetComponentNames()
        local result={};for name in pairs(self._components) do result[#result+1]=name end;table.sort(result);return result
    end
    function Section:AddComponent(name,options)
        options=options or {};local builder=assert(Library._components[name],'Unknown reusable component')
        local handle=owner(self,options.Id or name,'Component');local section=self;local context={Scope=handle.Scope,Window=self._window,Controls={},Props=options.Props or {}}
        function context:Add(kind,settings)
            assert(not handle.Destroyed and allowed[kind] and type(section['Add'..kind])=='function','Unknown or destroyed component control')
            assert(#handle.Controls<32,'A reusable component accepts at most 32 child controls')
            local prepared={};for key,value in pairs(settings or {}) do prepared[key]=value end
            local child=id(prepared.Id or ('item-'..(#handle.Controls+1)))
            assert(not self.Controls[child],'Duplicate component child Id')
            prepared.Id=handle.Id..'/'..child
            local control=section['Add'..kind](section,prepared)
            handle.Controls[#handle.Controls+1]=control;self.Controls[child]=control;return control
        end
        function context:CreateState(value,settings)
            local state=Library:CreateState(value,settings);handle:Manage(state,'Destroy');return state
        end
        function context:Manage(resource,method,key) return handle:Manage(resource,method,key) end
        local ok,result=pcall(builder,context,context.Props)
        if not ok then handle:Destroy();error(result,2) end
        handle.Exports=result or {};handle.Children=context.Controls
        function handle:Get(child) return self.Children[child] end
        function handle:GetValue() local values={};for key,control in pairs(self.Children) do if not control.Destroyed then values[key]=control:GetValue() end end;return values end
        function handle:SetValue(values,silent)
            assert(type(values)=='table' and not self.Destroyed,'Component values need a live component and record')
            local changes={};for key,value in pairs(values) do local child=assert(self.Children[key],'Unknown component child');changes[key]=child:_normalize(value) end
            Library:Batch(function() for key,value in pairs(changes) do self.Children[key]:SetValue(value,silent~=false) end end);return self
        end
        local sources={};for _,child in pairs(handle.Children) do sources[#sources+1]=self._window:GetFlagState(child.Id) end
        if #sources>0 then handle.State=self._window:Computed(sources,function() return handle:GetValue() end)
        else handle.State=Library:CreateState({}) end
        handle:Manage(handle.State,'Destroy')
        function handle:OnChanged(callback)
            assert(type(callback)=='function','Component listener must be a function')
            local scope=self.Scope:Child();local connection={Connected=true}
            for _,child in pairs(self.Children) do scope:Add(child:OnChanged(function() if connection.Connected and not self.Destroyed then callback(self:GetValue(),self) end end),'Disconnect') end
            function connection:Disconnect() self.Connected=false;scope:Destroy() end
            scope:Add(function() connection.Connected=false end);return connection
        end
        handle:Manage(function() handle.Children={};handle.Exports={};context.Controls={};context.Window=nil;context.Props=nil end)
        return handle
    end

    local formTypes={Input=true,Toggle=true,Slider=true,Dropdown=true,ColorPicker=true}
    function Section:CreateForm(options)
        assert(type(options)=='table' and type(options.Fields)=='table' and #options.Fields>=1 and #options.Fields<=64,'Form needs 1–64 Fields')
        local window=self._window;local name=id(options.Id)
        window._forms=window._forms or {};assert(not window._forms[name],'Duplicate form Id')
        assert(options.Validate==nil or type(options.Validate)=='function','Form Validate must be a function')
        assert(options.OnApply==nil or type(options.OnApply)=='function','Form OnApply must be a function')
        local fields,keys={},{}
        for index,field in ipairs(options.Fields) do
            assert(type(field)=='table' and formTypes[field.Type],'Unknown form field Type')
            id(field.Id);assert(not keys[field.Id],'Duplicate form field Id')
            assert(not ({_title=true,_status=true,_apply=true,_cancel=true})[field.Id],'Reserved form field Id')
            assert(field.Required==nil or type(field.Required)=='boolean','Required must be boolean')
            local prepared={};for key,value in pairs(field) do prepared[key]=value end
            fields[index]=prepared;keys[field.Id]=true
        end
        local form=owner(self,name,'Form');form.Fields={};form.Errors={};form._definitions=fields;form._listeners={}
        window._forms[name]=form
        local function add(kind,settings)
            settings.Persist=false;settings.Id=name..'/'..settings.Id
            if options.Translate==false then settings.Translate=false end
            local control=self['Add'..kind](self,settings);form.Controls[#form.Controls+1]=control;return control
        end
        local function values()
            local result={}
            for key,control in pairs(form.Fields) do
                result[key]=control.Type=='Input' and control.Input.Text or control:GetValue()
            end
            return result
        end
        local function render()
            if form.Destroyed then return end
            form.Dirty=not same(values(),form._committed:Get())
            form.Status:SetText(window:_t17(form.Dirty and 'Alterações não aplicadas' or 'Nenhuma alteração pendente',form.Dirty and 'Unapplied changes' or 'No pending changes'))
            form.ApplyButton:SetDisabled(form.Disabled or not form.Dirty);form.CancelButton:SetDisabled(form.Disabled or not form.Dirty)
        end
        local ok,reason=pcall(function()
            if options.Title then form.Header=add('Label',{Id='_title',Title=options.Title,Description=options.Description or '',Height=44}) end
            for _,field in ipairs(fields) do
                local settings={};for key,value in pairs(field) do settings[key]=value end
                settings.Type=nil;settings.Required=nil;settings.Callback=nil;settings.State=nil;settings.FireOnInit=false
                if options.Values and options.Values[field.Id]~=nil then settings.Default=copy(options.Values[field.Id]) end
                local control=add(field.Type,settings);form.Fields[field.Id]=control
                local errorLabel=add('Label',{Id=field.Id..'.error',Title='',Height=26,Visible=false});form.Errors[field.Id]=errorLabel
            end
            form._committed=Library:CreateState(values());form:Manage(form._committed,'Destroy')
            form.State=window:Computed({form._committed},function(value) return value end)
            form.Status=add('Label',{Id='_status',Title='',Height=28})
            form.ApplyButton=add('Button',{Id='_apply',Title=window:_t17('Aplicar','Apply'),Icon='check',Callback=function() form:Apply() end})
            form.CancelButton=add('Button',{Id='_cancel',Title=window:_t17('Cancelar','Cancel'),Icon='close',Callback=function() form:Cancel() end})
            for _,control in pairs(form.Fields) do
                form:Manage(control:OnChanged(function() render() end),'Disconnect')
                if control.Type=='Input' then form:Manage(control.Input:GetPropertyChangedSignal('Text'):Connect(function() render() end),'Disconnect') end
            end
        end)
        if not ok then form:Destroy();window._forms[name]=nil;error(reason,2) end
        function form:GetValue() return self._committed:Get() end
        function form:GetDraft() return values() end
        function form:IsDirty() return not same(values(),self._committed:Get()) end
        function form:_prepare(value)
            assert(type(value)=='table','Form values must be a record')
            local normalized={};local errors={}
            for key in pairs(value) do assert(self.Fields[key],'Unknown form field: '..tostring(key)) end
            for _,field in ipairs(fields) do
                local candidate=value[field.Id]
                local valid,result=pcall(self.Fields[field.Id]._normalize,self.Fields[field.Id],candidate)
                if not valid then errors[field.Id]=tostring(result)
                elseif field.Required and (result==nil or type(result)=='string' and result:match('^%s*$')) then errors[field.Id]=window:_t17('Campo obrigatório','Required field')
                else normalized[field.Id]=copy(result) end
            end
            if next(errors)==nil and options.Validate then
                local valid,message=options.Validate(copy(normalized),self)
                if valid~=true then
                    if type(message)=='table' then for key,text in pairs(message) do assert(self.Fields[key],'Validation returned an unknown field');errors[key]=tostring(text) end
                    else errors._form=tostring(message or window:_t17('Revise os campos','Review the fields')) end
                end
            end
            return next(errors)==nil,normalized,errors
        end
        function form:Validate()
            assert(not self.Destroyed,'Form has been destroyed')
            local valid,result,errors=self:_prepare(values());return valid,errors,result
        end
        function form:SetDraft(value)
            assert(not self.Destroyed,'Form has been destroyed')
            assert(type(value)=='table','Draft must be a record')
            local changes={}
            for key,item in pairs(value) do local control=assert(self.Fields[key],'Unknown form field');changes[key]=control:_normalize(item) end
            Library:Batch(function() for key,item in pairs(changes) do self.Fields[key]:SetValue(item,true) end end)
            render();return self
        end
        form.SetValue=form.SetDraft
        function form:_commit(value,silent)
            self._committed:Set(value)
            for key,control in pairs(self.Fields) do control:SetValue(value[key],true) end
            for _,errorLabel in pairs(self.Errors) do errorLabel:SetVisible(false) end
            render()
            if not silent then
                call(window,options.OnApply,copy(value),self)
                for _,field in ipairs(fields) do call(window,field.Callback,copy(value[field.Id]),self) end
                for listener in pairs(self._listeners) do if listener.Connected then call(window,listener.Callback,copy(value),self) end end
            end
        end
        function form:Apply()
            assert(not self.Destroyed,'Form has been destroyed')
            if self.Disabled then return false,'disabled' end
            local valid,value,errors=self:_prepare(values())
            for key,errorLabel in pairs(self.Errors) do errorLabel:SetText(errors[key] or '');errorLabel:SetVisible(errors[key]~=nil) end
            if not valid then self.Status:SetText(errors._form or window:_t17('Revise os campos destacados','Review highlighted fields'));return false,copy(errors) end
            if same(value,self._committed:Get()) then return false,'unchanged' end
            self:_commit(value,false);window:_scheduleSave();return true,self:GetValue()
        end
        function form:Cancel()
            assert(not self.Destroyed,'Form has been destroyed')
            self:SetDraft(self._committed:Get());for _,errorLabel in pairs(self.Errors) do errorLabel:SetVisible(false) end;return self
        end
        function form:OnChanged(callback)
            assert(type(callback)=='function','Form listener must be a function')
            local listener={Connected=true,Callback=callback}
            function listener:Disconnect() self.Connected=false;form._listeners[self]=nil end
            self._listeners[listener]=true;return listener
        end
        form:Manage(function()
            for listener in pairs(form._listeners) do listener.Connected=false end
            form._listeners={};form.Fields={};form.Errors={};window._forms[name]=nil
            if form.State and not form.State.Destroyed then form.State:Destroy() end
        end,nil,'form')
        render();return form
    end
    local export=Window._exportProfileExtras
    function Window:_exportProfileExtras(profile)
        export(self,profile)
        if self._forms and next(self._forms) then
            profile.Forms={};for name,form in pairs(self._forms) do if not form.Destroyed then profile.Forms[name]=form:GetValue() end end
        end
        return profile
    end
    local prepare=Window._prepareProfile
    function Window:_prepareProfile(source,options)
        local profile,extras,policy=prepare(self,source,options);local changes={}
        if profile.Forms~=nil then
            assert(type(profile.Forms)=='table','Profile Forms must be a record')
            for name,value in pairs(profile.Forms) do
                local form=self._forms and self._forms[name]
                if form and not form.Destroyed then
                    local valid,normalized=form:_prepare(value);assert(valid,'Profile contains invalid form: '..name);changes[#changes+1]={Form=form,Value=normalized}
                end
            end
        end
        self._preparedForms=changes;return profile,extras,policy
    end
    local import=Window.ImportConfig
    function Window:ImportConfig(source,options)
        self._preparedForms=nil
        local ok,reason=import(self,source,options);local changes=self._preparedForms;self._preparedForms=nil
        if ok then Library:Batch(function() for _,change in ipairs(changes or {}) do change.Form:_commit(change.Value,true) end end) end
        return ok,reason
    end
end
