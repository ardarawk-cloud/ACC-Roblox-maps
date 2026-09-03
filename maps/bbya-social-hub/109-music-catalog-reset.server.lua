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
 if catalog:GetAttribute("InjectionState")==nil then catalog:SetAttribute("InjectionState","READY_EMPTY") end
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

-- MALL KPOP PLAYLIST ----------------------------------------------------------
-- Dedicated Mall-only bank. The SoundGroup is server-muted by default and the
-- Mall client unmutes it only while the local avatar is inside the Mall bounds.
-- This deliberately bypasses CLUB/MainClub playlist state and UI.
local ContentProvider=game:GetService("ContentProvider")
local Players=game:GetService("Players")
local MALL_KPOP_PLAYLIST={
 {title="HANTU",assetId="130787669922537",playbackSpeed=0.5714285714},
 {title="MALU BANGET",assetId="128649936033154",playbackSpeed=0.5714285714},
 {title="STRATEGI KU",assetId="87125114946473",playbackSpeed=0.5714285714},
 {title="DI JATUHKAN",assetId="138472779676021",playbackSpeed=0.5714285714},
 {title="MEMULAI SEBELAHMU",assetId="115164716109234",playbackSpeed=0.5714285714},
 {title="TOPIK",assetId="106731979070100",playbackSpeed=0.5714285714},
 {title="MERAH MUDA",assetId="82573111697282",playbackSpeed=0.5714285714},
 {title="YA TUHAN",assetId="84541295288456",playbackSpeed=0.5714285714},
 {title="MALAM YANG SEMPURNA",assetId="112025968048348",playbackSpeed=0.5714285714},
 {title="KEREN",assetId="102724403050017",playbackSpeed=0.5714285714},
 {title="SEPERTI GILA",assetId="101221026959656",playbackSpeed=0.5714285714},
 {title="TERKENAL",assetId="102729376941557",playbackSpeed=0.5714285714},
 {title="AKU",assetId="130045741934771",playbackSpeed=0.5714285714},
 {title="EMAS",assetId="94909694876329",playbackSpeed=0.5714285714},
 {title="DITOK",assetId="128638509475237",playbackSpeed=0.5714285714},
 {title="AKU DAN KAMU",assetId="115814496839320",playbackSpeed=0.5714285714},
 {title="BUNGA",assetId="134192777315026",playbackSpeed=0.5714285714},
 {title="SATU ATAU DELAPAN",assetId="85568242991971",playbackSpeed=0.5714285714},
}

local mallGroup=SoundService:FindFirstChild("BBYAMallMaster")
if mallGroup and not mallGroup:IsA("SoundGroup") then mallGroup:Destroy();mallGroup=nil end
if not mallGroup then mallGroup=Instance.new("SoundGroup");mallGroup.Name="BBYAMallMaster";mallGroup.Parent=SoundService end
mallGroup.Volume=0
mallGroup:SetAttribute("Venue","MALL")
mallGroup:SetAttribute("BBYALocalZoneOnly",true)
mallGroup:SetAttribute("PlaylistReady",true)
mallGroup:SetAttribute("PlaylistId","mall-kpop")
mallGroup:SetAttribute("BankName","KPOP")
mallGroup:SetAttribute("GenrePolicy","KPOP")
mallGroup:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER")
mallGroup:SetAttribute("PlaylistCount",#MALL_KPOP_PLAYLIST)
mallGroup:SetAttribute("MusicCatalogState","MALL_KPOP_APPROVED_V1")
mallGroup:SetAttribute("RightsProfile","UNIVERSE_PERMISSION_APPROVED_ONLY")

local mallCatalog=ReplicatedStorage:FindFirstChild("BBYAMallPlaylistCatalog")
if mallCatalog and not mallCatalog:IsA("Folder") then mallCatalog:Destroy();mallCatalog=nil end
if not mallCatalog then mallCatalog=Instance.new("Folder");mallCatalog.Name="BBYAMallPlaylistCatalog";mallCatalog.Parent=ReplicatedStorage end
mallCatalog:ClearAllChildren()
mallCatalog:SetAttribute("PlaylistId","mall-kpop")
mallCatalog:SetAttribute("Venue","MALL")
mallCatalog:SetAttribute("BankName","KPOP")
mallCatalog:SetAttribute("GenrePolicy","KPOP")
mallCatalog:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER")
mallCatalog:SetAttribute("Count",#MALL_KPOP_PLAYLIST)
mallCatalog:SetAttribute("PlaybackSpeed",0.5714285714)
mallCatalog:SetAttribute("ApprovalState","18_APPROVED")
mallCatalog:SetAttribute("OutputSound","BBYAMallMasterSound")
mallCatalog:SetAttribute("SoundGroup","BBYAMallMaster")
mallCatalog:SetAttribute("ControlRemote","BBYAMallMusicControl")
mallCatalog:SetAttribute("InjectionState","ACTIVE_APPROVED_KPOP_BANK_V1")
for i,t in ipairs(MALL_KPOP_PLAYLIST) do
 local row=Instance.new("StringValue")
 row.Name=string.format("Track%02d",i)
 row.Value=t.title
 row:SetAttribute("AssetId",t.assetId)
 row:SetAttribute("Index",i)
 row:SetAttribute("PlaybackSpeed",t.playbackSpeed)
 row:SetAttribute("ApprovalState","APPROVED")
 row:SetAttribute("Venue","MALL")
 row:SetAttribute("BankName","KPOP")
 row.Parent=mallCatalog
end

local mallControl=ReplicatedStorage:FindFirstChild("BBYAMallMusicControl")
if mallControl and not mallControl:IsA("RemoteEvent") then mallControl:Destroy();mallControl=nil end
if not mallControl then mallControl=Instance.new("RemoteEvent");mallControl.Name="BBYAMallMusicControl";mallControl.Parent=ReplicatedStorage end

local mallSound=SoundService:FindFirstChild("BBYAMallMasterSound")
if mallSound and not mallSound:IsA("Sound") then mallSound:Destroy();mallSound=nil end
if not mallSound then mallSound=Instance.new("Sound");mallSound.Name="BBYAMallMasterSound";mallSound.Parent=SoundService end
mallSound.SoundGroup=mallGroup
mallSound.Volume=1
mallSound.Looped=false
mallSound.PlaybackSpeed=0.5714285714
mallSound:SetAttribute("Venue","MALL")
mallSound:SetAttribute("PlaylistId","mall-kpop")
mallSound:SetAttribute("BankName","KPOP")
mallSound:SetAttribute("GenrePolicy","KPOP")
mallSound:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER")

local mallIndex=tonumber(ReplicatedStorage:GetAttribute("BBYAMallCurrentIndex")) or 1
if mallIndex<1 or mallIndex>#MALL_KPOP_PLAYLIST then mallIndex=1 end
local mallSwitching=false
local mallQueue={}

local function inMall(player)
 local char=player and player.Character
 local hrp=char and char:FindFirstChild("HumanoidRootPart")
 if not hrp then return false end
 local p=hrp.Position
 return p.Y>-4 and p.Y<68 and math.abs(p.X)<=98 and p.Z>=285 and p.Z<=445
end

local function publishMallQueue()
 local count=#mallQueue
 local nextIndex=tonumber(mallQueue[1]) or 0
 ReplicatedStorage:SetAttribute("BBYAMallQueueCount",count)
 ReplicatedStorage:SetAttribute("BBYAMallNextRequestIndex",nextIndex)
 mallGroup:SetAttribute("QueueCount",count)
 mallGroup:SetAttribute("NextRequestIndex",nextIndex)
end

local function publishMallState(track)
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistEnabled",true)
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistId","mall-kpop")
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistBank","KPOP")
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistCount",#MALL_KPOP_PLAYLIST)
 ReplicatedStorage:SetAttribute("BBYAMallCurrentIndex",mallIndex)
 ReplicatedStorage:SetAttribute("BBYAMallCurrentTitle",track.title)
 ReplicatedStorage:SetAttribute("BBYAMallCurrentAssetId",track.assetId)
 ReplicatedStorage:SetAttribute("BBYAMallCurrentPlaybackSpeed",track.playbackSpeed)
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistOutputReady",true)
 mallGroup:SetAttribute("CurrentIndex",mallIndex)
 mallGroup:SetAttribute("CurrentTitle",track.title)
 mallGroup:SetAttribute("CurrentAssetId",track.assetId)
 mallGroup:SetAttribute("CurrentPlaybackSpeed",track.playbackSpeed)
 mallSound:SetAttribute("Title",track.title)
 mallSound:SetAttribute("PlaylistIndex",mallIndex)
 mallSound:SetAttribute("PlaybackSpeed",track.playbackSpeed)
 publishMallQueue()
end

local function waitMallLoaded(timeout)
 local deadline=os.clock()+(timeout or 6)
 while os.clock()<deadline do
  if mallSound.IsLoaded and (mallSound.TimeLength or 0)>.2 then return true end
  task.wait(.12)
 end
 return mallSound.IsLoaded
end

local function playMallIndex(wanted)
 if mallSwitching then return end
 mallSwitching=true
 mallIndex=((tonumber(wanted) or 1)-1)%#MALL_KPOP_PLAYLIST+1
 local tried=0
 while tried<#MALL_KPOP_PLAYLIST do
  local track=MALL_KPOP_PLAYLIST[mallIndex]
  mallSound:Stop()
  mallSound.SoundId="rbxassetid://"..track.assetId
  mallSound.PlaybackSpeed=track.playbackSpeed
  mallSound.TimePosition=0
  publishMallState(track)
  local preloadOk=pcall(function()ContentProvider:PreloadAsync({mallSound})end)
  if preloadOk and waitMallLoaded(6) then
   local ok=pcall(function()mallSound:Play()end)
   if ok then
    mallSwitching=false
    print("[BBYA] Mall KPOP playing",mallIndex,track.title,track.assetId,"speed",track.playbackSpeed)
    return
   end
  end
  mallGroup:SetAttribute("LastUnavailableTitle",track.title)
  mallGroup:SetAttribute("LastUnavailableAssetId",track.assetId)
  mallIndex=mallIndex%#MALL_KPOP_PLAYLIST+1
  tried+=1
 end
 mallSwitching=false
 warn("[BBYA] Mall KPOP playlist: no approved track could start")
end

local function popMallNext()
 if #mallQueue>0 then
  local n=table.remove(mallQueue,1)
  publishMallQueue()
  return n
 end
 return mallIndex%#MALL_KPOP_PLAYLIST+1
end

local function mallAdmin(player)
 return player:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)
end

mallControl.OnServerEvent:Connect(function(player,action,wanted)
 action=tostring(action or "")
 if action=="request" then
  if not inMall(player) then return end
  local n=tonumber(wanted)
  if not n or n<1 or n>#MALL_KPOP_PLAYLIST then return end
  table.insert(mallQueue,math.floor(n))
  publishMallQueue()
  if not mallSound.IsPlaying and not mallSwitching then task.defer(function()playMallIndex(popMallNext())end) end
  return
 end
 if not mallAdmin(player) then return end
 if action=="play" then
  local n=tonumber(wanted)
  if n and n>=1 and n<=#MALL_KPOP_PLAYLIST then task.defer(function()playMallIndex(n)end) end
 elseif action=="next" then task.defer(function()playMallIndex(popMallNext())end)
 elseif action=="prev" then task.defer(function()playMallIndex(((math.max(mallIndex,1)-2)%#MALL_KPOP_PLAYLIST)+1)end)
 elseif action=="clearqueue" then table.clear(mallQueue);publishMallQueue() end
end)

mallSound.Ended:Connect(function()task.defer(function()playMallIndex(popMallNext())end)end)
publishMallQueue()
task.defer(function()playMallIndex(mallIndex)end)

task.spawn(function()
 local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",120)
 local mall=root and root:WaitForChild("BBYAMall",120)
 if not mall then return end
 mall:SetAttribute("PlaylistKey","mall-kpop")
 mall:SetAttribute("PlaylistVenue","MALL")
 mall:SetAttribute("PlaylistBank","KPOP")
 mall:SetAttribute("PlaylistGenrePolicy","KPOP")
 mall:SetAttribute("PlaylistSyncAuthority","BBYA_MUSIC_MANAGER")
 mall:SetAttribute("PlaylistOutputReady",true)
 mall:SetAttribute("PlaylistCount",#MALL_KPOP_PLAYLIST)
 mall:SetAttribute("BackgroundMusicInjected",true)
 mall:SetAttribute("AudioPolicy","APPROVED_KPOP_BANK_ACTIVE_V1")
end)

print("[BBYA] Mall KPOP engine ready: venue=MALL bank=KPOP tracks=18 playback=0.5714285714; CLUB authority untouched")
