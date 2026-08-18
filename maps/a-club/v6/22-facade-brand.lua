-- BBYA V6 — PHYSICAL FACADE BRAND
-- Crown + wordmark are attached to one architectural brand wall. No floating crown/font placeholder.

local oldBrand=A2:FindFirstChild("A2 BBYA BRAND")
if oldBrand then oldBrand:Destroy() end
local oldWall=A2:FindFirstChild("A2 BRAND WALL")
if oldWall then oldWall:Destroy() end

-- Full-height brand backer starts above the open storefront/canopy and physically supports the crown.
part(A2,"A2 BRAND WALL",Vector3.new(108,13,2),CFrame.new(0,15.6,-1),P.black,Enum.Material.Slate,0,true,nil)
-- Wordmark attached to facade wall.
sign(A2,"A2 BBYA WORDMARK","BBYA\nSOCIAL HUB",CFrame.new(0,13.5,-2.08),Vector3.new(66,5.4,.35),P.pink,Enum.NormalId.Front,nil)

-- Crown centered above the wordmark: base + four sloped neon strokes + tips.
neon(A2,"A2 CROWN BASE",Vector3.new(20,.28,.28),CFrame.new(0,17.0,-2.18),P.pink,nil)
neon(A2,"A2 CROWN L1",Vector3.new(7,.28,.28),CFrame.new(-7.2,19.1,-2.18)*CFrame.Angles(0,0,math.rad(58)),P.pink,nil)
neon(A2,"A2 CROWN L2",Vector3.new(7,.28,.28),CFrame.new(-2.3,19.8,-2.18)*CFrame.Angles(0,0,math.rad(-62)),P.pink,nil)
neon(A2,"A2 CROWN R2",Vector3.new(7,.28,.28),CFrame.new(2.3,19.8,-2.18)*CFrame.Angles(0,0,math.rad(62)),P.pink,nil)
neon(A2,"A2 CROWN R1",Vector3.new(7,.28,.28),CFrame.new(7.2,19.1,-2.18)*CFrame.Angles(0,0,math.rad(-58)),P.pink,nil)
for _,x in ipairs({-9.8,0,9.8}) do
 local tip=neon(A2,"A2 CROWN TIP "..x,Vector3.new(.7,.7,.7),CFrame.new(x,21.3-(math.abs(x)>0 and 1.3 or 0),-2.18),P.pink,nil)
 tip.Shape=Enum.PartType.Ball
end
light(A2,"A2 BRAND GLOW",Vector3.new(0,16.5,0),P.pink,.75,18,nil)
workspace:SetAttribute("BBYAV6FacadeBrand","PHYSICAL_CROWN_ATTACHED")