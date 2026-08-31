-- BBYA SOCIAL HUB — ROOFTOP TROPICAL PLAYLIST AUTHORITY v7
-- Four physical corner speaker blocks + one canonical seamless master clock.
-- Self-healing runtime plus server-authoritative request / PREV / NEXT controls for the premium Music Suite.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")
local Players=game:GetService("Players")

local PLAYLIST={
 {title="Damon Empero ft. Veronica - Vacation | Tropical House | - Damon Empero",assetId="81739335079331"},
 {title="Rolipso - Come Around (Lyrics) - Sensual Musique",assetId="102905513042645"},
 {title="Dovian - Starting Over (Lyrics) - Sensual Musique",assetId="80455951712097"}
}
if #PLAYLIST==0 then return end

local SPEAKER_SPECS={
 {name="BBYARooftopSpeakerBlock1",pos=Vector3.new(47,47.55,-34)},
 {name="BBYARooftopSpeakerBlock2",pos=Vector3.new(-47,47.55,-34)},
 {name="BBYARooftopSpeakerBlock3",pos=Vector3.new(47,47.55,34)},
 {name="BBYARooftopSpeakerBlock4",pos=Vector3.new(-47,47.55,34)},
}

local control=ReplicatedStorage:FindFirstChild("BBYARooftopMusicControl")
if control and not control:IsA("RemoteEvent") then control:Destroy();control=nil end
if not control then control=Instance.new("RemoteEvent");control.Name="BBYARooftopMusicControl";control.Parent=ReplicatedStorage end

local currentIndex=tonumber(ReplicatedStorage:GetAttribute("BBYARooftopCurrentIndex")) or 1
if currentIndex<1 or currentIndex>#PLAYLIST then currentIndex=1 end
local group
local speakerRoot
local speakers={}
local masterSound
local endedConnection
local recovering=false
local queue={}
local requestCooldown={}

local function inZone(player)
 local c=player and player.Character
 local h=c and c:FindFirstChild("HumanoidRootPart")
 if not h then return false end
 local p=h.Position
 return p.Y>=40 and p.Y<=60 and math.abs(p.X)<=62 and p.Z>=-48 and p.Z<=48
end

local function isAdmin(player)
 return player and (player:GetAttribute("BBYAAdmin")==true
  or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId))
end

local function publishQueue()
 local count=#queue
 local nextIndex=tonumber(queue[1]) or 0
 ReplicatedStorage:SetAttribute("BBYARooftopQueueCount",count)
 ReplicatedStorage:SetAttribute("BBYARooftopNextRequestIndex",nextIndex)
 if group then
  group:SetAttribute("QueueCount",count)
  group:SetAttribute("NextRequestIndex",nextIndex)
 end
end

local function publishCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYARooftopPlaylistCatalog")
 if folder and not folder:IsA("Folder") then folder:Destroy();folder=nil end
 if not folder then folder=Instance.new("Folder");folder.Name="BBYARooftopPlaylistCatalog";folder.Parent=ReplicatedStorage end
 folder:SetAttribute("PlaylistId","rooftop-tropical")
 folder:SetAttribute("Venue","ROOFTOP")
 folder:SetAttribute("Count",#PLAYLIST)
 folder:SetAttribute("ControlRemote","BBYARooftopMusicControl")
 for i,t in ipairs(PLAYLIST) do
  local name="Track"..tostring(i)
  local entry=folder:FindFirstChild(name)
  if entry and not entry:IsA("StringValue") then entry:Destroy();entry=nil end
  if not entry then entry=Instance.new("StringValue");entry.Name=name;entry.Parent=folder end
  entry.Value=t.title
  entry:SetAttribute("Index",i)
  entry:SetAttribute("AssetId",t.assetId)
  entry:SetAttribute("PlaybackSpeed",1)
 end
 for _,entry in ipairs(folder:GetChildren()) do
  local i=tonumber(entry:GetAttribute("Index"))
  if not i or i<1 or i>#PLAYLIST then entry:Destroy() end
 end
end

local function ensureToneEQ()
 local eq=group:FindFirstChild("BBYARooftopToneEQV7") or group:FindFirstChild("BBYARooftopToneEQV6") or group:FindFirstChild("BBYARooftopToneEQV5") or group:FindFirstChild("BBYARooftopToneEQV4")
 if eq and not eq:IsA("EqualizerSoundEffect") then eq:Destroy();eq=nil end
 if not eq then eq=Instance.new("EqualizerSoundEffect");eq.Parent=group end
 eq.Name="BBYARooftopToneEQV7"
 eq.Enabled=true
 eq.LowGain=3.2
 eq.MidGain=-1.0
 eq.HighGain=-2.6
 return eq
end

local function ensureSpeakers()
 local legacy=Workspace:FindFirstChild("BBYARooftopSpeakerBlock")
 if legacy then legacy:Destroy() end
 speakerRoot=Workspace:FindFirstChild("BBYARooftopSpeakerArrayV4")
 if speakerRoot and not speakerRoot:IsA("Folder") then speakerRoot:Destroy();speakerRoot=nil end
 if not speakerRoot then speakerRoot=Instance.new("Folder");speakerRoot.Name="BBYARooftopSpeakerArrayV4";speakerRoot.Parent=Workspace end
 speakerRoot:SetAttribute("Venue","ROOFTOP")
 speakerRoot:SetAttribute("SpeakerCount",#SPEAKER_SPECS)
 speakerRoot:SetAttribute("AudioProfile","WARM_SEAMLESS_SELF_HEAL_V7")
 table.clear(speakers)
 for i,spec in ipairs(SPEAKER_SPECS) do
  local p=speakerRoot:FindFirstChild(spec.name)
  if p and not p:IsA("Part") then p:Destroy();p=nil end
  if not p then p=Instance.new("Part");p.Name=spec.name;p.Parent=speakerRoot end
  p.Size=Vector3.new(2.8,4.2,2.8)
  p.CFrame=CFrame.lookAt(spec.pos,Vector3.new(0,spec.pos.Y,0))
  p.Anchored=true;p.CanCollide=true;p.CanTouch=true;p.CanQuery=true
  p.Material=Enum.Material.Metal;p.Color=Color3.fromRGB(27,28,32)
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  p:SetAttribute("Venue","ROOFTOP")
  p:SetAttribute("Purpose","ROOM_SPEAKER_VISUAL_MASTER_CLOCK")
  p:SetAttribute("SpeakerIndex",i)
  for _,child in ipairs(p:GetChildren()) do
   if child:IsA("Sound") then pcall(function()child:Stop()end);child:Destroy() end
  end
  table.insert(speakers,p)
 end
end

local function ensureMasterSound()
 local created=false
 local old=SoundService:FindFirstChild("BBYARooftopPlaylist")
 if old and old~=masterSound then pcall(function()old:Stop()end);old:Destroy() end
 local found=SoundService:FindFirstChild("BBYARooftopMasterSound")
 if found and not found:IsA("Sound") then found:Destroy();found=nil end
 if not found then
  found=Instance.new("Sound")
  found.Name="BBYARooftopMasterSound"
  found.Parent=SoundService
  created=true
 end
 if masterSound~=found then created=true end
 masterSound=found
 masterSound.SoundGroup=group
 masterSound.Looped=false
 masterSound.Volume=.72
 masterSound.PlaybackSpeed=1
 masterSound:SetAttribute("Venue","ROOFTOP")
 masterSound:SetAttribute("SeamlessMasterClock",true)
 masterSound:SetAttribute("SelfHealing",true)
 return created
end

local function publishState()
 local t=PLAYLIST[currentIndex]
 ReplicatedStorage:SetAttribute("BBYARooftopPlaylistEnabled",true)
 ReplicatedStorage:SetAttribute("BBYARooftopPlaylistId","rooftop-tropical")
 ReplicatedStorage:SetAttribute("BBYARooftopPlaylistCount",#PLAYLIST)
 ReplicatedStorage:SetAttribute("BBYARooftopCurrentIndex",currentIndex)
 ReplicatedStorage:SetAttribute("BBYARooftopCurrentTitle",t.title)
 ReplicatedStorage:SetAttribute("BBYARooftopCurrentAssetId",t.assetId)
 publishQueue()
 if group then
  group:SetAttribute("CurrentIndex",currentIndex)
  group:SetAttribute("CurrentTitle",t.title)
  group:SetAttribute("CurrentAssetId",t.assetId)
  group:SetAttribute("SpeakerCount",#speakers)
  group:SetAttribute("PlaybackTopology","SINGLE_MASTER_CLOCK_SELF_HEAL_CONTROLS_V7")
 end
 if speakerRoot then
  speakerRoot:SetAttribute("CurrentIndex",currentIndex)
  speakerRoot:SetAttribute("CurrentTitle",t.title)
  speakerRoot:SetAttribute("CurrentAssetId",t.assetId)
 end
 for _,p in ipairs(speakers) do
  p:SetAttribute("CurrentIndex",currentIndex)
  p:SetAttribute("CurrentTitle",t.title)
  p:SetAttribute("CurrentAssetId",t.assetId)
 end
end

local function ensureCore()
 group=SoundService:FindFirstChild("BBYARooftopMaster")
 if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end
 if not group then group=Instance.new("SoundGroup");group.Name="BBYARooftopMaster";group.Parent=SoundService end
 group.Volume=.86
 group:SetAttribute("Venue","ROOFTOP")
 group:SetAttribute("BBYALocalZoneOnly",true)
 group:SetAttribute("PlaylistReady",true)
 group:SetAttribute("PlaylistCount",#PLAYLIST)
 group:SetAttribute("MusicCatalogState","ROOFTOP_TROPICAL_SELF_HEAL_CONTROLS_V7")
 ensureToneEQ();ensureSpeakers();local created=ensureMasterSound();publishCatalog();publishQueue()
 return created
end

local function popNextWanted()
 if #queue>0 then
  local wanted=table.remove(queue,1)
  publishQueue()
  return wanted
 end
 return currentIndex%#PLAYLIST+1
end

local function loadCurrent(resetPosition)
 currentIndex=((tonumber(currentIndex) or 1)-1)%#PLAYLIST+1
 local t=PLAYLIST[currentIndex]
 if not masterSound or not masterSound.Parent then ensureCore() end
 masterSound:Stop()
 masterSound.SoundId="rbxassetid://"..t.assetId
 if resetPosition then masterSound.TimePosition=0 end
 masterSound:SetAttribute("Title",t.title)
 masterSound:SetAttribute("PlaylistIndex",currentIndex)
 masterSound:SetAttribute("PlaylistId","rooftop-tropical")
 publishState()
 pcall(function()masterSound:Play()end)
end

local function playIndex(wanted)
 local n=tonumber(wanted)
 if not n or not PLAYLIST[n] then return end
 currentIndex=n
 loadCurrent(true)
end

local function bindEnded()
 if endedConnection then endedConnection:Disconnect();endedConnection=nil end
 if not masterSound or not masterSound.Parent then return end
 endedConnection=masterSound.Ended:Connect(function()
  task.defer(function()
   currentIndex=popNextWanted()
   loadCurrent(true)
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
  if now-(requestCooldown[player.UserId] or 0)<3 then return end
  requestCooldown[player.UserId]=now
  table.insert(queue,n)
  publishQueue()
  if not masterSound or not masterSound.IsPlaying then
   currentIndex=popNextWanted()
   loadCurrent(true)
   bindEnded()
  end
  return
 end
 if not isAdmin(player) then return end
 if action=="next" then
  currentIndex=popNextWanted();loadCurrent(true);bindEnded()
 elseif action=="prev" or action=="previous" then
  currentIndex=((currentIndex-2)%#PLAYLIST)+1;loadCurrent(true);bindEnded()
 elseif action=="play" then
  playIndex(wanted);bindEnded()
 elseif action=="clearqueue" then
  table.clear(queue);publishQueue()
 end
end)

Players.PlayerRemoving:Connect(function(player)requestCooldown[player.UserId]=nil end)

ensureCore();publishQueue();loadCurrent(true);bindEnded()

task.spawn(function()
 while task.wait(.50) do
  local wasLost=not (masterSound and masterSound.Parent)
  local recreated=ensureCore()
  group.Volume=.86
  group:SetAttribute("PlaylistReady",true)
  group:SetAttribute("PlaylistCount",#PLAYLIST)
  publishState()

  local expected="rbxassetid://"..PLAYLIST[currentIndex].assetId
  if wasLost or recreated or not masterSound or not masterSound.Parent or masterSound.SoundId~=expected or masterSound.SoundId=="" then
   if not recovering then
    recovering=true
    pcall(function()loadCurrent(true);bindEnded()end)
    recovering=false
   end
  elseif not masterSound.IsPlaying then
   local atEnd=false
   pcall(function()
    atEnd=masterSound.TimeLength>0 and masterSound.TimePosition>=math.max(0,masterSound.TimeLength-.25)
   end)
   if atEnd then
    currentIndex=popNextWanted()
    loadCurrent(true)
    bindEnded()
   else
    pcall(function()masterSound:Play()end)
   end
  end
 end
end)

print("[BBYA] Rooftop authority v7 online; 3-track catalog + request/PREV/NEXT controls + self-heal")
