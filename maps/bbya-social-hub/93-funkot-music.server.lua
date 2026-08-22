-- BBYA SOCIAL HUB — FUNKOT VENUE MUSIC ENGINE v2
-- Dedicated third venue channel: Main=Progressive, Underground=Indo, Funkot=Funkot.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("FunkotMusic")
if remote and not remote:IsA("RemoteEvent") then remote:Destroy();remote=nil end
if not remote then remote=Instance.new("RemoteEvent");remote.Name="FunkotMusic";remote.Parent=remotes end
local stateRemote=remotes:FindFirstChild("State")

local PLAYLIST={
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

local function inFunkot(player)
 local ch=player and player.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then return false end
 local p=hrp.Position
 return p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253
end
local function isAdmin(player)
 return player and (player:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId))
end
local function toast(player,msg)
 if stateRemote and stateRemote:IsA("RemoteEvent") then stateRemote:FireClient(player,"toast",msg) end
end

-- Let the architectural Funkot script create the group first, then take audio ownership.
local group
for _=1,80 do
 group=SoundService:FindFirstChild("BBYAFunkotMaster")
 if group and group:IsA("SoundGroup") then break end
 task.wait(.1)
end
if not group then
 group=Instance.new("SoundGroup");group.Name="BBYAFunkotMaster";group.Parent=SoundService
end
group.Volume=0
group:SetAttribute("Venue","FUNKOT")
group:SetAttribute("GenrePolicy","FUNKOT_ONLY")
group:SetAttribute("PlaylistCount",#PLAYLIST)
group:SetAttribute("AudioEngine","FUNKOT_VENUE_V2")

-- Remove the v1 standalone feed so only this engine owns playback.
for _,name in ipairs({"BBYAFunkotClubFeed","BBYAFunkotDeck"}) do
 local old=SoundService:FindFirstChild(name);if old then old:Destroy() end
end
local sound=Instance.new("Sound")
sound.Name="BBYAFunkotDeck";sound.SoundGroup=group;sound.Volume=1;sound.Looped=false;sound.Parent=SoundService

local current=0
local paused=false
local bad={}
local queue={}
local cooldown={}
local rng=Random.new(math.max(1,os.time()%2147483646))

local function valid(i)return PLAYLIST[i] and not bad[i] end
local function stateData()
 local t=PLAYLIST[current]
 return {venue="FUNKOT",genre="FUNKOT",index=current,title=t and t.title or "",style="funkot",playing=sound.IsPlaying and not paused,library=#PLAYLIST,queue=#queue,audioMode="FUNKOT_AUTODJ_V2"}
end
local function fireState(player)
 if player then remote:FireClient(player,"state",stateData());return end
 for _,p in ipairs(Players:GetPlayers()) do if inFunkot(p) then remote:FireClient(p,"state",stateData()) end end
end
local function chooseRandom()
 local candidates={}
 for i=1,#PLAYLIST do if valid(i) and i~=current then table.insert(candidates,i) end end
 if #candidates==0 then for i=1,#PLAYLIST do if valid(i) then table.insert(candidates,i) end end end
 if #candidates==0 then return nil end
 return candidates[rng:NextInteger(1,#candidates)]
end
local function playIndex(i)
 i=tonumber(i)
 if not i or not valid(i) then return false end
 local item=PLAYLIST[i]
 sound:Stop();sound.SoundId="rbxassetid://"..item.id;sound.TimePosition=0
 local ok=pcall(function()ContentProvider:PreloadAsync({sound})end)
 if not ok then bad[i]="preload_error";return false end
 sound:Play();task.wait(.3)
 if not sound.IsPlaying or (sound.TimeLength or 0)<=1 then
  sound:Stop();bad[i]="unavailable";group:SetAttribute("LastBadTrack",i);return false
 end
 current=i;paused=false;group:SetAttribute("CurrentAssetId",item.id);group:SetAttribute("CurrentTitle",item.title);fireState();return true
end
local function playNext()
 for _=1,#PLAYLIST do
  local i
  if #queue>0 then i=table.remove(queue,1).index else i=chooseRandom() end
  if not i then break end
  if playIndex(i) then return true end
 end
 warn("[BBYA/Funkot] no playable track available")
 fireState();return false
end

sound.Ended:Connect(function()task.defer(playNext)end)
remote.OnServerEvent:Connect(function(player,action,arg)
 if not inFunkot(player) and action~="state" then return end
 if action=="list" then remote:FireClient(player,"playlist",PLAYLIST);fireState(player)
 elseif action=="state" then fireState(player)
 elseif action=="request" then
  local i=tonumber(arg)
  if not i or not valid(i) then toast(player,"Track Funkot tidak tersedia.");return end
  local now=os.clock();if now-(cooldown[player.UserId] or 0)<12 then toast(player,"Tunggu sebentar sebelum request Funkot lagi.");return end
  cooldown[player.UserId]=now
  table.insert(queue,{index=i,userId=player.UserId});toast(player,string.format("Funkot queue #%d: %s",#queue,PLAYLIST[i].title));fireState(player)
 elseif action=="pause" and isAdmin(player) then paused=true;sound:Pause();fireState()
 elseif action=="resume" and isAdmin(player) then paused=false;sound:Resume();fireState()
 elseif action=="next" and isAdmin(player) then playNext()
 elseif action=="play" and isAdmin(player) then playIndex(tonumber(arg) or current)
 end
end)
Players.PlayerRemoving:Connect(function(p)cooldown[p.UserId]=nil end)

task.delay(3,function()if current==0 or not sound.IsPlaying then playNext() end end)
print(string.format("[BBYA] Funkot venue music v2 online: %d tracks / dedicated UI remote",#PLAYLIST))
