-- Communication launcher. Keeps native control handles and the shared Window lifecycle.
do
    local View={};View.__index=View
    local categories={
        ScriptRequest={Title={'Pedir script','Request script'},Description={'Para um jogo do Roblox','For a Roblox game'},Icon='gamepad'},
        Suggestion={Title={'Sugestão','Suggestion'},Description={'Melhorias e novas funções','Improvements and features'},Icon='spark'},
        Feedback={Title={'Feedback','Feedback'},Description={'Conte sua experiência','Share your experience'},Icon='message'},
        BugReport={Title={'Relatar bug','Report a bug'},Description={'Algo não funcionou?','Something went wrong?'},Icon='warning'},
    }
    local captions={Compose={'Mensagem','Message'},Diagnostics={'Diagnóstico','Diagnostics'},Review={'Revisar','Review'}}
    local function rect(object,x,y,w,h) object.Position=U2(x,y);object.Size=U2(math.max(1,w),math.max(1,h)) end
    function View:_tr(pair) return self.Hub:_tr(pair[1],pair[2]) end
    function View:_alive() return not self.Destroyed and not self.Hub.Destroyed and not self.Window.Destroyed end
    function View:Route(name,fallback)
        if name=='Category' or name=='Intro' or name=='Message' or name=='Counter' then return self.Sections.Message end
        if name=='CurrentGame' or name=='Target' then return self.Sections.Target end
        if name=='MessagePreview' or name=='Notice' then return self.Sections.Review end
        if name=='Submit' or name=='Cancel' or name=='Retry' or name=='Clear' then return self.Sections.Actions end
        if name=='Status' then return self.Sections.Status end
        if name=='GamePreview' or name=='GameLink' or name=='PlaceId' or name=='Metadata' or name=='Identity' or name=='Avatar' then return self.Sections.Context end
        return fallback
    end
    function View:SetPage(page)
        assert(self:_alive() and captions[page] and (page~='Diagnostics' or self.Hub.Diagnostics),'Unknown or unavailable feedback page')
        if self.Page==page then return self end
        local w=self.Window
        if w._openDropdown then w._openDropdown:SetOpen(false) end
        w:_hideTooltip()
        local focused=UserInputService:GetFocusedTextBox()
        local ancestor=focused
        while ancestor and ancestor~=self.Tab.Frame do ancestor=ancestor.Parent end
        if ancestor then focused:ReleaseFocus(false) end
        self.Scroll[self.Page]=self.Tab.Frame.CanvasPosition;self.Page=page
        self:Refresh();self.Tab.Frame.CanvasPosition=self.Scroll[page] or Vector2.new(0,0)
        if w:_motionAllowed(self.Root) then w:_motion(self.Root,{Position=U2(0,0)},.12,'feedback-page',self) end
        return self
    end
    function View:LayoutChrome()
        if not self:_alive() or not self.Hub.OwnsWindow or self.Window.ActiveTab~=self.Tab then return end
        local w=self.Window
        w.Nav.Position=U2(12,76);w.Nav.Size=UDim2.new(1,-24,0,36)
        w.NavLayout.FillDirection=Enum.FillDirection.Horizontal;w.Nav.AutomaticCanvasSize=Enum.AutomaticSize.X;w.Nav.ScrollingDirection=Enum.ScrollingDirection.X
        for _,page in ipairs(w.Tabs) do
            local measured=TextService:GetTextSize(page.Label.Text,page.Label.TextSize,page.Label.Font,Vector2.new(100000,100000))
            page.Button.Size=U2(math.min(math.max(120,w._logicalSize.X-24),math.max(120,math.ceil(measured.X)+page.Label.Position.X.Offset+14)),34)
        end
        w.SearchContainer.Visible=false;w.Search.Visible=false
        w.PageHost.Position=U2(12,120);w.PageHost.Size=UDim2.new(1,-24,1,-184)
        if w.PixelMotif then w.PixelMotif.Visible=false end
    end
    function View:_styleActions()
        local h=self.Hub;local scale=self.Window.TextScale or 1;local height=math.max(42,math.ceil(13*scale+22))
        for _,name in ipairs({'Submit','Cancel','Retry','Clear'}) do
            local c=h.Controls[name]
            if c and not c.Destroyed then
                c.TitleLabel.Visible=false;c.DescriptionLabel.Visible=false
                c.Frame.Size=UDim2.new(1,0,0,height);c.Button.Position=U2(0,0);c.Button.Size=UDim2.new(1,0,0,height)
                local layout=c._descriptionLayout
                if layout then
                    layout.Height=height
                    local data=layout.Children[c.Button];if data then data.Position=U2(0,0);data.Size=UDim2.new(1,0,0,height) end
                end
                local icon=c._titleIcon
                if icon and not icon.Destroyed and icon.Frame and icon.Frame.Parent then
                    if icon.Frame.Parent~=c.Button then icon.Frame.Parent=c.Button end
                    icon.Frame.Position=U2(10,math.floor((height-icon.Size)/2))
                    icon:SetRole(name=='Submit' and 'AccentText' or 'Text')
                end
                c.Button.TextXAlignment=Enum.TextXAlignment.Center
                local pad=c.Button:FindFirstChild('FeedbackPadding')
                if not pad then pad=ui(self.Window,'UIPadding',{Name='FeedbackPadding',Parent=c.Button,PaddingLeft=UDim.new(0,32),PaddingRight=UDim.new(0,12)}) end
            end
        end
    end
    function View:Layout()
        if not self:_alive() or self.LayingOut then return end;self.LayingOut=true
        local w=self.Window;local scale=math.max(.01,w._actualScale or 1)
        local measured=self.Tab.Frame.AbsoluteSize.X/scale
        local width=math.max(240,(measured>1 and measured or (w._logicalSize and w._logicalSize.X-24 or 740))-10)
        self.Width=width;local gap=12
        local function height(object,text,size,available)
            local bounds=TextService:GetTextSize(text,size,object.Font,Vector2.new(math.max(1,available),100000))
            return math.max(size+3,bounds.Y+3)
        end
        local th=height(self.HeroTitle,self.HeroTitle.Text,self.HeroTitle.TextSize,width-24)
        local sh=height(self.HeroDescription,self.HeroDescription.Text,self.HeroDescription.TextSize,width-24)
        self.Hero.Size=UDim2.new(1,0,0,th+sh+28)
        rect(self.HeroTitle,12,10,width-24,th);rect(self.HeroDescription,12,th+15,width-24,sh)
        local columns=math.min(#self.Cards,width>=700 and 4 or width>=280 and 2 or 1)
        local cardWidth=(width-gap*(columns-1))/math.max(1,columns);local cardHeight=66
        for _,card in ipairs(self.Cards) do
            card.TitleHeight=height(card.Title,card.Title.Text,card.Title.TextSize,cardWidth-44)
            card.DescriptionHeight=height(card.Description,card.Description.Text,card.Description.TextSize,cardWidth-24)
            cardHeight=math.max(cardHeight,card.TitleHeight+card.DescriptionHeight+24)
        end
        for i,card in ipairs(self.Cards) do
            rect(card.Button,((i-1)%columns)*(cardWidth+gap),math.floor((i-1)/columns)*(cardHeight+gap),cardWidth,cardHeight)
            rect(card.Title,34,10,cardWidth-44,card.TitleHeight)
            rect(card.Description,12,card.TitleHeight+15,cardWidth-24,card.DescriptionHeight)
        end
        self.Categories.Size=UDim2.new(1,0,0,math.ceil(#self.Cards/math.max(1,columns))*(cardHeight+gap)-gap)
        local pages=#self.PageOrder;local minimum=90
        for _,key in ipairs(self.PageOrder) do
            local b=self.Pages[key];local size=TextService:GetTextSize(b.Text,b.TextSize,b.Font,Vector2.new(100000,100000));minimum=math.max(minimum,size.X+24)
        end
        local navCols=math.max(1,math.min(pages,math.floor((width+8)/(minimum+8))));local navWidth=(width-(navCols-1)*8)/navCols
        local navHeight=math.max(36,math.ceil(13*(w.TextScale or 1)+20))
        for i,key in ipairs(self.PageOrder) do rect(self.Pages[key],((i-1)%navCols)*(navWidth+8),math.floor((i-1)/navCols)*(navHeight+8),navWidth,navHeight) end
        self.Navigation.Size=UDim2.new(1,0,0,math.ceil(pages/navCols)*(navHeight+8)-8)
        local wide=width>=660;self.Wide=wide
        self.BodyLayout.FillDirection=wide and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
        self.Tab.Left.Size=wide and UDim2.new(.62,-6,0,0) or UDim2.new(1,0,0,0)
        self.Tab.Right.Size=wide and UDim2.new(.38,-6,0,0) or UDim2.new(1,0,0,0);self.Tab.Right.Visible=true
        local half=(width-8)/2;local footerHeight=math.max(42,math.ceil(13*(w.TextScale or 1)+22))
        rect(self.Back,0,0,self.Page=='Review' and width or half,footerHeight)
        rect(self.Next,half+8,0,half,footerHeight);self.Footer.Size=UDim2.new(1,0,0,footerHeight)
        self:_styleActions()
        self.LayingOut=false
    end
    function View:Finish(add)
        self.Ready=true
        self.Controls=self.Hub.Controls
        if self.Hub.Diagnostics then
            self.ReviewDiagnostic=add(self.Sections.DiagnosticReview,'AddLabel','ReviewDiagnostic','','',{Height=56})
            self.Window:SetTextTranslation(self.ReviewDiagnostic.Frame,false)
        end
        self.Hub.Controls.Intro:SetVisible(false);self.Hub.Controls.Category:SetVisible(false)
        local avatar=self.Hub.Controls.Avatar
        avatar:SetIcon(false)
        avatar.TitleLabel.Visible=false;avatar.DescriptionLabel.Visible=false
        avatar.Frame.Size=UDim2.new(1,0,0,64);avatar.Image.Position=U2(0,0);avatar.Image.Size=U2(64,64)
        if avatar._descriptionLayout then
            avatar._descriptionLayout.Height=64
            local data=avatar._descriptionLayout.Children[avatar.Image];if data then data.Position=U2(0,0);data.Size=U2(64,64) end
        end
        for name,control in pairs(self.Controls) do
            control._feedbackHub=self.Hub
            control._feedbackPage=name:sub(1,10)=='Diagnostic' and 'Diagnostics' or (name=='ReviewDiagnostic' or name=='MessagePreview' or name=='Notice' or name=='Submit' or name=='Retry' or name=='Cancel' or name=='Clear') and 'Review' or 'Compose'
        end
        self:Refresh()
    end
    function View:Refresh()
        if not self:_alive() or self.Refreshing then return end;self.Refreshing=true
        local h,w=self.Hub,self.Window
        self.HeroTitle.Text=h:_tr('Central de Ideias','Ideas Center')
        self.HeroDescription.Text=h:_tr('Sugira melhorias, peça um script ou relate um problema.','Suggest improvements, request a script or report a problem.')
        for _,card in ipairs(self.Cards) do
            local item=categories[card.Id];local selected=h.Category==card.Id
            card.Title.Text=self:_tr(item.Title);card.Description.Text=self:_tr(item.Description)
            w:_bind(card.Button,{BackgroundColor3=selected and 'Accent' or 'Surface',BorderColor3=selected and 'Accent' or 'Border'})
            w:_bind(card.Title,{TextColor3=selected and 'AccentText' or 'Text'})
            w:_bind(card.Description,{TextColor3=selected and 'AccentText' or 'Muted'})
            card.Icon:SetRole(selected and 'AccentText' or 'Accent')
        end
        for key,b in pairs(self.Pages) do b.Text=self:_tr(captions[key]);w:_bind(b,{BackgroundColor3=self.Page==key and 'Accent' or 'Inset',TextColor3=self.Page==key and 'AccentText' or 'Text'}) end
        local titles={Target={'Jogo do relato','Report game'},Message={'Escreva sua mensagem','Write your message'},Review={'Confira antes de enviar','Review before sending'},Diagnostics={'Diagnóstico opcional','Optional diagnostics'},DiagnosticReview={'Diagnóstico anexado','Attached diagnostics'},Context={'Jogo e jogador','Game and player'},Status={'Status do envio','Delivery status'},Actions={'Enviar relato','Send report'}}
        for key,pair in pairs(titles) do self.Sections[key]:SetTitle(self:_tr(pair)) end
        self.Hero.Visible=self.Page=='Compose';self.Categories.Visible=self.Page=='Compose'
        if self.Ready then
            local c=h.Controls;local active=self.Page
            local included=h.Diagnostics and c.DiagnosticInclude:GetValue()
            local visibility={Target=active=='Compose',Message=active=='Compose',Review=active=='Review',Diagnostics=active=='Diagnostics',DiagnosticReview=active=='Review' and included,Context=true,Status=true,Actions=active=='Review' or h._operation~=nil}
            for key,section in pairs(self.Sections) do section._visible=visibility[key]==true;section.Frame.Visible=section._visible end
            c.Submit:SetVisible(active=='Review');c.Clear:SetVisible(active=='Review')
            c.Retry:SetVisible(active=='Review' and not h._operation and h:GetStatus().State=='Unconfirmed')
            if active=='Review' then
                local message=h:GetDraft().Message:gsub('\r\n','\n'):gsub('\r','\n'):gsub('^%s+',''):gsub('%s+$','')
                c.MessagePreview:SetText(message);c.MessagePreview:SetDescription('')
                if self.ReviewDiagnostic then local d=h.Diagnostics:Snapshot();self.ReviewDiagnostic:SetText(h.Diagnostics:Format(d)) end
            end
            c.Avatar.TitleLabel.Visible=false;c.Avatar.DescriptionLabel.Visible=false
        end
        self.Back.Visible=self.Page~='Compose';self.Back.Text=h:_tr('Editar mensagem','Edit message')
        self.Next.Visible=self.Page~='Review';self.Next.Text=h:_tr('Revisar envio','Review submission')
        self:Layout();self.Refreshing=false
    end
    function View:Destroy()
        if self.Destroyed then return end;self.Destroyed=true
        cleanup(self);self.Scope:Destroy();self.Cards={};self.Pages={};self.Controls=nil;self.Ready=false
    end
    function Window:_createFeedbackLauncher(hub)
        local v=setmetatable({Hub=hub,Window=self,Tab=hub.Tab,Scope=hub.Scope:Child(),Page='Compose',PageOrder={'Compose'},Scroll={},Cards={},Pages={},Sections={},_connections={},Launcher=true},View)
        if hub.Options.Diagnostics then v.PageOrder[#v.PageOrder+1]='Diagnostics' end;v.PageOrder[#v.PageOrder+1]='Review'
        local tab=v.Tab;tab.Columns=2;tab.Container.Visible=false
        v.Root=frame(self,tab.Frame,{Name='FeedbackLauncher',Size=UDim2.new(1,-10,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1})
        list(self,v.Root,12)
        v.Hero=frame(self,v.Root,{Name='FeedbackWelcome',LayoutOrder=1,Size=UDim2.new(1,0,0,80)},'Inset')
        v.HeroTitle=label(self,v.Hero,'',{Name='FeedbackHeading',TextSize=19,TextWrapped=true,TextTruncate=Enum.TextTruncate.None},'Accent')
        v.HeroDescription=label(self,v.Hero,'',{TextSize=12,TextWrapped=true,TextTruncate=Enum.TextTruncate.None},'Muted')
        v.Categories=frame(self,v.Root,{Name='FeedbackCategories',LayoutOrder=2,Size=UDim2.new(1,0,0,150),BackgroundTransparency=1})
        for _,id in ipairs(hub.Options.Categories) do
            local item=categories[id];local card={Id=id}
            card.Button=button(self,v,v.Categories,'',{Name='FeedbackCategory_'..id,Text='',BorderSizePixel=1},function() if v:_alive() then hub:SetCategory(id) end end)
            card.Title=label(self,card.Button,'',{TextSize=13,TextWrapped=true,TextTruncate=Enum.TextTruncate.None},'Text')
            card.Description=label(self,card.Button,'',{TextSize=11,TextWrapped=true,TextTruncate=Enum.TextTruncate.None},'Muted')
            card.Icon=iconSlot(self,card.Button,item.Icon,nil,16,U2(10,11),'Accent')
            v.Cards[#v.Cards+1]=card
        end
        v.Navigation=frame(self,v.Root,{Name='FeedbackPages',LayoutOrder=3,Size=UDim2.new(1,0,0,36),BackgroundTransparency=1})
        for _,key in ipairs(v.PageOrder) do v.Pages[key]=button(self,v,v.Navigation,'',{Name='FeedbackPage_'..key,TextSize=12},function() if v:_alive() then v:SetPage(key) end end) end
        v.Body=frame(self,v.Root,{Name='FeedbackWorkspace',LayoutOrder=4,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1})
        v.BodyLayout=list(self,v.Body,12,true);tab.Left.Parent=v.Body;tab.Right.Parent=v.Body
        for _,item in ipairs({{'Target','Left'},{'Message','Left'},{'Diagnostics','Left'},{'Review','Left'},{'DiagnosticReview','Left'},{'Context','Right'},{'Status','Right'},{'Actions','Right'}}) do
            v.Sections[item[1]]=tab:CreateSection({Title=item[1],Side=item[2]=='Right' and 'Right' or nil})
        end
        v.Footer=frame(self,v.Root,{Name='FeedbackNavigation',LayoutOrder=5,Size=UDim2.new(1,0,0,42),BackgroundTransparency=1})
        v.Back=button(self,v,v.Footer,'',{Name='FeedbackBack'},function() if v:_alive() then v:SetPage('Compose') end end)
        v.Next=button(self,v,v.Footer,'',{Name='FeedbackReview'},function() if v:_alive() then v:SetPage('Review') end end)
        local oldLayout=tab._layout
        tab._layout=function(page,...) oldLayout(page,...);if v:_alive() then v:Layout() end end
        v.Scope:Add(tab.Frame:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() if v:_alive() then v:Layout() end end),'Disconnect')
        v.Scope:Add(tab.Frame:GetPropertyChangedSignal('Visible'):Connect(function() if v:_alive() then self:_layout();v:Refresh() end end),'Disconnect')
        tab._toolManager=v
        for _,object in ipairs({v.HeroTitle,v.HeroDescription}) do self:SetTextTranslation(object,false) end
        return v
    end
    local layout=Window._layout
    function Window:_layout(...)
        layout(self,...)
        for _,hub in pairs(self._feedbackHubs or {}) do if hub.Launcher and not hub.Destroyed then hub.Launcher:LayoutChrome();hub.Launcher:Layout() end end
    end
    local textScale=Window.SetTextScale
    function Window:SetTextScale(...)
        local result=textScale(self,...)
        for _,hub in pairs(self._feedbackHubs or {}) do if hub.Launcher and not hub.Destroyed then hub.Launcher:Layout() end end
        return result
    end
    local focus=Window.FocusControl
    function Window:FocusControl(control)
        local target=type(control)=='string' and self.Controls[control] or control
        if target and target._feedbackHub and not target._feedbackHub.Destroyed and target._feedbackHub.Launcher then target._feedbackHub.Launcher:SetPage(target._feedbackPage) end
        return focus(self,control)
    end
end
