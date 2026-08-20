local Lighting=game:GetService("Lighting")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local remotes=ReplicatedStorage:FindFirstChild("ACC_MountainRemotes") or Instance.new("Folder");remotes.Name="ACC_MountainRemotes";remotes.Parent=ReplicatedStorage
local weatherRemote=remotes:FindFirstChild("Weather") or Instance.new("RemoteEvent");weatherRemote.Name="Weather";weatherRemote.Parent=remotes
local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere");atmosphere.Name="ACC_MountainAtmosphere";atmosphere.Parent=Lighting
local cc=Lighting:FindFirstChild("ACC_MountainColor") or Instance.new("ColorCorrectionEffect");cc.Name="ACC_MountainColor";cc.Parent=Lighting
Lighting.GlobalShadows=true;Lighting.EnvironmentDiffuseScale=.35;Lighting.EnvironmentSpecularScale=.32
local cycleMinutes=40;local weatherEndsAt=0
local function grade(hour)
 if hour>=4.8 and hour<7 then Lighting.Brightness=1.8;Lighting.OutdoorAmbient=Color3.fromRGB(133,122,118);cc.Brightness=.025;cc.Contrast=.08;cc.Saturation=-.02
 elseif hour>=7 and hour<16.8 then Lighting.Brightness=2.15;Lighting.OutdoorAmbient=Color3.fromRGB(126,136,149);cc.Brightness=.01;cc.Contrast=.07;cc.Saturation=-.035
 elseif hour>=16.8 and hour<19 then Lighting.Brightness=1.85;Lighting.OutdoorAmbient=Color3.fromRGB(145,116,104);cc.Brightness=.015;cc.Contrast=.1;cc.Saturation=-.015
 else Lighting.Brightness=.85;Lighting.OutdoorAmbient=Color3.fromRGB(58,67,84);cc.Brightness=-.025;cc.Contrast=.12;cc.Saturation=-.12 end
end
local function applyWeather(mode)
 if mode=="FOG" then atmosphere.Density=.48;atmosphere.Haze=2.3;atmosphere.Color=Color3.fromRGB(188,203,207)
 elseif mode=="RAIN" then atmosphere.Density=.36;atmosphere.Haze=1.85;atmosphere.Color=Color3.fromRGB(176,193,201)
 else atmosphere.Density=.27;atmosphere.Haze=1.35;atmosphere.Color=Color3.fromRGB(199,217,225) end
 workspace:SetAttribute("ACC_Weather",mode);weatherRemote:FireAllClients(mode)
end
applyWeather("CLEAR")
local started=os.clock()
task.spawn(function() while true do local elapsed=os.clock()-started;local h=((elapsed/60)/cycleMinutes*24+5.15)%24;Lighting.ClockTime=h;grade(h);workspace:SetAttribute("ACC_DayPhase",h<7 and "SUNRISE" or h<17 and "DAY" or h<19 and "SUNSET" or "NIGHT");task.wait(1) end end)
task.spawn(function() while true do local now=os.clock();if now>=weatherEndsAt then local r=math.random();if r<.16 then applyWeather("RAIN");weatherEndsAt=now+math.random(120,220) elseif r<.40 then applyWeather("FOG");weatherEndsAt=now+math.random(140,260) else applyWeather("CLEAR");weatherEndsAt=now+math.random(200,360) end end;task.wait(20) end end)