-- BBYA SOCIAL HUB — FUNKOT PLAYLIST AUTHORITY v3
-- Single playback authority for Funkot Diskotik.
-- Primary approved track stays first; legacy Funkot catalog is session-only fallback.
-- Failed assets are blacklisted for the current server session and are not retried.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")

local PLAYLIST={
 {title="Zinyo Funkytone - Siapa Benar - Garam Cina 2025.mp3",id="128141893547516",style="funkot",primary=true},
 {title="DJ Bahagiamu Sayang",id="110691393637838",style="funkot"},
 {title="DJ Mama Muda Enak Dong",id="134073539670673",style="funkot"},
 {title="Jamilah Itu Bukan Anunya Aisyah",id="116255319981650",style="funkot"},
 {title="Funkot Club Drive",id="124224888312006",style="funkot"},
 {title="Funkot Alt Drive",id="83125775305712",style="funkot"},
 {title="Funkot Melody Rhythm",id="95602240268105",style="funkot"},
 {title="DJ Funkot Karna Kamu Cantik",id="103451932037576",style="funkot"},
 {title="Funkot Aku Tak Berarti Bagimu",id="98095276635738",style="funkot"},
 {title="Funkot Ngamen 5",id="134100771661430",style="funkot"},
 {title="Funkot Garam Cina",id="79905157574964",style="funkot"},
 {title="DJ Funkot Ego Wong Tuo",id="78891075630689",style="funkot"},
}
if #PLAYLIST==0 then return end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("FunkotMusic")
if remote and not remote:IsA("RemoteEvent") then remote:Destroy();remote=nil end
if not remote then remote=Instance.new("RemoteEvent");remote.Name="FunkotMusic";remote.Parent=remotes end
local stateRemote=remotes:FindFirstChild("State")

-- Wait for the architectural builder to create the venue SoundGroup.
local group
for _=1,100 do
 group=SoundService:FindFirstChild("BBYAFunkotMaster")
 if group and group:IsA("SoundGroup") then break end
 task.wait(.1)
end
if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end
if not group then group=Instance.new("SoundGroup");group.Name="BBYAFunkotMaster";group.Parent=SoundService end

-- The client venue routers own local audibility. Start muted globally to avoid audio bleed.
group.Volume=0
group:SetAttribute("Venue","FUNKOT")
group:SetAttribute("GenrePolicy","FUNKOT_ONLY")
group:SetAttribute("BBYALocalZoneOnly",true)
group:SetAttribute("PlaylistReady",true)
group:SetAttribute("PlaylistCount",#PLAYLIST)
group:SetAttribute("MusicCatalogState","FUNKOT_ACTIVE")
group:SetAttribute("AudioEngine","FUNKOT_AUTHORITY_V3")
group:SetAttribute("PrimaryAssetId",PLAYLIST[1].id)
group:SetAttribute("SessionFallbackEnabled",true)

ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistId","funkot")
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistCount",#PLAYLIST)

-- One and only one Funkot playback deck.
for _,name in ipairs({"BBYAFunkotClubFeed","BBYAFunkotDeck","BBYAFunkotPlaylistV1","BBYAFunkotPlaylistV2","BBYAFunkotPlaylistV3"}) do
 local old=SoundService:FindFirstChild(name)
 if old and old:IsA("Sound") then
  pcall(function()old:Stop()end)
  old:Destroy()
 end
end
local sound=Instance.new("Sound")
sound.Name="BBYAFunkotPlaylistV3"
sound.SoundGroup=group
sound.Volume=.92
sound.Looped=false
sound.PlaybackSpeed=1
sound.Parent=SoundService
sound:SetAttribute("BBYAFunkotAuthority","V3")

local current=0
local paused=false
local transitioning=false
local bad={}
local queue={}
local cooldown={}
local rng=Random.new(math.max(1,os.time()%2147483646))

local function inZone(p)
 local c=p and p.Character
 local h=c and c:FindFirstChild("HumanoidRootPart")
 if not h then return false end
 local x=h.Position
 return x.Y>-4 and x.Y<34 and math.abs(x.X)<61 and x.Z>157 and x.Z<253
end
local function admin(p)
 return p and (p:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId))
end
local function valid(i)
 return PLAYLIST[i] and not bad[i]
end
local function state()
 local t=PLAYLIST[current]
 return {
  venue="FUNKOT",genre="FUNKOT",index=current,title=t and t.title or "Funkot AutoDJ",
  style="funkot",playing=sound.IsPlaying and not paused,library=#PLAYLIST,queue=#queue,
  audioMode="FUNKOT_AUTHORITY_V3",primaryAssetId=PLAYLIST[1].id
 }
end
local function fire(p)
 if p then remote:FireClient(p,"state",state());return end
 for _,pl in ipairs(Players:GetPlayers()) do if inZone(pl) then remote:FireClient(pl,"state",state()) end end
end
local function toast(p,msg)
 if stateRemote and stateRemote:IsA("RemoteEvent") then stateRemote:FireClient(p,"toast",msg) end
end

local function markBad(i,reason)
 local t=PLAYLIST[i]
 bad[i]=reason or "unavailable"
 group:SetAttribute("LastBadTrack",i)
 group:SetAttribute("LastBadAssetId",t and t.id or "")
 group:SetAttribute("LastBadReason",bad[i])
 warn(string.format("[BBYA/Funkot v3] session blacklist track %s asset %s (%s)",t and t.title or tostring(i),t and t.id or "?",bad[i]))
end

local function waitLoaded(timeout)
 local deadline=os.clock()+(timeout or 6)
 repeat
  if sound.IsLoaded and (sound.TimeLength or 0)>1 then return true end
  task.wait(.2)
 until os.clock()>=deadline
 return sound.IsLoaded and (sound.TimeLength or 0)>1
end

local function playIndex(i)
 i=tonumber(i)
 if not i or not valid(i) or transitioning then return false end
 transitioning=true
 local t=PLAYLIST[i]
 paused=false
 pcall(function()sound:Stop()end)
 sound.PlaybackSpeed=1
 sound.Volume=.92
 sound.SoundId="rbxassetid://"..t.id
 sound.TimePosition=0
 sound:SetAttribute("BBYAFunkotTrackIndex",i)
 sound:SetAttribute("BBYAFunkotAssetId",t.id)

 -- Preload is best-effort; final authority is IsLoaded + actual playback.
 local preloadOk=pcall(function()ContentProvider:PreloadAsync({sound})end)
 if not preloadOk then
  markBad(i,"preload_error")
  transitioning=false
  return false
 end
 if not waitLoaded(6) then
  markBad(i,"not_loaded")
  transitioning=false
  return false
 end

 local ok=pcall(function()sound:Play()end)
 if not ok then
  markBad(i,"play_error")
  transitioning=false
  return false
 end
 local deadline=os.clock()+2.5
 repeat
  if sound.IsPlaying and sound.PlaybackState==Enum.PlaybackState.Playing then break end
  task.wait(.15)
 until os.clock()>=deadline
 if not sound.IsPlaying then
  pcall(function()sound:Stop()end)
  markBad(i,"not_playing")
  transitioning=false
  return false
 end

 current=i
 group:SetAttribute("CurrentAssetId",t.id)
 group:SetAttribute("CurrentTitle",t.title)
 group:SetAttribute("CurrentTrackIndex",i)
 group:SetAttribute("CurrentTrackIsPrimary",t.primary==true)
 group:SetAttribute("LastPlaybackStartedAt",os.time())
 ReplicatedStorage:SetAttribute("BBYAFunkotCurrentTitle",t.title)
 ReplicatedStorage:SetAttribute("BBYAFunkotCurrentAssetId",t.id)
 transitioning=false
 fire()
 print(string.format("[BBYA/Funkot v3] PLAYING #%d %s (%s)%s",i,t.title,t.id,t.primary and " [PRIMARY]" or " [FALLBACK]"))
 return true
end

local function candidateOrder(startAt)
 local out={}
 local seen={}
 local function add(i)
  if i>=1 and i<=#PLAYLIST and valid(i) and not seen[i] then seen[i]=true;table.insert(out,i) end
 end
 if startAt then add(startAt) end
 -- Primary is always preferred on a fresh server unless it already failed this session.
 add(1)
 -- Queue/request candidates are handled before this function; remaining fallbacks are randomized.
 local fallback={}
 for i=2,#PLAYLIST do if valid(i) and not seen[i] then table.insert(fallback,i) end end
 while #fallback>0 do
  local k=rng:NextInteger(1,#fallback)
  add(table.remove(fallback,k))
 end
 return out
end

local function playAvailable(startAt)
 if transitioning then return false end
 for _,i in ipairs(candidateOrder(startAt)) do
  if playIndex(i) then return true end
 end
 warn("[BBYA/Funkot v3] no playable Funkot asset remains in this server session")
 group:SetAttribute("AudioState","NO_PLAYABLE_TRACK")
 fire()
 return false
end

local function nextTrack()
 if paused or transitioning then return end
 while #queue>0 do
  local q=table.remove(queue,1)
  if valid(q.index) and playIndex(q.index) then return end
 end
 local start=(current>0 and (current%#PLAYLIST)+1) or 1
 playAvailable(start)
end

sound.Ended:Connect(function()task.defer(nextTrack)end)
remote.OnServerEvent:Connect(function(p,a,v)
 if a=="list" then remote:FireClient(p,"playlist",PLAYLIST);fire(p);return end
 if a=="state" then fire(p);return end
 if not inZone(p) then return end
 if a=="request" then
  local i=tonumber(v)
  if not i or not valid(i) then toast(p,"Track Funkot tidak tersedia di session ini.");return end
  local n=os.clock()
  if n-(cooldown[p.UserId] or 0)<12 then toast(p,"Tunggu sebentar sebelum request Funkot lagi.");return end
  cooldown[p.UserId]=n
  table.insert(queue,{index=i,userId=p.UserId})
  toast(p,string.format("Funkot queue #%d: %s",#queue,PLAYLIST[i].title))
  fire(p)
 elseif admin(p) and a=="next" then
  nextTrack()
 elseif admin(p) and a=="play" then
  local i=tonumber(v) or current
  if not playIndex(i) then playAvailable() end
 elseif admin(p) and a=="pause" then
  paused=true;pcall(function()sound:Pause()end);fire()
 elseif admin(p) and a=="resume" then
  paused=false
  if sound.PlaybackState==Enum.PlaybackState.Paused then pcall(function()sound:Resume()end) end
  if not sound.IsPlaying then task.defer(function()playAvailable(current>0 and current or 1)end) end
  fire()
 end
end)
Players.PlayerRemoving:Connect(function(p)cooldown[p.UserId]=nil end)

-- Startup: let every older mapped Funkot script finish, then become sole playback owner.
task.delay(4,function()
 -- Re-delete legacy decks in case an older script initialized late.
 for _,name in ipairs({"BBYAFunkotClubFeed","BBYAFunkotDeck","BBYAFunkotPlaylistV1","BBYAFunkotPlaylistV2"}) do
  local old=SoundService:FindFirstChild(name)
  if old and old:IsA("Sound") then pcall(function()old:Stop()end);old:Destroy() end
 end
 if not sound.IsPlaying then playAvailable(1) end
end)

-- Self-heal only for this Funkot authority. Never retries assets already session-blacklisted.
task.spawn(function()
 while task.wait(3) do
  if not paused and not transitioning then
   if sound.Parent~=SoundService then
    warn("[BBYA/Funkot v3] authority deck was removed; cannot self-heal without respawn")
    break
   end
   if current>0 and sound.IsPlaying and sound.PlaybackSpeed~=1 then sound.PlaybackSpeed=1 end
   if current>0 and sound.IsPlaying and sound.Volume<.5 then sound.Volume=.92 end
   if not sound.IsPlaying and sound.PlaybackState~=Enum.PlaybackState.Paused then
    task.defer(nextTrack)
   end
  end
 end
end)

print(string.format("[BBYA] Funkot playlist authority v3 online: 1 primary + %d session fallbacks / legacy engine suppressed",#PLAYLIST-1))
