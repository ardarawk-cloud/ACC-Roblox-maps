local W=game:GetService("Workspace")
local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder",W);root.Name="BBYA_ZERO_BUILD"
local old=root:FindFirstChild("ShellAndDressing");if old then old:Destroy() end
local m=Instance.new("Model",root);m.Name="ShellAndDressing"
local C={dark=Color3.fromRGB(10,9,13),wall=Color3.fromRGB(28,23,31),floor=Color3.fromRGB(61,49,56),pink=Color3.fromRGB(255,42,157),blue=Color3.fromRGB(0,174,255),warm=Color3.fromRGB(255,188,122),metal=Color3.fromRGB(44,39,49),glass=Color3.fromRGB(60,38,67)}
local function p(n,s,cf,c,mat,t)local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Color=c;x.Material=mat or Enum.Material.SmoothPlastic;x.Transparency=t or 0;x.Parent=m;return x end
local function neon(n,s,cf,c)local x=p(n,s,cf,c or C.pink,Enum.Material.Neon);x.CanCollide=false;local l=Instance.new("PointLight",x);l.Color=x.Color;l.Brightness=1.15;l.Range=12;return x end

-- STRUCTURAL SHELL ONLY.
-- Floor 1 furniture / DJ backdrop / reception / salon / bar dressing are now authoritative in:
-- 42-main-club-realism.server.lua and 43-floor1-front-premium.server.lua.
-- Do NOT reintroduce legacy Floor 1 props here; they caused duplicate furniture and the false DJ wall at Z=35.

-- Irregular L1 shell: stepped wings, wide central club mass, narrower rear stage mass.
p("L1WestFrontWall",Vector3.new(2,24,34),CFrame.new(-48,12,-28),C.dark)
p("L1EastFrontWall",Vector3.new(2,24,28),CFrame.new(44,12,-31),C.dark)
p("L1WestClubWall",Vector3.new(2,24,54),CFrame.new(-59,12,7),C.dark)
p("L1EastClubWall",Vector3.new(2,24,48),CFrame.new(59,12,10),C.dark)
p("L1RearLeft",Vector3.new(28,24,2),CFrame.new(-42,12,42),C.dark)

-- Rear-center shell is now a structural frame, not a solid wall.
-- The opening exactly matches the recessed DJ Wall mount (58 x 13.25, centered at X=3/Y=10),
-- so the live wall at Z~47 is visible from the club while remaining architecturally recessed.
p("L1RearCenterLeft",Vector3.new(6,24,2),CFrame.new(-29,12,44),C.dark)
p("L1RearCenterTop",Vector3.new(58,7.375,2),CFrame.new(3,20.3125,44),C.dark)
p("L1RearCenterBottom",Vector3.new(58,3.375,2),CFrame.new(3,1.6875,44),C.dark)

p("L1RearRight",Vector3.new(28,24,2),CFrame.new(42,12,40),C.dark)

-- Structural columns around club, never through center dance area.
for _,x in ipairs({-34,34}) do
 for _,z in ipairs({-18,18}) do
  p("ClubColumn"..x.."_"..z,Vector3.new(2.4,24,2.4),CFrame.new(x,12,z),C.metal,Enum.Material.Metal)
 end
end

-- Upper perimeter fascia emphasizing vertical mass.
p("L2WestFascia",Vector3.new(2,20,72),CFrame.new(-59,34,4),C.wall,Enum.Material.Metal)
p("L2EastFascia",Vector3.new(2,20,72),CFrame.new(59,34,4),C.wall,Enum.Material.Metal)
p("L2RearFascia",Vector3.new(120,20,2),CFrame.new(0,34,44),C.wall,Enum.Material.Metal)

-- Upper-level / rooftop dressing remains here; Floor 1 dressing is intentionally absent.
for _,x in ipairs({-50,-42,-34}) do
 p("VIPSeat"..x,Vector3.new(7,2.5,4),CFrame.new(x,26,28),C.metal,Enum.Material.Fabric)
end
for _,x in ipairs({-48,-24,24,48}) do
 p("RoofLounge"..x,Vector3.new(9,2.5,5),CFrame.new(x,45.8,-26),C.metal,Enum.Material.Fabric)
 neon("RoofPathLight"..x,Vector3.new(3,.18,.18),CFrame.new(x,45.9,-18),C.warm)
end

print("[BBYA] structural shell loaded; rear-center DJ wall opening enabled")
