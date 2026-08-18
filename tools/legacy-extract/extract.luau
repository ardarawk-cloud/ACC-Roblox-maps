local SerializationService = game:GetService("SerializationService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local bundle = Instance.new("Folder")
bundle.Name = "ACC_Legacy_UI_Music_Lighting"

local uiFolder = Instance.new("Folder")
uiFolder.Name = "UI"
uiFolder.Parent = bundle

local audioFolder = Instance.new("Folder")
audioFolder.Name = "Audio"
audioFolder.Parent = bundle

local lightingFolder = Instance.new("Folder")
lightingFolder.Name = "Lighting"
lightingFolder.Parent = bundle

local skipped = {}
local function cloneSafe(source, parent)
	local ok, clone = pcall(function()
		return source:Clone()
	end)
	if not ok or not clone then
		table.insert(skipped, source:GetFullName())
		return false
	end
	pcall(function()
		clone:SetAttribute("ACC_OriginalPath", source:GetFullName())
	end)
	clone.Parent = parent
	return true
end

-- Preserve all StarterGui material exactly as authored.
for _, child in StarterGui:GetChildren() do
	cloneSafe(child, uiFolder)
end

-- Also preserve UI templates that live outside StarterGui.
local extraUiFolder = Instance.new("Folder")
extraUiFolder.Name = "Extra_UI_Roots"
extraUiFolder.Parent = uiFolder

local function hasGuiAncestor(instance)
	local p = instance.Parent
	while p and p ~= game do
		if p:IsA("LayerCollector") or p:IsA("GuiObject") then
			return true
		end
		p = p.Parent
	end
	return false
end

for _, obj in game:GetDescendants() do
	if not obj:IsDescendantOf(StarterGui) then
		local isUiRoot = obj:IsA("LayerCollector") or obj:IsA("GuiObject")
		if isUiRoot and not hasGuiAncestor(obj) then
			cloneSafe(obj, extraUiFolder)
		end
	end
end

-- Preserve SoundService structure first.
local soundServiceFolder = Instance.new("Folder")
soundServiceFolder.Name = "SoundService_Children"
soundServiceFolder.Parent = audioFolder
for _, child in SoundService:GetChildren() do
	cloneSafe(child, soundServiceFolder)
end

-- Preserve sounds/audio players that are placed elsewhere in the DataModel.
local externalAudioFolder = Instance.new("Folder")
externalAudioFolder.Name = "External_Audio"
externalAudioFolder.Parent = audioFolder

local manifestSounds = {}
for _, obj in game:GetDescendants() do
	local isSound = obj:IsA("Sound")
	local isAudioPlayer = obj.ClassName == "AudioPlayer"
	if (isSound or isAudioPlayer) and not obj:IsDescendantOf(SoundService) then
		cloneSafe(obj, externalAudioFolder)
	end
	if isSound then
		local item = {
			name = obj.Name,
			path = obj:GetFullName(),
			className = obj.ClassName,
		}
		pcall(function() item.soundId = obj.SoundId end)
		pcall(function() item.volume = obj.Volume end)
		pcall(function() item.looped = obj.Looped end)
		pcall(function() item.playbackSpeed = obj.PlaybackSpeed end)
		table.insert(manifestSounds, item)
	end
end

-- Preserve Lighting children such as Atmosphere, Sky, Bloom, ColorCorrection, etc.
local lightingChildren = Instance.new("Folder")
lightingChildren.Name = "Lighting_Children"
lightingChildren.Parent = lightingFolder
for _, child in Lighting:GetChildren() do
	cloneSafe(child, lightingChildren)
end

-- Preserve Lighting service properties as attributes on a Configuration object.
local lightingConfig = Instance.new("Configuration")
lightingConfig.Name = "Lighting_Service_Properties"
lightingConfig.Parent = lightingFolder

local lightingProperties = {
	"Brightness",
	"ClockTime",
	"TimeOfDay",
	"Ambient",
	"OutdoorAmbient",
	"ColorShift_Top",
	"ColorShift_Bottom",
	"ExposureCompensation",
	"EnvironmentDiffuseScale",
	"EnvironmentSpecularScale",
	"GeographicLatitude",
	"GlobalShadows",
	"ShadowSoftness",
	"FogColor",
	"FogStart",
	"FogEnd",
}

local lightingManifest = {}
for _, propertyName in lightingProperties do
	local ok, value = pcall(function()
		return Lighting[propertyName]
	end)
	if ok then
		pcall(function()
			lightingConfig:SetAttribute(propertyName, value)
		end)
		local valueType = typeof(value)
		if valueType == "Color3" then
			lightingManifest[propertyName] = { r = value.R, g = value.G, b = value.B }
		elseif valueType == "number" or valueType == "boolean" or valueType == "string" then
			lightingManifest[propertyName] = value
		else
			lightingManifest[propertyName] = tostring(value)
		end
	end
end

pcall(function()
	lightingConfig:SetAttribute("Technology", tostring(Lighting.Technology))
	lightingManifest.Technology = tostring(Lighting.Technology)
end)

-- Clouds live under Terrain rather than Lighting, but they materially affect the scene look.
local cloudsFolder = Instance.new("Folder")
cloudsFolder.Name = "Clouds"
cloudsFolder.Parent = lightingFolder
for _, obj in game:GetDescendants() do
	if obj.ClassName == "Clouds" then
		cloneSafe(obj, cloudsFolder)
	end
end

local manifest = {
	sourceUniverseId = game.GameId,
	sourcePlaceId = game.PlaceId,
	uiStarterGuiTopLevelCount = #StarterGui:GetChildren(),
	soundCount = #manifestSounds,
	sounds = manifestSounds,
	lighting = lightingManifest,
	skippedClonePaths = skipped,
}

local binary = SerializationService:SerializeInstancesAsync({ bundle })
local manifestJson = HttpService:JSONEncode(manifest)

return {
	BinaryOutput = binary,
	ReturnValues = { manifestJson },
}
