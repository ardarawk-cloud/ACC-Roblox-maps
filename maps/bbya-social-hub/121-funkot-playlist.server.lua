-- BBYA SOCIAL HUB — FUNKOT PLAYLIST AUTHORITY v2
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")
local PLAYLIST={
 {title="Zinyo Funkytone - Siapa Benar - Garam Cina 2025.mp3",id="128141893547516",style="funkot"}
}
if #PLAYLIST==0 then return end
local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder");remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("FunkotMusic");if remote and not remote:IsA("RemoteEvent") then remote:Destroy();remote=nil end;if not remote then remote=Instance.new("RemoteEvent");remote.Name="FunkotMusic";remote.Parent=remotes end
local group=SoundService:FindFirstChild("BBYAFunkotMaster");if group and not group:IsA("SoundGroup") then group:Destroy();group=nil end;if not group then group=Instance.new("SoundGroup");group.Name="BBYAFunkotMaster";group.Parent=SoundService end
group.Volume=.62;group:SetAttribute("Venue","FUNKOT");group:SetAttribute("GenrePolicy","FUNKOT_ONLY");group:SetAttribute("BBYALocalZoneOnly",true);group:SetAttribute("PlaylistReady",true);group:SetAttribute("PlaylistCount",#PLAYLIST);group:SetAttribute("MusicCatalogState","FUNKOT_ACTIVE")
ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistEnabled",true);ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistId","funkot");ReplicatedStorage:SetAttribute("BBYAFunkotPlaylistCount",#PLAYLIST)
for _,n in ipairs({"BBYAFunkotClubFeed","BBYAFunkotDeck","BBYAFunkotPlaylistV1"}) do local o=SoundService:FindFirstChild(n);if o then pcall(function()o:Stop();o:Destroy()end) end end
local sound=Instance.new("Sound");sound.Name="BBYAFunkotPlaylistV2";sound.SoundGroup=group;sound.Volume=.78;sound.Looped=false;sound.Parent=SoundService
local current=0;local paused=false;local bad={};local queue={};local cooldown={};local rng=Random.new(math.max(1,os.time()%2147483646))
local function inZone(p)local c=p and p.Character;local h=c and c:FindFirstChild("HumanoidRootPart");if not h then return false end;local x=h.Position;return x.Y>-4 and x.Y<34 and math.abs(x.X)<61 and x.Z>157 and x.Z<253 end
local function admin(p)return p and (p:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId)) end
local function state()local t=PLAYLIST[current];return {venue="FUNKOT",genre="FUNKOT",index=current,title=t and t.title or "",style="funkot",playing=sound.IsPlaying and not paused,library=#PLAYLIST,queue=#queue,audioMode="FUNKOT_APPROVED_V2"} end
local function fire(p)if p then remote:FireClient(p,"state",state());return end;for _,pl in ipairs(Players:GetPlayers()) do if inZone(pl) then remote:FireClient(pl,"state",state()) end end end
local function valid(i)return PLAYLIST[i] and not bad[i] end
local function play(i)i=tonumber(i);if not i or not valid(i) then return false end;local t=PLAYLIST[i];sound:Stop();sound.SoundId="rbxassetid://"..t.id;sound.TimePosition=0;local ok=pcall(function()ContentProvider:PreloadAsync({sound})end);if not ok then bad[i]=true;return false end;sound:Play();task.wait(.3);if not sound.IsPlaying or (sound.TimeLength or 0)<=1 then sound:Stop();bad[i]=true;return false end;current=i;paused=false;group:SetAttribute("CurrentAssetId",t.id);group:SetAttribute("CurrentTitle",t.title);ReplicatedStorage:SetAttribute("BBYAFunkotCurrentTitle",t.title);ReplicatedStorage:SetAttribute("BBYAFunkotCurrentAssetId",t.id);fire();return true end
local function nextTrack()local cand={};for i=1,#PLAYLIST do if valid(i) and i~=current then table.insert(cand,i) end end;if #cand==0 then for i=1,#PLAYLIST do if valid(i) then table.insert(cand,i) end end end;if #queue>0 then local qv=table.remove(queue,1);if play(qv.index) then return end end;while #cand>0 do local k=rng:NextInteger(1,#cand);local i=table.remove(cand,k);if play(i) then return end end end
sound.Ended:Connect(function()task.defer(nextTrack)end)
remote.OnServerEvent:Connect(function(p,a,v)if a=="list" then remote:FireClient(p,"playlist",PLAYLIST);fire(p);return elseif a=="state" then fire(p);return end;if not inZone(p) then return end;if a=="request" then local i=tonumber(v);if not i or not valid(i) then return end;local n=os.clock();if n-(cooldown[p.UserId] or 0)<12 then return end;cooldown[p.UserId]=n;table.insert(queue,{index=i,userId=p.UserId});fire(p) elseif admin(p) and a=="next" then nextTrack() elseif admin(p) and a=="play" then play(tonumber(v) or current) end end)
Players.PlayerRemoving:Connect(function(p)cooldown[p.UserId]=nil end)
task.delay(2,nextTrack)
print("[BBYA] Funkot approved playlist authority v2 online; tracks",#PLAYLIST)
