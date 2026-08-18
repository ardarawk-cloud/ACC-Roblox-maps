-- BBYA Social Hub v1.5.1 client: mobile safe-zone layout
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

local gui=Instance.new("ScreenGui");gui.Name="BBYA_UI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.DisplayOrder=20;gui.Parent=player:WaitForChild("PlayerGui")
local open=Instance.new("TextButton");open.Size=UDim2.fromOffset(72,34);open.Text="BBYA";open.Font=Enum.Font.GothamBold;open.TextSize=18;open.BackgroundColor3=Color3.fromRGB(35,18,48);open.TextColor3=Color3.new(1,1,1);open.Parent=gui;Instance.new("UICorner",open).CornerRadius=UDim.new(0,8)
local frame=Instance.new("Frame");frame.Size=UDim2.fromOffset(276,330);frame.BackgroundColor3=Color3.fromRGB(18,14,26);frame.BackgroundTransparency=.06;frame.Visible=false;frame.ClipsDescendants=true;frame.Parent=gui;Instance.new("UICorner",frame).CornerRadius=UDim.new(0,10)
local title=Instance.new("TextLabel");title.Size=UDim2.new(1,-40,0,34);title.Position=UDim2.fromOffset(10,4);title.BackgroundTransparency=1;title.Text="BBYA SOCIAL HUB";title.TextColor3=Color3.fromRGB(255,105,215);title.Font=Enum.Font.GothamBlack;title.TextSize=19;title.TextXAlignment=Enum.TextXAlignment.Left;title.Parent=frame
local close=Instance.new("TextButton");close.Size=UDim2.fromOffset(30,30);close.Position=UDim2.new(1,-35,0,5);close.Text="×";close.TextSize=24;close.Font=Enum.Font.GothamBold;close.TextColor3=Color3.new(1,1,1);close.BackgroundColor3=Color3.fromRGB(55,35,72);close.Parent=frame;Instance.new("UICorner",close).CornerRadius=UDim.new(0,7)
local scroll=Instance.new("ScrollingFrame");scroll.Size=UDim2.new(1,-12,1,-48);scroll.Position=UDim2.fromOffset(6,42);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=3;scroll.CanvasSize=UDim2.new();scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.Parent=frame
local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.fromOffset(82,42);grid.CellPadding=UDim2.fromOffset(6,6);grid.HorizontalAlignment=Enum.HorizontalAlignment.Center;grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=scroll
local function fitText(b)b.TextScaled=true;local c=Instance.new("UITextSizeConstraint");c.MinTextSize=9;c.MaxTextSize=16;c.Parent=b end
local order=0
local function button(txt,cb)order+=1;local b=Instance.new("TextButton");b.LayoutOrder=order;b.Text=txt;b.Font=Enum.Font.GothamBold;b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=Color3.fromRGB(45,28,62);b.TextWrapped=true;b.AutoButtonColor=true;fitText(b);Instance.new("UICorner",b).CornerRadius=UDim.new(0,7);b.Parent=scroll;b.MouseButton1Click:Connect(cb);return b end
open.MouseButton1Click:Connect(function()frame.Visible=not frame.Visible end);close.MouseButton1Click:Connect(function()frame.Visible=false end)
for _,e in ipairs({"dance","dance2","dance3","wave","cheer","laugh"})do button(string.upper(e),function()Dance:FireServer(e)end)end
button("SYNC\nNEAR",function()local c=player.Character;local r=c and c:FindFirstChild("HumanoidRootPart");if not r then return end;local best,bd=nil,math.huge;for _,p in ipairs(Players:GetPlayers())do if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then local d=(p.Character.HumanoidRootPart.Position-r.Position).Magnitude;if d<bd then bd=d;best=p end end end;if best and bd<35 then Sync:FireServer(best.UserId)end end)
button("GLOW\nSTICK",function()FX:FireServer("glowstick")end);button("CONFETTI",function()FX:FireServer("confetti")end)
for _,spot in ipairs({"DANCE","VIP","BAR","PHOTO","CHILL"})do button(spot,function()TP:FireServer(spot)end)end

local music=Instance.new("Frame");music.Name="MusicPanel";music.Size=UDim2.fromOffset(260,118);music.BackgroundColor3=Color3.fromRGB(16,13,24);music.BackgroundTransparency=.08;music.Parent=gui;Instance.new("UICorner",music).CornerRadius=UDim.new(0,10)
local mt=Instance.new("TextLabel");mt.Size=UDim2.new(1,-16,0,25);mt.Position=UDim2.fromOffset(8,6);mt.BackgroundTransparency=1;mt.Text="♫ BBYA MUSIC • 24/7";mt.Font=Enum.Font.GothamBlack;mt.TextSize=15;mt.TextColor3=Color3.fromRGB(255,105,215);mt.TextXAlignment=Enum.TextXAlignment.Left;mt.Parent=music
local now=Instance.new("TextLabel");now.Size=UDim2.new(1,-16,0,38);now.Position=UDim2.fromOffset(8,30);now.BackgroundTransparency=1;now.Text="NOW PLAYING\nLoading music system...";now.Font=Enum.Font.GothamBold;now.TextSize=12;now.TextWrapped=true;now.TextColor3=Color3.new(1,1,1);now.TextXAlignment=Enum.TextXAlignment.Left;now.Parent=music
local function smallButton(txt,x,w)local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(w,30);b.Position=UDim2.fromOffset(x,78);b.Text=txt;b.Font=Enum.Font.GothamBold;b.TextSize=12;b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=Color3.fromRGB(50,32,68);b.Parent=music;Instance.new("UICorner",b).CornerRadius=UDim.new(0,7);return b end
local mute=smallButton("MUTE",8,72);local volDown=smallButton("VOL-",88,46);local volUp=smallButton("VOL+",140,46);local hide=smallButton("HIDE",192,58)
local localVolume=.65;local muted=false
local function findMusic()for _,o in ipairs(workspace:GetDescendants())do if o:IsA("Sound")and(string.find(string.lower(o.Name),"music")or string.find(string.lower(o.Name),"bbya"))then return o end end end
local function refreshMusic()local s=findMusic();local track=workspace:GetAttribute("BBYANowPlaying")or(s and s.Name)or"BBYA 24/7";now.Text="NOW PLAYING\n"..tostring(track);if s then s.Volume=muted and 0 or localVolume end end
mute.MouseButton1Click:Connect(function()muted=not muted;mute.Text=muted and"UNMUTE"or"MUTE";refreshMusic()end)
volDown.MouseButton1Click:Connect(function()localVolume=math.max(0,localVolume-.1);muted=false;mute.Text="MUTE";refreshMusic()end)
volUp.MouseButton1Click:Connect(function()localVolume=math.min(1,localVolume+.1);muted=false;mute.Text="MUTE";refreshMusic()end)
hide.MouseButton1Click:Connect(function()music.Visible=false end)
button("MUSIC\nPANEL",function()music.Visible=not music.Visible;refreshMusic()end)

-- MOBILE SAFE-ZONE DOCKING: keep BBYA/admin-style panels away from movement/jump controls.
local cam=workspace.CurrentCamera
local function applySafeLayout()
 local v=cam.ViewportSize
 if v.X>v.Y then
  -- landscape: left vertical safe strip + top-center safe strip (matches marked red zones)
  open.Position=UDim2.new(0,16,1,-58)
  frame.AnchorPoint=Vector2.new(0,.5);frame.Position=UDim2.new(0,12,.5,0);frame.Size=UDim2.fromOffset(250,math.min(330,v.Y-120))
  music.AnchorPoint=Vector2.new(.5,0);music.Position=UDim2.new(.5,0,0,12)
 else
  -- portrait: top/left safe layout, never bottom-right where movement controls live
  open.Position=UDim2.new(0,12,1,-58)
  frame.AnchorPoint=Vector2.new(0,0);frame.Position=UDim2.new(0,12,0,90);frame.Size=UDim2.fromOffset(math.min(276,v.X-24),math.min(330,v.Y-190))
  music.AnchorPoint=Vector2.new(.5,0);music.Position=UDim2.new(.5,0,0,54)
 end
end
applySafeLayout();cam:GetPropertyChangedSignal("ViewportSize"):Connect(applySafeLayout)

task.spawn(function()while gui.Parent do refreshMusic();task.wait(2)end end)
local cinematic=false;local ci=1;local presets={CFrame.new(0,18,55)*CFrame.Angles(math.rad(-10),math.rad(180),0),CFrame.new(0,14,25)*CFrame.Angles(math.rad(-12),math.rad(180),0),CFrame.new(38,16,18)*CFrame.Angles(math.rad(-8),math.rad(130),0),CFrame.new(-38,18,-20)*CFrame.Angles(math.rad(-6),math.rad(-50),0),CFrame.new(0,28,-40)*CFrame.Angles(math.rad(-18),0,0)}
button("CINE\nCAM",function()cinematic=not cinematic;if cinematic then cam.CameraType=Enum.CameraType.Scriptable;ci=ci%#presets+1;TweenService:Create(cam,TweenInfo.new(1.2),{CFrame=presets[ci]}):Play()else cam.CameraType=Enum.CameraType.Custom;local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if h then cam.CameraSubject=h end end end)
button("CAM\nNEXT",function()if cinematic then ci=ci%#presets+1;TweenService:Create(cam,TweenInfo.new(1),{CFrame=presets[ci]}):Play()end end)
local gfx=1;local gb;gb=button("GRAPHICS\nMED",function()gfx=gfx%3+1;if gfx==1 then Lighting.Brightness=2.3;Lighting.ExposureCompensation=.25;gb.Text="GRAPHICS\nLOW"elseif gfx==2 then Lighting.Brightness=2.8;Lighting.ExposureCompensation=.5;gb.Text="GRAPHICS\nMED"else Lighting.Brightness=3;Lighting.ExposureCompensation=.6;gb.Text="GRAPHICS\nHIGH"end end)
print("[BBYA] v1.5.1 safe-zone UI loaded")