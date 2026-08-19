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
    for _,obj in ipairs(workspace:GetDescendants()) do
        if string.sub(obj.Name,1,#prefix)==prefix then obj:Destroy() end
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
    "WELCOME BAR SIGN",
    "WELCOME BACKDROP BRAND",
    "WELCOME BACKDROP TOP",
    "WELCOME BACKDROP BOTTOM",
    "WELCOME BACKDROP",
    "SELFIE WORDMARK",
    "CLUB WING BRAND",
    "CLUB SIGN",
    "CLUB ENTRY WAYFIND",
    "DJ BOOTH BRAND",
    "CROWN BASE","CROWN L1","CROWN L2","CROWN R2","CROWN R1",
}) do
    destroyNamed(name)
end

-- Owner correction: arrival/support forecourt must stay open. Remove the loose benches/chairs shown in live screenshots.
destroyPrefix("ARRIVAL SEAT ")

local mainBrand=findDeep("MAIN BBYA WORDMARK")
if mainBrand and mainBrand:IsA("BasePart") then
    mainBrand.CFrame=CFrame.new(22,21,-12.05)
    mainBrand.Size=Vector3.new(44,4.4,.35)
    setSignText(mainBrand,"BBYA SOCIAL HUB")
end

-- Queen is a zone label, not repeated venue branding.
local queenBoard=findDeep("QUEEN BOARD")
if queenBoard then setSignText(queenBoard,"QUEEN") end

-- =========================================================
-- FACADE GLASS MUST BE A REAL PHYSICAL BARRIER.
-- Pool water is intentionally excluded.
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
-- Replace overlapping decorative glass with a clean partition and one real door.
-- =========================================================
for _,obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") and (string.match(obj.Name,"^VIP FRONT GLASS ") or string.match(obj.Name,"^VIP FACADE PANEL ")) then
        obj:Destroy()
    end
end

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
    local ok,owns=pcall(function()
        return MarketplaceServiceLayout:UserOwnsGamePassAsync(player.UserId,VIP_GAMEPASS_ID)
    end)
    if ok and owns then
        player:SetAttribute("IsVIP",true)
        return true
    end
    return false
end

vipPrompt.Triggered:Connect(function(player)
    if ownsVip(player) then
        openVipDoor(player)
        return
    end
    if VIP_GAMEPASS_ID>0 then
        MarketplaceServiceLayout:PromptGamePassPurchase(player,VIP_GAMEPASS_ID)
    end
end)

MarketplaceServiceLayout.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
    if purchased and VIP_GAMEPASS_ID>0 and passId==VIP_GAMEPASS_ID then
        player:SetAttribute("IsVIP",true)
        openVipDoor(player)
    end
end)

-- =========================================================
-- REAL ROOFTOP ACCESS.
-- The previous single solid roof slab crossed the stair path. Split it around a stairwell.
-- =========================================================
destroyNamed("ROOFTOP DECK")

part(A6,"ROOFTOP DECK WEST",Vector3.new(87,2,92),CFrame.new(36.5,31,34),Color3.fromRGB(72,61,59),Enum.Material.WoodPlanks,0,true)
part(A6,"ROOFTOP DECK EAST FRONT",Vector3.new(16,2,54),CFrame.new(88,31,15),Color3.fromRGB(72,61,59),Enum.Material.WoodPlanks,0,true)
part(A6,"ROOFTOP DECK EAST EDGE",Vector3.new(7,2,92),CFrame.new(99.5,31,34),Color3.fromRGB(72,61,59),Enum.Material.WoodPlanks,0,true)

local roofLanding=findDeep("ROOF STAIR LANDING")
if roofLanding and roofLanding:IsA("BasePart") then
    roofLanding.CFrame=CFrame.new(88,32.45,69)
    roofLanding.Size=Vector3.new(14,1,12)
end
part(A6,"ROOF STAIR BRIDGE",Vector3.new(5,1,12),CFrame.new(79.5,32.45,69),C.stone,Enum.Material.Slate,0,true)
rail(A6,"ROOF STAIRWELL EAST RAIL",Vector3.new(.45,4.8,36),CFrame.new(96.1,35,61))
rail(A6,"ROOF STAIRWELL FRONT RAIL",Vector3.new(16,4.8,.45),CFrame.new(88,35,42.2))
neon(A6,"ROOF STAIR ARRIVAL GLOW",Vector3.new(12,.14,.14),CFrame.new(88,33.05,75),C.warm)

workspace:SetAttribute("BBYAOwnerLayoutFix","LIVE_OWNER_CORRECTIONS_V2")
workspace:SetAttribute("BBYAFacadeGlassSolid",true)
workspace:SetAttribute("BBYAVIPDoorInstalled",true)
workspace:SetAttribute("BBYAVIPPassResolved",VIP_GAMEPASS_ID>0)
workspace:SetAttribute("BBYARooftopStairwellOpen",true)
workspace:SetAttribute("BBYAArrivalSeatsRemoved",true)
