-- BBYA SOCIAL HUB — FUNKOT UPLOADER REGISTRY SHIM v6
-- Intentionally no Funkot playback. Runtime authority is 93-funkot-music.server.lua.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
ReplicatedStorage:SetAttribute("BBYAFunkotUploaderRegistryShim",true)
ReplicatedStorage:SetAttribute("BBYAFunkotRegistryTrackCount",3)
print("[BBYA] Funkot uploader registry shim v6; verified registry only")

-- BBYA SOCIAL HUB — MALL KPOP PLAYLIST AUTHORITY v2
-- Dedicated Mall-only 18-track KPOP bank.
-- AUTOPLAY + RANDOM NO-REPEAT SHUFFLE + self-healing SoundService output.
-- Source audio was prepared at 1.75x; PlaybackSpeed restores intended listening speed.
local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")
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

local group
local master
local endedConnection
local switching=false
local currentIndex=math.random(1,#PLAYLIST)
local queue={}
local cooldown={}
local shuffleBag={}

local function ensureCore()
 group=SoundService:FindFirstChild("BBYAMallMaster")
 if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end
 if not group then group=Instance.new("SoundGroup");group.Name="BBYAMallMaster";group.Parent=SoundService end
 group.Volume=.86
 group:SetAttribute("Venue","MALL")
 group:SetAttribute("BBYALocalZoneOnly",true)
 group:SetAttribute("PlaylistReady",true)
 group:SetAttribute("PlaylistCount",#PLAYLIST)
 group:SetAttribute("MusicCatalogState","MALL_KPOP_RANDOM_AUTOPLAY_V2")
 group:SetAttribute("AutoPlay",true)
 group:SetAttribute("ShuffleMode","RANDOM_NO_REPEAT_CYCLE")
 group:SetAttribute("PlaybackSpeed",PLAYBACK_SPEED)

 local found=SoundService:FindFirstChild("BBYAMallMasterSound")
 if found and not found:IsA("Sound") then found:Destroy();found=nil end
 if not found then found=Instance.new("Sound");found.Name="BBYAMallMasterSound";found.Parent=SoundService end
 if master~=found then
  if endedConnection then endedConnection:Disconnect();endedConnection=nil end
  master=found
 end
 master.SoundGroup=group
 master.Volume=.78
 master.Looped=false
 master.PlaybackSpeed=PLAYBACK_SPEED
 master:SetAttribute("Venue","MALL")
 master:SetAttribute("Bank","KPOP")
 master:SetAttribute("AutoPlay",true)
 master:SetAttribute("ShuffleMode","RANDOM_NO_REPEAT_CYCLE")
 return group,master
end

local function publishCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYAMallPlaylistCatalog")
 if folder and not folder:IsA("Folder") then folder:Destroy();folder=nil end
 if not folder then folder=Instance.new("Folder");folder.Name="BBYAMallPlaylistCatalog";folder.Parent=ReplicatedStorage end
 folder:SetAttribute("PlaylistId","mall-kpop-random")
 folder:SetAttribute("Venue","MALL")
 folder:SetAttribute("Bank","KPOP")
 folder:SetAttribute("Count",#PLAYLIST)
 folder:SetAttribute("ControlRemote","BBYAMallMusicControl")
 folder:SetAttribute("PlaybackSpeed",PLAYBACK_SPEED)
 folder:SetAttribute("AutoPlay",true)
 folder:SetAttribute("ShuffleMode","RANDOM_NO_REPEAT_CYCLE")
 for i,t in ipairs(PLAYLIST) do
  local name="Track"..tostring(i)
  local entry=folder:FindFirstChild(name)
  if entry and not entry:IsA("StringValue") then entry:Destroy();entry=nil end
  if not entry then entry=Instance.new("StringValue");entry.Name=name;entry.Parent=folder end
  entry.Value=t.title
  entry:SetAttribute("Index",i)
  entry:SetAttribute("AssetId",t.assetId)
  entry:SetAttribute("PlaybackSpeed",PLAYBACK_SPEED)
  entry:SetAttribute("Artist","KPOP")
 end
 for _,entry in ipairs(folder:GetChildren()) do
  local i=tonumber(entry:GetAttribute("Index"))
  if not i or i<1 or i>#PLAYLIST then entry:Destroy() end
 end
end

local function shuffle(t)
 for i=#t,2,-1 do
  local j=math.random(1,i)
  t[i],t[j]=t[j],t[i]
 end
end

local function refillBag()
 local bag={}
 for i=1,#PLAYLIST do if i~=currentIndex then table.insert(bag,i) end end
 shuffle(bag)
 shuffleBag=bag
end

local function removeCurrentFromBag()
 for i=#shuffleBag,1,-1 do
  if shuffleBag[i]==currentIndex then table.remove(shuffleBag,i) end
 end
 if #shuffleBag==0 then refillBag() end
end

local function inZone(player)
 local c=player and player.Character
 local h=c and c:FindFirstChild("HumanoidRootPart")
 if not h then return false end
 local p=h.Position
 return p.X>=-96 and p.X<=96 and p.Y>=-4 and p.Y<=70 and p.Z>=287 and p.Z<=443
end

local function isAdmin(player)
 return player and (player:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId))
end

local function publishQueue()
 ReplicatedStorage:SetAttribute("BBYAMallQueueCount",#queue)
 ReplicatedStorage:SetAttribute("BBYAMallNextRequestIndex",tonumber(queue[1]) or 0)
end

local function publishState()
 ensureCore()
 removeCurrentFromBag()
 local t=PLAYLIST[currentIndex]
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistEnabled",true)
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistId","mall-kpop-random")
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistBank","KPOP")
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistCount",#PLAYLIST)
 ReplicatedStorage:SetAttribute("BBYAMallCurrentIndex",currentIndex)
 ReplicatedStorage:SetAttribute("BBYAMallCurrentTitle",t.title)
 ReplicatedStorage:SetAttribute("BBYAMallCurrentAssetId",t.assetId)
 ReplicatedStorage:SetAttribute("BBYAMallPlaybackSpeed",PLAYBACK_SPEED)
 ReplicatedStorage:SetAttribute("BBYAMallAutoPlay",true)
 ReplicatedStorage:SetAttribute("BBYAMallShuffleMode","RANDOM_NO_REPEAT_CYCLE")
 ReplicatedStorage:SetAttribute("BBYAMallAutoNextIndex",tonumber(shuffleBag[1]) or 0)
 ReplicatedStorage:SetAttribute("BBYAMallShuffleRemaining",#shuffleBag)
 group:SetAttribute("CurrentIndex",currentIndex)
 group:SetAttribute("CurrentTitle",t.title)
 group:SetAttribute("CurrentAssetId",t.assetId)
 group:SetAttribute("AutoNextIndex",tonumber(shuffleBag[1]) or 0)
 publishQueue()
end

local function popNext()
 if #queue>0 then
  local wanted=table.remove(queue,1)
  publishQueue()
  return wanted
 end
 if #shuffleBag==0 then refillBag() end
 local wanted=table.remove(shuffleBag,1)
 if not wanted or wanted==currentIndex then
  refillBag();wanted=table.remove(shuffleBag,1)
 end
 return wanted or ((currentIndex%#PLAYLIST)+1)
end

local function waitLoaded(timeout)
 local deadline=os.clock()+(timeout or 7)
 while os.clock()<deadline do
  if master and master.Parent and master.IsLoaded and (master.TimeLength or 0)>.2 then return true end
  task.wait(.12)
 end
 return master and master.Parent and master.IsLoaded
end

local function playIndex(wanted)
 if switching then return false end
 switching=true
 ensureCore()
 local start=((tonumber(wanted) or 1)-1)%#PLAYLIST+1
 local candidate=start
 local tried=0
 while tried<#PLAYLIST do
  currentIndex=candidate
  removeCurrentFromBag()
  local t=PLAYLIST[currentIndex]
  master:Stop()
  master.SoundId="rbxassetid://"..t.assetId
  master.PlaybackSpeed=PLAYBACK_SPEED
  master.TimePosition=0
  master:SetAttribute("Title",t.title)
  master:SetAttribute("PlaylistIndex",currentIndex)
  master:SetAttribute("PlaylistId","mall-kpop-random")
  master:SetAttribute("Bank","KPOP")
  publishState()
  local preloadOk=pcall(function()ContentProvider:PreloadAsync({master})end)
  if preloadOk and waitLoaded(7) then
   local ok=pcall(function()master:Play()end)
   if ok then
    group:SetAttribute("LastStartOk",true)
    group:SetAttribute("LastStartTitle",t.title)
    switching=false
    print("[BBYA] Mall KPOP AUTO PLAY",currentIndex,t.title,t.assetId,"speed",PLAYBACK_SPEED)
    return true
   end
  end
  group:SetAttribute("LastStartOk",false)
  group:SetAttribute("LastUnavailableTitle",t.title)
  group:SetAttribute("LastUnavailableAssetId",t.assetId)
  candidate=popNext()
  tried+=1
 end
 switching=false
 warn("[BBYA] Mall KPOP: no approved track could start")
 return false
end

local function bindEnded()
 if endedConnection then endedConnection:Disconnect();endedConnection=nil end
 ensureCore()
 endedConnection=master.Ended:Connect(function()
  task.defer(function()
   playIndex(popNext())
   bindEnded()
  end)
 end)
end

control.OnServerEvent:Connect(function(player,action,wanted)
 action=tostring(action or "")
 if action=="request" then
  if not inZone(player) then return end
  local n=tonumber(wanted)
  if not n or not PLAYLIST[n] then return end
  local now=os.clock()
  if now-(cooldown[player.UserId] or 0)<3 then return end
  cooldown[player.UserId]=now
  table.insert(queue,n)
  publishQueue()
  if not (master and master.Parent and master.IsPlaying) and not switching then
   task.defer(function()playIndex(popNext());bindEnded()end)
  end
  return
 end
 if not isAdmin(player) then return end
 if action=="next" then
  task.defer(function()playIndex(popNext());bindEnded()end)
 elseif action=="prev" or action=="previous" then
  task.defer(function()playIndex(popNext());bindEnded()end)
 elseif action=="play" then
  local n=tonumber(wanted)
  if n and PLAYLIST[n] then task.defer(function()playIndex(n);bindEnded()end) end
 elseif action=="random" or action=="remix" then
  task.defer(function()playIndex(popNext());bindEnded()end)
 elseif action=="clearqueue" then
  table.clear(queue);publishQueue()
 end
end)

Players.PlayerRemoving:Connect(function(player)cooldown[player.UserId]=nil end)

ensureCore()
publishCatalog()
publishQueue()
refillBag()
playIndex(currentIndex)
bindEnded()

task.spawn(function()
 while task.wait(.5) do
  ensureCore()
  group.Volume=.86
  master.Volume=.78
  master.PlaybackSpeed=PLAYBACK_SPEED
  group:SetAttribute("PlaylistReady",true)
  group:SetAttribute("PlaylistCount",#PLAYLIST)
  publishCatalog()
  publishState()
  local expected="rbxassetid://"..PLAYLIST[currentIndex].assetId
  if master.SoundId~=expected or master.SoundId=="" then
   playIndex(currentIndex);bindEnded()
  elseif not master.IsPlaying and not switching then
   local atEnd=false
   pcall(function()atEnd=master.TimeLength>0 and master.TimePosition>=math.max(0,master.TimeLength-.25)end)
   if atEnd then playIndex(popNext());bindEnded() else pcall(function()master:Play()end) end
  end
 end
end)

print("[BBYA] Mall KPOP authority v2 online: 18 tracks, AUTOPLAY, RANDOM NO-REPEAT, PlaybackSpeed 0.5714285714, self-healing SoundService output")
