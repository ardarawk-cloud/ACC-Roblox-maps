-- BBYA V6 — S1 SERVICE / STAFF / TECHNICAL BASEMENT
-- Functional back-of-house volume so the venue is architecturally complete.

floor(S1,"S1 BASEMENT FLOOR",Vector3.new(110,1,80),Vector3.new(0,-12,102),Color3.fromRGB(70,70,73),Enum.Material.Concrete,nil)
part(S1,"S1 BASEMENT CEILING",Vector3.new(110,1,80),CFrame.new(0,-3,102),P.charcoal,Enum.Material.Concrete,0,true,nil)
wallZ(S1,"S1 WEST WALL",-55,62,142,-7.5,9,2,P.charcoal,nil)
wallZ(S1,"S1 EAST WALL",55,62,142,-7.5,9,2,P.charcoal,nil)
wallX(S1,"S1 FRONT WALL",62,-55,55,-7.5,9,2,P.charcoal,nil)
wallX(S1,"S1 REAR WALL",142,-55,55,-7.5,9,2,P.charcoal,nil)
-- Internal staff corridor and rooms.
wallZ(S1,"S1 STAFF CORRIDOR WEST",-12,68,136,-7.5,9,1.2,P.graphite,nil)
wallZ(S1,"S1 STAFF CORRIDOR EAST",12,68,136,-7.5,9,1.2,P.graphite,nil)
doorwayWallX(S1,"S1 TECH ROOM FRONT",96,-55,-12,-32,8,-7.5,9,1.2,P.graphite,nil)
doorwayWallX(S1,"S1 STORAGE FRONT",96,12,55,32,8,-7.5,9,1.2,P.graphite,nil)
wallX(S1,"S1 STAFF ROOM DIVIDER",118,-55,-12,-7.5,9,1.2,P.graphite,nil)
wallX(S1,"S1 DELIVERY DIVIDER",118,12,55,-7.5,9,1.2,P.graphite,nil)
-- Tech racks and storage blocks.
for _,x in ipairs({-47,-39,-31,-23}) do part(S1,"S1 TECH RACK "..x,Vector3.new(4,6,2),CFrame.new(x,-8.5,108),P.black,Enum.Material.Metal,0,true,nil) end
for _,x in ipairs({22,30,38,46}) do for _,z in ipairs({106,114,126,134}) do part(S1,"S1 STORAGE "..x.." "..z,Vector3.new(5,4,5),CFrame.new(x,-9.5,z),Color3.fromRGB(100,78,55),Enum.Material.WoodPlanks,0,true,nil) end end
for _,z in ipairs({74,90,106,122,136}) do light(S1,"S1 WORK LIGHT "..z,Vector3.new(0,-4.5,z),P.white,.7,12,nil) end
sign(S1,"S1 STAFF PLAQUE","STAFF / SERVICE",CFrame.new(0,-6.5,62.9),Vector3.new(13,1.3,.25),P.white,Enum.NormalId.Back,nil)
workspace:SetAttribute("BBYAV6Service","COMPLETE")
