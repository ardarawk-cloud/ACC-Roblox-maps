-- [D1] LUXURY ROOFTOP ARRIVAL / CIRCULATION
-- Separate resort mood: stone, wood and warm indirect light. Main axes remain clear.

finish(D1,"ROOFTOP STONE FINISH",Vector3.new(176,.16,196),CFrame.new(0,36.58,20),Color3.fromRGB(75,72,70),Enum.Material.Slate,0,false)
finish(D1,"CENTRAL SPINE FINISH",Vector3.new(14,.12,172),CFrame.new(0,36.72,18),Color3.fromRGB(112,78,52),Enum.Material.WoodPlanks,0,false)
finish(D1,"ARRIVAL PLAZA FINISH",Vector3.new(40,.14,20),CFrame.new(0,36.76,96),Color3.fromRGB(93,88,82),Enum.Material.Marble,0,false)

for i,z in ipairs({-64,-44,-24,-4,16,36,56,76,102}) do
 bollard(D1,"SPINE WEST BOLLARD "..i,Vector3.new(-9,38.2,z),P.warm)
 bollard(D1,"SPINE EAST BOLLARD "..i,Vector3.new(9,38.2,z),P.warm)
end

palm(D1,"ROOF FRONT WEST PALM",Vector3.new(-80,37.6,92),11)
palm(D1,"ROOF FRONT EAST PALM",Vector3.new(80,37.6,92),11)
palm(D1,"ROOF MID WEST PALM",Vector3.new(-82,37.6,8),10)
palm(D1,"ROOF MID EAST PALM",Vector3.new(82,37.6,8),10)

glassRail(D1,"ROOF FRONT GLASS",Vector3.new(0,40.2,119),Vector3.new(170,3.6,.35))
glassRail(D1,"ROOF WEST GLASS",Vector3.new(-88.5,40.2,20),Vector3.new(.35,3.6,190))
glassRail(D1,"ROOF EAST GLASS",Vector3.new(88.5,40.2,20),Vector3.new(.35,3.6,190))

-- Fictional low-cost city skyline beyond the front view edge. Non-collidable and no PointLights.
for i=1,13 do
 local x=-168+(i-1)*28
 local h=42+((i*19)%65)
 local w=16+((i*7)%10)
 finish(D1,"CITY TOWER "..i,Vector3.new(w,h,18),CFrame.new(x,h/2,242+((i%3)*10)),Color3.fromRGB(18+(i%3)*6,20+(i%4)*5,30+(i%2)*8),Enum.Material.SmoothPlastic,0,false)
 for floor=1,4 do
  local wy=8+floor*(h/5)
  local col=(floor+i)%2==0 and P.cyan or P.pink
  local win=finish(D1,"CITY WINDOWS "..i.."-"..floor,Vector3.new(math.max(6,w-5),.35,.18),CFrame.new(x,wy,232+((i%3)*10)),col,Enum.Material.Neon,.1,false)
  win.CanQuery=false
 end
end
finish(D1,"CITY HORIZON",Vector3.new(400,.25,4),CFrame.new(0,4,265),Color3.fromRGB(40,52,65),Enum.Material.Neon,.35,false)

zoneSign(D1,"ROOFTOP ARRIVAL SIGN","BBYA ROOFTOP  •  POOL ↓  •  SKY BAR ←  •  CHILL →",CFrame.new(0,43.2,105),Vector3.new(46,3,.25),P.warm,Enum.NormalId.Front)
