-- BBYA SOCIAL HUB — MALL KPOP MUSIC AUTHORITY v4 RELIABILITY
-- Preserves the locked 18-track KPOP bank. Adds progress-aware autoplay recovery.
-- Mall-only runtime guards also restore missing tenant browse prompts and make LookLab seating opt-in.

local SoundService=game:GetService("SoundService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")

local PLAYBACK_SPEED=0.5714285714
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
group:SetAttribute("MusicCatalogState","MALL_KPOP_RELIABLE_V4")
group:SetAttribute("AutoPlay",true)
group:SetAttribute("ShuffleMode","RANDOM_NO_REPEAT_CYCLE")
group:SetAttribute("HealthMode","PROGRESS_WATCHDOG_V4")

local sound=SoundService:FindFirstChild("BBYAMallMasterSound")
if sound and not sound:IsA("Sound")then sound:Destroy();sound=nil end
if not sound then sound=Instance.new("Sound");sound.Name="BBYAMallMasterSound";sound.Parent=SoundService end
sound.SoundGroup=group
sound.Volume=.78
sound.Looped=false
sound.PlaybackSpeed=PLAYBACK_SPEED
sound:SetAttribute("Venue","MALL")
sound:SetAttribute("Bank","KPOP")
sound:SetAttribute("Authority","MALL_KPOP_RELIABLE_V4")

local function publishCatalog()
 local folder=ReplicatedStorage:FindFirstChild("BBYAMallPlaylistCatalog")
 if folder and not folder:IsA("Folder")then folder:Destroy();folder=nil end
 if not folder then folder=Instance.new("Folder");folder.Name="BBYAMallPlaylistCatalog";folder.Parent=ReplicatedStorage end
 folder:ClearAllChildren()
 folder:SetAttribute("PlaylistId","mall-kpop-random")
 folder:SetAttribute("Venue","MALL")
 folder:SetAttribute("Bank","KPOP")
 folder:SetAttribute("Count",#PLAYLIST)
 folder:SetAttribute("ControlRemote","BBYAMallMusicControl")
 folder:SetAttribute("OutputSound","BBYAMallMasterSound")
 folder:SetAttribute("SoundGroup","BBYAMallMaster")
 folder:SetAttribute("PlaybackSpeed",PLAYBACK_SPEED)
 folder:SetAttribute("AutoPlay",true)
 folder:SetAttribute("ShuffleMode","RANDOM_NO_REPEAT_CYCLE")
 folder:SetAttribute("Authority","MALL_KPOP_RELIABLE_V4")
 for i,t in ipairs(PLAYLIST)do
  local row=Instance.new("StringValue");row.Name=string.format("Track%02d",i);row.Value=t.title
  row:SetAttribute("Index",i);row:SetAttribute("AssetId",t.assetId);row:SetAttribute("Artist","KPOP");row:SetAttribute("PlaybackSpeed",PLAYBACK_SPEED);row.Parent=folder
 end
end
publishCatalog()

local current=math.random(1,#PLAYLIST)
local bag={}
local queue={}
local cooldown={}
local badUntil={}
local switching=false
local generation=0
local startedAt=0
local lastProgressAt=0
local lastPosition=0

local function shuffle(t)
 for i=#t,2,-1 do local j=math.random(1,i);t[i],t[j]=t[j],t[i]end
end
local function healthy(i)return (badUntil[i] or 0)<=os.clock() end
local function refill()
 bag={}
 for i=1,#PLAYLIST do if i~=current and healthy(i)then table.insert(bag,i)end end
 if #bag==0 then table.clear(badUntil);for i=1,#PLAYLIST do if i~=current then table.insert(bag,i)end end end
 shuffle(bag)
end
local function nextIndex()
 while #queue>0 do local n=table.remove(queue,1);if PLAYLIST[n] and healthy(n)then return n end end
 if #bag==0 then refill()end
 local n=table.remove(bag,1)
 if not n or n==current then refill();n=table.remove(bag,1)end
 return n or(current%#PLAYLIST+1)
end
local function publishState()
 local t=PLAYLIST[current]
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistEnabled",true)
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistId","mall-kpop-random")
 ReplicatedStorage:SetAttribute("BBYAMallPlaylistCount",#PLAYLIST)
 ReplicatedStorage:SetAttribute("BBYAMallCurrentIndex",current)
 ReplicatedStorage:SetAttribute("BBYAMallCurrentTitle",t.title)
 ReplicatedStorage:SetAttribute("BBYAMallCurrentAssetId",t.assetId)
 ReplicatedStorage:SetAttribute("BBYAMallPlaybackSpeed",PLAYBACK_SPEED)
 ReplicatedStorage:SetAttribute("BBYAMallQueueCount",#queue)
 ReplicatedStorage:SetAttribute("BBYAMallNextRequestIndex",tonumber(queue[1])or 0)
 group:SetAttribute("CurrentIndex",current);group:SetAttribute("CurrentTitle",t.title);group:SetAttribute("CurrentAssetId",t.assetId);group:SetAttribute("QueueCount",#queue)
 sound:SetAttribute("Title",t.title);sound:SetAttribute("PlaylistIndex",current)
end

local start
local function quarantine(reason)
 badUntil[current]=os.clock()+30
 group:SetAttribute("LastHealthFailure",tostring(reason or "unknown"))
 group:SetAttribute("LastHealthFailureIndex",current)
end
local function transition(reason)
 if switching then return end
 group:SetAttribute("LastTransitionReason",tostring(reason or "next"))
 task.defer(function()start(nextIndex(),reason)end)
end
start=function(wanted,reason)
 if switching then return end
 switching=true
 generation=generation+1
 local token=generation
 current=((tonumber(wanted)or 1)-1)%#PLAYLIST+1
 local t=PLAYLIST[current]
 sound:Stop()
 sound.SoundId="rbxassetid://"..t.assetId
 sound.PlaybackSpeed=PLAYBACK_SPEED
 sound.TimePosition=0
 publishState()
 startedAt=os.clock();lastProgressAt=startedAt;lastPosition=0
 local ok=pcall(function()sound:Play()end)
 group:SetAttribute("LastStartOk",ok)
 group:SetAttribute("LastStartTitle",t.title)
 group:SetAttribute("LastTransitionReason",tostring(reason or "startup"))
 switching=false
 task.delay(8,function()
  if token~=generation or switching then return end
  if not sound.IsPlaying or sound.TimePosition<.12 then quarantine("load-or-progress-timeout");transition("load-timeout")end
 end)
 print("[BBYA] Mall KPOP v4 start",current,t.title,t.assetId,reason or "startup")
end

sound.Ended:Connect(function()transition("ended")end)

local function inZone(p)
 local c=p and p.Character;local h=c and c:FindFirstChild("HumanoidRootPart");if not h then return false end
 local x=h.Position;return x.X>=-108 and x.X<=108 and x.Y>=-6 and x.Y<=88 and x.Z>=248 and x.Z<=455
end
local function admin(p)return p and(p:GetAttribute("BBYAAdmin")==true or p:GetAttribute("BBYAOwner")==true or(game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId))end
control.OnServerEvent:Connect(function(p,action,wanted)
 action=tostring(action or"")
 if action=="request"then
  if not inZone(p)then return end
  local n=tonumber(wanted);if not n or not PLAYLIST[n]then return end
  local now=os.clock();if now-(cooldown[p.UserId]or 0)<3 then return end
  cooldown[p.UserId]=now;table.insert(queue,n);publishState();if not sound.IsPlaying then transition("request-recovery")end;return
 end
 if not admin(p)then return end
 if action=="next"then transition("admin-next")
 elseif action=="play"then local n=tonumber(wanted);if n and PLAYLIST[n]then task.defer(function()start(n,"admin-play")end)end
 elseif action=="clearqueue"then table.clear(queue);publishState()end
end)
Players.PlayerRemoving:Connect(function(p)cooldown[p.UserId]=nil end)

refill();start(current,"startup-random")
task.spawn(function()
 while task.wait(.75)do
  group.Volume=.86;sound.Volume=.78;sound.PlaybackSpeed=PLAYBACK_SPEED;group:SetAttribute("PlaylistReady",true);group:SetAttribute("PlaylistCount",#PLAYLIST);publishState()
  if not switching then
   local now=os.clock()
   if sound.IsPlaying then
    local pos=sound.TimePosition
    if pos>lastPosition+.03 then lastPosition=pos;lastProgressAt=now
    elseif now-startedAt>8 and now-lastProgressAt>8 then quarantine("stalled-timeposition");transition("stalled")end
   elseif now-startedAt>2.5 then quarantine("unexpected-stop");transition("watchdog-stop")end
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
 local function reconcile()
  for _,spec in ipairs(stores)do ensureBrowsePrompt(spec)end
  fixLookLab()
 end
 mall.ChildAdded:Connect(function(ch)if ch.Name:match("^Tenant_")then task.delay(.25,reconcile)end end)
 mall.DescendantAdded:Connect(function(d)if d.Name:match("^LookLabSeat")or d.Name:match("^AutoStyleTrigger")then task.delay(.05,fixLookLab)end end)
 while mall.Parent do reconcile();task.wait(3)end
end)

print("[BBYA] Mall KPOP v4 online: 18 tracks + progress watchdog + kiosk recovery + opt-in LookLab seating")
