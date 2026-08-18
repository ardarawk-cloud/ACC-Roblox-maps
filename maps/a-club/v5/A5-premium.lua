-- [A5] PREMIUM MAIN BAR
-- Counter runs along the west side; both lobby and club approaches remain clear.

finish(A5,"BAR FLOOR FINISH",Vector3.new(30,.16,46),CFrame.new(-72,.72,52),Color3.fromRGB(45,39,37),Enum.Material.WoodPlanks,0,false)
barCounter(A5,"MAIN BAR COUNTER",Vector3.new(-82,2.2,50),Vector3.new(18,3.4,5),90)
finish(A5,"BACK BAR WALL",Vector3.new(.45,9,28),CFrame.new(-87.3,6,51),P.black,Enum.Material.Slate,0,false)
for _,y in ipairs({3.4,5.5,7.6}) do
 finish(A5,"BAR SHELF "..y,Vector3.new(.8,.25,24),CFrame.new(-86.85,y,51),P.wood,Enum.Material.WoodPlanks,0,false)
 glow(A5,"BAR SHELF LIGHT "..y,Vector3.new(.15,.15,23),CFrame.new(-86.38,y-.28,51),P.warm,.26,6)
end
for i,z in ipairs({41,45,49,53,57,61}) do
 local bottle=finish(A5,"DISPLAY BOTTLE "..i,Vector3.new(.45,1.4,.65),CFrame.new(-86.2,4.2,z),i%2==0 and P.pink or P.gold,Enum.Material.Glass,.1,false)
 bottle.CanQuery=false
end
zoneSign(A5,"MAIN BAR BRAND","BBYA MAIN BAR",CFrame.new(-86.15,10,51)*CFrame.Angles(0,math.rad(90),0),Vector3.new(20,3,.2),P.gold,Enum.NormalId.Front)
for i,z in ipairs({38,45,52,59,66}) do stool(A5,"BAR STOOL "..i,Vector3.new(-76.5,3.1,z),P.graphite) end
sofa(A5,"BAR SOCIAL SOFA",Vector3.new(-65,1.4,36),11,90,P.graphite)
lowTable(A5,"BAR SOCIAL TABLE",Vector3.new(-71,1.3,36),Vector3.new(5,.7,4),P.black)
zoneSign(A5,"BAR WAYFINDING","LOBBY ↑  •  MAIN CLUB →",CFrame.new(-72,11,29.7),Vector3.new(20,2.4,.2),P.white,Enum.NormalId.Back)
