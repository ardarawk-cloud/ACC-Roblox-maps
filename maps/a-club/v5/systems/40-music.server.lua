-- [SYS-MUSIC] BBYA V5 HYBRID AUTO-DJ
local SoundService=game:GetService("SoundService")
local rng=Random.new(math.floor(os.clock()*100000)+game.JobId:len()*997)
local QUEUE={
 {id=85427648559465,title="DJ Phut Hon Indo Full Bass",genre="INDO",sub="BREAKBEAT"},
 {id=100787734732008,title="Aku Suka Jedag Jedug Full Bass",genre="INDO",sub="BREAKBEAT"},
 {id=110691393637838,title="DJ Bahagiamu Sayang Funkot",genre="INDO",sub="FUNKOT"},
 {id=101399039672234,title="DNA INDO BOUNCE",genre="INDO",sub="INDO_BOUNCE"},
 {id=128622207855102,title="DJ Breakbeat Stadium Jakarta",genre="INDO",sub="STADIUM"},
 {id=85229747030713,title="DJ Dumes Remix Koplo",genre="INDO",sub="KOPLO"},
 {id=87585997282125,title="Koplo Persatuan Kampungku",genre="INDO",sub="KOPLO"},
 {id=9040442826,title="Pumpin And Bumpin D",genre="INTL",sub="BASS_HOUSE"},
 {id=9045072146,title="Struck Down D",genre="INTL",sub="PSYTRANCE"},
 {id=1839246840,title="Fast Rave",genre="INTL",sub="TECHNO"},
 {id=9047436030,title="Ipanema House Beach",genre="INTL",sub="TROPICAL_HOUSE"},
 {id=7023598688,title="Bad Computer - Clarity",genre="INTL",sub="HOUSE"},
 {id=7023749823,title="Eskai - Mimi",genre="INTL",sub="PROGRESSIVE_HOUSE"},
 {id=5410085763,title="Tokyo Machine - PLAY",genre="INTL",sub="ELECTRO_HOUSE"},
 {id=5409360995,title="Dion Timmer - Shiawase",genre="INTL",sub="ELECTRONIC"},
 {id=7028977687,title="Stonebank - What Are You Waiting For",genre="INTL",sub="EDM"},
 {id=9042927806,title="We Want Disco",genre="INTL",sub="DISCO"},
 {id=133054925243074,title="Time Chasing",genre="INTL",sub="DNB"},
 {id=134324160901088,title="Fast Drum & Bass Action Soundtrack",genre="INTL",sub="DNB"},
}
local sound=SoundService:FindFirstChild("BBYA_V5_MainMusic") or Instance.new("Sound");sound.Name="BBYA_V5_MainMusic";sound.Volume=.58;sound.Looped=false;sound.Parent=SoundService
local mode="ALL";local list={};local idx=0;local bad={};local current=nil;local manualDJ=nil;local token=0
local function occupied() return #Players:GetPlayers()>0 end
local function shuffle(t) for i=#t,2,-1 do local j=rng:NextInteger(1,i);t[i],t[j]=t[j],t[i] end end
local function rebuild(filter)
 mode=filter or mode;list={}
 for _,t in ipairs(QUEUE) do if not bad[t.id] and (mode=="ALL" or mode==t.genre or mode==t.sub) then table.insert(list,t) end end
 shuffle(list);idx=0
end
local function publish(err)
 local dj="AUTO-DJ";if manualDJ then local p=Players:GetPlayerByUserId(manualDJ);dj=p and p.DisplayName or "AUTO-DJ" end
 workspace:SetAttribute("BBYANowPlaying",current and current.title or "BBYA 24/7");workspace:SetAttribute("BBYAMusicMode",mode);workspace:SetAttribute("BBYAMusicSubgenre",current and current.sub or "");workspace:SetAttribute("BBYACurrentDJ",dj);workspace:SetAttribute("BBYAMusicError",err or "")
 MusicState:FireAllClients({title=current and current.title or "BBYA 24/7",genre=current and current.genre or "",sub=current and current.sub or "",mode=mode,volume=sound.Volume,playing=sound.Playing,dj=dj,error=err or ""})
end
local nextTrack
local function playTrack(t)
 token+=1;local mine=token;current=t;sound:Stop();sound.SoundId="rbxassetid://"..t.id;sound.TimePosition=0;sound:Play();publish("")
 task.delay(5,function() if mine~=token or current~=t or not occupied() then return end;if not (sound.IsLoaded and sound.TimeLength>0 and (sound.Playing or sound.TimePosition>0)) then bad[t.id]=true;sound:Stop();current=nil;publish("SKIP UNAVAILABLE");task.delay(.2,nextTrack) end end)
end
nextTrack=function()
 if not occupied() then sound:Stop();current=nil;publish("WAITING FOR PLAYERS");return end
 if #list==0 or idx>=#list then rebuild(mode) end;if #list==0 then publish("NO PLAYABLE AUDIO");return end
 idx+=1;playTrack(list[idx])
end
sound.Ended:Connect(function() if occupied() then task.delay(.15,nextTrack) end end)
local function canDJ(p)
 if p.UserId==QUEEN_ID or p:GetAttribute("BBYARole")=="DJ" or p:GetAttribute("BBYAAllAccess")==true then return true end
 local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart");if not hrp then return false end
 local mainBooth=workspace:FindFirstChild("A4 | DJ BOOTH BODY",true)
 local poolBooth=workspace:FindFirstChild("D2 | POOL DJ CONSOLE",true)
 local nearMain=mainBooth and (hrp.Position-mainBooth.Position).Magnitude<=18
 local nearPool=poolBooth and (hrp.Position-poolBooth.Position).Magnitude<=18
 return nearMain or nearPool or false
end
MusicRemote.OnServerEvent:Connect(function(p,action,value)
 if not canDJ(p) then NoticeRemote:FireClient(p,"Stand at the A4 or D2 DJ booth to take control");return end
 action=string.upper(tostring(action or ""));manualDJ=p.UserId
 if action=="NEXT" then token+=1;nextTrack()
 elseif action=="PAUSE" then sound:Pause();publish("")
 elseif action=="PLAY" then if current then sound:Resume();publish("") else nextTrack() end
 elseif action=="VOLUME" then sound.Volume=math.clamp(tonumber(value) or .58,0,1);publish("")
 elseif action=="MODE" then local m=string.upper(tostring(value or "ALL"));if m=="ALL" or m=="INDO" or m=="INTL" then token+=1;bad={};rebuild(m);nextTrack() end
 elseif action=="SUBGENRE" then local m=string.upper(tostring(value or "ALL"));token+=1;rebuild(m);nextTrack() end
end)
Players.PlayerAdded:Connect(function() task.delay(1,function() if occupied() and not sound.Playing then manualDJ=nil;rebuild(mode);nextTrack() end end) end)
Players.PlayerRemoving:Connect(function(p) if manualDJ==p.UserId then manualDJ=nil end end)
rebuild("ALL");if occupied() then task.delay(1,nextTrack) else publish("WAITING FOR PLAYERS") end
workspace:SetAttribute("BBYASystemMusic","5.1")
