local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("WonderPocket_Remotes") or Instance.new("Folder")
remotes.Name = "WonderPocket_Remotes"
remotes.Parent = ReplicatedStorage

local WondiAction = remotes:FindFirstChild("WondiAction") or Instance.new("RemoteEvent")
WondiAction.Name = "WondiAction"
WondiAction.Parent = remotes

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

WondiAction.OnServerEvent:Connect(function(player, action)
    if not canUse(player) then return end
    local wondi=tostring(player:GetAttribute("WP_Wondi") or "Bubbi")
    action=tostring(action or "")
    if not (allowed[wondi] and allowed[wondi][action]) then return end
    player:SetAttribute("WP_LastWondiEmote",action)
    WondiAction:FireAllClients("EMOTE",player.UserId,wondi,action)
end)

Players.PlayerRemoving:Connect(function(player) cooldown[player.UserId]=nil end)
print("[WONDERPOCKET] Wondi interaction/emote system loaded")
