-- BBYA SOCIAL HUB — MUSIC SUITE v2.0 COMPACT PLAYER
-- Single visual authority: compact smoky-glass player, left venue cover, TRACKS/QUEUE above Search,
-- enlarged Library, square artwork cards, session Favorites, Now Playing + Up Next + core controls.
-- Server audio authorities are unchanged. Special venue data remains read-only through 93-venue-music-ui.client.lua.

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
 local b=Instance.new("TextButton");b.Name=n;b.Text=t;b.Position=pos or UDim2.new();b.Size=size or UDim2.new();b.BackgroundColor3=bg or C.card;b.BackgroundTransparency=.12;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=9;b.AutoButtonColor=true;b.Parent=p;corner(b,8);stroke(b,C.line,.62);return b
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
gui:SetAttribute("BBYAUIAuthority","MUSIC_SUITE_V2_COMPACT_SINGLE_VISUAL_AUTHORITY")
local backdrop=frame(gui,"Backdrop",UDim2.new(),UDim2.fromScale(1,1),Color3.new(0,0,0),1)
local shell=frame(backdrop,"Shell",UDim2.fromScale(.5,.5),UDim2.fromOffset(820,520),C.bg,.20,14);shell.AnchorPoint=Vector2.new(.5,.5);local shellStroke=stroke(shell,C.purple,.30)

local side=frame(shell,"Side",UDim2.fromOffset(10,10),UDim2.new(0,142,1,-20),C.panel,.28,12);stroke(side,C.line,.70)
label(side,"Brand","BBYA",UDim2.fromOffset(14,9),UDim2.new(1,-28,0,24),Enum.Font.GothamBlack,19,C.white)
label(side,"Sub","MUSIC",UDim2.fromOffset(14,31),UDim2.new(1,-28,0,14),Enum.Font.GothamBold,7,C.muted)
local venueCard=frame(side,"VenueCard",UDim2.fromOffset(14,56),UDim2.fromOffset(114,114),C.card,.08,12);local venueStroke=stroke(venueCard,C.purple,.35)
local venueGlyph=label(venueCard,"VenueGlyph","BBYA",UDim2.fromOffset(8,18),UDim2.new(1,-16,0,42),Enum.Font.GothamBlack,21,C.white,Enum.TextXAlignment.Center)
local venueText=label(venueCard,"Venue","BBYA MUSIC",UDim2.fromOffset(8,67),UDim2.new(1,-16,0,22),Enum.Font.GothamBold,8,C.purple,Enum.TextXAlignment.Center)
label(venueCard,"Hint","CURRENT VENUE",UDim2.fromOffset(8,89),UDim2.new(1,-16,0,14),Enum.Font.GothamBold,6,C.muted,Enum.TextXAlignment.Center)
local nav=frame(side,"Nav",UDim2.fromOffset(14,184),UDim2.new(1,-28,0,160),C.panel,1)
local nl=Instance.new("UIListLayout");nl.Padding=UDim.new(0,7);nl.Parent=nav
local navB={}
local function navButton(k,t)local b=btn(nav,"Nav"..k,t,nil,UDim2.new(1,0,0,36),C.card);b.TextXAlignment=Enum.TextXAlignment.Left;local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,11);pad.Parent=b;navB[k]=b;return b end
navButton("LIBRARY","TRACKS");navButton("NOW","NOW PLAYING");navButton("QUEUE","QUEUE");navButton("FAVORITES","♥ FAVORITES")
local status=frame(side,"Status",UDim2.new(0,14,1,-62),UDim2.new(1,-28,0,48),C.card,.20,9)
label(status,"SL","LIBRARY",UDim2.fromOffset(10,4),UDim2.new(1,-20,0,14),Enum.Font.GothamBold,6,C.muted)
local statusValue=label(status,"SV","0 TRACKS READY",UDim2.fromOffset(10,19),UDim2.new(1,-20,0,20),Enum.Font.GothamBold,8,C.green)

local content=frame(shell,"Content",UDim2.fromOffset(160,0),UDim2.new(1,-160,1,0),C.bg,1)
local header=frame(content,"Header",UDim2.fromOffset(18,10),UDim2.new(1,-36,0,40),C.bg,1)
local sectionTitle=label(header,"SectionTitle","TRACKS",UDim2.new(),UDim2.new(1,-50,1,0),Enum.Font.GothamBlack,17,C.white)
local close=btn(header,"Close","×",UDim2.new(1,-36,0,3),UDim2.fromOffset(34,34),C.card2);close.TextSize=19
local pages={}
local function page(n)local p=frame(content,n,UDim2.fromOffset(18,56),UDim2.new(1,-36,1,-72),C.bg,1);p.Visible=false;pages[n]=p;return p end
local lib=page("LIBRARY");local now=page("NOW");local queue=page("QUEUE");local favPage=page("FAVORITES")

-- TRACKS + QUEUE are intentionally above Search; no duplicate VENUE stat here.
local stats=frame(lib,"Stats",UDim2.fromOffset(0,0),UDim2.new(1,0,0,42),C.bg,1)
local stat={}
local function chip(k,h,col,x)
 local f=frame(stats,"Chip"..k,UDim2.new(x,0,0,0),UDim2.new(.5,-4,1,0),C.card,.16,8);stroke(f,col,.68)
 label(f,"H",h,UDim2.fromOffset(10,3),UDim2.new(.55,-10,1,-6),Enum.Font.GothamBold,6,C.muted)
 stat[k]=label(f,"V","0",UDim2.new(.55,0,0,3),UDim2.new(.45,-10,1,-6),Enum.Font.GothamBlack,11,col,Enum.TextXAlignment.Right)
end
chip("TRACKS","TRACKS",C.purple,0);chip("QUEUE","QUEUE",C.gold,.5)
local search=Instance.new("TextBox");search.Name="Search";search.Position=UDim2.fromOffset(0,50);search.Size=UDim2.new(1,0,0,38);search.BackgroundColor3=C.card;search.BackgroundTransparency=.14;search.BorderSizePixel=0;search.PlaceholderText="Search tracks...";search.PlaceholderColor3=C.muted;search.Text="";search.TextColor3=C.white;search.Font=Enum.Font.Gotham;search.TextSize=10;search.TextXAlignment=Enum.TextXAlignment.Left;search.ClearTextOnFocus=false;search.Parent=lib;corner(search,8);stroke(search,C.line,.55)
local sp=Instance.new("UIPadding");sp.PaddingLeft=UDim.new(0,12);sp.PaddingRight=UDim.new(0,12);sp.Parent=search
local libMeta=label(lib,"Meta","0 TRACKS",UDim2.fromOffset(0,91),UDim2.new(1,0,0,16),Enum.Font.GothamBold,7,C.muted,Enum.TextXAlignment.Right)
local list=Instance.new("ScrollingFrame");list.Name="TrackList";list.Position=UDim2.fromOffset(0,110);list.Size=UDim2.new(1,0,1,-110);list.BackgroundColor3=C.panel;list.BackgroundTransparency=.30;list.BorderSizePixel=0;list.ScrollBarThickness=3;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=lib;corner(list,10);stroke(list,C.line,.68)
local lp=Instance.new("UIPadding");lp.PaddingTop=UDim.new(0,6);lp.PaddingBottom=UDim.new(0,6);lp.PaddingLeft=UDim.new(0,6);lp.PaddingRight=UDim.new(0,6);lp.Parent=list
local ll=Instance.new("UIListLayout");ll.Padding=UDim.new(0,5);ll.Parent=list

-- NOW PLAYING + UP NEXT
local nowCard=frame(now,"NowCard",UDim2.new(0,0,0,0),UDim2.new(.62,-6,1,0),C.panel,.26,12);stroke(nowCard,C.purple,.58)
local art=frame(nowCard,"Artwork",UDim2.fromOffset(16,16),UDim2.fromOffset(142,142),Color3.fromRGB(38,22,57),.04,12)
local artGrad=Instance.new("UIGradient");artGrad.Color=ColorSequence.new(Color3.fromRGB(85,38,128),Color3.fromRGB(18,19,27));artGrad.Rotation=135;artGrad.Parent=art
label(art,"Brand","BBYA",UDim2.fromOffset(8,37),UDim2.new(1,-16,0,36),Enum.Font.GothamBlack,25,C.white,Enum.TextXAlignment.Center)
local artVenue=label(art,"Venue","BBYA MUSIC",UDim2.fromOffset(8,78),UDim2.new(1,-16,0,22),Enum.Font.GothamBold,8,C.cyan,Enum.TextXAlignment.Center)
local nowInfo=frame(nowCard,"NowInfo",UDim2.fromOffset(174,16),UDim2.new(1,-190,0,142),C.panel,1)
local nowState=label(nowInfo,"State","STANDBY",UDim2.fromOffset(0,0),UDim2.new(1,0,0,18),Enum.Font.GothamBold,8,C.green)
local nowTitle=label(nowInfo,"Track","BELUM ADA LAGU",UDim2.fromOffset(0,22),UDim2.new(1,0,0,72),Enum.Font.GothamBlack,15,C.white);nowTitle.TextWrapped=true;nowTitle.TextYAlignment=Enum.TextYAlignment.Top
local nowMeta=label(nowInfo,"Meta","BBYA MUSIC",UDim2.fromOffset(0,96),UDim2.new(1,0,0,18),Enum.Font.GothamBold,7,C.muted)
local wave=frame(nowInfo,"Wave",UDim2.fromOffset(0,117),UDim2.new(1,0,0,24),C.panel,1);local bars={}
for i=1,14 do local b=frame(wave,"Bar"..i,UDim2.new((i-.5)/14,0,1,0),UDim2.new(.04,0,0,3),i%4==0 and C.cyan or C.purple,0,3);b.AnchorPoint=Vector2.new(.5,1);bars[i]=b end
local pb=frame(nowCard,"Progress",UDim2.new(0,16,1,-86),UDim2.new(1,-32,0,5),C.card2,0,4);local pf=frame(pb,"Fill",UDim2.new(),UDim2.new(0,0,1,0),C.purple,0,4)
local elapsed=label(nowCard,"Elapsed","00:00",UDim2.new(0,16,1,-78),UDim2.new(.2,0,0,16),Enum.Font.GothamBold,7,C.muted)
local duration=label(nowCard,"Duration","00:00",UDim2.new(.8,-16,1,-78),UDim2.new(.2,0,0,16),Enum.Font.GothamBold,7,C.muted,Enum.TextXAlignment.Right)
local controls=frame(nowCard,"Controls",UDim2.new(0,16,1,-54),UDim2.new(1,-32,0,38),C.panel,1);local cl=Instance.new("UIListLayout");cl.FillDirection=Enum.FillDirection.Horizontal;cl.Padding=UDim.new(0,7);cl.Parent=controls
local prev=btn(controls,"Prev","PREV",nil,UDim2.new(.30,-5,1,0),C.card2);local mute=btn(controls,"Mute","MUTE",nil,UDim2.new(.40,-5,1,0),C.card2);local nextB=btn(controls,"Next","NEXT",nil,UDim2.new(.30,-5,1,0),Color3.fromRGB(58,34,92))
local up=frame(now,"UpNext",UDim2.new(.62,6,0,0),UDim2.new(.38,-6,1,0),C.panel,.26,12);stroke(up,C.line,.62)
label(up,"Title","UP NEXT",UDim2.fromOffset(12,8),UDim2.new(1,-24,0,24),Enum.Font.GothamBlack,11,C.white)
local upList=Instance.new("ScrollingFrame");upList.Name="UpNextList";upList.Position=UDim2.fromOffset(10,38);upList.Size=UDim2.new(1,-20,1,-48);upList.BackgroundTransparency=1;upList.BorderSizePixel=0;upList.ScrollBarThickness=2;upList.AutomaticCanvasSize=Enum.AutomaticSize.Y;upList.CanvasSize=UDim2.new();upList.Parent=up
local ul=Instance.new("UIListLayout");ul.Padding=UDim.new(0,5);ul.Parent=upList

-- QUEUE
local queueMeta=label(queue,"Meta","0 REQUESTS",UDim2.new(.5,0,0,0),UDim2.new(.5,0,0,20),Enum.Font.GothamBold,7,C.muted,Enum.TextXAlignment.Right)
local qp=frame(queue,"QueueCard",UDim2.fromOffset(0,26),UDim2.new(1,0,1,-26),C.panel,.28,11);stroke(qp,C.line,.62)
local qList=Instance.new("ScrollingFrame");qList.Name="QueueList";qList.Position=UDim2.fromOffset(12,12);qList.Size=UDim2.new(1,-24,1,-24);qList.BackgroundTransparency=1;qList.BorderSizePixel=0;qList.ScrollBarThickness=2;qList.AutomaticCanvasSize=Enum.AutomaticSize.Y;qList.CanvasSize=UDim2.new();qList.Parent=qp
local ql=Instance.new("UIListLayout");ql.Padding=UDim.new(0,6);ql.Parent=qList

-- FAVORITES lives in the same authority; no visual patch script required.
local favorites={}
local favHero=frame(favPage,"FavHero",UDim2.fromOffset(0,0),UDim2.new(1,0,0,46),C.card,.18,9);stroke(favHero,C.pink,.62)
label(favHero,"Heart","♥",UDim2.fromOffset(12,0),UDim2.fromOffset(32,46),Enum.Font.GothamBlack,20,C.pink,Enum.TextXAlignment.Center)
label(favHero,"Title","FAVORITES",UDim2.fromOffset(50,5),UDim2.new(1,-62,0,20),Enum.Font.GothamBlack,11,C.white)
label(favHero,"Sub","Saved for this session",UDim2.fromOffset(50,24),UDim2.new(1,-62,0,15),Enum.Font.GothamBold,6,C.muted)
local favList=Instance.new("ScrollingFrame");favList.Name="FavoriteList";favList.Position=UDim2.fromOffset(0,54);favList.Size=UDim2.new(1,0,1,-54);favList.BackgroundColor3=C.panel;favList.BackgroundTransparency=.30;favList.BorderSizePixel=0;favList.ScrollBarThickness=3;favList.AutomaticCanvasSize=Enum.AutomaticSize.Y;favList.CanvasSize=UDim2.new();favList.Parent=favPage;corner(favList,10);stroke(favList,C.line,.68)
local fp=Instance.new("UIPadding");fp.PaddingTop=UDim.new(0,6);fp.PaddingBottom=UDim.new(0,6);fp.PaddingLeft=UDim.new(0,6);fp.PaddingRight=UDim.new(0,6);fp.Parent=favList
local fl=Instance.new("UIListLayout");fl.Padding=UDim.new(0,5);fl.Parent=favList

local S={tracks={},title="",index=0,playing=false,queue=0,nextRequest=0,autoNext=0}
local function clear(p,prefix)for _,x in ipairs(p:GetChildren())do if x.Name:sub(1,#prefix)==prefix then x:Destroy()end end end
local function mini(p,n,no,titleText,meta,col)
 local r=frame(p,n,nil,UDim2.new(1,-2,0,48),C.card,.14,8)
 local artMini=frame(r,"Art",UDim2.fromOffset(5,5),UDim2.fromOffset(38,38),Color3.fromRGB(43,31,57),.08,7);label(artMini,"Glyph",tostring(no),UDim2.new(),UDim2.fromScale(1,1),Enum.Font.GothamBlack,8,col or C.purple,Enum.TextXAlignment.Center)
 label(r,"T",titleText,UDim2.fromOffset(50,4),UDim2.new(1,-56,0,22),Enum.Font.GothamBold,8,C.white);label(r,"M",meta,UDim2.fromOffset(50,24),UDim2.new(1,-56,0,16),Enum.Font.GothamBold,6,C.muted);return r
end
local function mallTracks()
 local folder=RS:FindFirstChild("BBYAMallPlaylistCatalog");if not folder then return{}end;local indexed={}
 for _,row in ipairs(folder:GetChildren())do if row:IsA("StringValue")then local i=tonumber(row:GetAttribute("Index"));if i then indexed[i]={title=row.Value,assetId=tostring(row:GetAttribute("AssetId")or""),playbackSpeed=tonumber(row:GetAttribute("PlaybackSpeed"))or 1,style="KPOP • RANDOM MIX"}end end end
 local out={};for i=1,#indexed do if indexed[i]then table.insert(out,indexed[i])end end;return out
end
local function syncMall()
 if venue()~="MALL"then return false end;S.tracks=mallTracks();S.index=tonumber(RS:GetAttribute("BBYAMallCurrentIndex"))or 1;S.title=tostring(RS:GetAttribute("BBYAMallCurrentTitle")or"");S.queue=tonumber(RS:GetAttribute("BBYAMallQueueCount"))or 0;S.nextRequest=tonumber(RS:GetAttribute("BBYAMallNextRequestIndex"))or 0;S.autoNext=tonumber(RS:GetAttribute("BBYAMallAutoNextIndex"))or 0;local sound=SS:FindFirstChild("BBYAMallMasterSound");S.playing=sound and sound:IsA("Sound")and sound.IsPlaying or false;return true
end
local function accent()return(V[venue()]or V.NONE).accent end
local function requestList()local v=venue();if v=="MAIN"or v=="UNDERGROUND"then music:FireServer("list")elseif v=="MALL"then syncMall()end end
local function request(i)local v=venue();if v=="MAIN"or v=="UNDERGROUND"then music:FireServer("request",i)elseif v=="MALL"and mallControl then mallControl:FireServer("request",i)end end
local function favKey(v,i)return tostring(v)..":"..tostring(i)end
local function isFavorite(v,i)return favorites[favKey(v,i)]~=nil end
local function setFavorite(v,i,titleText,metaText,on)if on then favorites[favKey(v,i)]={venue=v,index=i,title=titleText,meta=metaText}else favorites[favKey(v,i)]=nil end end

local function refreshChrome()
 local v=venue();local s=V[v]or V.NONE;venueText.Text=s.label;venueText.TextColor3=s.accent;venueGlyph.Text=s.short;venueStroke.Color=s.accent;shellStroke.Color=s.accent;artVenue.Text=s.label;artVenue.TextColor3=s.accent
 navB.FAVORITES.Visible=(v=="MAIN"or v=="UNDERGROUND"or v=="MALL")
end
local function refreshFavorites()
 clear(favList,"Fav_");local rows={};for _,item in pairs(favorites)do table.insert(rows,item)end;table.sort(rows,function(a,b)if a.venue==b.venue then return a.index<b.index end;return a.venue<b.venue end)
 if #rows==0 then mini(favList,"Fav_Empty","♥","NO FAVORITES YET","Tap ♥ on a track",C.pink);return end
 for n,item in ipairs(rows)do
  local r=mini(favList,"Fav_"..n,string.format("%02d",item.index),item.title,item.venue.." • "..item.meta,C.pink)
  local rm=btn(r,"Remove","♥",UDim2.new(1,-40,0,8),UDim2.fromOffset(30,30),Color3.fromRGB(55,30,48));rm.TextColor3=C.pink;rm.TextSize=12;rm.Activated:Connect(function()setFavorite(item.venue,item.index,item.title,item.meta,false);refreshFavorites()end)
  if item.venue==venue()then local req=btn(r,"Req","REQUEST",UDim2.new(1,-118,0,8),UDim2.fromOffset(72,30),Color3.fromRGB(54,34,83));req.TextSize=7;req.Activated:Connect(function()request(item.index)end)end
 end
end
local function rebuildLibrary()
 if SPECIAL[venue()]then return end
 clear(list,"Track_");local q=string.lower(search.Text or"");local shown=0;local a=accent();local v=venue()
 for i,item in ipairs(S.tracks)do
  local titleText=tostring(item.title or("Track "..i));local meta=tostring(item.style or item.genre or"BBYA MUSIC")
  if q==""or string.find(string.lower(titleText.." "..meta),q,1,true)then
   shown+=1;local r=frame(list,"Track_"..i,nil,UDim2.new(1,-2,0,50),C.card,.14,8);r.LayoutOrder=i;if S.playing and S.index==i then stroke(r,a,.28)end
   local artwork=frame(r,"Artwork",UDim2.fromOffset(5,5),UDim2.fromOffset(40,40),Color3.fromRGB(43,31,57),.06,7);label(artwork,"Glyph",string.format("%02d",i),UDim2.new(),UDim2.fromScale(1,1),Enum.Font.GothamBlack,8,a,Enum.TextXAlignment.Center)
   label(r,"Title",titleText,UDim2.fromOffset(52,4),UDim2.new(1,-182,0,23),Enum.Font.GothamBold,9,C.white);label(r,"Meta",string.upper(meta),UDim2.fromOffset(52,26),UDim2.new(1,-182,0,16),Enum.Font.GothamBold,6,C.muted)
   local fav=btn(r,"FavToggle",isFavorite(v,i)and"♥"or"♡",UDim2.new(1,-126,0,9),UDim2.fromOffset(30,30),Color3.fromRGB(48,31,52));fav.TextSize=12;fav.TextColor3=isFavorite(v,i)and C.pink or C.muted
   fav.Activated:Connect(function()local on=not isFavorite(v,i);setFavorite(v,i,titleText,meta,on);fav.Text=on and"♥"or"♡";fav.TextColor3=on and C.pink or C.muted;refreshFavorites()end)
   local req=btn(r,"Req",(S.playing and S.index==i)and"PLAYING"or"REQUEST",UDim2.new(1,-90,0,9),UDim2.fromOffset(84,30),Color3.fromRGB(54,34,83));req.TextSize=7
   if S.playing and S.index==i then req.Active=false;req.AutoButtonColor=false;req.TextColor3=C.muted else req.Activated:Connect(function()request(i)end)end
  end
 end
 libMeta.Text=string.format("%d / %d TRACKS",shown,#S.tracks);statusValue.Text=tostring(#S.tracks).." TRACKS READY";stat.TRACKS.Text=tostring(#S.tracks);stat.QUEUE.Text=tostring(S.queue or 0)
end
local function rebuildUp()
 if SPECIAL[venue()]then return end;clear(upList,"Next_");if #S.tracks==0 then mini(upList,"Next_Empty","--","PLAYLIST EMPTY","Waiting for venue playlist",C.muted);return end
 local used={};local order=0;local first=tonumber(S.nextRequest)or 0;if first>0 and S.tracks[first]then order+=1;used[first]=true;mini(upList,"Next_"..order,order,tostring(S.tracks[first].title or"Request"),"REQUEST QUEUE",C.gold)end
 local cur=math.max(S.index or 0,0);while order<5 and order<#S.tracks do cur=(cur%#S.tracks)+1;if not used[cur]then order+=1;used[cur]=true;mini(upList,"Next_"..order,order,tostring(S.tracks[cur].title or("Track "..cur)),"AUTO DJ",accent())end end
end
local function rebuildQueue()
 if SPECIAL[venue()]then return end;clear(qList,"Queue_");queueMeta.Text=tostring(S.queue or 0).." REQUESTS";stat.QUEUE.Text=tostring(S.queue or 0)
 if(S.queue or 0)==0 then mini(qList,"Queue_Empty","--","REQUEST QUEUE EMPTY","Choose a track then REQUEST",C.muted)
 elseif(S.nextRequest or 0)>0 and S.tracks[S.nextRequest]then mini(qList,"Queue_1","01",tostring(S.tracks[S.nextRequest].title or"Requested track"),"NEXT REQUEST",C.gold);if S.queue>1 then mini(qList,"Queue_Info","+",tostring(S.queue-1).." MORE REQUESTS","Server queue",accent())end
 else mini(qList,"Queue_Info","+",tostring(S.queue).." REQUESTS","Server queue",accent())end
end
local function refreshNow()
 if SPECIAL[venue()]then return end;local s=V[venue()]or V.NONE;local t=S.title;if t==""and S.index>0 and S.tracks[S.index]then t=tostring(S.tracks[S.index].title or"")end;if t==""then t="BELUM ADA LAGU"end
 nowTitle.Text=t;nowMeta.Text=s.label.." • "..tostring(#S.tracks).." TRACKS";nowState.Text=S.playing and"LIVE • PLAYING"or"STANDBY";nowState.TextColor3=S.playing and C.green or C.muted;mute.Text=player:GetAttribute("BBYAMusicMuted")==true and"UNMUTE"or"MUTE";prev.Visible=isAdmin();nextB.Visible=isAdmin();rebuildUp();rebuildQueue()
end
local function refresh()refreshChrome();if not SPECIAL[venue()]then rebuildLibrary();refreshNow()end;refreshFavorites()end
local function switch(k)
 for n,p in pairs(pages)do p.Visible=n==k end;for n,b in pairs(navB)do b.BackgroundColor3=n==k and Color3.fromRGB(55,35,82)or C.card;b.TextColor3=n==k and C.white or C.muted end
 sectionTitle.Text=(k=="LIBRARY"and"TRACKS")or(k=="NOW"and"NOW PLAYING")or k;if k=="FAVORITES"then refreshFavorites()end
end

local activeSound=nil;local lastSoundScan=0
local function findSound()
 if activeSound and activeSound.Parent and activeSound.IsPlaying then return activeSound end;if os.clock()-lastSoundScan<.5 then return activeSound end;lastSoundScan=os.clock();local v=venue();local info=V[v];if not info or not info.group then activeSound=nil;return nil end
 local group=SS:FindFirstChild(info.group);local known={MAIN={"BBYAClubDeckA","BBYAClubDeckB"},UNDERGROUND={"BBYABasementDeckA","BBYABasementDeckB"},FUNKOT={"BBYAFunkotDeck"},MALL={"BBYAMallMasterSound"},SKATEPARK={"BBYASkateparkMasterSound"},ROOFTOP={"BBYARooftopPlaylist"},VIP={"BBYAVIPPlaylist"}}
 for _,n in ipairs(known[v]or{})do local x=SS:FindFirstChild(n,true)or workspace:FindFirstChild(n,true);if x and x:IsA("Sound")and x.IsPlaying then activeSound=x;return x end end
 for _,rootObj in ipairs({SS,workspace})do for _,x in ipairs(rootObj:GetDescendants())do if x:IsA("Sound")and x.IsPlaying and group and x.SoundGroup==group then activeSound=x;return x end end end;activeSound=nil;return nil
end
local function fmt(sec)sec=math.max(0,math.floor(tonumber(sec)or 0));return string.format("%02d:%02d",math.floor(sec/60),sec%60)end

navB.LIBRARY.Activated:Connect(function()switch("LIBRARY")end);navB.NOW.Activated:Connect(function()switch("NOW")end);navB.QUEUE.Activated:Connect(function()switch("QUEUE")end);navB.FAVORITES.Activated:Connect(function()switch("FAVORITES")end)
search:GetPropertyChangedSignal("Text"):Connect(rebuildLibrary)
mute.Activated:Connect(function()player:SetAttribute("BBYAMusicMuted",not(player:GetAttribute("BBYAMusicMuted")==true));refreshNow()end)
prev.Activated:Connect(function()if not isAdmin()then return end;local v=venue();if v=="MALL"and mallControl then mallControl:FireServer("prev")elseif(v=="MAIN"or v=="UNDERGROUND")and #S.tracks>0 then local i=((math.max(S.index,1)-2)%#S.tracks)+1;music:FireServer("play",i)end end)
nextB.Activated:Connect(function()if not isAdmin()then return end;local v=venue();if v=="MALL"and mallControl then mallControl:FireServer("next")elseif v=="MAIN"or v=="UNDERGROUND"then music:FireServer("next")end end)
close.Activated:Connect(function()gui.Enabled=false end)
local function open()if legacy then legacy.Visible=false end;hub.Visible=false;gui.Enabled=true;requestList();refresh();switch("LIBRARY")end

stateRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist"and type(data)=="table"then if venue()~="MALL"and not SPECIAL[venue()]then S.tracks=data end;if gui.Enabled then refresh()end
 elseif kind=="music"and type(data)=="table"then local v=tostring(data.venue or venue());if v=="BASEMENT"then v="UNDERGROUND"end;if not SPECIAL[venue()]and(v==venue()or venue()=="NONE")then S.index=tonumber(data.index)or S.index;S.title=tostring(data.title or S.title or"");S.playing=data.playing==true;S.queue=tonumber(data.queue)or 0;S.nextRequest=tonumber(data.nextRequest)or 0;activeSound=nil;if gui.Enabled then refresh()end end end
end)
player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()activeSound=nil;if gui.Enabled then requestList();refresh();switch("LIBRARY")end end)
player:GetAttributeChangedSignal("BBYAAdmin"):Connect(function()if gui.Enabled then refreshNow()end end);player:GetAttributeChangedSignal("BBYAMusicMuted"):Connect(function()if gui.Enabled then refreshNow()end end)
for _,attr in ipairs({"BBYAMallPlaylistCount","BBYAMallCurrentIndex","BBYAMallCurrentTitle","BBYAMallCurrentAssetId","BBYAMallQueueCount","BBYAMallNextRequestIndex","BBYAMallAutoNextIndex","BBYAMallShuffleRemaining"})do RS:GetAttributeChangedSignal(attr):Connect(function()if venue()=="MALL"then syncMall();if gui.Enabled then refresh()end end end)end
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
 cam=workspace.CurrentCamera or cam;local vp=cam and cam.ViewportSize or Vector2.new(1280,720);local w=math.clamp(vp.X-52,620,860);local h=math.clamp(vp.Y-70,410,570);shell.Size=UDim2.fromOffset(w,h)
 local sideW=vp.X<760 and 126 or 142;side.Size=UDim2.new(0,sideW,1,-20);content.Position=UDim2.fromOffset(sideW+18,0);content.Size=UDim2.new(1,-(sideW+18),1,0)
 venueCard.Size=UDim2.fromOffset(sideW-28,sideW-28);nav.Position=UDim2.fromOffset(14,sideW+42);status.Visible=h>=470
 if vp.X<720 then nowCard.Size=UDim2.new(.66,-5,1,0);up.Position=UDim2.new(.66,5,0,0);up.Size=UDim2.new(.34,-5,1,0);art.Size=UDim2.fromOffset(112,112);nowInfo.Position=UDim2.fromOffset(140,16);nowInfo.Size=UDim2.new(1,-156,0,116);wave.Visible=false else nowCard.Size=UDim2.new(.62,-6,1,0);up.Position=UDim2.new(.62,6,0,0);up.Size=UDim2.new(.38,-6,1,0);art.Size=UDim2.fromOffset(142,142);nowInfo.Position=UDim2.fromOffset(174,16);nowInfo.Size=UDim2.new(1,-190,0,142);wave.Visible=true end
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()cam=workspace.CurrentCamera;if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end;layout()end);if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end

local acc=0
RunService.RenderStepped:Connect(function(dt)
 if not gui.Enabled then return end;acc+=dt;if acc<.10 then return end;acc=0;if venue()=="MALL"then syncMall()end
 local s=findSound();local loud=s and s.PlaybackLoudness or 0;local norm=math.clamp(loud/600,0,1)
 for i,b in ipairs(bars)do local center=1-math.abs((i-7.5)/7.5);b.Size=UDim2.new(.04,0,0,3+math.floor(norm*20*(.55+.45*center)))end
 if s then local len=tonumber(s.TimeLength)or 0;local pos=tonumber(s.TimePosition)or 0;pf.Size=UDim2.new(len>0 and math.clamp(pos/len,0,1)or 0,0,1,0);elapsed.Text=fmt(pos);duration.Text=fmt(len)else pf.Size=UDim2.new(0,0,1,0);elapsed.Text="00:00";duration.Text="00:00"end
end)

task.defer(function()layout();bind();refresh();switch("LIBRARY")end)
print("[BBYA] Music Suite v2.0 online: compact glass / left venue cover / TRACKS+QUEUE above Search / favorites / single visual authority")