local W=game:GetService("Workspace")
local root=W:WaitForChild("BBYA_ZERO_BUILD")
local old=root:FindFirstChild("FinalPolish")
if old then old:Destroy() end
local m=Instance.new("Model",root)
m.Name="FinalPolish"

local C={pink=Color3.fromRGB(255,42,157),warm=Color3.fromRGB(255,188,122)}
local function p(n,s,cf,c,mat,t,parent)
 local x=Instance.new("Part")
 x.Name=n
 x.Anchored=true
 x.CanCollide=false
 x.Size=s
 x.CFrame=cf
 x.Color=c
 x.Material=mat or Enum.Material.SmoothPlastic
 x.Transparency=t or 0
 x.Parent=parent or m
 return x
end
local function neon(n,s,cf,c,parent)
 local x=p(n,s,cf,c or C.pink,Enum.Material.Neon,0,parent)
 local l=Instance.new("PointLight",x)
 l.Color=x.Color
 l.Brightness=.55
 l.Range=8
 return x
end

-- IMPORTANT:
-- Floor 1 visual authority lives in 28-lighting-ambience.server.lua,
-- 42-main-club-realism.server.lua and 43-floor1-front-premium.server.lua.
-- This final-polish layer must NOT create Floor 1 geometry or override global Lighting,
-- otherwise old ribs/neon/lighting race with the premium venue pass.

-- Upper VIP edge lighting only.
for _,z in ipairs({-25,25}) do
 neon("VIPEdgeZ"..z,Vector3.new(74,.18,.18),CFrame.new(0,25.1,z),C.pink)
end

-- Rooftop soft guide lights only.
for _,x in ipairs({-45,-30,-15,0,15,30,45}) do
 neon("RoofGuide"..x,Vector3.new(5,.12,.18),CFrame.new(x,45.2,-38),C.warm)
end

-- Exterior subtle side accents without touching locked entrance/signage objects.
for _,x in ipairs({-52,52}) do
 neon("FacadeSideAccent"..x,Vector3.new(.2,12,.2),CFrame.new(x,13,-43.9),C.pink)
end

print("[BBYA] final polish limited to upper/roof/exterior; Floor 1 legacy overlays disabled")
