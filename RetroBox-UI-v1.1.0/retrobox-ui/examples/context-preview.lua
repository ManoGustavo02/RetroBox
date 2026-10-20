-- Image/model/custom previews share scoped ownership; originals are preserved.
local RetroBox=loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({Channel='stable',MinVersion='2.2.0'})
local window=RetroBox:CreateWindow({Id='preview-demo',Title='RetroBox / Previews',Locale='pt-BR'})
local tab=window:CreateTab({Title='Previews',Icon='image',Columns=2})
local section=tab:CreateSection('Imagem e objeto 3D')
section:AddPreview({Title='Imagem',Description='Arraste para girar; use + e - para zoom.',Image='rbxthumb://type=AvatarHeadShot&id='..game:GetService('Players').LocalPlayer.UserId..'&w=420&h=420',
    OnApply=function(snapshot) window:Notify({Content='Zoom escolhido: '..snapshot.View.Zoom}) end})
local model=Instance.new('Model'); model.Name='Bloco de demonstração'
local part=Instance.new('Part'); part.Name='Bloco'; part.Size=Vector3.new(3,4,2); part.CFrame=CFrame.new(0,0,0); part.Color=Color3.fromRGB(64,220,160); part.Anchored=true; part.Parent=model
local preview=section:AddPreview({Title='Modelo 3D',Description='Apenas uma cópia é exibida.',Model=model})
model:Destroy() -- Preview owns its clone, not the source.
local custom=tab:CreateSection({Title='Preview personalizado',Side='Right'})
custom:AddPreview({Title='Animação local',Mode='Custom',Render=function(container,scope)
    local square=Instance.new('Frame'); square.Name='AnimatedSample'; square.Size=UDim2.fromOffset(64,64); square.AnchorPoint=Vector2.new(.5,.5)
    square.Position=UDim2.fromScale(.5,.5); square.BackgroundColor3=Color3.fromRGB(100,180,255); square.BorderSizePixel=0; square.Parent=container
    if not window.ReducedMotion then
        local tween=game:GetService('TweenService'):Create(square,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Rotation=180})
        scope:Add(function() tween:Cancel(); tween:Destroy() end); tween:Play()
    end
end})
-- Rig previews may call preview:PlayAnimation(assetId,{Looped=true}); the rig
-- needs a Humanoid/AnimationController and an animation accessible to the client.
return window,preview
