-- BBYA MASTER MUSIC VAULT + AUTO-DJ v1.0
-- Server-authoritative playback. Tracks marked DEAD are never queued.

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
local function canControl(p)
 if not p then return false end
 if p.UserId==QUEEN_ID then return true end
 local r=string.upper(tostring(p:GetAttribute("BBYARole") or ""))
 return r=="DJ" or r=="ADMIN" or r=="ACC_MASTER_OWNER"
end

local VAULT={
 -- INDONESIAN FLOOR
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

 -- INTERNATIONAL FLOOR
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
sound.Name="BBYA_MainMusic";sound.Volume=.65;sound.Looped=false;sound.Parent=SoundService

local activeMode="ALL"
local queue={}
local cursor=0
local current=nil
local consecutiveFailures=0
local lastAction={}

local function usable(t)return t.status~="DEAD" end
local function rebuild(mode)
 activeMode=mode or activeMode
 queue={}
 local wanted=FLOWS[activeMode]
 if activeMode=="ALL" then
  for _,t in ipairs(VAULT)do if usable(t)then table.insert(queue,t)end end
 else
  for _,sub in ipairs(wanted or {})do
   for _,t in ipairs(VAULT)do if usable(t) and t.sub==sub then table.insert(queue,t)end end
  end
 end
 cursor=0
end

local function publish()
 workspace:SetAttribute("BBYANowPlaying",current and current.title or "BBYA 24/7")
 workspace:SetAttribute("BBYAMusicMode",activeMode)
 workspace:SetAttribute("BBYAMusicSubgenre",current and current.sub or "")
 workspace:SetAttribute("BBYAMusicStatus",current and current.status or "")
 MusicState:FireAllClients({
  title=current and current.title or "BBYA 24/7",
  genre=current and current.genre or "",
  sub=current and current.sub or "",
  status=current and current.status or "",
  mode=activeMode,
  volume=sound.Volume,
  playing=sound.Playing,
 })
end

local function tryTrack(t)
 current=t
 sound:Stop()
 sound.SoundId="rbxassetid://"..tostring(t.id)
 sound.TimePosition=0
 sound:Play()
 publish()
 -- Give Roblox time to resolve permission/load. If inaccessible, skip automatically.
 task.delay(8,function()
  if current~=t then return end
  if not sound.IsLoaded or sound.TimeLength<=0 then
   consecutiveFailures+=1
   if consecutiveFailures<=6 then task.defer(function() if current==t then sound:Stop(); current=nil; end end) end
  else
   consecutiveFailures=0
  end
 end)
end

local function nextTrack()
 if #queue==0 then rebuild(activeMode) end
 if #queue==0 then current=nil;publish();return end
 cursor=cursor%#queue+1
 tryTrack(queue[cursor])
end

sound.Ended:Connect(nextTrack)
sound.Stopped:Connect(function()
 -- Only auto-advance if a failed/unloaded track cleared itself rather than a manual pause.
 if current==nil then task.delay(.25,nextTrack) end
end)

local function rate(p,key,sec)
 local k=tostring(p.UserId)..":"..key;local n=os.clock()
 if lastAction[k] and n-lastAction[k]<sec then return false end
 lastAction[k]=n;return true
end

MusicRemote.OnServerEvent:Connect(function(p,action,value)
 if not canControl(p) or not rate(p,"music",.25) then return end
 action=string.upper(tostring(action or ""))
 if action=="NEXT" then nextTrack()
 elseif action=="PAUSE" then sound:Pause();publish()
 elseif action=="PLAY" then if sound.SoundId=="" then nextTrack() else sound:Resume();publish() end
 elseif action=="VOLUME" then sound.Volume=math.clamp(tonumber(value) or .65,0,1);publish()
 elseif action=="MODE" then local m=string.upper(tostring(value or "ALL"));if FLOWS[m]then rebuild(m);nextTrack()end
 elseif action=="SUBGENRE" then
  local sub=string.upper(tostring(value or ""));queue={};for _,t in ipairs(VAULT)do if usable(t)and t.sub==sub then table.insert(queue,t)end end;cursor=0;if #queue>0 then activeMode=sub;nextTrack()end
 end
end)

rebuild("ALL")
task.delay(3,nextTrack)
print("[BBYA MUSIC] Master Vault loaded:",#VAULT,"tracks")