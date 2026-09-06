-- BBYA SOCIAL HUB — DJ LIVE ENGINE v5 CLEAN REPLACEMENT
-- FAIL #3 replacement: old volume-suppression authority is retired.
-- AutoDJ sources keep their own Volume/Playback state; DJ takeover uses per-source EQ gates only.
-- One DJ authority, no patch stacking. Access remains managed DJ + OWNER/QA.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")
local Debris=game:GetService("Debris")

local QA_USERNAMES={nadmo97=true,arda_moron123=true}
local VENUE_GROUPS={CLUB="BBYAClubMaster",VIP="BBYAVIPMaster",UNDERGROUND="BBYABasementMaster",FUNKOT="BBYAFunkotMaster"}
local AUTO_SOURCES={
 CLUB={"BBYAClubDeckA","BBYAClubDeckB","BBYAMainPublicFallbackV4"},
 VIP={"BBYAVIPPlaylist"},
 UNDERGROUND={"BBYABasementDeckA","BBYABasementDeckB","BBYAUndergroundBreakbeatFallbackV4"},
 FUNKOT={"BBYAFunkotRuntimeV6"},
}
local GATE_NAME="BBYADJLiveV5AutoGate"
local NORMALIZED_175X=1/1.75

-- Read-only DJ library copied from current venue authorities. No invented IDs.
local LIBRARY={}
local function add(map,title,id,playbackSpeed)
 table.insert(LIBRARY,{map=map,title=title,id=tonumber(id),playbackSpeed=tonumber(playbackSpeed)or 1,artist=map})
end

-- MAIN CLUB — current progressive authority.
for _,t in ipairs({
 {"1.Walking On Air",96983528563473},{"10. CHRISYE - PERGILAH KASIH",105877233550276},{"10A - 130 - Always Loving You",94337788677482},
 {"11A - 130 - 01.runaway (mumu remix)",112322493409786},{"11A - 130 - Run_away_remix",89165355590583},{"11B - 126 - People (Eelke Kleijn Extended Mix)",134057367195123},
 {"11B - 128 - Nadia Ali - People",91900235935901},{"1A - 128 - Dreaming (Original Mix)",115774171488936},{"2A - 130 - tru love - Viemix Remix",100162128635185},
 {"2A - 132 - Stadium - The Time",82993942539950},{"3A - 128 - M O M M E N T",109286172792690},{"3A - 128 - Desert Rose - Stadium Mix 2011",94547306143480},
 {"3A - 130 - DESTINATION CALABRIA ORI",109116552044147},{"4. Stadium Club Remix - Stars of Edger",123077675190094},{"4B - 128 - Fly Away (Main Mix)",87114365256034},
 {"Utopia - Baby Doll (Phatbee Edit)",136681158481930},{"Tiket - Hanya Kamu yg Bisa (Phatbee & Berco Edit)",131557279061872},{"5A - 128 - Walking On Air",93670094706108},
 {"5A - 128 - Walkin On Air (Matthew)",81169975667413},{"5A - 130 - dj riri - rusty guitar",123696371004403},{"5A - 130 - PULSE OF JAKARTA",74479015238422},
 {"5A - 131 - High Revolution - Studio 51",102620964808698},{"11A - 130 - RUN AWAY",99998363156285},{"5B - 128 - Never Fear",88925775968276},
})do add("CLUB",t[1],t[2],1)end

-- VIP — exact 8-track v6.3 bank.
for _,t in ipairs({
 {"Wonder Girls - Nobody (ROOKIE Amapiano Edit)",105859685125263,1},{"AUDIO #135466870455541",135466870455541,1},{"AUDIO #104570664651564",104570664651564,1},
 {"AUDIO #126169746073506",126169746073506,NORMALIZED_175X},{"AUDIO #71255967755640",71255967755640,NORMALIZED_175X},{"AUDIO #96302475011963",96302475011963,NORMALIZED_175X},
 {"AUDIO #120132620242467",120132620242467,NORMALIZED_175X},{"AUDIO #132641805708328",132641805708328,NORMALIZED_175X},
})do add("VIP",t[1],t[2],t[3])end

-- UNDERGROUND — current 44-track authority, including 0.8 tracks and 1.75x-normalized owner uploads.
for _,t in ipairs({
 {"Tabola Bale - Kienzy x Ajun Perwira BKB EDIT",77926481439798,1},{"SOLEDAD [ DESTRA PRAYOGO ]#BKB2K25",112400686884526,1},{"MASIH DENGANMU [ DESTRA PRAYOGO ]#BKB2K25",140443777425109,1},
 {"MACARENA 2026 - ZHAK (BKB EDIT)",135670059308492,1},{"JANGAN TUNGGU LAMA LAMA BKB VOL 5",99406970263948,1},{"I NEED A DOCTOR 2025 - VAY BREAKS",129689050998627,1},
 {"I KNOW YOU WANT ME - KIN BKB EDIT",117479133947987,1},{"KUNTUL PANJANG - GERALD ATIMANG BOOTLEG",95368919127704,1},{"BANG BANG BANG - KIN EDIT",123499438012066,1},
 {"ANIMA BINTANG [ DESTRA PRAYOGO ]#BKB2K25",140442667497371,1},{"ANAK SINGKONG [ DESTRA PRAYOGO ]#BKB2K25",90986894139778,1},{"17.Mugwanti (Mahesa & hmp BKB Edit)",113698017406179,1},
 {"06. ARIA PIL KB (EANN BKB EDIT)",109573287368195,1},{"11A - 130 - RUN AWAY",99998363156285,1},{"TOR MONITOR KETUA - QMUNK AMSTRONG",105712830643792,1},
 {"SIK ASIK - Mail Alektra (BKB EDIT)",81832495836167,1},{"SEDIA AKU SEBELUM HUJAN - QMUNK AMSTRONG",117476404561871,1},{"POK ANI ANI - DJ VINNIE PARGOY, BILLIE KOPLO",139454814636865,1},
 {"PICA PICA 2 - ARIEF RASIT (BKB EDIT)",94631926635772,1},{"pararam-bkb-ipan-agstyan",99942691456392,1},{"Om Abidin - Ani Ani (Club Mix)",103410156771684,1},
 {"Ni De Wan Shui Qian Shan - Aldy alvaro, DJ U",106769175117849,1},{"Ni De Da An - Aldy alvaro",90741742310621,1},{"NGAPAIN REPOT (RAYEN BKB EDIT)",117103573334654,1},
 {"NGAPAIN REPOT (DEKA EDIT)",105840679569825,1},{"Ngapain Repot (Aldy Alvaro BKB edit)",106277277729828,1},{"MORENA BKB (HARLY EDIT)",97696234195316,1},
 {"I LOVE IT - KIN EDIT",131463436495955,.8},{"Jar of Hearts - Noka AxL Breakbeat Remix",90545257553901,.8},{"YOU DON'T EVEN KNOW ME STADIUM BREAKBEAT",133306911098734,.8},
 {"MILLION STARS STADIUM BREAKBEAT",118285103846602,.8},{"DJ TELOOR - WET GUITAR",74227363291004,.8},{"EE SAKADUNG KADING 2026",82680681349117,.8},
 {"BLACK HOLE - DJ TELOOR REMIX",126615725566516,.8},{"SERANA - FOR REVENGE (DJ Ugi Mekti BKB Edit)",79441401193706,.8},{"MUTIARA - IYAN.FG",117092832313612,.8},
 {"Kamu gak bakal tau",128236218314957,NORMALIZED_175X},{"Surga",73490528411091,NORMALIZED_175X},{"Hati",117969837722651,NORMALIZED_175X},
 {"Bintang jatuh",82059974893640,NORMALIZED_175X},{"Kapal tenggelam",124813032756402,NORMALIZED_175X},{"Pegangan",131317518484469,NORMALIZED_175X},
 {"Dalu dalu",112530372468543,NORMALIZED_175X},{"Anak kampung",128982389712711,NORMALIZED_175X},
})do add("UNDERGROUND",t[1],t[2],t[3])end

-- FUNKOT — exact runtime v6 bank.
for _,t in ipairs({
 {"Zinyo Funkytone - Siapa Benar - Garam Cina 2025.mp3",128141893547516},{"Zinyo Funky Tone - Hatiku Bagai Terpenjara 2025.mp3",98536948000407},{"Space Melody '23 - Dj Deri Rmx",128567852049551},
})do add("FUNKOT",t[1],t[2],1)end

local function parseBpm(title)
 for n in tostring(title):gmatch("%d%d%d")do local bpm=tonumber(n);if bpm and bpm>=80 and bpm<=200 then return bpm end end
 return 0
end
for i,t in ipairs(LIBRARY)do t.index=i;t.bpm=parseBpm(t.title);t.maps={t.map}end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local function remote(className,name)
 local r=remotes:FindFirstChild(name);if r and not r:IsA(className)then r:Destroy();r=nil end
 if not r then r=Instance.new(className);r.Name=name;r.Parent=remotes end
 return r
end
local action=remote("RemoteEvent","DJLiveAction")
local stateRemote=remote("RemoteEvent","DJLiveState")
local getState=remote("RemoteFunction","DJLiveGetState")
local getLibrary=remote("RemoteFunction","DJLiveGetLibrary")

for _,name in ipairs({"BBYADJLiveCleanEngine","BBYADJLiveV5Engine"})do local old=SoundService:FindFirstChild(name);if old then old:Destroy()end end
local engine=Instance.new("Folder");engine.Name="BBYADJLiveV5Engine";engine:SetAttribute("Version","DJ_LIVE_V5_EQ_GATE_SAFE");engine:SetAttribute("AutoDJTakeover","PER_SOURCE_EQ_GATE_ONLY");engine.Parent=SoundService

local function ensureEffect(sound,className,name)
 local e=sound:FindFirstChild(name);if e and e.ClassName~=className then e:Destroy();e=nil end
 if not e then e=Instance.new(className);e.Name=name;e.Parent=sound end
 return e
end
local function makeDeck(name)
 local s=Instance.new("Sound");s.Name=name;s.Volume=0;s.Looped=false;s.PlaybackSpeed=1;s.Parent=engine;s:SetAttribute("BBYADJLiveV5Deck",true)
 local fx={}
 fx.ECHO=ensureEffect(s,"EchoSoundEffect","DJV5Echo");fx.ECHO.Enabled=false;fx.ECHO.Delay=.18;fx.ECHO.Feedback=.38;fx.ECHO.WetLevel=-7
 fx.FILTER=ensureEffect(s,"EqualizerSoundEffect","DJV5Filter");fx.FILTER.Enabled=false;fx.FILTER.LowGain=2;fx.FILTER.MidGain=-5;fx.FILTER.HighGain=-16
 fx.REVERB=ensureEffect(s,"ReverbSoundEffect","DJV5Reverb");fx.REVERB.Enabled=false;fx.REVERB.DecayTime=1.8;fx.REVERB.WetLevel=-7
 fx.FLANGER=ensureEffect(s,"FlangeSoundEffect","DJV5Flanger");fx.FLANGER.Enabled=false;fx.FLANGER.Depth=.7;fx.FLANGER.Mix=.55;fx.FLANGER.Rate=.45
 return s,fx
end
local soundA,fxA=makeDeck("DeckA");local soundB,fxB=makeDeck("DeckB")
local function freshDeck()return{trackIndex=0,title="EMPTY",artist="",assetId=0,bpm=0,baseSpeed=1,playbackSpeed=1,playing=false,cue=0,loaded=false,fx={ECHO=false,FILTER=false,REVERB=false,FLANGER=false}}end
local S={live=false,map="CLUB",crossfader=.5,operator=nil,operatorUserId=nil,notice="READY",decks={A=freshDeck(),B=freshDeck()},gateActive=false}
local lastAction={};local brakeToken={A=0,B=0};local gated={};local gatedMap=nil

local function isOwnerQA(p)
 if not p then return false end
 local name=string.lower(p.Name)
 return QA_USERNAMES[name]==true or p:GetAttribute("BBYAOwner")==true or(game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId)
end
local function hasManagedDJ(p)return p~=nil and p:GetAttribute("BBYAHasDJRole")==true and p:GetAttribute("BBYAManagedRole")=="DJ"end
local function authorized(p)return isOwnerQA(p)or hasManagedDJ(p)end
local function identity(p)if isOwnerQA(p)then return"OWNER_QA"elseif hasManagedDJ(p)then return"DJ"end end
local function groupFor(map)local name=VENUE_GROUPS[map];local g=name and SoundService:FindFirstChild(name);return g and g:IsA("SoundGroup")and g or nil end
local function deckObjects(deck)if deck=="A"then return soundA,fxA,S.decks.A elseif deck=="B"then return soundB,fxB,S.decks.B end end

local function clearGates()
 for s,g in pairs(gated)do if g and g.Parent then g:Destroy()end;if s and s.Parent then s:SetAttribute("BBYADJLiveV5Gated",false)end end
 gated={};gatedMap=nil;S.gateActive=false
 for _,d in ipairs(SoundService:GetDescendants())do if d:IsA("EqualizerSoundEffect")and d.Name==GATE_NAME then d:Destroy()end end
end
local function findNamedSound(name)
 local d=SoundService:FindFirstChild(name,true);return d and d:IsA("Sound")and d or nil
end
local function ensureGate(sound)
 if not sound or not sound.Parent or sound:IsDescendantOf(engine)then return end
 local g=sound:FindFirstChild(GATE_NAME);if g and not g:IsA("EqualizerSoundEffect")then g:Destroy();g=nil end
 if not g then g=Instance.new("EqualizerSoundEffect");g.Name=GATE_NAME;g.Parent=sound end
 g.Enabled=true;g.LowGain=-80;g.MidGain=-80;g.HighGain=-80;gated[sound]=g;sound:SetAttribute("BBYADJLiveV5Gated",true)
end
local function mixGains()
 local x=math.clamp(tonumber(S.crossfader)or.5,0,1)
 return math.cos(x*math.pi*.5),math.sin(x*math.pi*.5)
end
local function shouldGate()
 if not S.live then return false end
 local ga,gb=mixGains()
 return(soundA.Playing and ga>.025)or(soundB.Playing and gb>.025)
end
local function syncAutoGates()
 if not shouldGate()then if gatedMap then clearGates()end;return end
 if gatedMap~=S.map then clearGates();gatedMap=S.map end
 for _,name in ipairs(AUTO_SOURCES[S.map]or{})do ensureGate(findNamedSound(name))end
 gatedMap=S.map;S.gateActive=true
end
local function routeDecks()
 local g=groupFor(S.map);if not g then return false end
 soundA.SoundGroup=g;soundB.SoundGroup=g;engine:SetAttribute("Map",S.map);engine:SetAttribute("Live",S.live);return true
end
local function applyFx(deck)local _,fx,d=deckObjects(deck);if d then for name,e in pairs(fx)do e.Enabled=d.fx[name]==true end end end
local function applyMix()
 local ga,gb=mixGains();soundA.Volume=S.live and ga or 0;soundB.Volume=S.live and gb or 0;applyFx("A");applyFx("B");syncAutoGates()
end
local function syncPlayingFlags()S.decks.A.playing=soundA.Playing;S.decks.B.playing=soundB.Playing;S.decks.A.playbackSpeed=soundA.PlaybackSpeed;S.decks.B.playbackSpeed=soundB.PlaybackSpeed end
local function snapshot()syncPlayingFlags();return{authorized=true,version="DJ_LIVE_V5",live=S.live,map=S.map,crossfader=S.crossfader,operator=S.operator,notice=S.notice,gateActive=S.gateActive,decks=S.decks}end
local function broadcast(notice)
 if notice~=nil then S.notice=tostring(notice)end
 local snap=snapshot();for _,p in ipairs(Players:GetPlayers())do if authorized(p)then stateRemote:FireClient(p,snap)end end
end
local function resetDecks()
 soundA:Stop();soundB:Stop();soundA.SoundId="";soundB.SoundId="";soundA.PlaybackSpeed=1;soundB.PlaybackSpeed=1;S.decks.A=freshDeck();S.decks.B=freshDeck();applyMix()
end
local function stopLive(notice)
 S.live=false;S.operator=nil;S.operatorUserId=nil;clearGates();soundA:Pause();soundB:Pause();applyMix();engine:SetAttribute("Live",false);broadcast(notice or"DJ LIVE STOP")
end

local function loadTrack(deck,index)
 local sound,_,d=deckObjects(deck);local t=LIBRARY[tonumber(index)or 0]
 if not sound or not d or not t or t.map~=S.map then return false end
 sound:Stop();sound.TimePosition=0;sound.PlaybackSpeed=t.playbackSpeed or 1;sound.SoundId="rbxassetid://"..tostring(t.id)
 d.trackIndex=t.index;d.title=t.title;d.artist=t.artist;d.assetId=t.id;d.bpm=t.bpm;d.baseSpeed=t.playbackSpeed or 1;d.playbackSpeed=sound.PlaybackSpeed;d.cue=0;d.loaded=false;d.playing=false
 task.spawn(function()
  local ok=pcall(function()ContentProvider:PreloadAsync({sound})end)
  if d.trackIndex==t.index then d.loaded=ok and sound.IsLoaded;broadcast(d.loaded and("LOADED • DECK "..deck.." • "..t.title)or("LOAD CHECK • DECK "..deck))end
 end)
 return true
end
local function playToggle(deck)
 local sound,_,d=deckObjects(deck);if not sound or not d or d.assetId<1 then return end
 if sound.Playing then sound:Pause()else pcall(function()sound:Play()end)end;syncPlayingFlags();applyMix()
end
local function cue(deck)
 local sound,_,d=deckObjects(deck);if not sound or not d or d.assetId<1 then return end
 if sound.Playing then sound:Pause()end;pcall(function()sound.TimePosition=math.max(0,d.cue or 0)end);syncPlayingFlags();applyMix()
end
local function syncDeck(deck)
 local target,_,td=deckObjects(deck);local source,_,sd=deckObjects(deck=="A"and"B"or"A")
 if not target or not source or not td or not sd or td.assetId<1 or sd.assetId<1 then return end
 if td.bpm>0 and sd.bpm>0 then target.PlaybackSpeed=math.clamp((td.baseSpeed or 1)*(sd.bpm/td.bpm),.4,1.4)else target.PlaybackSpeed=td.baseSpeed or 1 end
 if source.Playing then local phase=source.TimePosition%2;pcall(function()target.TimePosition=math.max(0,math.floor(target.TimePosition/2)*2+phase)end)end
 td.playbackSpeed=target.PlaybackSpeed
end
local function toggleFx(deck,name)name=string.upper(tostring(name or""));local _,_,d=deckObjects(deck);if d and d.fx[name]~=nil then d.fx[name]=not d.fx[name];applyFx(deck)end end
local function brake(deck)
 local sound,_,d=deckObjects(deck);if not sound or not d or d.assetId<1 then return end;brakeToken[deck]+=1;local token=brakeToken[deck];local start=math.max(.2,sound.PlaybackSpeed)
 task.spawn(function()for i=1,12 do if brakeToken[deck]~=token then return end;sound.PlaybackSpeed=math.max(.08,start*(1-i/13));task.wait(.045)end;if brakeToken[deck]==token then sound:Pause();sound.PlaybackSpeed=d.baseSpeed or 1;syncPlayingFlags();applyMix();broadcast("BRAKE • DECK "..deck)end end)
end
local function normalized(v)return string.upper(tostring(v or"")):gsub("[^A-Z0-9]","")end
local function findExistingSample(name)
 local wanted=normalized(name);for _,root in ipairs({SoundService,ReplicatedStorage})do for _,d in ipairs(root:GetDescendants())do if d:IsA("Sound")and not d:IsDescendantOf(engine)and(normalized(d.Name)==wanted or normalized(d:GetAttribute("BBYASFXName"))==wanted)then return d end end end
end
local function triggerSample(deck,name)
 name=string.upper(tostring(name or""));if name=="BRAKE"then brake(deck);return end
 local source=findExistingSample(name);if not source or source.SoundId==""then broadcast(name.." sample belum tersedia di BBYA SFX authority");return end
 local clone=Instance.new("Sound");clone.Name="DJV5Sample_"..name;clone.SoundId=source.SoundId;clone.Volume=source.Volume>0 and source.Volume or 1;clone.PlaybackSpeed=source.PlaybackSpeed;clone.SoundGroup=groupFor(S.map);clone.Parent=engine;Debris:AddItem(clone,20);pcall(function()clone:Play()end);broadcast(name.." • DECK "..deck)
end
local function setMap(map)
 map=string.upper(tostring(map or""));if not VENUE_GROUPS[map]or not groupFor(map)then broadcast("AUDIO MASTER "..map.." BELUM SIAP");return false end
 if map==S.map then return true end
 clearGates();S.map=map;resetDecks();routeDecks();engine:SetAttribute("Map",map);broadcast("VENUE • "..map);return true
end
local function liveStart(player)
 if S.live or not authorized(player)then return end;if not routeDecks()then broadcast("VENUE MASTER BELUM SIAP");return end
 S.live=true;S.operator=identity(player);S.operatorUserId=player.UserId;engine:SetAttribute("Live",true);applyMix();broadcast("DJ LIVE READY • "..S.map)
end
local function handle(player,kind,payload)
 if not authorized(player)then return end
 local now=os.clock();if now-(lastAction[player]or 0)<.03 then return end;lastAction[player]=now
 kind=string.lower(tostring(kind or""));payload=type(payload)=="table"and payload or{};local deck=string.upper(tostring(payload.deck or""))
 if kind=="load"then loadTrack(deck,payload.index)
 elseif kind=="play_toggle"then playToggle(deck)
 elseif kind=="cue"then cue(deck)
 elseif kind=="sync"then syncDeck(deck)
 elseif kind=="crossfader"then S.crossfader=math.clamp(tonumber(payload.value)or.5,0,1);applyMix()
 elseif kind=="fx_toggle"then toggleFx(deck,payload.fx)
 elseif kind=="sample"then triggerSample(deck,payload.fx)
 elseif kind=="map"then setMap(payload.value)
 elseif kind=="live_start"then liveStart(player)
 elseif kind=="live_stop"and(S.operatorUserId==player.UserId or isOwnerQA(player))then stopLive()
 else return end
 broadcast()
end

action.OnServerEvent:Connect(handle)
getState.OnServerInvoke=function(player)if not authorized(player)then return{authorized=false}end;return snapshot()end
getLibrary.OnServerInvoke=function(player)if not authorized(player)then return{}end;return LIBRARY end

local function applyAuth(p)
 local ok=authorized(p);p:SetAttribute("BBYADJLiveAuthorized",ok);p:SetAttribute("BBYADJLiveIdentity",identity(p)or"")
 if S.live and S.operatorUserId==p.UserId and not ok then stopLive("DJ LIVE STOP • AUTH REMOVED")end
end
local function bindPlayer(p)
 applyAuth(p);p:GetAttributeChangedSignal("BBYAHasDJRole"):Connect(function()applyAuth(p)end);p:GetAttributeChangedSignal("BBYAManagedRole"):Connect(function()applyAuth(p)end);p:GetAttributeChangedSignal("BBYAOwner"):Connect(function()applyAuth(p)end)
end
for _,p in ipairs(Players:GetPlayers())do bindPlayer(p)end
Players.PlayerAdded:Connect(bindPlayer)
Players.PlayerRemoving:Connect(function(p)lastAction[p]=nil;if S.live and S.operatorUserId==p.UserId then stopLive("DJ LIVE STOP • OPERATOR LEFT")end end)
soundA.Ended:Connect(function()syncPlayingFlags();applyMix();broadcast("DECK A ENDED")end)
soundB.Ended:Connect(function()syncPlayingFlags();applyMix();broadcast("DECK B ENDED")end)
SoundService.DescendantAdded:Connect(function(d)if d:IsA("Sound")and S.live then task.defer(syncAutoGates)end end)
task.spawn(function()while task.wait(.15)do if S.live then syncAutoGates()end end end)
task.spawn(function()while task.wait(.40)do if S.live or soundA.Playing or soundB.Playing then broadcast()end end end)
game:BindToClose(clearGates)
routeDecks();applyMix()
print("[BBYA] DJ LIVE v5 online: clean FAIL#3 replacement / per-source EQ gate / no AutoDJ Volume mutation")