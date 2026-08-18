-- BBYA V6 — SPAWN + ARCHITECTURAL CIRCULATION
-- Small wayfinding only. Geometry and sightlines do the navigation work.

-- Real spawn at A1, facing the storefront/social commons.
local spawn=Instance.new("SpawnLocation")
spawn.Name="A1 BBYA SPAWN"
spawn.Size=Vector3.new(12,.5,8)
spawn.CFrame=CFrame.new(0,1,-33)*CFrame.Angles(0,math.rad(180),0)
spawn.Anchored=true
spawn.CanCollide=true
spawn.Neutral=true
spawn.Transparency=.82
spawn.Material=Enum.Material.SmoothPlastic
spawn.Color=Color3.fromRGB(84,196,132)
spawn.Parent=A1
tag(spawn,A1,"01")

-- Arrival threshold lighting frames the building rather than filling the plaza with signs.
for _,x in ipairs({-32,32}) do
    part(A2,"A2 ENTRY POST "..x,Vector3.new(.7,8,.7),CFrame.new(x,4.5,12.6),P.charcoal,Enum.Material.Metal,0,true,nil)
    neon(A2,"A2 ENTRY ACCENT "..x,Vector3.new(.18,6,.18),CFrame.new(x,4.8,12.2),x<0 and P.pink or P.cyan,nil)
end

-- Small threshold markers at the rear of Social Commons.
twoFaceSign(A3,"A3 WEST ROUTE SIGN","CHILL / TALK","SOCIAL COMMONS",CFrame.new(-51,10,63),Vector3.new(11,1.4,.25),P.cyan,nil)
twoFaceSign(A3,"A3 CLUB ROUTE SIGN","CLUB / DANCE","SOCIAL COMMONS",CFrame.new(0,10,63),Vector3.new(11,1.4,.25),P.pink,nil)
twoFaceSign(A3,"A3 EAST ROUTE SIGN","SOCIAL BAR","SOCIAL COMMONS",CFrame.new(55,10,63),Vector3.new(11,1.4,.25),P.gold,nil)

-- Keep the primary circulation spine visible and furniture-free.
for _,z in ipairs({20,34,48,60}) do
    clearPad(A3,"A3 MAIN FLOW "..z,Vector3.new(0,.67,z),Vector3.new(14,.08,8),nil)
end

-- Stair entry cues are architectural light strips, not giant copy.
for _,cfg in ipairs({
    {zone=B1,x=-56,z=123,color=P.cyan,name="WEST"},
    {zone=B2,x=33,z=123,color=P.pink,name="EAST"},
}) do
    neon(cfg.zone,"B STAIR THRESHOLD "..cfg.name,Vector3.new(10,.12,.18),CFrame.new(cfg.x,.9,cfg.z),cfg.color,nil)
end

-- Lift landings on all levels remain physically clear.
clearPad(B3,"B3 VIP CLEAR LANDING",Vector3.new(59,20.82,112),Vector3.new(12,.12,10),nil)
clearPad(B3,"B3 ROOF CLEAR LANDING",Vector3.new(59,40.82,112),Vector3.new(12,.12,10),nil)

workspace:SetAttribute("BBYAV6Circulation","LOCKED_CLEAR")
workspace:SetAttribute("BBYAV6SpawnReady",true)