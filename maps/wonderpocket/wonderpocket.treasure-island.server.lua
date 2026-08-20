local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local CriticalSave = ServerStorage:WaitForChild("WONDERPOCKET_CriticalSave",20)
local EconomyAudit = ServerStorage:WaitForChild("WONDERPOCKET_EconomyAudit",20)
local DURATION_SECONDS = 240

local root = workspace:FindFirstChild("TreasureIsland") or Instance.new("Folder")
root.Name = "TreasureIsland"
root.Parent = workspace

local function part(name,size,pos,color,material)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.Position=pos;p.Anchored=true;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Parent=root
    return p
end

part("IslandBase",Vector3.new(85,8,85),Vector3.new(0,34,-185),Color3.fromRGB(78,158,79),Enum.Material.Grass)
part("BeachRing",Vector3.new(95,3,95),Vector3.new(0,28,-185),Color3.fromRGB(239,207,137),Enum.Material.Sand)
local water=part("Lagoon",Vector3.new(160,2,160),Vector3.new(0,25,-185),Color3.fromRGB(66,182,224),Enum.Material.Glass)
water.Transparency=.35;water.CanCollide=false

for i=1,16 do
    local angle=(i/16)*math.pi*2
    local r=30+((i%3)*5)
    local x,z=math.cos(angle)*r,math.sin(angle)*r
    local trunk=part("PalmTrunk",Vector3.new(2,10,2),Vector3.new(x,43,z-185),Color3.fromRGB(120,82,48),Enum.Material.Wood)
    trunk.Orientation=Vector3.new(0,math.deg(-angle),math.sin(i)*7)
    local crown=part("PalmCrown",Vector3.new(8,4,8),Vector3.new(x,49,z-185),Color3.fromRGB(51,143,74),Enum.Material.Grass)
    crown.Shape=Enum.PartType.Ball
end

for i,pos in ipairs({Vector3.new(-18,39,-190),Vector3.new(18,39,-177),Vector3.new(-4,39,-162),Vector3.new(14,39,-205)}) do
    local r=part("AncientRuins"..i,Vector3.new(7,10,5),pos,Color3.fromRGB(157,147,118),Enum.Material.Slate)
    r.Orientation=Vector3.new(0,i*23,0)
end

local chestSpots={Vector3.new(-25,40,-205),Vector3.new(22,40,-199),Vector3.new(0,40,-168),Vector3.new(-20,40,-174),Vector3.new(25,40,-178)}
local collected={}
local completed={}
local lastTrigger={}
local adventureConnections={}
local protectionConnections={}
local runToken={}
local deadlines={}

local function protected(player)
    return player:GetAttribute("WP_DataReadOnly")==true
        or player:GetAttribute("WP_DataLoadFailed")==true
        or player:GetAttribute("WP_DataLoaded")~=true
end

local function clearRunState(player)
    local uid=player.UserId
    collected[uid]={}
    completed[uid]=nil
    player:SetAttribute("WP_TreasureProgress",0)
    player:SetAttribute("WP_TreasureIslandComplete",false)
    player:SetAttribute("WP_AdventureTimeExpired",false)
    player:SetAttribute("WP_AdventureProtectedAbort",false)
end

local function expireRun(player,token)
    local uid=player.UserId
    if runToken[uid]~=token or player:GetAttribute("WP_ActiveAdventure")~="TreasureIsland" then return end
    player:SetAttribute("WP_AdventureTimeExpired",true)
    player:SetAttribute("WP_ActiveAdventure","")
end

local function beginRun(player)
    if protected(player) then return end
    local uid=player.UserId
    clearRunState(player)
    runToken[uid]=(runToken[uid] or 0)+1
    local token=runToken[uid]
    deadlines[uid]=os.time()+DURATION_SECONDS
    player:SetAttribute("WP_AdventureDeadline",deadlines[uid])
    task.delay(DURATION_SECONDS+1,function()
        if player.Parent then expireRun(player,token) end
    end)
end

local function abortProtectedRun(player)
    if not protected(player) or player:GetAttribute("WP_ActiveAdventure")~="TreasureIsland" then return end
    local uid=player.UserId
    runToken[uid]=(runToken[uid] or 0)+1
    deadlines[uid]=nil
    player:SetAttribute("WP_AdventureProtectedAbort",true)
    player:SetAttribute("WP_ActiveAdventure","")
end

local function getState(player)
    local uid=player.UserId
    collected[uid]=collected[uid] or {}
    return collected[uid]
end

local function grantCompletion(player)
    if protected(player) then return end
    local uid=player.UserId
    if completed[uid] then return end
    completed[uid]=true
    player:SetAttribute("Coins",(tonumber(player:GetAttribute("Coins")) or 0)+120)
    player:SetAttribute("Stars",(tonumber(player:GetAttribute("Stars")) or 0)+1)
    player:SetAttribute("WP_TreasureIslandComplete",true)
    player:SetAttribute("WP_AdventureCompletions",(tonumber(player:GetAttribute("WP_AdventureCompletions")) or 0)+1)
    player:SetAttribute("WP_ActiveAdventure","")
    if EconomyAudit then EconomyAudit:Fire(player,"TREASURE_ISLAND","TreasureIsland",120,1,0) end
    if CriticalSave then CriticalSave:Fire(player) end
end

for i,pos in ipairs(chestSpots) do
    local chest=part("Treasure"..i,Vector3.new(4,3,3),pos,Color3.fromRGB(173,93,43),Enum.Material.Wood)
    local prompt=Instance.new("ProximityPrompt")
    prompt.ActionText="Collect Treasure";prompt.ObjectText="Wonder Chest";prompt.HoldDuration=.25;prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt.Parent=chest
    prompt.Triggered:Connect(function(player)
        if protected(player) then return end
        if player:GetAttribute("WP_ActiveAdventure")~="TreasureIsland" then return end
        local uid=player.UserId
        if os.time()>(deadlines[uid] or 0) then
            expireRun(player,runToken[uid])
            return
        end
        local now=os.clock()
        local triggerKey=tostring(uid)..":"..i
        if lastTrigger[triggerKey] and now-lastTrigger[triggerKey]<.75 then return end
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
portal.Shape=Enum.PartType.Cylinder;portal.Orientation=Vector3.new(0,0,90)
local pp=Instance.new("ProximityPrompt")
pp.ActionText="Return to Wonder Square";pp.ObjectText="Adventure Portal";pp.HoldDuration=.15;pp.Parent=portal
pp.Triggered:Connect(function(player)
    local char=player.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    local target=workspace:FindFirstChild("WonderSquareSpawn",true) or workspace:FindFirstChildWhichIsA("SpawnLocation",true)
    if hrp and target then hrp.CFrame=target.CFrame*CFrame.new(0,4,0) end
    player:SetAttribute("WP_ActiveAdventure","")
end)

local function setupPlayer(player)
    clearRunState(player)
    adventureConnections[player]=player:GetAttributeChangedSignal("WP_AdventureStartedAt"):Connect(function()
        if player:GetAttribute("WP_ActiveAdventure")=="TreasureIsland" then beginRun(player) end
    end)
    protectionConnections[player]={}
    for _,attribute in ipairs({"WP_DataReadOnly","WP_DataLoadFailed","WP_DataLoaded"}) do
        table.insert(protectionConnections[player],player:GetAttributeChangedSignal(attribute):Connect(function()
            abortProtectedRun(player)
        end))
    end
end

Players.PlayerAdded:Connect(setupPlayer)
for _,player in Players:GetPlayers() do setupPlayer(player) end
Players.PlayerRemoving:Connect(function(player)
    local uid=player.UserId
    collected[uid]=nil;completed[uid]=nil;runToken[uid]=nil;deadlines[uid]=nil
    if adventureConnections[player] then adventureConnections[player]:Disconnect();adventureConnections[player]=nil end
    for _,connection in ipairs(protectionConnections[player] or {}) do connection:Disconnect() end
    protectionConnections[player]=nil
    for key in pairs(lastTrigger) do
        if string.sub(key,1,#tostring(uid)+1)==tostring(uid)..":" then lastTrigger[key]=nil end
    end
end)

print("[WONDERPOCKET] Protected timed server-authoritative Treasure Island loaded")
