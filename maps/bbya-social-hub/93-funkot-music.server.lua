-- BBYA SOCIAL HUB — FUNKOT DISKOTIK RUNTIME AUDIO v6
-- Single runtime playback authority. Only verified LIVE + permissioned assets are exposed.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")

local PLAYLIST={
 {title="Zinyo Funkytone - Siapa Benar - Garam Cina 2025.mp3",id="128141893547516",style="funkot"},
 {title="Zinyo Funky Tone_ Hatiku Bagai Terpenjara 2025.mp3",id="98536948000407",style="funkot"},
}
if #PLAYLIST==0 then return end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("FunkotMusic")
if remote and not remote:IsA("RemoteEvent") then remote:Destroy();remote=nil end
if not remote then remote=Instance.new("RemoteEvent");remote.Name="FunkotMusic";remote.Parent=remotes end

local group=SoundService:FindFirstChild("BBYAFunkotMaster")
if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end
if not group then group=Instance.new("SoundGroup");group.Name="BBYAFunkotMaster";group.Parent=SoundService end
group.Volume=0
group:SetAttribute("Venue","FUNKOT")
group:SetAttribute("PlaylistReady",true)
group:SetAttribute("PlaylistCount",#PLAYLIST)
group:SetAttribute("AudioEngine","FUNKOT_RUNTIME_V6")
group:SetAttribute("AutoDJHealthy",true)

ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistEnabled",true)
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistId","funkot")
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistCount",#PLAYLIST)

for _,n in ipairs({"BBYAFunkotClubFeed","BBYAFunkotDeck","BBYAFunkotPlaylistV1","BBYAFunkotPlaylistV2","BBYAFunkotPlaylistV3","BBYAFunkotRuntimeV4","BBYAFunkotRuntimeV5","BBYAFunkotRuntimeV6"}) do
 local o=SoundService:FindFirstChild(n)
 if o and o:IsA("Sound") then pcall(function()o:Stop()end);o:Destroy() end
end

local sound=Instance.new("Sound")
sound.Name="BBYAFunkotRuntimeV6"
sound.SoundGroup=group
sound.Volume=.92
sound.Looped=false
sound.Parent=SoundService

local current=0
local paused=false
local busy=false
local selecting=false
local queue={}
local cooldown={}
local retryAfter={}
local health={}
local failCount={}
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

local function available(i)
 return PLAYLIST[i] and (not retryAfter[i] or os.clock()>=retryAfter[i])
end

local function state()
 local t=PLAYLIST[current]
 local unavailable=0
 for i=1,#PLAYLIST do if retryAfter[i] and os.clock()<retryAfter[i] then unavailable+=1 end end
 return {
  venue="FUNKOT",genre="FUNKOT",index=current,
  title=t and t.title or "Funkot AutoDJ",style="funkot",
  playing=sound.IsPlaying and not paused,library=#PLAYLIST,queue=#queue,
  unavailable=unavailable,audioMode="FUNKOT_RUNTIME_V6"
 }
end

local function fire(p)
 if p then remote:FireClient(p,"state",state());return end
 for _,pl in ipairs(Players:GetPlayers()) do if inZone(pl) then remote:FireClient(pl,"state",state()) end end
end

local function ack(p,msg)
 if p then remote:FireClient(p,"ack",msg) end
end

local function markFailure(i)
 failCount[i]=(failCount[i] or 0)+1
 health[i]=false
 local waitSeconds=math.min(120,20*(2^math.min(failCount[i]-1,2)))
 retryAfter[i]=os.clock()+waitSeconds
 local t=PLAYLIST[i]
 group:SetAttribute("LastUnavailableAssetId",t and t.id or "")
 group:SetAttribute("LastUnavailableTitle",t and t.title or "")
 group:SetAttribute("LastUnavailableRetrySeconds",waitSeconds)
end

local function markHealthy(i)
 failCount[i]=0
 health[i]=true
 retryAfter[i]=nil
end

local function play(i)
 i=tonumber(i)
 if not i or not PLAYLIST[i] or busy then return false end
 busy=true
 local t=PLAYLIST[i]
 paused=false
 pcall(function()sound:Stop()end)
 sound.SoundId="rbxassetid://"..t.id
 sound.TimePosition=0
 sound.Volume=.92

 local ok=pcall(function()sound:Play()end)
 local ready=false
 if ok then
  local deadline=os.clock()+4.5
  repeat
   if sound.IsPlaying and (sound.IsLoaded or (sound.TimeLength or 0)>1) then ready=true;break end
   task.wait(.15)
  until os.clock()>=deadline
 end

 if not ready then
  pcall(function()sound:Stop()end)
  markFailure(i)
  busy=false
  fire()
  return false
 end

 markHealthy(i)
 current=i
 group:SetAttribute("CurrentAssetId",t.id)
 group:SetAttribute("CurrentTitle",t.title)
 group:SetAttribute("CurrentTrackIndex",i)
 group:SetAttribute("LastSuccessfulAssetId",t.id)
 group:SetAttribute("LastSuccessfulTitle",t.title)
 ReplicatedStorage:SetAttribute("BBYAFunkotCurrentTitle",t.title)
 ReplicatedStorage:SetAttribute("BBYAFunkotCurrentAssetId",t.id)
 busy=false
 fire()
 return true
end

local function shuffled(indices)
 for i=#indices,2,-1 do
  local j=rng:NextInteger(1,i)
  indices[i],indices[j]=indices[j],indices[i]
 end
 return indices
end

local function candidateOrder()
 local good,unknown,recovered={},{},{}
 for i=1,#PLAYLIST do
  if i~=current and available(i) then
   if health[i]==true then table.insert(good,i)
   elseif health[i]==false then table.insert(recovered,i)
   else table.insert(unknown,i) end
  end
 end
 shuffled(good);shuffled(unknown);shuffled(recovered)
 for _,i in ipairs(unknown) do table.insert(good,i) end
 for _,i in ipairs(recovered) do table.insert(good,i) end
 if #good==0 and current>0 and available(current) then table.insert(good,current) end
 return good
end

local function nextTrack()
 if paused or busy or selecting then return end
 selecting=true
 while #queue>0 do
  local qv=table.remove(queue,1)
  if available(qv.index) and play(qv.index) then selecting=false;return end
 end
 local cand=candidateOrder()
 for _,i in ipairs(cand) do
  if play(i) then selecting=false;return end
 end
 selecting=false
 task.delay(2,nextTrack)
end

sound.Ended:Connect(function()task.defer(nextTrack)end)

remote.OnServerEvent:Connect(function(p,a,v)
 if a=="list" then remote:FireClient(p,"playlist",PLAYLIST);fire(p);return end
 if a=="state" then fire(p);return end
 if not inZone(p) then return end

 if a=="request" then
  local i=tonumber(v)
  if not i or not PLAYLIST[i] then return end
  local n=os.clock()
  if n-(cooldown[p.UserId] or 0)<3 then return end
  cooldown[p.UserId]=n
  if not available(i) then
   ack(p,"Track sementara belum tersedia. Coba lagi nanti.")
   return
  end
  if not sound.IsPlaying then
   if play(i) then
    ack(p,"Diputar: "..PLAYLIST[i].title)
   else
    ack(p,"Track belum bisa diputar. AutoDJ lanjut ke track lain.")
    task.defer(nextTrack)
   end
  else
   table.insert(queue,{index=i,userId=p.UserId})
   ack(p,"Request masuk: "..PLAYLIST[i].title)
   fire(p)
  end
 elseif admin(p) and a=="next" then
  pcall(function()sound:Stop()end)
  task.defer(nextTrack)
 elseif admin(p) and a=="play" then
  local i=tonumber(v) or current
  if not available(i) or not play(i) then task.defer(nextTrack) end
 elseif admin(p) and a=="pause" then
  paused=true;pcall(function()sound:Pause()end);fire()
 elseif admin(p) and a=="resume" then
  paused=false;pcall(function()sound:Resume()end)
  if not sound.IsPlaying then task.defer(nextTrack) end
  fire()
 end
end)

Players.PlayerRemoving:Connect(function(p)cooldown[p.UserId]=nil end)

task.delay(1.5,function()
 if not play(1) then task.defer(nextTrack) end
end)

task.spawn(function()
 while task.wait(2) do
  if not paused and not busy and not selecting and not sound.IsPlaying and sound.PlaybackState~=Enum.PlaybackState.Paused then
   task.defer(nextTrack)
  end
 end
end)

print("[BBYA] Funkot Diskotik runtime audio v6 online; verified live tracks",#PLAYLIST)
