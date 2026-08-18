local Players = game:GetService("Players")

local function attachPrompt(model)
    if not model:IsA("Model") or model:GetAttribute("WP_MeetPromptAttached") then return end
    local ownerUserId = tonumber(model:GetAttribute("OwnerUserId"))
    local body = model:FindFirstChild("Body") or model.PrimaryPart
    if not ownerUserId or not body or not body:IsA("BasePart") then return end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "WP_MeetWondiPrompt"
    prompt.ActionText = "Say Hi"
    prompt.ObjectText = tostring(model:GetAttribute("WondiId") or "Wondi")
    prompt.HoldDuration = .15
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = body

    prompt.Triggered:Connect(function(player)
        if player.UserId ~= ownerUserId then return end
        player:SetAttribute("WP_Tutorial_MetWondi", true)
        player:SetAttribute("WP_LastWondiEmote", "Wave")
        prompt.ActionText = "Hi!"
        task.delay(1.5, function()
            if prompt.Parent then prompt.ActionText = "Say Hi" end
        end)
    end)

    model:SetAttribute("WP_MeetPromptAttached", true)
end

local function bindFolder(folder)
    for _, child in ipairs(folder:GetChildren()) do task.defer(attachPrompt, child) end
    folder.ChildAdded:Connect(function(child)
        task.wait(.2)
        attachPrompt(child)
    end)
end

local function findFolder()
    local root = workspace:WaitForChild("WONDERPOCKET", 15)
    if not root then return nil end
    return root:WaitForChild("ActiveWondies", 15)
end

local folder = findFolder()
if folder then bindFolder(folder) else warn("[WONDERPOCKET] ActiveWondies folder missing for meet prompt") end

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("WP_Tutorial_MetWondi", false)
end)

print("[WONDERPOCKET] Wondi meet interaction loaded")
