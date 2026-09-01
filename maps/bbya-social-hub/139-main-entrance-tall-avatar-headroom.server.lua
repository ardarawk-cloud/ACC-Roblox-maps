-- BBYA SOCIAL HUB — MAIN + ENTRANCE TALL AVATAR HEADROOM v2
-- Purpose: make the street entrance and Main Club comfortable for tall/Zepeto-style avatars.
-- Preserves the approved BBYA entrance logo/crown/signage exactly; geometry is translated/extended only.
-- Uses the vertical room already created by SiteBasement TALL_AVATAR_VERTICAL_STACK_V1.
-- No audio, global Lighting, Underground, VIP, Rooftop, Mall, or X/Z layout changes.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end

local DELTA=8
local MARK="BBYAMainEntranceHeadroomV2"

local function shiftPartY(part,delta)
 if not part or not part:IsA("BasePart") or part:GetAttribute(MARK) then return end
 part.CFrame=part.CFrame+Vector3.new(0,delta,0)
 part:SetAttribute(MARK,true)
end

local function extendUp(part,extra)
 if not part or not part:IsA("BasePart") or part:GetAttribute(MARK) then return end
 part.Size=Vector3.new(part.Size.X,part.Size.Y+extra,part.Size.Z)
 part.CFrame=part.CFrame+Vector3.new(0,extra/2,0)
 part:SetAttribute(MARK,true)
end

local function shiftModelY(model,delta)
 if not model or not model:IsA("Model") or model:GetAttribute(MARK) then return end
 model:PivotTo(model:GetPivot()+Vector3.new(0,delta,0))
 model:SetAttribute(MARK,true)
 for _,d in ipairs(model:GetDescendants()) do
  if d:IsA("BasePart") then d:SetAttribute(MARK,true) end
 end
end

-- STREET ENTRANCE -------------------------------------------------------------
task.spawn(function()
 local entrance=root:WaitForChild("Entrance",30)
 if not entrance then return end
 local signage=entrance:WaitForChild("EntranceSignage",20)
 local portalTop=entrance:WaitForChild("PortalTop",20)
 local crown=entrance:WaitForChild("CrownBase2",20)
 if not signage or not portalTop or not crown then
  warn("[BBYA Headroom V2] entrance authority incomplete")
  return
 end
 task.wait(.35)

 -- Keep floor datum fixed; grow vertical facade/portal clearance upward.
 for _,name in ipairs({"FacadeLeft","FacadeRight","PortalLeft","PortalRight","GlassLeft","GlassRight"}) do
  extendUp(entrance:FindFirstChild(name),DELTA)
 end
 shiftPartY(entrance:FindFirstChild("FacadeHeader"),DELTA)
 shiftPartY(portalTop,DELTA)
 shiftPartY(entrance:FindFirstChild("PortalPinkTop"),DELTA)

 -- Legendary entrance identity is not redesigned: move the complete approved sign assembly as one unit.
 shiftModelY(signage,DELTA)
 for _,d in ipairs(entrance:GetChildren()) do
  if d:IsA("BasePart") and d.Name:match("^Crown") then shiftPartY(d,DELTA) end
 end

 entrance:SetAttribute("BBYATallAvatarEntranceProfile","ZEPETO_CLEARANCE_V2")
 entrance:SetAttribute("BBYAEntranceVerticalDeltaY",DELTA)
 entrance:SetAttribute("BBYALegendaryLogoPreserved",true)
 root:SetAttribute("BBYAEntranceTallAvatarClearance",true)
 print("[BBYA Headroom V2] entrance raised 8 studs; legendary logo/crown preserved")
end)

-- FRONT-OF-HOUSE / INNER CLUB PORTAL -----------------------------------------
task.spawn(function()
 local front=root:WaitForChild("Floor1FrontPremium",35)
 if not front then return end
 local reception=front:WaitForChild("Reception",20)
 local transition=front:WaitForChild("EntranceToClubTransition",20)
 if not reception or not transition then return end
 task.wait(.35)

 for _,d in ipairs(reception:GetDescendants()) do
  if d:IsA("BasePart") and (d.Name:match("^ReceptionCeilingSlat") or d.Name:match("^ReceptionDownlight")) then
   shiftPartY(d,DELTA)
  end
 end

 for _,d in ipairs(transition:GetDescendants()) do
  if d:IsA("BasePart") then
   if d.Name:match("^CeilingFin") or d.Name:match("^FinLight") or d.Name=="PortalTop" then
    shiftPartY(d,DELTA)
   elseif d.Name=="PortalL" or d.Name=="PortalR" or d.Name=="PortalAccentL" or d.Name=="PortalAccentR" then
    extendUp(d,DELTA)
   end
  end
 end

 front:SetAttribute("BBYATallAvatarTransitionProfile","ZEPETO_CLEARANCE_V2")
 print("[BBYA Headroom V2] reception ceiling and inner club portal raised 8 studs")
end)

-- MAIN CLUB FALSE CEILING ------------------------------------------------------
task.spawn(function()
 local main=root:WaitForChild("MainClubRealism",40)
 if not main then return end
 local architecture=main:WaitForChild("Architecture",20)
 if not architecture then return end
 local ceiling=architecture:WaitForChild("CeilingArchitecture",20)
 local shell=architecture:WaitForChild("PremiumShell",20)
 if not ceiling or not shell then return end
 task.wait(.5)

 -- SiteBasement already opens the structural Main/VIP stack to ~28 studs.
 -- The premium false ceiling was still at ~20 studs; lift that whole assembly into the available space.
 shiftModelY(ceiling,DELTA)
 for _,d in ipairs(shell:GetChildren()) do
  if d:IsA("BasePart") and d.Name:match("^ColumnCore") then extendUp(d,DELTA) end
 end

 main:SetAttribute("BBYATallAvatarMainProfile","ZEPETO_CLEARANCE_V2")
 main:SetAttribute("BBYAMainCeilingDeltaY",DELTA)
 main:SetAttribute("BBYAMainTargetClearHeadroom",28)
 root:SetAttribute("BBYAMainTallAvatarClearance",true)
 root:SetAttribute("BBYAMainEntranceHeadroomAuthority","MAIN_ENTRANCE_TALL_AVATAR_V2")
 print("[BBYA Headroom V2] Main Club false ceiling raised 8 studs toward 28-stud target")
end)
