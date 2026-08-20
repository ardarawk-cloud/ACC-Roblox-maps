-- BBYA SOCIAL HUB — FLOOR 1 FEATURE CLIENT v1

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local camera=workspace.CurrentCamera
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local feature=remotes:WaitForChild("Feature")

local gui=Instance.new("ScreenGui")
gui.Name="BBYAFloor1FeaturesUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=30;gui.Parent=player:WaitForChild("PlayerGui")
local PINK=Color3.fromRGB(244,48,149);local CYAN=Color3.fromRGB(31,184,207);local WARM=Color3.fromRGB(255,205,158);local BG=Color3.fromRGB(12,11,15);local CARD=Color3.fromRGB(25,22,29);local WHITE=Color3.fromRGB(242,239,243);local MUTED=Color3.fromRGB(164,159,169)

local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 12);c.Parent=o end
local function stroke(o,c,t,tr)local s=Instance.new("UIStroke");s.Color=c;s.Thickness=t or 1;s.Transparency=tr or .35;s.Parent=o end
local function button(parent,text,pos,size,color)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=color or CARD;b.TextColor3=WHITE;b.Font=Enum.Font.GothamSemibold;b.TextSize=13;b.BorderSizePixel=0;b.AutoButtonColor=true;b.Parent=parent;round(b,9);return b
end
local function label(parent,text,pos,size,font,sizeText,color)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.TextColor3=color or WHITE;l.Font=font or Enum.Font.Gotham;l.TextSize=sizeText or 14;l.TextWrapped=true;l.Parent=parent;return l
end
local function playEmote(name)
 local ch=player.Character;if not ch then return end
 local hum=ch:FindFirstChildOfClass("Humanoid");if not hum then return end
 pcall(function()hum:PlayEmote(name)end)
end

-- global modal dimmer
local dim=Instance.new("Frame");dim.Size=UDim2.fromScale(1,1);dim.BackgroundColor3=Color3.new(0,0,0);dim.BackgroundTransparency=.48;dim.Visible=false;dim.BorderSizePixel=0;dim.Parent=gui
local flash=Instance.new("Frame");flash.Size=UDim2.fromScale(1,1);flash.BackgroundColor3=Color3.new(1,1,1);flash.BackgroundTransparency=1;flash.BorderSizePixel=0;flash.ZIndex=50;flash.Parent=gui
local countdown=label(gui,"",UDim2.fromScale(.35,.32),UDim2.fromScale(.30,.25),Enum.Font.GothamBlack,86,WHITE);countdown.TextScaled=true;countdown.Visible=false;countdown.ZIndex=51
local modeTag=label(gui,"",UDim2.new(.5,-150,0,24),UDim2.fromOffset(300,28),Enum.Font.GothamBold,12,WHITE);modeTag.TextXAlignment=Enum.TextXAlignment.Center;modeTag.Visible=false;modeTag.ZIndex=51

local activePanel
local function closePanel()
 if activePanel then activePanel:Destroy();activePanel=nil end
 dim.Visible=false
end
local function makePanel(title,subtitle,height)
 closePanel();dim.Visible=true
 local f=Instance.new("Frame");f.AnchorPoint=Vector2.new(.5,.5);f.Position=UDim2.fromScale(.5,.5);f.Size=UDim2.new(.86,0,0,height or 300);f.BackgroundColor3=BG;f.BorderSizePixel=0;f.ZIndex=20;f.Parent=gui;round(f,16);stroke(f,PINK,1,.42)
 local lim=Instance.new("UISizeConstraint");lim.MinSize=Vector2.new(300,220);lim.MaxSize=Vector2.new(430,480);lim.Parent=f
 label(f,title,UDim2.fromOffset(18,15),UDim2.new(1,-70,0,26),Enum.Font.GothamBold,18,WHITE).ZIndex=21
 local sub=label(f,subtitle or "",UDim2.fromOffset(18,43),UDim2.new(1,-36,0,38),Enum.Font.Gotham,11,MUTED);sub.TextXAlignment=Enum.TextXAlignment.Left;sub.ZIndex=21
 local x=button(f,"×",UDim2.new(1,-48,0,12),UDim2.fromOffset(34,34),Color3.fromRGB(34,30,39));x.TextSize=20;x.ZIndex=22;x.MouseButton1Click:Connect(closePanel)
 activePanel=f;return f
end

local function photoMode(data)
 closePanel()
 local oldType=camera.CameraType;local oldSubject=camera.CameraSubject;local oldCF=camera.CFrame
 camera.CameraType=Enum.CameraType.Scriptable
 if typeof(data.camera)=="CFrame" then camera.CFrame=data.camera end
 modeTag.Text=tostring(data.label or "BBYA PHOTO MODE");modeTag.Visible=true
 countdown.Visible=true
 for n=3,1,-1 do countdown.Text=tostring(n);countdown.TextTransparency=1;TweenService:Create(countdown,TweenInfo.new(.18),{TextTransparency=0}):Play();task.wait(.72) end
 countdown.Text=""
 flash.BackgroundTransparency=1
 TweenService:Create(flash,TweenInfo.new(.08),{BackgroundTransparency=.05}):Play();task.wait(.10)
 TweenService:Create(flash,TweenInfo.new(.42),{BackgroundTransparency=1}):Play()
 countdown.Text="PHOTO READY";countdown.TextScaled=false;countdown.TextSize=26;task.wait(.6);countdown.Visible=false;countdown.TextScaled=true

 local poses=Instance.new("Frame");poses.AnchorPoint=Vector2.new(.5,1);poses.Position=UDim2.new(.5,0,1,-26);poses.Size=UDim2.new(.78,0,0,52);poses.BackgroundColor3=BG;poses.BackgroundTransparency=.12;poses.BorderSizePixel=0;poses.ZIndex=52;poses.Parent=gui;round(poses,14);stroke(poses,PINK,1,.55)
 local plim=Instance.new("UISizeConstraint");plim.MaxSize=Vector2.new(420,52);plim.Parent=poses
 local options={{"POSE A","wave"},{"POSE B","cheer"},{"POSE C","dance2"}}
 for i,d in ipairs(options) do local b=button(poses,d[1],UDim2.new((i-1)/3,6,0,7),UDim2.new(1/3,-12,1,-14),i==2 and Color3.fromRGB(69,45,52) or CARD);b.ZIndex=53;b.MouseButton1Click:Connect(function()feature:FireServer("photoPose",d[2])end) end
 task.wait(math.max(2,(tonumber(data.duration) or 6)-3))
 if poses.Parent then poses:Destroy() end
 modeTag.Visible=false
 camera.CameraType=oldType
 camera.CameraSubject=oldSubject
 if oldType==Enum.CameraType.Scriptable then camera.CFrame=oldCF end
end

local function lookSession(data)
 local f=makePanel("BBYA LOOK LAB","Pilih mood styling. Efek look aktif sementara untuk sesi roleplay.",286)
 local y=92
 for i,d in ipairs({{"NIGHT",PINK,"Night"},{"EDITORIAL",WARM,"Editorial"},{"CLEAN",CYAN,"Clean"}}) do
  local b=button(f,d[1],UDim2.fromOffset(18,y+(i-1)*54),UDim2.new(1,-36,0,44),Color3.fromRGB(32,28,36));stroke(b,d[2],1,.25);b.ZIndex=22
  b.MouseButton1Click:Connect(function()feature:FireServer("lookMood",d[3]);closePanel()end)
 end
end

local function djMenu(data)
 local f=makePanel("REQUEST TO DJ","Masuk antrean DJ. Request tidak memotong track yang sedang dimainkan.",420)
 local holder=Instance.new("ScrollingFrame");holder.Position=UDim2.fromOffset(18,92);holder.Size=UDim2.new(1,-36,1,-110);holder.BackgroundTransparency=1;holder.BorderSizePixel=0;holder.ScrollBarThickness=3;holder.AutomaticCanvasSize=Enum.AutomaticSize.Y;holder.CanvasSize=UDim2.new();holder.ZIndex=21;holder.Parent=f
 local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,8);layout.Parent=holder
 for i,title in ipairs(data.playlist or {}) do
  local b=button(holder,string.format("%02d   %s",i,tostring(title)),UDim2.new(),UDim2.new(1,-5,0,43),Color3.fromRGB(30,26,34));b.TextXAlignment=Enum.TextXAlignment.Left;b.ZIndex=22
  b.MouseButton1Click:Connect(function()feature:FireServer("djRequest",i);closePanel()end)
 end
end

feature.OnClientEvent:Connect(function(kind,data)
 if kind=="photoMode" then task.spawn(photoMode,data or {})
 elseif kind=="lookSession" then lookSession(data or {})
 elseif kind=="djMenu" then djMenu(data or {})
 elseif kind=="dance" then local list=(data and data.emotes) or {"dance"};playEmote(list[math.random(1,#list)])
 elseif kind=="playEmote" then playEmote(tostring(data or "wave"))
 elseif kind=="toast" then
  local t=label(gui,tostring(data),UDim2.new(.5,-190,1,-80),UDim2.fromOffset(380,42),Enum.Font.GothamMedium,13,WHITE);t.AnchorPoint=Vector2.new(0,1);t.BackgroundTransparency=.08;t.BackgroundColor3=BG;t.ZIndex=60;round(t,10);stroke(t,PINK,1,.55);task.delay(2.4,function()if t.Parent then t:Destroy() end end)
 end
end)

player.CharacterAdded:Connect(function()closePanel();modeTag.Visible=false;countdown.Visible=false;camera=workspace.CurrentCamera end)
print("[BBYA] Floor 1 feature client online")