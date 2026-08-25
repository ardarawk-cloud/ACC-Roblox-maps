-- BBYA SOCIAL HUB — FUNKOT DISKOTIK RUNTIME AUDIO v4
-- Single runtime playback authority. 121-funkot-playlist.server.lua is registry shim only.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local PLAYLIST={
 {title="Zinyo Funkytone - Siapa Benar - Garam Cina 2025.mp3",id="128141893547516",style="funkot"},
 {title="Zinyo Funky Tone_ Hatiku Bagai Terpenjara 2025.mp3",id="98536948000407",style="funkot"},
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
local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder");remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("FunkotMusic");if remote and not remote:IsA("RemoteEvent") then remote:Destroy();remote=nil end;if not remote then remote=Instance.new("RemoteEvent");remote.Name="FunkotMusic";remote.Parent=remotes end
local stateRemote=remotes:FindFirstChild("State")
local group=SoundService:FindFirstChild("BBYAFunkotMaster");if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end;if not group then group=Instance.new("SoundGroup");group.Name="BBYAFunkotMaster";group.Parent=SoundService end
group.Volume=0;group:SetAttribute("Venue","FUNKOT");group:SetAttribute("PlaylistReady",true);group:SetAttribute("PlaylistCount",#PLAYLIST);group:SetAttribute("AudioEngine","FUNKOT_RUNTIME_V4")
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistEnabled",true);ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistId","funkot");ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistCount",#PLAYLIST)
for _,n in ipairs({"BBYAFunkotClubFeed","BBYAFunkotDeck","BBYAFunkotPlaylistV1","BBYAFunkotPlaylistV2","BBYAFunkotPlaylistV3","BBYAFunkotRuntimeV4"}) do local o=SoundService:FindFirstChild(n);if o and o:IsA("Sound") then pcall(function()o:Stop()end);o:Destroy() end end
local sound=Instance.new("Sound");sound.Name="BBYAFunkotRuntimeV4";sound.SoundGroup=group;sound.Volume=.92;sound.Looped=false;sound.Parent=SoundService
local current=0;local paused=false;local busy=false;local queue={};local cooldown={};local retryAfter={};local rng=Random.new(math.max(1,os.time()%2147483646))
local function inZone(p)local c=p and p.Character;local h=c and c:FindFirstChild("HumanoidRootPart");if not h then return false end;local x=h.Position;return x.Y>-4 and x.Y<34 and math.abs(x.X)<61 and x.Z>157 and x.Z<253 end
local function admin(p)return p and (p:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId)) end
local function available(i)return PLAYLIST[i] and (not retryAfter[i] or os.clock()>=retryAfter[i]) end
local function state()local t=PLAYLIST[current];return {venue="FUNKOT",genre="FUNKOT",index=current,title=t and t.title or "Funkot AutoDJ",style="funkot",playing=sound.IsPlaying and not paused,library=#PLAYLIST,queue=#queue,audioMode="FUNKOT_RUNTIME_V4"} end
local function fire(p)if p then remote:FireClient(p,"state",state());return end;for _,pl in ipairs(Players:GetPlayers()) do if inZone(pl) then remote:FireClient(pl,"state",state()) end end end
local function toast(p,msg)if stateRemote and stateRemote:IsA("RemoteEvent") then stateRemote:FireClient(p,"toast",msg) end end
local function play(i)
 i=tonumber(i);if not i or not PLAYLIST[i] or busy then return false end
 busy=true;local t=PLAYLIST[i];paused=false
 pcall(function()sound:Stop()end);sound.SoundId="rbxassetid://"..t.id;sound.TimePosition=0;sound.Volume=.92
 local ok=pcall(function()sound:Play()end)
 if ok then local deadline=os.clock()+8;repeat if sound.IsPlaying then break end;task.wait(.2) until os.clock()>=deadline end
 if not ok or not sound.IsPlaying then retryAfter[i]=os.clock()+15;busy=false;return false end
 current=i;retryAfter[i]=nil;group:SetAttribute("CurrentAssetId",t.id);group:SetAttribute("CurrentTitle",t.title);group:SetAttribute("CurrentTrackIndex",i);ReplicatedStorage:SetAttribute("BBYAFunkotCurrentTitle",t.title);ReplicatedStorage:SetAttribute("BBYAFunkotCurrentAssetId",t.id);busy=false;fire();return true
end
local function nextTrack()
 if paused or busy then return end
 while #queue>0 do local qv=table.remove(queue,1);if play(qv.index) then return end end
 local cand={};for i=1,#PLAYLIST do if i~=current and available(i) then table.insert(cand,i) end end;if #cand==0 then for i=1,#PLAYLIST do if available(i) then table.insert(cand,i) end end end
 while #cand>0 do local k=rng:NextInteger(1,#cand);local i=table.remove(cand,k);if play(i) then return end end
 task.delay(5,nextTrack)
end
sound.Ended:Connect(function()task.defer(nextTrack)end)
remote.OnServerEvent:Connect(function(p,a,v)
 if a=="list" then remote:FireClient(p,"playlist",PLAYLIST);fire(p);return elseif a=="state" then fire(p);return end
 if not inZone(p) then return end
 if a=="request" then local i=tonumber(v);if not i or not PLAYLIST[i] then return end;local n=os.clock();if n-(cooldown[p.UserId] or 0)<3 then return end;cooldown[p.UserId]=n;if not sound.IsPlaying then if not play(i) then toast(p,"Track belum bisa diputar, AutoDJ lanjut ke track lain.");task.defer(nextTrack) end else table.insert(queue,{index=i,userId=p.UserId});toast(p,"Request masuk: "..PLAYLIST[i].title);fire(p) end
 elseif admin(p) and a=="next" then pcall(function()sound:Stop()end);task.defer(nextTrack)
 elseif admin(p) and a=="play" then if not play(tonumber(v) or current) then task.defer(nextTrack) end
 elseif admin(p) and a=="pause" then paused=true;pcall(function()sound:Pause()end);fire()
 elseif admin(p) and a=="resume" then paused=false;pcall(function()sound:Resume()end);if not sound.IsPlaying then task.defer(nextTrack) end;fire() end
end)
Players.PlayerRemoving:Connect(function(p)cooldown[p.UserId]=nil end)
task.delay(3,nextTrack)
task.spawn(function()while task.wait(5) do if not paused and not busy and not sound.IsPlaying and sound.PlaybackState~=Enum.PlaybackState.Paused then task.defer(nextTrack) end end end)
print("[BBYA] Funkot Diskotik runtime audio v4 online; tracks",#PLAYLIST)
