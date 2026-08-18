local Players = game:GetService("Players")

local root = workspace:FindFirstChild("TreasureIsland") or Instance.new("Folder")
root.Name = "TreasureIsland"
root.Parent = workspace

local function part(name,size,pos,color,material)
    local p = Instance.new("Part")
    p.Name=name;p.Size=size;p.Position=pos;p.Anchored=true;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Parent=root
    return p
end

local island = part("IslandBase",Vector3.new(85,8,85),Vector3.new(0,34,-185),Color3.fromRGB(78,158,79),Enum.Material.Grass)
local sand = part("BeachRing",Vector3.new(95,3,95),Vector3.new(0,28,-185),Color3.fromRGB(239,207,137),Enum.Material.Sand)
local water = part("Lagoon",Vector3.new(160,2,160),Vector3.new(0,25,-185),Color3.fromRGB(66,182,224),Enum.Material.Glass)
water.Transparency=.35; water.CanCollide=false

for i=1,16 do
    local angle=(i/16)*math.pi*2
    local r=30+((i%3)*5)
    local x,z=math.cos(angle)*r,math.sin(angle)*r
    local trunk=part("PalmTrunk",Vector3.new(2,10,2),Vector3.new(x,43,z-185),Color3.fromRGB(120,82,48),Enum.Material.Wood)
    trunk.Orientation=Vector3.new(0,math.deg(-angle),math.sin(i)*7)
    local crown=part("PalmCrown",Vector3.new(8,4,8),Vector3.new(x,49,z-185),Color3.fromRGB(51,143,74),Enum.Material.Grass)
    crown.Shape=Enum.PartType.Ball
end

local ruins = {
    Vector3.new(-18,39,-190),Vector3.new(18,39,-177),Vector3.new(-4,39,-162),Vector3.new(14,39,-205)
}
for i,pos in ipairs(ruins) do
    local r=part("AncientRuins"..i,Vector3.new(7,10,5),pos,Color3.fromRGB(157,147,118),Enum.Material.Slate)
    r.Orientation=Vector3.new(0,i*23,0)
end

local chestSpots = {
    Vector3.new(-25,40,-205),Vector3.new(22,40,-199),Vector3.new(0,40,-168),Vector3.new(-20,40,-174),Vector3.new(25,40,-178)
}

local collected = {}
local completed = {}
local lastTrigger = {}
local adventureConnections = {}

local function resetRun(player)
    local uid = player.UserId
    collected[uid] = {}
    completed[uid] = nil
    player:SetAttribute("WP_TreasureProgress",0)
    player:SetAttribute("WP_TreasureIslandComplete",false)
end

local function getState(player)
    local uid=player.UserId
    collected[uid]=collected[uid] or {}
    return collected[uid]
end

local function grantCompletion(player)
    local uid=player.UserId
    if completed[uid] then return end
    completed[uid]=true
    player:SetAttribute("Coins",(tonumber(player:GetAttribute("Coins")) or 0)+120)
    player:SetAttribute("Stars",(tonumber(player:GetAttribute("Stars")) or 0)+1)
    player:SetAttribute("WP_TreasureIslandComplete",true)
    player:SetAttribute("WP_AdventureCompletions",(tonumber(player:GetAttribute("WP_AdventureCompletions")) or 0)+1)
end

for i,pos in ipairs(chestSpots) do
    local chest=part("Treasure"..i,Vector3.new(4,3,3),pos,Color3.fromRGB(173,93,43),Enum.Material.Wood)
    local prompt=Instance.new("ProximityPrompt")
    prompt.ActionText="Collect Treasure"
    prompt.ObjectText="Wonder Chest"
    prompt.HoldDuration=.25
    prompt.MaxActivationDistance=10
    prompt.RequiresLineOfSight=false
    prompt.Parent=chest
    prompt.Triggered:Connect(function(player)
        if player:GetAttribute("WP_ActiveAdventure") ~= "TreasureIsland" then return end
        local now=os.clock()
        local triggerKey=tostring(player.UserId)..":"..i
        if lastTrigger[triggerKey] and now-lastTrigger[triggerKey]<0.75 then return end
        lastTrigger[triggerKey]=now

        local state=getState(player)
        if state[i] then return end
        state[i]=true

        local count=0
        for _ in pairs(state) do count+=1 end
        player:SetAttribute("WP_TreasureProgress",count)
        if count>=#chestSpots then grantCompletion(player) end
    end)
end

local portal=part("ReturnPortal",Vector3.new(8,1,8),Vector3.new(0,39,-145),Color3.fromRGB(137,98,255),Enum.Material.Neon)
portal.Shape=Enum.PartType.Cylinder
portal.Orientation=Vector3.new(0,0,90)
local pp=Instance.new("ProximityPrompt")
pp.ActionText="Return to Wonder Square";pp.ObjectText="Adventure Portal";pp.HoldDuration=.15;pp.Parent=portal
pp.Triggered:Connect(function(player)
    local char=player.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    local target=workspace:FindFirstChild("WonderSquareSpawn",true) or workspace:FindFirstChildWhichIsA("SpawnLocation",true)
    if hrp and target then hrp.CFrame=target.CFrame*CFrame.new(0,4,0) end
    player:SetAttribute("WP_ActiveAdventure", "")
end)

local function setupPlayer(player)
    resetRun(player)
    adventureConnections[player] = player:GetAttributeChangedSignal("WP_AdventureStartedAt"):Connect(function()
        if player:GetAttribute("WP_ActiveAdventure") == "TreasureIsland" then resetRun(player) end
    end)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in Players:GetPlayers() do setupPlayer(player) end

Players.PlayerRemoving:Connect(function(player)
    local uid=player.UserId
    collected[uid]=nil
    completed[uid]=nil
    if adventureConnections[player] then adventureConnections[player]:Disconnect(); adventureConnections[player]=nil end
    for key in pairs(lastTrigger) do
        if string.sub(key,1,#tostring(uid)+1)==tostring(uid)..":" then lastTrigger[key]=nil end
    end
end)

print("[WONDERPOCKET] Treasure Island run-safe multiplayer environment loaded")
