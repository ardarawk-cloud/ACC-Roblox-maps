-- [B2] EAST STAIR CORE FINISH
-- Mirror of B1; stair width and landings remain untouched.

finish(B2,"EAST STAIR CORE SKIN",Vector3.new(23,.14,36),CFrame.new(70,.72,-24),P.charcoal,Enum.Material.Slate,0,false)
for _,y in ipairs({2.2,5.2,8.2,11.2,14.2,17.2,20.2,23.2,26.2,29.2,32.2,35.2}) do
 glow(B2,"EAST STAIR GUIDE "..y,Vector3.new(.18,.18,8),CFrame.new(81.05,y,-24),P.pink,.16,5)
end
zoneSign(B2,"EAST STAIR G SIGN","B2 • VIP / ROOFTOP",CFrame.new(58.1,7,-24)*CFrame.Angles(0,math.rad(-90),0),Vector3.new(16,2.4,.2),P.pink,Enum.NormalId.Front)
zoneSign(B2,"EAST STAIR VIP SIGN","VIP LEVEL",CFrame.new(58.1,22,-24)*CFrame.Angles(0,math.rad(-90),0),Vector3.new(12,2.2,.2),P.gold,Enum.NormalId.Front)
zoneSign(B2,"EAST STAIR ROOF SIGN","ROOFTOP",CFrame.new(58.1,35,-24)*CFrame.Angles(0,math.rad(-90),0),Vector3.new(12,2.2,.2),P.warm,Enum.NormalId.Front)
