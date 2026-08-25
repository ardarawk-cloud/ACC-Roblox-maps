-- BBYA SOCIAL HUB — ROOFTOP TROPICAL PLAYLIST AUTHORITY v5
-- Four physical corner speaker blocks, one canonical master playback clock.
-- This removes side-to-side drift/delay caused by four independent Sound instances.
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")

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

local currentIndex=tonumber(ReplicatedStorage:GetAttribute("BBYARooftopCurrentIndex")) or 1
if currentIndex<1 or currentIndex>#PLAYLIST then currentIndex=1 end
local group
local speakerRoot
local speakers={}
local masterSound
local endedConnection

local function publishCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYARooftopPlaylistCatalog")
 if folder and not folder:IsA("Folder") then folder:Destroy();folder=nil end
 if not folder then folder=Instance.new("Folder");folder.Name="BBYARooftopPlaylistCatalog";folder.Parent=ReplicatedStorage end
 folder:SetAttribute("PlaylistId","rooftop-tropical")
 folder:SetAttribute("Count",#PLAYLIST)
 for i,t in ipairs(PLAYLIST) do
  local name="Track"..tostring(i)
  local entry=folder:FindFirstChild(name)
  if entry and not entry:IsA("StringValue") then entry:Destroy();entry=nil end
  if not entry then entry=Instance.new("StringValue");entry.Name=name;entry.Parent=folder end
  entry.Value=t.title
  entry:SetAttribute("Index",i)
  entry:SetAttribute("AssetId",t.assetId)
 end
 for _,entry in ipairs(folder:GetChildren()) do
  local i=tonumber(entry:GetAttribute("Index"))
  if not i or i<1 or i>#PLAYLIST then entry:Destroy() end
 end
end

local function ensureToneEQ()
 local eq=group:FindFirstChild("BBYARooftopToneEQV5") or group:FindFirstChild("BBYARooftopToneEQV4")
 if eq and not eq:IsA("EqualizerSoundEffect") then eq:Destroy();eq=nil end
 if not eq then eq=Instance.new("EqualizerSoundEffect");eq.Parent=group end
 eq.Name="BBYARooftopToneEQV5"
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
 speakerRoot:SetAttribute("AudioProfile","WARM_SEAMLESS_MASTER_V5")
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
  -- Remove legacy independent emitters: one master Sound prevents drift/delay.
  for _,child in ipairs(p:GetChildren()) do
   if child:IsA("Sound") then pcall(function()child:Stop()end);child:Destroy() end
  end
  table.insert(speakers,p)
 end
end

local function ensureMasterSound()
 local old=SoundService:FindFirstChild("BBYARooftopPlaylist")
 if old and old~=masterSound then pcall(function()old:Stop()end);old:Destroy() end
 masterSound=SoundService:FindFirstChild("BBYARooftopMasterSound")
 if masterSound and not masterSound:IsA("Sound") then masterSound:Destroy();masterSound=nil end
 if not masterSound then masterSound=Instance.new("Sound");masterSound.Name="BBYARooftopMasterSound";masterSound.Parent=SoundService end
 masterSound.SoundGroup=group
 masterSound.Looped=false
 masterSound.Volume=.72
 masterSound.PlaybackSpeed=1
 masterSound:SetAttribute("Venue","ROOFTOP")
 masterSound:SetAttribute("SeamlessMasterClock",true)
 return masterSound
end

local function publishState()
 local t=PLAYLIST[currentIndex]
 ReplicatedStorage:SetAttribute("BBYARooftopPlaylistEnabled",true)
 ReplicatedStorage:SetAttribute("BBYARooftopPlaylistId","rooftop-tropical")
 ReplicatedStorage:SetAttribute("BBYARooftopPlaylistCount",#PLAYLIST)
 ReplicatedStorage:SetAttribute("BBYARooftopCurrentIndex",currentIndex)
 ReplicatedStorage:SetAttribute("BBYARooftopCurrentTitle",t.title)
 ReplicatedStorage:SetAttribute("BBYARooftopCurrentAssetId",t.assetId)
 if group then
  group:SetAttribute("CurrentIndex",currentIndex)
  group:SetAttribute("CurrentTitle",t.title)
  group:SetAttribute("CurrentAssetId",t.assetId)
  group:SetAttribute("SpeakerCount",#speakers)
  group:SetAttribute("PlaybackTopology","SINGLE_MASTER_CLOCK")
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
 group:SetAttribute("MusicCatalogState","ROOFTOP_TROPICAL_SEAMLESS_V5")
 ensureToneEQ();ensureSpeakers();ensureMasterSound();publishCatalog()
end

local function playIndex(index)
 currentIndex=((tonumber(index) or 1)-1)%#PLAYLIST+1
 ensureCore()
 local t=PLAYLIST[currentIndex]
 masterSound:Stop()
 masterSound.SoundId="rbxassetid://"..t.assetId
 masterSound.TimePosition=0
 masterSound:SetAttribute("Title",t.title)
 masterSound:SetAttribute("PlaylistIndex",currentIndex)
 masterSound:SetAttribute("PlaylistId","rooftop-tropical")
 publishState()
 pcall(function()masterSound:Play()end)
 print("[BBYA] Rooftop seamless master now playing",currentIndex,t.title,t.assetId)
end

local function bindEnded()
 if endedConnection then endedConnection:Disconnect();endedConnection=nil end
 endedConnection=masterSound.Ended:Connect(function()
  task.defer(function()playIndex(currentIndex%#PLAYLIST+1)end)
 end)
end

ensureCore();bindEnded();playIndex(currentIndex)

task.spawn(function()
 while task.wait(.50) do
  group.Volume=.86
  group:SetAttribute("PlaylistReady",true)
  group:SetAttribute("PlaylistCount",#PLAYLIST)
  publishState()
  if masterSound and masterSound.Parent and not masterSound.IsPlaying then pcall(function()masterSound:Play()end) end
 end
end)

print("[BBYA] Rooftop authority v5 online; 4 physical speakers + one seamless master clock; tracks",#PLAYLIST)
