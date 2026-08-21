-- ACC Mountain cinematic ambience v4.1
local Lighting=game:GetService("Lighting")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Terrain=workspace.Terrain
local remotes=ReplicatedStorage:FindFirstChild("ACC_MountainRemotes") or Instance.new("Folder");remotes.Name="ACC_MountainRemotes";remotes.Parent=ReplicatedStorage
local weatherRemote=remotes:FindFirstChild("Weather") or Instance.new("RemoteEvent");weatherRemote.Name="Weather";weatherRemote.Parent=remotes
local atmosphere=Lighting:FindFirstChild("ACC_MountainAtmosphere") or Instance.new("Atmosphere");atmosphere.Name="ACC_MountainAtmosphere";atmosphere.Parent=Lighting
local cc=Lighting:FindFirstChild("ACC_MountainColor") or Instance.new("ColorCorrectionEffect");cc.Name="ACC_MountainColor";cc.Parent=Lighting
local bloom=Lighting:FindFirstChild("ACC_MountainBloom") or Instance.new("BloomEffect");bloom.Name="ACC_MountainBloom";bloom.Parent=Lighting
local rays=Lighting:FindFirstChild("ACC_MountainRays") or Instance.new("SunRaysEffect");rays.Name="ACC_MountainRays";rays.Parent=Lighting
local clouds=Terrain:FindFirstChild("ACC_MountainClouds") or Instance.new("Clouds");clouds.Name="ACC_MountainClouds";clouds.Parent=Terrain
Lighting.GlobalShadows=true;Lighting.EnvironmentDiffuseScale=.5;Lighting.EnvironmentSpecularScale=.45;Lighting.ShadowSoftness=.28
bloom.Size=32;bloom.Threshold=1.05;rays.Spread=.78
clouds.Cover=.42;clouds.Density=.72;clouds.Color=Color3.fromRGB(238,241,240)
-- Full cycle is intentionally visible during normal playtesting: ~32 real minutes.
local cycleMinutes=32
local started=os.clock()
local weatherMode="CLEAR"
local weatherUntil=0
local function phase(hour)
 if hour>=5 and hour<8 then
  Lighting.Brightness=2.05;Lighting.Ambient=Color3.fromRGB(118,105,97);Lighting.OutdoorAmbient=Color3.fromRGB(143,128,116);Lighting.ColorShift_Top=Color3.fromRGB(255,198,151);Lighting.ColorShift_Bottom=Color3.fromRGB(119,131,145)
  cc.Brightness=.025;cc.Contrast=.08;cc.Saturation=.03;cc.TintColor=Color3.fromRGB(255,231,205);bloom.Intensity=.22;rays.Intensity=.13;return "MORNING"
 elseif hour>=8 and hour<16.5 then
  Lighting.Brightness=2.45;Lighting.Ambient=Color3.fromRGB(118,126,133);Lighting.OutdoorAmbient=Color3.fromRGB(145,155,165);Lighting.ColorShift_Top=Color3.fromRGB(234,244,255);Lighting.ColorShift_Bottom=Color3.fromRGB(214,224,217)
  cc.Brightness=.01;cc.Contrast=.06;cc.Saturation=.02;cc.TintColor=Color3.fromRGB(247,252,255);bloom.Intensity=.12;rays.Intensity=.07;return "DAY"
 elseif hour>=16.5 and hour<19.2 then
  Lighting.Brightness=1.85;Lighting.Ambient=Color3.fromRGB(128,99,91);Lighting.OutdoorAmbient=Color3.fromRGB(152,118,103);Lighting.ColorShift_Top=Color3.fromRGB(255,163,112);Lighting.ColorShift_Bottom=Color3.fromRGB(105,111,132)
  cc.Brightness=.015;cc.Contrast=.11;cc.Saturation=.05;cc.TintColor=Color3.fromRGB(255,215,185);bloom.Intensity=.3;rays.Intensity=.16;return "SUNSET"
 else
  Lighting.Brightness=.72;Lighting.Ambient=Color3.fromRGB(39,48,66);Lighting.OutdoorAmbient=Color3.fromRGB(52,63,82);Lighting.ColorShift_Top=Color3.fromRGB(71,85,125);Lighting.ColorShift_Bottom=Color3.fromRGB(32,41,56)
  cc.Brightness=-.035;cc.Contrast=.15;cc.Saturation=-.11;cc.TintColor=Color3.fromRGB(199,215,245);bloom.Intensity=.16;rays.Intensity=0;return "NIGHT"
 end
end
local function weather(mode)
 weatherMode=mode
 if mode=="FOG" then atmosphere.Density=.43;atmosphere.Haze=2.1;atmosphere.Glare=.12;atmosphere.Color=Color3.fromRGB(190,203,204);clouds.Cover=.68;clouds.Density=.84
 elseif mode=="RAIN" then atmosphere.Density=.34;atmosphere.Haze=1.8;atmosphere.Glare=.06;atmosphere.Color=Color3.fromRGB(178,193,199);clouds.Cover=.82;clouds.Density=.9
 else atmosphere.Density=.24;atmosphere.Haze=1.05;atmosphere.Glare=.18;atmosphere.Color=Color3.fromRGB(203,218,224);clouds.Cover=.4;clouds.Density=.7 end
 workspace:SetAttribute("ACC_Weather",mode);weatherRemote:FireAllClients(mode)
end
weather("CLEAR")
task.spawn(function()
 while true do
  local elapsed=os.clock()-started;local h=((elapsed/60)/cycleMinutes*24+5.35)%24;Lighting.ClockTime=h
  local p=phase(h);workspace:SetAttribute("ACC_DayPhase",p);workspace:SetAttribute("ACC_ClockHour",math.floor(h*10)/10)
  task.wait(1)
 end
end)
task.spawn(function()
 while true do
  local now=os.clock()
  if now>=weatherUntil then local r=math.random();if r<.12 then weather("RAIN");weatherUntil=now+math.random(100,170) elseif r<.29 then weather("FOG");weatherUntil=now+math.random(120,200) else weather("CLEAR");weatherUntil=now+math.random(210,330) end end
  task.wait(15)
 end
end)
workspace:SetAttribute("ACC_TimeCycle","v4.1-four-phase")
workspace:SetAttribute("ACC_RealisticAmbience",true)
print("[ACC] cinematic morning/day/sunset/night cycle v4.1 ready")