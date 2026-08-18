-- BBYA V6 — VIP ACCESS THRESHOLDS
-- Physical stair + lift-entry gates. They remain preview-open while Game Pass ID is 0.

local function vipGate(parent,name,x,z,y,yaw)
    local cf=CFrame.new(x,y,z)*CFrame.Angles(0,math.rad(yaw or 0),0)
    part(parent,name.." POST L",Vector3.new(.7,9,.7),cf*CFrame.new(-6,4.5,0),P.graphite,Enum.Material.Metal,0,true,nil)
    part(parent,name.." POST R",Vector3.new(.7,9,.7),cf*CFrame.new(6,4.5,0),P.graphite,Enum.Material.Metal,0,true,nil)
    part(parent,name.." HEADER",Vector3.new(12.7,.7,.8),cf*CFrame.new(0,9,0),P.graphite,Enum.Material.Metal,0,true,nil)
    neon(parent,name.." ACCENT",Vector3.new(9,.12,.12),cf*CFrame.new(0,8.55,-.45),P.gold,nil)
    local barrier=part(parent,name.." BARRIER",Vector3.new(11.5,8,.45),cf*CFrame.new(0,4,0),P.glass,Enum.Material.Glass,.82,false,nil)
    barrier:SetAttribute("BBYAVIPBarrier",true)
    barrier:SetAttribute("BBYAVIPGateName",name)
    sign(parent,name.." PLAQUE","VIP",cf*CFrame.new(0,7.2,-.48),Vector3.new(5,1.2,.18),P.gold,Enum.NormalId.Front,nil)
    return barrier
end

local function liftVipThreshold()
    -- Sits just outside the VIP landing doors, leaving the lift cab/shaft itself clear.
    local barrier=part(C2,"C2 LIFT VIP BARRIER",Vector3.new(11.5,8,.4),CFrame.new(59,24.5,117.15),P.glass,Enum.Material.Glass,.9,false,nil)
    barrier:SetAttribute("BBYAVIPBarrier",true)
    barrier:SetAttribute("BBYAVIPGateName","C2 LIFT VIP GATE")
    barrier:SetAttribute("BBYALiftVIPThreshold",true)
    neon(C2,"C2 LIFT VIP THRESHOLD LINE",Vector3.new(10,.12,.12),CFrame.new(59,28.3,116.9),P.gold,nil)
    sign(C2,"C2 LIFT VIP PLAQUE","VIP",CFrame.new(64.7,27.3,116.9),Vector3.new(3.5,1,.18),P.gold,Enum.NormalId.Front,nil)
    return barrier
end

-- Top of West/East stair cores into VIP lounge level.
local west=vipGate(C1,"C1 WEST VIP GATE",-56,116.6,20.5,0)
local east=vipGate(C2,"C2 EAST VIP GATE",33,116.6,20.5,0)
local liftGate=liftVipThreshold()
west.CanCollide=false;east.CanCollide=false;liftGate.CanCollide=false

workspace:SetAttribute("BBYAV6VIPGates","PREVIEW_OPEN")
workspace:SetAttribute("BBYAV6VIPLiftThreshold",true)
