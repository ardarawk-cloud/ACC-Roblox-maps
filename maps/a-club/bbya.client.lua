-- BBYA Social Hub v1.3 client: mobile UI, cinematic cam, graphics, dance/sync
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

local gui=Instance.new("ScreenGui");gui.Name="BBYA_UI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.Parent=player:WaitForChild("PlayerGui")
local open=Instance.new("TextButton");open.Size=UDim2.fromOffset(82,36);open.Position=UDim2.new(0,12,1,-50);open.Text="BBYA";open.Font=Enum.Font.GothamBold;open.TextScaled=true;open.BackgroundColor3=Color3.fromRGB(35,18,48);open.TextColor3=Color3.new(1,1,1);open.Parent=gui
local frame=Instance.new("Frame");frame.Size=UDim2.fromOffset(300,360);frame.Position=UDim2.new(0,12,1,-420);frame.BackgroundColor3=Color3.fromRGB(18,14,26);frame.BackgroundTransparency=.08;frame.Visible=false;frame.Parent=gui
local title=Instance.new("TextLabel");title.Size=UDim2.new(1,0,0,38);title.BackgroundTransparency=1;title.Text="BBYA SOCIAL HUB";title.TextColor3=Color3.fromRGB(255,105,215);title.Font=Enum.Font.GothamBlack;title.TextScaled=true;title.Parent=frame
local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.fromOffset(92,44);grid.CellPadding=UDim2.fromOffset(6,7);grid.HorizontalAlignment=Enum.HorizontalAlignment.Center;grid.VerticalAlignment=Enum.VerticalAlignment.Center;grid.Parent=frame
local function button(txt,cb)local b=Instance.new("TextButton");b.Text=txt;b.Font=Enum.Font.GothamBold;b.TextScaled=true;b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=Color3.fromRGB(45,28,62);b.Parent=frame;b.MouseButton1Click:Connect(cb);return b end
open.MouseButton1Click:Connect(function()frame.Visible=not frame.Visible end)

for _,e in ipairs({"dance","dance2","dance3","wave","cheer","laugh"})do button(string.upper(e),function()Dance:FireServer(e)end)end
button("SYNC NEAR",function()
 local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart");if not root then return end
 local best,bestD=nil,math.huge
 for _,p in ipairs(Players:GetPlayers())do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then local d=(p.Character.HumanoidRootPart.Position-root.Position).Magnitude;if d<bestD then bestD=d;best=p end end end
 if best and bestD<35 then Sync:FireServer(best.UserId)end
end)
button("GLOWSTICK",function()FX:FireServer("glowstick")end)
button("CONFETTI",function()FX:FireServer("confetti")end)
for _,spot in ipairs({"DANCE","VIP","BAR","PHOTO","CHILL"})do button(spot,function()TP:FireServer(spot)end)end

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
button("CINE CAM",function()
 cinematic=not cinematic
 if cinematic then cam.CameraType=Enum.CameraType.Scriptable;camIndex=camIndex%#presets+1;TweenService:Create(cam,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{CFrame=presets[camIndex]}):Play()
 else cam.CameraType=Enum.CameraType.Custom;local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if hum then cam.CameraSubject=hum end end
end)
button("CAM NEXT",function()if cinematic then camIndex=camIndex%#presets+1;TweenService:Create(cam,TweenInfo.new(1),{CFrame=presets[camIndex]}):Play()end end)

local gfx=1
button("GRAPHICS",function()
 gfx=gfx%3+1
 if gfx==1 then Lighting.Brightness=2.3;Lighting.ExposureCompensation=.25;Lighting.EnvironmentDiffuseScale=.35;Lighting.EnvironmentSpecularScale=.45
 elseif gfx==2 then Lighting.Brightness=2.8;Lighting.ExposureCompensation=.5;Lighting.EnvironmentDiffuseScale=.5;Lighting.EnvironmentSpecularScale=.7
 else Lighting.Brightness=3.0;Lighting.ExposureCompensation=.6;Lighting.EnvironmentDiffuseScale=.65;Lighting.EnvironmentSpecularScale=1 end
end)

print("[BBYA] v1.3 client UI/cinematic/dance loaded")