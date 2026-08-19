-- BBYA SOCIAL HUB — OWNER LIVE LAYOUT FIX
-- Removes noisy/incorrect signage, hardens facade glass, builds a gated VIP entrance,
-- opens a real rooftop stairwell, and keeps the arrival/support forecourt visually clean.

local MarketplaceServiceLayout=game:GetService("MarketplaceService")

local function findDeep(name)
    return workspace:FindFirstChild(name,true)
end

local function destroyNamed(name)
    local obj=findDeep(name)
    if obj then obj:Destroy() end
end

local function destroyPrefix(prefix)
    local kill={}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if string.sub(obj.Name,1,#prefix)==prefix then table.insert(kill,obj) end
    end
    for _,obj in ipairs(kill) do
        if obj and obj.Parent then obj:Destroy() end
    end
end

local function setSignText(partObj,text)
    if not partObj then return end
    local gui=partObj:FindFirstChildOfClass("SurfaceGui")
    local label=gui and gui:FindFirstChildOfClass("TextLabel")
    if label then label.Text=text end
end

-- =========================================================
-- CLEAN SIGNAGE: one BBYA SOCIAL HUB identity only.
-- =========================================================
for _,name in ipairs({
    "WELCOME BAR SIGN","WELCOME BACKDROP BRAND","WELCOME BACKDROP TOP","WELCOME BACKDROP BOTTOM","WELCOME BACKDROP",
    "SELFIE WORDMARK","CLUB WING BRAND","CLUB SIGN","CLUB ENTRY WAYFIND","DJ BOOTH BRAND",
    "CROWN BASE","CROWN L1","CROWN L2","CROWN R2","CROWN R1",
}) do
    destroyNamed(name)
end

destroyPrefix("ARRIVAL SEAT ")

local mainBrand=findDeep("MAIN BBYA WORDMARK")
if mainBrand and mainBrand:IsA("BasePart") then
    mainBrand.CFrame=CFrame.new(22,21,-12.05)
    mainBrand.Size=Vector3.new(44,4.4,.35)
    setSignText(mainBrand,"BBYA SOCIAL HUB")
end

local queenBoard=findDeep("QUEEN BOARD")
if queenBoard then setSignText(queenBoard,"QUEEN") end

-- =========================================================
-- FACADE GLASS MUST BE A REAL PHYSICAL BARRIER.
-- =========================================================
for _,obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        local upper=string.upper(obj.Name)
        if string.find(upper,"GLASS",1,true) and not string.find(upper,"POOL WATER",1,true) then
            obj.CanCollide=true
            obj.CanTouch=true
            obj.CanQuery=true
        end
    end
end

-- =========================================================
-- VIP GLASS FRONT + LOCKED ACCESS DOOR.
-- =========================================================
local vipFacadeKill={}
for _,obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") and (string.match(obj.Name,"^VIP FRONT GLASS ") or string.match(obj.Name,"^VIP FACADE PANEL ")) then
        table.insert(vipFacadeKill,obj)
    end
end
for _,obj in ipairs(vipFacadeKill) do if obj.Parent then obj:Destroy() end end

local vipGlassL=glass(A5,"VIP LOCKED GLASS LEFT",Vector3.new(39.5,13,.5),CFrame.new(51.75,7.1,-8.55),.34)
vipGlassL.CanCollide=true
local vipGlassR=glass(A5,"VIP LOCKED GLASS RIGHT",Vector3.new(21.5,13,.5),CFrame.new(93.25,7.1,-8.55),.34)
vipGlassR.CanCollide=true

local vipDoor=part(A5,"VIP ACCESS DOOR",Vector3.new(10,12,.75),CFrame.new(77.5,6.2,-8.65),Color3.fromRGB(70,95,125),Enum.Material.Glass,.22,true)
vipDoor.CanCollide=true
vipDoor.CanTouch=true
vipDoor.CanQuery=true

local vipPrompt=Instance.new("ProximityPrompt")
vipPrompt.Name="VIP ACCESS PROMPT"
vipPrompt.ActionText="ENTER VIP"
vipPrompt.ObjectText="VIP AREA"
vipPrompt.HoldDuration=.15
vipPrompt.MaxActivationDistance=10
vipPrompt.RequiresLineOfSight=false
vipPrompt.Parent=vipDoor

local resolvedCommerce=rawget(_G,"BBYA_COMMERCE_RESOLVED") or {}
local VIP_GAMEPASS_ID=tonumber(resolvedCommerce.vipGamePassId) or 0
local doorBusy=false

local function openVipDoor(player)
    if doorBusy then return end
    doorBusy=true
    vipDoor.CanCollide=false
    vipDoor.Transparency=.72
    task.delay(3,function()
        if vipDoor and vipDoor.Parent then
            vipDoor.CanCollide=true
            vipDoor.Transparency=.22
        end
        doorBusy=false
    end)
end

local function ownsVip(player)
    if player:GetAttribute("BBYAAllAccess")==true or player:GetAttribute("IsVIP")==true then return true end
    if VIP_GAMEPASS_ID<=0 then return false end
    local ok,owns=pcall(function() return MarketplaceServiceLayout:UserOwnsGamePassAsync(player.UserId,VIP_GAMEPASS_ID) end)
    if ok and owns then player:SetAttribute("IsVIP",true);return true end
    return false
end

vipPrompt.Triggered:Connect(function(player)
    if ownsVip(player) then openVipDoor(player)
    elseif VIP_GAMEPASS_ID>0 then MarketplaceServiceLayout:PromptGamePassPurchase(player,VIP_GAMEPASS_ID) end
end)

MarketplaceServiceLayout.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
    if purchased and VIP_GAMEPASS_ID>0 and passId==VIP_GAMEPASS_ID then
        player:SetAttribute("IsVIP",true)
        openVipDoor(player)
    end
end)

-- =========================================================
-- REAL ROOFTOP ACCESS — FULLY OPEN EXIT.
-- Stair flight center: X=88, Z=47..67.25, Y=16.7..31.55.
-- Remove every old landing/rail/slab that can cross the avatar path, then rebuild the exit beyond the last step.
-- =========================================================

-- Ceiling opening around the entire second flight.
destroyNamed("VIP CEILING")
for _,name in ipairs({"VIP CEILING WEST","VIP CEILING EAST","VIP CEILING FRONT BRIDGE","VIP CEILING REAR CAP"}) do destroyNamed(name) end
part(A5,"VIP CEILING WEST",Vector3.new(48,1,84),CFrame.new(56,18,35),C.charcoal,Enum.Material.Concrete,0,true)
part(A5,"VIP CEILING EAST",Vector3.new(8,1,84),CFrame.new(100,18,35),C.charcoal,Enum.Material.Concrete,0,true)
part(A5,"VIP CEILING FRONT BRIDGE",Vector3.new(16,1,46),CFrame.new(88,18,15),C.charcoal,Enum.Material.Concrete,0,true)
-- No rear cap: the flight and exit remain open all the way toward Z=80.

-- Rooftop opening.
destroyNamed("ROOFTOP DECK")
for _,name in ipairs({"ROOFTOP DECK WEST","ROOFTOP DECK EAST FRONT","ROOFTOP DECK EAST EDGE"}) do destroyNamed(name) end
part(A6,"ROOFTOP DECK WEST",Vector3.new(86,2,92),CFrame.new(36,31,34),Color3.fromRGB(72,61,59),Enum.Material.WoodPlanks,0,true)
part(A6,"ROOFTOP DECK EAST FRONT",Vector3.new(14,2,54),CFrame.new(89,31,15),Color3.fromRGB(72,61,59),Enum.Material.WoodPlanks,0,true)
part(A6,"ROOFTOP DECK EAST EDGE",Vector3.new(6,2,92),CFrame.new(100,31,34),Color3.fromRGB(72,61,59),Enum.Material.WoodPlanks,0,true)

-- Remove all previous objects around the top stair mouth, including the landing that was sitting over the last steps.
for _,name in ipairs({
    "ROOF STAIR LANDING","ROOF STAIR BRIDGE",
    "ROOF LANDING RAIL WEST","ROOF LANDING RAIL EAST",
    "ROOF STAIRWELL EAST RAIL","ROOF STAIRWELL FRONT RAIL",
    "ROOF STAIR ARRIVAL GLOW",
}) do destroyNamed(name) end

-- Open transition after the final stair. Nothing sits above the avatar path.
part(A6,"ROOF EXIT TRANSITION",Vector3.new(8,.7,2.2),CFrame.new(88,31.62,68.25),C.stone,Enum.Material.Slate,0,true)
part(A6,"ROOF ACCESS LANDING",Vector3.new(14,1,9),CFrame.new(88,31.5,73.6),C.stone,Enum.Material.Slate,0,true)

-- Side guards only, outside the 8-stud stair width. No front/cross rail.
rail(A6,"ROOF ACCESS GUARD WEST",Vector3.new(.4,4,10),CFrame.new(80.7,34,73.5))
rail(A6,"ROOF ACCESS GUARD EAST",Vector3.new(.4,4,10),CFrame.new(95.3,34,73.5))
neon(A6,"ROOF ACCESS GLOW",Vector3.new(12,.14,.14),CFrame.new(88,32.08,77.8),C.warm)

workspace:SetAttribute("BBYAOwnerLayoutFix","LIVE_OWNER_CORRECTIONS_V4")
workspace:SetAttribute("BBYAFacadeGlassSolid",true)
workspace:SetAttribute("BBYAVIPDoorInstalled",true)
workspace:SetAttribute("BBYAVIPPassResolved",VIP_GAMEPASS_ID>0)
workspace:SetAttribute("BBYARooftopStairwellOpen",true)
workspace:SetAttribute("BBYAVIPCeilingStairwellOpen",true)
workspace:SetAttribute("BBYARooftopExitCrossBarrier",false)
workspace:SetAttribute("BBYAArrivalSeatsRemoved",true)
