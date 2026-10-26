-- A bounded recycled card viewport; scrolling does not create one UI per item.
do
    local function items(value)
        assert(type(value)=='table' and #value<=5000,'CardGrid accepts at most 5000 Items')
        local result,ids={},{}
        for key in pairs(value) do assert(type(key)=='number' and key%1==0 and key>=1 and key<=#value,'Items must be a dense array') end
        for index,record in ipairs(value) do
            assert(type(record)=='table' and type(record.Id)=='string' and #record.Id>=1 and #record.Id<=128 and not ids[record.Id],'Card Ids must be unique nonempty strings')
            local entry={Id=record.Id,Title=record.Title or record.Id,Description=record.Description or '',Image=record.Image,Icon=record.Icon,Category=record.Category or '',
                Badges={},Enabled=record.Enabled~=false,Translate=record.Translate~=false}
            for _,key in ipairs({'Title','Description','Category'}) do assert(type(entry[key])=='string' and #entry[key]<=2048,'Invalid card '..key) end
            assert(entry.Image==nil or type(entry.Image)=='string' and #entry.Image<=2048,'Invalid card Image');resolveIcon(entry.Icon)
            assert(record.Badges==nil or type(record.Badges)=='table' and #record.Badges<=4,'Card accepts at most four Badges')
            for _,badge in ipairs(record.Badges or {}) do assert(type(badge)=='string' and #badge<=64,'Invalid card Badge');entry.Badges[#entry.Badges+1]=badge end
            result[index]=entry;ids[entry.Id]=index
        end
        return result,ids
    end
    function Section:AddCardGrid(options)
        options=options or {};local initial,index=items(options.Items or {})
        local height=options.Height or 340;local cardHeight=options.CardHeight or 158;local minWidth=options.MinCardWidth or 180
        local gap=options.Gap or 10;local columns=options.Columns
        assert(finite(height) and height>=180 and height<=900,'Grid Height must be 180–900')
        assert(finite(cardHeight) and cardHeight>=120 and cardHeight<=300,'CardHeight must be 120–300')
        assert(finite(minWidth) and minWidth>=140 and minWidth<=600,'MinCardWidth must be 140–600')
        assert(finite(gap) and gap>=0 and gap<=24,'Grid Gap must be 0–24')
        assert(columns==nil or finite(columns) and columns%1==0 and columns>=1 and columns<=6,'Columns must be 1–6')
        assert(options.OnActivate==nil or type(options.OnActivate)=='function','OnActivate must be a function')
        local actions,actionIds={},{}
        for _,action in ipairs(options.Actions or {}) do
            assert(#actions<3 and type(action)=='table' and type(action.Id)=='string' and not actionIds[action.Id],'Grid accepts at most three unique Actions')
            assert(type(action.Text)=='string' and #action.Text<=64 and type(action.Callback)=='function','Action needs Text and Callback')
            actions[#actions+1]={Id=action.Id,Text=action.Text,Callback=action.Callback};actionIds[action.Id]=true
        end
        local self=base(self,'CardGrid',options,height);local window=self._window
        self.Persist=options.Persist==true;self.Items=initial;self._cardIndex=index;self._cards={};self._filtered={};self.Query='';self.Filter=nil
        local top=#self.Description>0 and 46 or 26
        if options.Searchable~=false then
            self.Search=ui(window,'TextBox',{Parent=self.Frame,Position=U2(0,top),Size=UDim2.new(1,0,0,28),Text='',PlaceholderText=window:_t17('Pesquisar cards…','Search cards…'),
                Font=window.Font,TextSize=12,ClearTextOnFocus=false,BorderSizePixel=1},{BackgroundColor3='Inset',TextColor3='Text',PlaceholderColor3='Muted',BorderColor3='Border'})
            top=top+34
            connect(self,self.Search:GetPropertyChangedSignal('Text'),function() self:SetQuery(self.Search.Text) end)
            window:_watchField(self.Search)
        end
        self.Viewport=ui(window,'ScrollingFrame',{Parent=self.Frame,Position=U2(0,top),Size=UDim2.new(1,0,1,-top),CanvasSize=U2(0,0),CanvasPosition=Vector2.new(0,0),
            BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,ScrollingDirection=Enum.ScrollingDirection.Y,ClipsDescendants=true},{ScrollBarImageColor3='Accent'})
        self.Empty=label(window,self.Viewport,options.EmptyText or window:_t17('Nenhum card encontrado','No cards found'),{Size=UDim2.new(1,-8,0,48),TextWrapped=true},'Muted')
        local function makeCard()
            local card={}
            card.Frame=ui(window,'TextButton',{Parent=self.Viewport,Text='',AutoButtonColor=false,BorderSizePixel=1,ClipsDescendants=true},
                {BackgroundColor3='Surface',BorderColor3='Border'})
            card.Icon=iconSlot(window,card.Frame,nil,'grid',24,U2(8,8),'Text')
            self:Manage(card.Icon,'Destroy')
            card.Image=ui(window,'ImageLabel',{Parent=card.Frame,Position=U2(8,8),Size=U2(28,28),BackgroundTransparency=1,Image='',Visible=false})
            card.Title=label(window,card.Frame,'',{Position=U2(40,7),Size=UDim2.new(1,-48,0,24),TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd})
            card.Description=label(window,card.Frame,'',{Position=U2(8,40),Size=UDim2.new(1,-16,0,44),TextSize=11,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,TextTruncate=Enum.TextTruncate.AtEnd},'Muted')
            card.Badges=label(window,card.Frame,'',{Position=U2(8,87),Size=UDim2.new(1,-16,0,18),TextSize=10,TextTruncate=Enum.TextTruncate.AtEnd},'Accent')
            card.Actions={}
            for i,action in ipairs(actions) do
                card.Actions[i]=button(window,self,card.Frame,action.Text,{Position=UDim2.new((i-1)/#actions,6,1,-34),Size=UDim2.new(1/#actions,-12,0,27),TextSize=10},function()
                    local record=card.Record
                    if not self.Disabled and record and record.Enabled and not self.Destroyed then call(window,action.Callback,copy(record),self) end
                end)
            end
            connect(self,card.Frame.Activated,function()
                local record=card.Record
                if self.Destroyed or self.Disabled or not record or not record.Enabled then return end
                self:SetValue(record.Id);call(window,options.OnActivate,copy(record),self)
            end)
            self._cards[#self._cards+1]=card;return card
        end
        function self:_normalize(value)
            assert(value==nil or type(value)=='string' and self._cardIndex[value],'Unknown card Id')
            return value
        end
        function self:_filterCards()
            self._filtered={}
            for _,record in ipairs(self.Items) do
                local haystack=(record.Title..' '..record.Description..' '..record.Category..' '..table.concat(record.Badges,' ')):lower()
                if (self.Query=='' or haystack:find(self.Query:lower(),1,true)) and (not self.Filter or record.Category==self.Filter or table.find(record.Badges,self.Filter)) then
                    self._filtered[#self._filtered+1]=record
                end
            end
        end
        function self:_render()
            if self.Destroyed or not self.Viewport or not self.Viewport.Parent then return end
            local width=math.max(140,self.Viewport.AbsoluteSize.X-8)
            local count=columns or math.max(1,math.min(6,math.floor((width+gap)/(minWidth+gap))))
            local cardWidth=(width-(count-1)*gap)/count
            local rows=math.ceil(#self._filtered/count);local step=cardHeight+gap
            self.Viewport.CanvasSize=U2(0,rows*step)
            local viewportHeight=math.max(100,self.Viewport.AbsoluteSize.Y)
            local first=math.max(0,math.floor(self.Viewport.CanvasPosition.Y/step)-1)
            local pool=math.min(64,math.max(0,math.min(rows-first,math.ceil(viewportHeight/step)+3))*count)
            self.Empty.Visible=#self._filtered==0
            for i=1,pool do
                local card=self._cards[i] or makeCard();local itemIndex=first*count+i;local record=self._filtered[itemIndex]
                local entering=record and (not card.Record or card.Record.Id~=record.Id or not card.Frame.Visible)
                if entering or not record then window:_cancelAnimations(card.Frame,false) end
                card.Frame.Visible=record~=nil;card.Record=record
                if record then
                    card.Frame.Position=U2(((i-1)%count)*(cardWidth+gap),(first+math.floor((i-1)/count))*step)
                    card.Frame.Size=U2(cardWidth,cardHeight);card.Frame.Active=not self.Disabled and record.Enabled
                    window:_bind(card.Frame,{BorderColor3=record.Id==self.Value and 'Accent' or 'Border'})
                    card.Title.Text=record.Title;card.Description.Text=record.Description;card.Badges.Text=table.concat(record.Badges,' · ')
                    card.Icon:Set(record.Image and false or record.Icon);card.Image.Visible=record.Image~=nil;card.Image.Image=record.Image or ''
                    card.Title.TextTransparency=record.Enabled and 0 or .4
                    card.Description.TextTransparency=0;card.Badges.TextTransparency=0;card.Image.ImageTransparency=0
                    window:_selectionMark(card.Frame,record.Id==self.Value,self)
                    if entering and record.Enabled and not self.Disabled and options.Animated~=false then
                        for _,text in ipairs({card.Title,card.Description,card.Badges}) do window:_revealText(text,self,'card-enter') end
                        if card.Image.Visible then window:_revealText(card.Image,self,'card-enter') end
                    end
                    for _,action in ipairs(card.Actions) do action.Active=not self.Disabled and record.Enabled end
                    window:SetTextTranslation(card.Frame,options.Translate~=false and record.Translate)
                end
            end
            for i=pool+1,#self._cards do window:_cancelAnimations(self._cards[i].Frame,false);self._cards[i].Frame.Visible=false;self._cards[i].Record=nil end
            self._columnCount=count
        end
        function self:SetQuery(value)
            assert(type(value)=='string' and #value<=256,'Grid query exceeds 256 bytes')
            self.Query=value;self:_filterCards();self.Viewport.CanvasPosition=Vector2.new(0,0);self:_render();return self
        end
        function self:SetFilter(value)
            assert(value==nil or type(value)=='string' and #value<=64,'Filter must be a category or badge')
            self.Filter=value;self:SetQuery(self.Query);return self
        end
        function self:SetItems(value)
            local prepared,ids=items(value);self.Items=prepared;self._cardIndex=ids
            if self.Value and not ids[self.Value] then self:SetValue(nil,true) end
            self:SetQuery(self.Query);return self
        end
        function self:GetItems() return copy(self.Items) end
        function self:GetSelectedItem() local selected=self._cardIndex[self.Value];return selected and copy(self.Items[selected]) or nil end
        function self:GetViewStats() return {Total=#self.Items,Filtered=#self._filtered,Pool=#self._cards,Columns=self._columnCount} end
        connect(self,self.Viewport:GetPropertyChangedSignal('CanvasPosition'),function() self:_render() end)
        connect(self,self.Viewport:GetPropertyChangedSignal('AbsoluteSize'),function() self:_render() end)
        self:Manage(function() self.Items={};self._filtered={};self._cards={};self._cardIndex={};self.Viewport=nil;self.Empty=nil;self.Search=nil end)
        self:_filterCards();return init(self,options,nil)
    end
end
