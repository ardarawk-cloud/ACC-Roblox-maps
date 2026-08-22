-- BECAK E-BIKE — Vehicle Signal Lights v1.45
-- Physics-safe brake/reverse/turn lights with mobile steering hysteresis and driver-aware idle shutdown.
local Workspace = game:GetService('Workspace')
local UPDATE_HZ, ROOT_NAME = 8, 'BecakEBike'
local INDICATOR_STEER_THRESHOLD, INDICATOR_CANCEL_THRESHOLD = 0.42, 0.18
local INDICATOR_MIN_SPEED, BLINK_PERIOD = 1.5, 0.55
local tracked = {}

local function makeLamp(model,chassis,name,offset,color)
 local old=model:FindFirstChild(name); if old and old:IsA('BasePart') then return old end
 local p=Instance.new('Part'); p.Name=name; p.Size=Vector3.new(.55,.28,.18); p.Material=Enum.Material.Neon; p.Color=color; p.Transparency=.72; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Massless=true; p.Anchored=false; p.CFrame=chassis.CFrame*CFrame.new(offset); p.Parent=model
 local w=Instance.new('WeldConstraint'); w.Part0=chassis; w.Part1=p; w.Parent=p; return p
end

local function track(model)
 if not model:IsA('Model') or tracked[model] or not model:GetAttribute('OwnerUserId') then return end
 local c=model.PrimaryPart or model:FindFirstChild('Chassis'); local s=model:FindFirstChild('DriverSeat',true)
 if not c or not c:IsA('BasePart') or not s or not s:IsA('VehicleSeat') then return end
 tracked[model]={chassis=c,seat=s,left=makeLamp(model,c,'RearBrakeLightLeft',Vector3.new(-2.15,.25,4.9),Color3.fromRGB(255,45,35)),right=makeLamp(model,c,'RearBrakeLightRight',Vector3.new(2.15,.25,4.9),Color3.fromRGB(255,45,35)),reverse=makeLamp(model,c,'RearReverseLight',Vector3.new(0,.18,4.92),Color3.fromRGB(235,245,255)),tlr=makeLamp(model,c,'RearTurnSignalLeft',Vector3.new(-2.65,.23,4.88),Color3.fromRGB(255,165,40)),trr=makeLamp(model,c,'RearTurnSignalRight',Vector3.new(2.65,.23,4.88),Color3.fromRGB(255,165,40)),tlf=makeLamp(model,c,'FrontTurnSignalLeft',Vector3.new(-2.55,.18,-4.75),Color3.fromRGB(255,165,40)),trf=makeLamp(model,c,'FrontTurnSignalRight',Vector3.new(2.55,.18,-4.75),Color3.fromRGB(255,165,40)),lastSpeed=0,intent=0}
 model:SetAttribute('VehicleSignalsReady',true); model:SetAttribute('VehicleSignalsVersion','v1.45'); model:SetAttribute('VehicleSignalDriverPresent',false)
end

local function lamp(p,on,a,i) if p and p.Parent then p.Transparency=on and a or i end end
local function pair(a,b,on) lamp(a,on,.05,.9); lamp(b,on,.05,.9) end
local function allOff(x)
 lamp(x.left,false,.08,.72); lamp(x.right,false,.08,.72); lamp(x.reverse,false,.12,.88); pair(x.tlf,x.tlr,false); pair(x.trf,x.trr,false)
end
local function scan() local r=Workspace:FindFirstChild(ROOT_NAME); local v=r and r:FindFirstChild('Vehicles'); if v then for _,m in ipairs(v:GetChildren()) do track(m) end end end

scan(); local root=Workspace:FindFirstChild(ROOT_NAME); local vehicles=root and root:FindFirstChild('Vehicles'); if vehicles then vehicles.ChildAdded:Connect(function(c) task.defer(track,c) end) end
while task.wait(1/UPDATE_HZ) do
 if not vehicles or not vehicles.Parent then root=Workspace:FindFirstChild(ROOT_NAME); vehicles=root and root:FindFirstChild('Vehicles'); if vehicles then scan() end end
 local blink=(os.clock()%BLINK_PERIOD)<BLINK_PERIOD*.5
 for model,x in pairs(tracked) do
  if not model.Parent or not x.chassis.Parent then tracked[model]=nil else
   local driverPresent=x.seat.Occupant~=nil
   model:SetAttribute('VehicleSignalDriverPresent',driverPresent)
   if not driverPresent then
    x.intent=0; x.lastSpeed=0; allOff(x)
    model:SetAttribute('BrakeLightsActive',false); model:SetAttribute('ReverseLightActive',false); model:SetAttribute('TurnSignalLeftActive',false); model:SetAttribute('TurnSignalRightActive',false)
   else
    local vel=x.chassis.AssemblyLinearVelocity; local f=x.chassis.CFrame.LookVector:Dot(vel); local speed=math.abs(f); local throttle=x.seat.ThrottleFloat; local steer=x.seat.SteerFloat
    local braking=speed>2 and (math.abs(throttle)<.05 and x.lastSpeed-speed>.45 or throttle*f<-.2); local reversing=throttle<-.05 or f< -2; local eligible=speed>=INDICATOR_MIN_SPEED or math.abs(throttle)>.08
    if not eligible then x.intent=0 elseif steer<=-INDICATOR_STEER_THRESHOLD then x.intent=-1 elseif steer>=INDICATOR_STEER_THRESHOLD then x.intent=1 elseif math.abs(steer)<=INDICATOR_CANCEL_THRESHOLD then x.intent=0 end
    local li=x.intent==-1; local ri=x.intent==1; lamp(x.left,braking,.08,.72); lamp(x.right,braking,.08,.72); lamp(x.reverse,reversing,.12,.88); pair(x.tlf,x.tlr,li and blink); pair(x.trf,x.trr,ri and blink)
    model:SetAttribute('BrakeLightsActive',braking); model:SetAttribute('ReverseLightActive',reversing); model:SetAttribute('TurnSignalLeftActive',li); model:SetAttribute('TurnSignalRightActive',ri); x.lastSpeed=speed
   end
  end
 end
end

Workspace:SetAttribute('ACC_BecakVehicleSignals','v1.45'); Workspace:SetAttribute('BecakBrakeLights','ON'); Workspace:SetAttribute('BecakReverseLight','ON'); Workspace:SetAttribute('BecakAutoTurnIndicators','ON'); Workspace:SetAttribute('BecakIndicatorHysteresis','ON'); Workspace:SetAttribute('BecakDriverAwareSignals','ON'); Workspace:SetAttribute('BecakIndicatorSteerThreshold',INDICATOR_STEER_THRESHOLD); Workspace:SetAttribute('BecakIndicatorCancelThreshold',INDICATOR_CANCEL_THRESHOLD); Workspace:SetAttribute('BecakVehicleSignalsHz',UPDATE_HZ)
print('[BECAK E-BIKE] vehicle signals v1.45 ready • driver-aware idle shutdown • stable mobile indicators • physics-safe')
