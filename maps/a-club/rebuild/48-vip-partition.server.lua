-- BBYA SOCIAL HUB — VIP INTERIOR PARTITION
-- Fully separates the VIP wing from the main social floor with solid glass and one gated access door.

local MarketplaceServiceVIP=game:GetService("MarketplaceService")
local TweenServiceVIP=game:GetService("TweenService")

local commerceVIP=rawget(_G,"BBYA_COMMERCE_RESOLVED") or {}
local VIP_GAMEPASS_ID=tonumber(commerceVIP.vipGamePassId) or 0

-- Clean any previous interior partition from repeat builds.
for _,name in ipairs({
    "VIP INNER GLASS FRONT",
    "VIP INNER GLASS REAR",
    "VIP INNER DOOR",
    "VIP INNER FRAME FRONT",
    "VIP INNER FRAME DOOR A",
    "VIP INNER FRAME DOOR B",
    "VIP INNER FRAME REAR",
    "VIP INNER TOP BEAM",
}) do
    local old=workspace:FindFirstChild(name,true)
    if old then old:Destroy() end
end

-- West edge of VIP FLOOR is x=32. This wall closes the side opening into the main social floor.
local frontGlass=glass(A5,"VIP INNER GLASS FRONT",Vector3.new(.55,14,28),CFrame.new(32,7.2,7),.30)
frontGlass.CanCollide=true
frontGlass.CanTouch=true
frontGlass.CanQuery=true

local rearGlass=glass(A5,"VIP INNER GLASS REAR",Vector3.new(.55,14,48),CFrame.new(32,7.2,53),.30)
rearGlass.CanCollide=true
rearGlass.CanTouch=true
rearGlass.CanQuery=true

-- Structural frame keeps the divider reading as a deliberate VIP enclosure.
for _,cfg in ipairs({
    {name="VIP INNER FRAME FRONT",z=-7},
    {name="VIP INNER FRAME DOOR A",z=21},
    {name="VIP INNER FRAME DOOR B",z=29},
    {name="VIP INNER FRAME REAR",z=77},
}) do
    part(A5,cfg.name,Vector3.new(1.1,16,1.1),CFrame.new(32,8,cfg.z),C.graphite,Enum.Material.Metal,0,true)
end
part(A5,"VIP INNER TOP BEAM",Vector3.new(1.1,1.1,84),CFrame.new(32,15.5,35),C.graphite,Enum.Material.Metal,0,true)

-- Single controlled doorway through the partition.
local vipInnerDoor=part(A5,"VIP INNER DOOR",Vector3.new(.75,12,8),CFrame.new(32,6.2,25),Color3.fromRGB(70,95,125),Enum.Material.Glass,.20,true)
vipInnerDoor.CanCollide=true
vipInnerDoor.CanTouch=true
vipInnerDoor.CanQuery=true

local prompt=Instance.new("ProximityPrompt")
prompt.Name="VIP INNER ACCESS PROMPT"
prompt.ActionText="ENTER VIP"
prompt.ObjectText="VIP ACCESS"
prompt.HoldDuration=.15
prompt.MaxActivationDistance=10
prompt.RequiresLineOfSight=false
prompt.Parent=vipInnerDoor

local closedCF=vipInnerDoor.CFrame
local openCF=closedCF*CFrame.new(0,11,0)
local busy=false

local function ownsVIP(player)
    if player:GetAttribute("BBYAAllAccess")==true or player:GetAttribute("IsVIP")==true then return true end
    if VIP_GAMEPASS_ID<=0 then return false end
    local ok,owns=pcall(function()
        return MarketplaceServiceVIP:UserOwnsGamePassAsync(player.UserId,VIP_GAMEPASS_ID)
    end)
    if ok and owns then
        player:SetAttribute("IsVIP",true)
        return true
    end
    return false
end

local function openDoor()
    if busy or not vipInnerDoor.Parent then return end
    busy=true
    vipInnerDoor.CanCollide=false
    TweenServiceVIP:Create(vipInnerDoor,TweenInfo.new(.28,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=openCF,Transparency=.58}):Play()
    task.delay(3,function()
        if not vipInnerDoor.Parent then return end
        local tween=TweenServiceVIP:Create(vipInnerDoor,TweenInfo.new(.28,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{CFrame=closedCF,Transparency=.20})
        tween:Play()
        tween.Completed:Wait()
        vipInnerDoor.CanCollide=true
        busy=false
    end)
end

prompt.Triggered:Connect(function(player)
    if ownsVIP(player) then
        openDoor()
    elseif VIP_GAMEPASS_ID>0 then
        MarketplaceServiceVIP:PromptGamePassPurchase(player,VIP_GAMEPASS_ID)
    end
end)

MarketplaceServiceVIP.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
    if purchased and VIP_GAMEPASS_ID>0 and passId==VIP_GAMEPASS_ID then
        player:SetAttribute("IsVIP",true)
        openDoor()
    end
end)

workspace:SetAttribute("BBYAVIPInteriorPartition",true)
workspace:SetAttribute("BBYAVIPInteriorDoor",true)
workspace:SetAttribute("BBYAVIPInteriorDoorPassId",VIP_GAMEPASS_ID)
