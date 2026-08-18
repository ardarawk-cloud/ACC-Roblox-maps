-- BBYA V6 — FUNCTIONAL SOCIAL SEATING
-- Furniture is not decoration-only. These invisible prompt seats turn hangout pockets into usable social spaces.

local function socialSeat(parent,name,cf,componentCode)
    local seat=Instance.new("Seat")
    seat.Name=name
    seat.Size=Vector3.new(3,.55,3)
    seat.CFrame=cf
    seat.Anchored=true
    seat.Transparency=1
    seat.CanCollide=false
    seat.CanTouch=false
    seat.CanQuery=false
    seat.Parent=parent
    tag(seat,parent,componentCode)
    seat:SetAttribute("BBYASocialSeat",true)

    local prompt=Instance.new("ProximityPrompt")
    prompt.Name="SIT PROMPT"
    prompt.ActionText="SIT"
    prompt.ObjectText="BBYA SOCIAL SEAT"
    prompt.HoldDuration=0
    prompt.MaxActivationDistance=7
    prompt.RequiresLineOfSight=false
    prompt.Parent=seat
    prompt.Triggered:Connect(function(player)
        local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health>0 then seat:Sit(hum) end
    end)
    return seat
end

-- A1 arrival benches.
socialSeat(A1,"A1 SOCIAL SEAT WEST",CFrame.new(-24,2.05,-28),"01")
socialSeat(A1,"A1 SOCIAL SEAT EAST",CFrame.new(24,2.05,-28),"01")

-- A3 Social Commons islands + host stools.
socialSeat(A3,"A3 SOCIAL SEAT WEST",CFrame.new(-21,2.05,46)*CFrame.Angles(0,math.rad(90),0),nil)
socialSeat(A3,"A3 SOCIAL SEAT EAST",CFrame.new(21,2.05,49)*CFrame.Angles(0,math.rad(-90),0),nil)
for _,x in ipairs({39,45,51,57}) do socialSeat(A3,"A3 HOST SEAT "..x,CFrame.new(x,2.15,27),"02") end

-- A4 club side social pockets; dance floor itself stays clear.
for _,cfg in ipairs({
    {-38,84,90},{-38,105,90},{38,84,-90},{38,105,-90},
}) do socialSeat(A4,"A4 SOCIAL WATCH SEAT "..cfg[1].." "..cfg[2],CFrame.new(cfg[1],2.05,cfg[2])*CFrame.Angles(0,math.rad(cfg[3]),0),"05") end

-- A5 Social Bar booths.
for _,z in ipairs({78,86,94,102,110}) do socialSeat(A5,"A5 BAR SOCIAL SEAT "..z,CFrame.new(64,2.05,z)*CFrame.Angles(0,math.rad(90),0),"08") end

-- A6 conversation pairs.
for _,z in ipairs({78,94,110}) do
    socialSeat(A6,"A6 TALK SEAT WEST "..z,CFrame.new(-64,2.05,z)*CFrame.Angles(0,math.rad(90),0),nil)
    socialSeat(A6,"A6 TALK SEAT EAST "..z,CFrame.new(-53,2.05,z)*CFrame.Angles(0,math.rad(-90),0),nil)
end

-- VIP lounges / Queen / private rooms.
for _,z in ipairs({78,98,116}) do
    socialSeat(C1,"C1 VIP SOCIAL SEAT A "..z,CFrame.new(-58,22.05,z)*CFrame.Angles(0,math.rad(90),0),"09W")
    socialSeat(C1,"C1 VIP SOCIAL SEAT B "..z,CFrame.new(-42,22.05,z)*CFrame.Angles(0,math.rad(-90),0),"09W")
end
for _,z in ipairs({78,98,112}) do
    socialSeat(C2,"C2 VIP SOCIAL SEAT A "..z,CFrame.new(14,22.05,z)*CFrame.Angles(0,math.rad(90),0),"09E")
    socialSeat(C2,"C2 VIP SOCIAL SEAT B "..z,CFrame.new(40,22.05,z)*CFrame.Angles(0,math.rad(-90),0),"09E")
end
socialSeat(C3,"C3 QUEEN SOCIAL SEAT",CFrame.new(-18,22.05,141),"10")
socialSeat(C3,"C3 PRIVATE WEST SEAT",CFrame.new(-38.5,22.05,142),"12W")
socialSeat(C3,"C3 PRIVATE EAST SEAT",CFrame.new(35,22.05,142),"12E")

-- Rooftop resort seating.
for _,x in ipairs({-36,-24,24,36}) do socialSeat(D2,"D2 POOL DAYBED SEAT "..x,CFrame.new(x,42.05,66),"13") end
for _,z in ipairs({74,91,108}) do
    socialSeat(D4,"D4 CHILL SEAT A "..z,CFrame.new(-66,42.05,z)*CFrame.Angles(0,math.rad(90),0),nil)
    socialSeat(D4,"D4 CHILL SEAT B "..z,CFrame.new(-51,42.05,z)*CFrame.Angles(0,math.rad(-90),0),nil)
end
for _,x in ipairs({-33,-11,11,33}) do socialSeat(D5,"D5 CABANA SOCIAL SEAT "..x,CFrame.new(x,42.05,134),"16") end

workspace:SetAttribute("BBYAV6FunctionalSocialSeats",true)
