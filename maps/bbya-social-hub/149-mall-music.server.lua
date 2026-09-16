-- BBYA SOCIAL HUB — MALL KPOP MUSIC AUTHORITY v5 AUTOMIX
-- Preserves the locked 18-track KPOP bank, progress watchdog, kiosk recovery and opt-in LookLab seating.
-- Adds standby preload + 4-second crossfade so the next song starts before the current song fully ends.

local SoundService=game:GetService("SoundService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local TweenService=game:GetService("TweenService")
local ContentProvider=game:GetService("ContentProvider")

local PLAYBACK_SPEED=0.5714285714
local MIX_SECONDS=4
local PRELOAD_SECONDS=12
local LOAD_TIMEOUT=5
local LIVE_VOLUME=.78
local PLAYLIST={
 {title="HANTU",assetId="130787669922537"},{title="MALU BANGET",assetId="128649936033154"},{title="STRATEGI KU",assetId="87125114946473"},{title="DI JATUHKAN",assetId="138472779676021"},{title="MEMULAI SEBELAHMU",assetId="115164716109234"},{title="TOPIK",assetId="106731979070100"},{title="MERAH MUDA",assetId="82573111697282"},{title="YA TUHAN",assetId="84541295288456"},{title="MALAM YANG SEMPURNA",assetId="112025968048348"},{title="KEREN",assetId="102724403050017"},{title="SEPERTI GILA",assetId="101221026959656"},{title="TERKENAL",assetId="102729376941557"},{title="AKU",assetId="130045741934771"},{title="EMAS",assetId="94909694876329"},{title="DITOK",assetId="128638509475237"},{title="AKU DAN KAMU",assetId="115814496839320"},{title="BUNGA",assetId="134192777315026"},{title="SATU ATAU DELAPAN",assetId="85568242991971"},
}

local control=ReplicatedStorage:FindFirstChild("BBYAMallMusicControl")
if control and not control:IsA("RemoteEvent")then control:Destroy();control=nil end
if not control then control=Instance.new("RemoteEvent");control.Name="BBYAMallMusicControl";control.Parent=ReplicatedStorage end

local group=SoundService:FindFirstChild("BBYAMallMaster")
if group and not group:IsA("SoundGroup")then group:Destroy();group=nil end
if not group then group=Instance.new("SoundGroup");group.Name="BBYAMallMaster";group.Parent=SoundService end
group.Volume=.86
group:SetAttribute("Venue","MALL")
group:SetAttribute("BBYALocalZoneOnly",true)
group:SetAttribute("PlaylistReady",true)
group:SetAttribute("PlaylistCount",#PLAYLIST)
group:SetAttribute("MusicCatalogState","MALL_KPOP_AUTOMIX_V5")
group:SetAttribute("AutoPlay",true)
group:SetAttribute("ShuffleMode","RANDOM_NO_REPEAT_CYCLE")
group:SetAttribute("HealthMode","PROGRESS_WATCHDOG_AUTOMIX_V5")
group:SetAttribute("AutoMix",true)
group:SetAttribute("MixSeconds",MIX_SECONDS)

local sound=SoundService:FindFirstChild("BBYAMallMasterSound")
if sound and not sound:IsA("Sound")then sound:Destroy();sound=nil end
if not sound then sound=Instance.new("Sound");sound.Name="BBYAMallMasterSound";sound.Parent=SoundService end
local standby=SoundService:FindFirstChild("BBYAMallStandby")
if standby and not standby:IsA("Sound")then standby:Destroy();standby=nil end
if not standby then standby=Instance.new("Sound");standby.Name="BBYAMallStandby";standby.Parent=SoundService end
for _,s in ipairs({sound,standby})do s.SoundGroup=group;s.Looped=false;s.PlaybackSpeed=PLAYBACK_SPEED;s:SetAttribute("Venue","MALL");s:SetAttribute("Bank","KPOP");s:SetAttribute("Authority","MALL_KPOP_AUTOMIX_V5")end
sound.Volume=LIVE_VOLUME;standby.Volume=0;sound:SetAttribute("DeckRole","LIVE");standby:SetAttribute("DeckRole","STANDBY")

local function publishCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYAMallPlaylistCatalog")
 if folder and not folder:IsA("Folder")then folder:Destroy();folder=nil end
 if not folder then folder=Instance.new("Folder");folder.Name="BBYAMallPlaylistCatalog";folder.Parent=ReplicatedStorage end
 folder:ClearAllChildren();folder:SetAttribute("PlaylistId","mall-kpop-random");folder:SetAttribute("Venue","MALL");folder:SetAttribute("Bank","KPOP");folder:SetAttribute("Count",#PLAYLIST);folder:SetAttribute("ControlRemote","BBYAMallMusicControl");folder:SetAttribute("OutputSound","BBYAMallMasterSound");folder:SetAttribute("SoundGroup","BBYAMallMaster");folder:SetAttribute("PlaybackSpeed",PLAYBACK_SPEED);folder:SetAttribute("AutoPlay",true);folder:SetAttribute("ShuffleMode","RANDOM_NO_REPEAT_CYCLE");folder:SetAttribute("Authority","MALL_KPOP_AUTOMIX_V5");folder:SetAttribute("AutoMix",true);folder:SetAttribute("MixSeconds",MIX_SECONDS)
 for i,t in ipairs(PLAYLIST)do local row=Instance.new("StringValue");row.Name=string.format("Track%02d",i);row.Value=t.title;row:SetAttribute("Index",i);row:SetAttribute("AssetId",t.assetId);row:SetAttribute("Artist","KPOP");row:SetAttribute("PlaybackSpeed",PLAYBACK_SPEED);row.Parent=folder end
end
publishCatalog()

local current=math.random(1,#PLAYLIST)
local bag={}
local queue={}
local cooldown={}
local badUntil={}
local preparedIndex=nil
local preparedFromQueue=false
local preparing=false
local transitioning=false
local startedAt=0
local lastProgressAt=0
local lastPosition=0

local function shuffle(t)for i=#t,2,-1 do local j=math.random(1,i);t[i],t[j]=t[j],t[i]end end
local function healthy(i)return PLAYLIST[i] and (badUntil[i]or 0)<=os.clock()end
local function refill()
 bag={};for i=1,#PLAYLIST do if i~=current and healthy(i)then table.insert(bag,i)end end
 if #bag==0 then table.clear(badUntil);for i=1,#PLAYLIST do if i~=current then table.insert(bag,i)end end end
 shuffle(bag)
end
local function firstQueue()
 while #queue>0 do if healthy(queue[1])then return queue[1]end;table.remove(queue,1)end
 return nil
end
local function peekNext()
 local q=firstQueue();if q then return q,true end
 if #bag==0 then refill()end
 while #bag>0 and(not healthy(bag[#bag])or bag[#bag]==current)do table.remove(bag)end
 if #bag==0 then refill()end
 return bag[#bag]or(current%#PLAYLIST+1),false
end
local function consumePrepared(i,fromQueue)
 if fromQueue and queue[1]==i then table.remove(queue,1)
 elseif not fromQueue then for n=#bag,1,-1 do if bag[n]==i then table.remove(bag,n);break end end end
end
local function waitLoaded(s,timeout)local deadline=os.clock()+(timeout or LOAD_TIMEOUT);while os.clock()<deadline do if s.IsLoaded and(s.TimeLength or 0)>1 then return true end;task.wait(.1)end;return s.IsLoaded and(s.TimeLength or 0)>1 end
local function configure(s,i,vol)local t=PLAYLIST[i];s:Stop();s.SoundId="rbxassetid://"..t.assetId;s.PlaybackSpeed=PLAYBACK_SPEED;s.TimePosition=0;s.Volume=vol or 0;s:SetAttribute("Title",t.title);s:SetAttribute("PlaylistIndex",i);s:SetAttribute("DeckRole",s==sound and"LIVE"or"STANDBY")end
local function publishState()
 local t=PLAYLIST[current];ReplicatedStorage:SetAttribute("BBYAMallPlaylistEnabled",true);ReplicatedStorage:SetAttribute("BBYAMallPlaylistId","mall-kpop-random");ReplicatedStorage:SetAttribute("BBYAMallPlaylistCount",#PLAYLIST);ReplicatedStorage:SetAttribute("BBYAMallCurrentIndex",current);ReplicatedStorage:SetAttribute("BBYAMallCurrentTitle",t.title);ReplicatedStorage:SetAttribute("BBYAMallCurrentAssetId",t.assetId);ReplicatedStorage:SetAttribute("BBYAMallPlaybackSpeed",PLAYBACK_SPEED);ReplicatedStorage:SetAttribute("BBYAMallQueueCount",#queue);ReplicatedStorage:SetAttribute("BBYAMallNextRequestIndex",tonumber(queue[1])or 0);group:SetAttribute("CurrentIndex",current);group:SetAttribute("CurrentTitle",t.title);group:SetAttribute("CurrentAssetId",t.assetId);group:SetAttribute("QueueCount",#queue);group:SetAttribute("StandbyIndex",preparedIndex or 0);sound:SetAttribute("Title",t.title);sound:SetAttribute("PlaylistIndex",current)
end
local function quarantine(i,reason)if not i then return end;badUntil[i]=os.clock()+30;group:SetAttribute("LastHealthFailure",tostring(reason or"unknown"));group:SetAttribute("LastHealthFailureIndex",i);if preparedIndex==i then preparedIndex=nil;preparedFromQueue=false end end
local function prepare(i,fromQueue)
 i=((tonumber(i)or 1)-1)%#PLAYLIST+1;if not healthy(i)or preparing then return false end
 if preparedIndex==i and standby.IsLoaded then preparedFromQueue=fromQueue==true;return true end
 preparing=true;preparedIndex=i;preparedFromQueue=fromQueue==true;configure(standby,i,0);standby:SetAttribute("DeckRole","STANDBY");task.spawn(function()pcall(function()ContentProvider:PreloadAsync({standby})end)end);local ok=waitLoaded(standby,LOAD_TIMEOUT);preparing=false
 if not ok then quarantine(i,"standby-preload-failed");return false end;publishState();return true
end
local function prepareDesired()local i,q=peekNext();if i then return prepare(i,q)end;return false end
local function hardStart(i,reason)
 i=((tonumber(i)or 1)-1)%#PLAYLIST+1;if not healthy(i)then local n,q=peekNext();i=n or i;consumePrepared(i,q)end
 current=i;preparedIndex=nil;preparedFromQueue=false;configure(sound,i,LIVE_VOLUME);standby:Stop();standby.Volume=0;standby:SetAttribute("DeckRole","STANDBY");startedAt=os.clock();lastProgressAt=startedAt;lastPosition=0;publishState();local ok=pcall(function()sound:Play()end);group:SetAttribute("LastStartOk",ok);group:SetAttribute("LastTransitionReason",reason or"hard-start");task.defer(prepareDesired)
end
local function mixTo(i,fromQueue,reason)
 i=((tonumber(i)or 1)-1)%#PLAYLIST+1;if transitioning then return end
 if preparedIndex~=i or not standby.IsLoaded then if not prepare(i,fromQueue)then quarantine(i,"preload-fallback");local n,q=peekNext();hardStart(n or(current%#PLAYLIST+1),reason or"preload-fallback");return end end
 transitioning=true;standby.Volume=0;standby.TimePosition=0;standby:SetAttribute("DeckRole","MIX_IN");sound:SetAttribute("DeckRole","MIX_OUT");local ok=pcall(function()standby:Play()end);if not ok then transitioning=false;quarantine(i,"standby-play-failed");hardStart(i,"standby-play-fallback");return end
 TweenService:Create(standby,TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Linear),{Volume=LIVE_VOLUME}):Play();TweenService:Create(sound,TweenInfo.new(MIX_SECONDS,Enum.EasingStyle.Linear),{Volume=0}):Play();group:SetAttribute("LastTransitionReason",reason or"automix");task.wait(MIX_SECONDS)
 local handoff=math.max(0,standby.TimePosition);sound:Stop();consumePrepared(i,fromQueue);current=i;configure(sound,i,LIVE_VOLUME);sound.TimePosition=handoff;sound:SetAttribute("DeckRole","LIVE");pcall(function()sound:Play()end);standby:Stop();standby.Volume=0;standby:SetAttribute("DeckRole","STANDBY");preparedIndex=nil;preparedFromQueue=false;transitioning=false;startedAt=os.clock();lastProgressAt=startedAt;lastPosition=handoff;publishState();task.defer(prepareDesired)
end

local function inZone(p)local c=p and p.Character;local h=c and c:FindFirstChild("HumanoidRootPart");if not h then return false end;local x=h.Position;return x.X>=-108 and x.X<=108 and x.Y>=-6 and x.Y<=88 and x.Z>=248 and x.Z<=455 end
local function admin(p)return p and(p:GetAttribute("BBYAAdmin")==true or p:GetAttribute("BBYAOwner")==true or(game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId))end
control.OnServerEvent:Connect(function(p,action,wanted)
 action=tostring(action or"")
 if action=="request"then if not inZone(p)then return end;local n=tonumber(wanted);if not n or not PLAYLIST[n]then return end;local now=os.clock();if now-(cooldown[p.UserId]or 0)<3 then return end;cooldown[p.UserId]=now;table.insert(queue,n);publishState();if not transitioning then task.spawn(prepareDesired)end;return end
 if not admin(p)then return end
 if action=="next"then local n,q=peekNext();task.spawn(function()mixTo(n,q,"admin-next")end)
 elseif action=="play"then local n=tonumber(wanted);if n and PLAYLIST[n]then task.spawn(function()mixTo(n,false,"admin-play")end)end
 elseif action=="clearqueue"then table.clear(queue);publishState();task.spawn(prepareDesired)end
end)
Players.PlayerRemoving:Connect(function(p)cooldown[p.UserId]=nil end)

refill();hardStart(current,"startup-random")
task.spawn(function()
 while task.wait(.25)do
  group.Volume=.86;group:SetAttribute("PlaylistReady",true);group:SetAttribute("PlaylistCount",#PLAYLIST);sound.PlaybackSpeed=PLAYBACK_SPEED
  if not transitioning then
   local now=os.clock()
   if sound.IsPlaying then
    local pos=sound.TimePosition
    if pos>lastPosition+.03 then lastPosition=pos;lastProgressAt=now elseif now-startedAt>8 and now-lastProgressAt>8 then quarantine(current,"stalled-timeposition");local n,q=peekNext();hardStart(n or(current%#PLAYLIST+1),"stalled")end
    if sound.TimeLength>1 then local remaining=sound.TimeLength-pos;local triggerSpeed=math.max(.1,sound.PlaybackSpeed);if remaining<=PRELOAD_SECONDS*triggerSpeed and not preparedIndex and not preparing then task.spawn(prepareDesired)end;if remaining<=MIX_SECONDS*triggerSpeed+.12 then local n=preparedIndex;local q=preparedFromQueue;if not n then n,q=peekNext()end;task.spawn(function()mixTo(n,q,"auto-end")end)end end
   elseif now-startedAt>2.5 then quarantine(current,"unexpected-stop");local n,q=peekNext();hardStart(n or(current%#PLAYLIST+1),"watchdog-stop")end
  end
 end
end)

-- Mall-only runtime reliability guards ----------------------------------------
-- 1) Re-add a browse prompt only when a tenant has lost the commerce server's primary kiosk.
-- 2) Retire LookLab auto-touch seating and replace it with an explicit STYLE prompt.
task.spawn(function()
 local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",90);if not root then return end
 local mall=root:WaitForChild("BBYAMall",90);if not mall then return end
 local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30);if not remotes then return end
 local commerce=remotes:WaitForChild("MallRobuxCommerce",30)
 local lookRemote=remotes:WaitForChild("LookLabAvatar",30)
 local stores={
  {unit="Tenant_luma",key="FASHION",title="LUMA FASHION"},{unit="Tenant_stride",key="SHOES",title="STRIDE SNEAKERS"},{unit="Tenant_byte",key="BYTE",title="BYTE TECH"},
  {unit="Tenant_daily",key="DAILY",title="DAILY MARKET"},{unit="Tenant_mono",key="MONO",title="MONO HOME"},{unit="Tenant_muse",key="BEAUTY",title="MUSE BEAUTY"},
  {unit="Tenant_north",key="NORTH",title="NORTH LABEL"},{unit="Tenant_street",key="STREETWEAR",title="STREET UNIT"},{unit="Tenant_page",key="BOOKS",title="PAGE & CO"},
  {unit="Tenant_glow",key="GLOW",title="GLOW LAB"},{unit="Tenant_sound",key="SOUND",title="SOUND ROOM"},{unit="Tenant_fit",key="FIT",title="FIT DISTRICT"},
 }
 local function ensureBrowsePrompt(spec)
  if not commerce then return end
  local unit=mall:FindFirstChild(spec.unit);if not unit then return end
  local primary=unit:FindFirstChild("BBYAServerCatalogPrompt",true)
  local fallback=unit:FindFirstChild("BBYACatalogFallbackPrompt",true)
  if primary then if fallback then fallback:Destroy()end;return end
  if fallback then return end
  local anchor=unit:FindFirstChild("BBYACatalogDisplayServer",true)or unit:FindFirstChild("Display2",true)or unit:FindFirstChild("Counter",true)or unit:FindFirstChild("Floor",true)
  if not anchor or not anchor:IsA("BasePart")then return end
  local q=Instance.new("ProximityPrompt");q.Name="BBYACatalogFallbackPrompt";q.ActionText="BROWSE";q.ObjectText=spec.title;q.KeyboardKeyCode=Enum.KeyCode.E;q.GamepadKeyCode=Enum.KeyCode.ButtonX;q.MaxActivationDistance=9;q.HoldDuration=0;q.RequiresLineOfSight=false;q.Parent=anchor
  q.Triggered:Connect(function(p)if p and p.Parent then commerce:FireClient(p,"open",{key=spec.key,title=spec.title,subtitle="ROBLOX MARKETPLACE"})end end)
 end
 local function fixLookLab()
  if not lookRemote then return end
  local glow=mall:FindFirstChild("Tenant_glow");if not glow then return end
  for _,d in ipairs(glow:GetDescendants())do if d.Name:match("^AutoStyleTrigger")then d:Destroy()end end
  for _,seat in ipairs(glow:GetDescendants())do
   if seat:IsA("Seat")and seat.Name:match("^LookLabSeat")then
    seat.CanTouch=false;seat.CanCollide=false;seat.CanQuery=false
    if not seat:FindFirstChild("LookLabStylePrompt")then
     local q=Instance.new("ProximityPrompt");q.Name="LookLabStylePrompt";q.ActionText="STYLE";q.ObjectText="LOOK LAB";q.KeyboardKeyCode=Enum.KeyCode.E;q.GamepadKeyCode=Enum.KeyCode.ButtonX;q.MaxActivationDistance=7;q.HoldDuration=.05;q.RequiresLineOfSight=false;q.Parent=seat
     q.Triggered:Connect(function(p)
      local ch=p and p.Character;local hum=ch and ch:FindFirstChildOfClass("Humanoid");if not hum or hum.Health<=0 then return end
      if seat.Occupant and seat.Occupant~=hum then return end
      seat:Sit(hum)
      task.delay(.18,function()if p.Parent and hum.Parent and hum.SeatPart==seat then lookRemote:FireClient(p,"open",{station=tonumber(seat.Name:match("(%d+)$"))or 0,mall=true,prompt=true})end end)
     end)
    end
   end
  end
 end
 local function reconcile()for _,spec in ipairs(stores)do ensureBrowsePrompt(spec)end;fixLookLab()end
 mall.ChildAdded:Connect(function(ch)if ch.Name:match("^Tenant_")then task.delay(.25,reconcile)end end)
 mall.DescendantAdded:Connect(function(d)if d.Name:match("^LookLabSeat")or d.Name:match("^AutoStyleTrigger")then task.delay(.05,fixLookLab)end end)
 while mall.Parent do reconcile();task.wait(3)end
end)

print("[BBYA] Mall KPOP v5 online: 18 tracks / 4s AutoMix / watchdog / kiosk recovery / opt-in LookLab")
