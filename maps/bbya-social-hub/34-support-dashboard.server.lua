local W=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder")
root.Name="BBYA_ZERO_BUILD"
root.Parent=W

local old=root:FindFirstChild("SupportDashboard")
if old then old:Destroy() end

local model=Instance.new("Model")
model.Name="SupportDashboard"
model.Parent=root

-- Keep the approved front-right wall location, but make the board read like a premium club fixture.
local wallCF=CFrame.new(26.30,7.25,-30)*CFrame.Angles(0,math.rad(90),0)
local PINK=Color3.fromRGB(255,42,157)
local CYAN=Color3.fromRGB(0,207,255)
local WHITE=Color3.fromRGB(247,245,250)
local MUTED=Color3.fromRGB(164,158,177)
local PANEL=Color3.fromRGB(13,11,18)
local PANEL2=Color3.fromRGB(24,19,31)
local CARD=Color3.fromRGB(31,25,39)
local GOLD=Color3.fromRGB(255,198,94)

local function part(name,size,cf,color,material,transparency)
 local p=Instance.new("Part")
 p.Name=name;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=true
 p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=model
 return p
end

-- 3D physical housing: recessed black metal shell + two slim luminous edge bars.
part("SupportHousing",Vector3.new(22.2,11.7,.62),wallCF,Color3.fromRGB(7,7,10),Enum.Material.Metal,0)
local face=part("SupportGlassFace",Vector3.new(21.5,11.0,.10),wallCF*CFrame.new(0,0,-.38),Color3.fromRGB(12,10,17),Enum.Material.Glass,.08)
part("PinkEdge",Vector3.new(.16,10.45,.12),wallCF*CFrame.new(-10.58,0,-.45),PINK,Enum.Material.Neon,0)
part("CyanEdge",Vector3.new(.16,10.45,.12),wallCF*CFrame.new(10.58,0,-.45),CYAN,Enum.Material.Neon,0)
part("TopGlow",Vector3.new(20.7,.10,.12),wallCF*CFrame.new(0,5.22,-.45),PINK,Enum.Material.Neon,0)

local gui=Instance.new("SurfaceGui")
gui.Name="SawerUI"
gui.Face=Enum.NormalId.Front
gui.AlwaysOnTop=true
gui.LightInfluence=.02
gui.PixelsPerStud=85
gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
gui.Parent=face

local function corner(o,r)
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o
end
local function outline(o,color,thickness,transparency)
 local s=Instance.new("UIStroke");s.Color=color or Color3.fromRGB(70,59,82);s.Thickness=thickness or 1;s.Transparency=transparency or 0;s.Parent=o
end
local function frame(parent,pos,size,color,transparency,r)
 local f=Instance.new("Frame");f.Position=pos;f.Size=size;f.BackgroundColor3=color;f.BackgroundTransparency=transparency or 0;f.BorderSizePixel=0;f.Parent=parent
 if r then corner(f,r) end
 return f
end
local function text(parent,value,pos,size,color,font,scaled,xalign)
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=pos;t.Size=size;t.Text=value;t.TextColor3=color or WHITE;t.Font=font or Enum.Font.GothamMedium;t.TextScaled=scaled~=false;t.TextXAlignment=xalign or Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.Parent=parent
 return t
end

local bg=frame(gui,UDim2.fromScale(0,0),UDim2.fromScale(1,1),PANEL,0)
local bgGrad=Instance.new("UIGradient")
bgGrad.Color=ColorSequence.new({
 ColorSequenceKeypoint.new(0,Color3.fromRGB(37,15,34)),
 ColorSequenceKeypoint.new(.44,Color3.fromRGB(16,13,22)),
 ColorSequenceKeypoint.new(1,Color3.fromRGB(7,12,18)),
})
bgGrad.Rotation=20
bgGrad.Parent=bg

-- Ambient glow blocks.
local glowL=frame(bg,UDim2.fromScale(-.08,-.08),UDim2.fromScale(.42,.42),PINK,.88,999)
local glowR=frame(bg,UDim2.fromScale(.77,.66),UDim2.fromScale(.32,.34),CYAN,.91,999)

-- HEADER ----------------------------------------------------------------------
text(bg,"BBYA",UDim2.fromScale(.055,.055),UDim2.fromScale(.14,.075),WHITE,Enum.Font.GothamBlack,true)
local supportTitle=text(bg,"SUPPORT",UDim2.fromScale(.19,.055),UDim2.fromScale(.27,.075),PINK,Enum.Font.GothamBlack,true)
local live=frame(bg,UDim2.fromScale(.79,.06),UDim2.fromScale(.15,.07),Color3.fromRGB(34,27,42),.04,999)
outline(live,PINK,1.2,.25)
local dot=frame(live,UDim2.fromScale(.09,.34),UDim2.fromScale(.10,.32),PINK,0,999)
text(live,"LIVE WALL",UDim2.fromScale(.25,.12),UDim2.fromScale(.66,.76),WHITE,Enum.Font.GothamBold,true,Enum.TextXAlignment.Center)
text(bg,"Support the room. Light up the night.",UDim2.fromScale(.057,.139),UDim2.fromScale(.58,.047),MUTED,Enum.Font.GothamMedium,true)

local divider=frame(bg,UDim2.fromScale(.055,.205),UDim2.fromScale(.89,.003),Color3.fromRGB(96,78,108),.18)
local dg=Instance.new("UIGradient");dg.Color=ColorSequence.new(PINK,CYAN);dg.Parent=divider

-- LEFT: TOP SUPPORTERS ---------------------------------------------------------
local left=frame(bg,UDim2.fromScale(.055,.245),UDim2.fromScale(.585,.63),PANEL2,.12,14)
outline(left,Color3.fromRGB(77,61,89),1,.35)
text(left,"TOP SUPPORTERS",UDim2.fromScale(.045,.045),UDim2.fromScale(.55,.09),WHITE,Enum.Font.GothamBold,true)
text(left,"THIS SESSION",UDim2.fromScale(.67,.052),UDim2.fromScale(.27,.07),MUTED,Enum.Font.GothamBold,true,Enum.TextXAlignment.Right)

local rows={
 {rank="01",accent=GOLD},
 {rank="02",accent=Color3.fromRGB(203,206,219)},
 {rank="03",accent=Color3.fromRGB(210,135,91)},
}
for i,row in ipairs(rows) do
 local y=.17+(i-1)*.245
 local card=frame(left,UDim2.fromScale(.04,y),UDim2.fromScale(.92,.205),CARD,.05,10)
 outline(card,Color3.fromRGB(70,57,82),1,.50)
 local rank=frame(card,UDim2.fromScale(.035,.20),UDim2.fromScale(.12,.60),Color3.fromRGB(18,15,23),0,999)
 outline(rank,row.accent,1.2,.15)
 text(rank,row.rank,UDim2.fromScale(.10,.10),UDim2.fromScale(.80,.80),row.accent,Enum.Font.GothamBlack,true,Enum.TextXAlignment.Center)
 text(card,"Waiting for supporter",UDim2.fromScale(.19,.19),UDim2.fromScale(.58,.33),WHITE,Enum.Font.GothamSemibold,true)
 text(card,"Be the first to claim this spot",UDim2.fromScale(.19,.53),UDim2.fromScale(.61,.24),MUTED,Enum.Font.GothamMedium,true)
 text(card,"—",UDim2.fromScale(.82,.22),UDim2.fromScale(.13,.42),row.accent,Enum.Font.GothamBlack,true,Enum.TextXAlignment.Center)
end

-- RIGHT: SUPPORT ACTION --------------------------------------------------------
local right=frame(bg,UDim2.fromScale(.665,.245),UDim2.fromScale(.28,.63),Color3.fromRGB(23,17,28),.04,14)
outline(right,PINK,1.25,.30)
text(right,"DROP SUPPORT",UDim2.fromScale(.08,.055),UDim2.fromScale(.84,.085),WHITE,Enum.Font.GothamBold,true,Enum.TextXAlignment.Center)
text(right,"Pick an amount",UDim2.fromScale(.11,.145),UDim2.fromScale(.78,.055),MUTED,Enum.Font.GothamMedium,true,Enum.TextXAlignment.Center)

local chips={{"10",.08,.245},{"25",.53,.245},{"50",.08,.405},{"100",.53,.405}}
for _,v in ipairs(chips) do
 local chip=frame(right,UDim2.fromScale(v[2],v[3]),UDim2.fromScale(.39,.125),Color3.fromRGB(33,26,40),.02,10)
 outline(chip,CYAN,1,.45)
 text(chip,v[1].." R$",UDim2.fromScale(.08,.08),UDim2.fromScale(.84,.84),CYAN,Enum.Font.GothamBold,true,Enum.TextXAlignment.Center)
end

local primary=frame(right,UDim2.fromScale(.08,.585),UDim2.fromScale(.84,.19),PINK,0,12)
local pg=Instance.new("UIGradient");pg.Color=ColorSequence.new(Color3.fromRGB(255,45,162),Color3.fromRGB(197,31,151));pg.Rotation=15;pg.Parent=primary
text(primary,"OPEN SUPPORT",UDim2.fromScale(.06,.17),UDim2.fromScale(.88,.42),WHITE,Enum.Font.GothamBlack,true,Enum.TextXAlignment.Center)
text(primary,"TAP / USE",UDim2.fromScale(.12,.60),UDim2.fromScale(.76,.22),Color3.fromRGB(255,218,239),Enum.Font.GothamBold,true,Enum.TextXAlignment.Center)

local hint=frame(right,UDim2.fromScale(.08,.80),UDim2.fromScale(.84,.115),Color3.fromRGB(12,20,26),.1,9)
outline(hint,CYAN,1,.55)
text(hint,"Every support lights up BBYA",UDim2.fromScale(.07,.14),UDim2.fromScale(.86,.72),Color3.fromRGB(193,235,247),Enum.Font.GothamMedium,true,Enum.TextXAlignment.Center)

-- FOOTER ----------------------------------------------------------------------
text(bg,"BBYA SOCIAL HUB",UDim2.fromScale(.055,.905),UDim2.fromScale(.30,.045),MUTED,Enum.Font.GothamBold,true)
text(bg,"24 / 7",UDim2.fromScale(.82,.905),UDim2.fromScale(.12,.045),CYAN,Enum.Font.GothamBlack,true,Enum.TextXAlignment.Right)
local footerLine=frame(bg,UDim2.fromScale(.055,.963),UDim2.fromScale(.89,.004),Color3.fromRGB(79,65,91),.35)

local prompt=Instance.new("ProximityPrompt")
prompt.Name="OpenSawerMenu"
prompt.ActionText="Support BBYA"
prompt.ObjectText="BBYA Support Wall"
prompt.KeyboardKeyCode=Enum.KeyCode.E
prompt.HoldDuration=0
prompt.MaxActivationDistance=14
prompt.RequiresLineOfSight=false
prompt.Parent=face

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
local state=remotes and remotes:FindFirstChild("State")
prompt.Triggered:Connect(function(player)
 if state then state:FireClient(player,"openSupport",true) end
end)

print("[BBYA] Premium glass support wall loaded on front-right wall")