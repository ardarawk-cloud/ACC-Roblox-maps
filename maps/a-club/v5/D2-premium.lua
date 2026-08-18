-- [D2] PREMIUM INFINITY POOL
-- Water footprint is deliberately smaller than the 76x42 program zone to preserve 12-stud deck bands.

local poolCenter=Vector3.new(0,37.05,-43)
finish(D2,"POOL BASIN",Vector3.new(54,.55,20),CFrame.new(poolCenter-Vector3.new(0,.45,0)),Color3.fromRGB(20,75,92),Enum.Material.SmoothPlastic,0,true)
local water=finish(D2,"POOL WATER",Vector3.new(52,.32,18),CFrame.new(poolCenter),P.water,Enum.Material.Glass,.22,false)
water.Reflectance=.08

-- Warm stone coping; rear edge is kept visually low for infinity effect.
finish(D2,"POOL WEST COPING",Vector3.new(2,.35,24),CFrame.new(-28,37.2,-43),P.cream,Enum.Material.Marble,0,true)
finish(D2,"POOL EAST COPING",Vector3.new(2,.35,24),CFrame.new(28,37.2,-43),P.cream,Enum.Material.Marble,0,true)
finish(D2,"POOL FRONT COPING",Vector3.new(58,.35,2),CFrame.new(0,37.2,-31),P.cream,Enum.Material.Marble,0,true)
finish(D2,"POOL INFINITY LIP",Vector3.new(58,.2,.65),CFrame.new(0,37.05,-55),Color3.fromRGB(55,110,125),Enum.Material.Glass,.35,true)

glow(D2,"UNDERWATER WEST",Vector3.new(.25,.2,14),CFrame.new(-22,36.72,-43),Color3.fromRGB(75,220,235),.28,9)
glow(D2,"UNDERWATER EAST",Vector3.new(.25,.2,14),CFrame.new(22,36.72,-43),Color3.fromRGB(75,220,235),.28,9)

-- Pool DJ deck sits behind water but remains inside D2 and out of the main D1 spine.
finish(D2,"POOL DJ DECK",Vector3.new(18,.6,6),CFrame.new(0,37,-60),P.wood,Enum.Material.WoodPlanks,0,true)
finish(D2,"POOL DJ CONSOLE",Vector3.new(12,2.6,3.5),CFrame.new(0,38.6,-60),P.charcoal,Enum.Material.Metal,0,true)
glow(D2,"POOL DJ UNDERLIGHT",Vector3.new(10,.2,.18),CFrame.new(0,38.2,-58.15),P.cyan,.2,7)
zoneSign(D2,"POOL DJ LABEL","POOL DJ",CFrame.new(0,41,-58),Vector3.new(12,2,.2),P.warm,Enum.NormalId.Front)
zoneSign(D2,"POOL IDENTITY","INFINITY POOL",CFrame.new(0,40,-30),Vector3.new(18,2.4,.2),P.cyan,Enum.NormalId.Back)
