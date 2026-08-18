-- [D5] PREMIUM CABANAS
-- Each cabana stays inside its 30x24 program rectangle and outside D1 central spine.

finish(D5,"WEST CABANA DECK",Vector3.new(28,.14,22),CFrame.new(-62,36.74,-40),Color3.fromRGB(105,76,53),Enum.Material.WoodPlanks,0,false)
finish(D5,"EAST CABANA DECK",Vector3.new(28,.14,22),CFrame.new(62,36.74,-40),Color3.fromRGB(105,76,53),Enum.Material.WoodPlanks,0,false)

cabana(D5,"WEST CABANA A",Vector3.new(-69,36.8,-40),0)
cabana(D5,"WEST CABANA B",Vector3.new(-55,36.8,-40),0)
cabana(D5,"EAST CABANA A",Vector3.new(55,36.8,-40),0)
cabana(D5,"EAST CABANA B",Vector3.new(69,36.8,-40),0)

-- Tropical accents remain at outside edges of the program blocks.
palm(D5,"WEST CABANA PALM",Vector3.new(-77,37.6,-31),9)
palm(D5,"EAST CABANA PALM",Vector3.new(77,37.6,-31),9)

for _,x in ipairs({-74,-50,50,74}) do
 bollard(D5,"CABANA LAMP "..x,Vector3.new(x,38.2,-52),P.warm)
end
zoneSign(D5,"WEST CABANA SIGN","CABANAS",CFrame.new(-62,44.5,-52),Vector3.new(15,2.2,.2),P.warm,Enum.NormalId.Front)
zoneSign(D5,"EAST CABANA SIGN","CABANAS",CFrame.new(62,44.5,-52),Vector3.new(15,2.2,.2),P.warm,Enum.NormalId.Front)
