-- BBYA SOCIAL HUB — MUSIC CATALOG RESET AUTHORITY v2
-- Hard reset requested by owner: no active tracks in Main / Underground / Funkot / VIP.
-- Audio-only engines/recovery are disabled; ClubSystems stays alive because it also owns non-audio support logic.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ServerScriptService=game:GetService("ServerScriptService")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")

ReplicatedStorage:SetAttribute("BBYAMusicCatalogReset",true)
ReplicatedStorage:SetAttribute("BBYAMusicCatalogVersion","RESET_EMPTY_V2")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local function ensureRemote(name,className)
 local x=remotes:FindFirstChild(name)
 if x and x.ClassName~=className then x:Destroy();x=nil end
 if not x then x=Instance.new(className);x.Name=name;x.Parent=remotes end
 return x
end
ensureRemote("Music","RemoteEvent")
ensureRemote("State","RemoteEvent")
ensureRemote("FunkotMusic","RemoteEvent")
ensureRemote("InternalMusic","BindableEvent")
ensureRemote("BasementMusic","BindableEvent")

local function ensureGroup(name,venue)
 local g=SoundService:FindFirstChild(name)
 if g and not g:IsA("SoundGroup") then g:Destroy();g=nil end
 if not g then g=Instance.new("SoundGroup");g.Name=name;g.Parent=SoundService end
 g.Volume=0
 g:SetAttribute("Venue",venue)
 g:SetAttribute("BBYALocalZoneOnly",true)
 g:SetAttribute("PlaylistReady",false)
 g:SetAttribute("PlaylistCount",0)
 g:SetAttribute("RecoveryActive",false)
 g:SetAttribute("RecoveryFallbackCount",0)
 g:SetAttribute("MusicCatalogState","RESET_EMPTY")
 return g
end

local groups={
 ["BBYAClubMaster"]=ensureGroup("BBYAClubMaster","MAIN"),
 ["BBYABasementMaster"]=ensureGroup("BBYABasementMaster","UNDERGROUND"),
 ["BBYAFunkotMaster"]=ensureGroup("BBYAFunkotMaster","FUNKOT"),
 ["BBYAVIPMaster"]=ensureGroup("BBYAVIPMaster","VIP"),
 ["BBYASkateparkMaster"]=ensureGroup("BBYASkateparkMaster","SKATEPARK"),
 ["BBYARooftopMaster"]=ensureGroup("BBYARooftopMaster","ROOFTOP"),
}

local knownSounds={
 BBYAClubDeckA=true,BBYAClubDeckB=true,BBYABasementDeckA=true,BBYABasementDeckB=true,
 BBYAFunkotDeck=true,BBYAFunkotClubFeed=true,BBYAMainPublicFallbackV4=true,
 BBYAUndergroundBreakbeatFallbackV4=true,BBYAClubFeed=true,BBYAClubSound=true,
}
local function controlledSound(s)
 if not s:IsA("Sound") then return false end
 if knownSounds[s.Name] or s:GetAttribute("BBYARecovery")==true then return true end
 local sg=s.SoundGroup
 return sg and groups[sg.Name]~=nil or false
end
local function scrubSound(s,destroy)
 if not controlledSound(s) then return end
 pcall(function()s:Stop()end)
 pcall(function()s.SoundId=""end)
 pcall(function()s.TimePosition=0 end)
 pcall(function()s.Volume=0 end)
 if destroy then pcall(function()s:Destroy()end) end
end

local function scrubWorkspaceVIP()
 local vipGroup=groups.BBYAVIPMaster
 for _,o in ipairs(Workspace:GetDescendants()) do
  if o:IsA("Sound") and o.Name=="CornerSpatialAudio" then
   pcall(function()o:Stop();o.SoundId="";o.TimePosition=0;o.Volume=0;o.SoundGroup=vipGroup end)
  end
 end
end

-- These are audio-only authorities. ClubSystems is intentionally NOT disabled because SUPPORT still depends on it.
local engineNames={"BasementIndoAutoDJ","FunkotVenueMusicV2","AudioWatchdog","AudioHealthGuardV3"}
local function disableOldAudioEngines()
 for _,name in ipairs(engineNames) do
  local s=ServerScriptService:FindFirstChild(name)
  if s and s:IsA("BaseScript") and s~=script then pcall(function()s.Enabled=false end) end
 end
end

local resetActive=true
SoundService.DescendantAdded:Connect(function(o)
 if not resetActive or not o:IsA("Sound") then return end
 task.defer(function()
  if o.Parent and controlledSound(o) then scrubSound(o,true) end
 end)
end)
Workspace.DescendantAdded:Connect(function(o)
 if not resetActive or not o:IsA("Sound") or o.Name~="CornerSpatialAudio" then return end
 task.defer(function()
  if o.Parent then pcall(function()o:Stop();o.SoundId="";o.Volume=0;o.SoundGroup=groups.BBYAVIPMaster end) end
 end)
end)

local function applyReset()
 disableOldAudioEngines()
 for _,o in ipairs(SoundService:GetDescendants()) do
  if o:IsA("Sound") and controlledSound(o) then scrubSound(o,true) end
 end
 scrubWorkspaceVIP()
 for _,g in pairs(groups) do
  g.Volume=0;g:SetAttribute("PlaylistReady",false);g:SetAttribute("PlaylistCount",0);g:SetAttribute("RecoveryActive",false);g:SetAttribute("RecoveryFallbackCount",0);g:SetAttribute("MusicCatalogState","RESET_EMPTY")
 end
 Workspace:SetAttribute("BBYAMusicCatalogReset",true)
end

-- Reset immediately. Repeat after legacy delayed Funkot startup windows to guarantee zero music.
task.defer(applyReset)
task.delay(4,applyReset)
task.delay(8,applyReset)

print("[BBYA] Music Catalog Reset v2 armed: MAIN / UNDERGROUND / FUNKOT / VIP = 0 tracks; SUPPORT preserved")
