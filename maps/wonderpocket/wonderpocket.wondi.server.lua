-- WONDERPOCKET Wondi Follow System v0.8
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ROOT = workspace:FindFirstChild("WONDERPOCKET") or workspace
local folder = ROOT:FindFirstChild("ActiveWondies") or Instance.new("Folder")
folder.Name = "ActiveWondies"
folder.Parent = ROOT

local active = {}
local connections = {}

local palette = {
    Bubbi=Color3.fromRGB(118,224,145),
    Flamo=Color3.fromRGB(255,120,78),
    Mossy=Color3.fromRGB(92,178,96),
    Lumi=Color3.fromRGB(255,236,145),
    Zappy=Color3.fromRGB(114,188,255),
    Puffy=Color3.fromRGB(215,228,255),
}

local function remove(player)
    if active[player] then
        active[player]:Destroy()
        active[player]=nil
    end
end

local function makeWondi(player)
    remove(player)
    if not player.Parent then return end

    local wondiId=tostring(player:GetAttribute("ActiveWondi") or "Bubbi")
    local model=Instance.new("Model")
    model.Name=wondiId.."_"..player.UserId

    local body=Instance.new("Part")
    body.Name="Body"
    body.Shape=Enum.PartType.Ball
    body.Size=Vector3.new(2.6,2.4,2.6)
    body.Material=Enum.Material.SmoothPlastic
    body.Color=palette[wondiId] or palette.Bubbi
    body.Anchored=true
    body.CanCollide=false
    body.CanTouch=false
    body.Parent=model

    local accent=Instance.new("Part")
    accent.Name="Accent"
    accent.Size=Vector3.new(.35,1.2,.75)
    accent.Material=Enum.Material.SmoothPlastic
    accent.Color=body.Color:Lerp(Color3.new(0,0,0),.18)
    accent.Anchored=true
    accent.CanCollide=false
    accent.CanTouch=false
    accent.Parent=model

    model.PrimaryPart=body
    model:SetAttribute("OwnerUserId",player.UserId)
    model:SetAttribute("WondiId",wondiId)
    model.Parent=folder
    active[player]=model
end

local function scheduleSpawn(player)
    task.spawn(function()
        local char=player.Character or player.CharacterAdded:Wait()
        if not char or not player.Parent then return end
        local hrp=char:WaitForChild("HumanoidRootPart",8)
        if not hrp then return end
        task.wait(.4)
        if player.Parent and player.Character==char then makeWondi(player) end
    end)
end

local function bindPlayer(player)
    if connections[player] then return end
    connections[player]={}
    table.insert(connections[player],player.CharacterAdded:Connect(function() scheduleSpawn(player) end))
    table.insert(connections[player],player.CharacterRemoving:Connect(function() remove(player) end))
    table.insert(connections[player],player:GetAttributeChangedSignal("ActiveWondi"):Connect(function()
        if player.Character then scheduleSpawn(player) end
    end))
    if player.Character then scheduleSpawn(player) end
end

Players.PlayerAdded:Connect(bindPlayer)
for _,player in Players:GetPlayers() do bindPlayer(player) end

Players.PlayerRemoving:Connect(function(player)
    remove(player)
    if connections[player] then
        for _,c in ipairs(connections[player]) do c:Disconnect() end
        connections[player]=nil
    end
end)

RunService.Heartbeat:Connect(function(dt)
    for player,model in pairs(active) do
        if not player.Parent or not model.Parent then
            remove(player)
        else
            local char=player.Character
            local rootPart=char and char:FindFirstChild("HumanoidRootPart")
            local body=model.PrimaryPart
            if rootPart and body then
                local t=os.clock()
                local target=rootPart.Position-rootPart.CFrame.LookVector*4+rootPart.CFrame.RightVector*2+Vector3.new(0,1.4+math.sin(t*3)*.25,0)
                local alpha=1-math.exp(-6*math.min(dt,.1))
                local pos=body.Position:Lerp(target,alpha)
                body.CFrame=CFrame.new(pos,rootPart.Position+Vector3.new(0,1,0))
                local accent=model:FindFirstChild("Accent")
                if accent then accent.CFrame=body.CFrame*CFrame.new(0,1.55,0)*CFrame.Angles(0,0,math.rad(20)) end
            end
        end
    end
end)

print("[WONDERPOCKET] Wondi reconnect-safe follow system loaded")
