-- BBYA SOCIAL HUB - VIP AMAPIANO PLAYLIST AUTHORITY v5
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Players=game:GetService("Players")
local PLAYLIST={
 {title="Wonder Girls - Nobody (ROOKIE Amapiano Edit)",assetId="105859685125263",key="D# minor / Eb minor",camelot="2A"},
 {title="ACC_Audio_1787515147552.mp3",assetId="135466870455541",key="D minor",camelot="7A"},
 {title="ACC_Audio_1787515343208.mp3",assetId="104570664651564",key="F# minor",camelot="11A"}
}

if #PLAYLIST==0 then return end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
if not remotes then remotes=Instance.new("Folder");remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage end
local vipRemote=remotes:FindFirstChild("VIPMusic")
if vipRemote and not vipRemote:IsA("RemoteEvent") then vipRemote:Destroy();vipRemote=nil end
if not vipRemote then vipRemote=Instance.new("RemoteEvent");vipRemote.Name="VIPMusic";vipRemote.Parent=remotes end

local currentIndex=tonumber(ReplicatedStorage:GetAttribute("BBYAVIPCurrentIndex")) or 1
if currentIndex<1 or currentIndex>#PLAYLIST then currentIndex=1 end
local group
local sound
local endedConnection
local lastControl={}

local function currentData()
 local track=PLAYLIST[currentIndex]
 return {venue="VIP",index=currentIndex,title=track.title,assetId=track.assetId,playing=sound and sound.IsPlaying or false,count=#PLAYLIST}
end

local function publishState()
 local track=PLAYLIST[currentIndex]
 ReplicatedStorage:SetAttribute("BBYAVIPTrack01Enabled",true)
 ReplicatedStorage:SetAttribute("BBYAVIPPlaylistId","vip-amapiano")
 ReplicatedStorage:SetAttribute("BBYAVIPPlaylistCount",#PLAYLIST)
 ReplicatedStorage:SetAttribute("BBYAVIPCurrentIndex",currentIndex)
 ReplicatedStorage:SetAttribute("BBYAVIPCurrentTitle",track.title)
 ReplicatedStorage:SetAttribute("BBYAVIPCurrentAssetId",track.assetId)
 ReplicatedStorage:SetAttribute("BBYAVIPTrack01Title",PLAYLIST[1].title)
 ReplicatedStorage:SetAttribute("BBYAVIPTrack01AssetId",PLAYLIST[1].assetId)
end

local function ensureCore()
 group=SoundService:FindFirstChild("BBYAVIPMaster")
 if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end
 if not group then group=Instance.new("SoundGroup");group.Name="BBYAVIPMaster";group.Parent=SoundService end
 group.Volume=.62
 group:SetAttribute("Venue","VIP")
 group:SetAttribute("BBYALocalZoneOnly",true)
 group:SetAttribute("PlaylistReady",true)
 group:SetAttribute("PlaylistCount",#PLAYLIST)
 group:SetAttribute("RecoveryActive",false)
 group:SetAttribute("RecoveryFallbackCount",0)
 group:SetAttribute("MusicCatalogState","VIP_AMAPIANO_ACTIVE")

 local old=SoundService:FindFirstChild("BBYAVIPTrack01")
 if old then old:Destroy() end
 sound=SoundService:FindFirstChild("BBYAVIPPlaylist")
 if sound and not sound:IsA("Sound") then sound:Destroy();sound=nil end
 if not sound then
  sound=Instance.new("Sound")
  sound.Name="BBYAVIPPlaylist"
  sound.Looped=false
  sound.Volume=.72
  sound.Parent=SoundService
 end
 sound.SoundGroup=group
 sound.Looped=false
 sound.Volume=.72
end

local function broadcastState()
 publishState()
 vipRemote:FireAllClients("state",currentData())
end

local function playIndex(index)
 if #PLAYLIST==0 then return end
 currentIndex=((tonumber(index) or 1)-1)%#PLAYLIST+1
 ensureCore()
 local track=PLAYLIST[currentIndex]
 sound:Stop()
 sound.SoundId="rbxassetid://"..track.assetId
 sound.TimePosition=0
 sound:SetAttribute("Title",track.title)
 sound:SetAttribute("Venue","VIP")
 sound:SetAttribute("PlaylistIndex",currentIndex)
 sound:SetAttribute("PlaylistId","vip-amapiano")
 publishState()
 pcall(function()sound:Play()end)
 task.delay(.15,broadcastState)
 print("[BBYA] VIP Amapiano now playing",currentIndex,track.title,track.assetId)
end

local function bindEnded()
 if endedConnection then endedConnection:Disconnect();endedConnection=nil end
 endedConnection=sound.Ended:Connect(function()
  task.defer(function()playIndex(currentIndex%#PLAYLIST+1)end)
 end)
end

local function canControl(player)
 if not player then return false end
 if player:GetAttribute("BBYAAdmin")==true then return true end
 if game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId then return true end
 return false
end

vipRemote.OnServerEvent:Connect(function(player,action,value)
 action=tostring(action or "")
 if action=="list" then
  vipRemote:FireClient(player,"playlist",PLAYLIST)
  vipRemote:FireClient(player,"state",currentData())
  return
 end
 if not canControl(player) then vipRemote:FireClient(player,"toast","REQUEST KHUSUS HOST VIP");return end
 local now=os.clock();if now-(lastControl[player] or 0)<.45 then return end;lastControl[player]=now
 if action=="request" or action=="play" then playIndex(tonumber(value) or currentIndex)
 elseif action=="next" then playIndex(currentIndex%#PLAYLIST+1)
 elseif action=="previous" then playIndex(((currentIndex-2)%#PLAYLIST)+1) end
end)
Players.PlayerRemoving:Connect(function(p)lastControl[p]=nil end)

ensureCore()
bindEnded()
playIndex(currentIndex)

task.spawn(function()
 while task.wait(1) do
  ensureCore()
  publishState()
  group.Volume=.62
  group:SetAttribute("PlaylistReady",true)
  group:SetAttribute("PlaylistCount",#PLAYLIST)
  if sound and not sound.IsPlaying then pcall(function()sound:Play()end) end
 end
end)

print("[BBYA] VIP Amapiano playlist authority v5 online; tracks",#PLAYLIST)
