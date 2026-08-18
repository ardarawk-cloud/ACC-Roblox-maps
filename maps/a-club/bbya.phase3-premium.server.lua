-- BBYA SOCIAL HUB — PREMIUM PHASE 3 v4.3
-- Lobby depth + Queen Skybox polish + rooftop event atmosphere + supporter venue celebration.

local TweenService = game:GetService("TweenService")

local ROOT_NAME = "BBYA Premium Phase 3 v4.3"
local old = workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

-- Wait for the v4 shell before decorating it.
local rebuild = workspace:WaitForChild("BBYA Premium Visual Rebuild v4", 15)
if not rebuild then
	warn("[BBYA PHASE3] Premium Visual Rebuild v4 not found")
	return
end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local C = {
	black = Color3.fromRGB(8,8,14),
	stone = Color3.fromRGB(38,34,44),
	stone2 = Color3.fromRGB(56,48,61),
	pink = Color3.fromRGB(255,45,170),
	purple = Color3.fromRGB(126,62,225),
	cyan = Color3.fromRGB(48,228,255),
	gold = Color3.fromRGB(255,193,79),
	warm = Color3.fromRGB(255,128,72),
	glass = Color3.fromRGB(69,100,130),
	green = Color3.fromRGB(40,108,72),
}

local function part(name,size,cf,color,material,transparency,collide,parent)
	local p=Instance.new("Part")
	p.Name=name
	p.Size=size
	p.CFrame=cf
	p.Anchored=true
	p.CanCollide=collide~=false
	p.Material=material or Enum.Material.SmoothPlastic
	p.Color=color or C.stone
	p.Transparency=transparency or 0
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	p.Parent=parent or root
	return p
end

local function neon(name,size,cf,color,parent,brightness,range)
	local p=part(name,size,cf,color,Enum.Material.Neon,0,false,parent)
	local l=Instance.new("PointLight")
	l.Color=color
	l.Brightness=brightness or .8
	l.Range=range or 10
	l.Shadows=false
	l.Parent=p
	return p
end

local function glass(name,size,cf,parent)
	return part(name,size,cf,C.glass,Enum.Material.Glass,.5,false,parent)
end

local function sign(name,text,cf,size,color,parent)
	local p=part(name,size,cf,C.black,Enum.Material.SmoothPlastic,0,false,parent)
	local g=Instance.new("SurfaceGui")
	g.Face=Enum.NormalId.Front
	g.LightInfluence=0
	g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
	g.PixelsPerStud=30
	g.Parent=p
	local t=Instance.new("TextLabel")
	t.Name="Text"
	t.Size=UDim2.fromScale(1,1)
	t.BackgroundTransparency=1
	t.Text=text
	t.TextColor3=color or C.pink
	t.TextStrokeTransparency=.3
	t.Font=Enum.Font.GothamBlack
	t.TextScaled=true
	t.TextWrapped=true
	t.Parent=g
	return p,t
end

local function seat(name,cf,size,color,parent)
	local s=Instance.new("Seat")
	s.Name=name
	s.Size=size or Vector3.new(5,1.3,4)
	s.CFrame=cf
	s.Anchored=true
	s.Material=Enum.Material.Fabric
	s.Color=color or C.purple
	s.Parent=parent
	return s
end

-- ============================================================
-- 01 PREMIUM LOBBY EXPERIENCE
-- ============================================================
local lobby=Instance.new("Folder")
lobby.Name="01 Premium Lobby Experience"
lobby.Parent=root

-- Concierge island + architectural portal.
part("Lobby Concierge Island",Vector3.new(30,3.2,8),CFrame.new(0,3.5,61),C.black,Enum.Material.Marble,0,true,lobby)
neon("Concierge Gold Rim",Vector3.new(28,.16,.18),CFrame.new(0,5.1,57.1),C.gold,lobby,.55,8)
sign("Concierge Sign","WELCOME TO BBYA",CFrame.new(0,7.5,56.9),Vector3.new(26,3,.35),C.pink,lobby)

for _,x in ipairs({-18,18}) do
	part("Portal Column "..x,Vector3.new(3,16,3),CFrame.new(x,10,45),C.stone2,Enum.Material.Marble,0,true,lobby)
	neon("Portal Light "..x,Vector3.new(.24,13,.24),CFrame.new(x + (x<0 and 1.7 or -1.7),10,43.7),x<0 and C.cyan or C.pink,lobby,.9,10)
end
part("Portal Crown",Vector3.new(39,2.2,3),CFrame.new(0,18,45),C.black,Enum.Material.Metal,0,true,lobby)
sign("Portal Title","ENTER THE NIGHT",CFrame.new(0,18,43.35),Vector3.new(30,4,.3),C.cyan,lobby)

-- Lounge waiting pockets.
for _,cfg in ipairs({{-35,53,12},{35,53,-12}}) do
	local x,z,yaw=cfg[1],cfg[2],cfg[3]
	seat("Lobby Sofa A "..x,CFrame.new(x,3.1,z)*CFrame.Angles(0,math.rad(yaw),0),Vector3.new(8,1.3,4),Color3.fromRGB(75,48,79),lobby)
	seat("Lobby Sofa B "..x,CFrame.new(x,3.1,z-8)*CFrame.Angles(0,math.rad(-yaw),0),Vector3.new(8,1.3,4),Color3.fromRGB(68,45,76),lobby)
	part("Lobby Table "..x,Vector3.new(5,.8,5),CFrame.new(x,2.9,z-4),C.black,Enum.Material.Glass,.12,true,lobby)
	neon("Lobby Table Glow "..x,Vector3.new(4,.08,.12),CFrame.new(x,3.35,z-6.4),x<0 and C.cyan or C.pink,lobby,.35,5)
end

-- Central reflecting strip gives a luxury-hotel arrival feel.
part("Lobby Reflecting Strip",Vector3.new(10,.25,24),CFrame.new(0,2.55,75),Color3.fromRGB(35,145,205),Enum.Material.Glass,.28,false,lobby)
neon("Lobby Water Edge L",Vector3.new(.12,.08,23),CFrame.new(-5.1,2.72,75),C.cyan,lobby,.35,6)
neon("Lobby Water Edge R",Vector3.new(.12,.08,23),CFrame.new(5.1,2.72,75),C.pink,lobby,.35,6)

-- ============================================================
-- 02 QUEEN SKYBOX PREMIUM PASS
-- ============================================================
local queen=Instance.new("Folder")
queen.Name="02 Queen Skybox Premium"
queen.Parent=root

-- Crown canopy and privacy wings around the existing throne zone.
part("Queen Canopy",Vector3.new(46,1.2,28),CFrame.new(0,35,15),C.black,Enum.Material.Metal,0,true,queen)
for _,x in ipairs({-21,21}) do
	glass("Queen Side Glass "..x,Vector3.new(1,10,25),CFrame.new(x,28,15),queen)
	neon("Queen Side Accent "..x,Vector3.new(.22,8,.22),CFrame.new(x + (x<0 and .7 or -.7),29,3),x<0 and C.cyan or C.pink,queen,.65,8)
end

for i=-3,3 do
	local height=4 + (3-math.abs(i))*1.2
	neon("Queen Crown Ray "..i,Vector3.new(.65,height,.65),CFrame.new(i*3,36+height/2,16),i%2==0 and C.gold or C.pink,queen,.7,8)
end

-- Private social benches + center table.
seat("Queen Guest Sofa L",CFrame.new(-12,23.2,13)*CFrame.Angles(0,math.rad(20),0),Vector3.new(9,1.4,4.5),Color3.fromRGB(84,50,88),queen)
seat("Queen Guest Sofa R",CFrame.new(12,23.2,13)*CFrame.Angles(0,math.rad(-20),0),Vector3.new(9,1.4,4.5),Color3.fromRGB(84,50,88),queen)
part("Queen Crystal Table",Vector3.new(8,1,5),CFrame.new(0,23.2,11),C.glass,Enum.Material.Glass,.28,true,queen)
neon("Queen Table Glow",Vector3.new(7,.1,.15),CFrame.new(0,23.75,8.6),C.gold,queen,.35,5)
sign("Queen Private Label","♛ QUEEN SKYBOX • PRIVATE VIEW",CFrame.new(0,29.5,3.15),Vector3.new(35,3.3,.3),C.gold,queen)

-- ============================================================
-- 03 ROOFTOP EVENT ATMOSPHERE
-- ============================================================
local roof=Instance.new("Folder")
roof.Name="03 Rooftop Event Atmosphere"
roof.Parent=root

-- Event arches framing the pool party deck.
for _,x in ipairs({-44,44}) do
	part("Rooftop Event Column "..x,Vector3.new(2,12,2),CFrame.new(x,44,18),C.black,Enum.Material.Metal,0,true,roof)
	neon("Rooftop Column Glow "..x,Vector3.new(.28,10,.28),CFrame.new(x,44,16.9),x<0 and C.cyan or C.pink,roof,.75,10)
end
part("Rooftop Event Arch",Vector3.new(90,1.2,2),CFrame.new(0,50,18),C.black,Enum.Material.Metal,0,true,roof)
sign("Rooftop Event Banner","BBYA • BALI AFTER DARK",CFrame.new(0,48.2,16.9),Vector3.new(44,4,.35),C.pink,roof)

-- Pool halo and warm social fire bowls (lights only; no heavy particles).
for i=0,15 do
	local a=(math.pi*2)*(i/16)
	local x=math.cos(a)*42
	local z=-25+math.sin(a)*24
	neon("Pool Halo "..i,Vector3.new(2.2,.18,.45),CFrame.new(x,39.2,z)*CFrame.Angles(0,-a,0),i%2==0 and C.cyan or C.pink,roof,.3,5)
end

for _,pos in ipairs({Vector3.new(-57,39,-36),Vector3.new(57,39,-36),Vector3.new(-57,39,22),Vector3.new(57,39,22)}) do
	part("Fire Bowl",Vector3.new(4,1.2,4),CFrame.new(pos),C.black,Enum.Material.Metal,0,true,roof)
	local flame=neon("Fire Bowl Glow",Vector3.new(2,.6,2),CFrame.new(pos+Vector3.new(0,1,0)),C.warm,roof,.7,8)
	flame.Shape=Enum.PartType.Ball
end

-- Elevated photo bridge looking over the pool.
part("Rooftop Photo Bridge",Vector3.new(36,1.2,8),CFrame.new(0,42.5,6),C.stone2,Enum.Material.Marble,0,true,roof)
glass("Photo Bridge Rail L",Vector3.new(36,3,.4),CFrame.new(0,44.2,2.1),roof)
glass("Photo Bridge Rail R",Vector3.new(36,3,.4),CFrame.new(0,44.2,9.9),roof)
neon("Photo Bridge Edge L",Vector3.new(34,.14,.18),CFrame.new(0,43.2,2),C.cyan,roof,.4,6)
neon("Photo Bridge Edge R",Vector3.new(34,.14,.18),CFrame.new(0,43.2,10),C.pink,roof,.4,6)
sign("Photo Bridge Sign","PHOTO SPOT • BBYA",CFrame.new(0,47.5,10.2),Vector3.new(25,3,.3),C.gold,roof)

-- ============================================================
-- 04 SUPPORT / SAWER CELEBRATION IN-VENUE
-- ============================================================
local support=Instance.new("Folder")
support.Name="04 Support Celebration"
support.Parent=root

local screen,screenText=sign("Support Celebration Screen","SUPPORT THE NIGHT",CFrame.new(0,15,-56.9),Vector3.new(45,5,.35),C.gold,support)
local supportBars={}
for i=-5,5 do
	local b=neon("Support Pulse "..i,Vector3.new(2.4,.35,.28),CFrame.new(i*4,10,-56.8),i%2==0 and C.pink or C.cyan,support,.25,5)
	table.insert(supportBars,b)
end

local pulseToken=0
local function celebrate()
	local name=workspace:GetAttribute("BBYALastSupporter")
	local amount=workspace:GetAttribute("BBYALastSupportAmount")
	if not name or not amount or tonumber(amount or 0)<=0 then return end
	pulseToken += 1
	local mine=pulseToken
	screenText.Text=string.format("♥ %s • SAWER R$%d ♥",tostring(name),tonumber(amount) or 0)
	screenText.TextColor3=C.gold
	for _,b in ipairs(supportBars) do
		TweenService:Create(b,TweenInfo.new(.18),{Size=Vector3.new(2.4,2.1,.28),Color=C.gold}):Play()
		local l=b:FindFirstChildOfClass("PointLight")
		if l then l.Brightness=1.4 end
	end
	task.delay(2.6,function()
		if mine~=pulseToken then return end
		screenText.Text="SUPPORT THE NIGHT"
		screenText.TextColor3=C.gold
		for i,b in ipairs(supportBars) do
			TweenService:Create(b,TweenInfo.new(.3),{Size=Vector3.new(2.4,.35,.28),Color=i%2==0 and C.pink or C.cyan}):Play()
			local l=b:FindFirstChildOfClass("PointLight")
			if l then l.Brightness=.25 end
		end
	end)
end

workspace:GetAttributeChangedSignal("BBYALastSupportAmount"):Connect(celebrate)

workspace:SetAttribute("BBYAPremiumPhase3","4.3")
print("[BBYA] Premium Phase 3 v4.3 loaded")
