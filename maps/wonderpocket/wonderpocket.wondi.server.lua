-- WONDERPOCKET Living Wondi Companion v1.0
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ROOT = workspace:FindFirstChild("WONDERPOCKET") or workspace
local folder = ROOT:FindFirstChild("ActiveWondies") or Instance.new("Folder")
folder.Name = "ActiveWondies"
folder.Parent = ROOT

local active = {}
local connections = {}
local runtime = {}

local BODY_SIZE = Vector3.new(2.6,2.4,2.6)
local palette = {
    Bubbi=Color3.fromRGB(118,224,145),
    Flamo=Color3.fromRGB(255,120,78),
    Mossy=Color3.fromRGB(92,178,96),
    Lumi=Color3.fromRGB(255,236,145),
    Zappy=Color3.fromRGB(114,188,255),
    Puffy=Color3.fromRGB(215,228,255),
}

local function makePart(name,size,color,shape)
    local part=Instance.new("Part")
    part.Name=name
    part.Size=size
    part.Color=color
    part.Material=Enum.Material.SmoothPlastic
    part.Anchored=true
    part.CanCollide=false
    part.CanTouch=false
    part.CanQuery=false
    if shape then part.Shape=shape end
    return part
end

local function remove(player)
    if active[player] then
        active[player]:Destroy()
        active[player]=nil
    end
    runtime[player]=nil
end

local function makeWondi(player)
    remove(player)
    if not player.Parent then return end

    local wondiId=tostring(player:GetAttribute("ActiveWondi") or "Bubbi")
    local baseColor=palette[wondiId] or palette.Bubbi
    local model=Instance.new("Model")
    model.Name=wondiId.."_"..player.UserId

    local body=makePart("Body",BODY_SIZE,baseColor,Enum.PartType.Ball)
    body.Parent=model

    local accent=makePart("Accent",Vector3.new(.38,1.15,.72),baseColor:Lerp(Color3.new(0,0,0),.18))
    accent.Parent=model

    local leftEar=makePart("LeftEar",Vector3.new(.5,.88,.5),baseColor:Lerp(Color3.new(1,1,1),.08),Enum.PartType.Ball)
    leftEar.Parent=model
    local rightEar=leftEar:Clone()
    rightEar.Name="RightEar"
    rightEar.Parent=model

    local eyeColor=Color3.fromRGB(35,48,62)
    local leftEye=makePart("LeftEye",Vector3.new(.26,.34,.14),eyeColor,Enum.PartType.Ball)
    leftEye.Parent=model
    local rightEye=leftEye:Clone()
    rightEye.Name="RightEye"
    rightEye.Parent=model

    local belly=makePart("Belly",Vector3.new(1.28,1.08,.16),baseColor:Lerp(Color3.new(1,1,1),.34),Enum.PartType.Ball)
    belly.Parent=model

    model.PrimaryPart=body
    model:SetAttribute("OwnerUserId",player.UserId)
    model:SetAttribute("WondiId",wondiId)
    model:SetAttribute("LivingCompanion",true)
    model.Parent=folder
    active[player]=model
    runtime[player]={
        phase=math.random()*math.pi*2,
        lastSeq=tonumber(player:GetAttribute("WP_WondiEmoteSeq")) or 0,
        emote=nil,
        emoteUntil=0,
    }
end

local function scheduleSpawn(player)
    task.spawn(function()
        local char=player.Character or player.CharacterAdded:Wait()
        if not char or not player.Parent then return end
        local hrp=char:WaitForChild("HumanoidRootPart",8)
        if not hrp then return end
        task.wait(.35)
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

local function updateEmote(player,data,now)
    local seq=tonumber(player:GetAttribute("WP_WondiEmoteSeq")) or 0
    if seq~=data.lastSeq then
        data.lastSeq=seq
        data.emote=tostring(player:GetAttribute("WP_LastWondiEmote") or "Wave")
        data.emoteUntil=now+1.65
    elseif now>=data.emoteUntil then
        data.emote=nil
    end
end

RunService.Heartbeat:Connect(function(dt)
    local now=os.clock()
    for player,model in pairs(active) do
        if not player.Parent or not model.Parent then
            remove(player)
        else
            local char=player.Character
            local rootPart=char and char:FindFirstChild("HumanoidRootPart")
            local body=model.PrimaryPart
            local data=runtime[player]
            if rootPart and body and data then
                updateEmote(player,data,now)

                local horizontalVelocity=Vector3.new(rootPart.AssemblyLinearVelocity.X,0,rootPart.AssemblyLinearVelocity.Z).Magnitude
                local idle=horizontalVelocity<1.1
                local hoverSpeed=idle and 2.0 or 3.0
                local hover=math.sin(now*hoverSpeed+data.phase)*(idle and .18 or .25)

                -- When the player pauses, Wondi floats slightly closer to their side.
                local backDistance=idle and 2.2 or 4.0
                local sideDistance=idle and 1.7 or 2.0
                local target=rootPart.Position-rootPart.CFrame.LookVector*backDistance+rootPart.CFrame.RightVector*sideDistance+Vector3.new(0,1.45+hover,0)

                local currentDistance=(body.Position-target).Magnitude
                local pos
                if currentDistance>45 then
                    pos=target
                else
                    local alpha=1-math.exp(-(idle and 4.2 or 6.2)*math.min(dt,.1))
                    pos=body.Position:Lerp(target,alpha)
                end

                local emote=data.emote
                local roll=0
                local extraY=0
                local pulse=1
                if emote=="Wave" then
                    roll=math.sin(now*11)*.18
                    extraY=math.abs(math.sin(now*8))*.24
                elseif emote=="Happy" then
                    extraY=math.abs(math.sin(now*9))*.42
                    pulse=1+.04*math.sin(now*10)
                elseif emote=="Sleep" then
                    roll=.12*math.sin(now*2)
                    extraY=-.18
                elseif emote=="Float" then
                    extraY=.62+.16*math.sin(now*4)
                elseif emote=="Spark" or emote=="Glow" or emote=="Zap" or emote=="Bloom" then
                    pulse=1+.055*math.sin(now*13)
                    extraY=.12*math.sin(now*8)
                end

                pos+=Vector3.new(0,extraY,0)
                local lookAt=rootPart.Position+Vector3.new(0,1.05,0)
                local bodyCF=CFrame.new(pos,lookAt)*CFrame.Angles(0,0,roll)
                body.Size=BODY_SIZE*pulse
                body.CFrame=bodyCF

                local accent=model:FindFirstChild("Accent")
                if accent then
                    accent.CFrame=bodyCF*CFrame.new(0,1.55,0)*CFrame.Angles(0,0,math.rad(18)+roll*.5)
                end
                local leftEar=model:FindFirstChild("LeftEar")
                local rightEar=model:FindFirstChild("RightEar")
                if leftEar then leftEar.CFrame=bodyCF*CFrame.new(-.72,1.02,.02)*CFrame.Angles(0,0,math.rad(-16)) end
                if rightEar then rightEar.CFrame=bodyCF*CFrame.new(.72,1.02,.02)*CFrame.Angles(0,0,math.rad(16)) end

                local eyeY=(emote=="Happy") and .33 or .26
                local eyeSquash=(emote=="Sleep") and .10 or .34
                local leftEye=model:FindFirstChild("LeftEye")
                local rightEye=model:FindFirstChild("RightEye")
                if leftEye then
                    leftEye.Size=Vector3.new(.26,eyeSquash,.14)
                    leftEye.CFrame=bodyCF*CFrame.new(-.48,eyeY,-1.16)
                end
                if rightEye then
                    rightEye.Size=Vector3.new(.26,eyeSquash,.14)
                    rightEye.CFrame=bodyCF*CFrame.new(.48,eyeY,-1.16)
                end
                local belly=model:FindFirstChild("Belly")
                if belly then belly.CFrame=bodyCF*CFrame.new(0,-.35,-1.15) end
            end
        end
    end
end)

print("[WONDERPOCKET] living Wondi companion + visible emote system loaded")
