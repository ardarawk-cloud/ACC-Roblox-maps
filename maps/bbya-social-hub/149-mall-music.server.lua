-- BBYA SOCIAL HUB — MALL KPOP MUSIC AUTHORITY v3 CLEAN
-- Single Mall audio/catalog authority. Preserves the locked 18-track KPOP bank.
-- Playback starts immediately; preload is best-effort and never gates Play().

local SoundService=game:GetService("SoundService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ContentProvider=game:GetService("ContentProvider")
local Players=game:GetService("Players")

local PLAYBACK_SPEED=0.5714285714
local PLAYLIST={
 {title="HANTU",assetId="130787669922537"},{title="MALU BANGET",assetId="128649936033154"},{title="STRATEGI KU",assetId="87125114946473"},{title="DI JATUHKAN",assetId="138472779676021"},{title="MEMULAI SEBELAHMU",assetId="115164716109234"},{title="TOPIK",assetId="106731979070100"},{title="MERAH MUDA",assetId="82573111697282"},{title="YA TUHAN",assetId="84541295288456"},{title="MALAM YANG SEMPURNA",assetId="112025968048348"},{title="KEREN",assetId="102724403050017"},{title="SEPERTI GILA",assetId="101221026959656"},{title="TERKENAL",assetId="102729376941557"},{title="AKU",assetId="130045741934771"},{title="EMAS",assetId="94909694876329"},{title="DITOK",assetId="128638509475237"},{title="AKU DAN KAMU",assetId="115814496839320"},{title="BUNGA",assetId="134192777315026"},{title="SATU ATAU DELAPAN",assetId="85568242991971"},
}

local control=ReplicatedStorage:FindFirstChild("BBYAMallMusicControl");if control and not control:IsA("RemoteEvent")then control:Destroy();control=nil end;if not control then control=Instance.new("RemoteEvent");control.Name="BBYAMallMusicControl";control.Parent=ReplicatedStorage end
local group=SoundService:FindFirstChild("BBYAMallMaster");if group and not group:IsA("SoundGroup")then group:Destroy();group=nil end;if not group then group=Instance.new("SoundGroup");group.Name="BBYAMallMaster";group.Parent=SoundService end
group.Volume=.86;group:SetAttribute("Venue","MALL");group:SetAttribute("BBYALocalZoneOnly",true);group:SetAttribute("PlaylistReady",true);group:SetAttribute("PlaylistCount",#PLAYLIST);group:SetAttribute("MusicCatalogState","MALL_KPOP_CLEAN_V3");group:SetAttribute("AutoPlay",true);group:SetAttribute("ShuffleMode","RANDOM_NO_REPEAT_CYCLE")
local sound=SoundService:FindFirstChild("BBYAMallMasterSound");if sound and not sound:IsA("Sound")then sound:Destroy();sound=nil end;if not sound then sound=Instance.new("Sound");sound.Name="BBYAMallMasterSound";sound.Parent=SoundService end
sound.SoundGroup=group;sound.Volume=.78;sound.Looped=false;sound.PlaybackSpeed=PLAYBACK_SPEED;sound:SetAttribute("Venue","MALL");sound:SetAttribute("Bank","KPOP");sound:SetAttribute("Authority","MALL_KPOP_V3_CLEAN")

local function publishCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYAMallPlaylistCatalog");if folder and not folder:IsA("Folder")then folder:Destroy();folder=nil end;if not folder then folder=Instance.new("Folder");folder.Name="BBYAMallPlaylistCatalog";folder.Parent=ReplicatedStorage end;folder:ClearAllChildren();folder:SetAttribute("PlaylistId","mall-kpop-random");folder:SetAttribute("Venue","MALL");folder:SetAttribute("Bank","KPOP");folder:SetAttribute("Count",#PLAYLIST);folder:SetAttribute("ControlRemote","BBYAMallMusicControl");folder:SetAttribute("OutputSound","BBYAMallMasterSound");folder:SetAttribute("SoundGroup","BBYAMallMaster");folder:SetAttribute("PlaybackSpeed",PLAYBACK_SPEED);folder:SetAttribute("AutoPlay",true);folder:SetAttribute("ShuffleMode","RANDOM_NO_REPEAT_CYCLE");folder:SetAttribute("Authority","MALL_KPOP_V3_CLEAN")
 for i,t in ipairs(PLAYLIST)do local row=Instance.new("StringValue");row.Name=string.format("Track%02d",i);row.Value=t.title;row:SetAttribute("Index",i);row:SetAttribute("AssetId",t.assetId);row:SetAttribute("Artist","KPOP");row:SetAttribute("PlaybackSpeed",PLAYBACK_SPEED);row.Parent=folder end
end
publishCatalog()

local current=math.random(1,#PLAYLIST);local bag={};local queue={};local cooldown={};local switching=false;local startedAt=0
local function shuffle(t)for i=#t,2,-1 do local j=math.random(1,i);t[i],t[j]=t[j],t[i]end end
local function refill()bag={};for i=1,#PLAYLIST do if i~=current then table.insert(bag,i)end end;shuffle(bag)end
local function nextIndex()if #queue>0 then local n=table.remove(queue,1);return n end;if #bag==0 then refill()end;local n=table.remove(bag,1);if not n or n==current then refill();n=table.remove(bag,1)end;return n or(current%#PLAYLIST+1)end
local function publishState()
 local t=PLAYLIST[current];ReplicatedStorage:SetAttribute("BBYAMallPlaylistEnabled",true);ReplicatedStorage:SetAttribute("BBYAMallPlaylistId","mall-kpop-random");ReplicatedStorage:SetAttribute("BBYAMallPlaylistCount",#PLAYLIST);ReplicatedStorage:SetAttribute("BBYAMallCurrentIndex",current);ReplicatedStorage:SetAttribute("BBYAMallCurrentTitle",t.title);ReplicatedStorage:SetAttribute("BBYAMallCurrentAssetId",t.assetId);ReplicatedStorage:SetAttribute("BBYAMallPlaybackSpeed",PLAYBACK_SPEED);ReplicatedStorage:SetAttribute("BBYAMallQueueCount",#queue);ReplicatedStorage:SetAttribute("BBYAMallNextRequestIndex",tonumber(queue[1])or 0);group:SetAttribute("CurrentIndex",current);group:SetAttribute("CurrentTitle",t.title);group:SetAttribute("CurrentAssetId",t.assetId);group:SetAttribute("QueueCount",#queue);sound:SetAttribute("Title",t.title);sound:SetAttribute("PlaylistIndex",current)
end
local function start(wanted)
 if switching then return end;switching=true;current=((tonumber(wanted)or 1)-1)%#PLAYLIST+1;local t=PLAYLIST[current];sound:Stop();sound.SoundId="rbxassetid://"..t.assetId;sound.PlaybackSpeed=PLAYBACK_SPEED;sound.TimePosition=0;publishState();startedAt=os.clock();local ok=pcall(function()sound:Play()end);if not ok then group:SetAttribute("LastStartOk",false)else group:SetAttribute("LastStartOk",true);group:SetAttribute("LastStartTitle",t.title)end;task.spawn(function()pcall(function()ContentProvider:PreloadAsync({sound})end)end);switching=false;print("[BBYA] Mall KPOP v3 start",current,t.title,t.assetId)
end
sound.Ended:Connect(function()task.defer(function()start(nextIndex())end)end)
local function inZone(p)local c=p and p.Character;local h=c and c:FindFirstChild("HumanoidRootPart");if not h then return false end;local x=h.Position;return x.X>=-108 and x.X<=108 and x.Y>=-6 and x.Y<=75 and x.Z>=248 and x.Z<=455 end
local function admin(p)return p and(p:GetAttribute("BBYAAdmin")==true or p:GetAttribute("BBYAOwner")==true or(game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId))end
control.OnServerEvent:Connect(function(p,action,wanted)
 action=tostring(action or"");if action=="request"then if not inZone(p)then return end;local n=tonumber(wanted);if not n or not PLAYLIST[n]then return end;local now=os.clock();if now-(cooldown[p.UserId]or 0)<3 then return end;cooldown[p.UserId]=now;table.insert(queue,n);publishState();if not sound.IsPlaying then task.defer(function()start(nextIndex())end)end;return end;if not admin(p)then return end;if action=="next"then task.defer(function()start(nextIndex())end)elseif action=="play"then local n=tonumber(wanted);if n and PLAYLIST[n]then task.defer(function()start(n)end)end elseif action=="clearqueue"then table.clear(queue);publishState()end
end)
Players.PlayerRemoving:Connect(function(p)cooldown[p.UserId]=nil end)
refill();start(current)
task.spawn(function()while task.wait(1)do group.Volume=.86;sound.Volume=.78;sound.PlaybackSpeed=PLAYBACK_SPEED;group:SetAttribute("PlaylistReady",true);group:SetAttribute("PlaylistCount",#PLAYLIST);publishState();if not sound.IsPlaying and not switching and os.clock()-startedAt>1.5 then start(nextIndex())end end end)
print("[BBYA] Mall KPOP v3 online: 18 tracks preserved / immediate Play / best-effort preload / self-heal")