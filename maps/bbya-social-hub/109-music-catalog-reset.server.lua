-- BBYA SOCIAL HUB — OPENING STABILITY AUTHORITY v5.1
-- Replaces the obsolete destructive catalog-reset runtime.
-- Active venue audio authorities stay authoritative; this script never scrubs Sounds,
-- never disables AutoDJ engines, and never changes global Lighting.
-- Also prepares an empty Pasar Malam playlist/output contract for BBYA Music Manager.
-- Also adds a restrained local-only readability lift to the former Photo Studio / Salon lounge.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")

-- AUDIO STABILITY -------------------------------------------------------------
-- The old reset authority left this true and then destroyed late-created venue Sounds.
-- Opening runtime is now additive: each dedicated venue authority owns its own playlist/player.
ReplicatedStorage:SetAttribute("BBYAMusicCatalogReset",false)
ReplicatedStorage:SetAttribute("BBYAMusicCatalogVersion","ACTIVE_VENUES_OPENING_STABILITY_V5_1")
ReplicatedStorage:SetAttribute("BBYAMainPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYAUndergroundPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYASkateparkPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYARooftopPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistEnabled",false)
Workspace:SetAttribute("BBYAMusicCatalogReset",false)
Workspace:SetAttribute("BBYAOpeningAudioStability","V5_1_ACTIVE_AUTHORITIES")

-- PASAR MALAM PLAYLIST / OUTPUT CONTRACT -------------------------------------
-- Empty by design. BBYA Music Manager will later populate the catalog and inject
-- approved Koplo Roblox Asset IDs. No track is hard-coded or started here.
local function ensureNightMarketOutput()
 local group=SoundService:FindFirstChild("BBYANightMarketMaster")
 if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end
 if not group then
  group=Instance.new("SoundGroup")
  group.Name="BBYANightMarketMaster"
  group.Parent=SoundService
 end
 group.Volume=1
 group:SetAttribute("Venue","NIGHT_MARKET")
 group:SetAttribute("BBYALocalZoneOnly",true)
 group:SetAttribute("PlaylistId","pasar-malam-koplo")
 group:SetAttribute("GenrePolicy","KOPLO")
 group:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER")
 group:SetAttribute("OutputReady",true)
 if group:GetAttribute("PlaylistReady")==nil then group:SetAttribute("PlaylistReady",false) end
 if group:GetAttribute("PlaylistCount")==nil then group:SetAttribute("PlaylistCount",0) end
 if not group:GetAttribute("MusicCatalogState") then group:SetAttribute("MusicCatalogState","AWAITING_BBYA_MUSIC_MANAGER") end

 local catalog=ReplicatedStorage:FindFirstChild("BBYANightMarketPlaylistCatalog")
 if catalog and not catalog:IsA("Folder") then catalog:Destroy();catalog=nil end
 if not catalog then
  catalog=Instance.new("Folder")
  catalog.Name="BBYANightMarketPlaylistCatalog"
  catalog.Parent=ReplicatedStorage
 end
 catalog:SetAttribute("PlaylistId","pasar-malam-koplo")
 catalog:SetAttribute("Venue","NIGHT_MARKET")
 catalog:SetAttribute("GenrePolicy","KOPLO")
 catalog:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER")
 catalog:SetAttribute("OutputSound","BBYANightMarketMasterSound")
 catalog:SetAttribute("SoundGroup","BBYANightMarketMaster")
 catalog:SetAttribute("InjectionState","READY_EMPTY")
 if catalog:GetAttribute("Count")==nil then catalog:SetAttribute("Count",0) end

 local sound=SoundService:FindFirstChild("BBYANightMarketMasterSound")
 if sound and not sound:IsA("Sound") then sound:Destroy();sound=nil end
 if not sound then
  sound=Instance.new("Sound")
  sound.Name="BBYANightMarketMasterSound"
  sound.Parent=SoundService
 end
 sound.SoundGroup=group
 sound.Volume=1
 sound.Looped=false
 sound:SetAttribute("Venue","NIGHT_MARKET")
 sound:SetAttribute("PlaylistId","pasar-malam-koplo")
 sound:SetAttribute("GenrePolicy","KOPLO")
 sound:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER")
 sound:SetAttribute("OutputReady",true)

 ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistOutputReady",true)
 return group
end

local nightMarketGroup=ensureNightMarketOutput()

local ACTIVE_GROUPS={
 BBYAClubMaster="MAIN",
 BBYABasementMaster="UNDERGROUND",
 BBYAFunkotMaster="FUNKOT",
 BBYASkateparkMaster="SKATEPARK",
 BBYARooftopMaster="ROOFTOP",
 BBYANightMarketMaster="NIGHT_MARKET",
}

local function markActiveGroups()
 for name,venue in pairs(ACTIVE_GROUPS) do
  local g=SoundService:FindFirstChild(name)
  if g and g:IsA("SoundGroup") then
   g:SetAttribute("Venue",venue)
   g:SetAttribute("BBYALocalZoneOnly",true)
   if g:GetAttribute("MusicCatalogState")=="RESET_EMPTY" then
    g:SetAttribute("MusicCatalogState","ACTIVE_AUTHORITY_RECOVERED_V5_1")
   end
  end
 end
end
markActiveGroups()

task.spawn(function()
 while task.wait(1) do
  -- Keep only the compatibility flag authoritative. Dedicated venue scripts own
  -- SoundId, playback, health checks, SoundGroup volume and playlist state.
  if ReplicatedStorage:GetAttribute("BBYAMusicCatalogReset")~=false then
   ReplicatedStorage:SetAttribute("BBYAMusicCatalogReset",false)
  end
  ensureNightMarketOutput()
  markActiveGroups()
 end
end)

-- Mark the Pasar Malam model only after its geometry authorities have initialized.
task.spawn(function()
 local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",120)
 if not root then return end
 local market=root:WaitForChild("BBYANightMarket",120)
 if not market then return end
 task.wait(2.5)
 market:SetAttribute("PlaylistKey","pasar-malam-koplo")
 market:SetAttribute("PlaylistVenue","NIGHT_MARKET")
 market:SetAttribute("PlaylistGenrePolicy","KOPLO")
 market:SetAttribute("PlaylistSyncAuthority","BBYA_MUSIC_MANAGER")
 market:SetAttribute("PlaylistOutputReady",true)
 market:SetAttribute("BackgroundMusicInjected",false)
 market:SetAttribute("AudioPolicy","PLAYLIST_SLOT_READY_AWAITING_SYNC")
end)

-- FORMER-STUDIO LOCAL READABILITY --------------------------------------------
-- Local fixtures only. WITA/global Brightness/Ambient/ClockTime remain untouched.
task.spawn(function()
 local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",120)
 if not root then return end
 local lounge=root:WaitForChild("MainClubSocialLoungeV1",120)
 if not lounge then
  warn("[BBYA] Opening stability v5.1: MainClubSocialLoungeV1 unavailable; local lift skipped")
  return
 end

 local old=root:FindFirstChild("MainClubOpeningStabilityV1")
 if old then old:Destroy() end
 local out=Instance.new("Model")
 out.Name="MainClubOpeningStabilityV1"
 out:SetAttribute("Pass","FORMER_STUDIO_LOCAL_READABILITY_V1")
 out:SetAttribute("LocalLightingOnly",true)
 out:SetAttribute("GlobalLightingUntouched",true)
 out:SetAttribute("UndergroundUntouched",true)
 out:SetAttribute("WITAUntouched",true)
 out.Parent=root

 local warm=Color3.fromRGB(255,222,195)
 local neutral=Color3.fromRGB(235,226,218)
 local specs={
  {Vector3.new(-42.0,9.7,-31.0),warm,.72,14.5},
  {Vector3.new(-42.0,9.7,-21.0),warm,.76,15.0},
  {Vector3.new(-42.0,9.7,-11.0),warm,.72,14.5},
  {Vector3.new(-33.0,9.2,-31.0),neutral,.56,13.0},
  {Vector3.new(-33.0,9.2,-21.0),neutral,.60,13.5},
  {Vector3.new(-33.0,9.2,-11.0),neutral,.56,13.0},
  {Vector3.new(-28.5,7.3,-21.0),warm,.42,10.5},
 }
 for i,s in ipairs(specs) do
  local anchor=Instance.new("Part")
  anchor.Name="FormerStudioFill"..i
  anchor.Size=Vector3.new(.18,.18,.18)
  anchor.Position=s[1]
  anchor.Anchored=true
  anchor.CanCollide=false
  anchor.CanTouch=false
  anchor.CanQuery=false
  anchor.Transparency=1
  anchor.CastShadow=false
  anchor.Parent=out
  local light=Instance.new("PointLight")
  light.Name="FormerStudioLocalReadability"
  light.Color=s[2]
  light.Brightness=s[3]
  light.Range=s[4]
  light.Shadows=false
  light.Parent=anchor
 end

 print("[BBYA] Opening stability v5.1: active venue authorities preserved; Pasar Malam Koplo output ready-empty; former-studio local readability online")
end)
