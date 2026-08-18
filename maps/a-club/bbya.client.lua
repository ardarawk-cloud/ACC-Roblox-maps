-- BBYA Social Hub v1.3.1 client: mobile-safe UI, cinematic cam, graphics, dance/sync
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("BBYA_Remotes")
local Dance=remotes:WaitForChild("Dance")
local Sync=remotes:WaitForChild("SyncDance")
local FX=remotes:WaitForChild("FX")
local TP=remotes:WaitForChild("Teleport")

local gui=Instance.new("ScreenGui")
gui.Name="BBYA_UI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=false
gui.DisplayOrder=20
gui.Parent=player:WaitForChild("PlayerGui")

local open=Instance.new("TextButton")
open.Size=UDim2.fromOffset(72,34)
open.Position=UDim2.new(0,10,1,-46)
open.Text="BBYA"
open.Font=Enum.Font.GothamBold
open.TextSize=18
open.BackgroundColor3=Color3.fromRGB(35,18,48)
open.TextColor3=Color3.new(1,1,1)
open.Parent=gui
local openCorner=Instance.new("UICorner");openCorner.CornerRadius=UDim.new(0,8);openCorner.Parent=open

local frame=Instance.new("Frame")
frame.Size=UDim2.fromOffset(276,330)
frame.Position=UDim2.new(0,10,0,92)
frame.BackgroundColor3=Color3.fromRGB(18,14,26)
frame.BackgroundTransparency=.06
frame.Visible=false
frame.ClipsDescendants=true
frame.Parent=gui
local fc=Instance.new("UICorner");fc.CornerRadius=UDim.new(0,10);fc.Parent=frame

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-40,0,34)
title.Position=UDim2.fromOffset(10,4)
title.BackgroundTransparency=1
title.Text="BBYA SOCIAL HUB"
title.TextColor3=Color3.fromRGB(255,105,215)
title.Font=Enum.Font.GothamBlack
title.TextSize=19
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=frame

local close=Instance.new("TextButton")
close.Size=UDim2.fromOffset(30,30)
close.Position=UDim2.new(1,-35,0,5)
close.Text="×"
close.TextSize=24
close.Font=Enum.Font.GothamBold
close.TextColor3=Color3.new(1,1,1)
close.BackgroundColor3=Color3.fromRGB(55,35,72)
close.Parent=frame
local cc=Instance.new("UICorner");cc.CornerRadius=UDim.new(0,7);cc.Parent=close

local scroll=Instance.new("ScrollingFrame")
scroll.Size=UDim2.new(1,-12,1,-48)
scroll.Position=UDim2.fromOffset(6,42)
scroll.BackgroundTransparency=1
scroll.BorderSizePixel=0
scroll.ScrollBarThickness=3
scroll.CanvasSize=UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
scroll.Parent=frame

local grid=Instance.new("UIGridLayout")
grid.CellSize=UDim2.fromOffset(82,42)
grid.CellPadding=UDim2.fromOffset(6,6)
grid.HorizontalAlignment=Enum.HorizontalAlignment.Center
grid.SortOrder=Enum.SortOrder.LayoutOrder
grid.Parent=scroll

local function fitText(b)
 b.TextScaled=true
 local c=Instance.new("UITextSizeConstraint")
 c.MinTextSize=10
 c.MaxTextSize=17
 c.Parent=b
end

local layoutOrder=0
local function button(txt,cb)
 layoutOrder+=1
 local b=Instance.new("TextButton")
 b.LayoutOrder=layoutOrder
 b.Text=txt
 b.Font=Enum.Font.GothamBold
 b.TextColor3=Color3.new(1,1,1)
 b.BackgroundColor3=Color3.fromRGB(45,28,62)
 b.TextWrapped=true
 b.AutoButtonColor=true
 fitText(b)
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,7);corner.Parent=b
 b.Parent=scroll
 b.MouseButton1Click:Connect(cb)
 return b
end

open.MouseButton1Click:Connect(function()frame.Visible=not frame.Visible end)
close.MouseButton1Click:Connect(function()frame.Visible=false end)

for _,e in ipairs({"dance","dance2","dance3","wave","cheer","laugh"}) do
 button(string.upper(e),function()Dance:FireServer(e)end)
end
button("SYNC\nNEAR",function()
 local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart");if not root then return end
 local best,bestD=nil,math.huge
 for _,p in ipairs(Players:GetPlayers()) do
  if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
   local d=(p.Character.HumanoidRootPart.Position-root.Position).Magnitude
   if d<bestD then bestD=d;best=p end
  end
 end
 if best and bestD<35 then Sync:FireServer(best.UserId) end
end)
button("GLOW\nSTICK",function()FX:FireServer("glowstick")end)
button("CONFETTI",function()FX:FireServer("confetti")end)
for _,spot in ipairs({"DANCE","VIP","BAR","PHOTO","CHILL"}) do button(spot,function()TP:FireServer(spot)end) end

local cam=workspace.CurrentCamera
local cinematic=false
local camIndex=1
local presets={
 CFrame.new(0,18,55)*CFrame.Angles(math.rad(-10),math.rad(180),0),
 CFrame.new(0,14,25)*CFrame.Angles(math.rad(-12),math.rad(180),0),
 CFrame.new(38,16,18)*CFrame.Angles(math.rad(-8),math.rad(130),0),
 CFrame.new(-38,18,-20)*CFrame.Angles(math.rad(-6),math.rad(-50),0),
 CFrame.new(0,28,-40)*CFrame.Angles(math.rad(-18),0,0),
}
button("CINE\nCAM",function()
 cinematic=not cinematic
 if cinematic then
  cam.CameraType=Enum.CameraType.Scriptable
  camIndex=camIndex%#presets+1
  TweenService:Create(cam,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{CFrame=presets[camIndex]}):Play()
 else
  cam.CameraType=Enum.CameraType.Custom
  local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
  if hum then cam.CameraSubject=hum end
 end
end)
button("CAM\nNEXT",function()
 if cinematic then camIndex=camIndex%#presets+1;TweenService:Create(cam,TweenInfo.new(1),{CFrame=presets[camIndex]}):Play() end
end)

local gfx=1
local gfxButton
gfxButton=button("GRAPHICS\nMED",function()
 gfx=gfx%3+1
 if gfx==1 then
  Lighting.Brightness=2.3;Lighting.ExposureCompensation=.25;Lighting.EnvironmentDiffuseScale=.35;Lighting.EnvironmentSpecularScale=.45;gfxButton.Text="GRAPHICS\nLOW"
 elseif gfx==2 then
  Lighting.Brightness=2.8;Lighting.ExposureCompensation=.5;Lighting.EnvironmentDiffuseScale=.5;Lighting.EnvironmentSpecularScale=.7;gfxButton.Text="GRAPHICS\nMED"
 else
  Lighting.Brightness=3.0;Lighting.ExposureCompensation=.6;Lighting.EnvironmentDiffuseScale=.65;Lighting.EnvironmentSpecularScale=1;gfxButton.Text="GRAPHICS\nHIGH"
 end
end)

print("[BBYA] v1.3.1 mobile-safe UI loaded")