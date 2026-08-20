local ReplicatedStorage=game:GetService("ReplicatedStorage")
local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder",ReplicatedStorage)
remotes.Name="BBYAClubRemotes"
local tp=remotes:FindFirstChild("Teleport") or Instance.new("RemoteEvent",remotes)
tp.Name="Teleport"

-- Only destinations with known walkable geometry are exposed in the unified UI.
-- QueenSkybox is intentionally omitted for now: the current upper-level asset is still a solid placeholder shell.
local destinations={
 Arrival=CFrame.new(0,4,-58),
 Photo=CFrame.new(-39,3,-25),
 LookLab=CFrame.new(-38,3,-4),
 MainClub=CFrame.new(3,3,11),
 VIP=CFrame.new(46,27,2),
 Rooftop=CFrame.new(43,47,-28),
 Pool=CFrame.new(0,47,-12),
 Basement=CFrame.new(0,-12,0),
}

tp.OnServerEvent:Connect(function(player,key)
 local cf=destinations[key]
 if not cf then return end
 local char=player.Character
 if not char then return end
 local root=char:FindFirstChild("HumanoidRootPart")
 if root then root.CFrame=cf end
end)

print("[BBYA] Verified travel destinations online; invalid Queen placeholder removed")