-- BBYA SOCIAL HUB — REAR FUNKOT CLUB v1
-- Tall 30-stud hall behind the skatepark with architectural truss, moving heads, beams and lasers.
local Workspace=game:GetService("Workspace")
local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")
local RunService=game:GetService("RunService")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local old=root:FindFirstChild("FunkotClub")
if old then old:Destroy() end
local m=Instance.new("Model");m.Name="FunkotClub";m.Parent=root
m:SetAttribute("Pass","FUNKOT_CLUB_V1")
m:SetAttribute("TeleportKey","Funkot")
m:SetAttribute("CeilingHeightStuds",30)
m:SetAttribute("Location","BEHIND_SKATEPARK")

local C={
 black=Color3.fromRGB(8,8,11),
 charcoal=Color3.fromRGB(20,21,25),
 metal=Color3.fromRGB(54,57,64),
 silver=Color3.fromRGB(115,120,128),
 white=Color3.fromRGB(239,238,235),
 pink=Color3.fromRGB(248,35,151),
 cyan=Color3.fromRGB(0,190,226),
 violet=Color3.fromRGB(146,72,255),
 red=Color3.fromRGB(255,55,70),
 amber=Color3.fromRGB(255,180,52),
}
local function part(name,size,cf,color,mat,collide,parent,shape)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.charcoal;p.Material=mat or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if shape then p.Shape=shape end
 p.Parent=parent or m
 return p
end
local function cylinder(name,size,cf,color,parent,collide)
 return part(name,size,cf,color or C.metal,Enum.Material.Metal,collide==true,parent,Enum.PartType.Cylinder)
end
local function neon(name,size,cf,color,parent)
 local p=part(name,size,cf,color,Enum.Material.Neon,false,parent);p.CastShadow=false;return p
end
local function labelPart(name,textValue,size,cf)
 local p=part(name,size,cf,C.black,Enum.Material.Metal,false)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.PixelsPerStud=55;g.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=textValue;t.TextColor3=C.white;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.Parent=g
 local grad=Instance.new("UIGradient");grad.Color=ColorSequence.new(C.pink,C.cyan);grad.Parent=t
 return p
end

-- Connector from the rear skatepark. The park ends around Z=150; club begins after it.
part("ConnectorFloor",Vector3.new(18,.7,22),CFrame.new(0,.55,160),Color3.fromRGB(45,46,50),Enum.Material.Concrete,true)
for _,x in ipairs({-9,9}) do
 cylinder("ConnectorRail"..x,Vector3.new(20,.28,.28),CFrame.new(x,2.1,160)*CFrame.Angles(0,0,math.rad(90)),C.silver,nil,false)
end

-- Main shell: ~112 x 88 with 30-stud clear ceiling height.
local centerZ=205
local floorY=.55
local ceilingY=30.5
part("DanceFloorSlab",Vector3.new(112,1,88),CFrame.new(0,floorY,centerZ),Color3.fromRGB(27,28,32),Enum.Material.Concrete,true)
part("NorthWall",Vector3.new(112,30,2),CFrame.new(0,15.5,249),C.charcoal,Enum.Material.Concrete,true)
part("WestWall",Vector3.new(2,30,88),CFrame.new(-56,15.5,205),C.charcoal,Enum.Material.Concrete,true)
part("EastWall",Vector3.new(2,30,88),CFrame.new(56,15.5,205),C.charcoal,Enum.Material.Concrete,true)
part("SouthWallL",Vector3.new(44,30,2),CFrame.new(-34,15.5,161),C.charcoal,Enum.Material.Concrete,true)
part("SouthWallR",Vector3.new(44,30,2),CFrame.new(34,15.5,161),C.charcoal,Enum.Material.Concrete,true)
part("Ceiling",Vector3.new(112,1.2,88),CFrame.new(0,ceilingY,centerZ),C.black,Enum.Material.Metal,true)

-- Architectural wall ribs and soft uplighting: breaks the boxy shell into club-scale bays.
local ribs=Instance.new("Model");ribs.Name="ArchitecturalRibs";ribs.Parent=m
for _,x in ipairs({-50,-38,-26,-14,14,26,38,50}) do
 cylinder("NorthRib"..x,Vector3.new(27,.52,.52),CFrame.new(x,15.5,247.8)*CFrame.Angles(0,0,math.rad(90)),C.metal,ribs,false)
 cylinder("SouthRib"..x,Vector3.new(27,.52,.52),CFrame.new(x,15.5,162.2)*CFrame.Angles(0,0,math.rad(90)),C.metal,ribs,false)
end
for _,z in ipairs({170,182,194,206,218,230,242}) do
 cylinder("WestRib"..z,Vector3.new(27,.52,.52),CFrame.new(-54.8,15.5,z)*CFrame.Angles(0,0,math.rad(90)),C.metal,ribs,false)
 cylinder("EastRib"..z,Vector3.new(27,.52,.52),CFrame.new(54.8,15.5,z)*CFrame.Angles(0,0,math.rad(90)),C.metal,ribs,false)
end

-- Raised stage / DJ booth.
part("Stage",Vector3.new(64,2,16),CFrame.new(0,1.7,238),Color3.fromRGB(31,31,36),Enum.Material.Metal,true)
part("StageFront",Vector3.new(62,1,.45),CFrame.new(0,2.1,229.8),C.black,Enum.Material.Metal,false)
neon("StageFrontPink",Vector3.new(57,.14,.14),CFrame.new(0,2.65,229.55),C.pink)
part("DJBoothBody",Vector3.new(32,4.4,6),CFrame.new(0,4.8,239),Color3.fromRGB(19,20,24),Enum.Material.Metal,true)
part("DJBoothTop",Vector3.new(35,.55,7),CFrame.new(0,7.25,239),C.silver,Enum.Material.Metal,true)
neon("DJBoothCyan",Vector3.new(29,.16,.16),CFrame.new(0,6.1,235.9),C.cyan)
for _,x in ipairs({-9,9}) do
 cylinder("DeckJog"..x,Vector3.new(.35,3.8,3.8),CFrame.new(x,7.8,239)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(80,83,90),nil,false)
end
part("Mixer",Vector3.new(7,.5,4),CFrame.new(0,7.65,239),C.black,Enum.Material.Metal,false)

labelPart("FunkotSign","BBYA  FUNKOT  CLUB",Vector3.new(46,7,.55),CFrame.new(0,13.5,247.6))
labelPart("EntrySign","FUNKOT CLUB  •  10 R$",Vector3.new(26,4,.45),CFrame.new(0,13,162.1)*CFrame.Angles(0,math.rad(180),0))

-- Lounge islands: cylinders/rounded silhouettes rather than block walls.
local lounge=Instance.new("Model");lounge.Name="LoungeIslands";lounge.Parent=m
for _,x in ipairs({-43,43}) do
 for _,z in ipairs({184,209}) do
  cylinder("RoundSofaBase"..x.."_"..z,Vector3.new(2.1,12,12),CFrame.new(x,2.25,z)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(30,31,37),lounge,true)
  cylinder("Table"..x.."_"..z,Vector3.new(.7,5.2,5.2),CFrame.new(x,3.1,z)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(68,73,82),lounge,true)
  neon("TableRing"..x.."_"..z,Vector3.new(.12,5.6,5.6),CFrame.new(x,3.5,z)*CFrame.Angles(0,0,math.rad(90)),(z%2==0) and C.cyan or C.pink,lounge)
 end
end

-- Ceiling truss at Y 24-27: enough vertical volume for true club lighting.
local truss=Instance.new("Model");truss.Name="CeilingTruss";truss.Parent=m
for _,z in ipairs({176,193,210,227,242}) do
 cylinder("TrussH"..z,Vector3.new(104,.42,.42),CFrame.new(0,26,z),C.silver,truss,false)
end
for _,x in ipairs({-46,-23,0,23,46}) do
 cylinder("TrussV"..x,Vector3.new(78,.42,.42),CFrame.new(x,26,205)*CFrame.Angles(0,math.rad(90),0),C.silver,truss,false)
end

-- Moving heads + spots.
local moving=Instance.new("Model");moving.Name="MovingHeads";moving.Parent=m
local movers={}
for i,x in ipairs({-42,-28,-14,0,14,28,42}) do
 local z=(i%2==0) and 194 or 216
 local mount=cylinder("MoverMount"..i,Vector3.new(.8,2.2,2.2),CFrame.new(x,25.2,z)*CFrame.Angles(0,0,math.rad(90)),C.black,moving,false)
 local head=part("MoverHead"..i,Vector3.new(1.5,2.2,2.8),CFrame.new(x,23.8,z),C.metal,Enum.Material.Metal,false,moving)
 local spot=Instance.new("SpotLight");spot.Face=Enum.NormalId.Bottom;spot.Angle=30;spot.Range=58;spot.Brightness=5;spot.Shadows=true;spot.Color=({C.pink,C.cyan,C.violet,C.white,C.red,C.cyan,C.pink})[i];spot.Parent=head
 table.insert(movers,{part=head,x=x,z=z,phase=i*.75})
end

-- Laser emitters and animated targets.
local lasers=Instance.new("Model");lasers.Name="LaserRig";lasers.Parent=m
local laserRows={}
for i,x in ipairs({-45,-30,-15,0,15,30,45}) do
 local emitter=part("LaserEmitter"..i,Vector3.new(.8,.8,1.2),CFrame.new(x,24.5,235),C.black,Enum.Material.Metal,false,lasers)
 local a0=Instance.new("Attachment");a0.Name="Emitter";a0.Parent=emitter
 local target=part("LaserTarget"..i,Vector3.new(.15,.15,.15),CFrame.new(x,4,180),C.black,Enum.Material.SmoothPlastic,false,lasers);target.Transparency=1
 local a1=Instance.new("Attachment");a1.Name="Target";a1.Parent=target
 local beam=Instance.new("Beam");beam.Attachment0=a0;beam.Attachment1=a1;beam.FaceCamera=true;beam.Width0=.07;beam.Width1=.035;beam.LightEmission=1;beam.LightInfluence=0;beam.Color=ColorSequence.new((i%2==0) and C.cyan or C.pink);beam.Transparency=NumberSequence.new(.08);beam.Parent=emitter
 table.insert(laserRows,{target=target,x=x,phase=i*.9})
end

-- Floor strips and wall wash, restrained so the room remains readable.
for _,x in ipairs({-46,-23,0,23,46}) do neon("FloorStrip"..x,Vector3.new(.13,.08,62),CFrame.new(x,1.08,205),(x%46==0) and C.pink or C.cyan) end
for _,z in ipairs({174,190,206,222,238}) do
 local wash=part("WallWashL"..z,Vector3.new(.35,.35,.35),CFrame.new(-53.8,4,z),C.black,Enum.Material.Metal,false)
 local l=Instance.new("PointLight");l.Color=(z%2==0) and C.violet or C.pink;l.Brightness=2;l.Range=18;l.Shadows=false;l.Parent=wash
 local wash2=wash:Clone();wash2.Name="WallWashR"..z;wash2.CFrame=CFrame.new(53.8,4,z);wash2.Parent=m
end

-- Dedicated Funkot audio group. Existing approved/working IDs only; silently skips unavailable assets.
local oldGroup=SoundService:FindFirstChild("BBYAFunkotMaster");if oldGroup then oldGroup:Destroy() end
local group=Instance.new("SoundGroup");group.Name="BBYAFunkotMaster";group.Volume=0;group.Parent=SoundService
group:SetAttribute("Venue","FUNKOT_CLUB");group:SetAttribute("GenrePolicy","FUNKOT_ONLY")
local eq=Instance.new("EqualizerSoundEffect");eq.LowGain=2.0;eq.MidGain=-.3;eq.HighGain=.65;eq.Parent=group
local comp=Instance.new("CompressorSoundEffect");comp.Threshold=-9;comp.Ratio=2.4;comp.Attack=.04;comp.Release=.22;comp.GainMakeup=.5;comp.Parent=group
local playlist={
 "110691393637838","134073539670673","116255319981650","124224888312006","83125775305712","95602240268105","103451932037576","98095276635738","134100771661430","79905157574964","78891075630689"
}
local sound=Instance.new("Sound");sound.Name="BBYAFunkotClubFeed";sound.SoundGroup=group;sound.Volume=1;sound.Looped=false;sound.Parent=SoundService
local index=0
local function nextTrack()
 for _=1,#playlist do
  index=(index%#playlist)+1
  sound:Stop();sound.SoundId="rbxassetid://"..playlist[index]
  local ok=pcall(function()ContentProvider:PreloadAsync({sound})end)
  if ok then
   sound:Play();task.wait(.4)
   if sound.IsPlaying and (sound.TimeLength or 0)>1 then group:SetAttribute("CurrentAssetId",playlist[index]);return end
  end
 end
 warn("[BBYA/Funkot] no accessible Funkot track in current playlist")
end
sound.Ended:Connect(function()task.defer(nextTrack)end)
task.delay(2,nextTrack)

local start=os.clock()
RunService.Heartbeat:Connect(function()
 local t=os.clock()-start
 for _,row in ipairs(movers) do
  local yaw=math.sin(t*.55+row.phase)*.65
  local pitch=.45+math.sin(t*.72+row.phase)*.18
  row.part.CFrame=CFrame.new(row.x,23.8,row.z)*CFrame.Angles(pitch,yaw,0)
 end
 for _,row in ipairs(laserRows) do
  local x=row.x+math.sin(t*1.05+row.phase)*18
  local z=180+math.cos(t*.82+row.phase)*24
  row.target.CFrame=CFrame.new(x,2.1,z)
 end
end)

print("[BBYA] Funkot Club v1 online: tall 30-stud hall / full moving light rig / laser system")
