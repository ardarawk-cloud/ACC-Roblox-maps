-- TRACK 01 v4.2.0 — AUTO RANDOM 24/7 + AUTOMIX
-- Approved/active BBYA SoundIds only. Skatepark is hard-excluded.
-- Spatial emitters exist only inside Car 01-04.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")
local ContentProvider=game:GetService("ContentProvider")
local RunService=game:GetService("RunService")

local VERSION="4.2.0"
local CROSSFADE=7
local MASTER_DEFAULT=.72
local CAR_SPECS={{name="CAR_01",z=-58,gain=.42},{name="CAR_02",z=-5,gain=.58},{name="CAR_03",z=48,gain=.78},{name="CAR_04",z=101,gain=.96}}
local Z_OFFSETS={-14,0,14}
local PLAYLIST={
-- BBYA Progressive: 28 active routed assets.
{id="92702917431354",source="PROGRESSIVE"},{id="115888429247140",source="PROGRESSIVE"},{id="81067975196024",source="PROGRESSIVE"},{id="76999503317939",source="PROGRESSIVE"},{id="118117585511088",source="PROGRESSIVE"},{id="100105336048945",source="PROGRESSIVE"},{id="133637574696828",source="PROGRESSIVE"},{id="115630349269312",source="PROGRESSIVE"},{id="103311122364729",source="PROGRESSIVE"},{id="127279442599331",source="PROGRESSIVE"},{id="81269753705199",source="PROGRESSIVE"},{id="107310072452368",source="PROGRESSIVE"},{id="79404897034350",source="PROGRESSIVE"},{id="130628759763851",source="PROGRESSIVE"},{id="80712330348006",source="PROGRESSIVE"},{id="88482943108864",source="PROGRESSIVE"},{id="131113336118215",source="PROGRESSIVE"},{id="130652457794872",source="PROGRESSIVE"},{id="96201307185074",source="PROGRESSIVE"},{id="125068509199097",source="PROGRESSIVE"},{id="132685557961369",source="PROGRESSIVE"},{id="92845805134726",source="PROGRESSIVE"},{id="111162505018062",source="PROGRESSIVE"},{id="86119899029100",source="PROGRESSIVE"},{id="79262763273656",source="PROGRESSIVE"},{id="119021087760906",source="PROGRESSIVE"},{id="76089367016271",source="PROGRESSIVE"},{id="127018756715269",source="PROGRESSIVE"},
-- BBYA Underground: approved + permissioned LIVE_IN_PLAYLIST only.
{id="77926481439798",source="UNDERGROUND"},{id="112400686884526",source="UNDERGROUND"},{id="75709298846740",source="UNDERGROUND"},{id="140443777425109",source="UNDERGROUND"},{id="135670059308492",source="UNDERGROUND"},{id="114038149273002",source="UNDERGROUND"},{id="99406970263948",source="UNDERGROUND"},{id="129689050998627",source="UNDERGROUND"},{id="117479133947987",source="UNDERGROUND"},{id="125107386771710",source="UNDERGROUND"},{id="95368919127704",source="UNDERGROUND"},{id="123499438012066",source="UNDERGROUND"},{id="140442667497371",source="UNDERGROUND"},{id="90986894139778",source="UNDERGROUND"},{id="130909529715712",source="UNDERGROUND"},{id="116771187608517",source="UNDERGROUND"},{id="113698017406179",source="UNDERGROUND"},{id="109573287368195",source="UNDERGROUND"},{id="99998363156285",source="UNDERGROUND"},{id="105712830643792",source="UNDERGROUND"},{id="81832495836167",source="UNDERGROUND"},{id="117476404561871",source="UNDERGROUND"},{id="139454814636865",source="UNDERGROUND"},{id="94631926635772",source="UNDERGROUND"},{id="99942691456392",source="UNDERGROUND"},{id="103410156771684",source="UNDERGROUND"},{id="106769175117849",source="UNDERGROUND"},{id="90741742310621",source="UNDERGROUND"},{id="117103573334654",source="UNDERGROUND"},{id="105840679569825",source="UNDERGROUND"},{id="106277277729828",source="UNDERGROUND"},{id="97696234195316",source="UNDERGROUND"},{id="106194805739169",source="UNDERGROUND"},
-- BBYA Funkot runtime: verified approved + permissioned.
{id="128141893547516",source="FUNKOT"},{id="98536948000407",source="FUNKOT"},{id="128567852049551",source="FUNKOT"},
-- BBYA Rooftop Tropical: approved + permissioned LIVE_IN_PLAYLIST only.
{id="81739335079331",source="ROOFTOP"},{id="102905513042645",source="ROOFTOP"},{id="80455951712097",source="ROOFTOP"},
}
assert(#PLAYLIST==67,"TRACK01 67-track catalog lock failed")

local old=Workspace:FindFirstChild("TRACK01_MusicSpatial")
if old then old:Destroy() end
local root=Instance.new("Folder");root.Name="TRACK01_MusicSpatial";root.Parent=Workspace
local probe=SoundService:FindFirstChild("TRACK01_MusicProbe")
if probe then probe:Destroy() end
probe=Instance.new("Sound");probe.Name="TRACK01_MusicProbe";probe.Volume=0;probe.Parent=SoundService
local decks={A={},B={}}
for _,spec in ipairs(CAR_SPECS) do
 local f=Instance.new("Folder");f.Name=spec.name;f.Parent=root
 for n,dz in ipairs(Z_OFFSETS) do
  local p=Instance.new("Part");p.Name=string.format("Emitter_%02d",n);p.Size=Vector3.new(.25,.25,.25);p.CFrame=CFrame.new(25.5,9.2,spec.z+dz);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Transparency=1;p.Parent=f
  for _,deckName in ipairs({"A","B"}) do
   local s=Instance.new("Sound");s.Name="Deck"..deckName;s.Volume=0;s.Looped=false;s.RollOffMode=Enum.RollOffMode.InverseTapered;s.RollOffMinDistance=3;s.RollOffMaxDistance=12.5;s.EmitterSize=2;s.Parent=p
   table.insert(decks[deckName],{sound=s,gain=spec.gain})
  end
 end
end

local rng=Random.new(math.max(1,os.time()%2147483646))
local bag,bagPos={},1
local active,inactive="A","B"
local currentIndex,currentTrack=0,nil
local paused,transitioning=false,false
local masterVolume=MASTER_DEFAULT
local failedUntil={}
local stateEvent

local function authorized(p)
 if not p then return false end
 if RunService:IsStudio() then return true end
 if string.lower(p.Name or "")=="ridhoomaukamu" then return true end
 local raw=Workspace:GetAttribute("TRACK01_ADMIN_USER_IDS")
 if type(raw)=="string" then for token in string.gmatch(raw,"[^,%s]+") do if tonumber(token)==p.UserId then return true end end end
 if game.CreatorType==Enum.CreatorType.User then return p.UserId==game.CreatorId end
 if game.CreatorType==Enum.CreatorType.Group then local ok,rank=pcall(function()return p:GetRankInGroup(game.CreatorId)end);return ok and rank>=255 end
 return false
end
local function shuffle()
 bag={};for i=1,#PLAYLIST do bag[i]=i end
 for i=#bag,2,-1 do local j=rng:NextInteger(1,i);bag[i],bag[j]=bag[j],bag[i] end
 if #bag>1 and bag[1]==currentIndex then bag[1],bag[2]=bag[2],bag[1] end
 bagPos=1
end
local function candidate()
 if #bag==0 or bagPos>#bag then shuffle() end
 for _=1,#PLAYLIST do
  if bagPos>#bag then shuffle() end
  local i=bag[bagPos];bagPos+=1
  if i~=currentIndex and (not failedUntil[i] or os.clock()>=failedUntil[i]) then return i end
 end
 return rng:NextInteger(1,#PLAYLIST)
end
local function setVolume(deckName,a)
 a=math.clamp(a,0,1)
 for _,r in ipairs(decks[deckName]) do r.sound.Volume=math.clamp(masterVolume*r.gain*a,0,1) end
end
local function stopDeck(deckName)
 for _,r in ipairs(decks[deckName]) do pcall(function()r.sound:Stop()end);r.sound.TimePosition=0;r.sound.Volume=0 end
end
local function rep(deckName)return decks[deckName][1] and decks[deckName][1].sound or nil end
local function preload(i)
 local t=PLAYLIST[i];probe:Stop();probe.SoundId="rbxassetid://"..t.id;probe.TimePosition=0
 local ok=pcall(function()ContentProvider:PreloadAsync({probe})end);if not ok then return false end
 local deadline=os.clock()+6
 while os.clock()<deadline do if probe.IsLoaded and (probe.TimeLength or 0)>1 then return true end;task.wait(.12) end
 return probe.IsLoaded and (probe.TimeLength or 0)>1
end
local function prepare(deckName,i)
 local t=PLAYLIST[i]
 if not preload(i) then failedUntil[i]=os.clock()+60;Workspace:SetAttribute("TRACK01_MUSIC_LAST_FAILED_ID",t.id);return false end
 for _,r in ipairs(decks[deckName]) do local s=r.sound;pcall(function()s:Stop()end);s.SoundId="rbxassetid://"..t.id;s.TimePosition=0;s.Volume=0;s:SetAttribute("TrackId",t.id);s:SetAttribute("TrackSource",t.source) end
 return true
end
local function playDeck(deckName)
 local n=0;for _,r in ipairs(decks[deckName]) do if pcall(function()r.sound:Play()end) then n+=1 end end;return n>0
end
local function publish()
 local r=rep(active)
 Workspace:SetAttribute("TRACK01_MUSIC_AUTO",true);Workspace:SetAttribute("TRACK01_MUSIC_AUTOMIX",true);Workspace:SetAttribute("TRACK01_MUSIC_SPATIAL_CARS_ONLY",true);Workspace:SetAttribute("TRACK01_MUSIC_SKATEPARK_EXCLUDED",true)
 Workspace:SetAttribute("TRACK01_MUSIC_TRACK_COUNT",#PLAYLIST);Workspace:SetAttribute("TRACK01_MUSIC_VERSION",VERSION);Workspace:SetAttribute("TRACK01_MUSIC_VOLUME",masterVolume)
 Workspace:SetAttribute("TRACK01_MUSIC_STATUS",paused and "PAUSED" or (currentTrack and "PLAYING" or "STARTING"));Workspace:SetAttribute("TRACK01_MUSIC_CURRENT_SOUND_ID",currentTrack and currentTrack.id or "");Workspace:SetAttribute("TRACK01_MUSIC_CURRENT_TRACK",currentTrack and ("BBYA "..currentTrack.source) or "AUTO RANDOM 24/7");Workspace:SetAttribute("TRACK01_MUSIC_CURRENT_SOURCE",currentTrack and currentTrack.source or "");Workspace:SetAttribute("TRACK01_MUSIC_PLAYING",r and r.IsPlaying and not paused or false)
 if not stateEvent or not stateEvent.Parent then local folder=ReplicatedStorage:FindFirstChild("TRACK01_Admin");stateEvent=folder and folder:FindFirstChild("State") or nil end
 if stateEvent and stateEvent:IsA("RemoteEvent") then
  local snap={venueStatus=Workspace:GetAttribute("TRACK01_VENUE_STATUS") or "NIGHT_SERVICE",eventMode=Workspace:GetAttribute("TRACK01_EVENT_MODE") or "NONE",eventPreset=Workspace:GetAttribute("TRACK01_EVENT_PRESET") or "NORMAL",pulseEnabled=Workspace:GetAttribute("TRACK01_LIGHT_PULSE_ENABLED")~=false,lightingPreset=Workspace:GetAttribute("TRACK01_LIGHTING_PRESET") or "STANDARD",featureComplete=Workspace:GetAttribute("ACC_TRACK01_FEATURE_COMPLETE")==true,sourceRuntimeVersion=Workspace:GetAttribute("ACC_TRACK01_VERSION") or "UNKNOWN",panelVersion=VERSION,playerCount=#Players:GetPlayers(),operatorName="AUTO DJ",uptimeSeconds=0,musicConfigured=true,musicPlaying=r and r.IsPlaying and not paused or false,musicVolume=masterVolume,musicTrack=currentTrack and ("BBYA "..currentTrack.source.." • RANDOM AUTOMIX") or "AUTO RANDOM 24/7 • AUTOMIX"}
  for _,p in ipairs(Players:GetPlayers()) do if authorized(p) then stateEvent:FireClient(p,snap) end end
 end
end
local function fade(fromDeck,toDeck)
 local steps=70
 for i=0,steps do while paused do task.wait(.15) end;local a=i/steps;setVolume(fromDeck,1-a);setVolume(toDeck,a);task.wait(CROSSFADE/steps) end
end
local function first()
 for _=1,#PLAYLIST do local i=candidate();if prepare(active,i) and playDeck(active) then currentIndex=i;currentTrack=PLAYLIST[i];for n=1,15 do setVolume(active,n/15);task.wait(.08) end;publish();return true end end
 return false
end
local function nextMix()
 if transitioning or paused then return false end;transitioning=true
 local chosen
 for _=1,#PLAYLIST do local i=candidate();if prepare(inactive,i) and playDeck(inactive) then chosen=i;break end end
 if not chosen then transitioning=false;return false end
 local old,new=active,inactive;fade(old,new);stopDeck(old);active,inactive=new,old;currentIndex=chosen;currentTrack=PLAYLIST[chosen];transitioning=false;publish();return true
end
local function restart()
 if currentIndex<1 then return end
 for _,r in ipairs(decks[active]) do r.sound.TimePosition=0;if not paused then pcall(function()r.sound:Play()end) end end;setVolume(active,1);publish()
end
local function pauseAll()for _,d in ipairs({"A","B"}) do for _,r in ipairs(decks[d]) do pcall(function()r.sound:Pause()end) end end end
local function resumeAll()for _,d in ipairs({"A","B"}) do for _,r in ipairs(decks[d]) do pcall(function()r.sound:Resume()end) end end end

task.spawn(function()
 while task.wait(.4) do
  local folder=ReplicatedStorage:FindFirstChild("TRACK01_Admin");local command=folder and folder:FindFirstChild("Command")
  if command and command:IsA("RemoteEvent") then
   command.OnServerEvent:Connect(function(p,a,v)
    if not authorized(p) then return end
    if a=="MUSIC_PLAY" then paused=false;resumeAll();if not (rep(active) and rep(active).IsPlaying) then restart() end
    elseif a=="MUSIC_PAUSE" then paused=true;pauseAll()
    elseif a=="MUSIC_RESTART" then restart()
    elseif a=="MUSIC_VOLUME" and type(v)=="number" then masterVolume=math.clamp(masterVolume+v,.10,1);setVolume(active,1) end
    task.defer(function()task.wait(.1);publish()end)
   end)
   break
  end
 end
end)
Workspace:SetAttribute("ACC_TRACK01_MUSIC_READY",true)
task.spawn(function()
 while not first() do Workspace:SetAttribute("TRACK01_MUSIC_STATUS","RETRYING");task.wait(3) end
 while task.wait(.35) do
  if not paused and not transitioning then
   local r=rep(active)
   if not r or not r.IsPlaying then nextMix() else local len=r.TimeLength or 0;if len>2 and r.TimePosition>=math.max(1,len-CROSSFADE-.4) then nextMix() end end
  end
 end
end)
task.spawn(function()while task.wait(2) do publish() end end)
print("[TRACK 01] v4.2.0 AutoDJ ready: 67-track BBYA pool, random 24/7, 7s automix, Car 01-04 only, Skatepark excluded")
