-- BBYA SOCIAL HUB — ROOFTOP TROPICAL PLAYLIST AUTHORITY v4
-- Four-corner spatial speaker array with warm low-end tuning and controlled gain.
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
local sounds={}
local primarySound
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
 local eq=group:FindFirstChild("BBYARooftopToneEQV4")
 if eq and not eq:IsA("EqualizerSoundEffect") then eq:Destroy();eq=nil end
 if not eq then eq=Instance.new("EqualizerSoundEffect");eq.Name="BBYARooftopToneEQV4";eq.Parent=group end
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
 speakerRoot:SetAttribute("AudioProfile","WARM_BALANCED_V4")

 local oldClock=SoundService:FindFirstChild("BBYARooftopPlaylist")
 if oldClock and oldClock:IsA("Sound") then pcall(function()oldClock:Stop()end);oldClock:Destroy() end

 table.clear(speakers)
 table.clear(sounds)
 for i,spec in ipairs(SPEAKER_SPECS) do
  local p=speakerRoot:FindFirstChild(spec.name)
  if p and not p:IsA("Part") then p:Destroy();p=nil end
  if not p then p=Instance.new("Part");p.Name=spec.name;p.Parent=speakerRoot end
  p.Size=Vector3.new(2.8,4.2,2.8)
  p.CFrame=CFrame.lookAt(spec.pos,Vector3.new(0,spec.pos.Y,0))
  p.Anchored=true
  p.CanCollide=true
  p.CanTouch=true
  p.CanQuery=true
  p.Material=Enum.Material.Metal
  p.Color=Color3.fromRGB(27,28,32)
  p.TopSurface=Enum.SurfaceType.Smooth
  p.BottomSurface=Enum.SurfaceType.Smooth
  p:SetAttribute("Venue","ROOFTOP")
  p:SetAttribute("Purpose","SPATIAL_MUSIC_EMITTER")
  p:SetAttribute("SpeakerIndex",i)

  local s=p:FindFirstChild("RooftopSpatialSound"..i)
  if s and not s:IsA("Sound") then s:Destroy();s=nil end
  if not s then s=Instance.new("Sound");s.Name="RooftopSpatialSound"..i;s.Parent=p end
  s.SoundGroup=group
  s.Looped=false
  s.Volume=.52
  s.PlaybackSpeed=1
  s.RollOffMode=Enum.RollOffMode.InverseTapered
  s.RollOffMinDistance=11
  s.RollOffMaxDistance=82
  s.EmitterSize=12
  s:SetAttribute("Venue","ROOFTOP")
  s:SetAttribute("SpatialEmitter",true)
  s:SetAttribute("SpeakerIndex",i)
  table.insert(speakers,p)
  table.insert(sounds,s)
 end
 primarySound=sounds[1]
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
  group:SetAttribute("SpeakerCount",#sounds)
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
 group:SetAttribute("MusicCatalogState","ROOFTOP_TROPICAL_4CORNER_ACTIVE")
 ensureToneEQ()
 ensureSpeakers()
 publishCatalog()
end

local function playIndex(index)
 currentIndex=((tonumber(index) or 1)-1)%#PLAYLIST+1
 ensureCore()
 local t=PLAYLIST[currentIndex]
 for _,s in ipairs(sounds) do
  pcall(function()s:Stop()end)
  s.SoundId="rbxassetid://"..t.assetId
  s.TimePosition=0
  s:SetAttribute("Title",t.title)
  s:SetAttribute("Venue","ROOFTOP")
  s:SetAttribute("PlaylistIndex",currentIndex)
  s:SetAttribute("PlaylistId","rooftop-tropical")
 end
 publishState()
 task.wait(.05)
 for _,s in ipairs(sounds) do pcall(function()s:Play()end) end
 print("[BBYA] Rooftop four-corner array now playing",currentIndex,t.title,t.assetId)
end

local function bindEnded()
 if endedConnection then endedConnection:Disconnect();endedConnection=nil end
 if not primarySound then return end
 endedConnection=primarySound.Ended:Connect(function()
  task.defer(function()playIndex(currentIndex%#PLAYLIST+1)end)
 end)
end

ensureCore()
bindEnded()
playIndex(currentIndex)

task.spawn(function()
 while task.wait(1.25) do
  group.Volume=.86
  group:SetAttribute("PlaylistReady",true)
  group:SetAttribute("PlaylistCount",#PLAYLIST)
  publishState()

  if primarySound and primarySound.Parent then
   if not primarySound.IsPlaying then
    for _,s in ipairs(sounds) do pcall(function()s:Play()end) end
   else
    local clock=primarySound.TimePosition
    for i=2,#sounds do
     local s=sounds[i]
     if s and s.Parent then
      if not s.IsPlaying then
       pcall(function()s.TimePosition=clock;s:Play()end)
      elseif math.abs(s.TimePosition-clock)>.35 then
       pcall(function()s.TimePosition=clock end)
      end
     end
    end
   end
  end
 end
end)

print("[BBYA] Rooftop tropical authority v4 online; 4 corner speakers; warm EQ; tracks",#PLAYLIST)
