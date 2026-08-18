-- BBYA MASTER MUSIC VAULT + HYBRID AUTO-DJ v1.2
-- Empty server = music off. First player joins = Auto-DJ starts.
-- A player physically at the DJ booth may manually control music; trusted roles can control anywhere.

local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local remotes=ReplicatedStorage:FindFirstChild("BBYA_Remotes") or Instance.new("Folder")
remotes.Name="BBYA_Remotes";remotes.Parent=ReplicatedStorage
local MusicRemote=remotes:FindFirstChild("MusicControl") or Instance.new("RemoteEvent")
MusicRemote.Name="MusicControl";MusicRemote.Parent=remotes
local MusicState=remotes:FindFirstChild("MusicState") or Instance.new("RemoteEvent")
MusicState.Name="MusicState";MusicState.Parent=remotes

local QUEEN_ID=4271188557
local manualDJUserId=nil

local function trustedRole(p)
 if not p then return false end
 if p.UserId==QUEEN_ID then return true end
 local r=string.upper(tostring(p:GetAttribute("BBYARole") or ""))
 return r=="DJ" or r=="ADMIN" or r=="ACC_MASTER_OWNER"
end

local function findDJAnchor()
 return workspace:FindFirstChild("DJ Console",true)
  or workspace:FindFirstChild("DJ Booth",true)
  or workspace:FindFirstChild("Pool DJ Deck",true)
end

local function atDJBooth(p)
 local root=p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 local anchor=findDJAnchor()
 if not root or not anchor or not anchor:IsA("BasePart") then return false end
 return (root.Position-anchor.Position).Magnitude<=18
end

local function canControl(p)
 return trustedRole(p) or atDJBooth(p)
end

local VAULT={
 {id=85427648559465,title="DJ Phut Hon Indo Full Bass",genre="INDO",sub="BREAKBEAT",status="VERIFIED",rating=5},
 {id=100787734732008,title="Aku Suka Jedag Jedug Full Bass",genre="INDO",sub="BREAKBEAT",status="VERIFIED",rating=5},
 {id=103491797412309,title="Pyro Pulse",genre="INDO",sub="BREAKBEAT",status="TEST",rating=4},
 {id=110691393637838,title="DJ Bahagiamu Sayang Funkot",genre="INDO",sub="FUNKOT",status="VERIFIED",rating=5},
 {id=101399039672234,title="DNA INDO BOUNCE",genre="INDO",sub="INDO_BOUNCE",status="VERIFIED",rating=5},
 {id=128622207855102,title="DJ Breakbeat Stadium Jakarta",genre="INDO",sub="STADIUM",status="VERIFIED",rating=5},
 {id=133512901677493,title="Rindu Aku Rindu Kamu",genre="INDO",sub="BREAKBEAT",status="TEST",rating=4},
 {id=84377101694514,title="Remon x Asik Sekali",genre="INDO",sub="BREAKBEAT",status="TEST",rating=4},
 {id=105003998270064,title="Dora Dora",genre="INDO",sub="BREAKBEAT",status="TEST",rating=4},
 {id=111053774716038,title="Sama Sama Suka",genre="INDO",sub="FUNKOT",status="TEST",rating=4},
 {id=103451932037576,title="Karna Kamu Cantik",genre="INDO",sub="FUNKOT",status="TEST",rating=4},
 {id=139850430998864,title="Jangan Pergi",genre="INDO",sub="FUNKOT",status="TEST",rating=4},
 {id=101860743794506,title="ABG Tua",genre="INDO",sub="FUNKOT",status="TEST",rating=4},
 {id=134100771661430,title="Ngamen 5",genre="INDO",sub="FUNKOT",status="TEST",rating=4},
 {id=85229747030713,title="DJ Dumes Remix Koplo",genre="INDO",sub="KOPLO",status="VERIFIED",rating=4},
 {id=87585997282125,title="Koplo Persatuan Kampungku",genre="INDO",sub="KOPLO",status="VERIFIED",rating=4},
 {id=9040442826,title="Pumpin' And Bumpin' D",genre="INTL",sub="BASS_HOUSE",status="VERIFIED",rating=4},
 {id=9045072146,title="Struck Down D",genre="INTL",sub="PSYTRANCE",status="VERIFIED",rating=4},
 {id=1839246840,title="Fast Rave",genre="INTL",sub="TECHNO",status="TEST",rating=4},
 {id=9047436030,title="Ipanema House Beach",genre="INTL",sub="TROPICAL_HOUSE",status="VERIFIED",rating=3},
 {id=7023598688,title="Bad Computer - Clarity",genre="INTL",sub="HOUSE",status="TEST",rating=4},
 {id=7023749823,title="Eskai - Mimi",genre="INTL",sub="PROGRESSIVE_HOUSE",status="TEST",rating=4},
 {id=5410085763,title="Tokyo Machine - PLAY",genre="INTL",sub="ELECTRO_HOUSE",status="TEST",rating=5},
 {id=5409360995,title="Dion Timmer - Shiawase",genre="INTL",sub="ELECTRONIC",status="TEST",rating=4},
 {id=7028977687,title="Stonebank - What Are You Waiting For",genre="INTL",sub="EDM",status="TEST",rating=5},
 {id=9042927806,title="We Want Disco",genre="INTL",sub="DISCO",status="VERIFIED",rating=3},
 {id=133054925243074,title="Time Chasing",genre="INTL",sub="DNB",status="TEST",rating=4},
 {id=134324160901088,title="Fast Drum & Bass Action Soundtrack",genre="INTL",sub="DNB",status="TEST",rating=4},
}

local FLOWS={
 INDONESIA={"INDO_BOUNCE","STADIUM","BREAKBEAT","FUNKOT","KOPLO","FULL_BASS"},
 INTERNATIONAL={"TROPICAL_HOUSE","HOUSE","PROGRESSIVE_HOUSE","BASS_HOUSE","EDM","TECHNO","PSYTRANCE","DNB","DISCO"},
 ALL={}
}

local sound=SoundService:FindFirstChild("BBYA_MainMusic") or Instance.new("Sound")
sound.Name="BBYA_MainMusic";sound.Volume=.65;sound.Looped=false;sound.PlaybackSpeed=1;sound.Parent=SoundService

local activeMode="ALL"
local queue={}
local cursor=0
local current=nil
local sessionBad={}
local lastAction={}
local token=0

local function occupied() return #Players:GetPlayers()>0 end
local function usable(t)return t.status~="DEAD" and not sessionBad[t.id] end

local function rebuild(mode)
 activeMode=mode or activeMode;queue={}
 local wanted=FLOWS[activeMode]
 if activeMode=="ALL" then
  for _,status in ipairs({"VERIFIED","TEST"}) do for _,t in ipairs(VAULT)do if usable(t) and t.status==status then table.insert(queue,t)end end end
 else
  for _,sub in ipairs(wanted or {})do for _,status in ipairs({"VERIFIED","TEST"}) do for _,t in ipairs(VAULT)do if usable(t) and t.sub==sub and t.status==status then table.insert(queue,t)end end end end
 end
 cursor=0
end

local function publish(err)
 local djName="AUTO-DJ"
 if manualDJUserId then local p=Players:GetPlayerByUserId(manualDJUserId);djName=p and p.DisplayName or "AUTO-DJ" end
 workspace:SetAttribute("BBYANowPlaying",current and current.title or "BBYA 24/7")
 workspace:SetAttribute("BBYAMusicMode",activeMode)
 workspace:SetAttribute("BBYAMusicSubgenre",current and current.sub or "")
 workspace:SetAttribute("BBYAMusicStatus",current and current.status or "")
 workspace:SetAttribute("BBYAMusicError",err or "")
 workspace:SetAttribute("BBYACurrentDJ",djName)
 MusicState:FireAllClients({title=current and current.title or "BBYA 24/7",genre=current and current.genre or "",sub=current and current.sub or "",status=current and current.status or "",mode=activeMode,volume=sound.Volume,playing=sound.Playing,error=err or "",dj=djName,manualDJ=manualDJUserId~=nil})
end

local nextTrack
local function tryTrack(t)
 if not occupied() then return end
 token+=1;local myToken=token;current=t
 sound:Stop();sound.SoundId="rbxassetid://"..tostring(t.id);sound.TimePosition=0;sound:Play();publish("")
 task.delay(5,function()
  if myToken~=token or current~=t or not occupied() then return end
  local ok=sound.IsLoaded and sound.TimeLength>0 and (sound.Playing or sound.TimePosition>0)
  if not ok then sessionBad[t.id]=true;sound:Stop();current=nil;publish("SKIPPING UNAVAILABLE AUDIO");task.delay(.15,function()if myToken==token and occupied() then nextTrack()end end)end
 end)
end

nextTrack=function()
 if not occupied() then sound:Stop();current=nil;publish("WAITING FOR PLAYERS");return end
 if #queue==0 then rebuild(activeMode) end
 if #queue==0 then current=nil;publish("NO PLAYABLE AUDIO - CHECK ROBLOX AUDIO PERMISSIONS");return end
 local attempts=0
 repeat attempts+=1;cursor=cursor%#queue+1;local t=queue[cursor];if usable(t) then tryTrack(t);return end until attempts>=#queue
 rebuild(activeMode)
 if #queue==0 then current=nil;publish("NO PLAYABLE AUDIO - CHECK ROBLOX AUDIO PERMISSIONS");return end
 cursor=1;tryTrack(queue[1])
end

sound.Ended:Connect(function()if occupied() then task.delay(.15,nextTrack)end end)
local function rate(p,key,sec)local k=tostring(p.UserId)..":"..key;local n=os.clock();if lastAction[k] and n-lastAction[k]<sec then return false end;lastAction[k]=n;return true end

MusicRemote.OnServerEvent:Connect(function(p,action,value)
 if not canControl(p) or not rate(p,"music",.2) then return end
 action=string.upper(tostring(action or ""))
 manualDJUserId=p.UserId
 if action=="NEXT" then token+=1;nextTrack()
 elseif action=="PAUSE" then sound:Pause();publish("")
 elseif action=="PLAY" then if sound.SoundId=="" or current==nil then nextTrack() else sound:Resume();publish("") end
 elseif action=="VOLUME" then sound.Volume=math.clamp(tonumber(value) or .65,0,1);publish("")
 elseif action=="MODE" then local m=string.upper(tostring(value or "ALL"));if FLOWS[m]then token+=1;sessionBad={};rebuild(m);nextTrack()end
 elseif action=="SUBGENRE" then local sub=string.upper(tostring(value or ""));token+=1;queue={};for _,t in ipairs(VAULT)do if t.status~="DEAD" and t.sub==sub then table.insert(queue,t)end end;cursor=0;if #queue>0 then activeMode=sub;nextTrack()end end
end)

Players.PlayerAdded:Connect(function()
 task.delay(1,function()
  if occupied() and not sound.Playing and current==nil then manualDJUserId=nil;rebuild(activeMode);nextTrack()end
 end)
end)

Players.PlayerRemoving:Connect(function(p)
 if manualDJUserId==p.UserId then manualDJUserId=nil end
 task.defer(function()
  if #Players:GetPlayers()<=1 then token+=1;sound:Stop();current=nil;publish("WAITING FOR PLAYERS")
  elseif not sound.Playing and manualDJUserId==nil then task.delay(.5,nextTrack) end
 end)
end)

-- If script boots while somebody is already in the server, start immediately. Otherwise stay silent.
rebuild("ALL")
if occupied() then task.delay(1,nextTrack) else sound:Stop();publish("WAITING FOR PLAYERS") end
print("[BBYA MUSIC] Hybrid Auto-DJ v1.2 loaded:",#VAULT,"tracks; empty server silent, first player starts music, booth DJ can take over")