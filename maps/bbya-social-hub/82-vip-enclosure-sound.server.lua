-- BBYA SOCIAL HUB — VIP ENCLOSURE + SOUND SYNC v7
-- Closed VIP shell + four positional speakers synced to Main western AutoDJ.
-- Every VIP speaker is routed through BBYAClubMaster so Basement local mixing can mute it completely.

local Workspace=game:GetService("Workspace")
local SoundService=game:GetService("SoundService")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
local vip=upper and upper:WaitForChild("L2_VIP_Level",30)
local active=vip and vip:WaitForChild("VIPMinimalStanding",30)
if not active then return end
task.wait(.55)

local old=active:FindFirstChild("VIPEnclosureV6") or active:FindFirstChild("VIPEnclosureV7")
if old then old:Destroy() end
local out=Instance.new("Model");out.Name="VIPEnclosureV7";out.Parent=active
out:SetAttribute("ClosedWalls",true);out:SetAttribute("FrontEntranceOpen",true);out:SetAttribute("RearSoundGuaranteed",true);out:SetAttribute("MainAudioGroupRouted",true)

local C={wall=Color3.fromRGB(19,20,23),panel=Color3.fromRGB(29,31,35),metal=Color3.fromRGB(62,66,72),speaker=Color3.fromRGB(9,10,12),grille=Color3.fromRGB(23,24,28)}
local function part(name,size,cf,color,mat,collide,parent)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.wall;p.Material=mat or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out;return p
end

local walls=Instance.new("Model");walls.Name="ClosedVIPWalls";walls.Parent=out
part("RearNorthWall",Vector3.new(116,18.5,1.2),CFrame.new(0,34.25,44.35),C.wall,Enum.Material.Concrete,true,walls)
part("WestWall",Vector3.new(1.2,18.5,90),CFrame.new(-57.35,34.25,0),C.wall,Enum.Material.Concrete,true,walls)
part("EastWall",Vector3.new(1.2,18.5,90),CFrame.new(57.35,34.25,0),C.wall,Enum.Material.Concrete,true,walls)
part("FrontWallLeft",Vector3.new(43,18.5,1.2),CFrame.new(-36.5,34.25,-44.35),C.wall,Enum.Material.Concrete,true,walls)
part("FrontWallRight",Vector3.new(43,18.5,1.2),CFrame.new(36.5,34.25,-44.35),C.wall,Enum.Material.Concrete,true,walls)

local panels=Instance.new("Model");panels.Name="WallAcousticPanels";panels.Parent=out
for _,z in ipairs({-30,-15,0,15,30}) do
 part("WestPanel"..z,Vector3.new(.25,12,10),CFrame.new(-56.65,34,z),C.panel,Enum.Material.Fabric,false,panels)
 part("EastPanel"..z,Vector3.new(.25,12,10),CFrame.new(56.65,34,z),C.panel,Enum.Material.Fabric,false,panels)
end
for _,x in ipairs({-48,-32,-16,0,16,32,48}) do part("RearPanel"..x,Vector3.new(10,12,.25),CFrame.new(x,34,43.65),C.panel,Enum.Material.Fabric,false,panels) end

local rig=active:FindFirstChild("SuspendedCornerSound")
if not rig then rig=Instance.new("Model");rig.Name="SuspendedCornerSound";rig.Parent=active end
local function ensureCluster(name,pos)
 local existing=rig:FindFirstChild("CornerSpeaker_"..name)
 if existing then return existing end
 local cluster=Instance.new("Model");cluster.Name="CornerSpeaker_"..name;cluster.Parent=rig
 local target=Vector3.new(0,28,0);local cf=CFrame.lookAt(pos,Vector3.new(target.X,pos.Y-1,target.Z))
 local cabinet=part("Cabinet",Vector3.new(5.2,7,3),cf,C.speaker,Enum.Material.Metal,false,cluster);cabinet:SetAttribute("Suspended",true);cabinet:SetAttribute("WallCorner",name)
 part("FrontGrille",Vector3.new(4.65,6.4,.12),cf*CFrame.new(0,0,-1.56),C.grille,Enum.Material.SmoothPlastic,false,cluster)
 for i,dy in ipairs({-1.55,1.2}) do local d=part("Driver"..i,Vector3.new(.18,2.35,2.35),cf*CFrame.new(0,dy,-1.64)*CFrame.Angles(0,math.rad(90),0),Color3.fromRGB(14,14,16),Enum.Material.SmoothPlastic,false,cluster);d.Shape=Enum.PartType.Cylinder end
 local right=cf.RightVector
 for i,offset in ipairs({-1.45,1.45}) do local anchor=pos+right*offset;part("Hanger"..i,Vector3.new(.16,2.1,.16),CFrame.new(anchor.X,42.45,anchor.Z),C.metal,Enum.Material.Metal,false,cluster) end
 local s=Instance.new("Sound");s.Name="CornerSpatialAudio";s.Volume=.065;s.Looped=false;s.RollOffMode=Enum.RollOffMode.InverseTapered;s.RollOffMinDistance=10;s.RollOffMaxDistance=72;s.EmitterSize=14
 local mainGroup=SoundService:FindFirstChild("BBYAClubMaster");if mainGroup then s.SoundGroup=mainGroup end
 s.Parent=cabinet
 return cluster
end
local corners={NW=Vector3.new(-54.5,38.1,40.5),NE=Vector3.new(54.5,38.1,40.5),SW=Vector3.new(-54.5,38.1,-40.5),SE=Vector3.new(54.5,38.1,-40.5)}
for name,pos in pairs(corners) do ensureCluster(name,pos) end

local function activeDeck()
 local a=SoundService:FindFirstChild("BBYAClubDeckA");local b=SoundService:FindFirstChild("BBYAClubDeckB")
 if a and a:IsA("Sound") and b and b:IsA("Sound") then
  if a.IsPlaying and b.IsPlaying then return (a.Volume>=b.Volume) and a or b end
  if a.IsPlaying then return a end;if b.IsPlaying then return b end
 elseif a and a:IsA("Sound") and a.IsPlaying then return a elseif b and b:IsA("Sound") and b.IsPlaying then return b end
end

task.spawn(function()
 while task.wait(.45) do
  local deck=activeDeck();local mainGroup=SoundService:FindFirstChild("BBYAClubMaster")
  if deck and deck.SoundId~="" then
   for _,obj in ipairs(rig:GetDescendants()) do
    if obj:IsA("Sound") and obj.Name=="CornerSpatialAudio" then
     if mainGroup then obj.SoundGroup=mainGroup end
     if obj.SoundId~=deck.SoundId then obj:Stop();obj.SoundId=deck.SoundId;obj.TimePosition=math.max(0,deck.TimePosition);obj:Play()
     elseif not obj.IsPlaying then obj.TimePosition=math.max(0,deck.TimePosition);obj:Play()
     elseif math.abs(obj.TimePosition-deck.TimePosition)>1.4 then obj.TimePosition=math.max(0,deck.TimePosition) end
     obj.PlaybackSpeed=deck.PlaybackSpeed;obj.Volume=.065
    end
   end
  end
 end
end)

print("[BBYA] VIP v7 online: Main-group routed corner speakers / zero Basement bleed")