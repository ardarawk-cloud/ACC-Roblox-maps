-- BBYA SOCIAL HUB — VENUE AUDIO MASTERS v6 SKATE DIRECT PLAY
-- Skatepark catalog is frozen. Selected tracks are never dropped while another load is in flight.
-- Success means the Sound is actually playing AND TimePosition advances; IsLoaded alone is never treated as playback.
-- Rooftop/VIP delegation and Pasar Malam approved bank are preserved.

local SoundService=game:GetService("SoundService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ContentProvider=game:GetService("ContentProvider")
local Workspace=game:GetService("Workspace")
local NORMALIZED_175X=1/1.75

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
local NIGHT_MARKET_PLAYLIST={{title="Gadis Manis Kalimantan - Shinta Gisul",assetId="132656781327264",playbackSpeed=.8},{title="Aishiteru 2 - Ajeng Febria",assetId="85424046735289",playbackSpeed=.8},{title="Nemen (Hiphop Dangdut Version) - NDX AKA",assetId="89901574840210",playbackSpeed=.8},{title="Apa Kabar Mantan - NDX AKA",assetId="108659387121290",playbackSpeed=.8},{title="Kopi Dangdut / Tarik Sis Semongko - Vita Alvia",assetId="107887958475943",playbackSpeed=.8}}

local function ensure(name,venue,active,state)
 local g=SoundService:FindFirstChild(name);if g and not g:IsA("SoundGroup")then g:Destroy();g=nil end;if not g then g=Instance.new("SoundGroup");g.Name=name;g.Parent=SoundService end
 g.Volume=active and .72 or 0;g:SetAttribute("Venue",venue);g:SetAttribute("BBYALocalZoneOnly",true);g:SetAttribute("PlaylistReady",active==true)
 if active then g:SetAttribute("MusicCatalogState",state or"ACTIVE")else g:SetAttribute("PlaylistCount",0);g:SetAttribute("MusicCatalogState",state or"RESET_EMPTY")end;return g
end
local skateGroup=ensure("BBYASkateparkMaster","SKATEPARK",true,"SKATEPARK_MIXED_V9_DIRECT_PLAY");skateGroup.Volume=1;skateGroup:SetAttribute("VenueGainProfile","SKATEPARK_FULL_LEVEL_V1");skateGroup:SetAttribute("ApprovedPopPunkSpeed",NORMALIZED_175X);skateGroup:SetAttribute("PopPunkBank","POP PUNK");skateGroup:SetAttribute("PopPunkBankCount",12);skateGroup:SetAttribute("PopPunkBankState","ACTIVE_APPROVED_12");skateGroup:SetAttribute("PlaybackRepair","DIRECT_SELECTION_SERIALIZED_V2")
ensure("BBYARooftopMaster","ROOFTOP",true,"ROOFTOP_TROPICAL_ACTIVE");ensure("BBYAVIPMaster","VIP",false,"VIP_DELEGATED_TO_110_AUTHORITY")

local skateControl=ReplicatedStorage:FindFirstChild("BBYASkateparkMusicControl");if skateControl and not skateControl:IsA("RemoteEvent")then skateControl:Destroy();skateControl=nil end;if not skateControl then skateControl=Instance.new("RemoteEvent");skateControl.Name="BBYASkateparkMusicControl";skateControl.Parent=ReplicatedStorage end
local function publishSkateCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYASkateparkPlaylistCatalog");if folder and not folder:IsA("Folder")then folder:Destroy();folder=nil end;if not folder then folder=Instance.new("Folder");folder.Name="BBYASkateparkPlaylistCatalog";folder.Parent=ReplicatedStorage end;folder:ClearAllChildren()
 folder:SetAttribute("PlaylistId","skatepark-mixed");folder:SetAttribute("Venue","SKATEPARK");folder:SetAttribute("Count",#SKATE_PLAYLIST);folder:SetAttribute("RightsProfile","ROBLOX_CREATOR_STORE_APM_PLUS_CUSTOM_APPROVED");folder:SetAttribute("ControlRemote","BBYASkateparkMusicControl");folder:SetAttribute("ApprovedPopPunkSpeed",NORMALIZED_175X);folder:SetAttribute("PopPunkBank","POP PUNK");folder:SetAttribute("PopPunkBankCount",12);folder:SetAttribute("PopPunkBankState","ACTIVE_APPROVED_12");folder:SetAttribute("InjectionState","MALL_REGRESSION_RESTORED_V1");folder:SetAttribute("PlaybackRepair","DIRECT_SELECTION_SERIALIZED_V2")
 for i,t in ipairs(SKATE_PLAYLIST)do local row=Instance.new("StringValue");row.Name=string.format("Track%02d",i);row.Value=t.title;row:SetAttribute("AssetId",t.assetId);row:SetAttribute("Index",i);row:SetAttribute("PlaybackSpeed",tonumber(t.playbackSpeed)or 1);row:SetAttribute("ApprovalState",t.approvalState or"ROBLOX_CREATOR_STORE");if t.speedProfile then row:SetAttribute("SpeedProfile",t.speedProfile)end;if t.bank then row:SetAttribute("Bank",t.bank)end;row.Parent=folder end
end
local sound=SoundService:FindFirstChild("BBYASkateparkMasterSound");if sound and not sound:IsA("Sound")then sound:Destroy();sound=nil end;if not sound then sound=Instance.new("Sound");sound.Name="BBYASkateparkMasterSound";sound.Parent=SoundService end
sound.SoundGroup=skateGroup;sound.Volume=1;sound.Looped=false;sound.PlaybackSpeed=1;sound:SetAttribute("Venue","SKATEPARK");sound:SetAttribute("PlaylistId","skatepark-mixed");sound:SetAttribute("RightsProfile","ROBLOX_CREATOR_STORE_APM_PLUS_CUSTOM_APPROVED");sound:SetAttribute("VenueGainProfile","SKATEPARK_FULL_LEVEL_V1");sound:SetAttribute("PopPunkBankState","ACTIVE_APPROVED_12")
local index=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkCurrentIndex"))or 1;if index<1 or index>#SKATE_PLAYLIST then index=1 end
local skateQueue={};local workerBusy=false;local pendingWanted=nil;local pendingDirect=false;local lastDirectFailAt=0
local function publishQueue()local count=#skateQueue;local nextIndex=tonumber(skateQueue[1])or 0;ReplicatedStorage:SetAttribute("BBYASkateparkQueueCount",count);ReplicatedStorage:SetAttribute("BBYASkateparkNextRequestIndex",nextIndex);skateGroup:SetAttribute("QueueCount",count);skateGroup:SetAttribute("NextRequestIndex",nextIndex)end
local function publishState(track)
 ReplicatedStorage:SetAttribute("BBYASkateparkCurrentIndex",index);ReplicatedStorage:SetAttribute("BBYASkateparkCurrentTitle",track.title);ReplicatedStorage:SetAttribute("BBYASkateparkCurrentAssetId",track.assetId);ReplicatedStorage:SetAttribute("BBYASkateparkCurrentPlaybackSpeed",tonumber(track.playbackSpeed)or 1)
 skateGroup:SetAttribute("PlaylistCount",#SKATE_PLAYLIST);skateGroup:SetAttribute("CurrentIndex",index);skateGroup:SetAttribute("CurrentTitle",track.title);skateGroup:SetAttribute("CurrentAssetId",track.assetId);skateGroup:SetAttribute("CurrentPlaybackSpeed",tonumber(track.playbackSpeed)or 1);skateGroup:SetAttribute("CurrentBank",track.bank or"LEGACY");skateGroup:SetAttribute("PlaylistReady",true);publishQueue()
end
local function actuallyStarted(startPos,timeout)
 local deadline=os.clock()+(timeout or 4);local baseline=tonumber(startPos)or 0
 while os.clock()<deadline do if sound.IsPlaying and(sound.TimePosition or 0)>baseline+.03 then return true end;task.wait(.10)end;return false
end
local function attemptTrack(wanted)
 index=((tonumber(wanted)or 1)-1)%#SKATE_PLAYLIST+1;local track=SKATE_PLAYLIST[index]
 sound:Stop();sound.SoundId="rbxassetid://"..track.assetId;sound.PlaybackSpeed=tonumber(track.playbackSpeed)or 1;sound.TimePosition=0;sound:SetAttribute("Title",track.title);sound:SetAttribute("PlaylistIndex",index);sound:SetAttribute("PlaybackSpeed",sound.PlaybackSpeed);sound:SetAttribute("Bank",track.bank or"LEGACY");if track.speedProfile then sound:SetAttribute("SpeedProfile",track.speedProfile)else sound:SetAttribute("SpeedProfile",nil)end;publishState(track)
 task.spawn(function()pcall(function()ContentProvider:PreloadAsync({sound})end)end)
 for try=1,2 do
  sound.TimePosition=0;local ok=pcall(function()sound:Play()end);if ok and actuallyStarted(0,4)then skateGroup:SetAttribute("LastPlaybackStatus","PLAYING");skateGroup:SetAttribute("LastPlaybackTitle",track.title);skateGroup:SetAttribute("LastPlaybackAssetId",track.assetId);return true end
  sound:Stop();task.wait(.18)
 end
 skateGroup:SetAttribute("LastUnavailableTitle",track.title);skateGroup:SetAttribute("LastUnavailableAssetId",track.assetId);skateGroup:SetAttribute("LastPlaybackStatus","FAILED_TO_ADVANCE");return false
end
local function startWorker()
 if workerBusy then return end;workerBusy=true
 task.spawn(function()
  while pendingWanted do
   local wanted=pendingWanted;local direct=pendingDirect;pendingWanted=nil;pendingDirect=false
   local ok=attemptTrack(wanted);if not ok and direct then lastDirectFailAt=os.clock()end
   -- A request arriving while this attempt ran is retained in pendingWanted and runs next.
  end
  workerBusy=false
 end)
end
local function scheduleWanted(wanted,direct)
 local n=tonumber(wanted);if not n or n<1 or n>#SKATE_PLAYLIST then return end
 if direct or pendingWanted==nil then pendingWanted=math.floor(n);pendingDirect=direct==true end
 startWorker()
end
local function popNextWanted()if #skateQueue>0 then local wanted=table.remove(skateQueue,1);publishQueue();return wanted end;return index%#SKATE_PLAYLIST+1 end
local function isAdmin(player)return player:GetAttribute("BBYAAdmin")==true or player:GetAttribute("BBYAOwner")==true or(game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)end
skateControl.OnServerEvent:Connect(function(player,action,wanted)
 action=tostring(action or"")
 if action=="request"then local n=tonumber(wanted);if not n or n<1 or n>#SKATE_PLAYLIST then return end;if isAdmin(player)then scheduleWanted(n,true)else table.insert(skateQueue,math.floor(n));publishQueue();if not sound.IsPlaying then scheduleWanted(popNextWanted(),false)end end;return end
 if not isAdmin(player)then return end
 if action=="play"then scheduleWanted(wanted,true)elseif action=="next"then scheduleWanted(popNextWanted(),true)elseif action=="prev"then scheduleWanted(((math.max(index,1)-2)%#SKATE_PLAYLIST)+1,true)elseif action=="clearqueue"then table.clear(skateQueue);publishQueue()end
end)
sound.Ended:Connect(function()task.defer(function()scheduleWanted(popNextWanted(),false)end)end)
publishSkateCatalog();publishQueue();scheduleWanted(index,false)
task.spawn(function()while task.wait(1.25)do skateGroup.Volume=1;sound.Volume=1;skateGroup:SetAttribute("PlaylistReady",true);skateGroup:SetAttribute("PlaylistCount",#SKATE_PLAYLIST);if not sound.IsPlaying and not workerBusy and os.clock()-lastDirectFailAt>4 then scheduleWanted(popNextWanted(),false)end end end)

-- PASAR MALAM KOPLO — preserved approved five-track authority.
local nightMarketGroup=ensure("BBYANightMarketMaster","NIGHT_MARKET",true,"NIGHT_MARKET_KOPLO_APPROVED_V1");nightMarketGroup.Volume=1;nightMarketGroup:SetAttribute("PlaylistId","pasar-malam-koplo");nightMarketGroup:SetAttribute("GenrePolicy","DANGDUT_KOPLO");nightMarketGroup:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER");nightMarketGroup:SetAttribute("Authority","VENUE_AUDIO_MASTERS_V6");nightMarketGroup:SetAttribute("PlaylistCount",#NIGHT_MARKET_PLAYLIST);nightMarketGroup:SetAttribute("RightsProfile","UNIVERSE_PERMISSION_HTTP_200_APPROVED_ONLY")
local function publishNightMarketCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYANightMarketPlaylistCatalog");if folder and not folder:IsA("Folder")then folder:Destroy();folder=nil end;if not folder then folder=Instance.new("Folder");folder.Name="BBYANightMarketPlaylistCatalog";folder.Parent=ReplicatedStorage end;folder:ClearAllChildren();folder:SetAttribute("PlaylistId","pasar-malam-koplo");folder:SetAttribute("Venue","NIGHT_MARKET");folder:SetAttribute("GenrePolicy","DANGDUT_KOPLO");folder:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER");folder:SetAttribute("Count",#NIGHT_MARKET_PLAYLIST);folder:SetAttribute("PlaybackSpeed",.8);folder:SetAttribute("ApprovalState","5_APPROVED_2_REJECTED_EXCLUDED");folder:SetAttribute("RightsProfile","UNIVERSE_PERMISSION_HTTP_200_APPROVED_ONLY");folder:SetAttribute("OutputSound","BBYANightMarketMasterSound");folder:SetAttribute("SoundGroup","BBYANightMarketMaster");folder:SetAttribute("InjectionState","ACTIVE_APPROVED_BANK_V1")
 for i,t in ipairs(NIGHT_MARKET_PLAYLIST)do local row=Instance.new("StringValue");row.Name=string.format("Track%02d",i);row.Value=t.title;row:SetAttribute("AssetId",t.assetId);row:SetAttribute("Index",i);row:SetAttribute("PlaybackSpeed",tonumber(t.playbackSpeed)or .8);row:SetAttribute("ApprovalState","APPROVED");row.Parent=folder end
end
local nightMarketSound=SoundService:FindFirstChild("BBYANightMarketMasterSound");if nightMarketSound and not nightMarketSound:IsA("Sound")then nightMarketSound:Destroy();nightMarketSound=nil end;if not nightMarketSound then nightMarketSound=Instance.new("Sound");nightMarketSound.Name="BBYANightMarketMasterSound";nightMarketSound.Parent=SoundService end
nightMarketSound.SoundGroup=nightMarketGroup;nightMarketSound.Volume=1;nightMarketSound.Looped=false;nightMarketSound.PlaybackSpeed=.8;nightMarketSound:SetAttribute("Venue","NIGHT_MARKET");nightMarketSound:SetAttribute("PlaylistId","pasar-malam-koplo");nightMarketSound:SetAttribute("GenrePolicy","DANGDUT_KOPLO");nightMarketSound:SetAttribute("SyncAuthority","BBYA_MUSIC_MANAGER");nightMarketSound:SetAttribute("RightsProfile","UNIVERSE_PERMISSION_HTTP_200_APPROVED_ONLY")
local nightMarketIndex=tonumber(ReplicatedStorage:GetAttribute("BBYANightMarketCurrentIndex"))or 1;if nightMarketIndex<1 or nightMarketIndex>#NIGHT_MARKET_PLAYLIST then nightMarketIndex=1 end;local nightMarketSwitching=false
local function publishNightMarketState(track)local speed=tonumber(track.playbackSpeed)or .8;ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistEnabled",true);ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistId","pasar-malam-koplo");ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistCount",#NIGHT_MARKET_PLAYLIST);ReplicatedStorage:SetAttribute("BBYANightMarketCurrentIndex",nightMarketIndex);ReplicatedStorage:SetAttribute("BBYANightMarketCurrentTitle",track.title);ReplicatedStorage:SetAttribute("BBYANightMarketCurrentAssetId",track.assetId);ReplicatedStorage:SetAttribute("BBYANightMarketCurrentPlaybackSpeed",speed);ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistOutputReady",true);nightMarketGroup:SetAttribute("CurrentIndex",nightMarketIndex);nightMarketGroup:SetAttribute("CurrentTitle",track.title);nightMarketGroup:SetAttribute("CurrentAssetId",track.assetId);nightMarketGroup:SetAttribute("CurrentPlaybackSpeed",speed);nightMarketGroup:SetAttribute("PlaylistReady",true);nightMarketSound:SetAttribute("Title",track.title);nightMarketSound:SetAttribute("PlaylistIndex",nightMarketIndex);nightMarketSound:SetAttribute("PlaybackSpeed",speed)end
local function playNightMarketIndex(wanted)
 if nightMarketSwitching then return end;nightMarketSwitching=true;nightMarketIndex=((tonumber(wanted)or 1)-1)%#NIGHT_MARKET_PLAYLIST+1;local track=NIGHT_MARKET_PLAYLIST[nightMarketIndex];nightMarketSound:Stop();nightMarketSound.SoundId="rbxassetid://"..track.assetId;nightMarketSound.PlaybackSpeed=tonumber(track.playbackSpeed)or .8;nightMarketSound.TimePosition=0;publishNightMarketState(track);task.spawn(function()pcall(function()ContentProvider:PreloadAsync({nightMarketSound})end)end);pcall(function()nightMarketSound:Play()end);nightMarketSwitching=false
end
nightMarketSound.Ended:Connect(function()task.defer(function()playNightMarketIndex(nightMarketIndex%#NIGHT_MARKET_PLAYLIST+1)end)end);publishNightMarketCatalog();playNightMarketIndex(nightMarketIndex)
task.spawn(function()local root2=Workspace:WaitForChild("BBYA_ZERO_BUILD",120);local market2=root2 and root2:WaitForChild("BBYANightMarket",120);if market2 then market2:SetAttribute("PlaylistKey","pasar-malam-koplo");market2:SetAttribute("PlaylistVenue","NIGHT_MARKET");market2:SetAttribute("PlaylistGenrePolicy","DANGDUT_KOPLO");market2:SetAttribute("PlaylistSyncAuthority","BBYA_MUSIC_MANAGER");market2:SetAttribute("PlaylistOutputReady",true);market2:SetAttribute("PlaylistCount",#NIGHT_MARKET_PLAYLIST);market2:SetAttribute("BackgroundMusicInjected",true);market2:SetAttribute("AudioPolicy","APPROVED_KOPLO_BANK_ACTIVE_V1")end end)
task.spawn(function()while task.wait(1.25)do nightMarketGroup.Volume=1;nightMarketSound.Volume=1;nightMarketGroup:SetAttribute("PlaylistReady",true);nightMarketGroup:SetAttribute("PlaylistCount",#NIGHT_MARKET_PLAYLIST);ReplicatedStorage:SetAttribute("BBYANightMarketPlaylistEnabled",true);if not nightMarketSound.IsPlaying and not nightMarketSwitching then playNightMarketIndex(nightMarketIndex)end end end)
print("[BBYA] Venue audio masters v6 online: Skatepark direct selection serialized / POP PUNK 12 frozen / Pasar Malam preserved")
