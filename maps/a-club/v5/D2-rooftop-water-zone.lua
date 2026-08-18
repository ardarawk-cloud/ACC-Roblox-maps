-- [D2] ROOFTOP WATER / POOL FOOTPRINT — ARCHITECTURE ONLY
local D2=registerZone("D2","ROOFTOP WATER / POOL FOOTPRINT","ROOF",Vector3.new(0,36.72,-43),Vector3.new(76,.14,42))
program(D2,"D2 PROGRAM FOOTPRINT",Vector2.new(76,42),Vector3.new(0,36.72,-43),C.pool)
zoneStamp(D2,CFrame.new(0,42,-64),Vector3.new(28,3,.25),C.pool,Enum.NormalId.Front)
