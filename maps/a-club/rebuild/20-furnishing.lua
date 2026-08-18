-- BBYA SOCIAL HUB — CLEAN REBUILD FURNISHING

-- Arrival social pockets.
for _,cfg in ipairs({
    {-66,-48,0,C.graphite},{-44,-48,0,C.cream},{44,-48,180,C.cream},{66,-48,180,C.graphite}
}) do
    seat(A1,"ARRIVAL SEAT "..cfg[1],CFrame.new(cfg[1],1.25,cfg[2])*CFrame.Angles(0,math.rad(cfg[3]),0),10,cfg[4])
end
for _,x in ipairs({-55,55}) do
    tableLow(A1,"ARRIVAL TABLE "..x,CFrame.new(x,1.1,-42),Vector3.new(6,.6,4))
    palm(A1,"ARRIVAL PALM "..x,Vector3.new(x,1,-70),12)
end

-- Atrium hangout islands.
for _,cfg in ipairs({
    {-2,17,90,C.cream},{17,17,-90,C.graphite},{-2,50,90,C.graphite},{17,50,-90,C.cream}
}) do
    seat(A2,"ATRIUM SOFA "..cfg[1].." "..cfg[2],CFrame.new(cfg[1],1.25,cfg[2])*CFrame.Angles(0,math.rad(cfg[3]),0),11,cfg[4])
end
for _,z in ipairs({17,50}) do
    tableLow(A2,"ATRIUM TABLE "..z,CFrame.new(8,1.05,z),Vector3.new(7,.6,4))
end

-- Club side lounges, keeping dance floor fully open.
for _,cfg in ipairs({
    {-75,20,90},{-75,48,90},{8,20,-90},{8,48,-90}
}) do
    seat(A3,"CLUB WATCH SOFA "..cfg[1].." "..cfg[2],CFrame.new(cfg[1],1.25,cfg[2])*CFrame.Angles(0,math.rad(cfg[3]),0),10,C.graphite)
end

-- Mezzanine social seating.
for _,y in ipairs({16.9,30.9}) do
    for _,z in ipairs({18,42,66}) do
        seat(A4,"MEZZ SOFA "..y.." "..z,CFrame.new(-78,y,z)*CFrame.Angles(0,math.rad(90),0),9,y<20 and C.graphite or C.cream)
        tableLow(A4,"MEZZ TABLE "..y.." "..z,CFrame.new(-68,y-.2,z),Vector3.new(5,.6,4))
    end
end

-- VIP lounge under rooftop.
for _,z in ipairs({10,31,52}) do
    seat(A5,"VIP EAST SOFA "..z,CFrame.new(94,1.25,z)*CFrame.Angles(0,math.rad(-90),0),11,C.cream)
    seat(A5,"VIP WEST SOFA "..z,CFrame.new(48,1.25,z)*CFrame.Angles(0,math.rad(90),0),11,C.graphite)
    tableLow(A5,"VIP TABLE "..z,CFrame.new(71,1.05,z),Vector3.new(7,.7,5))
end
part(A5,"VIP BAR BODY",Vector3.new(28,4,6),CFrame.new(68,2.2,68),C.graphite,Enum.Material.Slate,0,true)
part(A5,"VIP BAR TOP",Vector3.new(29,.4,6.6),CFrame.new(68,4.4,68),C.wood,Enum.Material.WoodPlanks,0,true)
neon(A5,"VIP BAR ACCENT",Vector3.new(26,.18,.18),CFrame.new(68,2.4,64.9),C.pink)
sign(A5,"VIP SIGN","VIP AREA",CFrame.new(68,11.5,-6.8),Vector3.new(30,4,.3),C.pink,Enum.NormalId.Front)

-- Rooftop loungers and cabana-like chill corners.
for _,x in ipairs({9,25,71,87}) do
    seat(A6,"POOL LOUNGER "..x,CFrame.new(x,32.4,48),8,C.cream)
end
for _,x in ipairs({12,84}) do
    for _,dx in ipairs({-6,6}) do
        for _,dz in ipairs({-5,5}) do
            part(A6,"CABANA POST "..x.." "..dx.." "..dz,Vector3.new(.55,8,.55),CFrame.new(x+dx,36,67+dz),C.wood,Enum.Material.Wood,0,true)
        end
    end
    part(A6,"CABANA ROOF "..x,Vector3.new(14,.5,12),CFrame.new(x,40,67),C.charcoal,Enum.Material.WoodPlanks,0,true)
    seat(A6,"CABANA DAYBED "..x,CFrame.new(x,32.4,68),9,C.cream)
end
for _,p in ipairs({Vector3.new(5,32,7),Vector3.new(91,32,7),Vector3.new(5,32,75),Vector3.new(91,32,75)}) do
    palm(A6,"ROOF PALM "..p.X.." "..p.Z,p,10)
end

-- Foreground Queen landmark from owner reference.
part(A7,"QUEEN PODIUM",Vector3.new(28,1.2,18),CFrame.new(-38,.8,-23),C.charcoal,Enum.Material.Marble,0,true)
neon(A7,"QUEEN PODIUM EDGE",Vector3.new(28,.18,.18),CFrame.new(-38,1.5,-32),C.pink)
local throne=seat(A7,"BBYA QUEEN THRONE",CFrame.new(-38,2.1,-23),8,C.graphite)
part(A7,"QUEEN THRONE BACK",Vector3.new(10,10,2),CFrame.new(-38,6.6,-20.4),C.black,Enum.Material.Metal,0,true)
for i=0,4 do
    neon(A7,"QUEEN CROWN SPIKE "..i,Vector3.new(1,6,1),CFrame.new(-44+i*3,12+(i%2)*1.5,-20.2)*CFrame.Angles(0,0,math.rad((i-2)*10)),C.pink)
end
sign(A7,"QUEEN BOARD","BBYA QUEEN",CFrame.new(-38,14,-20),Vector3.new(24,4,.3),C.pink,Enum.NormalId.Front)

-- Support / top supporter landmark. Backend comes later; this is physical destination only.
part(A7,"SUPPORT BOARD BODY",Vector3.new(32,16,2),CFrame.new(45,8,-22),C.black,Enum.Material.SmoothPlastic,0,true)
sign(A7,"SUPPORT BOARD","SUPPORT\nTOP SUPPORTERS",CFrame.new(45,8,-23.1),Vector3.new(30,14,.3),C.cyan,Enum.NormalId.Front)
neon(A7,"SUPPORT BOARD EDGE TOP",Vector3.new(32,.18,.18),CFrame.new(45,16,-23.2),C.cyan)
neon(A7,"SUPPORT BOARD EDGE BOTTOM",Vector3.new(32,.18,.18),CFrame.new(45,.2,-23.2),C.pink)

-- Lifestyle labels seen from hero arrival.
sign(A6,"ROOFTOP POOL SIGN","ROOFTOP\nPOOL PARTY",CFrame.new(82,45,-4),Vector3.new(28,8,.35),C.cyan,Enum.NormalId.Front)
sign(A3,"CLUB SIGN","BBYA CLUB",CFrame.new(-69,12,-9.2),Vector3.new(34,5,.3),C.pink,Enum.NormalId.Front)

-- City skyline depth behind venue.
local heights={34,48,29,58,41,72,37,54,44,66,32,52,76,39}
for i,h in ipairs(heights) do
    local x=-110+(i-1)*17
    local z=130+(i%3)*12
    part(A8,"CITY BUILDING "..i,Vector3.new(13,h,14),CFrame.new(x,h/2,z),Color3.fromRGB(10,12,20),Enum.Material.SmoothPlastic,0,false)
    for _,y in ipairs({9,18,27,36,45,54}) do
        if y<h-4 then
            neon(A8,"CITY WINDOW "..i.." "..y,Vector3.new(7,.18,.2),CFrame.new(x,y,z-7.1),i%2==0 and C.warm or C.cyan)
        end
    end
end

workspace:SetAttribute("BBYAFurnishing","PREMIUM_SOCIAL_PASS_1")
