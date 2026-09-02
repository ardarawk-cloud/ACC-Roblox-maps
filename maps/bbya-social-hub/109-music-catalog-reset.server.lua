-- BBYA SOCIAL HUB — OPENING STABILITY AUTHORITY v5.2
-- Replaces the obsolete destructive catalog-reset runtime.
-- Active venue audio authorities stay authoritative; this script never scrubs Sounds,
-- never disables AutoDJ engines, and never changes global Lighting.
-- Pasar Malam output now carries approved Koplo batch 1 while remaining BBYA Music Manager compatible.
-- Also adds a restrained local-only readability lift to the former Photo Studio / Salon lounge.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")
local ContentProvider=game:GetService("ContentProvider")

-- AUDIO STABILITY -------------------------------------------------------------
-- The old reset authority left this true and then destroyed late-created venue Sounds.
-- Opening runtime is now additive: each dedicated venue authority owns its own playlist/player.
ReplicatedStorage:SetAttribute("BBYAMusicCatalogReset",false)
ReplicatedStorage:SetAttribute("BBYAMusicCatalogVersion","ACTIVE_VENUES_OPENING_STABILITY_V5_2")
ReplicatedStorage:SetAttribute("BBYAMainPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYAUndergroundPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYASkateparkPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYARooftopPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistEnabled",true)
Workspace:SetAttribute("BBYAMusicCatalogReset",false)
Workspace:SetAttribute("BBYAOpeningAudioStability","V5_2_ACTIVE_AUTHORITIES")

-- PASAR MALAM PLAYLIST / OUTPUT CONTRACT -------------------------------------
local NIGHT_MARKET_PLAYLIST={
 {title="Gadis Manis Kalimantan - Shinta Gisul",assetId="132656781327264"},
 {title="Aishiteru 2 - Ajeng Febria",assetId="85424046735289"},
 {title="Nemen (Hiphop Dangdut Version) - NDX AKA",assetId="89901574840210"},
 {title="Tresno Tekan Mati New Version - NDX AKA",assetId="79750284945796"},
 {title="Apa Kabar Mantan - NDX AKA",assetId="108659387121290"},
}

local nightMarketIndex=tonumber(ReplicatedStorage:GetAttribute("BBYANightMarketCurrentIndex")) or 1
if nightMarketIndex<1 or nightMarketIndex>#NIGHT_MARKET_PLAYLIST then nightMarketIndex=1 end
local nightMarketSwitching=false
local nightMarketEndedConnection

local function publishNightMarketCatalog(catalog)
 catalog:SetAttribute("PlaylistId","pasar-malam-koplo")
 catalog:SetAttribute("Venue","NIGHT_MARKET")
 catalog:SetAttribute("GenrePolicy","KOPLO")
 catalog:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER")
 catalog:SetAttribute("SourceBatch","APPROVED_BATCH_1")
 catalog:SetAttribute("OutputSound","BBYANightMarketMasterSound")
 catalog:SetAttribute("SoundGroup","BBYANightMarketMaster")
 catalog:SetAttribute("InjectionState","ACTIVE_APPROVED_BATCH_1")
 catalog:SetAttribute("Count",#NIGHT_MARKET_PLAYLIST)
 for i,t in ipairs(NIGHT_MARKET_PLAYLIST) do
  local name=string.format("Track%02d",i)
  local row=catalog:FindFirstChild(name)
  if row and not row:IsA("StringValue") then row:Destroy();row=nil end
  if not row then row=Instance.new("StringValue");row.Name=name;row.Parent=catalog end
  row.Value=t.title
  row:SetAttribute("Index",i)
  row:SetAttribute("AssetId",t.assetId)
  row:SetAttribute("PlaybackSpeed",1)
  row:SetAttribute("ApprovalState","APPROVED")
 end
 for _,row in ipairs(catalog:GetChildren()) do
  local i=tonumber(row:GetAttribute("Index"))
  if not i or i<1 or i>#NIGHT_MARKET_PLAYLIST then row:Destroy() end
 end
end

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
 group:SetAttribute("SourceBatch","APPROVED_BATCH_1")
 group:SetAttribute("OutputReady",true)
 group:SetAttribute("PlaylistReady",true)
 group:SetAttribute("PlaylistCount",#NIGHT_MARKET_PLAYLIST)
 group:SetAttribute("MusicCatalogState","NIGHT_MARKET_KOPLO_BATCH_1_ACTIVE")

 local catalog=ReplicatedStorage:FindFirstChild("BBYANightMarketPlaylistCatalog")
 if catalog and not catalog:IsA("Folder") then catalog:Destroy();catalog=nil end
 if not catalog then
  catalog=Instance.new("Folder")
  catalog.Name="BBYANightMarketPlaylistCatalog"
  catalog.Parent=ReplicatedStorage
 end
 publishNightMarketCatalog(catalog)

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
 sound.PlaybackSpeed=1
 sound:SetAttribute("Venue","NIGHT_MARKET")
 sound:SetAttribute("PlaylistId","pasar-malam-koplo")
 sound:SetAttribute("GenrePolicy","KOPLO")
 sound:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER")
 sound:SetAttribute("SourceBatch","APPROVED_BATCH_1")
 sound:SetAttribute("OutputReady",true)

 ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistOutputReady",true)
 ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistCount",#NIGHT_MARKET_PLAYLIST)
 ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistId","pasar-malam-koplo")
 return group,sound,catalog
end

local function publishNightMarketState(group,sound,track)
 ReplicatedStorage:SetAttribute("BBYANightMarketCurrentIndex",nightMarketIndex)
 ReplicatedStorage:SetAttribute("BBYANightMarketCurrentTitle",track.title)
 ReplicatedStorage:SetAttribute("BBYANightMarketCurrentAssetId",track.assetId)
 group:SetAttribute("CurrentIndex",nightMarketIndex)
 group:SetAttribute("CurrentTitle",track.title)
 group:SetAttribute("CurrentAssetId",track.assetId)
 sound:SetAttribute("Title",track.title)
 sound:SetAttribute("PlaylistIndex",nightMarketIndex)
end

local function waitNightMarketLoaded(sound,timeout)
 local deadline=os.clock()+(timeout or 6)
 while os.clock()<deadline do
  if sound.IsLoaded and (sound.TimeLength or 0)>.2 then return true end
  task.wait(.12)
 end
 return sound.IsLoaded
end

local function playNightMarketIndex(wanted)
 if nightMarketSwitching then return end
 nightMarketSwitching=true
 local group,sound=ensureNightMarketOutput()
 nightMarketIndex=((tonumber(wanted) or 1)-1)%#NIGHT_MARKET_PLAYLIST+1
 local tried=0
 while tried<#NIGHT_MARKET_PLAYLIST do
  local track=NIGHT_MARKET_PLAYLIST[nightMarketIndex]
  sound:Stop()
  sound.SoundId="rbxassetid://"..track.assetId
  sound.PlaybackSpeed=1
  sound.TimePosition=0
  publishNightMarketState(group,sound,track)
  local preloadOk=pcall(function()ContentProvider:PreloadAsync({sound})end)
  if preloadOk and waitNightMarketLoaded(sound,6) then
   local ok=pcall(function()sound:Play()end)
   if ok then
    nightMarketSwitching=false
    print("[BBYA] Pasar Malam Koplo playing",nightMarketIndex,track.title,track.assetId)
    return
   end
  end
  group:SetAttribute("LastUnavailableTitle",track.title)
  group:SetAttribute("LastUnavailableAssetId",track.assetId)
  nightMarketIndex=nightMarketIndex%#NIGHT_MARKET_PLAYLIST+1
  tried+=1
 end
 nightMarketSwitching=false
 warn("[BBYA] Pasar Malam Koplo batch 1: no track could start")
end

local function bindNightMarketEnded()
 local _,sound=ensureNightMarketOutput()
 if nightMarketEndedConnection then nightMarketEndedConnection:Disconnect();nightMarketEndedConnection=nil end
 nightMarketEndedConnection=sound.Ended:Connect(function()
  task.defer(function()playNightMarketIndex(nightMarketIndex%#NIGHT_MARKET_PLAYLIST+1)end)
 end)
end

local nightMarketGroup,nightMarketSound=ensureNightMarketOutput()
bindNightMarketEnded()
task.defer(function()playNightMarketIndex(nightMarketIndex)end)

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
    g:SetAttribute("MusicCatalogState","ACTIVE_AUTHORITY_RECOVERED_V5_2")
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
  local group,sound=ensureNightMarketOutput()
  markActiveGroups()
  if not nightMarketSwitching then
   local expected="rbxassetid://"..NIGHT_MARKET_PLAYLIST[nightMarketIndex].assetId
   if sound.SoundId~=expected or sound.SoundId=="" then
    task.defer(function()playNightMarketIndex(nightMarketIndex)end)
   elseif not sound.IsPlaying then
    local atEnd=false
    pcall(function()
     atEnd=sound.TimeLength>0 and sound.TimePosition>=math.max(0,sound.TimeLength-.25)
    end)
    local wanted=atEnd and (nightMarketIndex%#NIGHT_MARKET_PLAYLIST+1) or nightMarketIndex
    task.defer(function()playNightMarketIndex(wanted)end)
   end
  end
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
 market:SetAttribute("PlaylistCount",#NIGHT_MARKET_PLAYLIST)
 market:SetAttribute("BackgroundMusicInjected",true)
 market:SetAttribute("AudioPolicy","KOPLO_PLAYLIST_ACTIVE_BATCH_1")
end)

-- FORMER-STUDIO LOCAL READABILITY --------------------------------------------
-- Local fixtures only. WITA/global Brightness/Ambient/ClockTime remain untouched.
task.spawn(function()
 local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",120)
 if not root then return end
 local lounge=root:WaitForChild("MainClubSocialLoungeV1",120)
 if not lounge then
  warn("[BBYA] Opening stability v5.2: MainClubSocialLoungeV1 unavailable; local lift skipped")
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

 print("[BBYA] Opening stability v5.2: Pasar Malam Koplo batch 1 active; active venue authorities preserved; former-studio local readability online")
end)
