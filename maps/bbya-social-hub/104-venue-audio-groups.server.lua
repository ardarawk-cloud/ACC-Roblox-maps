-- BBYA SOCIAL HUB — VENUE AUDIO MASTERS v4.4
-- Independent local-only SoundGroups for every music venue.
-- Rooftop + Skatepark are active; VIP remains isolated/reset.
-- Skatepark uses Roblox Creator Store/APM assets plus approved custom uploads.
-- v4.4 adds server-authoritative Skatepark request + PREV/NEXT controls for Music Suite.

local SoundService=game:GetService("SoundService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ContentProvider=game:GetService("ContentProvider")

local SKATE_PLAYLIST={
 {title="Mutronic Plague",assetId="1837057495"},
 {title="Rock On",assetId="1841242625"},
 {title="Run Run Run",assetId="9040318014"},
 {title="We've Got This! - 60",assetId="9043707741"},
 {title="Fuel Fury",assetId="9042632936"},
 {title="Boom Boom (b 30)",assetId="1840009708"},
 {title="Untungnya, Hidup Harus Tetap Berjalan — Pop Punk Cover",assetId="134928414278364"},
 {title="Untungnya Hidup Harus Tetap Berjalan",assetId="101433831748471",playbackSpeed=0.8},
}

local function ensure(name,venue,active,state)
 local g=SoundService:FindFirstChild(name)
 if g and not g:IsA("SoundGroup") then g:Destroy();g=nil end
 if not g then g=Instance.new("SoundGroup");g.Name=name;g.Parent=SoundService end
 g.Volume=active and .72 or 0
 g:SetAttribute("Venue",venue)
 g:SetAttribute("BBYALocalZoneOnly",true)
 g:SetAttribute("PlaylistReady",active==true)
 if active then
  g:SetAttribute("MusicCatalogState",state or "ACTIVE")
 else
  g:SetAttribute("PlaylistCount",0)
  g:SetAttribute("MusicCatalogState","RESET_EMPTY")
 end
 return g
end

local skateGroup=ensure("BBYASkateparkMaster","SKATEPARK",true,"SKATEPARK_MIXED_V4")
-- Skatepark-specific gain. Do not raise Rooftop or any other venue group.
skateGroup.Volume=1.0
skateGroup:SetAttribute("VenueGainProfile","SKATEPARK_FULL_LEVEL_V1")
ensure("BBYARooftopMaster","ROOFTOP",true,"ROOFTOP_TROPICAL_ACTIVE")
ensure("BBYAVIPMaster","VIP",false)

local skateControl=ReplicatedStorage:FindFirstChild("BBYASkateparkMusicControl")
if skateControl and not skateControl:IsA("RemoteEvent") then skateControl:Destroy();skateControl=nil end
if not skateControl then
 skateControl=Instance.new("RemoteEvent")
 skateControl.Name="BBYASkateparkMusicControl"
 skateControl.Parent=ReplicatedStorage
end

local function publishSkateCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYASkateparkPlaylistCatalog")
 if folder and not folder:IsA("Folder") then folder:Destroy();folder=nil end
 if not folder then folder=Instance.new("Folder");folder.Name="BBYASkateparkPlaylistCatalog";folder.Parent=ReplicatedStorage end
 folder:ClearAllChildren()
 folder:SetAttribute("PlaylistId","skatepark-mixed")
 folder:SetAttribute("Venue","SKATEPARK")
 folder:SetAttribute("Count",#SKATE_PLAYLIST)
 folder:SetAttribute("RightsProfile","ROBLOX_CREATOR_STORE_APM_PLUS_CUSTOM_APPROVED")
 folder:SetAttribute("ControlRemote","BBYASkateparkMusicControl")
 for i,t in ipairs(SKATE_PLAYLIST) do
  local row=Instance.new("StringValue")
  row.Name=string.format("Track%02d",i)
  row.Value=t.title
  row:SetAttribute("AssetId",t.assetId)
  row:SetAttribute("Index",i)
  row:SetAttribute("PlaybackSpeed",tonumber(t.playbackSpeed) or 1)
  row.Parent=folder
 end
end

local sound=SoundService:FindFirstChild("BBYASkateparkMasterSound")
if sound and not sound:IsA("Sound") then sound:Destroy();sound=nil end
if not sound then sound=Instance.new("Sound");sound.Name="BBYASkateparkMasterSound";sound.Parent=SoundService end
sound.SoundGroup=skateGroup
sound.Volume=1.0
sound.Looped=false
sound.PlaybackSpeed=1
sound:SetAttribute("Venue","SKATEPARK")
sound:SetAttribute("PlaylistId","skatepark-mixed")
sound:SetAttribute("RightsProfile","ROBLOX_CREATOR_STORE_APM_PLUS_CUSTOM_APPROVED")
sound:SetAttribute("VenueGainProfile","SKATEPARK_FULL_LEVEL_V1")

local index=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkCurrentIndex")) or 1
if index<1 or index>#SKATE_PLAYLIST then index=1 end
local switching=false
local skateQueue={}

local function publishQueue()
 local count=#skateQueue
 local nextIndex=tonumber(skateQueue[1]) or 0
 ReplicatedStorage:SetAttribute("BBYASkateparkQueueCount",count)
 ReplicatedStorage:SetAttribute("BBYASkateparkNextRequestIndex",nextIndex)
 skateGroup:SetAttribute("QueueCount",count)
 skateGroup:SetAttribute("NextRequestIndex",nextIndex)
end

local function publishState(track)
 ReplicatedStorage:SetAttribute("BBYASkateparkCurrentIndex",index)
 ReplicatedStorage:SetAttribute("BBYASkateparkCurrentTitle",track.title)
 ReplicatedStorage:SetAttribute("BBYASkateparkCurrentAssetId",track.assetId)
 ReplicatedStorage:SetAttribute("BBYASkateparkCurrentPlaybackSpeed",tonumber(track.playbackSpeed) or 1)
 skateGroup:SetAttribute("PlaylistCount",#SKATE_PLAYLIST)
 skateGroup:SetAttribute("CurrentIndex",index)
 skateGroup:SetAttribute("CurrentTitle",track.title)
 skateGroup:SetAttribute("CurrentAssetId",track.assetId)
 skateGroup:SetAttribute("CurrentPlaybackSpeed",tonumber(track.playbackSpeed) or 1)
 skateGroup:SetAttribute("PlaylistReady",true)
 publishQueue()
end

local function waitLoaded(timeout)
 local deadline=os.clock()+(timeout or 6)
 while os.clock()<deadline do
  if sound.IsLoaded and (sound.TimeLength or 0)>.2 then return true end
  task.wait(.12)
 end
 return sound.IsLoaded
end

local function playIndex(wanted)
 if switching then return end
 switching=true
 index=((tonumber(wanted) or 1)-1)%#SKATE_PLAYLIST+1
 local tried=0
 while tried<#SKATE_PLAYLIST do
  local track=SKATE_PLAYLIST[index]
  sound:Stop()
  sound.SoundId="rbxassetid://"..track.assetId
  sound.PlaybackSpeed=tonumber(track.playbackSpeed) or 1
  sound.TimePosition=0
  sound:SetAttribute("Title",track.title)
  sound:SetAttribute("PlaylistIndex",index)
  sound:SetAttribute("PlaybackSpeed",sound.PlaybackSpeed)
  publishState(track)
  local preloadOk=pcall(function()ContentProvider:PreloadAsync({sound})end)
  if preloadOk and waitLoaded(6) then
   local ok=pcall(function()sound:Play()end)
   if ok then
    switching=false
    print("[BBYA] Skatepark playing",index,track.title,track.assetId,"speed",sound.PlaybackSpeed)
    return
   end
  end
  skateGroup:SetAttribute("LastUnavailableTitle",track.title)
  skateGroup:SetAttribute("LastUnavailableAssetId",track.assetId)
  index=index%#SKATE_PLAYLIST+1
  tried+=1
 end
 switching=false
 warn("[BBYA] Skatepark playlist: no track could start")
end

local function popNextWanted()
 if #skateQueue>0 then
  local wanted=table.remove(skateQueue,1)
  publishQueue()
  return wanted
 end
 return index%#SKATE_PLAYLIST+1
end

local function isAdmin(player)
 return player:GetAttribute("BBYAAdmin")==true
  or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)
end

skateControl.OnServerEvent:Connect(function(player,action,wanted)
 action=tostring(action or "")
 if action=="request" then
  local n=tonumber(wanted)
  if not n or n<1 or n>#SKATE_PLAYLIST then return end
  table.insert(skateQueue,math.floor(n))
  publishQueue()
  if not sound.IsPlaying and not switching then
   local nextWanted=popNextWanted()
   task.defer(function()playIndex(nextWanted)end)
  end
  return
 end
 if not isAdmin(player) then return end
 if action=="play" then
  local n=tonumber(wanted)
  if n and n>=1 and n<=#SKATE_PLAYLIST then task.defer(function()playIndex(n)end) end
 elseif action=="next" then
  local n=popNextWanted()
  task.defer(function()playIndex(n)end)
 elseif action=="prev" then
  local n=((math.max(index,1)-2)%#SKATE_PLAYLIST)+1
  task.defer(function()playIndex(n)end)
 elseif action=="clearqueue" then
  table.clear(skateQueue)
  publishQueue()
 end
end)

sound.Ended:Connect(function()
 task.defer(function()playIndex(popNextWanted())end)
end)

publishSkateCatalog()
publishQueue()
playIndex(index)

task.spawn(function()
 while task.wait(1.25) do
  -- Keep only Skatepark at full level; other venue masters are untouched.
  skateGroup.Volume=1.0
  sound.Volume=1.0
  skateGroup:SetAttribute("PlaylistReady",true)
  skateGroup:SetAttribute("PlaylistCount",#SKATE_PLAYLIST)
  if not sound.IsPlaying and not switching then playIndex(popNextWanted()) end
 end
end)

print("[BBYA] Venue audio masters v4.4: Skatepark 8-track request + transport controls active; Rooftop active; VIP isolated")
