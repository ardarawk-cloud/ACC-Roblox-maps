-- BBYA SOCIAL HUB — ROOFTOP SEATING POLISH v3.1
-- Rooftop-only interaction correction after live mobile QC.
-- Keeps Rooftop Resort v3 visuals/lighting intact and only refines native seat placement/triggering.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
if not upper then return end
local roof=upper:WaitForChild("R_Rooftop",30)
if not roof then return end

-- Wait for the final Rooftop Resort authority to finish rebuilding the zone.
local deadline=os.clock()+35
repeat
 if roof:GetAttribute("Pass")=="ROOFTOP_RESORT_PREMIUM_V3"
  and roof:FindFirstChild("PremiumCabanasV3")
  and roof:FindFirstChild("PoolsideLoungersV3")
  and roof:FindFirstChild("RooftopBarV3")
  and roof:FindFirstChild("SunsetSocialLoungeV3") then
  break
 end
 task.wait(.15)
until os.clock()>=deadline

if roof:GetAttribute("Pass")~="ROOFTOP_RESORT_PREMIUM_V3" then
 warn("[BBYA] Rooftop seating polish skipped: premium rooftop not ready")
 return
end

task.wait(.45)

local old=roof:FindFirstChild("RooftopSeatingPolishV31")
if old then old:Destroy() end
local marker=Instance.new("Model")
marker.Name="RooftopSeatingPolishV31"
marker.Parent=roof
marker:SetAttribute("RooftopOnly",true)
marker:SetAttribute("GlobalLightingUntouched",true)
marker:SetAttribute("VisualGeometryUntouched",true)
marker:SetAttribute("NaturalSeatAlignment",true)

local tuned=0
local touchLocks={}

local function findHumanoid(hit)
 if not hit then return nil end
 local model=hit:FindFirstAncestorOfClass("Model")
 if not model then return nil end
 return model:FindFirstChildOfClass("Humanoid")
end

local function tuneSeat(seat)
 if not seat:IsA("Seat") then return end
 local name=seat.Name
 local down=.16
 local back=.20
 local size=Vector3.new(2.2,.20,2.0)

 if name:match("^DaybedSeat") then
  -- Live QC showed the avatar sitting too far forward/high on the cabana daybed.
  down=.30
  back=.95
  size=Vector3.new(2.75,.20,2.45)
 elseif name=="LoungerSeat" then
  down=.23
  back=.65
  size=Vector3.new(2.25,.20,2.25)
 elseif name=="BarSeat" then
  down=.18
  back=.12
  size=Vector3.new(1.90,.20,1.90)
 elseif name:match("^LoungeSeat") then
  down=.22
  back=.38
  size=Vector3.new(2.15,.20,2.10)
 elseif name=="ArrivalSeat" then
  down=.18
  back=.28
  size=Vector3.new(4.8,.20,1.45)
 end

 local oldCf=seat.CFrame
 local look=oldCf.LookVector
 local up=oldCf.UpVector
 local newPos=oldCf.Position-(look*back)-Vector3.new(0,down,0)
 seat.CFrame=CFrame.lookAt(newPos,newPos+look,up)
 seat.Size=size
 seat.Transparency=1
 seat.Anchored=true
 seat.CanCollide=false
 seat.CanTouch=true
 seat.CanQuery=false
 seat.CastShadow=false
 seat.Disabled=false
 seat:SetAttribute("BBYANaturalSeat",true)
 seat:SetAttribute("SeatProfile","ROOFTOP_V31")

 -- Explicit server-side sit makes the interaction reliable even though the invisible
 -- seat no longer acts as a physical block above the cushion.
 seat.Touched:Connect(function(hit)
  local hum=findHumanoid(hit)
  if not hum or hum.Health<=0 or hum.SeatPart then return end
  local now=os.clock()
  local last=touchLocks[hum] or 0
  if now-last<.65 then return end
  touchLocks[hum]=now
  seat:Sit(hum)
 end)
 tuned+=1
end

for _,obj in ipairs(roof:GetDescendants()) do
 if obj:IsA("Seat") then tuneSeat(obj) end
end

roof:SetAttribute("SeatAlignmentProfile","ROOFTOP_V31_NATURAL")
roof:SetAttribute("SeatPolishCount",tuned)
roof:SetAttribute("SeatPolishLive",true)
print(string.format("[BBYA] Rooftop seating polish v3.1 online: %d seats aligned naturally / rooftop visuals unchanged",tuned))
