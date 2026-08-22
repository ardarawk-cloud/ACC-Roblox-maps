-- BBYA SOCIAL HUB — VENUE LIGHTING v3
-- Material-first nightclub lighting: warm architectural base + restrained moving heads.
-- Server owns architecture and pan/tilt only; client audio-reactive renderer owns live beam intensity.

local W=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")

local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder",W)
root.Name="BBYA_ZERO_BUILD"
local old=root:FindFirstChild("ClubAmbience")
if old then old:Destroy() end

local m=Instance.new("Model")
m.Name="ClubAmbience"
m.Parent=root
m:SetAttribute("BBYALightingAuthority","SERVER_MOTION_CLIENT_AUDIO_INTENSITY_V3")

local C={
 pink=Color3.fromRGB(255,39,154),cyan=Color3.fromRGB(0,200,230),warm=Color3.fromRGB(255,191,132),neutral=Color3.fromRGB(224,214,207),
}
local function emitter(name,pos)
 local p=Instance.new("Part");p.Name=name;p.Size=Vector3.new(.3,.3,.3);p.CFrame=CFrame.new(pos);p.Anchored=true
 p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Transparency=1;p.Parent=m;return p
end
local function spot(name,pos,color,brightness,range,angle,phase)
 local p=emitter(name,pos)
 local s=Instance.new("SpotLight");s.Name="Beam";s.Face=Enum.NormalId.Bottom;s.Color=color;s.Brightness=brightness;s.Range=range;s.Angle=angle;s.Shadows=false;s.Parent=p
 s:SetAttribute("BBYAAudioReactive",true);s:SetAttribute("BBYABaseBrightness",brightness)
 return {p=p,s=s,phase=phase or 0,base=brightness}
end
local function point(name,pos,color,brightness,range,shadows)
 local p=emitter(name,pos)
 local l=Instance.new("PointLight");l.Name=name.."Light";l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=shadows==true;l.Parent=p
 return l
end

local rigs={
 spot("StageBeam_L",Vector3.new(-15,17.4,31),C.pink,1.65,44,27,.2),
 spot("StageBeam_C",Vector3.new(3,17.4,31),C.neutral,1.35,44,24,1.1),
 spot("StageBeam_R",Vector3.new(21,17.4,31),C.cyan,1.65,44,27,2.0),
 spot("DanceBeam_L",Vector3.new(-12,17.2,7),C.cyan,1.10,35,30,2.7),
 spot("DanceBeam_C",Vector3.new(3,17.2,7),C.warm,.95,35,28,3.4),
 spot("DanceBeam_R",Vector3.new(18,17.2,7),C.pink,1.10,35,30,4.1),
}

point("EntranceWarm",Vector3.new(0,8,-13),C.warm,.75,19,true)
point("VIPWarmFront",Vector3.new(-40,7,1),C.warm,.65,16,true)
point("VIPWarmRear",Vector3.new(-40,7,27),C.warm,.65,16,true)
point("BarWarmFront",Vector3.new(40,7,3),C.warm,.78,16,true)
point("BarWarmRear",Vector3.new(40,7,20),C.warm,.72,16,true)
point("StageWash",Vector3.new(3,12,39),Color3.fromRGB(190,173,196),.48,18,false)

Lighting.ClockTime=21.2
Lighting.Brightness=1.55
Lighting.Ambient=Color3.fromRGB(29,26,33)
Lighting.OutdoorAmbient=Color3.fromRGB(19,17,24)
Lighting.EnvironmentDiffuseScale=.34
Lighting.EnvironmentSpecularScale=.88
Lighting.ShadowSoftness=.32
Lighting.ExposureCompensation=-.20

local at=Lighting:FindFirstChild("BBYAAtmosphere") or Instance.new("Atmosphere")
at.Name="BBYAAtmosphere";at.Density=.19;at.Offset=.03;at.Color=Color3.fromRGB(151,139,166);at.Decay=Color3.fromRGB(50,39,59);at.Glare=.04;at.Haze=.55;at.Parent=Lighting
local bloom=Lighting:FindFirstChild("BBYABloom") or Instance.new("BloomEffect")
bloom.Name="BBYABloom";bloom.Intensity=.28;bloom.Size=22;bloom.Threshold=1.65;bloom.Parent=Lighting
local cc=Lighting:FindFirstChild("BBYAColor") or Instance.new("ColorCorrectionEffect")
cc.Name="BBYAColor";cc.Brightness=-.015;cc.Contrast=.08;cc.Saturation=-.035;cc.TintColor=Color3.fromRGB(244,236,248);cc.Parent=Lighting

-- Smooth low-frequency pan/tilt remains architectural motion. No fake timer-driven brightness pulse.
task.spawn(function()
 local t=0
 while m.Parent do
  t+=.035
  for i,r in ipairs(rigs) do
   local yaw=math.sin(t+r.phase)*((i<=3) and 10 or 7)
   local pitch=math.cos(t*.72+r.phase)*((i<=3) and 4 or 3)
   r.p.CFrame=CFrame.new(r.p.Position)*CFrame.Angles(math.rad(pitch),math.rad(yaw),0)
   r.s.Brightness=r.base
  end
  task.wait(.12)
 end
end)

print("[BBYA] venue lighting v3 online: warm base + restrained motion / client audio intensity")