-- BBYA SOCIAL HUB — MIXED MUSIC RESET AUTHORITY v4
-- MAIN stays reset; UNDERGROUND + FUNKOT runtime libraries are explicitly active.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ServerScriptService=game:GetService("ServerScriptService")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")
local UNDERGROUND_REBUILD_ENABLED=true
local FUNKOT_RUNTIME_ENABLED=true

ReplicatedStorage:SetAttribute("BBYAMusicCatalogReset",true)
ReplicatedStorage:SetAttribute("BBYAMusicCatalogVersion","RESET_WITH_UNDERGROUND_FUNKOT_V4")
ReplicatedStorage:SetAttribute("BBYAUndergroundPlaylistEnabled",UNDERGROUND_REBUILD_ENABLED)
-- Declare Funkot active immediately so clients never see the old reset state while
-- 93-funkot-music.server.lua is starting. 93 remains the single playback authority.
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistEnabled",FUNKOT_RUNTIME_ENABLED)

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

local function ensureGroup(name,venue,active)
 local g=SoundService:FindFirstChild(name)
 if g and not g:IsA("SoundGroup") then g:Destroy();g=nil end
 if not g then g=Instance.new("SoundGroup");g.Name=name;g.Parent=SoundService end
 if active then
  g.Volume=1
  g:SetAttribute("Venue",venue)
  g:SetAttribute("BBYALocalZoneOnly",true)
  g:SetAttribute("PlaylistReady",true)
  g:SetAttribute("MusicCatalogState",venue=="FUNKOT" and "FUNKOT_ACTIVE" or "OWNER_LIBRARY_ACTIVE")
  return g
 end
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
 ["BBYAClubMaster"]=ensureGroup("BBYAClubMaster","MAIN",false),
 ["BBYABasementMaster"]=ensureGroup("BBYABasementMaster","UNDERGROUND",UNDERGROUND_REBUILD_ENABLED),
 ["BBYAFunkotMaster"]=ensureGroup("BBYAFunkotMaster","FUNKOT",FUNKOT_RUNTIME_ENABLED),
 ["BBYAVIPMaster"]=ensureGroup("BBYAVIPMaster","VIP",false),
 ["BBYASkateparkMaster"]=ensureGroup("BBYASkateparkMaster","SKATEPARK",false),
 ["BBYARooftopMaster"]=ensureGroup("BBYARooftopMaster","ROOFTOP",false),
}

local knownSounds={
 BBYAClubDeckA=true,BBYAClubDeckB=true,BBYABasementDeckA=true,BBYABasementDeckB=true,
 BBYAFunkotDeck=true,BBYAFunkotClubFeed=true,BBYAMainPublicFallbackV4=true,
 BBYAUndergroundBreakbeatFallbackV4=true,BBYAClubFeed=true,BBYAClubSound=true,
}
local function controlledSound(s)
 if not s:IsA("Sound") then return false end
 local sg=s.SoundGroup
 if UNDERGROUND_REBUILD_ENABLED and sg and sg.Name=="BBYABasementMaster" then return false end
 -- Funkot is no longer a reset channel. Never scrub sounds owned by the canonical
 -- Funkot runtime group; 93-funkot-music.server.lua controls their lifecycle.
 if FUNKOT_RUNTIME_ENABLED and sg and sg.Name=="BBYAFunkotMaster" then return false end
 if knownSounds[s.Name] or s:GetAttribute("BBYARecovery")==true then return true end
 if sg and sg.Name=="BBYAVIPMaster" and ReplicatedStorage:GetAttribute("BBYAVIPTrack01Enabled")==true then return false end
 return sg and groups[sg.Name]~=nil or false
end
local function scrubSound(s,destroy)
 if not controlledSound(s) then return end
 pcall(function()s:Stop()end);pcall(function()s.SoundId=""end);pcall(function()s.TimePosition=0 end);pcall(function()s.Volume=0 end)
 if destroy then pcall(function()s:Destroy()end) end
end
local function scrubWorkspaceVIP()
 if ReplicatedStorage:GetAttribute("BBYAVIPTrack01Enabled")==true then return end
 local vipGroup=groups.BBYAVIPMaster
 for _,o in ipairs(Workspace:GetDescendants()) do
  if o:IsA("Sound") and o.Name=="CornerSpatialAudio" then pcall(function()o:Stop();o.SoundId="";o.TimePosition=0;o.Volume=0;o.SoundGroup=vipGroup end) end
 end
end

local engineNames={"BasementIndoAutoDJ","FunkotVenueMusicV2","AudioWatchdog","AudioHealthGuardV3"}
local function disableOldAudioEngines()
 for _,name in ipairs(engineNames) do
  local keepUnderground=UNDERGROUND_REBUILD_ENABLED and name=="BasementIndoAutoDJ"
  local keepFunkot=FUNKOT_RUNTIME_ENABLED and name=="FunkotVenueMusicV2"
  if not keepUnderground and not keepFunkot then
   local s=ServerScriptService:FindFirstChild(name)
   if s and s:IsA("BaseScript") and s~=script then pcall(function()s.Disabled=true end) end
  end
 end
end

local resetActive=true
SoundService.DescendantAdded:Connect(function(o)
 if not resetActive or not o:IsA("Sound") then return end
 task.defer(function()if o.Parent and controlledSound(o) then scrubSound(o,true) end end)
end)
Workspace.DescendantAdded:Connect(function(o)
 if not resetActive or not o:IsA("Sound") or o.Name~="CornerSpatialAudio" then return end
 task.defer(function()if o.Parent then pcall(function()o:Stop();o.SoundId="";o.Volume=0;o.SoundGroup=groups.BBYAVIPMaster end) end end)
end)

local function applyReset()
 disableOldAudioEngines()
 for _,o in ipairs(SoundService:GetDescendants()) do if o:IsA("Sound") and controlledSound(o) then scrubSound(o,true) end end
 scrubWorkspaceVIP()
 for name,g in pairs(groups) do
  local undergroundActive=UNDERGROUND_REBUILD_ENABLED and name=="BBYABasementMaster"
  local funkotActive=FUNKOT_RUNTIME_ENABLED and name=="BBYAFunkotMaster"
  if funkotActive then
   -- 93 owns the Sound volume; this only guarantees that the group/reset authority
   -- never zeroes the venue again.
   g.Volume=.62;g:SetAttribute("PlaylistReady",true);g:SetAttribute("MusicCatalogState","FUNKOT_ACTIVE")
  elseif not undergroundActive then
   g.Volume=0;g:SetAttribute("PlaylistReady",false);g:SetAttribute("PlaylistCount",0);g:SetAttribute("RecoveryActive",false);g:SetAttribute("RecoveryFallbackCount",0);g:SetAttribute("MusicCatalogState","RESET_EMPTY")
  end
 end
 Workspace:SetAttribute("BBYAMusicCatalogReset",true)
end

task.defer(applyReset);task.delay(4,applyReset);task.delay(8,applyReset)
print("[BBYA] Mixed catalog authority v4: UNDERGROUND + FUNKOT active; MAIN reset preserved")
