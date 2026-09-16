-- BBYA SOCIAL HUB — ROOFTOP TROPICAL PLAYLIST AUTHORITY v9 AUTOMIX
-- Preserves the approved 10-track tropical bank, speaker geometry, request queue and speed compensation.
-- Adds standby preload + 4-second crossfade while keeping BBYARooftopMasterSound canonical for UI/runtime health.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local ContentProvider=game:GetService("ContentProvider")

local PLAYLIST={
 {title="Seksi musik",assetId="105487713760091"},{title="Orang lain",assetId="84947610237530"},{title="Nyunset",assetId="120548212398790"},{title="Cinta lagi",assetId="77495993960172"},{title="Tropical",assetId="96703385093368"},{title="Berdiri di sebelahku",assetId="98964227395218"},{title="Setiap menit",assetId="100869573664531"},{title="Musik asik",assetId="134438985639092"},{title="Ajak aku kembali",assetId="115989404258612"},{title="Aku berharap kamu tau",assetId="107555884946142"}
}
local SOURCE_UPLOAD_SPEED=1.75
local NORMAL_PLAYBACK_SPEED=1/SOURCE_UPLOAD_SPEED
local MIX_SECONDS=4
local PRELOAD_SECONDS=12
local LOAD_TIMEOUT=5
local LIVE_VOLUME=.72
local ROOFTOP_DECK_Y=59.86
local SPEAKER_HEIGHT=4.2
local SPEAKER_CENTER_Y=ROOFTOP_DECK_Y+(SPEAKER_HEIGHT*.5)
if #PLAYLIST==0 then return end

local SPEAKER_SPECS={
 {name="BBYARooftopSpeakerBlock1",pos=Vector3.new(47,SPEAKER_CENTER_Y,-34)},
 {name="BBYARooftopSpeakerBlock2",pos=Vector3.new(-47,SPEAKER_CENTER_Y,-34)},
 {name="BBYARooftopSpeakerBlock3",pos=Vector3.new(47,SPEAKER_CENTER_Y,34)},
 {name="BBYARooftopSpeakerBlock4",pos=Vector3.new(-47,SPEAKER_CENTER_Y,34)},
}
local control=ReplicatedStorage:FindFirstChild("BBYARooftopMusicControl")
if control and not control:IsA("RemoteEvent")then control:Destroy();control=nil end
if not control then control=Instance.new("RemoteEvent");control.Name="BBYARooftopMusicControl";control.Parent=ReplicatedStorage end

local group=SoundService:FindFirstChild("BBYARooftopMaster")
if group and not group:IsA("SoundGroup")then group:Destroy();group=nil end
if not group then group=Instance.new("SoundGroup");group.Name="BBYARooftopMaster";group.Parent=SoundService end
group.Volume=.86;group:SetAttribute("Venue","ROOFTOP");group:SetAttribute("BBYALocalZoneOnly",true);group:SetAttribute("PlaylistReady",true);group:SetAttribute("PlaylistCount",#PLAYLIST);group:SetAttribute("MusicCatalogState","ROOFTOP_TROPICAL_10_APPROVED_V9_AUTOMIX");group:SetAttribute("SourceUploadSpeed",SOURCE_UPLOAD_SPEED);group:SetAttribute("PlaybackSpeedLocked",NORMAL_PLAYBACK_SPEED);group:SetAttribute("DeckDatumY",ROOFTOP_DECK_Y);group:SetAttribute("AutoMix",true);group:SetAttribute("MixSeconds",MIX_SECONDS)
local eq=group:FindFirstChild("BBYARooftopToneEQV7")or Instance.new("EqualizerSoundEffect");eq.Name="BBYARooftopToneEQV7";eq.Enabled=true;eq.LowGain=3.2;eq.MidGain=-1;eq.HighGain=-2.6;eq.Parent=group

local speakerRoot=Workspace:FindFirstChild("BBYARooftopSpeakerArrayV4")
if speakerRoot and not speakerRoot:IsA("Folder")then speakerRoot:Destroy();speakerRoot=nil end
if not speakerRoot then speakerRoot=Instance.new("Folder");speakerRoot.Name="BBYARooftopSpeakerArrayV4";speakerRoot.Parent=Workspace end
speakerRoot:SetAttribute("Venue","ROOFTOP");speakerRoot:SetAttribute("SpeakerCount",#SPEAKER_SPECS);speakerRoot:SetAttribute("AudioProfile","WARM_AUTOMIX_V9");speakerRoot:SetAttribute("DeckDatumY",ROOFTOP_DECK_Y);speakerRoot:SetAttribute("SpeakerCenterY",SPEAKER_CENTER_Y)
local speakers={}
local legacySpeaker=Workspace:FindFirstChild("BBYARooftopSpeakerBlock");if legacySpeaker then legacySpeaker:Destroy()end
for i,spec in ipairs(SPEAKER_SPECS)do
 local p=speakerRoot:FindFirstChild(spec.name);if p and not p:IsA("Part")then p:Destroy();p=nil end;if not p then p=Instance.new("Part");p.Name=spec.name;p.Parent=speakerRoot end
 p.Size=Vector3.new(2.8,SPEAKER_HEIGHT,2.8);p.CFrame=CFrame.lookAt(spec.pos,Vector3.new(0,spec.pos.Y,0));p.Anchored=true;p.CanCollide=true;p.CanTouch=true;p.CanQuery=true;p.Material=Enum.Material.Metal;p.Color=Color3.fromRGB(27,28,32);p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p:SetAttribute("Venue","ROOFTOP");p:SetAttribute("Purpose","ROOM_SPEAKER_VISUAL_MASTER_CLOCK");p:SetAttribute("SpeakerIndex",i);p:SetAttribute("DeckDatumY",ROOFTOP_DECK_Y)
 for _,child in ipairs(p:GetChildren())do if child:IsA("Sound")then pcall(function()child:Stop()end);child:Destroy()end end
 table.insert(speakers,p)
end

local legacy=SoundService:FindFirstChild("BBYARooftopPlaylist");if legacy then pcall(function()legacy:Stop()end);legacy:Destroy()end
local sound=SoundService:FindFirstChild("BBYARooftopMasterSound")
if sound and not sound:IsA("Sound")then sound:Destroy();sound=nil end
if not sound then sound=Instance.new("Sound");sound.Name="BBYARooftopMasterSound";sound.Parent=SoundService end
local standby=SoundService:FindFirstChild("BBYARooftopStandby")
if standby and not standby:IsA("Sound")then standby:Destroy();standby=nil end
if not standby then standby=Instance.new("Sound");standby.Name="BBYARooftopStandby";standby.Parent=SoundService end
for _,s in ipairs({sound,standby})do s.SoundGroup=group;s.Looped=false;s.PlaybackSpeed=NORMAL_PLAYBACK_SPEED;s:SetAttribute("Venue","ROOFTOP");s:SetAttribute("PlaybackSpeedLocked",NORMAL_PLAYBACK_SPEED);s:SetAttribute("SourceUploadSpeed",SOURCE_UPLOAD_SPEED)end
sound.Volume=LIVE_VOLUME;standby.Volume=0;sound:SetAttribute("DeckRole","LIVE");standby:SetAttribute("DeckRole","STANDBY")

local currentIndex=tonumber(ReplicatedStorage:GetAttribute("BBYARooftopCurrentIndex"))or 1;if currentIndex<1 or currentIndex>#PLAYLIST then currentIndex=1 end
local queue={};local requestCooldown={};local preparedIndex=nil;local preparing=false;local transitioning=false

local function inZone(player)local c=player and player.Character;local h=c and c:FindFirstChild("HumanoidRootPart");if not h then return false end;local p=h.Position;return p.Y>=55 and p.Y<=68 and math.abs(p.X)<=62 and p.Z>=-48 and p.Z<=48 end
local function isAdmin(player)return player and(player:GetAttribute("BBYAAdmin")==true or player:GetAttribute("BBYAOwner")==true or(game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId))end
local function publishQueue()local count=#queue;local ni=tonumber(queue[1])or 0;ReplicatedStorage:SetAttribute("BBYARooftopQueueCount",count);ReplicatedStorage:SetAttribute("BBYARooftopNextRequestIndex",ni);group:SetAttribute("QueueCount",count);group:SetAttribute("NextRequestIndex",ni)end
local function publishCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYARooftopPlaylistCatalog");if folder and not folder:IsA("Folder")then folder:Destroy();folder=nil end;if not folder then folder=Instance.new("Folder");folder.Name="BBYARooftopPlaylistCatalog";folder.Parent=ReplicatedStorage end;folder:ClearAllChildren();folder:SetAttribute("PlaylistId","rooftop-tropical");folder:SetAttribute("Venue","ROOFTOP");folder:SetAttribute("Count",#PLAYLIST);folder:SetAttribute("ControlRemote","BBYARooftopMusicControl");folder:SetAttribute("SourceUploadSpeed",SOURCE_UPLOAD_SPEED);folder:SetAttribute("PlaybackSpeed",NORMAL_PLAYBACK_SPEED);folder:SetAttribute("AutoMix",true);folder:SetAttribute("MixSeconds",MIX_SECONDS)
 for i,t in ipairs(PLAYLIST)do local e=Instance.new("StringValue");e.Name="Track"..i;e.Value=t.title;e:SetAttribute("Index",i);e:SetAttribute("AssetId",t.assetId);e:SetAttribute("PlaybackSpeed",NORMAL_PLAYBACK_SPEED);e.Parent=folder end
end
local function nextWanted(consume)
 if #queue>0 then local n=queue[1];if consume then table.remove(queue,1);publishQueue()end;return n end
 return currentIndex%#PLAYLIST+1
end
local function waitLoaded(s,timeout)local deadline=os.clock()+(timeout or LOAD_TIMEOUT);while os.clock()<deadline do if s.IsLoaded and(s.TimeLength or 0)>1 then return true end;task.wait(.1)end;return s.IsLoaded and(s.TimeLength or 0)>1 end
local function configure(s,i,vol)local t=PLAYLIST[i];s:Stop();s.SoundId="rbxassetid://"..t.assetId;s.PlaybackSpeed=NORMAL_PLAYBACK_SPEED;s.TimePosition=0;s.Volume=vol or 0;s:SetAttribute("Title",t.title);s:SetAttribute("PlaylistIndex",i);s:SetAttribute("PlaylistId","rooftop-tropical")end
local function publishState()
 local t=PLAYLIST[currentIndex];ReplicatedStorage:SetAttribute("BBYARooftopPlaylistEnabled",true);ReplicatedStorage:SetAttribute("BBYARooftopPlaylistId","rooftop-tropical");ReplicatedStorage:SetAttribute("BBYARooftopPlaylistCount",#PLAYLIST);ReplicatedStorage:SetAttribute("BBYARooftopCurrentIndex",currentIndex);ReplicatedStorage:SetAttribute("BBYARooftopCurrentTitle",t.title);ReplicatedStorage:SetAttribute("BBYARooftopCurrentAssetId",t.assetId);ReplicatedStorage:SetAttribute("BBYARooftopSourceUploadSpeed",SOURCE_UPLOAD_SPEED);ReplicatedStorage:SetAttribute("BBYARooftopPlaybackSpeed",NORMAL_PLAYBACK_SPEED);ReplicatedStorage:SetAttribute("BBYARooftopSpeakerCenterY",SPEAKER_CENTER_Y);group:SetAttribute("CurrentIndex",currentIndex);group:SetAttribute("CurrentTitle",t.title);group:SetAttribute("CurrentAssetId",t.assetId);group:SetAttribute("StandbyIndex",preparedIndex or 0);speakerRoot:SetAttribute("CurrentIndex",currentIndex);speakerRoot:SetAttribute("CurrentTitle",t.title);speakerRoot:SetAttribute("CurrentAssetId",t.assetId);for _,p in ipairs(speakers)do p:SetAttribute("CurrentIndex",currentIndex);p:SetAttribute("CurrentTitle",t.title);p:SetAttribute("CurrentAssetId",t.assetId)end;publishQueue()
end
local function prepare(i)
 i=((tonumber(i)or 1)-1)%#PLAYLIST+1;if preparing then return false end;if preparedIndex==i and standby.IsLoaded then return true end
 preparing=true;preparedIndex=i;configure(standby,i,0);standby:SetAttribute("DeckRole","STANDBY");task.spawn(function()pcall(function()ContentProvider:PreloadAsync({standby})end)end);local ok=waitLoaded(standby,LOAD_TIMEOUT);preparing=false;if not ok then preparedIndex=nil;group:SetAttribute("LastPreloadFailure",i);return false end;publishState();return true
end
local function hardStart(i,reason)
 i=((tonumber(i)or 1)-1)%#PLAYLIST+1;currentIndex=i;preparedIndex=nil;configure(sound,i,LIVE_VOLUME);sound:SetAttribute("DeckRole","LIVE");standby:Stop();standby.Volume=0;standby:SetAttribute("DeckRole","STANDBY");publishState();pcall(function()sound:Play()end);group:SetAttribute("LastTransitionReason",reason or"hard-start");task.defer(function()prepare(nextWanted(false))end)
end
local function mixTo(i,reason)
 i=((tonumber(i)or 1)-1)%#PLAYLIST+1;if transitioning then return end
 if preparedIndex~=i or not standby.IsLoaded then if not prepare(i)then hardStart(i,"preload-fallback");return end end
 transitioning=true;standby.Volume=0;standby.TimePosition=0;standby:SetAttribute("DeckRole","MIX_IN");sound:SetAttribute("DeckRole","MIX_OUT");local ok=pcall(function()standby:Play()end);if not ok then transitioning=false;hardStart(i,"standby-play-fallback");return end
 TweenService:Create(standby,TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Linear),{Volume=LIVE_VOLUME}):Play();TweenService:Create(sound,TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Linear),{Volume=0}):Play();group:SetAttribute("LastTransitionReason",reason or"automix");task.wait(MIX_SECONDS)
 local pos=math.max(0,standby.TimePosition);sound:Stop();currentIndex=i;if #queue>0 and queue[1]==i then table.remove(queue,1);publishQueue()end;configure(sound,i,LIVE_VOLUME);sound.TimePosition=pos;sound:SetAttribute("DeckRole","LIVE");pcall(function()sound:Play()end);standby:Stop();standby.Volume=0;standby:SetAttribute("DeckRole","STANDBY");preparedIndex=nil;transitioning=false;publishState();task.defer(function()prepare(nextWanted(false))end)
end
control.OnServerEvent:Connect(function(player,action,wanted)
 action=tostring(action or"")
 if action=="request"then if not inZone(player)then return end;local n=tonumber(wanted);if not n or not PLAYLIST[n]then return end;local now=os.clock();if now-(requestCooldown[player.UserId]or 0)<3 then return end;requestCooldown[player.UserId]=now;table.insert(queue,n);publishQueue();if not preparedIndex then task.spawn(function()prepare(nextWanted(false))end)end;return end
 if not isAdmin(player)then return end
 if action=="next"then task.spawn(function()mixTo(nextWanted(true),"admin-next")end)
 elseif action=="prev"or action=="previous"then task.spawn(function()mixTo(((currentIndex-2)%#PLAYLIST)+1,"admin-prev")end)
 elseif action=="play"then local n=tonumber(wanted);if n and PLAYLIST[n]then task.spawn(function()mixTo(n,"admin-play")end)end
 elseif action=="clearqueue"then table.clear(queue);publishQueue()end
end)
Players.PlayerRemoving:Connect(function(p)requestCooldown[p.UserId]=nil end)
publishCatalog();publishQueue();hardStart(currentIndex,"startup")
task.spawn(function()
 while task.wait(.25)do
  group.Volume=.86;group:SetAttribute("PlaylistReady",true);group:SetAttribute("PlaylistCount",#PLAYLIST);sound.PlaybackSpeed=NORMAL_PLAYBACK_SPEED
  if not transitioning then
   if not sound.IsPlaying then hardStart(nextWanted(true),"watchdog-stop")
   elseif sound.TimeLength>1 then local remaining=sound.TimeLength-sound.TimePosition;local speed=math.max(.1,sound.PlaybackSpeed);if remaining<=PRELOAD_SECONDS*speed and not preparedIndex then task.spawn(function()prepare(nextWanted(false))end)end;if remaining<=MIX_SECONDS*speed+.12 then task.spawn(function()mixTo(preparedIndex or nextWanted(false),"auto-end")end)end end
  end
 end
end)
print("[BBYA] Rooftop v9 online: 10 approved tracks / preserved speakers / 4s AutoMix")
