local W=game:GetService("Workspace")
local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder",W);root.Name="BBYA_ZERO_BUILD"
local old=root:FindFirstChild("ShellAndDressing");if old then old:Destroy() end
local m=Instance.new("Model",root);m.Name="ShellAndDressing"
local C={dark=Color3.fromRGB(10,9,13),wall=Color3.fromRGB(28,23,31),floor=Color3.fromRGB(61,49,56),pink=Color3.fromRGB(255,42,157),blue=Color3.fromRGB(0,174,255),warm=Color3.fromRGB(255,188,122),metal=Color3.fromRGB(44,39,49),glass=Color3.fromRGB(60,38,67)}
local function p(n,s,cf,c,mat,t)local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Color=c;x.Material=mat or Enum.Material.SmoothPlastic;x.Transparency=t or 0;x.Parent=m;return x end
local function neon(n,s,cf,c)local x=p(n,s,cf,c or C.pink,Enum.Material.Neon);x.CanCollide=false;local l=Instance.new("PointLight",x);l.Color=x.Color;l.Brightness=1.15;l.Range=12;return x end
-- Irregular L1 shell: stepped wings, wide central club mass, narrower rear stage mass.
p("L1WestFrontWall",Vector3.new(2,24,34),CFrame.new(-48,12,-28),C.dark)
p("L1EastFrontWall",Vector3.new(2,24,28),CFrame.new(44,12,-31),C.dark)
p("L1WestClubWall",Vector3.new(2,24,54),CFrame.new(-59,12,7),C.dark)
p("L1EastClubWall",Vector3.new(2,24,48),CFrame.new(59,12,10),C.dark)
p("L1RearLeft",Vector3.new(28,24,2),CFrame.new(-42,12,42),C.dark)
p("L1RearCenter",Vector3.new(64,24,2),CFrame.new(0,12,44),C.dark)
p("L1RearRight",Vector3.new(28,24,2),CFrame.new(42,12,40),C.dark)
-- structural columns around club, not through center
for _,x in ipairs({-34,34}) do for _,z in ipairs({-18,18}) do p("ClubColumn"..x.."_"..z,Vector3.new(2.4,24,2.4),CFrame.new(x,12,z),C.metal,Enum.Material.Metal) end end
-- upper perimeter fascia emphasizing vertical mass
p("L2WestFascia",Vector3.new(2,20,72),CFrame.new(-59,34,4),C.wall,Enum.Material.Metal)
p("L2EastFascia",Vector3.new(2,20,72),CFrame.new(59,34,4),C.wall,Enum.Material.Metal)
p("L2RearFascia",Vector3.new(120,20,2),CFrame.new(0,34,44),C.wall,Enum.Material.Metal)
-- reception lounge dressing
for _,x in ipairs({-14,14}) do p("ReceptionBench"..x,Vector3.new(10,2,4),CFrame.new(x,1.5,-27),C.metal,Enum.Material.Slate) end
-- photo area platform + halo
p("PhotoPodium",Vector3.new(12,1.2,8),CFrame.new(-41,1.2,-34),C.metal,Enum.Material.Metal)
neon("PhotoHaloTop",Vector3.new(12,.3,.3),CFrame.new(-41,10,-25.2),C.pink)
-- salon stations + stools
for _,z in ipairs({-20,-12,-4}) do p("SalonStool"..z,Vector3.new(3,2,3),CFrame.new(-43,1.5,z),C.metal,Enum.Material.Metal) end
-- dance-floor low perimeter seating; center remains open
for _,z in ipairs({-16,16}) do p("DanceSofaL"..z,Vector3.new(12,2.5,4),CFrame.new(-40,1.7,z),C.metal,Enum.Material.Fabric);p("DanceSofaR"..z,Vector3.new(12,2.5,4),CFrame.new(40,1.7,z),C.metal,Enum.Material.Fabric) end
-- main bar details
for _,z in ipairs({-8,-2,4,10}) do p("BarStool"..z,Vector3.new(2.5,2.2,2.5),CFrame.new(34.5,1.6,z),C.metal,Enum.Material.Metal) end
-- DJ riser screen and stage accents
p("DJScreen",Vector3.new(30,8,.5),CFrame.new(0,9,35),C.glass,Enum.Material.Glass,.12)
for _,x in ipairs({-12,-6,0,6,12}) do neon("StageVertical"..x,Vector3.new(.35,8,.35),CFrame.new(x,10,34.4),(x%12==0) and C.pink or C.blue) end
-- VIP lounge furniture
for _,x in ipairs({-50,-42,-34}) do p("VIPSeat"..x,Vector3.new(7,2.5,4),CFrame.new(x,26,28),C.metal,Enum.Material.Fabric) end
-- rooftop deck furniture and path lights
for _,x in ipairs({-48,-24,24,48}) do p("RoofLounge"..x,Vector3.new(9,2.5,5),CFrame.new(x,45.8,-26),C.metal,Enum.Material.Fabric);neon("RoofPathLight"..x,Vector3.new(3,.18,.18),CFrame.new(x,45.9,-18),C.warm) end
print("[BBYA] shell + dressing complete")