local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local WondiAction = remotes:FindFirstChild("WondiAction") or Instance.new("RemoteEvent")
WondiAction.Name = "WondiAction"
WondiAction.Parent = remotes

local CriticalSave = ServerStorage:WaitForChild("WONDERPOCKET_CriticalSave",20)

local allowed = {
    Bubbi={Wave=true,Happy=true,Sleep=true},
    Flamo={Wave=true,Spark=true},
    Mossy={Wave=true,Bloom=true},
    Lumi={Wave=true,Glow=true},
    Zappy={Wave=true,Zap=true},
    Puffy={Wave=true,Float=true},
}

local cooldown = {}
local function canUse(player)
    local now=os.clock()
    local last=cooldown[player.UserId] or 0
    if now-last<1.2 then return false end
    cooldown[player.UserId]=now
    return true
end

local function triggerVisibleEmote(player,action)
    player:SetAttribute("WP_LastWondiEmote",action)
    player:SetAttribute("WP_WondiEmoteSeq",(tonumber(player:GetAttribute("WP_WondiEmoteSeq")) or 0)+1)
end

WondiAction.OnServerEvent:Connect(function(player, action)
    if not canUse(player) then return end
    local wondi=tostring(player:GetAttribute("ActiveWondi") or "Bubbi")
    action=tostring(action or "")
    if not (allowed[wondi] and allowed[wondi][action]) then return end

    triggerVisibleEmote(player,action)

    -- Tutorial progress is server-authoritative and only mutates in a safe loaded session.
    if player:GetAttribute("WP_TutorialStarted")==true
        and player:GetAttribute("WP_OnboardingComplete")~=true
        and player:GetAttribute("WP_DataLoaded")==true
        and player:GetAttribute("WP_DataReadOnly")~=true
        and player:GetAttribute("WP_DataLoadFailed")~=true
        and player:GetAttribute("WP_Tutorial_MetWondi")~=true then
        player:SetAttribute("WP_Tutorial_MetWondi",true)
        if CriticalSave then CriticalSave:Fire(player) end
    end

    WondiAction:FireAllClients("EMOTE",player.UserId,wondi,action)
end)

Players.PlayerRemoving:Connect(function(player) cooldown[player.UserId]=nil end)
print("[WONDERPOCKET] Canonical Wondi interaction + visible emote trigger loaded")
