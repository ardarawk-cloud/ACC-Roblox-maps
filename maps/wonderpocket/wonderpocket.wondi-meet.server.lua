local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local CriticalSave = ServerStorage:WaitForChild("WONDERPOCKET_CriticalSave",20)

local function triggerVisibleWave(player)
    player:SetAttribute("WP_LastWondiEmote","Wave")
    player:SetAttribute("WP_WondiEmoteSeq",(tonumber(player:GetAttribute("WP_WondiEmoteSeq")) or 0)+1)
end

local function attachPrompt(model)
    if not model:IsA("Model") or model:GetAttribute("WP_MeetPromptAttached") then return end
    local ownerUserId=tonumber(model:GetAttribute("OwnerUserId"))
    local body=model:FindFirstChild("Body") or model.PrimaryPart
    if not ownerUserId or not body or not body:IsA("BasePart") then return end

    local prompt=Instance.new("ProximityPrompt")
    prompt.Name="WP_MeetWondiPrompt"
    prompt.ActionText="Say Hi"
    prompt.ObjectText=tostring(model:GetAttribute("WondiId") or "Wondi")
    prompt.HoldDuration=.15
    prompt.MaxActivationDistance=10
    prompt.RequiresLineOfSight=false
    prompt.Enabled=false
    prompt.Parent=body

    local ownerConnections={}
    local function disconnectOwner()
        for _,connection in ipairs(ownerConnections) do connection:Disconnect() end
        table.clear(ownerConnections)
    end

    local function syncPrompt()
        local owner=Players:GetPlayerByUserId(ownerUserId)
        prompt.Enabled = owner ~= nil
            and owner:GetAttribute("WP_DataLoaded")==true
            and owner:GetAttribute("WP_DataReadOnly")~=true
            and owner:GetAttribute("WP_DataLoadFailed")~=true
            and owner:GetAttribute("WP_Tutorial_MetWondi") ~= true
    end

    local function bindOwner()
        local owner=Players:GetPlayerByUserId(ownerUserId)
        if not owner then return end
        disconnectOwner()
        for _,attribute in ipairs({"WP_Tutorial_MetWondi","WP_DataLoaded","WP_DataReadOnly","WP_DataLoadFailed"}) do
            table.insert(ownerConnections,owner:GetAttributeChangedSignal(attribute):Connect(syncPrompt))
        end
        syncPrompt()
    end

    prompt.Triggered:Connect(function(player)
        if player.UserId~=ownerUserId or player:GetAttribute("WP_DataLoaded")~=true then return end
        if player:GetAttribute("WP_DataReadOnly")==true or player:GetAttribute("WP_DataLoadFailed")==true then return end
        if player:GetAttribute("WP_Tutorial_MetWondi")~=true then
            player:SetAttribute("WP_Tutorial_MetWondi",true)
            if CriticalSave then CriticalSave:Fire(player) end
        end
        triggerVisibleWave(player)
        prompt.Enabled=false
    end)

    task.spawn(function()
        -- Keep the meet prompt synchronized even when the initial DataStore read is slow.
        -- Stop only when the owner leaves or the authoritative main data load fails closed.
        while prompt.Parent do
            local owner=Players:GetPlayerByUserId(ownerUserId)
            if not owner then return end
            if owner:GetAttribute("WP_DataLoadFailed")==true then
                syncPrompt()
                return
            end
            if owner:GetAttribute("WP_DataLoaded")==true then
                bindOwner()
                return
            end
            task.wait(.25)
        end
    end)

    prompt.AncestryChanged:Connect(function(_,parent)
        if parent==nil then disconnectOwner() end
    end)

    model:SetAttribute("WP_MeetPromptAttached",true)
end

local function bindFolder(folder)
    for _,child in ipairs(folder:GetChildren()) do task.defer(attachPrompt,child) end
    folder.ChildAdded:Connect(function(child) task.wait(.2);attachPrompt(child) end)
end

local function findFolder()
    local root=workspace:WaitForChild("WONDERPOCKET",15)
    if not root then return nil end
    return root:WaitForChild("ActiveWondies",15)
end

local folder=findFolder()
if folder then bindFolder(folder) else warn("[WONDERPOCKET] ActiveWondies folder missing for meet prompt") end

Players.PlayerAdded:Connect(function(player)
    task.spawn(function()
        while player.Parent and player:GetAttribute("WP_DataLoaded")~=true do
            if player:GetAttribute("WP_DataLoadFailed")==true then return end
            task.wait(.25)
        end
        if player.Parent and player:GetAttribute("WP_Tutorial_MetWondi")==nil then
            player:SetAttribute("WP_Tutorial_MetWondi",false)
        end
    end)
end)

print("[WONDERPOCKET] Read-only synchronized tutorial Wondi meet + visible Wave loaded")
