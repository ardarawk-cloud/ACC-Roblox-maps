-- BBYA SOCIAL HUB — WORLD PROMPT CLEANUP v2
-- Menu-first UX: Travel is the only navigation authority for duplicate world teleports.
local Workspace=game:GetService("Workspace")

local function shouldRemovePrompt(p)
 if not p:IsA("ProximityPrompt") then return false end
 if p.Name=="CreatePrestigeMessage" or p.Name=="RooftopAccessPrompt" then return true end
 local action=tostring(p.ActionText or "")
 local object=tostring(p.ObjectText or "")
 if action=="Go Up" or action=="Go Down" then
  if object=="VIP Level" or object=="Rooftop" or object=="Rooftop Pool" or object=="Main Club" or object=="Basement" then return true end
 end
 return false
end

local function shouldRemoveAccessPart(o)
 return o:IsA("BasePart") and o.Name=="RooftopAccess"
end

local function removeIfDuplicate(o)
 if not o or not o.Parent then return false end
 if shouldRemovePrompt(o) or shouldRemoveAccessPart(o) then
  o:Destroy()
  return true
 end
 return false
end

local function sweep()
 local removed=0
 for _,d in ipairs(Workspace:GetDescendants()) do
  if removeIfDuplicate(d) then removed+=1 end
 end
 return removed
end

task.defer(function()
 local total=sweep()
 print("[BBYA] Menu-first prompt cleanup v2 removed "..total.." duplicate world navigation objects")
end)

Workspace.DescendantAdded:Connect(function(d)
 if shouldRemovePrompt(d) or shouldRemoveAccessPart(d) then
  task.defer(function()
   if d.Parent then removeIfDuplicate(d) end
  end)
 end
end)

-- -----------------------------------------------------------------------------
-- ROOFTOP SEATING POLISH v3.1
-- Live mobile QC showed the invisible native seats sitting too high/forward above
-- cushions. Keep all Rooftop v3 visuals and lighting intact; only refine seat
-- placement and make the sit trigger non-blocking/reliable.
-- -----------------------------------------------------------------------------
task.spawn(function()
 local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
 if not root then return end
 local upper=root:WaitForChild("UpperLevels",30)
 if not upper then return end
 local roof=upper:WaitForChild("R_Rooftop",30)
 if not roof then return end

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
  local character=hit:FindFirstAncestorOfClass("Model")
  return character and character:FindFirstChildOfClass("Humanoid") or nil
 end

 local function tuneSeat(seat)
  if not seat:IsA("Seat") then return end
  local name=seat.Name
  local down=.16
  local back=.20
  local size=Vector3.new(2.2,.20,2.0)

  if name:match("^DaybedSeat") then
   down=.30;back=.95;size=Vector3.new(2.75,.20,2.45)
  elseif name=="LoungerSeat" then
   down=.23;back=.65;size=Vector3.new(2.25,.20,2.25)
  elseif name=="BarSeat" then
   down=.18;back=.12;size=Vector3.new(1.90,.20,1.90)
  elseif name:match("^LoungeSeat") then
   down=.22;back=.38;size=Vector3.new(2.15,.20,2.10)
  elseif name=="ArrivalSeat" then
   down=.18;back=.28;size=Vector3.new(4.8,.20,1.45)
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
 print(string.format("[BBYA] Rooftop seating polish v3.1 online: %d seats aligned naturally / Rooftop visuals unchanged",tuned))
end)
