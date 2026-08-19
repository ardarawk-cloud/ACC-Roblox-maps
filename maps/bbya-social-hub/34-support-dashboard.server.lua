local W=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder",W);root.Name="BBYA_ZERO_BUILD"
local old=root:FindFirstChild("SupportDashboard");if old then old:Destroy() end
local model=Instance.new("Model",root);model.Name="SupportDashboard"

-- Actual Floor1 front-right wall is the X=27 wall segment. Mount on its INNER face,
-- flush to the wall and facing toward the club (-X), instead of floating across the facade.
local wallCF=CFrame.new(26.35,7,-30)*CFrame.Angles(0,math.rad(90),0)
local board=Instance.new("Part");board.Name="SawerDashboard";board.Anchored=true;board.CanCollide=false;board.Size=Vector3.new(20,10,.42);board.CFrame=wallCF;board.Color=Color3.fromRGB(10,10,14);board.Material=Enum.Material.Metal;board.Parent=model
local trim=Instance.new("Part");trim.Name="DashboardGlow";trim.Anchored=true;trim.CanCollide=false;trim.Size=Vector3.new(20.5,10.5,.08);trim.CFrame=wallCF*CFrame.new(0,0,-.25);trim.Color=Color3.fromRGB(255,42,157);trim.Material=Enum.Material.Neon;trim.Parent=model
local face=Instance.new("Part");face.Name="DashboardFace";face.Anchored=true;face.CanCollide=false;face.Size=Vector3.new(20.15,10.15,.06);face.CFrame=wallCF*CFrame.new(0,0,-.31);face.Color=Color3.fromRGB(16,14,20);face.Material=Enum.Material.SmoothPlastic;face.Parent=model

local gui=Instance.new("SurfaceGui");gui.Name="SawerUI";gui.Face=Enum.NormalId.Front;gui.AlwaysOnTop=true;gui.LightInfluence=.05;gui.PixelsPerStud=70;gui.Parent=face
local bg=Instance.new("Frame");bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=Color3.fromRGB(12,11,16);bg.BorderSizePixel=0;bg.Parent=gui
local grad=Instance.new("UIGradient");grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(41,15,33)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,10,14))});grad.Rotation=90;grad.Parent=bg
local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Position=UDim2.fromScale(.06,.06);title.Size=UDim2.fromScale(.88,.15);title.Text="SUPPORT BBYA";title.TextColor3=Color3.fromRGB(255,66,171);title.Font=Enum.Font.GothamBold;title.TextScaled=true;title.TextXAlignment=Enum.TextXAlignment.Left;title.Parent=bg
local sub=Instance.new("TextLabel");sub.BackgroundTransparency=1;sub.Position=UDim2.fromScale(.06,.21);sub.Size=UDim2.fromScale(.88,.07);sub.Text="SAWER  •  SUPPORTER WALL";sub.TextColor3=Color3.fromRGB(185,182,194);sub.Font=Enum.Font.GothamMedium;sub.TextScaled=true;sub.TextXAlignment=Enum.TextXAlignment.Left;sub.Parent=bg
local line=Instance.new("Frame");line.Position=UDim2.fromScale(.06,.31);line.Size=UDim2.fromScale(.88,.008);line.BackgroundColor3=Color3.fromRGB(255,42,157);line.BorderSizePixel=0;line.Parent=bg
local top=Instance.new("TextLabel");top.BackgroundTransparency=1;top.Position=UDim2.fromScale(.06,.36);top.Size=UDim2.fromScale(.55,.09);top.Text="TOP SUPPORTERS";top.TextColor3=Color3.fromRGB(245,245,248);top.Font=Enum.Font.GothamBold;top.TextScaled=true;top.TextXAlignment=Enum.TextXAlignment.Left;top.Parent=bg
for i,t in ipairs({"01  Waiting for supporter","02  Waiting for supporter","03  Waiting for supporter"}) do local r=Instance.new("TextLabel");r.BackgroundColor3=Color3.fromRGB(25,22,31);r.BackgroundTransparency=.08;r.BorderSizePixel=0;r.Position=UDim2.fromScale(.06,.47+(i-1)*.12);r.Size=UDim2.fromScale(.58,.095);r.Text="   "..t;r.TextColor3=Color3.fromRGB(225,223,230);r.Font=Enum.Font.GothamMedium;r.TextScaled=true;r.TextXAlignment=Enum.TextXAlignment.Left;r.Parent=bg;local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,8);c.Parent=r end
local amounts=Instance.new("TextLabel");amounts.BackgroundTransparency=1;amounts.Position=UDim2.fromScale(.06,.84);amounts.Size=UDim2.fromScale(.58,.08);amounts.Text="10   •   25   •   50   •   100 R$";amounts.TextColor3=Color3.fromRGB(0,205,255);amounts.Font=Enum.Font.GothamBold;amounts.TextScaled=true;amounts.Parent=bg
local cta=Instance.new("TextLabel");cta.BackgroundColor3=Color3.fromRGB(78,20,58);cta.BorderSizePixel=0;cta.Position=UDim2.fromScale(.69,.47);cta.Size=UDim2.fromScale(.25,.45);cta.Text="TAP / USE\nTO OPEN\nSUPPORT";cta.TextColor3=Color3.new(1,1,1);cta.Font=Enum.Font.GothamBold;cta.TextScaled=true;cta.Parent=bg;local cc=Instance.new("UICorner");cc.CornerRadius=UDim.new(0,12);cc.Parent=cta
local prompt=Instance.new("ProximityPrompt");prompt.Name="OpenSawerMenu";prompt.ActionText="Open Support";prompt.ObjectText="BBYA Support Wall";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=0;prompt.MaxActivationDistance=14;prompt.RequiresLineOfSight=false;prompt.Parent=face
local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes");local state=remotes and remotes:FindFirstChild("State")
prompt.Triggered:Connect(function(player)if state then state:FireClient(player,"openSupport",true) end end)
print("[BBYA] Support wall flush-mounted on front-right wall")