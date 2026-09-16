-- BBYA SOCIAL HUB - VIP AMAPIANO PLAYLIST AUTHORITY v7 AUTOMIX
-- Preserves the approved 8-track VIP bank and per-track playback-speed compensation.
-- Adds standby preload + 4-second dual-deck crossfade while keeping BBYAVIPPlaylist as the canonical UI sound.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Players=game:GetService("Players")
local MarketplaceService=game:GetService("MarketplaceService")
local TweenService=game:GetService("TweenService")
local ContentProvider=game:GetService("ContentProvider")

local ORIGINAL_SPEED=1
local UPLOAD_SPEED=1.75
local COMPENSATED_SPEED=1/UPLOAD_SPEED
local MIX_SECONDS=4
local PRELOAD_SECONDS=12
local LOAD_TIMEOUT=5
local LIVE_VOLUME=.72

local PLAYLIST={
 {title="Wonder Girls - Nobody (ROOKIE Amapiano Edit)",assetId="105859685125263",playbackSpeed=ORIGINAL_SPEED,uploadSpeed=1},
 {title="AUDIO #135466870455541",assetId="135466870455541",playbackSpeed=ORIGINAL_SPEED,uploadSpeed=1},
 {title="AUDIO #104570664651564",assetId="104570664651564",playbackSpeed=ORIGINAL_SPEED,uploadSpeed=1},
 {title="AUDIO #126169746073506",assetId="126169746073506",playbackSpeed=COMPENSATED_SPEED,uploadSpeed=UPLOAD_SPEED},
 {title="AUDIO #71255967755640",assetId="71255967755640",playbackSpeed=COMPENSATED_SPEED,uploadSpeed=UPLOAD_SPEED},
 {title="AUDIO #96302475011963",assetId="96302475011963",playbackSpeed=COMPENSATED_SPEED,uploadSpeed=UPLOAD_SPEED},
 {title="AUDIO #120132620242467",assetId="120132620242467",playbackSpeed=COMPENSATED_SPEED,uploadSpeed=UPLOAD_SPEED},
 {title="AUDIO #132641805708328",assetId="132641805708328",playbackSpeed=COMPENSATED_SPEED,uploadSpeed=UPLOAD_SPEED}
}
if #PLAYLIST==0 then return end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
if not remotes then remotes=Instance.new("Folder");remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage end
local vipRemote=remotes:FindFirstChild("VIPMusic")
if vipRemote and not vipRemote:IsA("RemoteEvent")then vipRemote:Destroy();vipRemote=nil end
if not vipRemote then vipRemote=Instance.new("RemoteEvent");vipRemote.Name="VIPMusic";vipRemote.Parent=remotes end

local group=SoundService:FindFirstChild("BBYAVIPMaster")
if group and not group:IsA("SoundGroup")then group:Destroy();group=nil end
if not group then group=Instance.new("SoundGroup");group.Name="BBYAVIPMaster";group.Parent=SoundService end
group.Volume=.62
group:SetAttribute("Venue","VIP")
group:SetAttribute("BBYALocalZoneOnly",true)
group:SetAttribute("PlaylistReady",true)
group:SetAttribute("PlaylistCount",#PLAYLIST)
group:SetAttribute("MusicCatalogState","VIP_AMAPIANO_8_APPROVED_V7_AUTOMIX")
group:SetAttribute("AutoMix",true)
group:SetAttribute("MixSeconds",MIX_SECONDS)
group:SetAttribute("PlaybackTopology","CANONICAL_MASTER_PLUS_STANDBY_CROSSFADE")

local legacy=SoundService:FindFirstChild("BBYAVIPTrack01");if legacy then legacy:Destroy()end
local sound=SoundService:FindFirstChild("BBYAVIPPlaylist")
if sound and not sound:IsA("Sound")then sound:Destroy();sound=nil end
if not sound then sound=Instance.new("Sound");sound.Name="BBYAVIPPlaylist";sound.Parent=SoundService end
local standby=SoundService:FindFirstChild("BBYAVIPStandby")
if standby and not standby:IsA("Sound")then standby:Destroy();standby=nil end
if not standby then standby=Instance.new("Sound");standby.Name="BBYAVIPStandby";standby.Parent=SoundService end
for _,s in ipairs({sound,standby})do s.SoundGroup=group;s.Looped=false;s:SetAttribute("Venue","VIP")end
sound.Volume=LIVE_VOLUME;standby.Volume=0
sound:SetAttribute("DeckRole","LIVE");standby:SetAttribute("DeckRole","STANDBY")

local currentIndex=tonumber(ReplicatedStorage:GetAttribute("BBYAVIPCurrentIndex"))or 1
if currentIndex<1 or currentIndex>#PLAYLIST then currentIndex=1 end
local preparedIndex=nil
local preparing=false
local transitioning=false
local generation=0
local lastControl={}

local function track(i)return PLAYLIST[((tonumber(i)or 1)-1)%#PLAYLIST+1]end
local function nextIndex()return currentIndex%#PLAYLIST+1 end
local function waitLoaded(s,timeout)
 local deadline=os.clock()+(timeout or LOAD_TIMEOUT)
 while os.clock()<deadline do if s.IsLoaded and (s.TimeLength or 0)>1 then return true end;task.wait(.10)end
 return s.IsLoaded and (s.TimeLength or 0)>1
end
local function configure(s,i,volume)
 local t=track(i);s:Stop();s.SoundId="rbxassetid://"..t.assetId;s.PlaybackSpeed=t.playbackSpeed;s.TimePosition=0;s.Volume=volume or 0
 s:SetAttribute("Title",t.title);s:SetAttribute("PlaylistIndex",i);s:SetAttribute("PlaylistId","vip-amapiano");s:SetAttribute("UploadSpeed",t.uploadSpeed);s:SetAttribute("PlaybackSpeedLocked",t.playbackSpeed)
end
local function currentData()
 local t=track(currentIndex)
 return{venue="VIP",index=currentIndex,title=t.title,assetId=t.assetId,playing=sound.IsPlaying,count=#PLAYLIST,playbackSpeed=t.playbackSpeed,uploadSpeed=t.uploadSpeed,audioMode="VIP_AUTOMIX_V7",mixSeconds=MIX_SECONDS,standbyIndex=preparedIndex or 0}
end
local function publishState()
 local t=track(currentIndex)
 ReplicatedStorage:SetAttribute("BBYAVIPTrack01Enabled",true);ReplicatedStorage:SetAttribute("BBYAVIPPlaylistId","vip-amapiano");ReplicatedStorage:SetAttribute("BBYAVIPPlaylistCount",#PLAYLIST);ReplicatedStorage:SetAttribute("BBYAVIPCurrentIndex",currentIndex);ReplicatedStorage:SetAttribute("BBYAVIPCurrentTitle",t.title);ReplicatedStorage:SetAttribute("BBYAVIPCurrentAssetId",t.assetId);ReplicatedStorage:SetAttribute("BBYAVIPTrack01Title",PLAYLIST[1].title);ReplicatedStorage:SetAttribute("BBYAVIPTrack01AssetId",PLAYLIST[1].assetId);ReplicatedStorage:SetAttribute("BBYAVIPUploadSpeed",t.uploadSpeed);ReplicatedStorage:SetAttribute("BBYAVIPPlaybackSpeed",t.playbackSpeed)
 group:SetAttribute("CurrentIndex",currentIndex);group:SetAttribute("CurrentTitle",t.title);group:SetAttribute("CurrentAssetId",t.assetId);group:SetAttribute("UploadSpeed",t.uploadSpeed);group:SetAttribute("PlaybackSpeedLocked",t.playbackSpeed);group:SetAttribute("StandbyIndex",preparedIndex or 0)
end
local function broadcastState()publishState();vipRemote:FireAllClients("state",currentData())end
local function prepare(i)
 i=((tonumber(i)or 1)-1)%#PLAYLIST+1
 if transitioning or preparing then return false end
 if preparedIndex==i and standby.IsLoaded then return true end
 preparing=true;preparedIndex=i;configure(standby,i,0);standby:SetAttribute("DeckRole","STANDBY");group:SetAttribute("StandbyIndex",i)
 task.spawn(function()pcall(function()ContentProvider:PreloadAsync({standby})end)end)
 local ok=waitLoaded(standby,LOAD_TIMEOUT);preparing=false
 if not ok then preparedIndex=nil;group:SetAttribute("LastPreloadFailure",i);return false end
 return true
end
local function hardStart(i,reason)
 i=((tonumber(i)or 1)-1)%#PLAYLIST+1;generation+=1;currentIndex=i;preparedIndex=nil;configure(sound,i,LIVE_VOLUME);sound:SetAttribute("DeckRole","LIVE");standby:Stop();standby.Volume=0;standby:SetAttribute("DeckRole","STANDBY");publishState();pcall(function()sound:Play()end);task.defer(function()prepare(nextIndex())end);group:SetAttribute("LastTransitionReason",reason or"hard-start");broadcastState()
end
local function mixTo(i,reason)
 i=((tonumber(i)or 1)-1)%#PLAYLIST+1
 if transitioning then return end
 transitioning=true
 if preparedIndex~=i or not standby.IsLoaded then
  preparing=false
  if not prepare(i)then transitioning=false;hardStart(i,"preload-fallback");return end
 end
 local t=track(i);standby.Volume=0;standby.TimePosition=0;standby:SetAttribute("DeckRole","MIX_IN");sound:SetAttribute("DeckRole","MIX_OUT");local ok=pcall(function()standby:Play()end)
 if not ok then transitioning=false;hardStart(i,"standby-play-fallback");return end
 local up=TweenService:Create(standby,TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Linear),{Volume=LIVE_VOLUME});local down=TweenService:Create(sound,TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Linear),{Volume=0});up:Play();down:Play();group:SetAttribute("LastTransitionReason",reason or"automix")
 task.wait(MIX_SECONDS)
 local handoff=math.max(0,standby.TimePosition);sound:Stop();currentIndex=i;configure(sound,i,LIVE_VOLUME);sound.TimePosition=handoff;sound:SetAttribute("DeckRole","LIVE");pcall(function()sound:Play()end);standby:Stop();standby.Volume=0;standby:SetAttribute("DeckRole","STANDBY");preparedIndex=nil;transitioning=false;publishState();broadcastState();task.defer(function()prepare(nextIndex())end)
 print("[BBYA] VIP AutoMix",currentIndex,t.title,reason or"automix")
end
local function canControl(p)return p and(p:GetAttribute("BBYAAdmin")==true or p:GetAttribute("BBYAOwner")==true or(game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId))end
vipRemote.OnServerEvent:Connect(function(p,action,value)
 action=tostring(action or"")
 if action=="list"then vipRemote:FireClient(p,"playlist",PLAYLIST);vipRemote:FireClient(p,"state",currentData());return end
 if not canControl(p)then vipRemote:FireClient(p,"toast","REQUEST KHUSUS HOST VIP");return end
 local now=os.clock();if now-(lastControl[p]or 0)<.45 then return end;lastControl[p]=now
 if action=="request"or action=="play"then task.spawn(function()mixTo(tonumber(value)or currentIndex,"admin-play")end)
 elseif action=="next"then task.spawn(function()mixTo(nextIndex(),"admin-next")end)
 elseif action=="previous"or action=="prev"then task.spawn(function()mixTo(((currentIndex-2)%#PLAYLIST)+1,"admin-prev")end)end
end)
Players.PlayerRemoving:Connect(function(p)lastControl[p]=nil end)

hardStart(currentIndex,"startup")
-- Resolve display titles from Roblox metadata without inventing names.
task.spawn(function()
 for index,t in ipairs(PLAYLIST)do task.spawn(function()local id=tonumber(t.assetId);if not id then return end;local ok,info=pcall(function()return MarketplaceService:GetProductInfo(id,Enum.InfoType.Asset)end);if ok and type(info)=="table"and type(info.Name)=="string"and info.Name~=""then t.title=info.Name;publishState();vipRemote:FireAllClients("playlist",PLAYLIST);vipRemote:FireAllClients("state",currentData())end end)end
end)
task.spawn(function()
 while task.wait(.25)do
  group.Volume=.62;group:SetAttribute("PlaylistReady",true);group:SetAttribute("PlaylistCount",#PLAYLIST)
  if not transitioning then
   if not sound.IsPlaying then hardStart(nextIndex(),"watchdog-stop")
   elseif sound.TimeLength>1 then
    local speed=math.max(.1,sound.PlaybackSpeed);local remaining=sound.TimeLength-sound.TimePosition
    if remaining<=PRELOAD_SECONDS*speed and not preparedIndex then prepare(nextIndex())end
    if remaining<=MIX_SECONDS*speed+.12 then task.spawn(function()mixTo(preparedIndex or nextIndex(),"auto-end")end)end
   end
  end
 end
end)
print("[BBYA] VIP Amapiano v7 online: 8 tracks / standby preload / 4s AutoMix")
