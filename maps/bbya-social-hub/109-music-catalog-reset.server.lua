-- BBYA SOCIAL HUB — MIXED MUSIC RESET AUTHORITY v6
-- MAIN + UNDERGROUND + FUNKOT + ROOFTOP runtime libraries are explicitly active.
-- Other legacy/empty venue channels remain protected by reset authority.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ServerScriptService=game:GetService("ServerScriptService")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")
local MAIN_RUNTIME_ENABLED=true
local UNDERGROUND_REBUILD_ENABLED=true
local FUNKOT_RUNTIME_ENABLED=true
local ROOFTOP_RUNTIME_ENABLED=true

-- Main Club is live again. Keep the legacy global reset flag false so the
-- compact music client does not intentionally render MAIN as an empty catalog.
ReplicatedStorage:SetAttribute("BBYAMusicCatalogReset",false)
ReplicatedStorage:SetAttribute("BBYAMusicCatalogVersion","MAIN_UNDERGROUND_FUNKOT_ROOFTOP_ACTIVE_V6")
ReplicatedStorage:SetAttribute("BBYAMainPlaylistEnabled",MAIN_RUNTIME_ENABLED)
ReplicatedStorage:SetAttribute("BBYAUndergroundPlaylistEnabled",UNDERGROUND_REBUILD_ENABLED)
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistEnabled",FUNKOT_RUNTIME_ENABLED)
-- Declare Rooftop active immediately so reset authority never destroys its canonical sound
-- while 134-rooftop-playlist.server.lua is starting.
ReplicatedStorage:SetAttribute("BBYARooftopPlaylistEnabled",ROOFTOP_RUNTIME_ENABLED)

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
  g.Volume=(venue=="ROOFTOP" and .68) or (venue=="FUNKOT" and .62) or 1
  g:SetAttribute("Venue",venue)
  g:SetAttribute("BBYALocalZoneOnly",true)
  g:SetAttribute("PlaylistReady",true)
  if venue=="FUNKOT" then
   g:SetAttribute("MusicCatalogState","FUNKOT_ACTIVE")
  elseif venue=="ROOFTOP" then
   g:SetAttribute("MusicCatalogState","ROOFTOP_TROPICAL_ACTIVE")
  elseif venue=="MAIN" then
   g:SetAttribute("MusicCatalogState","MAIN_PROGRESSIVE_ACTIVE")
  else
   g:SetAttribute("MusicCatalogState","OWNER_LIBRARY_ACTIVE")
  end
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
 ["BBYAClubMaster"]=ensureGroup("BBYAClubMaster","MAIN",MAIN_RUNTIME_ENABLED),
 ["BBYABasementMaster"]=ensureGroup("BBYABasementMaster","UNDERGROUND",UNDERGROUND_REBUILD_ENABLED),
 ["BBYAFunkotMaster"]=ensureGroup("BBYAFunkotMaster","FUNKOT",FUNKOT_RUNTIME_ENABLED),
 ["BBYAVIPMaster"]=ensureGroup("BBYAVIPMaster","VIP",false),
 ["BBYASkateparkMaster"]=ensureGroup("BBYASkateparkMaster","SKATEPARK",false),
 ["BBYARooftopMaster"]=ensureGroup("BBYARooftopMaster","ROOFTOP",ROOFTOP_RUNTIME_ENABLED),
}

local knownSounds={
 BBYAClubDeckA=true,BBYAClubDeckB=true,BBYABasementDeckA=true,BBYABasementDeckB=true,
 BBYAFunkotDeck=true,BBYAFunkotClubFeed=true,BBYAMainPublicFallbackV4=true,
 BBYAUndergroundBreakbeatFallbackV4=true,BBYAClubFeed=true,BBYAClubSound=true,
}
local function controlledSound(s)
 if not s:IsA("Sound") then return false end
 local sg=s.SoundGroup
 -- Canonical active runtimes own every sound in their own SoundGroup. Reset must never scrub them.
 if MAIN_RUNTIME_ENABLED and sg and sg.Name=="BBYAClubMaster" then return false end
 if UNDERGROUND_REBUILD_ENABLED and sg and sg.Name=="BBYABasementMaster" then return false end
 if FUNKOT_RUNTIME_ENABLED and sg and sg.Name=="BBYAFunkotMaster" then return false end
 if ROOFTOP_RUNTIME_ENABLED and sg and sg.Name=="BBYARooftopMaster" then return false end
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
  local mainActive=MAIN_RUNTIME_ENABLED and name=="BBYAClubMaster"
  local undergroundActive=UNDERGROUND_REBUILD_ENABLED and name=="BBYABasementMaster"
  local funkotActive=FUNKOT_RUNTIME_ENABLED and name=="BBYAFunkotMaster"
  local rooftopActive=ROOFTOP_RUNTIME_ENABLED and name=="BBYARooftopMaster"
  if mainActive then
   g.Volume=1;g:SetAttribute("PlaylistReady",true);g:SetAttribute("MusicCatalogState","MAIN_PROGRESSIVE_ACTIVE")
  elseif funkotActive then
   g.Volume=.62;g:SetAttribute("PlaylistReady",true);g:SetAttribute("MusicCatalogState","FUNKOT_ACTIVE")
  elseif undergroundActive then
   g.Volume=1;g:SetAttribute("PlaylistReady",true);g:SetAttribute("MusicCatalogState","OWNER_LIBRARY_ACTIVE")
  elseif rooftopActive then
   g.Volume=.68;g:SetAttribute("PlaylistReady",true);g:SetAttribute("MusicCatalogState","ROOFTOP_TROPICAL_ACTIVE")
  else
   g.Volume=0;g:SetAttribute("PlaylistReady",false);g:SetAttribute("PlaylistCount",0);g:SetAttribute("RecoveryActive",false);g:SetAttribute("RecoveryFallbackCount",0);g:SetAttribute("MusicCatalogState","RESET_EMPTY")
  end
 end
 Workspace:SetAttribute("BBYAMusicCatalogReset",false)
end

task.defer(applyReset);task.delay(4,applyReset);task.delay(8,applyReset)
print("[BBYA] Mixed catalog authority v6: MAIN + UNDERGROUND + FUNKOT + ROOFTOP active")
