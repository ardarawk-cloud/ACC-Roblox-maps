-- [A4] MAIN CLUB / DANCE HALL
local A4=registerZone("A4","MAIN CLUB / DANCE HALL","G",Vector3.new(0,9,9),Vector3.new(108,18,146))
-- Side walls split around actual openings: stair doors Z -34..-16, bar/chill doors Z 48..68.
wallZ(A4,"CLUB WEST WALL REAR",-54,-62,-34,9,18,3)
wallZ(A4,"CLUB WEST WALL MID",-54,-16,48,9,18,3)
wallZ(A4,"CLUB WEST WALL FRONT",-54,68,84,9,18,3)
wallZ(A4,"CLUB EAST WALL REAR",54,-62,-34,9,18,3)
wallZ(A4,"CLUB EAST WALL MID",54,-16,48,9,18,3)
wallZ(A4,"CLUB EAST WALL FRONT",54,68,84,9,18,3)
program(A4,"MAIN CLUB CLEAR FLOOR",Vector2.new(100,118),Vector3.new(0,.62,9),C.pink)
landing(A4,"DANCE LANDING",Vector3.new(0,.64,14),C.pink)
-- Stage is integrated into rear wall zone; 14+ stud side circulation retained.
part(A4,"STAGE PLATFORM",Vector3.new(76,3,18),CFrame.new(0,1.5,-77),C.wall2,Enum.Material.Concrete,0,true)
landing(A4,"DJ LANDING",Vector3.new(0,3.7,-63),C.pink)
label(A4,"STAGE LABEL","DJ / STAGE",CFrame.new(0,7,-86.8),Vector3.new(28,3,.25),C.pink,Enum.NormalId.Front)
zoneStamp(A4,CFrame.new(0,8,-59.8),Vector3.new(38,4,.25),C.pink,Enum.NormalId.Front)
