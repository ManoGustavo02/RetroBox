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
        if w:_motionAllowed(self.Root) then
            self.Root.Position=U2(0,10)
            w:_motion(self.Root,{Position=U2(0,0)},.22,'feedback-page',self,nil,{Easing='Quint'})
            for _,section in pairs(self.Sections) do if section.Frame.Visible and section.TitleLabel then w:_revealText(section.TitleLabel,self,'feedback-section') end end
        end
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
        -- Header: accent rail, icon tile and wrapped copy beside it.
        local tile=width>=300 and 44 or 0;local textX=tile>0 and 18+tile+14 or 16
        local th=height(self.HeroTitle,self.HeroTitle.Text,self.HeroTitle.TextSize,width-textX-14)
        local sh=height(self.HeroDescription,self.HeroDescription.Text,self.HeroDescription.TextSize,width-textX-14)
        local heroHeight=math.max(tile+28,th+sh+30)
        self.Hero.Size=UDim2.new(1,0,0,heroHeight)
        rect(self.HeroBar,0,0,4,heroHeight);self.HeroTile.Visible=tile>0
        if tile>0 then rect(self.HeroTile,18,math.floor((heroHeight-tile)/2),tile,tile) end
        rect(self.HeroTitle,textX,12,width-textX-14,th);rect(self.HeroDescription,textX,th+17,width-textX-14,sh)
        local columns=math.min(#self.Cards,width>=700 and 4 or width>=280 and 2 or 1)
        local cardWidth=(width-gap*(columns-1))/math.max(1,columns);local cardHeight=74
        for _,card in ipairs(self.Cards) do
            card.TitleHeight=height(card.Title,card.Title.Text,card.Title.TextSize,cardWidth-74)
            card.DescriptionHeight=height(card.Description,card.Description.Text,card.Description.TextSize,cardWidth-26)
            card.Top=math.max(44,card.TitleHeight+20)
            cardHeight=math.max(cardHeight,card.Top+card.DescriptionHeight+12)
        end
        for i,card in ipairs(self.Cards) do
            rect(card.Button,((i-1)%columns)*(cardWidth+gap),math.floor((i-1)/columns)*(cardHeight+gap),cardWidth,cardHeight)
            rect(card.Tile,12,12,28,28);rect(card.Bar,0,0,cardWidth,3)
            rect(card.Title,50,14,cardWidth-74,card.TitleHeight)
            rect(card.Description,13,card.Top,cardWidth-26,card.DescriptionHeight)
            if card.Check.Frame then card.Check.Frame.Position=U2(cardWidth-24,10) end
        end
        self.Categories.Size=UDim2.new(1,0,0,math.ceil(#self.Cards/math.max(1,columns))*(cardHeight+gap)-gap)
        local pages=#self.PageOrder;local minimum=90
        for _,key in ipairs(self.PageOrder) do
            local b=self.Pages[key];local size=TextService:GetTextSize(b.Text,b.TextSize,b.Font,Vector2.new(100000,100000));minimum=math.max(minimum,size.X+52)
        end
        local navCols=math.max(1,math.min(pages,math.floor((width+8)/(minimum+8))));local navWidth=(width-(navCols-1)*8)/navCols
        local navHeight=math.max(38,math.ceil(13*(w.TextScale or 1)+22))
        for i,key in ipairs(self.PageOrder) do
            local b=self.Pages[key];rect(b,((i-1)%navCols)*(navWidth+8),math.floor((i-1)/navCols)*(navHeight+8),navWidth,navHeight)
            local badge=self.Badges[key];rect(badge.Frame,-31,math.floor((navHeight-22)/2),22,22)
        end
        self.Rail.Visible=navCols==pages and pages>1
        rect(self.Rail,math.floor(navWidth/2),math.floor(navHeight/2)-1,math.max(1,width-navWidth),2)
        self.Navigation.Size=UDim2.new(1,0,0,math.ceil(pages/navCols)*(navHeight+8)-8)
        local done=self.Success.Visible and self.SuccessTitle
        if done then
            local textW=width-90-math.min(190,width*.36)
            local sh2=height(self.SuccessMessage,self.SuccessMessage.Text,self.SuccessMessage.TextSize,math.max(80,textW))
            local successHeight=math.max(76,sh2+44)
            local stacked=width<420
            if stacked then successHeight=successHeight+48 end
            self.Success.Size=UDim2.new(1,0,0,successHeight)
            rect(self.SuccessBar,0,0,4,successHeight);rect(self.SuccessTile,18,14,40,40)
            local tw=stacked and width-90 or textW
            rect(self.SuccessTitle,72,12,tw,22);rect(self.SuccessMessage,72,36,tw,sh2)
            local bw=stacked and width-90 or math.min(190,width*.36)-16
            rect(self.Again,stacked and 72 or width-bw-14,stacked and successHeight-46 or math.floor((successHeight-38)/2),bw,36)
        end
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
        local counter=self.Hub.Controls.Counter
        self.CounterTrack=frame(self.Window,counter.Frame,{Name='FeedbackLengthTrack',Position=UDim2.new(0,0,1,-4),Size=UDim2.new(1,0,0,3)},'Border')
        self.CounterFill=frame(self.Window,self.CounterTrack,{Name='FeedbackLengthFill',Size=UDim2.new(0,0,1,0)},'Muted')
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
            w:_bind(card.Button,{BackgroundColor3='Surface',BorderColor3=selected and 'Accent' or 'Border'})
            card.Button.BorderSizePixel=selected and 2 or 1
            w:_bind(card.Tile,{BackgroundColor3=selected and 'Accent' or 'Inset'})
            w:_bind(card.Title,{TextColor3=selected and 'Accent' or 'Text'})
            w:_bind(card.Description,{TextColor3='Muted'})
            card.Icon:SetRole(selected and 'AccentText' or 'Accent')
            if card.Selected~=selected then
                card.Selected=selected
                card.Check:Set(selected and 'check' or false)
                if selected and card.Check.Frame then card.Check:SetRole('Accent') end
                if selected and w:_motionAllowed(card.Bar) then card.Bar.Size=UDim2.new(0,0,0,3);card.Bar.Visible=true;w:_motion(card.Bar,{Size=UDim2.new(1,0,0,3)},.24,'feedback-card',self,nil,{Easing='Quint'})
                else card.Bar.Visible=selected;card.Bar.Size=UDim2.new(1,0,0,3) end
            end
        end
        local current=table.find(self.PageOrder,self.Page) or 1
        for index,key in ipairs(self.PageOrder) do
            local b=self.Pages[key];local badge=self.Badges[key];local state=index==current and 'Active' or index<current and 'Done' or 'Next'
            b.Text=self:_tr(captions[key])
            w:_bind(b,{BackgroundColor3=state=='Active' and 'Accent' or state=='Done' and 'Surface' or 'Inset',TextColor3=state=='Active' and 'AccentText' or state=='Done' and 'Text' or 'Muted',BorderColor3=state=='Next' and 'Border' or 'Accent'})
            w:_bind(badge.Frame,{BackgroundColor3=state=='Active' and 'AccentText' or state=='Done' and 'Success' or 'Border'})
            badge.Digit.Text=state=='Done' and '' or tostring(index)
            w:_bind(badge.Digit,{TextColor3=state=='Active' and 'Accent' or 'Text'})
            badge.Check:Set(state=='Done' and 'check' or false)
        end
        w:_bind(self.Rail,{BackgroundColor3=current>1 and 'Accent' or 'Border'})
        local titles={Target={'Jogo do relato','Report game'},Message={'Escreva sua mensagem','Write your message'},Review={'Confira antes de enviar','Review before sending'},Diagnostics={'Diagnóstico opcional','Optional diagnostics'},DiagnosticReview={'Diagnóstico anexado','Attached diagnostics'},Context={'Jogo e jogador','Game and player'},Status={'Status do envio','Delivery status'},Actions={'Enviar relato','Send report'}}
        for key,pair in pairs(titles) do self.Sections[key]:SetTitle(self:_tr(pair)) end
        self.Hero.Visible=self.Page=='Compose';self.Categories.Visible=self.Page=='Compose'
        local status=h._ready and h:GetStatus()
        local sent=status and status.State=='Sent' or false
        if sent and not self.Success.Visible then
            self.Success.Visible=true
            if w:_motionAllowed(self.SuccessScale) then self.SuccessScale.Scale=.6;w:_motion(self.SuccessScale,{Scale=1},.32,'feedback-success',self,nil,{Easing='Back'}) end
            w:_revealText(self.SuccessTitle,self,'feedback-success-text')
        elseif not sent then self.Success.Visible=false end
        if sent then
            self.SuccessTitle.Text=h:_tr('Mensagem enviada!','Message sent!');self.SuccessMessage.Text=status.Message
            self.Again.Text=h:_tr('Escrever outra','Write another')
        end
        if self.CounterFill and h.Controls and h.Controls.Message then
            local text=h:GetDraft().Message:gsub('^%s+',''):gsub('%s+$','')
            local n=utf8.len(text) or #text;local o=h.Options
            local role=n>o.MaxLength and 'Danger' or n<o.MinLength and 'Muted' or 'Accent'
            w:_bind(self.CounterFill,{BackgroundColor3=role})
            w:_motion(self.CounterFill,{Size=UDim2.new(math.min(1,n/math.max(1,o.MaxLength)),0,1,0)},.14,'feedback-length',self)
        end
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
        w:_bind(self.Next,{BackgroundColor3='Accent',TextColor3='AccentText'})
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
        -- Delivery confirmation: shown only after a confirmed Sent result.
        v.Success=frame(self,v.Root,{Name='FeedbackSent',LayoutOrder=0,Size=UDim2.new(1,0,0,76),BorderSizePixel=1,Visible=false},'Surface')
        self:_bind(v.Success,{BackgroundColor3='Surface',BorderColor3='Success'})
        v.SuccessBar=frame(self,v.Success,{Name='SuccessRail'},'Success')
        v.SuccessTile=frame(self,v.Success,{Name='SuccessTile'},'Success')
        v.SuccessScale=ui(self,'UIScale',{Parent=v.SuccessTile,Scale=1})
        v.SuccessIcon=iconSlot(self,v.SuccessTile,'check',nil,24,U2(8,8),'AccentText')
        v.SuccessTitle=label(self,v.Success,'',{Name='SuccessTitle',TextSize=16,TextTruncate=Enum.TextTruncate.AtEnd},'Success')
        v.SuccessMessage=label(self,v.Success,'',{Name='SuccessMessage',TextSize=12,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top},'Muted')
        v.Again=button(self,v,v.Success,'',{Name='FeedbackWriteAnother',TextSize=12},function()
            if v:_alive() then hub:ClearDraft();v:SetPage('Compose') end
        end)
        v.Hero=frame(self,v.Root,{Name='FeedbackWelcome',LayoutOrder=1,Size=UDim2.new(1,0,0,80),BorderSizePixel=1},'Surface')
        self:_bind(v.Hero,{BackgroundColor3='Surface',BorderColor3='Border'})
        v.HeroBar=frame(self,v.Hero,{Name='HeroRail'},'Accent')
        v.HeroTile=frame(self,v.Hero,{Name='HeroTile'},'Accent')
        v.HeroIcon=iconSlot(self,v.HeroTile,'notification',nil,24,U2(10,10),'AccentText')
        v.HeroTitle=label(self,v.Hero,'',{Name='FeedbackHeading',TextSize=19,TextWrapped=true,TextTruncate=Enum.TextTruncate.None},'Text')
        v.HeroDescription=label(self,v.Hero,'',{TextSize=12,TextWrapped=true,TextTruncate=Enum.TextTruncate.None},'Muted')
        v.Categories=frame(self,v.Root,{Name='FeedbackCategories',LayoutOrder=2,Size=UDim2.new(1,0,0,150),BackgroundTransparency=1})
        for _,id in ipairs(hub.Options.Categories) do
            local item=categories[id];local card={Id=id}
            card.Button=button(self,v,v.Categories,'',{Name='FeedbackCategory_'..id,Text='',BorderSizePixel=1},function() if v:_alive() then hub:SetCategory(id) end end)
            card.Bar=frame(self,card.Button,{Name='SelectedRail',Size=UDim2.new(1,0,0,3),Visible=false,ZIndex=card.Button.ZIndex+2},'Accent')
            card.Tile=frame(self,card.Button,{Name='IconTile',ZIndex=card.Button.ZIndex+1},'Inset')
            card.Title=label(self,card.Button,'',{TextSize=13,TextWrapped=true,TextTruncate=Enum.TextTruncate.None},'Text')
            card.Description=label(self,card.Button,'',{TextSize=11,TextWrapped=true,TextTruncate=Enum.TextTruncate.None},'Muted')
            card.Icon=iconSlot(self,card.Tile,item.Icon,nil,16,U2(6,6),'Accent')
            card.Check=iconSlot(self,card.Button,false,nil,12,U2(0,10),'Accent')
            v.Cards[#v.Cards+1]=card
        end
        v.Navigation=frame(self,v.Root,{Name='FeedbackPages',LayoutOrder=3,Size=UDim2.new(1,0,0,36),BackgroundTransparency=1})
        v.Rail=frame(self,v.Navigation,{Name='StepRail',Size=UDim2.new(1,0,0,2)},'Border')
        v.Badges={}
        for _,key in ipairs(v.PageOrder) do
            local b=button(self,v,v.Navigation,'',{Name='FeedbackPage_'..key,TextSize=12,BorderSizePixel=1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},function() if v:_alive() then v:SetPage(key) end end)
            ui(self,'UIPadding',{Name='StepPadding',Parent=b,PaddingLeft=UDim.new(0,40),PaddingRight=UDim.new(0,8)})
            local badge={Frame=frame(self,b,{Name='StepBadge',Size=U2(22,22),ZIndex=5},'Border')}
            badge.Frame.Position=U2(-31,8)
            badge.Digit=label(self,badge.Frame,'',{Name='StepNumber',Size=UDim2.fromScale(1,1),TextSize=12,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=6})
            badge.Check=iconSlot(self,badge.Frame,false,nil,12,U2(5,5),'AccentText')
            v.Pages[key]=b;v.Badges[key]=badge
        end
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
