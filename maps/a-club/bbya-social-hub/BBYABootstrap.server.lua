local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local function ensure(parent, className, name)
	local existing = parent:FindFirstChild(name)
	if existing then return existing end
	local obj = Instance.new(className)
	obj.Name = name
	obj.Parent = parent
	return obj
end

local bbya = ensure(ReplicatedStorage, "Folder", "BBYA")
local remotes = ensure(bbya, "Folder", "Remotes")
ensure(bbya, "Folder", "Assets")
ensure(bbya, "Folder", "Shared")

for _, name in ipairs({
	"MusicCommand","LightingCommand","EventCommand","AnnouncementCommand",
	"TeleportRequest","SupportEffect","DanceCommand","SettingsCommand"
}) do
	ensure(remotes, "RemoteEvent", name)
end

ensure(ServerScriptService, "Folder", "BBYAServer")
ensure(StarterGui, "ScreenGui", "BBYA_UI")

local world = ensure(Workspace, "Folder", "BBYA_WORLD")
for _, name in ipairs({
	"Arrival","Lobby","MainClub","DJStage","Social","Bar","VIP","Queen",
	"Rooftop","Pool","Skyline","PhotoSpots","Navigation","LightingGroups"
}) do
	ensure(world, "Folder", name)
end

print("BBYA SOCIAL HUB hierarchy ready")
