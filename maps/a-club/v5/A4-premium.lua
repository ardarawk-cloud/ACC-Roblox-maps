-- [A4] PREMIUM MAIN CLUB / DANCE HALL
-- High-energy neon core. Central dance/crowd area stays open and readable.

finish(A4,"DANCE FLOOR DARK FINISH",Vector3.new(104,.18,116),CFrame.new(0,.72,10),P.black,Enum.Material.SmoothPlastic,0,false)

-- Low-cost neon floor grid; decorative only.
for _,x in ipairs({-44,-32,-20,-8,8,20,32,44}) do
 local col=(x%24==0) and P.cyan or P.pink
 glow(A4,"DANCE GRID X "..x,Vector3.new(.16,.12,108),CFrame.new(x,.88,10),col,.16,5)
end
for _,z in ipairs({-42,-26,-10,6,22,38,54,70}) do
 local col=(z%32==6) and P.gold or ((z%32==-10) and P.violet or P.cyan)
 glow(A4,"DANCE GRID Z "..z,Vector3.new(96,.12,.16),CFrame.new(0,.89,z),col,.14,5)
end

-- Stage architecture and focal LED wall.
finish(A4,"STAGE BLACK SKIN",Vector3.new(76,.28,18),CFrame.new(0,3.04,-77),P.black,Enum.Material.Metal,0,false)
finish(A4,"MAIN LED WALL",Vector3.new(62,12,.7),CFrame.new(0,10.2,-86.15),P.black,Enum.Material.SmoothPlastic,0,false)
for i=1,7 do
 local x=-27+(i-1)*9
 local col=(i%2==0) and P.cyan or P.pink
 glow(A4,"LED WALL BAR "..i,Vector3.new(5.6,.55,.16),CFrame.new(x,9.8+(i%3)*2.1,-85.72),col,.42,10)
end
zoneSign(A4,"MAIN LED BRAND","BBYA  •  24/7 NIGHT SYSTEM",CFrame.new(0,13.6,-85.7),Vector3.new(48,3,.2),P.pink,Enum.NormalId.Back)

-- DJ booth is centered and leaves both stage wings open.
finish(A4,"DJ BOOTH BODY",Vector3.new(24,3.4,5.5),CFrame.new(0,5,-71.5),P.charcoal,Enum.Material.Metal,0,true)
finish(A4,"DJ BOOTH TOP",Vector3.new(25,.35,6),CFrame.new(0,6.85,-71.5),P.graphite,Enum.Material.Metal,0,true)
glow(A4,"DJ BOOTH FRONT",Vector3.new(20,.26,.2),CFrame.new(0,5.5,-68.65),P.pink,.55,12)
zoneSign(A4,"DJ BOOTH BRAND","BBYA RESIDENT DJ",CFrame.new(0,5,-68.48),Vector3.new(19,2.4,.2),P.white,Enum.NormalId.Front)

-- Speaker towers / stage wings.
for _,x in ipairs({-32,32}) do
 finish(A4,"SPEAKER TOWER "..x,Vector3.new(8,12,5),CFrame.new(x,8,-72),P.black,Enum.Material.Metal,0,true)
 for y=4.5,11.5,3.5 do
  local cone=finish(A4,"SPEAKER CONE "..x.." "..y,Vector3.new(2.8,2.8,.35),CFrame.new(x,y,-69.35),P.graphite,Enum.Material.SmoothPlastic,0,false)
  cone.Shape=Enum.PartType.Cylinder;cone.CFrame=cone.CFrame*CFrame.Angles(0,math.rad(90),0)
 end
 glow(A4,"STAGE WING PIN "..x,Vector3.new(.32,11,.32),CFrame.new(x+(x<0 and -5 or 5),9,-71),x<0 and P.cyan or P.pink,.48,11)
end

-- Ceiling truss system, aligned with the room rather than random floating parts.
for _,z in ipairs({-45,-15,15,45,72}) do
 finish(A4,"CEILING TRUSS "..z,Vector3.new(98,.45,.45),CFrame.new(0,16,z),P.graphite,Enum.Material.Metal,0,false)
 for _,x in ipairs({-38,-19,0,19,38}) do
  local col=((x+z)%2==0) and P.pink or P.cyan
  glow(A4,"CEILING PIXEL "..x.." "..z,Vector3.new(3.4,.35,1.2),CFrame.new(x,15.55,z),col,.55,13)
 end
end

-- Perimeter accents reinforce circulation without filling it with furniture.
glow(A4,"WEST FLOOR EDGE",Vector3.new(.2,.18,118),CFrame.new(-50,.9,10),P.cyan,.18,6)
glow(A4,"EAST FLOOR EDGE",Vector3.new(.2,.18,118),CFrame.new(50,.9,10),P.pink,.18,6)
zoneSign(A4,"CLUB EXIT WAYFINDING","LOBBY ↓   •   BAR ←   •   CHILL →   •   VIP / ROOF STAIRS",CFrame.new(0,13,80.2),Vector3.new(46,2.5,.2),P.white,Enum.NormalId.Back)
