local W=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local root=W:WaitForChild("BBYA_ZERO_BUILD")
local old=root:FindFirstChild("FinalPolish");if old then old:Destroy() end
local m=Instance.new("Model",root);m.Name="FinalPolish"
local C={pink=Color3.fromRGB(255,42,157),blue=Color3.fromRGB(0,174,255),warm=Color3.fromRGB(255,188,122),dark=Color3.fromRGB(18,16,22),metal=Color3.fromRGB(45,41,50)}
local function p(n,s,cf,c,mat,t,parent)local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.CanCollide=false;x.Size=s;x.CFrame=cf;x.Color=c;x.Material=mat or Enum.Material.SmoothPlastic;x.Transparency=t or 0;x.Parent=parent or m;return x end
local function neon(n,s,cf,c,parent)local x=p(n,s,cf,c or C.pink,Enum.Material.Neon,0,parent);local l=Instance.new("PointLight",x);l.Color=x.Color;l.Brightness=.8;l.Range=10;return x end
-- club ceiling ribs / visual depth
for _,z in ipairs({-18,-8,2,12,22}) do p("ClubCeilingRib"..z,Vector3.new(78,.45,1.2),CFrame.new(0,20,z),C.metal,Enum.Material.Metal) end
-- side wall accent lines, leaving entrance and center sightline clear
for _,x in ipairs({-43,43}) do for _,z in ipairs({-14,0,14,28}) do neon("WallAccent"..x.."_"..z,Vector3.new(.25,7,.25),CFrame.new(x,8,z),(z%28==0) and C.blue or C.pink) end end
-- dance floor perimeter trim
neon("DanceTrimFront",Vector3.new(62,.12,.25),CFrame.new(0,1,-21),C.pink)
neon("DanceTrimRear",Vector3.new(62,.12,.25),CFrame.new(0,1,21),C.blue)
neon("DanceTrimLeft",Vector3.new(.25,.12,42),CFrame.new(-31,1,0),C.pink)
neon("DanceTrimRight",Vector3.new(.25,.12,42),CFrame.new(31,1,0),C.blue)
-- premium VIP edge lighting
for _,z in ipairs({-25,25}) do neon("VIPEdgeZ"..z,Vector3.new(74,.18,.18),CFrame.new(0,25.1,z),C.pink) end
-- rooftop soft guide lights
for _,x in ipairs({-45,-30,-15,0,15,30,45}) do neon("RoofGuide"..x,Vector3.new(5,.12,.18),CFrame.new(x,45.2,-38),C.warm) end
-- exterior subtle side accents without touching locked entrance/signage objects
for _,x in ipairs({-52,52}) do neon("FacadeSideAccent"..x,Vector3.new(.2,12,.2),CFrame.new(x,13,-43.9),C.pink) end
-- lighting final tune
Lighting.ClockTime=21.15
Lighting.Brightness=2.2
Lighting.Ambient=Color3.fromRGB(58,43,62)
Lighting.OutdoorAmbient=Color3.fromRGB(32,27,38)
Lighting.EnvironmentDiffuseScale=.4
Lighting.EnvironmentSpecularScale=.65
local atm=Lighting:FindFirstChild("BBYAAtmosphere") or Instance.new("Atmosphere",Lighting);atm.Name="BBYAAtmosphere";atm.Density=.18;atm.Offset=.05;atm.Color=Color3.fromRGB(190,170,210);atm.Decay=Color3.fromRGB(80,60,90);atm.Glare=.08;atm.Haze=.6
local dof=Lighting:FindFirstChild("BBYADOF") or Instance.new("DepthOfFieldEffect",Lighting);dof.Name="BBYADOF";dof.FarIntensity=.06;dof.FocusDistance=70;dof.InFocusRadius=55;dof.NearIntensity=.02
print("[BBYA] final polish applied")