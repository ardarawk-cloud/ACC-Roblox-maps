-- BBYA V6 — ROOFTOP LIFESTYLE FLOOR
-- Warm tropical resort language. Neon is restrained accent only.

-- Shared rooftop structural slab around programmed zones.
floor(D1,"D1 ARRIVAL DECK",Vector3.new(48,1,32),Vector3.new(46,40,132),P.stone2,Enum.Material.Slate,nil)
floor(D2,"D2 POOL DECK",Vector3.new(92,1,58),Vector3.new(0,40,92),Color3.fromRGB(82,75,69),Enum.Material.WoodPlanks,"13")
floor(D3,"D3 SKYBAR DECK",Vector3.new(28,1,58),Vector3.new(58,40,92),Color3.fromRGB(90,72,56),Enum.Material.WoodPlanks,"15")
floor(D4,"D4 CHILL DECK",Vector3.new(28,1,58),Vector3.new(-58,40,92),Color3.fromRGB(78,69,61),Enum.Material.WoodPlanks,nil)
floor(D5,"D5 CABANA DECK",Vector3.new(92,1,30),Vector3.new(0,40,133),Color3.fromRGB(76,68,60),Enum.Material.WoodPlanks,"16")
floor(D6,"D6 VIEW DECK",Vector3.new(92,1,20),Vector3.new(0,40,53),Color3.fromRGB(73,69,67),Enum.Material.Slate,"17")

-- Rooftop perimeter safety: glass rails keep city view open.
glass(D6,"D6 FRONT GLASS RAIL",Vector3.new(88,5,.45),CFrame.new(0,43,44),"17")
glass(D4,"D4 WEST GLASS RAIL",Vector3.new(.45,5,55),CFrame.new(-72,43,92),nil)
glass(D3,"D3 EAST GLASS RAIL",Vector3.new(.45,5,55),CFrame.new(72,43,92),"15")
glass(D5,"D5 REAR GLASS RAIL",Vector3.new(88,5,.45),CFrame.new(0,43,148),"16")

-- D1: lift/stair arrival pavilion. Real walls/roof around lift exit, open toward deck.
part(D1,"D1 ARRIVAL PAVILION ROOF",Vector3.new(38,.6,20),CFrame.new(48,50,132),P.charcoal,Enum.Material.WoodPlanks,0,true,nil)
for _,x in ipairs({31,65}) do
    part(D1,"D1 PAVILION POST "..x,Vector3.new(.7,10,.7),CFrame.new(x,45,123),P.wood,Enum.Material.Wood,0,true,nil)
    part(D1,"D1 PAVILION POST R "..x,Vector3.new(.7,10,.7),CFrame.new(x,45,141),P.wood,Enum.Material.Wood,0,true,nil)
end
-- clear lift exit landing from shaft front opening.
clearPad(D1,"D1 LIFT CLEAR EXIT",Vector3.new(59,40.62,112),Vector3.new(12,.12,10),nil)
part(D1,"D1 LIFT EXIT WALK",Vector3.new(16,.25,18),CFrame.new(59,40.65,118),P.stone2,Enum.Material.Marble,0,true,nil)
-- warm lamps, no giant rooftop text.
for _,p in ipairs({Vector3.new(36,48,128),Vector3.new(58,48,128),Vector3.new(36,48,140),Vector3.new(58,48,140)}) do light(D1,"D1 ARRIVAL WARM",p,P.warm,1.1,15,nil) end
sign(D1,"D1 SMALL WAYFIND","POOL  ←     SKY BAR  →",CFrame.new(47,47.5,121),Vector3.new(18,1.5,.25),P.white,Enum.NormalId.Front,nil)

-- D2 actual infinity pool basin, not a blue rectangle label.
part(D2,"D2 POOL BASIN",Vector3.new(68,3.2,38),CFrame.new(0,39.1,92),Color3.fromRGB(36,83,97),Enum.Material.Slate,0,true,"13")
local water=part(D2,"D2 POOL WATER",Vector3.new(66,.45,36),CFrame.new(0,40.1,92),P.water,Enum.Material.Glass,.28,false,"13")
water.CanQuery=false
-- infinity edge and submerged steps.
glass(D2,"D2 INFINITY FRONT",Vector3.new(66,3,.35),CFrame.new(0,41.2,74),"13")
for i=0,3 do part(D2,"D2 POOL STEP "..i,Vector3.new(12,.45,2.8),CFrame.new(-25,40.25-i*.42,105-i*2.1),Color3.fromRGB(178,171,161),Enum.Material.Slate,0,true,"13") end
-- pool loungers + parasol-like shade frames.
for _,x in ipairs({-36,-24,24,36}) do
    sofa(D2,"D2 POOL DAYBED "..x,Vector3.new(x,41.3,66),8,0,P.cream,"13")
end
for _,x in ipairs({-30,30}) do
    part(D2,"D2 SHADE POST "..x,Vector3.new(.5,7,.5),CFrame.new(x,44,67),P.wood,Enum.Material.Wood,0,true,"13")
    part(D2,"D2 SHADE TOP "..x,Vector3.new(14,.35,8),CFrame.new(x,47.5,67),P.charcoal,Enum.Material.Fabric,0,true,"13")
end

-- D2/14 Pool DJ is a real small island/deck.
part(D2,"D2 POOL DJ ISLAND",Vector3.new(22,1.2,12),CFrame.new(0,41.1,119),P.stone2,Enum.Material.Slate,0,true,"14")
part(D2,"D2 POOL DJ DESK",Vector3.new(14,3,4),CFrame.new(0,43,119),P.graphite,Enum.Material.Metal,0,true,"14")
part(D2,"D2 POOL DJ PERGOLA",Vector3.new(22,.4,12),CFrame.new(0,49,119),P.wood,Enum.Material.WoodPlanks,0,true,"14")
for _,x in ipairs({-10,10}) do for _,z in ipairs({114,124}) do part(D2,"D2 DJ POST",Vector3.new(.55,8,.55),CFrame.new(x,45,z),P.wood,Enum.Material.Wood,0,true,"14") end end
for _,p in ipairs({Vector3.new(-8,47,117),Vector3.new(8,47,117)}) do light(D2,"D2 DJ WARM",p,P.warm,.9,12,"14") end

-- D3 real Sky Bar room/open pavilion.
part(D3,"D3 BAR PAVILION ROOF",Vector3.new(24,.6,46),CFrame.new(59,50,92),P.charcoal,Enum.Material.WoodPlanks,0,true,"15")
for _,z in ipairs({70,92,114}) do
    part(D3,"D3 BAR POST "..z,Vector3.new(.6,9,.6),CFrame.new(48,45,z),P.wood,Enum.Material.Wood,0,true,"15")
    part(D3,"D3 BAR POST E "..z,Vector3.new(.6,9,.6),CFrame.new(70,45,z),P.wood,Enum.Material.Wood,0,true,"15")
end
bar(D3,"D3 SKY BAR COUNTER",Vector3.new(64,42.2,91),Vector3.new(14,3.4,6),90,"15")
for _,z in ipairs({76,84,92,100,108}) do
    part(D3,"D3 BAR STOOL "..z,Vector3.new(2.2,.6,2.2),CFrame.new(56,41.6,z),P.cream,Enum.Material.Fabric,0,true,"15")
end
for _,z in ipairs({74,90,106}) do light(D3,"D3 BAR WARM "..z,Vector3.new(60,48,z),P.warm,1.05,15,"15") end
sign(D3,"D3 SKYBAR PLAQUE","SKY BAR",CFrame.new(49,47,91),Vector3.new(.3,1.5,8),P.gold,Enum.NormalId.Left,"15")

-- D4 rooftop chill: proper social pockets, no giant 'SUNSET SOCIAL DECK' letters.
for _,z in ipairs({74,91,108}) do
    sofa(D4,"D4 CHILL SOFA A "..z,Vector3.new(-66,41.3,z),10,90,P.cream,nil)
    sofa(D4,"D4 CHILL SOFA B "..z,Vector3.new(-51,41.3,z),10,-90,P.graphite,nil)
    tableLow(D4,"D4 CHILL TABLE "..z,Vector3.new(-58.5,41.1,z),Vector3.new(5,.6,4),P.black,nil)
end
for _,z in ipairs({72,88,104,120}) do light(D4,"D4 CHILL WARM "..z,Vector3.new(-59,47,z),P.warm,.85,13,nil) end
palm(D4,"D4 PALM NORTH",Vector3.new(-64,41.5,118),8,nil)
palm(D4,"D4 PALM SOUTH",Vector3.new(-52,41.5,69),8,nil)

-- D5 real cabanas.
local cabanaXs={-33,-11,11,33}
for _,x in ipairs(cabanaXs) do
    local cx=x
    -- four-post cabana + roof + daybed
    for _,dx in ipairs({-5,5}) do for _,dz in ipairs({-5,5}) do
        part(D5,"D5 CABANA POST "..cx,Vector3.new(.55,7,.55),CFrame.new(cx+dx,44,133+dz),P.wood,Enum.Material.Wood,0,true,"16")
    end end
    part(D5,"D5 CABANA ROOF "..cx,Vector3.new(11,.45,11),CFrame.new(cx,47.5,133),P.charcoal,Enum.Material.WoodPlanks,0,true,"16")
    sofa(D5,"D5 CABANA DAYBED "..cx,Vector3.new(cx,41.3,134),8,0,P.cream,"16")
    light(D5,"D5 CABANA WARM "..cx,Vector3.new(cx,46.5,133),P.warm,.75,10,"16")
end

-- D6 actual photo/view deck with frames and unobstructed city sightline.
part(D6,"D6 VIEW PLATFORM",Vector3.new(80,.5,12),CFrame.new(0,40.8,53),P.stone2,Enum.Material.Marble,0,true,"17")
-- two photo frames, not text walls.
for _,x in ipairs({-24,24}) do
    part(D6,"D6 PHOTO FRAME L "..x,Vector3.new(.5,8,.5),CFrame.new(x-5,45,48),P.wood,Enum.Material.Wood,0,true,"17")
    part(D6,"D6 PHOTO FRAME R "..x,Vector3.new(.5,8,.5),CFrame.new(x+5,45,48),P.wood,Enum.Material.Wood,0,true,"17")
    part(D6,"D6 PHOTO FRAME TOP "..x,Vector3.new(10,.5,.5),CFrame.new(x,49,48),P.wood,Enum.Material.Wood,0,true,"17")
    light(D6,"D6 PHOTO KEY "..x,Vector3.new(x,48,56),P.warm,1.15,13,"17")
end
sign(D6,"D6 VIEW PLAQUE","CITY VIEW",CFrame.new(0,43.5,44.4),Vector3.new(10,1.3,.25),P.white,Enum.NormalId.Back,"17")

-- Restrained rooftop branding only.
neon(D1,"D1 BRAND ACCENT",Vector3.new(22,.14,.14),CFrame.new(47,49.6,121),P.pink,nil)

workspace:SetAttribute("BBYAV6Rooftop","COMPLETE")
