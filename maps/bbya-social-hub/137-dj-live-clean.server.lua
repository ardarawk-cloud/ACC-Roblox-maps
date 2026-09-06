-- BBYA SOCIAL HUB — DJ LIVE CLEAN ENGINE v2.2
-- Single DJ LIVE audio/control authority.
-- Access: managed DJ role, plus explicit OWNER/QA identities without changing their managed role/title.
-- Venue catalog/routing remains owned by existing BBYA music authorities outside DJ LIVE.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")
local Debris=game:GetService("Debris")

local QA_USERNAMES={nadmo97=true,arda_moron123=true}
local VENUE_GROUPS={CLUB="BBYAClubMaster",VIP="BBYAVIPMaster",UNDERGROUND="BBYABasementMaster",FUNKOT="BBYAFunkotMaster"}
local AUTO_SOURCES={CLUB={"BBYAClubDeckA","BBYAClubDeckB"},VIP={"BBYAVIPPlaylist"},UNDERGROUND={"BBYABasementDeckA","BBYABasementDeckB"},FUNKOT={"BBYAFunkotRuntimeV6"}}

-- Read-only index of assets already present in BBYA authorities. No new/invented IDs.
local LIBRARY={
 {id=96983528563473,title="1.Walking On Air",artist="BBYA Main",map="CLUB"},
 {id=105877233550276,title="10. CHRISYE - PERGILAH KASIH",artist="BBYA Main",map="CLUB"},
 {id=94337788677482,title="10A - 130 - Always Loving You",artist="BBYA Main",map="CLUB"},
 {id=112322493409786,title="11A - 130 - 01.runaway (mumu remix)",artist="BBYA Main",map="CLUB"},
 {id=89165355590583,title="11A - 130 - Run_away_remix",artist="BBYA Main",map="CLUB"},
 {id=134057367195123,title="11B - 126 - People (Eelke Kleijn Extended Mix)",artist="BBYA Main",map="CLUB"},
 {id=91900235935901,title="11B - 128 - Nadia Ali - People",artist="BBYA Main",map="CLUB"},
 {id=115774171488936,title="1A - 128 - Dreaming (Original Mix)",artist="BBYA Main",map="CLUB"},
 {id=100162128635185,title="2A - 130 - tru love - Viemix Remix",artist="BBYA Main",map="CLUB"},
 {id=82993942539950,title="2A - 132 - Stadium - The Time",artist="BBYA Main",map="CLUB"},
 {id=109286172792690,title="3A - 128 - M O M M E N T",artist="BBYA Main",map="CLUB"},
 {id=94547306143480,title="3A - 128 - Desert Rose - Stadium Mix 2011",artist="BBYA Main",map="CLUB"},
 {id=109116552044147,title="3A - 130 - DESTINATION CALABRIA ORI",artist="BBYA Main",map="CLUB"},
 {id=123077675190094,title="4. Stadium Club Remix - Stars of Edger",artist="BBYA Main",map="CLUB"},
 {id=87114365256034,title="4B - 128 - Fly Away (Main Mix)",artist="BBYA Main",map="CLUB"},
 {id=136681158481930,title="Utopia - Baby Doll (Phatbee Edit)",artist="BBYA Main",map="CLUB"},
 {id=131557279061872,title="Tiket - Hanya Kamu yg Bisa (Phatbee & Berco Edit)",artist="BBYA Main",map="CLUB"},
 {id=93670094706108,title="5A - 128 - Walking On Air",artist="BBYA Main",map="CLUB"},
 {id=81169975667413,title="5A - 128 - Walkin On Air (Matthew)",artist="BBYA Main",map="CLUB"},
 {id=123696371004403,title="5A - 130 - dj riri - rusty guitar",artist="BBYA Main",map="CLUB"},
 {id=74479015238422,title="5A - 130 - PULSE OF JAKARTA",artist="BBYA Main",map="CLUB"},
 {id=102620964808698,title="5A - 131 - High Revolution - Studio 51",artist="BBYA Main",map="CLUB"},
 {id=99998363156285,title="11A - 130 - RUN AWAY",artist="BBYA Main",map="CLUB"},
 {id=88925775968276,title="5B - 128 - Never Fear",artist="BBYA Main",map="CLUB"},
 {id=126169746073506,title="AUDIO #126169746073506",artist="VIP Amapiano",map="VIP"},
 {id=71255967755640,title="AUDIO #71255967755640",artist="VIP Amapiano",map="VIP"},
 {id=96302475011963,title="AUDIO #96302475011963",artist="VIP Amapiano",map="VIP"},
 {id=120132620242467,title="AUDIO #120132620242467",artist="VIP Amapiano",map="VIP"},
 {id=132641805708328,title="AUDIO #132641805708328",artist="VIP Amapiano",map="VIP"},
 {id=77926481439798,title="Tabola Bale - Kienzy x Ajun Perwira BKB EDIT",artist="BBYA Underground",map="UNDERGROUND"},
 {id=112400686884526,title="SOLEDAD [ DESTRA PRAYOGO ]#BKB2K25",artist="BBYA Underground",map="UNDERGROUND"},
 {id=140443777425109,title="MASIH DENGANMU [ DESTRA PRAYOGO ]#BKB2K25",artist="BBYA Underground",map="UNDERGROUND"},
 {id=135670059308492,title="MACARENA 2026 - ZHAK (BKB EDIT)",artist="BBYA Underground",map="UNDERGROUND"},
 {id=99406970263948,title="JANGAN TUNGGU LAMA LAMA BKB VOL 5",artist="BBYA Underground",map="UNDERGROUND"},
 {id=129689050998627,title="I NEED A DOCTOR 2025 - VAY BREAKS",artist="BBYA Underground",map="UNDERGROUND"},
 {id=117479133947987,title="I KNOW YOU WANT ME - KIN BKB EDIT",artist="BBYA Underground",map="UNDERGROUND"},
 {id=95368919127704,title="KUNTUL PANJANG - GERALD ATIMANG BOOTLEG",artist="BBYA Underground",map="UNDERGROUND"},
 {id=123499438012066,title="BANG BANG BANG - KIN EDIT",artist="BBYA Underground",map="UNDERGROUND"},
 {id=140442667497371,title="ANIMA BINTANG [ DESTRA PRAYOGO ]#BKB2K25",artist="BBYA Underground",map="UNDERGROUND"},
 {id=90986894139778,title="ANAK SINGKONG [ DESTRA PRAYOGO ]#BKB2K25",artist="BBYA Underground",map="UNDERGROUND"},
 {id=113698017406179,title="17.Mugwanti (Mahesa & hmp BKB Edit)",artist="BBYA Underground",map="UNDERGROUND"},
 {id=109573287368195,title="06. ARIA PIL KB (EANN BKB EDIT)",artist="BBYA Underground",map="UNDERGROUND"},
 {id=105712830643792,title="TOR MONITOR KETUA - QMUNK AMSTRONG",artist="BBYA Underground",map="UNDERGROUND"},
 {id=81832495836167,title="SIK ASIK - Mail Alektra (BKB EDIT)",artist="BBYA Underground",map="UNDERGROUND"},
 {id=117476404561871,title="SEDIA AKU SEBELUM HUJAN - QMUNK AMSTRONG",artist="BBYA Underground",map="UNDERGROUND"},
 {id=139454814636865,title="POK ANI ANI - DJ VINNIE PARGOY, BILLIE KOPLO",artist="BBYA Underground",map="UNDERGROUND"},
 {id=94631926635772,title="PICA PICA 2 - ARIEF RASIT (BKB EDIT)",artist="BBYA Underground",map="UNDERGROUND"},
 {id=99942691456392,title="pararam-bkb-ipan-agstyan",artist="BBYA Underground",map="UNDERGROUND"},
 {id=103410156771684,title="Om Abidin - Ani Ani (Club Mix)",artist="BBYA Underground",map="UNDERGROUND"},
 {id=106769175117849,title="Ni De Wan Shui Qian Shan - Aldy alvaro, DJ U",artist="BBYA Underground",map="UNDERGROUND"},
 {id=90741742310621,title="Ni De Da An - Aldy alvaro",artist="BBYA Underground",map="UNDERGROUND"},
 {id=117103573334654,title="NGAPAIN REPOT (RAYEN BKB EDIT)",artist="BBYA Underground",map="UNDERGROUND"},
 {id=105840679569825,title="NGAPAIN REPOT (DEKA EDIT)",artist="BBYA Underground",map="UNDERGROUND"},
 {id=106277277729828,title="Ngapain Repot (Aldy Alvaro BKB edit)",artist="BBYA Underground",map="UNDERGROUND"},
 {id=97696234195316,title="MORENA BKB (HARLY EDIT)",artist="BBYA Underground",map="UNDERGROUND"},
 {id=131463436495955,title="I LOVE IT - KIN EDIT",artist="BBYA Underground",map="UNDERGROUND"},
 {id=90545257553901,title="Jar of Hearts - Noka AxL Breakbeat Remix",artist="BBYA Underground",map="UNDERGROUND"},
 {id=133306911098734,title="YOU DON'T EVEN KNOW ME STADIUM BREAKBEAT",artist="BBYA Underground",map="UNDERGROUND"},
 {id=118285103846602,title="MILLION STARS STADIUM BREAKBEAT",artist="BBYA Underground",map="UNDERGROUND"},
 {id=74227363291004,title="DJ TELOOR - WET GUITAR",artist="BBYA Underground",map="UNDERGROUND"},
 {id=82680681349117,title="EE SAKADUNG KADING 2026",artist="BBYA Underground",map="UNDERGROUND"},
 {id=126615725566516,title="BLACK HOLE - DJ TELOOR REMIX",artist="BBYA Underground",map="UNDERGROUND"},
 {id=79441401193706,title="SERANA - FOR REVENGE (DJ Ugi Mekti BKB Edit)",artist="BBYA Underground",map="UNDERGROUND"},
 {id=117092832313612,title="MUTIARA - IYAN.FG",artist="BBYA Underground",map="UNDERGROUND"},
 {id=128141893547516,title="Zinyo Funkytone - Siapa Benar - Garam Cina 2025.mp3",artist="BBYA Funkot",map="FUNKOT"},
 {id=98536948000407,title="Zinyo Funky Tone - Hatiku Bagai Terpenjara 2025.mp3",artist="BBYA Funkot",map="FUNKOT"},
 {id=128567852049551,title="Space Melody '23 - Dj Deri Rmx",artist="BBYA Funkot",map="FUNKOT"},
}
local function parseBpm(title)
 for n in tostring(title):gmatch("%d%d%d") do local bpm=tonumber(n);if bpm and bpm>=80 and bpm<=200 then return bpm end end
 return 0
end
for i,t in ipairs(LIBRARY) do t.index=i;t.bpm=parseBpm(t.title);t.maps={t.map} end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local function remote(className,name)local r=remotes:FindFirstChild(name);if r and not r:IsA(className) then r:Destroy();r=nil end;if not r then r=Instance.new(className);r.Name=name;r.Parent=remotes end;return r end
local action=remote("RemoteEvent","DJLiveAction")
local stateRemote=remote("RemoteEvent","DJLiveState")
local getState=remote("RemoteFunction","DJLiveGetState")
local getLibrary=remote("RemoteFunction","DJLiveGetLibrary")

local engine=SoundService:FindFirstChild("BBYADJLiveCleanEngine")
if engine and not engine:IsA("Folder") then engine:Destroy();engine=nil end
if not engine then engine=Instance.new("Folder");engine.Name="BBYADJLiveCleanEngine";engine.Parent=SoundService end
engine:SetAttribute("Version","DJ_LIVE_CLEAN_V2_2_DJ_PLUS_OWNER_QA")

local function ensureEffect(sound,className,name)
 local e=sound:FindFirstChild(name);if e and e.ClassName~=className then e:Destroy();e=nil end
 if not e then e=Instance.new(className);e.Name=name;e.Parent=sound end;return e
end
local function makeDeck(name)
 local s=engine:FindFirstChild(name);if s and not s:IsA("Sound") then s:Destroy();s=nil end
 if not s then s=Instance.new("Sound");s.Name=name;s.Parent=engine end
 s.Volume=0;s.Looped=false;s.PlaybackSpeed=1
 local fx={}
 fx.ECHO=ensureEffect(s,"EchoSoundEffect","DJLiveEcho");fx.ECHO.Enabled=false;fx.ECHO.Delay=.18;fx.ECHO.Feedback=.38;fx.ECHO.WetLevel=-7
 fx.FILTER=ensureEffect(s,"EqualizerSoundEffect","DJLiveFilter");fx.FILTER.Enabled=false;fx.FILTER.LowGain=2;fx.FILTER.MidGain=-5;fx.FILTER.HighGain=-16
 fx.REVERB=ensureEffect(s,"ReverbSoundEffect","DJLiveReverb");fx.REVERB.Enabled=false;fx.REVERB.DecayTime=1.8;fx.REVERB.WetLevel=-7
 fx.FLANGER=ensureEffect(s,"FlangeSoundEffect","DJLiveFlanger");fx.FLANGER.Enabled=false;fx.FLANGER.Depth=.7;fx.FLANGER.Mix=.55;fx.FLANGER.Rate=.45
 return s,fx
end
local soundA,fxA=makeDeck("DeckA");local soundB,fxB=makeDeck("DeckB")
local function freshDeck()return {trackIndex=0,title="EMPTY",artist="",assetId=0,bpm=0,playing=false,cue=0,loaded=false,fx={ECHO=false,FILTER=false,REVERB=false,FLANGER=false}} end
local S={live=false,map="CLUB",crossfader=.5,operator=nil,operatorUserId=nil,notice="",decks={A=freshDeck(),B=freshDeck()}}
local suppressed={};local lastAction={};local brakeToken={A=0,B=0}

local function isOwnerQA(p)
 if not p then return false end
 local name=string.lower(p.Name)
 return QA_USERNAMES[name]==true or p:GetAttribute("BBYAOwner")==true or (game.CreatorType==Enum.CreatorType.User and p.UserId==game.CreatorId)
end
local function hasManagedDJ(p)return p~=nil and p:GetAttribute("BBYAHasDJRole")==true and p:GetAttribute("BBYAManagedRole")=="DJ" end
local function authorized(p)return isOwnerQA(p) or hasManagedDJ(p) end
local function identity(p)if isOwnerQA(p) then return "OWNER_QA" end;if hasManagedDJ(p) then return "DJ" end;return nil end
local function groupFor(map)local n=VENUE_GROUPS[map];local g=n and SoundService:FindFirstChild(n);return g and g:IsA("SoundGroup") and g or nil end
local function deckObjects(deck)if deck=="A" then return soundA,fxA,S.decks.A elseif deck=="B" then return soundB,fxB,S.decks.B end end
local function autoSources(map)local out={};for _,name in ipairs(AUTO_SOURCES[map] or {}) do local s=SoundService:FindFirstChild(name);if s and s:IsA("Sound") then table.insert(out,s) end end;return out end
local function restoreSources()for s,vol in pairs(suppressed) do if s and s.Parent then s.Volume=vol;s:SetAttribute("BBYADJLiveSuppressed",false) end end;suppressed={} end
local function suppressSources(map)restoreSources();for _,s in ipairs(autoSources(map)) do suppressed[s]=s.Volume;s.Volume=0;s:SetAttribute("BBYADJLiveSuppressed",true) end end
local function enforceSuppression()if not S.live then return end;for _,s in ipairs(autoSources(S.map)) do if suppressed[s]==nil then suppressed[s]=s.Volume end;s.Volume=0;s:SetAttribute("BBYADJLiveSuppressed",true) end end
local function restoreAutoDefaults(map)
 for _,s in ipairs(autoSources(map)) do s:SetAttribute("BBYADJLiveSuppressed",false);if map=="CLUB" or map=="UNDERGROUND" then s.Volume=(s:GetAttribute("DeckRole")=="LIVE") and 1 or 0 elseif map=="VIP" then s.Volume=.72 elseif map=="FUNKOT" then s.Volume=.92 end end
end
local function routeDecks()local g=groupFor(S.map);if not g then return false end;soundA.SoundGroup=g;soundB.SoundGroup=g;engine:SetAttribute("Map",S.map);engine:SetAttribute("Live",S.live);return true end
local function applyFx(deck)local _,fx,d=deckObjects(deck);if d then for name,e in pairs(fx) do e.Enabled=d.fx[name]==true end end end
local function applyMix()local x=math.clamp(tonumber(S.crossfader) or .5,0,1);soundA.Volume=S.live and math.cos(x*math.pi*.5) or 0;soundB.Volume=S.live and math.sin(x*math.pi*.5) or 0;applyFx("A");applyFx("B") end
local function syncPlayingFlags()S.decks.A.playing=soundA.Playing;S.decks.B.playing=soundB.Playing end
local function snapshot()syncPlayingFlags();return {authorized=true,version="DJ_LIVE_CLEAN_V2_2",live=S.live,map=S.map,crossfader=S.crossfader,operator=S.operator,notice=S.notice,decks=S.decks} end
local function broadcast(notice)
 if notice~=nil then S.notice=tostring(notice) end
 local snap=snapshot();for _,p in ipairs(Players:GetPlayers()) do if authorized(p) then stateRemote:FireClient(p,snap) end end
end
local function stopLive(notice)
 if not S.live then return end
 local old=S.map;S.live=false;S.operator=nil;S.operatorUserId=nil;restoreSources();restoreAutoDefaults(old);soundA:Pause();soundB:Pause();applyMix();broadcast(notice or "DJ LIVE STOP")
end

local function loadTrack(deck,index)
 local sound,_,d=deckObjects(deck);local t=LIBRARY[tonumber(index) or 0]
 if not sound or not d or not t then return false end
 sound:Stop();sound.TimePosition=0;sound.PlaybackSpeed=1;sound.SoundId="rbxassetid://"..tostring(t.id)
 d.trackIndex=t.index;d.title=t.title;d.artist=t.artist;d.assetId=t.id;d.bpm=t.bpm;d.cue=0;d.loaded=false;d.playing=false
 task.spawn(function()local ok=pcall(function()ContentProvider:PreloadAsync({sound})end);if d.trackIndex==t.index then d.loaded=ok;broadcast(ok and ("Loaded Deck "..deck..": "..t.title) or ("Load failed Deck "..deck)) end end)
 return true
end
local function playToggle(deck)local sound,_,d=deckObjects(deck);if not sound or not d or d.assetId<1 then return end;if sound.Playing then sound:Pause() else pcall(function()sound:Play()end) end;syncPlayingFlags() end
local function cue(deck)local sound,_,d=deckObjects(deck);if not sound or not d or d.assetId<1 then return end;if sound.Playing then sound:Pause() end;pcall(function()sound.TimePosition=math.max(0,d.cue or 0)end);syncPlayingFlags() end
local function syncDeck(deck)
 local target,_,td=deckObjects(deck);local source,_,sd=deckObjects(deck=="A" and "B" or "A");if not target or not source or not td or not sd or td.assetId<1 or sd.assetId<1 then return end
 if td.bpm>0 and sd.bpm>0 then target.PlaybackSpeed=math.clamp(sd.bpm/td.bpm,.75,1.25) else target.PlaybackSpeed=source.PlaybackSpeed end
 if source.Playing then local phase=source.TimePosition%2;pcall(function()target.TimePosition=math.max(0,math.floor(target.TimePosition/2)*2+phase)end) end
end
local function toggleFx(deck,name)name=string.upper(tostring(name or ""));local _,_,d=deckObjects(deck);if d and d.fx[name]~=nil then d.fx[name]=not d.fx[name];applyFx(deck) end end
local function brake(deck)
 local sound,_,d=deckObjects(deck);if not sound or not d or d.assetId<1 then return end;brakeToken[deck]+=1;local token=brakeToken[deck];local start=math.max(.8,sound.PlaybackSpeed)
 task.spawn(function()for i=1,12 do if brakeToken[deck]~=token then return end;sound.PlaybackSpeed=math.max(.08,start*(1-i/13));task.wait(.045) end;if brakeToken[deck]==token then sound:Pause();sound.PlaybackSpeed=1;syncPlayingFlags();broadcast("BRAKE • DECK "..deck) end end)
end
local function normalized(v)return string.upper(tostring(v or "")):gsub("[^A-Z0-9]","") end
local function findExistingSample(name)
 local wanted=normalized(name);for _,root in ipairs({SoundService,ReplicatedStorage}) do for _,d in ipairs(root:GetDescendants()) do if d:IsA("Sound") and d~=soundA and d~=soundB and (normalized(d.Name)==wanted or normalized(d:GetAttribute("BBYASFXName"))==wanted) then return d end end end
end
local function triggerSample(deck,name)
 name=string.upper(tostring(name or ""));local source=findExistingSample(name)
 if source and source.SoundId~="" then local clone=Instance.new("Sound");clone.Name="DJLiveSample_"..name;clone.SoundId=source.SoundId;clone.Volume=source.Volume>0 and source.Volume or 1;clone.PlaybackSpeed=source.PlaybackSpeed;clone.SoundGroup=groupFor(S.map);clone.Parent=engine;clone.Ended:Connect(function()if clone.Parent then clone:Destroy() end end);Debris:AddItem(clone,20);pcall(function()clone:Play()end);broadcast(name.." • DECK "..deck);return end
 if name=="BRAKE" then brake(deck);return end;broadcast(name.." sample belum tersedia di BBYA SFX authority")
end
local function setMap(map)
 map=string.upper(tostring(map or ""));if not VENUE_GROUPS[map] then return false end;if not groupFor(map) then broadcast("Audio master "..map.." belum tersedia");return false end
 if S.live then local old=S.map;restoreSources();restoreAutoDefaults(old);S.map=map;suppressSources(map) else S.map=map end;routeDecks();applyMix();return true
end
local function liveStart(player)
 if S.live or not authorized(player) then return end;if not routeDecks() then broadcast("Venue master belum siap");return end
 S.live=true;S.operator=identity(player);S.operatorUserId=player.UserId;suppressSources(S.map);applyMix();broadcast("DJ LIVE START • "..S.map)
end
local function handle(player,kind,payload)
 if not authorized(player) then return end
 local now=os.clock();if now-(lastAction[player] or 0)<.035 then return end;lastAction[player]=now
 kind=string.lower(tostring(kind or ""));payload=type(payload)=="table" and payload or {};local deck=string.upper(tostring(payload.deck or ""))
 if kind=="load" then loadTrack(deck,payload.index) elseif kind=="play_toggle" then playToggle(deck) elseif kind=="cue" then cue(deck) elseif kind=="sync" then syncDeck(deck) elseif kind=="crossfader" then S.crossfader=math.clamp(tonumber(payload.value) or .5,0,1);applyMix() elseif kind=="fx_toggle" then toggleFx(deck,payload.fx) elseif kind=="sample" then triggerSample(deck,payload.fx) elseif kind=="map" then setMap(payload.value) elseif kind=="live_start" then liveStart(player) elseif kind=="live_stop" and S.operatorUserId==player.UserId then stopLive() else return end
 broadcast()
end
action.OnServerEvent:Connect(handle)
getState.OnServerInvoke=function(player)if not authorized(player) then return {authorized=false} end;return snapshot() end
getLibrary.OnServerInvoke=function(player)if not authorized(player) then return {} end;return LIBRARY end

local function applyAuth(p)
 local ok=authorized(p);local id=identity(p);p:SetAttribute("BBYADJLiveAuthorized",ok);p:SetAttribute("BBYADJLiveIdentity",id or "")
 if S.live and S.operatorUserId==p.UserId and not ok then stopLive("DJ LIVE STOP • authorization removed") end
end
local function bindPlayer(p)
 applyAuth(p)
 p:GetAttributeChangedSignal("BBYAHasDJRole"):Connect(function()applyAuth(p)end)
 p:GetAttributeChangedSignal("BBYAManagedRole"):Connect(function()applyAuth(p)end)
 p:GetAttributeChangedSignal("BBYAOwner"):Connect(function()applyAuth(p)end)
end
for _,p in ipairs(Players:GetPlayers()) do bindPlayer(p) end
Players.PlayerAdded:Connect(bindPlayer)
Players.PlayerRemoving:Connect(function(p)lastAction[p]=nil;if S.live and S.operatorUserId==p.UserId then stopLive("DJ LIVE STOP • operator left") end end)
soundA.Ended:Connect(function()syncPlayingFlags();broadcast()end);soundB.Ended:Connect(function()syncPlayingFlags();broadcast()end)
task.spawn(function()while task.wait(.10) do if S.live then enforceSuppression();applyMix() end end end)
task.spawn(function()while task.wait(.40) do if S.live or soundA.Playing or soundB.Playing then broadcast() end end end)
game:BindToClose(function()restoreSources();restoreAutoDefaults(S.map)end)
routeDecks();applyMix()
print("[BBYA] DJ LIVE CLEAN ENGINE v2.2 online: managed DJ role + explicit owner/QA route / no public access")