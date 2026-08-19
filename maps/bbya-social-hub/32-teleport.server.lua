local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder",ReplicatedStorage);remotes.Name="BBYAClubRemotes"
local tp=remotes:FindFirstChild("Teleport") or Instance.new("RemoteEvent",remotes);tp.Name="Teleport"
local destinations={
 Arrival=CFrame.new(0,4,-58),
 MainClub=CFrame.new(0,4,-8),
 VIP=CFrame.new(0,28,-34),
 Queen=CFrame.new(-43,28,10),
 Rooftop=CFrame.new(0,48,-34),
 Pool=CFrame.new(0,48,-12),
 Basement=CFrame.new(0,-12,0),
}
tp.OnServerEvent:Connect(function(player,key)
 local cf=destinations[key];if not cf then return end
 local char=player.Character;if not char then return end
 local root=char:FindFirstChild("HumanoidRootPart");if root then root.CFrame=cf end
end)
