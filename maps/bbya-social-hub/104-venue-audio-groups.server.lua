-- BBYA SOCIAL HUB — VENUE AUDIO MASTERS v7 AUTOMIX
-- Preserves the approved Skatepark 20-track bank and Pasar Malam 5-track bank.
-- Both venues now use canonical master + standby preload with a 4-second crossfade.
-- Selected-track retry, request queues, per-track playback speed, venue groups and catalog metadata remain server-authoritative.

local SoundService=game:GetService("SoundService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ContentProvider=game:GetService("ContentProvider")
local Workspace=game:GetService("Workspace")
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")

local NORMALIZED_175X=1/1.75
local MIX_SECONDS=4
local PRELOAD_SECONDS=12
local LOAD_TIMEOUT=6

local SKATE_PLAYLIST={
 {title="Mutronic Plague",assetId="1837057495"},{title="Rock On",assetId="1841242625"},{title="Run Run Run",assetId="9040318014"},{title="We've Got This! - 60",assetId="9043707741"},{title="Fuel Fury",assetId="9042632936"},{title="Boom Boom (b 30)",assetId="1840009708"},
 {title="Untungnya Hidup Harus Tetap Berjalan",assetId="101433831748471",playbackSpeed=.8,approvalState="APPROVED"},
 {title="Vierra - Perih (Pop Punk Version)",assetId="73111765506214",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD"},
 {title="Apa yang aku lakukan",assetId="134467357340949",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD",bank="POP PUNK"},
 {title="Cewek baru",assetId="94716486418996",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD",bank="POP PUNK"},
 {title="Ke dalam",assetId="137855682924521",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD",bank="POP PUNK"},
 {title="Jatuh",assetId="100571973862831",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD",bank="POP PUNK"},
 {title="Gantian",assetId="76764826294674",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD",bank="POP PUNK"},
 {title="Panggung rock",assetId="73605786993749",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD",bank="POP PUNK"},
 {title="Orang kuat",assetId="122266407959894",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD",bank="POP PUNK"},
 {title="Orang agak kurang",assetId="120903123891114",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD",bank="POP PUNK"},
 {title="Tak antemi",assetId="85284576958779",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD",bank="POP PUNK"},
 {title="Bawa aku hidup",assetId="114950574110478",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD",bank="POP PUNK"},
 {title="Halus",assetId="77600449290121",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD",bank="POP PUNK"},
 {title="Saat hatimu berhenti",assetId="106253638699689",playbackSpeed=NORMALIZED_175X,approvalState="APPROVED",speedProfile="NORMALIZED_175X_UPLOAD",bank="POP PUNK"},
}
local NIGHT_MARKET_PLAYLIST={
 {title="Gadis Manis Kalimantan - Shinta Gisul",assetId="132656781327264",playbackSpeed=.8},
 {title="Aishiteru 2 - Ajeng Febria",assetId="85424046735289",playbackSpeed=.8},
 {title="Nemen (Hiphop Dangdut Version) - NDX AKA",assetId="89901574840210",playbackSpeed=.8},
 {title="Apa Kabar Mantan - NDX AKA",assetId="108659387121290",playbackSpeed=.8},
 {title="Kopi Dangdut / Tarik Sis Semongko - Vita Alvia",assetId="107887958475943",playbackSpeed=.8},
}

local function ensureGroup(name,venue,volume,state)
 local g=SoundService:FindFirstChild(name);if g and not g:IsA("SoundGroup")then g:Destroy();g=nil end
 if not g then g=Instance.new("SoundGroup");g.Name=name;g.Parent=SoundService end
 g.Volume=volume;g:SetAttribute("Venue",venue);g:SetAttribute("BBYALocalZoneOnly",true);g:SetAttribute("PlaylistReady",true);g:SetAttribute("MusicCatalogState",state);g:SetAttribute("AutoMix",true);g:SetAttribute("MixSeconds",MIX_SECONDS)
 return g
end
local function ensureSound(name,group,venue,volume)
 local s=SoundService:FindFirstChild(name);if s and not s:IsA("Sound")then s:Destroy();s=nil end
 if not s then s=Instance.new("Sound");s.Name=name;s.Parent=SoundService end
 s.SoundGroup=group;s.Looped=false;s.Volume=volume;s:SetAttribute("Venue",venue);return s
end
local function waitLoaded(sound,timeout)
 local deadline=os.clock()+(timeout or LOAD_TIMEOUT)
 while os.clock()<deadline do if sound.IsLoaded and(sound.TimeLength or 0)>1 then return true end;task.wait(.10)end
 return sound.IsLoaded and(sound.TimeLength or 0)>1
end
local function actuallyAdvanced(sound,startPos,timeout)
 local deadline=os.clock()+(timeout or 2.2);local base=tonumber(startPos)or 0
 while os.clock()<deadline do if sound.IsPlaying and(sound.TimePosition or 0)>base+.03 then return true end;task.wait(.10)end
 return false
end
local function isAdmin(player)return player and(player:GetAttribute("BBYAAdmin")==true or player:GetAttribute("BBYAOwner")==true or(game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId))end

-- SKATEPARK -------------------------------------------------------------------
local skateGroup=ensureGroup("BBYASkateparkMaster","SKATEPARK",1,"SKATEPARK_MIXED_V11_AUTOMIX")
skateGroup:SetAttribute("VenueGainProfile","SKATEPARK_FULL_LEVEL_V1");skateGroup:SetAttribute("ApprovedPopPunkSpeed",NORMALIZED_175X);skateGroup:SetAttribute("PopPunkBank","POP PUNK");skateGroup:SetAttribute("PopPunkBankCount",12);skateGroup:SetAttribute("PopPunkBankState","ACTIVE_APPROVED_12");skateGroup:SetAttribute("PlaybackRepair","SELECTED_RETRY_AUTOMIX_V4");skateGroup:SetAttribute("PlaylistCount",#SKATE_PLAYLIST)
local skateControl=ReplicatedStorage:FindFirstChild("BBYASkateparkMusicControl");if skateControl and not skateControl:IsA("RemoteEvent")then skateControl:Destroy();skateControl=nil end;if not skateControl then skateControl=Instance.new("RemoteEvent");skateControl.Name="BBYASkateparkMusicControl";skateControl.Parent=ReplicatedStorage end
local skateSound=ensureSound("BBYASkateparkMasterSound",skateGroup,"SKATEPARK",1)
local skateStandby=ensureSound("BBYASkateparkStandby",skateGroup,"SKATEPARK",0)
skateSound:SetAttribute("PlaylistId","skatepark-mixed");skateSound:SetAttribute("DeckRole","LIVE");skateStandby:SetAttribute("PlaylistId","skatepark-mixed");skateStandby:SetAttribute("DeckRole","STANDBY")
local skateIndex=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkCurrentIndex"))or 1;if skateIndex<1 or skateIndex>#SKATE_PLAYLIST then skateIndex=1 end
local skateQueue={};local skateCooldown={};local skateBadUntil={};local skatePrepared=nil;local skatePreparing=false;local skateTransitioning=false;local skateStartedAt=0;local skateLastPos=0;local skateLastProgress=0

local function publishSkateCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYASkateparkPlaylistCatalog");if folder and not folder:IsA("Folder")then folder:Destroy();folder=nil end;if not folder then folder=Instance.new("Folder");folder.Name="BBYASkateparkPlaylistCatalog";folder.Parent=ReplicatedStorage end;folder:ClearAllChildren();folder:SetAttribute("PlaylistId","skatepark-mixed");folder:SetAttribute("Venue","SKATEPARK");folder:SetAttribute("Count",#SKATE_PLAYLIST);folder:SetAttribute("RightsProfile","ROBLOX_CREATOR_STORE_APM_PLUS_CUSTOM_APPROVED");folder:SetAttribute("ControlRemote","BBYASkateparkMusicControl");folder:SetAttribute("ApprovedPopPunkSpeed",NORMALIZED_175X);folder:SetAttribute("PopPunkBank","POP PUNK");folder:SetAttribute("PopPunkBankCount",12);folder:SetAttribute("PopPunkBankState","ACTIVE_APPROVED_12");folder:SetAttribute("PlaybackRepair","SELECTED_RETRY_AUTOMIX_V4");folder:SetAttribute("AutoMix",true);folder:SetAttribute("MixSeconds",MIX_SECONDS)
 for i,t in ipairs(SKATE_PLAYLIST)do local row=Instance.new("StringValue");row.Name=string.format("Track%02d",i);row.Value=t.title;row:SetAttribute("AssetId",t.assetId);row:SetAttribute("Index",i);row:SetAttribute("PlaybackSpeed",tonumber(t.playbackSpeed)or 1);row:SetAttribute("ApprovalState",t.approvalState or"ROBLOX_CREATOR_STORE");if t.speedProfile then row:SetAttribute("SpeedProfile",t.speedProfile)end;if t.bank then row:SetAttribute("Bank",t.bank)end;row.Parent=folder end
end
local function skateHealthy(i)return SKATE_PLAYLIST[i]and(skateBadUntil[i]or 0)<=os.clock()end
local function skateNext()
 while #skateQueue>0 do if skateHealthy(skateQueue[1])then return skateQueue[1],true end;table.remove(skateQueue,1)end
 for step=1,#SKATE_PLAYLIST do local n=((skateIndex-1+step)%#SKATE_PLAYLIST)+1;if skateHealthy(n)then return n,false end end
 table.clear(skateBadUntil);return skateIndex%#SKATE_PLAYLIST+1,false
end
local function publishSkateState()
 local t=SKATE_PLAYLIST[skateIndex];local speed=tonumber(t.playbackSpeed)or 1
 ReplicatedStorage:SetAttribute("BBYASkateparkCurrentIndex",skateIndex);ReplicatedStorage:SetAttribute("BBYASkateparkCurrentTitle",t.title);ReplicatedStorage:SetAttribute("BBYASkateparkCurrentAssetId",t.assetId);ReplicatedStorage:SetAttribute("BBYASkateparkCurrentPlaybackSpeed",speed);ReplicatedStorage:SetAttribute("BBYASkateparkQueueCount",#skateQueue);ReplicatedStorage:SetAttribute("BBYASkateparkNextRequestIndex",tonumber(skateQueue[1])or 0)
 skateGroup:SetAttribute("PlaylistCount",#SKATE_PLAYLIST);skateGroup:SetAttribute("CurrentIndex",skateIndex);skateGroup:SetAttribute("CurrentTitle",t.title);skateGroup:SetAttribute("CurrentAssetId",t.assetId);skateGroup:SetAttribute("CurrentPlaybackSpeed",speed);skateGroup:SetAttribute("CurrentBank",t.bank or"LEGACY");skateGroup:SetAttribute("PlaylistReady",true);skateGroup:SetAttribute("QueueCount",#skateQueue);skateGroup:SetAttribute("NextRequestIndex",tonumber(skateQueue[1])or 0);skateGroup:SetAttribute("StandbyIndex",skatePrepared or 0)
 skateSound:SetAttribute("Title",t.title);skateSound:SetAttribute("PlaylistIndex",skateIndex);skateSound:SetAttribute("PlaybackSpeed",speed)
end
local function configureSkate(s,i,vol)
 local t=SKATE_PLAYLIST[i];local speed=tonumber(t.playbackSpeed)or 1;s:Stop();s.SoundId="rbxassetid://"..t.assetId;s.PlaybackSpeed=speed;s.TimePosition=0;s.Volume=vol or 0;s:SetAttribute("Title",t.title);s:SetAttribute("PlaylistIndex",i);s:SetAttribute("PlaybackSpeed",speed);s:SetAttribute("Bank",t.bank or"LEGACY");if t.speedProfile then s:SetAttribute("SpeedProfile",t.speedProfile)else s:SetAttribute("SpeedProfile",nil)end
end
local function quarantineSkate(i,reason)if not i then return end;skateBadUntil[i]=os.clock()+30;skateGroup:SetAttribute("LastUnavailableTitle",SKATE_PLAYLIST[i]and SKATE_PLAYLIST[i].title or"");skateGroup:SetAttribute("LastUnavailableAssetId",SKATE_PLAYLIST[i]and SKATE_PLAYLIST[i].assetId or"");skateGroup:SetAttribute("LastPlaybackStatus",tostring(reason or"FAILED"));if skatePrepared==i then skatePrepared=nil end end
local function prepareSkate(i)
 i=((tonumber(i)or 1)-1)%#SKATE_PLAYLIST+1;if skatePreparing or not skateHealthy(i)then return false end;if skatePrepared==i and skateStandby.IsLoaded then return true end
 skatePreparing=true;skatePrepared=i;configureSkate(skateStandby,i,0);skateStandby:SetAttribute("DeckRole","STANDBY");task.spawn(function()pcall(function()ContentProvider:PreloadAsync({skateStandby})end)end);local ok=waitLoaded(skateStandby,LOAD_TIMEOUT);skatePreparing=false;if not ok then quarantineSkate(i,"STANDBY_PRELOAD_FAILED");return false end;publishSkateState();return true
end
local function hardStartSkate(i,direct,reason)
 i=((tonumber(i)or 1)-1)%#SKATE_PLAYLIST+1;skateIndex=i;skatePrepared=nil;configureSkate(skateSound,i,1);skateSound:SetAttribute("DeckRole","LIVE");skateStandby:Stop();skateStandby.Volume=0;skateStandby:SetAttribute("DeckRole","STANDBY");publishSkateState();local tries=direct and 6 or 3;local ok=false
 task.spawn(function()pcall(function()ContentProvider:PreloadAsync({skateSound})end)end)
 for _=1,tries do local before=skateSound.TimePosition;pcall(function()skateSound:Play()end);if actuallyAdvanced(skateSound,before,2.2)then ok=true;break end;task.wait(.25)end
 if not ok then skateSound:Stop();quarantineSkate(i,"FAILED_TO_ADVANCE");local n=skateNext();if n and n~=i then return hardStartSkate(n,false,"fallback")end;return false end
 skateStartedAt=os.clock();skateLastProgress=skateStartedAt;skateLastPos=skateSound.TimePosition;skateGroup:SetAttribute("LastPlaybackStatus","PLAYING");skateGroup:SetAttribute("LastTransitionReason",reason or"hard-start");local n=skateNext();task.defer(function()prepareSkate(n)end);return true
end
local function mixSkate(i,fromQueue,reason)
 i=((tonumber(i)or 1)-1)%#SKATE_PLAYLIST+1;if skateTransitioning then return end
 if skatePrepared~=i or not skateStandby.IsLoaded then if not prepareSkate(i)then hardStartSkate(i,fromQueue,reason or"preload-fallback");return end end
 skateTransitioning=true;skateStandby.Volume=0;skateStandby.TimePosition=0;skateStandby:SetAttribute("DeckRole","MIX_IN");skateSound:SetAttribute("DeckRole","MIX_OUT");local ok=pcall(function()skateStandby:Play()end);if not ok then skateTransitioning=false;hardStartSkate(i,fromQueue,"standby-play-fallback");return end
 TweenService:Create(skateStandby,TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Linear),{Volume=1}):Play();TweenService:Create(skateSound,TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Linear),{Volume=0}):Play();skateGroup:SetAttribute("LastTransitionReason",reason or"automix");task.wait(MIX_SECONDS)
 local pos=math.max(0,skateStandby.TimePosition);skateSound:Stop();if fromQueue and skateQueue[1]==i then table.remove(skateQueue,1)end;skateIndex=i;configureSkate(skateSound,i,1);skateSound.TimePosition=pos;skateSound:SetAttribute("DeckRole","LIVE");pcall(function()skateSound:Play()end);skateStandby:Stop();skateStandby.Volume=0;skateStandby:SetAttribute("DeckRole","STANDBY");skatePrepared=nil;skateTransitioning=false;skateStartedAt=os.clock();skateLastProgress=skateStartedAt;skateLastPos=pos;publishSkateState();local n=skateNext();task.defer(function()prepareSkate(n)end)
end
skateControl.OnServerEvent:Connect(function(player,action,wanted)
 action=tostring(action or"")
 if action=="request"then local n=tonumber(wanted);if not n or not SKATE_PLAYLIST[n]then return end;local now=os.clock();if now-(skateCooldown[player.UserId]or 0)<3 then return end;skateCooldown[player.UserId]=now;if isAdmin(player)or not skateSound.IsPlaying then task.spawn(function()mixSkate(n,false,"direct-request")end)else table.insert(skateQueue,n);publishSkateState();task.spawn(function()local ni=skateNext();prepareSkate(ni)end)end;return end
 if not isAdmin(player)then return end
 if action=="play"then task.spawn(function()mixSkate(tonumber(wanted)or skateIndex,false,"admin-play")end)
 elseif action=="next"then local n,q=skateNext();task.spawn(function()mixSkate(n,q,"admin-next")end)
 elseif action=="prev"then task.spawn(function()mixSkate(((math.max(skateIndex,1)-2)%#SKATE_PLAYLIST)+1,false,"admin-prev")end)
 elseif action=="clearqueue"then table.clear(skateQueue);publishSkateState()end
end)

publishSkateCatalog();publishSkateState();task.spawn(function()hardStartSkate(skateIndex,false,"startup")end)
task.spawn(function()
 while task.wait(.25)do
  skateGroup.Volume=1;skateSound.Volume=skateTransitioning and skateSound.Volume or 1;skateGroup:SetAttribute("PlaylistReady",true);skateGroup:SetAttribute("PlaylistCount",#SKATE_PLAYLIST)
  if not skateTransitioning and skateSound.IsPlaying then
   local now=os.clock();local pos=skateSound.TimePosition;if pos>skateLastPos+.03 then skateLastPos=pos;skateLastProgress=now elseif now-skateStartedAt>8 and now-skateLastProgress>8 then quarantineSkate(skateIndex,"STALLED");local n=skateNext();task.spawn(function()hardStartSkate(n,false,"watchdog-stall")end)end
   if skateSound.TimeLength>1 then local remaining=skateSound.TimeLength-pos;local speed=math.max(.1,skateSound.PlaybackSpeed);local n,q=skateNext();if remaining<=PRELOAD_SECONDS*speed and not skatePrepared and not skatePreparing then task.spawn(function()prepareSkate(n)end)end;if remaining<=MIX_SECONDS*speed+.12 then task.spawn(function()mixSkate(skatePrepared or n,q,"auto-end")end)end end
  elseif not skateTransitioning and not skateSound.IsPlaying and os.clock()-skateStartedAt>2.5 then local n=skateNext();task.spawn(function()hardStartSkate(n,false,"watchdog-stop")end)end
 end
end)

-- PASAR MALAM -----------------------------------------------------------------
local nightGroup=ensureGroup("BBYANightMarketMaster","NIGHT_MARKET",1,"NIGHT_MARKET_KOPLO_AUTOMIX_V2")
nightGroup:SetAttribute("PlaylistId","pasar-malam-koplo");nightGroup:SetAttribute("GenrePolicy","DANGDUT_KOPLO");nightGroup:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER");nightGroup:SetAttribute("Authority","VENUE_AUDIO_MASTERS_V7");nightGroup:SetAttribute("PlaylistCount",#NIGHT_MARKET_PLAYLIST);nightGroup:SetAttribute("RightsProfile","UNIVERSE_PERMISSION_HTTP_200_APPROVED_ONLY")
local nightControl=ReplicatedStorage:FindFirstChild("BBYANightMarketMusicControl");if nightControl and not nightControl:IsA("RemoteEvent")then nightControl:Destroy();nightControl=nil end;if not nightControl then nightControl=Instance.new("RemoteEvent");nightControl.Name="BBYANightMarketMusicControl";nightControl.Parent=ReplicatedStorage end
local nightSound=ensureSound("BBYANightMarketMasterSound",nightGroup,"NIGHT_MARKET",1)
local nightStandby=ensureSound("BBYANightMarketStandby",nightGroup,"NIGHT_MARKET",0)
for _,s in ipairs({nightSound,nightStandby})do s:SetAttribute("PlaylistId","pasar-malam-koplo");s:SetAttribute("GenrePolicy","DANGDUT_KOPLO");s:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER");s:SetAttribute("RightsProfile","UNIVERSE_PERMISSION_HTTP_200_APPROVED_ONLY")end
nightSound:SetAttribute("DeckRole","LIVE");nightStandby:SetAttribute("DeckRole","STANDBY")
local nightIndex=tonumber(ReplicatedStorage:GetAttribute("BBYANightMarketCurrentIndex"))or 1;if nightIndex<1 or nightIndex>#NIGHT_MARKET_PLAYLIST then nightIndex=1 end
local nightQueue={};local nightCooldown={};local nightPrepared=nil;local nightPreparing=false;local nightTransitioning=false;local nightStartedAt=0;local nightLastPos=0;local nightLastProgress=0
local function publishNightCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYANightMarketPlaylistCatalog");if folder and not folder:IsA("Folder")then folder:Destroy();folder=nil end;if not folder then folder=Instance.new("Folder");folder.Name="BBYANightMarketPlaylistCatalog";folder.Parent=ReplicatedStorage end;folder:ClearAllChildren();folder:SetAttribute("PlaylistId","pasar-malam-koplo");folder:SetAttribute("Venue","NIGHT_MARKET");folder:SetAttribute("GenrePolicy","DANGDUT_KOPLO");folder:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER");folder:SetAttribute("Count",#NIGHT_MARKET_PLAYLIST);folder:SetAttribute("PlaybackSpeed",.8);folder:SetAttribute("ApprovalState","5_APPROVED_2_REJECTED_EXCLUDED");folder:SetAttribute("RightsProfile","UNIVERSE_PERMISSION_HTTP_200_APPROVED_ONLY");folder:SetAttribute("OutputSound","BBYANightMarketMasterSound");folder:SetAttribute("SoundGroup","BBYANightMarketMaster");folder:SetAttribute("InjectionState","ACTIVE_APPROVED_BANK_AUTOMIX_V2");folder:SetAttribute("ControlRemote","BBYANightMarketMusicControl");folder:SetAttribute("AutoMix",true);folder:SetAttribute("MixSeconds",MIX_SECONDS)
 for i,t in ipairs(NIGHT_MARKET_PLAYLIST)do local row=Instance.new("StringValue");row.Name=string.format("Track%02d",i);row.Value=t.title;row:SetAttribute("AssetId",t.assetId);row:SetAttribute("Index",i);row:SetAttribute("PlaybackSpeed",tonumber(t.playbackSpeed)or .8);row:SetAttribute("ApprovalState","APPROVED");row.Parent=folder end
end
local function nightNext()if #nightQueue>0 then return nightQueue[1],true end;return nightIndex%#NIGHT_MARKET_PLAYLIST+1,false end
local function configureNight(s,i,vol)local t=NIGHT_MARKET_PLAYLIST[i];local speed=tonumber(t.playbackSpeed)or .8;s:Stop();s.SoundId="rbxassetid://"..t.assetId;s.PlaybackSpeed=speed;s.TimePosition=0;s.Volume=vol or 0;s:SetAttribute("Title",t.title);s:SetAttribute("PlaylistIndex",i);s:SetAttribute("PlaybackSpeed",speed)end
local function publishNightState()
 local t=NIGHT_MARKET_PLAYLIST[nightIndex];local speed=tonumber(t.playbackSpeed)or .8;ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistEnabled",true);ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistId","pasar-malam-koplo");ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistCount",#NIGHT_MARKET_PLAYLIST);ReplicatedStorage:SetAttribute("BBYANightMarketCurrentIndex",nightIndex);ReplicatedStorage:SetAttribute("BBYANightMarketCurrentTitle",t.title);ReplicatedStorage:SetAttribute("BBYANightMarketCurrentAssetId",t.assetId);ReplicatedStorage:SetAttribute("BBYANightMarketCurrentPlaybackSpeed",speed);ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistOutputReady",true);ReplicatedStorage:SetAttribute("BBYANightMarketQueueCount",#nightQueue);ReplicatedStorage:SetAttribute("BBYANightMarketNextRequestIndex",tonumber(nightQueue[1])or 0);nightGroup:SetAttribute("CurrentIndex",nightIndex);nightGroup:SetAttribute("CurrentTitle",t.title);nightGroup:SetAttribute("CurrentAssetId",t.assetId);nightGroup:SetAttribute("CurrentPlaybackSpeed",speed);nightGroup:SetAttribute("PlaylistReady",true);nightGroup:SetAttribute("QueueCount",#nightQueue);nightGroup:SetAttribute("StandbyIndex",nightPrepared or 0);nightSound:SetAttribute("Title",t.title);nightSound:SetAttribute("PlaylistIndex",nightIndex);nightSound:SetAttribute("PlaybackSpeed",speed)
end
local function prepareNight(i)
 i=((tonumber(i)or 1)-1)%#NIGHT_MARKET_PLAYLIST+1;if nightPreparing then return false end;if nightPrepared==i and nightStandby.IsLoaded then return true end;nightPreparing=true;nightPrepared=i;configureNight(nightStandby,i,0);nightStandby:SetAttribute("DeckRole","STANDBY");task.spawn(function()pcall(function()ContentProvider:PreloadAsync({nightStandby})end)end);local ok=waitLoaded(nightStandby,LOAD_TIMEOUT);nightPreparing=false;if not ok then nightPrepared=nil;nightGroup:SetAttribute("LastPreloadFailure",i);return false end;publishNightState();return true
end
local function hardStartNight(i,reason)
 i=((tonumber(i)or 1)-1)%#NIGHT_MARKET_PLAYLIST+1;nightIndex=i;nightPrepared=nil;configureNight(nightSound,i,1);nightSound:SetAttribute("DeckRole","LIVE");nightStandby:Stop();nightStandby.Volume=0;nightStandby:SetAttribute("DeckRole","STANDBY");publishNightState();pcall(function()nightSound:Play()end);nightStartedAt=os.clock();nightLastProgress=nightStartedAt;nightLastPos=0;nightGroup:SetAttribute("LastTransitionReason",reason or"hard-start");local n=nightNext();task.defer(function()prepareNight(n)end)
end
local function mixNight(i,fromQueue,reason)
 i=((tonumber(i)or 1)-1)%#NIGHT_MARKET_PLAYLIST+1;if nightTransitioning then return end;if nightPrepared~=i or not nightStandby.IsLoaded then if not prepareNight(i)then hardStartNight(i,"preload-fallback");return end end
 nightTransitioning=true;nightStandby.Volume=0;nightStandby.TimePosition=0;nightStandby:SetAttribute("DeckRole","MIX_IN");nightSound:SetAttribute("DeckRole","MIX_OUT");local ok=pcall(function()nightStandby:Play()end);if not ok then nightTransitioning=false;hardStartNight(i,"standby-play-fallback");return end
 TweenService:Create(nightStandby,TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Linear),{Volume=1}):Play();TweenService:Create(nightSound,TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Linear),{Volume=0}):Play();nightGroup:SetAttribute("LastTransitionReason",reason or"automix");task.wait(MIX_SECONDS)
 local pos=math.max(0,nightStandby.TimePosition);nightSound:Stop();if fromQueue and nightQueue[1]==i then table.remove(nightQueue,1)end;nightIndex=i;configureNight(nightSound,i,1);nightSound.TimePosition=pos;nightSound:SetAttribute("DeckRole","LIVE");pcall(function()nightSound:Play()end);nightStandby:Stop();nightStandby.Volume=0;nightStandby:SetAttribute("DeckRole","STANDBY");nightPrepared=nil;nightTransitioning=false;nightStartedAt=os.clock();nightLastProgress=nightStartedAt;nightLastPos=pos;publishNightState();local n=nightNext();task.defer(function()prepareNight(n)end)
end
local function inNightMarket(player)local c=player and player.Character;local h=c and c:FindFirstChild("HumanoidRootPart");if not h then return false end;local p=h.Position;return math.abs(p.X)<=118 and p.Z>=465 and p.Z<=685 end
nightControl.OnServerEvent:Connect(function(player,action,wanted)
 action=tostring(action or"")
 if action=="request"then if not inNightMarket(player)then return end;local n=tonumber(wanted);if not n or not NIGHT_MARKET_PLAYLIST[n]then return end;local now=os.clock();if now-(nightCooldown[player.UserId]or 0)<3 then return end;nightCooldown[player.UserId]=now;table.insert(nightQueue,n);publishNightState();task.spawn(function()prepareNight(nightQueue[1])end);return end
 if not isAdmin(player)then return end
 if action=="play"then local n=tonumber(wanted);if n and NIGHT_MARKET_PLAYLIST[n]then task.spawn(function()mixNight(n,false,"admin-play")end)end
 elseif action=="next"then local n,q=nightNext();task.spawn(function()mixNight(n,q,"admin-next")end)
 elseif action=="prev"or action=="previous"then task.spawn(function()mixNight(((nightIndex-2)%#NIGHT_MARKET_PLAYLIST)+1,false,"admin-prev")end)
 elseif action=="clearqueue"then table.clear(nightQueue);publishNightState()end
end)

publishNightCatalog();publishNightState();hardStartNight(nightIndex,"startup")
task.spawn(function()
 local root2=Workspace:WaitForChild("BBYA_ZERO_BUILD",120);local market2=root2 and root2:WaitForChild("BBYANightMarket",120);if market2 then market2:SetAttribute("PlaylistKey","pasar-malam-koplo");market2:SetAttribute("PlaylistVenue","NIGHT_MARKET");market2:SetAttribute("PlaylistGenrePolicy","DANGDUT_KOPLO");market2:SetAttribute("PlaylistSyncAuthority","BBYA_MUSIC_MANAGER");market2:SetAttribute("PlaylistOutputReady",true);market2:SetAttribute("PlaylistCount",#NIGHT_MARKET_PLAYLIST);market2:SetAttribute("BackgroundMusicInjected",true);market2:SetAttribute("AudioPolicy","APPROVED_KOPLO_BANK_AUTOMIX_V2")end
end)
task.spawn(function()
 while task.wait(.25)do
  nightGroup.Volume=1;nightGroup:SetAttribute("PlaylistReady",true);nightGroup:SetAttribute("PlaylistCount",#NIGHT_MARKET_PLAYLIST)
  if not nightTransitioning then
   local now=os.clock()
   if nightSound.IsPlaying then
    local pos=nightSound.TimePosition;if pos>nightLastPos+.03 then nightLastPos=pos;nightLastProgress=now elseif now-nightStartedAt>8 and now-nightLastProgress>8 then local n,q=nightNext();task.spawn(function()mixNight(n,q,"watchdog-stall")end)end
    if nightSound.TimeLength>1 then local remaining=nightSound.TimeLength-pos;local speed=math.max(.1,nightSound.PlaybackSpeed);local n,q=nightNext();if remaining<=PRELOAD_SECONDS*speed and not nightPrepared and not nightPreparing then task.spawn(function()prepareNight(n)end)end;if remaining<=MIX_SECONDS*speed+.12 then task.spawn(function()mixNight(nightPrepared or n,q,"auto-end")end)end end
   elseif now-nightStartedAt>2.5 then local n,q=nightNext();task.spawn(function()hardStartNight(n,"watchdog-stop")end)end
  end
 end
end)

Players.PlayerRemoving:Connect(function(p)skateCooldown[p.UserId]=nil;nightCooldown[p.UserId]=nil end)
print("[BBYA] Venue audio masters v7 online: Skatepark + Pasar Malam 4s AutoMix / approved catalogs preserved")
