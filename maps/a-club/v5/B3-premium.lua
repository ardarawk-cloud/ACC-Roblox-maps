-- [B3] PREMIUM LIFT CORE
-- Visual shaft finish + three coded call stations. Movement logic lives in SYS-LIFT.

-- Glass front strips flank a clear 10-stud lift door opening around X=73.
for _,y in ipairs({7,25,43}) do
 finish(B3,"LIFT DOOR LEFT "..y,Vector3.new(3,10,.35),CFrame.new(67.5,y,99.7),P.charcoal,Enum.Material.Metal,0,true)
 finish(B3,"LIFT DOOR RIGHT "..y,Vector3.new(3,10,.35),CFrame.new(78.5,y,99.7),P.charcoal,Enum.Material.Metal,0,true)
 glow(B3,"LIFT HEADER "..y,Vector3.new(14,.3,.25),CFrame.new(73,y+5.2,99.5),y<10 and P.cyan or (y<30 and P.gold or P.warm),.28,7)
 zoneSign(B3,"LIFT LEVEL SIGN "..y,y<10 and "G • LIFT" or (y<30 and "VIP • LIFT" or "ROOF • LIFT"),CFrame.new(73,y+3.8,99.45),Vector3.new(10,2,.2),P.white,Enum.NormalId.Front)
end

-- Lift car is intentionally static/invisible in the shaft; server uses safe floor-to-floor transfer.
local liftCar=finish(B3,"LIFT CAR PLATFORM",Vector3.new(12,.6,12),CFrame.new(73,.4,108),P.graphite,Enum.Material.Metal,0,true)
liftCar:SetAttribute("BBYALiftCar",true)
finish(B3,"LIFT CAR BACK",Vector3.new(12,9,.4),CFrame.new(73,5,113.7),P.charcoal,Enum.Material.Metal,0,true)
glow(B3,"LIFT CAR CEILING",Vector3.new(8,.2,3),CFrame.new(73,9.1,108),P.warm,.3,8)
