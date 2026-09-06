-- BBYA SOCIAL HUB — MUSIC PLAYER v3 COMPACT REFERENCE
-- Single visual authority. Runtime QC lock: compact music-player form, no large sidebar/dashboard.
-- Default page is NOW PLAYING with square artwork, waveform/progress, core controls and short UP NEXT list.
-- TRACKS / QUEUE / FAVORITES remain available as small internal tabs. Server audio authorities are unchanged.

local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local SS=game:GetService("SoundService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local clubGui=pg:WaitForChild("BBYAClubUI",30);if not clubGui then return end
local hub=clubGui:WaitForChild("HubPanel",30);if not hub then return end
local remotes=RS:WaitForChild("BBYAClubRemotes",30);if not remotes then return end
local music=remotes:WaitForChild("Music",30)
local stateRemote=remotes:WaitForChild("State",30)
local mallControl=RS:FindFirstChild("BBYAMallMusicControl")

local C={
 bg=Color3.fromRGB(8,9,13),panel=Color3.fromRGB(18,19,25),card=Color3.fromRGB(27,28,36),card2=Color3.fromRGB(35,36,46),
 white=Color3.fromRGB(247,247,250),muted=Color3.fromRGB(148,151,164),line=Color3.fromRGB(73,76,89),
 purple=Color3.fromRGB(145,84,255),pink=Color3.fromRGB(236,53,165),cyan=Color3.fromRGB(43,198,226),green=Color3.fromRGB(79,216,145),gold=Color3.fromRGB(232,183,86)
}
local V={
 MAIN={label="MAIN CLUB",short="CLUB",accent=C.pink,group="BBYAClubMaster"},UNDERGROUND={label="UNDERGROUND",short="UG",accent=C.cyan,group="BBYABasementMaster"},
 VIP={label="VIP",short="VIP",accent=C.gold,group="BBYAVIPMaster"},FUNKOT={label="FUNKOT",short="FKT",accent=C.purple,group="BBYAFunkotMaster"},
 SKATEPARK={label="SKATEPARK",short="SK8",accent=C.cyan,group="BBYASkateparkMaster"},ROOFTOP={label="ROOFTOP",short="ROOF",accent=C.gold,group="BBYARooftopMaster"},
 MALL={label="MALL",short="MALL",accent=C.gold,group="BBYAMallMaster"},NONE={label="BBYA MUSIC",short="BBYA",accent=C.purple}
}
local SPECIAL={FUNKOT=true,VIP=true,SKATEPARK=true,ROOFTOP=true}

local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o;return c end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col or C.line;s.Thickness=1;s.Transparency=tr or .55;s.Parent=o;return s end
local function label(p,n,t,pos,size,font,ts,col,align)
 local x=Instance.new("TextLabel");x.Name=n;x.BackgroundTransparency=1;x.Text=t;x.Position=pos;x.Size=size;x.Font=font or Enum.Font.Gotham;x.TextSize=ts or 9;x.TextColor3=col or C.white;x.TextXAlignment=align or Enum.TextXAlignment.Left;x.TextYAlignment=Enum.TextYAlignment.Center;x.TextTruncate=Enum.TextTruncate.AtEnd;x.Parent=p;return x
end
local function btn(p,n,t,pos,size,bg)
 local b=Instance.new("TextButton");b.Name=n;b.Text=t;b.Position=pos or UDim2.new();b.Size=size or UDim2.new();b.BackgroundColor3=bg or C.card;b.BackgroundTransparency=.12;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=8;b.AutoButtonColor=true;b.Parent=p;corner(b,8);stroke(b,C.line,.62);return b
end
local function frame(p,n,pos,size,bg,tr,r)
 local f=Instance.new("Frame");f.Name=n;f.Position=pos or UDim2.new();f.Size=size or UDim2.new();f.BackgroundColor3=bg or C.panel;f.BackgroundTransparency=tr or .18;f.BorderSizePixel=0;f.Parent=p;if r then corner(f,r) end;return f
end
local function venueAt(p)
 if p.Y<-4.5 then return "UNDERGROUND" end
 if p.Y>=40 and p.Y<=60 and math.abs(p.X)<=62 and p.Z>=-48 and p.Z<=48 then return "ROOFTOP" end
 if p.Y>=20 and p.Y<40 and math.abs(p.X)<=58 and p.Z>=-46 and p.Z<=46 then return "VIP" end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return "FUNKOT" end
 if p.Y>-4 and p.Y<20 and math.abs(p.X)<=61 and p.Z>=72 and p.Z<=152 then return "SKATEPARK" end
 if p.Y>=-4 and p.Y<=70 and p.X>=-96 and p.X<=96 and p.Z>=287 and p.Z<=443 then return "MALL" end
 if p.Y>-4 and p.Y<18 and math.abs(p.X)<=61 and p.Z>=0 and p.Z<70 then return "MAIN" end
 return "NONE"
end
local function venue()
 local v=tostring(player:GetAttribute("BBYAAudioVenue") or "");if v=="BASEMENT" then v="UNDERGROUND" end;if V[v] then return v end
 local ch=player.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart");return hrp and venueAt(hrp.Position) or "NONE"
end
local function isAdmin()return player:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)end

local legacyCard=hub:FindFirstChild("PlayerCard",true);local legacy=legacyCard and legacyCard.Parent;if legacy then legacy.Visible=false end
local old=pg:FindFirstChild("BBYAMusicSuiteV1");if old then old:Destroy() end
local compact=clubGui:FindFirstChild("BBYACompactMusicLayerV7");if compact then compact:Destroy() end

local gui=Instance.new("ScreenGui");gui.Name="BBYAMusicSuiteV1";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=930;gui.Enabled=false;gui.Parent=pg
gui:SetAttribute("BBYAUIAuthority","MUSIC_PLAYER_V3_COMPACT_REFERENCE")
local backdrop=frame(gui,"Backdrop",UDim2.new(),UDim2.fromScale(1,1),Color3.new(0,0,0),1)
local shell=frame(backdrop,"Shell",UDim2.fromScale(.5,.5),UDim2.fromOffset(520,350),C.bg,.16,16);shell.AnchorPoint=Vector2.new(.5,.5);local shellStroke=stroke(shell,C.purple,.24)

local header=frame(shell,"Header",UDim2.fromOffset(12,10),UDim2.new(1,-24,0,40),C.panel,.25,10)
local venuePill=frame(header,"VenuePill",UDim2.fromOffset(8,7),UDim2.fromOffset(82,26),C.card,.08,8);local venueStroke=stroke(venuePill,C.purple,.35)
local venueGlyph=label(venuePill,"VenueGlyph","BBYA",UDim2.new(),UDim2.fromScale(1,1),Enum.Font.GothamBlack,9,C.white,Enum.TextXAlignment.Center)
local headerTitle=label(header,"Title","NOW PLAYING",UDim2.fromOffset(100,4),UDim2.new(1,-146,0,18),Enum.Font.GothamBlack,13,C.white)
local headerSub=label(header,"Sub","BBYA MUSIC",UDim2.fromOffset(100,21),UDim2.new(1,-146,0,14),Enum.Font.GothamBold,7,C.muted)
local close=btn(header,"Close","×",UDim2.new(1,-34,0,5),UDim2.fromOffset(30,30),C.card2);close.TextSize=17

local tabs=frame(shell,"Tabs",UDim2.fromOffset(12,57),UDim2.new(1,-24,0,30),C.bg,1)
local tabKeys={"NOW","TRACKS","QUEUE","FAVORITES"};local tabText={NOW="NOW",TRACKS="TRACKS",QUEUE="QUEUE",FAVORITES="♥"};local tabButtons={}
for i,k in ipairs(tabKeys)do local b=btn(tabs,"Tab"..k,tabText[k],UDim2.new((i-1)/4,0,0,0),UDim2.new(.25,-4,1,0),C.card);b.TextSize=8;tabButtons[k]=b end

local pages={}
local function page(n)local p=frame(shell,n,UDim2.fromOffset(12,94),UDim2.new(1,-24,1,-106),C.bg,1);p.Visible=false;pages[n]=p;return p end
local now=page("NOW");local tracks=page("TRACKS");local queue=page("QUEUE");local favoritesPage=page("FAVORITES")

-- NOW PLAYING reference layout: artwork hero + current info + short UP NEXT.
local art=frame(now,"Artwork",UDim2.fromOffset(0,0),UDim2.fromOffset(132,132),Color3.fromRGB(39,24,56),.03,13);stroke(art,C.purple,.55)
local grad=Instance.new("UIGradient");grad.Color=ColorSequence.new(Color3.fromRGB(92,44,129),Color3.fromRGB(16,17,23));grad.Rotation=135;grad.Parent=art
local artGlyph=label(art,"Glyph","BBYA",UDim2.fromOffset(8,34),UDim2.new(1,-16,0,34),Enum.Font.GothamBlack,23,C.white,Enum.TextXAlignment.Center)
local artVenue=label(art,"Venue","BBYA MUSIC",UDim2.fromOffset(8,72),UDim2.new(1,-16,0,20),Enum.Font.GothamBold,8,C.cyan,Enum.TextXAlignment.Center)
label(art,"Hint","NOW PLAYING",UDim2.fromOffset(8,98),UDim2.new(1,-16,0,18),Enum.Font.GothamBold,6,C.muted,Enum.TextXAlignment.Center)

local info=frame(now,"CurrentInfo",UDim2.fromOffset(144,0),UDim2.new(1,-144,0,132),C.panel,.24,12);stroke(info,C.line,.68)
local nowState=label(info,"State","STANDBY",UDim2.fromOffset(12,8),UDim2.new(1,-24,0,16),Enum.Font.GothamBold,7,C.green)
local nowTitle=label(info,"Track","BELUM ADA LAGU",UDim2.fromOffset(12,26),UDim2.new(1,-24,0,34),Enum.Font.GothamBlack,12,C.white);nowTitle.TextWrapped=true;nowTitle.TextYAlignment=Enum.TextYAlignment.Top
local nowMeta=label(info,"Meta","BBYA MUSIC",UDim2.fromOffset(12,60),UDim2.new(1,-24,0,16),Enum.Font.GothamBold,7,C.muted)
local wave=frame(info,"Wave",UDim2.fromOffset(12,80),UDim2.new(1,-24,0,22),C.panel,1);local bars={}
for i=1,16 do local b=frame(wave,"Bar"..i,UDim2.new((i-.5)/16,0,1,0),UDim2.new(.035,0,0,3),i%5==0 and C.cyan or C.purple,0,3);b.AnchorPoint=Vector2.new(.5,1);bars[i]=b end
local progress=frame(info,"Progress",UDim2.fromOffset(12,106),UDim2.new(1,-24,0,4),C.card2,0,4);local progressFill=frame(progress,"Fill",UDim2.new(),UDim2.new(0,0,1,0),C.purple,0,4)
local elapsed=label(info,"Elapsed","00:00",UDim2.fromOffset(12,112),UDim2.fromOffset(60,14),Enum.Font.GothamBold,6,C.muted)
local duration=label(info,"Duration","00:00",UDim2.new(1,-72,0,112),UDim2.fromOffset(60,14),Enum.Font.GothamBold,6,C.muted,Enum.TextXAlignment.Right)

local controls=frame(now,"Controls",UDim2.fromOffset(0,142),UDim2.new(1,0,0,34),C.bg,1)
local prev=btn(controls,"Prev","PREV",UDim2.new(0,0,0,0),UDim2.new(.22,-3,1,0),C.card2)
local mute=btn(controls,"Mute","MUTE",UDim2.new(.22,3,0,0),UDim2.new(.56,-6,1,0),C.card2)
local nextB=btn(controls,"Next","NEXT",UDim2.new(.78,3,0,0),UDim2.new(.22,-3,1,0),Color3.fromRGB(58,34,92))

local up=frame(now,"UpNext",UDim2.fromOffset(0,184),UDim2.new(1,0,1,-184),C.panel,.26,11);stroke(up,C.line,.65)
label(up,"Title","UP NEXT",UDim2.fromOffset(10,4),UDim2.new(1,-20,0,18),Enum.Font.GothamBlack,9,C.white)
local upList=Instance.new("ScrollingFrame");upList.Name="UpNextList";upList.Position=UDim2.fromOffset(8,24);upList.Size=UDim2.new(1,-16,1,-30);upList.BackgroundTransparency=1;upList.BorderSizePixel=0;upList.ScrollBarThickness=2;upList.AutomaticCanvasSize=Enum.AutomaticSize.Y;upList.CanvasSize=UDim2.new();upList.Parent=up
local ul=Instance.new("UIListLayout");ul.Padding=UDim.new(0,4);ul.Parent=upList

-- TRACKS page: compact search only when user explicitly opens TRACKS.
local search=Instance.new("TextBox");search.Name="Search";search.Position=UDim2.fromOffset(0,0);search.Size=UDim2.new(1,0,0,30);search.BackgroundColor3=C.card;search.BackgroundTransparency=.12;search.BorderSizePixel=0;search.PlaceholderText="Search tracks...";search.PlaceholderColor3=C.muted;search.Text="";search.TextColor3=C.white;search.Font=Enum.Font.Gotham;search.TextSize=9;search.TextXAlignment=Enum.TextXAlignment.Left;search.ClearTextOnFocus=false;search.Parent=tracks;corner(search,8);stroke(search,C.line,.58)
local sp=Instance.new("UIPadding");sp.PaddingLeft=UDim.new(0,10);sp.PaddingRight=UDim.new(0,10);sp.Parent=search
local trackMeta=label(tracks,"Meta","0 TRACKS",UDim2.new(.55,0,0,32),UDim2.new(.45,0,0,16),Enum.Font.GothamBold,6,C.muted,Enum.TextXAlignment.Right)
local trackList=Instance.new("ScrollingFrame");trackList.Name="TrackList";trackList.Position=UDim2.fromOffset(0,50);trackList.Size=UDim2.new(1,0,1,-50);trackList.BackgroundColor3=C.panel;trackList.BackgroundTransparency=.28;trackList.BorderSizePixel=0;trackList.ScrollBarThickness=3;trackList.AutomaticCanvasSize=Enum.AutomaticSize.Y;trackList.CanvasSize=UDim2.new();trackList.Parent=tracks;corner(trackList,10);stroke(trackList,C.line,.68)
local tl=Instance.new("UIListLayout");tl.Padding=UDim.new(0,4);tl.Parent=trackList;local tp=Instance.new("UIPadding");tp.PaddingTop=UDim.new(0,5);tp.PaddingBottom=UDim.new(0,5);tp.PaddingLeft=UDim.new(0,5);tp.PaddingRight=UDim.new(0,5);tp.Parent=trackList

local queueMeta=label(queue,"Meta","0 REQUESTS",UDim2.new(.55,0,0,0),UDim2.new(.45,0,0,18),Enum.Font.GothamBold,6,C.muted,Enum.TextXAlignment.Right)
local qList=Instance.new("ScrollingFrame");qList.Position=UDim2.fromOffset(0,24);qList.Size=UDim2.new(1,0,1,-24);qList.BackgroundColor3=C.panel;qList.BackgroundTransparency=.28;qList.BorderSizePixel=0;qList.ScrollBarThickness=3;qList.AutomaticCanvasSize=Enum.AutomaticSize.Y;qList.CanvasSize=UDim2.new();qList.Parent=queue;corner(qList,10);stroke(qList,C.line,.68)
local ql=Instance.new("UIListLayout");ql.Padding=UDim.new(0,4);ql.Parent=qList

local favMeta=label(favoritesPage,"Meta","SESSION FAVORITES",UDim2.fromOffset(0,0),UDim2.new(1,0,0,18),Enum.Font.GothamBold,7,C.pink)
local favList=Instance.new("ScrollingFrame");favList.Position=UDim2.fromOffset(0,24);favList.Size=UDim2.new(1,0,1,-24);favList.BackgroundColor3=C.panel;favList.BackgroundTransparency=.28;favList.BorderSizePixel=0;favList.ScrollBarThickness=3;favList.AutomaticCanvasSize=Enum.AutomaticSize.Y;favList.CanvasSize=UDim2.new();favList.Parent=favoritesPage;corner(favList,10);stroke(favList,C.line,.68)
local fl=Instance.new("UIListLayout");fl.Padding=UDim.new(0,4);fl.Parent=favList

local S={tracks={},title="",index=0,playing=false,queue=0,nextRequest=0,autoNext=0}
local favorites={}
local function clear(p,prefix)for _,x in ipairs(p:GetChildren())do if x.Name:sub(1,#prefix)==prefix then x:Destroy()end end end
local function row(p,n,no,titleText,meta,col,height)
 local r=frame(p,n,nil,UDim2.new(1,-2,0,height or 34),C.card,.12,7)
 local badge=frame(r,"Badge",UDim2.fromOffset(5,5),UDim2.fromOffset((height or 34)-10,(height or 34)-10),Color3.fromRGB(43,31,57),.06,6);label(badge,"N",tostring(no),UDim2.new(),UDim2.fromScale(1,1),Enum.Font.GothamBlack,7,col or C.purple,Enum.TextXAlignment.Center)
 label(r,"T",titleText,UDim2.fromOffset((height or 34),2),UDim2.new(1,-((height or 34)+8),0,16),Enum.Font.GothamBold,8,C.white)
 label(r,"M",meta,UDim2.fromOffset((height or 34),17),UDim2.new(1,-((height or 34)+8),0,13),Enum.Font.GothamBold,6,C.muted);return r
end
local function mallTracks()
 local folder=RS:FindFirstChild("BBYAMallPlaylistCatalog");if not folder then return{}end;local indexed={}
 for _,r in ipairs(folder:GetChildren())do if r:IsA("StringValue")then local i=tonumber(r:GetAttribute("Index"));if i then indexed[i]={title=r.Value,assetId=tostring(r:GetAttribute("AssetId")or""),style="KPOP • RANDOM MIX"}end end end
 local out={};for i=1,#indexed do if indexed[i]then table.insert(out,indexed[i])end end;return out
end
local function syncMall()
 if venue()~="MALL"then return false end;S.tracks=mallTracks();S.index=tonumber(RS:GetAttribute("BBYAMallCurrentIndex"))or 1;S.title=tostring(RS:GetAttribute("BBYAMallCurrentTitle")or"");S.queue=tonumber(RS:GetAttribute("BBYAMallQueueCount"))or 0;S.nextRequest=tonumber(RS:GetAttribute("BBYAMallNextRequestIndex"))or 0;local sound=SS:FindFirstChild("BBYAMallMasterSound");S.playing=sound and sound:IsA("Sound")and sound.IsPlaying or false;return true
end
local function requestList()local v=venue();if v=="MAIN"or v=="UNDERGROUND"then music:FireServer("list")elseif v=="MALL"then syncMall()end end
local function request(i)local v=venue();if v=="MAIN"or v=="UNDERGROUND"then music:FireServer("request",i)elseif v=="MALL"and mallControl then mallControl:FireServer("request",i)end end
local function key(v,i)return tostring(v)..":"..tostring(i)end
local function accent()return(V[venue()]or V.NONE).accent end

local function rebuildFav()
 clear(favList,"Fav_");local items={};for _,it in pairs(favorites)do table.insert(items,it)end;table.sort(items,function(a,b)if a.venue==b.venue then return a.index<b.index end;return a.venue<b.venue end)
 if #items==0 then row(favList,"Fav_Empty","♥","NO FAVORITES YET","Tap ♥ in TRACKS",C.pink,36);return end
 for n,it in ipairs(items)do local r=row(favList,"Fav_"..n,string.format("%02d",it.index),it.title,it.venue.." • "..it.meta,C.pink,38);local rm=btn(r,"Remove","♥",UDim2.new(1,-35,0,5),UDim2.fromOffset(28,28),Color3.fromRGB(55,30,48));rm.TextColor3=C.pink;rm.TextSize=11;rm.Activated:Connect(function()favorites[key(it.venue,it.index)]=nil;rebuildFav()end)end
end
local function rebuildTracks()
 clear(trackList,"Track_");local q=string.lower(search.Text or"");local shown=0;local v=venue();local a=accent()
 if SPECIAL[v]then row(trackList,"Track_Info","♪","VENUE PLAYBACK ACTIVE","Track requests are not exposed here",a,38);trackMeta.Text="VENUE MODE";return end
 for i,it in ipairs(S.tracks)do local titleText=tostring(it.title or("Track "..i));local meta=tostring(it.style or it.genre or"BBYA MUSIC");if q==""or string.find(string.lower(titleText.." "..meta),q,1,true)then shown+=1;local r=row(trackList,"Track_"..i,string.format("%02d",i),titleText,string.upper(meta),a,40);local fav=btn(r,"Fav",favorites[key(v,i)]and"♥"or"♡",UDim2.new(1,-72,0,6),UDim2.fromOffset(28,28),C.card2);fav.TextColor3=favorites[key(v,i)]and C.pink or C.muted;fav.Activated:Connect(function()local k=key(v,i);if favorites[k]then favorites[k]=nil else favorites[k]={venue=v,index=i,title=titleText,meta=meta}end;rebuildTracks();rebuildFav()end);local rq=btn(r,"Req",S.playing and S.index==i and"LIVE"or"REQ",UDim2.new(1,-39,0,6),UDim2.fromOffset(34,28),Color3.fromRGB(54,34,83));rq.TextSize=6;if not(S.playing and S.index==i)then rq.Activated:Connect(function()request(i)end)else rq.Active=false end end end
 trackMeta.Text=string.format("%d / %d TRACKS",shown,#S.tracks)
end
local function rebuildQueue()
 clear(qList,"Queue_");queueMeta.Text=tostring(S.queue or 0).." REQUESTS"
 if(S.queue or 0)==0 then row(qList,"Queue_Empty","--","REQUEST QUEUE EMPTY","Choose a track in TRACKS",C.muted,38);return end
 if(S.nextRequest or 0)>0 and S.tracks[S.nextRequest]then row(qList,"Queue_1","01",tostring(S.tracks[S.nextRequest].title or"Requested track"),"NEXT REQUEST",C.gold,38)end
 if(S.queue or 0)>1 then row(qList,"Queue_More","+",tostring((S.queue or 0)-1).." MORE REQUESTS","SERVER QUEUE",accent(),38)end
end
local function rebuildUp()
 clear(upList,"Next_");if #S.tracks==0 then row(upList,"Next_Empty","--","UP NEXT","Waiting for playlist",C.muted,30);return end
 local used={};local order=0;local first=tonumber(S.nextRequest)or 0;if first>0 and S.tracks[first]then order+=1;used[first]=true;row(upList,"Next_"..order,order,tostring(S.tracks[first].title or"Request"),"REQUEST",C.gold,30)end
 local cur=math.max(S.index or 0,0);while order<3 and order<#S.tracks do cur=(cur%#S.tracks)+1;if not used[cur]then order+=1;used[cur]=true;row(upList,"Next_"..order,order,tostring(S.tracks[cur].title or("Track "..cur)),"AUTO DJ",accent(),30)end end
end
local function refreshChrome()
 local v=venue();local s=V[v]or V.NONE;venueGlyph.Text=s.short;venueStroke.Color=s.accent;shellStroke.Color=s.accent;artVenue.Text=s.label;artVenue.TextColor3=s.accent;headerSub.Text=s.label
end
local function refreshNow()
 local v=venue();local s=V[v]or V.NONE;local t=S.title
 if t==""and S.index>0 and S.tracks[S.index]then t=tostring(S.tracks[S.index].title or"")end
 if SPECIAL[v]and t==""then t="LIVE VENUE AUDIO"end;if t==""then t="BELUM ADA LAGU"end
 nowTitle.Text=t;nowMeta.Text=s.label..(SPECIAL[v]and" • VENUE MODE"or(" • "..tostring(#S.tracks).." TRACKS"));nowState.Text=S.playing and"LIVE • PLAYING"or"STANDBY";nowState.TextColor3=S.playing and C.green or C.muted;mute.Text=player:GetAttribute("BBYAMusicMuted")==true and"UNMUTE"or"MUTE";prev.Visible=isAdmin();nextB.Visible=isAdmin();rebuildUp();rebuildQueue()
end
local function refresh()refreshChrome();rebuildTracks();refreshNow();rebuildFav()end
local function switch(k)
 for n,p in pairs(pages)do p.Visible=n==k end
 for n,b in pairs(tabButtons)do b.BackgroundColor3=n==k and Color3.fromRGB(55,35,82)or C.card;b.TextColor3=n==k and C.white or C.muted end
 headerTitle.Text=(k=="NOW"and"NOW PLAYING")or(k=="TRACKS"and"LIBRARY")or k
 if k=="TRACKS"then rebuildTracks()elseif k=="QUEUE"then rebuildQueue()elseif k=="FAVORITES"then rebuildFav()end
end

local activeSound=nil;local lastSoundScan=0
local function findSound()
 if activeSound and activeSound.Parent and activeSound.IsPlaying then return activeSound end;if os.clock()-lastSoundScan<.5 then return activeSound end;lastSoundScan=os.clock();local v=venue();local info=V[v];if not info or not info.group then activeSound=nil;return nil end
 local group=SS:FindFirstChild(info.group);local known={MAIN={"BBYAClubDeckA","BBYAClubDeckB"},UNDERGROUND={"BBYABasementDeckA","BBYABasementDeckB"},FUNKOT={"BBYAFunkotDeck"},MALL={"BBYAMallMasterSound"},SKATEPARK={"BBYASkateparkMasterSound"},ROOFTOP={"BBYARooftopPlaylist"},VIP={"BBYAVIPPlaylist"}}
 for _,n in ipairs(known[v]or{})do local x=SS:FindFirstChild(n,true)or workspace:FindFirstChild(n,true);if x and x:IsA("Sound")and x.IsPlaying then activeSound=x;return x end end
 for _,rootObj in ipairs({SS,workspace})do for _,x in ipairs(rootObj:GetDescendants())do if x:IsA("Sound")and x.IsPlaying and group and x.SoundGroup==group then activeSound=x;return x end end end;activeSound=nil;return nil
end
local function fmt(sec)sec=math.max(0,math.floor(tonumber(sec)or 0));return string.format("%02d:%02d",math.floor(sec/60),sec%60)end

for k,b in pairs(tabButtons)do b.Activated:Connect(function()switch(k)end)end
search:GetPropertyChangedSignal("Text"):Connect(rebuildTracks)
mute.Activated:Connect(function()player:SetAttribute("BBYAMusicMuted",not(player:GetAttribute("BBYAMusicMuted")==true));refreshNow()end)
prev.Activated:Connect(function()if not isAdmin()then return end;local v=venue();if v=="MALL"and mallControl then mallControl:FireServer("prev")elseif(v=="MAIN"or v=="UNDERGROUND")and #S.tracks>0 then local i=((math.max(S.index,1)-2)%#S.tracks)+1;music:FireServer("play",i)end end)
nextB.Activated:Connect(function()if not isAdmin()then return end;local v=venue();if v=="MALL"and mallControl then mallControl:FireServer("next")elseif v=="MAIN"or v=="UNDERGROUND"then music:FireServer("next")end end)
close.Activated:Connect(function()gui.Enabled=false end)
local function open()if legacy then legacy.Visible=false end;hub.Visible=false;gui.Enabled=true;requestList();refresh();switch("NOW")end

stateRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist"and type(data)=="table"then if venue()~="MALL"and not SPECIAL[venue()]then S.tracks=data end;if gui.Enabled then refresh()end
 elseif kind=="music"and type(data)=="table"then local v=tostring(data.venue or venue());if v=="BASEMENT"then v="UNDERGROUND"end;if v==venue()or venue()=="NONE"then S.index=tonumber(data.index)or S.index;S.title=tostring(data.title or S.title or"");S.playing=data.playing==true;S.queue=tonumber(data.queue)or 0;S.nextRequest=tonumber(data.nextRequest)or 0;activeSound=nil;if gui.Enabled then refresh()end end end
end)
player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()activeSound=nil;if gui.Enabled then requestList();refresh();switch("NOW")end end)
player:GetAttributeChangedSignal("BBYAAdmin"):Connect(function()if gui.Enabled then refreshNow()end end);player:GetAttributeChangedSignal("BBYAMusicMuted"):Connect(function()if gui.Enabled then refreshNow()end end)
for _,attr in ipairs({"BBYAMallPlaylistCount","BBYAMallCurrentIndex","BBYAMallCurrentTitle","BBYAMallCurrentAssetId","BBYAMallQueueCount","BBYAMallNextRequestIndex","BBYAMallAutoNextIndex"})do RS:GetAttributeChangedSignal(attr):Connect(function()if venue()=="MALL"then syncMall();if gui.Enabled then refresh()end end end)end
RS.ChildAdded:Connect(function(child)if child.Name=="BBYAMallMusicControl"then mallControl=child elseif child.Name=="BBYAMallPlaylistCatalog"and venue()=="MALL"then task.defer(function()syncMall();if gui.Enabled then refresh()end end)end end)

local bound={}
local function bind()
 local m=pg:FindFirstChild("BBYACommandMenuUI");local d=m and m:FindFirstChild("FeatureDrawer");local slot=d and d:FindFirstChild("Slot_MUSIC",true);if not slot then return end
 for _,x in ipairs(slot:GetDescendants())do if x:IsA("TextButton")and not bound[x]then bound[x]=true;x.Activated:Connect(function()task.defer(open)end)end end
end
pg.DescendantAdded:Connect(function(obj)if obj.Name=="BBYACommandMenuUI"or obj.Name=="FeatureDrawer"or obj.Name=="Slot_MUSIC"or obj:IsA("TextButton")then task.defer(bind)end end)
if legacy then legacy:GetPropertyChangedSignal("Visible"):Connect(function()if legacy.Visible then task.defer(open)end end)end

local cam=workspace.CurrentCamera
local function layout()
 cam=workspace.CurrentCamera or cam;local vp=cam and cam.ViewportSize or Vector2.new(1280,720);local landscape=vp.X>=vp.Y
 local w=math.min(landscape and 520 or 360,math.max(300,vp.X-28));local h=math.min(landscape and 350 or 500,math.max(300,vp.Y-76));shell.Size=UDim2.fromOffset(w,h);shell.Position=UDim2.new(.5,0,.5,landscape and 18 or 24)
 local artSize=math.clamp(math.floor(h*.38),106,132);art.Size=UDim2.fromOffset(artSize,artSize);info.Position=UDim2.fromOffset(artSize+12,0);info.Size=UDim2.new(1,-(artSize+12),0,artSize);controls.Position=UDim2.fromOffset(0,artSize+10);up.Position=UDim2.fromOffset(0,artSize+52);up.Size=UDim2.new(1,0,1,-(artSize+52));wave.Visible=w>=390
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()cam=workspace.CurrentCamera;if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end;layout()end);if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end

local acc=0
RunService.RenderStepped:Connect(function(dt)
 if not gui.Enabled then return end;acc+=dt;if acc<.10 then return end;acc=0;if venue()=="MALL"then syncMall()end
 local s=findSound();local loud=s and s.PlaybackLoudness or 0;local norm=math.clamp(loud/600,0,1)
 for i,b in ipairs(bars)do local center=1-math.abs((i-8.5)/8.5);b.Size=UDim2.new(.035,0,0,3+math.floor(norm*17*(.55+.45*center)))end
 if s then local len=tonumber(s.TimeLength)or 0;local pos=tonumber(s.TimePosition)or 0;progressFill.Size=UDim2.new(len>0 and math.clamp(pos/len,0,1)or 0,0,1,0);elapsed.Text=fmt(pos);duration.Text=fmt(len);if SPECIAL[venue()]then S.playing=s.IsPlaying;S.title=tostring(s:GetAttribute("Title")or s.Name or"LIVE VENUE AUDIO")end else progressFill.Size=UDim2.new(0,0,1,0);elapsed.Text="00:00";duration.Text="00:00"end
end)

task.defer(function()layout();bind();refresh();switch("NOW")end)
print("[BBYA] Music Player v3 online: compact reference / artwork hero / UP NEXT / internal tabs / no dashboard sidebar")