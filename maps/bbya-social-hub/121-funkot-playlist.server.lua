-- BBYA SOCIAL HUB — FUNKOT UPLOADER REGISTRY SHIM v6
-- Intentionally no Funkot playback. Runtime authority is 93-funkot-music.server.lua.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
ReplicatedStorage:SetAttribute("BBYAFunkotUploaderRegistryShim",true)
ReplicatedStorage:SetAttribute("BBYAFunkotRegistryTrackCount",3)
print("[BBYA] Funkot uploader registry shim v6; verified registry only")

-- BBYA SOCIAL HUB — MALL KPOP PLAYLIST AUTHORITY v1
-- Dedicated Mall-only 18-track KPOP bank. This block does not reuse or mutate any Club/Funkot playlist.
-- Source audio was prepared at 1.75x; PlaybackSpeed restores intended listening speed.
local SoundService=game:GetService("SoundService")
local Players=game:GetService("Players")
local PLAYBACK_SPEED=0.5714285714
local PLAYLIST={
 {title="HANTU",assetId="130787669922537"},
 {title="MALU BANGET",assetId="128649936033154"},
 {title="STRATEGI KU",assetId="87125114946473"},
 {title="DI JATUHKAN",assetId="138472779676021"},
 {title="MEMULAI SEBELAHMU",assetId="115164716109234"},
 {title="TOPIK",assetId="106731979070100"},
 {title="MERAH MUDA",assetId="82573111697282"},
 {title="YA TUHAN",assetId="84541295288456"},
 {title="MALAM YANG SEMPURNA",assetId="112025968048348"},
 {title="KEREN",assetId="102724403050017"},
 {title="SEPERTI GILA",assetId="101221026959656"},
 {title="TERKENAL",assetId="102729376941557"},
 {title="AKU",assetId="130045741934771"},
 {title="EMAS",assetId="94909694876329"},
 {title="DITOK",assetId="128638509475237"},
 {title="AKU DAN KAMU",assetId="115814496839320"},
 {title="BUNGA",assetId="134192777315026"},
 {title="SATU ATAU DELAPAN",assetId="85568242991971"},
}

local control=ReplicatedStorage:FindFirstChild("BBYAMallMusicControl")
if control and not control:IsA("RemoteEvent") then control:Destroy();control=nil end
if not control then control=Instance.new("RemoteEvent");control.Name="BBYAMallMusicControl";control.Parent=ReplicatedStorage end

local group=SoundService:FindFirstChild("BBYAMallMaster")
if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end
if not group then group=Instance.new("SoundGroup");group.Name="BBYAMallMaster";group.Parent=SoundService end
group.Volume=.78
group:SetAttribute("Venue","MALL")
group:SetAttribute("BBYALocalZoneOnly",true)
group:SetAttribute("PlaylistReady",true)
group:SetAttribute("PlaylistCount",#PLAYLIST)
group:SetAttribute("MusicCatalogState","MALL_KPOP_V1")

local master=SoundService:FindFirstChild("BBYAMallMasterSound")
if master and not master:IsA("Sound") then master:Destroy();master=nil end
if not master then master=Instance.new("Sound");master.Name="BBYAMallMasterSound";master.Parent=SoundService end
master.SoundGroup=group;master.Volume=.68;master.Looped=false;master.PlaybackSpeed=PLAYBACK_SPEED
master:SetAttribute("Venue","MALL");master:SetAttribute("Bank","KPOP")

local function publishCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYAMallPlaylistCatalog")
 if folder and not folder:IsA("Folder") then folder:Destroy();folder=nil end
 if not folder then folder=Instance.new("Folder");folder.Name="BBYAMallPlaylistCatalog";folder.Parent=ReplicatedStorage end
 folder:SetAttribute("PlaylistId","mall-kpop");folder:SetAttribute("Venue","MALL");folder:SetAttribute("Bank","KPOP")
 folder:SetAttribute("Count",#PLAYLIST);folder:SetAttribute("ControlRemote","BBYAMallMusicControl");folder:SetAttribute("PlaybackSpeed",PLAYBACK_SPEED)
 for i,t in ipairs(PLAYLIST) do
  local name="Track"..tostring(i);local entry=folder:FindFirstChild(name)
  if entry and not entry:IsA("StringValue") then entry:Destroy();entry=nil end
  if not entry then entry=Instance.new("StringValue");entry.Name=name;entry.Parent=folder end
  entry.Value=t.title;entry:SetAttribute("Index",i);entry:SetAttribute("AssetId",t.assetId);entry:SetAttribute("PlaybackSpeed",PLAYBACK_SPEED);entry:SetAttribute("Artist","KPOP")
 end
 for _,entry in ipairs(folder:GetChildren()) do local i=tonumber(entry:GetAttribute("Index"));if not i or i<1 or i>#PLAYLIST then entry:Destroy() end end
end

local currentIndex=tonumber(ReplicatedStorage:GetAttribute("BBYAMallCurrentIndex")) or 1
if currentIndex<1 or currentIndex>#PLAYLIST then currentIndex=1 end
local queue={};local cooldown={};local endedConnection

local function inZone(player)
 local c=player and player.Character;local h=c and c:FindFirstChild("HumanoidRootPart")
 if not h then return false end
 local p=h.Position
 return p.X>=-96 and p.X<=96 and p.Y>=-4 and p.Y<=70 and p.Z>=287 and p.Z<=443
end
local function isAdmin(player)
 return player and (player:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId))
end
local function publishQueue()
 ReplicatedStorage:SetAttribute("BBYAMallQueueCount",#queue);ReplicatedStorage:SetAttribute("BBYAMallNextRequestIndex",tonumber(queue[1]) or 0)
end
local function publishState()
 local t=PLAYLIST[currentIndex]
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistEnabled",true);ReplicatedStorage:SetAttribute("BBYAMallPlaylistId","mall-kpop");ReplicatedStorage:SetAttribute("BBYAMallPlaylistBank","KPOP")
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistCount",#PLAYLIST);ReplicatedStorage:SetAttribute("BBYAMallCurrentIndex",currentIndex);ReplicatedStorage:SetAttribute("BBYAMallCurrentTitle",t.title)
 ReplicatedStorage:SetAttribute("BBYAMallCurrentAssetId",t.assetId);ReplicatedStorage:SetAttribute("BBYAMallPlaybackSpeed",PLAYBACK_SPEED)
 group:SetAttribute("CurrentIndex",currentIndex);group:SetAttribute("CurrentTitle",t.title);group:SetAttribute("CurrentAssetId",t.assetId);publishQueue()
end
local function popNext()
 if #queue>0 then local wanted=table.remove(queue,1);publishQueue();return wanted end
 return currentIndex%#PLAYLIST+1
end
local function loadCurrent()
 currentIndex=((tonumber(currentIndex) or 1)-1)%#PLAYLIST+1
 local t=PLAYLIST[currentIndex];master:Stop();master.SoundId="rbxassetid://"..t.assetId;master.PlaybackSpeed=PLAYBACK_SPEED;master.TimePosition=0
 master:SetAttribute("Title",t.title);master:SetAttribute("PlaylistIndex",currentIndex);master:SetAttribute("PlaylistId","mall-kpop");master:SetAttribute("Bank","KPOP")
 publishState();pcall(function()master:Play()end)
end
local function bindEnded()
 if endedConnection then endedConnection:Disconnect();endedConnection=nil end
 endedConnection=master.Ended:Connect(function()currentIndex=popNext();loadCurrent();bindEnded()end)
end

control.OnServerEvent:Connect(function(player,action,wanted)
 action=tostring(action or "")
 if action=="request" then
  if not inZone(player) then return end
  local n=tonumber(wanted);if not n or not PLAYLIST[n] then return end
  local now=os.clock();if now-(cooldown[player.UserId] or 0)<3 then return end
  cooldown[player.UserId]=now;table.insert(queue,n);publishQueue()
  if not master.IsPlaying then currentIndex=popNext();loadCurrent();bindEnded() end
  return
 end
 if not isAdmin(player) then return end
 if action=="next" then currentIndex=popNext();loadCurrent();bindEnded()
 elseif action=="prev" or action=="previous" then currentIndex=((currentIndex-2)%#PLAYLIST)+1;loadCurrent();bindEnded()
 elseif action=="play" then local n=tonumber(wanted);if n and PLAYLIST[n] then currentIndex=n;loadCurrent();bindEnded() end
 elseif action=="clearqueue" then table.clear(queue);publishQueue() end
end)
Players.PlayerRemoving:Connect(function(player)cooldown[player.UserId]=nil end)

publishCatalog();publishQueue();loadCurrent();bindEnded()
task.spawn(function()
 while task.wait(.5) do
  group.Volume=.78;group:SetAttribute("PlaylistReady",true);group:SetAttribute("PlaylistCount",#PLAYLIST);publishCatalog();publishState()
  local expected="rbxassetid://"..PLAYLIST[currentIndex].assetId
  if master.SoundGroup~=group then master.SoundGroup=group end
  if math.abs(master.PlaybackSpeed-PLAYBACK_SPEED)>.000001 then master.PlaybackSpeed=PLAYBACK_SPEED end
  if master.SoundId~=expected or master.SoundId=="" then loadCurrent();bindEnded()
  elseif not master.IsPlaying then
   local atEnd=false;pcall(function()atEnd=master.TimeLength>0 and master.TimePosition>=math.max(0,master.TimeLength-.25)end)
   if atEnd then currentIndex=popNext();loadCurrent();bindEnded() else pcall(function()master:Play()end) end
  end
 end
end)
print("[BBYA] Mall KPOP authority v1 online: MALL-only catalog, 18 tracks, PlaybackSpeed 0.5714285714")
