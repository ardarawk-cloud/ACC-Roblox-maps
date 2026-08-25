-- BBYA SOCIAL HUB — MIXED MUSIC RESET AUTHORITY v4
-- MAIN/FUNKOT stay reset; UNDERGROUND + SKATEPARK + ROOFTOP are explicitly active.
-- Dedicated active venue authorities must never be scrubbed by this legacy reset guard.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ServerScriptService=game:GetService("ServerScriptService")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")

local ACTIVE_GROUPS={
 BBYABasementMaster=true,
 BBYASkateparkMaster=true,
 BBYARooftopMaster=true,
}

ReplicatedStorage:SetAttribute("BBYAMusicCatalogReset",true)
ReplicatedStorage:SetAttribute("BBYAMusicCatalogVersion","RESET_WITH_ACTIVE_VENUES_V4")
ReplicatedStorage:SetAttribute("BBYAUndergroundPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYASkateparkPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYARooftopPlaylistEnabled",true)

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
 g:SetAttribute("Venue",venue)
 g:SetAttribute("BBYALocalZoneOnly",true)
 if active then
  -- Do not overwrite venue-specific catalog state if its own authority already populated it.
  if g.Volume<=0 then g.Volume=.72 end
  if g:GetAttribute("MusicCatalogState")==nil or g:GetAttribute("MusicCatalogState")=="RESET_EMPTY" then
   g:SetAttribute("MusicCatalogState","ACTIVE_AUTHORITY_PRESERVED")
  end
  return g
 end
 g.Volume=0
 g:SetAttribute("PlaylistReady",false)
 g:SetAttribute("PlaylistCount",0)
 g:SetAttribute("RecoveryActive",false)
 g:SetAttribute("RecoveryFallbackCount",0)
 g:SetAttribute("MusicCatalogState","RESET_EMPTY")
 return g
end

local groups={
 ["BBYAClubMaster"]=ensureGroup("BBYAClubMaster","MAIN",false),
 ["BBYABasementMaster"]=ensureGroup("BBYABasementMaster","UNDERGROUND",true),
 ["BBYAFunkotMaster"]=ensureGroup("BBYAFunkotMaster","FUNKOT",false),
 ["BBYAVIPMaster"]=ensureGroup("BBYAVIPMaster","VIP",false),
 ["BBYASkateparkMaster"]=ensureGroup("BBYASkateparkMaster","SKATEPARK",true),
 ["BBYARooftopMaster"]=ensureGroup("BBYARooftopMaster","ROOFTOP",true),
}

local knownSounds={
 BBYAClubDeckA=true,BBYAClubDeckB=true,BBYABasementDeckA=true,BBYABasementDeckB=true,
 BBYAFunkotDeck=true,BBYAFunkotClubFeed=true,BBYAMainPublicFallbackV4=true,
 BBYAUndergroundBreakbeatFallbackV4=true,BBYAClubFeed=true,BBYAClubSound=true,
}
local function controlledSound(s)
 if not s:IsA("Sound") then return false end
 local sg=s.SoundGroup
 if sg and ACTIVE_GROUPS[sg.Name] then return false end
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
  if name~="BasementIndoAutoDJ" then
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
  if not ACTIVE_GROUPS[name] then
   g.Volume=0;g:SetAttribute("PlaylistReady",false);g:SetAttribute("PlaylistCount",0);g:SetAttribute("RecoveryActive",false);g:SetAttribute("RecoveryFallbackCount",0);g:SetAttribute("MusicCatalogState","RESET_EMPTY")
  end
 end
 Workspace:SetAttribute("BBYAMusicCatalogReset",true)
end

task.defer(applyReset);task.delay(4,applyReset);task.delay(8,applyReset)
print("[BBYA] Mixed catalog authority v4: Underground + Skatepark + Rooftop preserved; Main/Funkot reset")