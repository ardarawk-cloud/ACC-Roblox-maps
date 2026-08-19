-- BBYA SOCIAL HUB — PHASE 2 PREMIUM INTERIOR / SOCIAL DETAIL
-- Adds premium hospitality detail while preserving the clean circulation lanes.

-- =========================================================
-- SOCIAL ATRIUM / WELCOME
-- =========================================================
part(A2,"WELCOME BAR BODY",Vector3.new(30,4,6),CFrame.new(24,2.2,67),C.graphite,Enum.Material.Slate,0,true)
part(A2,"WELCOME BAR TOP",Vector3.new(31,.45,6.7),CFrame.new(24,4.45,67),C.wood,Enum.Material.WoodPlanks,0,true)
neon(A2,"WELCOME BAR PINK",Vector3.new(28,.14,.14),CFrame.new(24,2.3,63.6),C.pink)
sign(A2,"WELCOME BAR SIGN","WELCOME",CFrame.new(24,9.5,77.3),Vector3.new(20,2.8,.3),C.warm,Enum.NormalId.Front)

-- Photo/selfie wall facing the atrium, away from the center walk.
part(A2,"SELFIE WALL",Vector3.new(24,12,1),CFrame.new(-1,6,70),C.black,Enum.Material.SmoothPlastic,0,true)
neon(A2,"SELFIE FRAME TOP",Vector3.new(19,.18,.18),CFrame.new(-1,11.2,69.4),C.pink)
neon(A2,"SELFIE FRAME L",Vector3.new(.18,9,.18),CFrame.new(-10.5,6.7,69.4),C.cyan)
neon(A2,"SELFIE FRAME R",Vector3.new(.18,9,.18),CFrame.new(8.5,6.7,69.4),C.pink)
sign(A2,"SELFIE WORDMARK","BBYA\nSOCIAL HUB",CFrame.new(-1,6.3,69.3),Vector3.new(16,7,.25),C.pink,Enum.NormalId.Front)
part(A2,"SELFIE PLATFORM",Vector3.new(18,.5,9),CFrame.new(-1,.5,64),C.graphite,Enum.Material.Marble,0,true)

-- =========================================================
-- MAIN CLUB SHOW ENVIRONMENT
-- =========================================================
for _,x in ipairs({-56,-42,-28,-14,0}) do
    part(A3,"CLUB TRUSS X "..x,Vector3.new(1,1,54),CFrame.new(x,18,37),C.graphite,Enum.Material.Metal,0,false)
end
for _,z in ipairs({16,37,58}) do
    part(A3,"CLUB TRUSS Z "..z,Vector3.new(70,1,1),CFrame.new(-28,18,z),C.graphite,Enum.Material.Metal,0,false)
end

for i,cfg in ipairs({
    {-56,17,18,C.pink},{-42,17,18,C.cyan},{-28,17,18,C.pink},{-14,17,18,C.cyan},{0,17,18,C.pink},
    {-56,17,55,C.cyan},{-42,17,55,C.pink},{-28,17,55,C.cyan},{-14,17,55,C.pink},{0,17,55,C.cyan},
}) do
    part(A3,"SHOW HEAD "..i,Vector3.new(2.2,1.4,2.2),CFrame.new(cfg[1],cfg[2],cfg[3]),C.black,Enum.Material.Metal,0,false)
    local lens=neon(A3,"SHOW LENS "..i,Vector3.new(1.3,.25,1.3),CFrame.new(cfg[1],cfg[2]-.75,cfg[3]),cfg[4])
    lens:SetAttribute("BBYAShowLight",true)
end

for _,z in ipairs({18,34,50,66}) do
    part(A3,"CLUB WALL PANEL WEST "..z,Vector3.new(1,10,11),CFrame.new(-85.3,7,z),z%32==2 and C.graphite or C.charcoal,Enum.Material.Slate,0,true)
    neon(A3,"CLUB WALL STRIP WEST "..z,Vector3.new(.15,7,.15),CFrame.new(-84.7,7,z-4.5),z%32==2 and C.cyan or C.pink)
end

neon(A3,"DJ BOOTH FRONT",Vector3.new(20,.25,.25),CFrame.new(-28,5.6,69.4),C.pink)
sign(A3,"DJ BOOTH BRAND","BBYA",CFrame.new(-28,6.6,69.35),Vector3.new(14,2.3,.25),C.pink,Enum.NormalId.Front)

-- =========================================================
-- MEZZANINE SOCIAL BALCONIES
-- =========================================================
for _,cfg in ipairs({
    {y=17,z=18},{y=17,z=50},{y=31,z=28},{y=31,z=58},
}) do
    part(A4,"MEZZ PRIVACY PANEL "..cfg.y.." "..cfg.z,Vector3.new(1,7,10),CFrame.new(-93.5,cfg.y+3,cfg.z),C.charcoal,Enum.Material.Slate,0,true)
    neon(A4,"MEZZ WARM STRIP "..cfg.y.." "..cfg.z,Vector3.new(.15,5,.15),CFrame.new(-92.9,cfg.y+3,cfg.z),C.warm)
end

-- =========================================================
-- VIP HOSPITALITY / QUEEN INTEGRATION
-- =========================================================
part(A5,"VIP BACKBAR",Vector3.new(34,10,1.2),CFrame.new(68,7,76),C.black,Enum.Material.Slate,0,true)
for _,y in ipairs({4,7,10}) do
    part(A5,"VIP BACKBAR SHELF "..y,Vector3.new(30,.35,2),CFrame.new(68,y,74.8),C.wood,Enum.Material.WoodPlanks,0,false)
end
for _,x in ipairs({48,60,76,92}) do
    part(A5,"VIP WALL PANEL "..x,Vector3.new(12,10,.8),CFrame.new(x,8,76.7),C.graphite,Enum.Material.Fabric,0,true)
    neon(A5,"VIP WALL LINE "..x,Vector3.new(8,.12,.12),CFrame.new(x,12.7,76.2),x<70 and C.pink or C.gold)
end

-- Decorative inlay and side seating belong to the elevated Queen deck created in furnishing.
part(A5,"VIP QUEEN NICHE FLOOR",Vector3.new(26,.2,16),CFrame.new(48,19.75,61),Color3.fromRGB(42,32,48),Enum.Material.Marble,0,false)
seat(A5,"VIP QUEEN SOFA",CFrame.new(38,20.3,60)*CFrame.Angles(0,math.rad(90),0),9,C.cream)
tableLow(A5,"VIP QUEEN TABLE",CFrame.new(42,20.05,56),Vector3.new(5,.5,4))
neon(A5,"VIP QUEEN NICHE EDGE",Vector3.new(24,.16,.16),CFrame.new(48,20,52.9),C.pink)

-- =========================================================
-- ROOFTOP LIFESTYLE / SKY BAR
-- =========================================================
part(A6,"SKY BAR BODY",Vector3.new(24,4,7),CFrame.new(86,34.2,51),C.graphite,Enum.Material.Slate,0,true)
part(A6,"SKY BAR TOP",Vector3.new(25,.4,7.7),CFrame.new(86,36.4,51),C.wood,Enum.Material.WoodPlanks,0,true)
neon(A6,"SKY BAR WARM",Vector3.new(22,.14,.14),CFrame.new(86,34.4,47.2),C.warm)
sign(A6,"SKY BAR SIGN","SKY BAR",CFrame.new(98.4,39,51),Vector3.new(.3,2.5,13),C.gold,Enum.NormalId.Right)

for _,x in ipairs({16,80}) do
    part(A6,"POOL DAYBED PLATFORM "..x,Vector3.new(18,.55,14),CFrame.new(x,32.1,42),C.charcoal,Enum.Material.WoodPlanks,0,true)
    seat(A6,"POOL SOCIAL DAYBED "..x,CFrame.new(x,33,42),12,C.cream)
end

for _,x in ipairs({18,78}) do
    part(A6,"ROOF PHOTO FRAME L "..x,Vector3.new(.55,8,.55),CFrame.new(x-6,37,6),C.wood,Enum.Material.Wood,0,true)
    part(A6,"ROOF PHOTO FRAME R "..x,Vector3.new(.55,8,.55),CFrame.new(x+6,37,6),C.wood,Enum.Material.Wood,0,true)
    part(A6,"ROOF PHOTO FRAME TOP "..x,Vector3.new(12,.55,.55),CFrame.new(x,41,6),C.wood,Enum.Material.Wood,0,true)
end

workspace:SetAttribute("BBYAPremiumInterior","REFERENCE_CONNECTED_PASS_3")
workspace:SetAttribute("BBYASocialDensity","PREMIUM_HANGOUT_PASS_2")
