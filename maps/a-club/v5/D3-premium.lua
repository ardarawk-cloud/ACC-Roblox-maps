-- [D3] PREMIUM SKY BAR
-- Warm resort bar; no club-neon grid.

finish(D3,"SKY BAR DECK",Vector3.new(38,.14,32),CFrame.new(-58,36.74,43),Color3.fromRGB(105,76,53),Enum.Material.WoodPlanks,0,false)
barCounter(D3,"SKY BAR COUNTER",Vector3.new(-72,38.2,43),Vector3.new(22,3.4,5),90)
finish(D3,"SKY BAR BACK WALL",Vector3.new(.4,8,24),CFrame.new(-78.2,41,43),P.charcoal,Enum.Material.Slate,0,false)
for _,y in ipairs({39.5,42,44.5}) do
 finish(D3,"SKY BAR SHELF "..y,Vector3.new(.55,.22,20),CFrame.new(-77.8,y,43),P.wood,Enum.Material.WoodPlanks,0,false)
 glow(D3,"SKY BAR SHELF LIGHT "..y,Vector3.new(.14,.14,19),CFrame.new(-77.45,y-.25,43),P.warm,.22,6)
end
for i,z in ipairs({34,39,44,49,54}) do stool(D3,"SKY BAR STOOL "..i,Vector3.new(-66,39.1,z),P.graphite) end
zoneSign(D3,"SKY BAR SIGN","BBYA SKY BAR",CFrame.new(-77.4,46,43)*CFrame.Angles(0,math.rad(90),0),Vector3.new(18,2.8,.2),P.warm,Enum.NormalId.Front)

-- Small standing/social ledge toward pool, preserving central roof spine at x=-8..8.
finish(D3,"POOL VIEW LEDGE",Vector3.new(17,1,2.6),CFrame.new(-45,38.1,29),P.wood,Enum.Material.WoodPlanks,0,true)
for _,x in ipairs({-50,-45,-40}) do stool(D3,"VIEW STOOL "..x,Vector3.new(x,39,33),P.graphite) end
