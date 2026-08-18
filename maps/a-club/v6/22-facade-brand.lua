-- BBYA V6 — PHYSICAL FACADE BRAND
-- Replace font crown with physical neon crown geometry. Only the BBYA wordmark remains textual.

local oldBrand=A2:FindFirstChild("A2 BBYA BRAND")
if oldBrand then oldBrand:Destroy() end

-- Wordmark attached to facade wall.
sign(A2,"A2 BBYA WORDMARK","BBYA\nSOCIAL HUB",CFrame.new(0,12.8,-2.1),Vector3.new(66,5.4,.4),P.pink,Enum.NormalId.Front,nil)

-- Crown centered above the wordmark: base + four sloped neon strokes + tips.
neon(A2,"A2 CROWN BASE",Vector3.new(20,.28,.28),CFrame.new(0,16.1,-2.45),P.pink,nil)
neon(A2,"A2 CROWN L1",Vector3.new(7,.28,.28),CFrame.new(-7.2,18.2,-2.45)*CFrame.Angles(0,0,math.rad(58)),P.pink,nil)
neon(A2,"A2 CROWN L2",Vector3.new(7,.28,.28),CFrame.new(-2.3,18.9,-2.45)*CFrame.Angles(0,0,math.rad(-62)),P.pink,nil)
neon(A2,"A2 CROWN R2",Vector3.new(7,.28,.28),CFrame.new(2.3,18.9,-2.45)*CFrame.Angles(0,0,math.rad(62)),P.pink,nil)
neon(A2,"A2 CROWN R1",Vector3.new(7,.28,.28),CFrame.new(7.2,18.2,-2.45)*CFrame.Angles(0,0,math.rad(-58)),P.pink,nil)
for _,x in ipairs({-9.8,0,9.8}) do
 local tip=neon(A2,"A2 CROWN TIP "..x,Vector3.new(.7,.7,.7),CFrame.new(x,20.4-(math.abs(x)>0 and 1.3 or 0),-2.45),P.pink,nil)
 tip.Shape=Enum.PartType.Ball
end
light(A2,"A2 BRAND GLOW",Vector3.new(0,15.5,0),P.pink,.75,18,nil)
workspace:SetAttribute("BBYAV6FacadeBrand","PHYSICAL_CROWN")
