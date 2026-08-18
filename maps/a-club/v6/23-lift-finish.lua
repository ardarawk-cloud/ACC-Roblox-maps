-- BBYA V6 — B3 LIFT FINISH
-- Physical cab interior + restrained landing finish. Names start with B3 LIFT CAB so runtime moves them with the cab.

-- Cab ceiling closes the elevator volume.
part(B3,"B3 LIFT CAB CEILING",Vector3.new(12,.55,11),CFrame.new(59,9.7,124.8),P.graphite,Enum.Material.Metal,0,true,nil)
-- Interior rear feature panel and warm-neutral avatar light.
part(B3,"B3 LIFT CAB REAR PANEL",Vector3.new(8,5,.18),CFrame.new(59,5.4,129.72),P.black,Enum.Material.SmoothPlastic,0,false,nil)
neon(B3,"B3 LIFT CAB CEILING ACCENT",Vector3.new(7,.12,.12),CFrame.new(59,9.35,124.8),P.cyan,nil)
local cabLight=light(B3,"B3 LIFT CAB LIGHT",Vector3.new(59,8.8,124.8),P.white,1.15,11,nil)
cabLight.Parent:SetAttribute("BBYACriticalFill",true)

-- Small cab directory; not a giant wall label.
sign(B3,"B3 LIFT CAB DIRECTORY","G   •   VIP   •   ROOF",CFrame.new(59,6.6,129.58),Vector3.new(7.5,1.1,.18),P.white,Enum.NormalId.Front,nil)

-- Landing frames make the three exits visibly architectural.
for _,lv in ipairs({
    {code="G",y=0,color=P.cyan},
    {code="VIP",y=20,color=P.gold},
    {code="ROOF",y=40,color=P.warm},
}) do
    part(B3,"B3 "..lv.code.." LANDING HEADER",Vector3.new(14,.45,1.6),CFrame.new(59,lv.y+10.1,118.8),P.graphite,Enum.Material.Metal,0,true,nil)
    neon(B3,"B3 "..lv.code.." LANDING ACCENT",Vector3.new(8,.12,.12),CFrame.new(59,lv.y+9.75,117.95),lv.color,nil)
    sign(B3,"B3 "..lv.code.." LEVEL PLAQUE",lv.code,CFrame.new(66.6,lv.y+8.1,118.6),Vector3.new(1.8,1.4,.2),lv.color,Enum.NormalId.Front,nil)
end

workspace:SetAttribute("BBYAV6LiftFinish","COMPLETE")