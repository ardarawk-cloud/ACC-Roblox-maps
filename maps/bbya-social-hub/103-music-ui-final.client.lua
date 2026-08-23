-- BBYA SOCIAL HUB — COMPACT MUSIC UI FINAL AUTHORITY v7
-- One small Now Playing card + separate Playlist drawer.
-- Legacy dashboard remains backend-only and is never shown to the player.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("BBYAClubUI",30)
if not gui then return end
local hub=gui:WaitForChild("HubPanel",30)
if not hub then return end
local camera=workspace.CurrentCamera

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local musicRemote=remotes:WaitForChild("Music",30)
local stateRemote=remotes:WaitForChild("State",30)
local funkotRemote=remotes:WaitForChild("FunkotMusic",30)

local C={
 bg=Color3.fromRGB(10,11,16),card=Color3.fromRGB(21,22,29),card2=Color3.fromRGB(29,30,39),
 white=Color3.fromRGB(246,246,249),muted=Color3.fromRGB(156,160,173),line=Color3.fromRGB(78,81,96),
 pink=Color3.fromRGB(232,38,165),cyan=Color3.fromRGB(39,196,225),gold=Color3.fromRGB(220,173,86),
 purple=Color3.fromRGB(143,82,255),green=Color3.fromRGB(68,205,135),
}
local VENUES={
 MAIN={label="MAIN CLUB",short="CLUB",accent=C.pink,group="BBYAClubMaster"},
 UNDERGROUND={label="UNDERGROUND",short="UNDERGROUND",accent=C.cyan,group="BBYABasementMaster"},
 VIP={label="VIP",short="VIP",accent=C.gold,group="BBYAVIPMaster"},
 FUNKOT={label="FUNKOT",short="FUNKOT",accent=C.purple,group="BBYAFunkotMaster"},
 SKATEPARK={label="SKATEPARK",short="SKATEPARK",accent=C.cyan,group="BBYASkateparkMaster"},
 ROOFTOP={label="ROOFTOP",short="ROOFTOP",accent=C.gold,group="BBYARooftopMaster"},
 NONE={label="MUSIC",short="MUSIC",accent=C.muted,group=nil},
}

local function corner(o,r)
 local c=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,r or 10);c.Parent=o;return c
end
local function stroke(o,col,tr,name)
 local s=o:FindFirstChild(name or "CompactMusicStroke") or Instance.new("UIStroke")
 s.Name=name or "CompactMusicStroke";s.Color=col or C.line;s.Thickness=1;s.Transparency=tr or .46;s.Parent=o;return s
end
local function label(parent,name,text,pos,size,font,ts,color,align)
 local x=parent:FindFirstChild(name) or Instance.new("TextLabel")
 x.Name=name;x.BackgroundTransparency=1;x.Text=text;x.Position=pos;x.Size=size;x.Font=font or Enum.Font.Gotham
 x.TextSize=ts or 10;x.TextColor3=color or C.white;x.TextXAlignment=align or Enum.TextXAlignment.Left;x.TextYAlignment=Enum.TextYAlignment.Center
 x.TextWrapped=true;x.Parent=parent;return x
end
local function button(parent,name,text,pos,size,bg)
 local b=parent:FindFirstChild(name) or Instance.new("TextButton")
 b.Name=name;b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.card2;b.BackgroundTransparency=.16;b.BorderSizePixel=0
 b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=9;b.AutoButtonColor=true;b.Parent=parent;corner(b,8);stroke(b,C.line,.58,name.."Stroke");return b
end
local function isAdmin()
 return player:GetAttribute("BBYAAdmin")==true or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)
end
local function resetActive()
 return ReplicatedStorage:GetAttribute("BBYAMusicCatalogReset")==true
end
local function venueAtPosition(p)
 if p.Y<-4.5 then return "UNDERGROUND" end
 if p.Y>=40 and p.Y<=60 and math.abs(p.X)<=62 and p.Z>=-48 and p.Z<=48 then return "ROOFTOP" end
 if p.Y>=20 and p.Y<40 and math.abs(p.X)<=58 and p.Z>=-46 and p.Z<=46 then return "VIP" end
 if p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253 then return "FUNKOT" end
 if p.Y>-4 and p.Y<20 and math.abs(p.X)<=61 and p.Z>=72 and p.Z<=152 then return "SKATEPARK" end
 if p.Y>-4 and p.Y<18 and math.abs(p.X)<=61 and p.Z>=0 and p.Z<70 then return "MAIN" end
 return "NONE"
end
local function currentVenue()
 local v=tostring(player:GetAttribute("BBYAAudioVenue") or "")
 if VENUES[v] then return v end
 local ch=player.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 return hrp and venueAtPosition(hrp.Position) or "NONE"
end

-- Legacy music frame is backend-only. It may still receive remote data, but v7 never exposes it.
local legacyPlayerCard=hub:FindFirstChild("PlayerCard",true)
local legacyMusicFrame=legacyPlayerCard and legacyPlayerCard.Parent
if legacyMusicFrame then legacyMusicFrame.Visible=false end

local old=gui:FindFirstChild("BBYACompactMusicLayerV7")
if old then old:Destroy() end
local layer=Instance.new("Frame")
layer.Name="BBYACompactMusicLayerV7";layer.Size=UDim2.fromScale(1,1);layer.BackgroundTransparency=1;layer.Visible=false;layer.ZIndex=700;layer.Parent=gui
layer:SetAttribute("BBYACompactMusicAuthority","V7")

local card=Instance.new("Frame")
card.Name="CompactMusicCardV7";card.AnchorPoint=Vector2.new(.5,.5);card.Position=UDim2.fromScale(.5,.5);card.Size=UDim2.fromOffset(440,170)
card.BackgroundColor3=C.bg;card.BackgroundTransparency=.28;card.BorderSizePixel=0;card.ZIndex=701;card.Parent=layer;corner(card,15)
local cardStroke=stroke(card,C.pink,.25,"VenueStrokeV7")

local cover=Instance.new("Frame")
cover.Name="CoverShell";cover.Position=UDim2.fromOffset(14,14);cover.Size=UDim2.fromOffset(110,110);cover.BackgroundColor3=C.card2;cover.BackgroundTransparency=.18;cover.BorderSizePixel=0;cover.ZIndex=702;cover.Parent=card;corner(cover,11)
local coverStroke=stroke(cover,C.pink,.38,"CoverStrokeV7")
local coverImage=Instance.new("ImageLabel")
coverImage.Name="TrackCover";coverImage.Size=UDim2.fromScale(1,1);coverImage.BackgroundTransparency=1;coverImage.Image="";coverImage.ScaleType=Enum.ScaleType.Crop;coverImage.ZIndex=703;coverImage.Parent=cover;corner(coverImage,11)
local coverBrand=label(cover,"FallbackBrand","BBYA",UDim2.fromOffset(9,20),UDim2.new(1,-18,0,30),Enum.Font.GothamBlack,22,C.white,Enum.TextXAlignment.Center);coverBrand.ZIndex=704
local coverVenue=label(cover,"FallbackVenue","CLUB",UDim2.fromOffset(9,54),UDim2.new(1,-18,0,24),Enum.Font.GothamBold,9,C.pink,Enum.TextXAlignment.Center);coverVenue.ZIndex=704

local nowSmall=label(card,"NowPlayingLabel","NOW PLAYING",UDim2.fromOffset(140,14),UDim2.new(1,-184,0,18),Enum.Font.GothamBold,9,C.pink);nowSmall.ZIndex=703
local nowTitle=label(card,"NowPlayingTitle","BELUM ADA LAGU",UDim2.fromOffset(140,32),UDim2.new(1,-184,0,45),Enum.Font.GothamBold,18,C.white);nowTitle.ZIndex=703
local nowMeta=label(card,"NowPlayingMeta","CLUB • PLAYLIST EMPTY",UDim2.fromOffset(140,78),UDim2.new(1,-184,0,18),Enum.Font.GothamMedium,9,C.muted);nowMeta.ZIndex=703

local wave=Instance.new("Frame")
wave.Name="AudioWaveV7";wave.Position=UDim2.fromOffset(140,99);wave.Size=UDim2.new(1,-184,0,22);wave.BackgroundTransparency=1;wave.ZIndex=703;wave.Parent=card
local waveBars={}
for i=1,14 do
 local b=Instance.new("Frame");b.Name="Bar"..i;b.AnchorPoint=Vector2.new(.5,1);b.Position=UDim2.new((i-.5)/14,0,1,0);b.Size=UDim2.new(.045,0,0,3)
 b.BackgroundColor3=(i%4==0 and C.cyan or C.pink);b.BorderSizePixel=0;b.ZIndex=704;b.Parent=wave;corner(b,3);table.insert(waveBars,b)
end

local playlistBtn=button(card,"PlaylistButtonV7","PLAYLIST",UDim2.fromOffset(140,128),UDim2.fromOffset(96,30),Color3.fromRGB(59,26,51));playlistBtn.ZIndex=704
local muteBtn=button(card,"MuteButtonV7","MUTE",UDim2.fromOffset(244,128),UDim2.fromOffset(76,30),C.card2);muteBtn.ZIndex=704
local adminPrev=button(card,"AdminPreviousV7","PREV",UDim2.fromOffset(328,128),UDim2.fromOffset(46,30),C.card2);adminPrev.ZIndex=704
local adminNext=button(card,"AdminNextV7","NEXT",UDim2.fromOffset(380,128),UDim2.fromOffset(46,30),Color3.fromRGB(64,26,53));adminNext.ZIndex=704
local closeBtn=button(card,"CompactCloseV7","×",UDim2.new(1,-42,0,10),UDim2.fromOffset(32,32),Color3.fromRGB(32,33,42));closeBtn.TextSize=19;closeBtn.ZIndex=706

local drawer=Instance.new("Frame")
drawer.Name="PlaylistDrawerV7";drawer.AnchorPoint=Vector2.new(.5,.5);drawer.Position=UDim2.fromScale(.5,.5);drawer.Size=UDim2.fromOffset(540,360)
drawer.BackgroundColor3=C.bg;drawer.BackgroundTransparency=.25;drawer.BorderSizePixel=0;drawer.Visible=false;drawer.ZIndex=710;drawer.Parent=layer;corner(drawer,15)
local drawerStroke=stroke(drawer,C.pink,.25,"DrawerVenueStrokeV7")
local drawerTitle=label(drawer,"PlaylistTitle","CLUB PLAYLIST",UDim2.fromOffset(16,10),UDim2.new(1,-116,0,28),Enum.Font.GothamBlack,15,C.white);drawerTitle.ZIndex=712
local drawerCount=label(drawer,"PlaylistCount","0 TRACKS",UDim2.fromOffset(16,37),UDim2.new(1,-116,0,18),Enum.Font.GothamBold,9,C.muted);drawerCount.ZIndex=712
local drawerBack=button(drawer,"PlaylistBackV7","BACK",UDim2.new(1,-98,0,12),UDim2.fromOffset(48,30),C.card2);drawerBack.ZIndex=713
local drawerClose=button(drawer,"PlaylistCloseV7","×",UDim2.new(1,-44,0,12),UDim2.fromOffset(32,30),C.card2);drawerClose.TextSize=18;drawerClose.ZIndex=713
local scroller=Instance.new("ScrollingFrame")
scroller.Name="PlaylistScrollerV7";scroller.Position=UDim2.fromOffset(14,66);scroller.Size=UDim2.new(1,-28,1,-80);scroller.BackgroundTransparency=1;scroller.BorderSizePixel=0
scroller.ScrollBarThickness=3;scroller.ScrollBarImageTransparency=.28;scroller.CanvasSize=UDim2.fromOffset(0,0);scroller.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroller.ZIndex=711;scroller.Parent=drawer
local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,7);list.SortOrder=Enum.SortOrder.LayoutOrder;list.Parent=scroller
local emptyText=label(scroller,"PlaylistEmpty","PLAYLIST KOSONG\n0 TRACKS • playlist sedang disusun ulang",UDim2.fromOffset(0,0),UDim2.new(1,-6,0,90),Enum.Font.GothamBold,11,C.muted,Enum.TextXAlignment.Center)
emptyText.TextYAlignment=Enum.TextYAlignment.Center;emptyText.LayoutOrder=1;emptyText.ZIndex=712

local toast=label(layer,"MusicToastV7","",UDim2.new(.5,-160,1,-76),UDim2.fromOffset(320,42),Enum.Font.GothamBold,10,C.white,Enum.TextXAlignment.Center)
toast.AnchorPoint=Vector2.new(0,0);toast.BackgroundColor3=Color3.fromRGB(15,16,22);toast.BackgroundTransparency=.14;toast.BorderSizePixel=0;toast.Visible=false;toast.ZIndex=760;corner(toast,9);stroke(toast,C.pink,.45,"ToastStrokeV7")
local toastToken=0
local function showToast(text)
 toastToken+=1;local token=toastToken;toast.Text=tostring(text or "");toast.Visible=true
 task.delay(1.8,function()if toastToken==token then toast.Visible=false end end)
end

local VIP_TRACK={title="Wonder Girls - Nobody (ROOKIE Amapiano Edit)",assetId="105859685125263"}
local state={}
for key in pairs(VENUES) do state[key]={title="",index=0,playing=false,tracks={},history={},cover=""} end
local function effectiveTracks(v)
 if v=="VIP" then return {VIP_TRACK} end
 if resetActive() then return {} end
 return (state[v] and state[v].tracks) or {}
end
local function currentSpec()
 local v=currentVenue();return v,VENUES[v] or VENUES.NONE
end

local function setCover(v,item,data)
 local image=""
 if type(item)=="table" then image=tostring(item.cover or item.coverId or item.image or "") end
 if image=="" and type(data)=="table" then image=tostring(data.cover or data.coverId or data.image or "") end
 if image~="" and not image:find("rbxassetid://",1,true) then image="rbxassetid://"..image end
 coverImage.Image=image;coverImage.Visible=image~="";coverBrand.Visible=image=="";coverVenue.Visible=image==""
end
local function refreshAdmin()
 local v=currentVenue();local tracks=effectiveTracks(v);local visible=isAdmin() and #tracks>0 and layer.Visible and card.Visible
 adminPrev.Visible=visible;adminNext.Visible=visible
end
local function refreshCard()
 local v,spec=currentSpec();local s=state[v] or state.NONE;local tracks=effectiveTracks(v)
 local vipTrack=(v=="VIP" and tracks[1]) or nil
 local empty=(resetActive() and v~="VIP") or #tracks==0 or (s.title=="" and not vipTrack)
 cardStroke.Color=spec.accent;coverStroke.Color=spec.accent;drawerStroke.Color=spec.accent;nowSmall.TextColor3=spec.accent;coverVenue.TextColor3=spec.accent
 coverVenue.Text=spec.short
 nowTitle.Text=vipTrack and VIP_TRACK.title or (empty and "BELUM ADA LAGU" or s.title)
 nowMeta.Text=vipTrack and "VIP • 1 TRACK" or (empty and (spec.short.." • PLAYLIST EMPTY") or (spec.short..(s.playing and " • PLAYING" or " • READY")))
 local item=vipTrack or ((s.index>0 and tracks[s.index]) or nil);setCover(v,item,s)
 drawerTitle.Text=spec.short.." PLAYLIST";drawerCount.Text=tostring(#tracks)..(#tracks==1 and " TRACK" or " TRACKS")
 muteBtn.Text=player:GetAttribute("BBYAMusicMuted")==true and "UNMUTE" or "MUTE"
 refreshAdmin()
end

local function clearRows()
 for _,child in ipairs(scroller:GetChildren()) do
  if child:IsA("Frame") and child.Name:match("^TrackRowV7_") then child:Destroy() end
 end
end
local function requestTrack(v,index)
 if resetActive() then showToast("PLAYLIST MASIH KOSONG");return end
 if v=="FUNKOT" then funkotRemote:FireServer("request",index)
 elseif v=="MAIN" or v=="UNDERGROUND" then musicRemote:FireServer("request",index)
 else showToast("REQUEST VENUE INI BELUM AKTIF") end
end
local function rebuildPlaylist()
 clearRows()
 local v,spec=currentSpec();local tracks=effectiveTracks(v);emptyText.Visible=#tracks==0
 drawerTitle.Text=spec.short.." PLAYLIST";drawerCount.Text=tostring(#tracks).." TRACKS";drawerStroke.Color=spec.accent
 if #tracks==0 then emptyText.Text="PLAYLIST KOSONG\n0 TRACKS • playlist sedang disusun ulang";return end
 for i,item in ipairs(tracks) do
  local row=Instance.new("Frame");row.Name="TrackRowV7_"..i;row.LayoutOrder=i+1;row.Size=UDim2.new(1,-5,0,48);row.BackgroundColor3=C.card2;row.BackgroundTransparency=.24;row.BorderSizePixel=0;row.ZIndex=712;row.Parent=scroller;corner(row,9)
  local num=label(row,"TrackNumber",string.format("%02d",i),UDim2.fromOffset(12,0),UDim2.fromOffset(34,48),Enum.Font.GothamBold,9,spec.accent);num.ZIndex=713
  local title=label(row,"TrackTitle",tostring(item.title or ("Track "..i)),UDim2.fromOffset(50,0),UDim2.new(1,-160,1,0),Enum.Font.GothamMedium,10,C.white);title.TextWrapped=false;title.TextTruncate=Enum.TextTruncate.AtEnd;title.ZIndex=713
  local req=button(row,"Request","REQUEST",UDim2.new(1,-102,0,8),UDim2.fromOffset(90,32),Color3.fromRGB(67,25,57));req.ZIndex=714;stroke(req,spec.accent,.5,"RequestStroke")
  req.Activated:Connect(function()requestTrack(v,i)end)
 end
end

local function requestList(v)
 if resetActive() then return end
 if v=="FUNKOT" then funkotRemote:FireServer("list")
 elseif v=="MAIN" or v=="UNDERGROUND" then musicRemote:FireServer("list") end
end
local function openMusic()
 hub.Visible=false
 if legacyMusicFrame then legacyMusicFrame.Visible=false end
 layer.Visible=true;card.Visible=true;drawer.Visible=false
 local v=currentVenue();requestList(v);refreshCard();rebuildPlaylist()
end
local function closeMusic()
 layer.Visible=false;card.Visible=true;drawer.Visible=false
end
local function openPlaylist()
 if not layer.Visible then return end
 card.Visible=false;drawer.Visible=true;rebuildPlaylist();refreshAdmin()
end
local function backToCard()
 drawer.Visible=false;card.Visible=true;refreshCard()
end

closeBtn.Activated:Connect(closeMusic)
drawerClose.Activated:Connect(closeMusic)
drawerBack.Activated:Connect(backToCard)
playlistBtn.Activated:Connect(openPlaylist)
muteBtn.Activated:Connect(function()
 player:SetAttribute("BBYAMusicMuted",not (player:GetAttribute("BBYAMusicMuted")==true));refreshCard()
end)

local function playPrevious()
 if not isAdmin() then return end
 local v=currentVenue();local s=state[v];local tracks=effectiveTracks(v);if not s or #tracks==0 then return end
 local prev=table.remove(s.history)
 if not prev then prev=((math.max(s.index,1)-2)%#tracks)+1 end
 if v=="FUNKOT" then funkotRemote:FireServer("play",prev)
 elseif v=="MAIN" or v=="UNDERGROUND" then musicRemote:FireServer("play",prev) end
end
local function playNext()
 if not isAdmin() then return end
 local v=currentVenue();if #effectiveTracks(v)==0 then return end
 if v=="FUNKOT" then funkotRemote:FireServer("next")
 elseif v=="MAIN" or v=="UNDERGROUND" then musicRemote:FireServer("next") end
end
adminPrev.Activated:Connect(playPrevious);adminNext.Activated:Connect(playNext)

local function ingestState(v,data)
 if not VENUES[v] or type(data)~="table" then return end
 local s=state[v];local ni=tonumber(data.index) or 0
 if ni>0 and s.index>0 and ni~=s.index then table.insert(s.history,s.index);if #s.history>8 then table.remove(s.history,1) end end
 s.index=ni;s.title=tostring(data.title or s.title or "");s.playing=data.playing==true;s.cover=tostring(data.cover or data.coverId or s.cover or "")
 if layer.Visible and currentVenue()==v then refreshCard();if drawer.Visible then rebuildPlaylist() end end
end
stateRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist" and type(data)=="table" then
  local v=currentVenue();if v=="MAIN" or v=="UNDERGROUND" then state[v].tracks=resetActive() and {} or data end
  if layer.Visible then refreshCard();rebuildPlaylist() end
 elseif kind=="music" and type(data)=="table" then
  local v=tostring(data.venue or "MAIN");if v=="BASEMENT" then v="UNDERGROUND" end;ingestState(v,data)
 elseif kind=="toast" then showToast(data) end
end)
funkotRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist" and type(data)=="table" then state.FUNKOT.tracks=resetActive() and {} or data;if layer.Visible then refreshCard();rebuildPlaylist() end
 elseif kind=="state" and type(data)=="table" then ingestState("FUNKOT",data) end
end)

local function activeSound()
 local v=currentVenue();local spec=VENUES[v];if not spec or not spec.group then return nil end
 local known={MAIN={"BBYAClubDeckA","BBYAClubDeckB"},UNDERGROUND={"BBYABasementDeckA","BBYABasementDeckB"},FUNKOT={"BBYAFunkotDeck"}}
 for _,name in ipairs(known[v] or {}) do local s=SoundService:FindFirstChild(name);if s and s:IsA("Sound") and s.IsPlaying then return s end end
 local g=SoundService:FindFirstChild(spec.group)
 if g and g:IsA("SoundGroup") then
  for _,s in ipairs(SoundService:GetDescendants()) do if s:IsA("Sound") and s.SoundGroup==g and s.IsPlaying then return s end end
 end
 return nil
end
local peak,smooth,visualAcc=100,0,0
RunService.RenderStepped:Connect(function(dt)
 visualAcc+=dt;if visualAcc<1/20 then return end;visualAcc=0
 local s=(not resetActive()) and activeSound() or nil;local loud=(s and s.PlaybackLoudness) or 0
 peak=math.max(100,loud,peak*.985);local norm=math.clamp(loud/math.max(peak,100),0,1);smooth+=(norm-smooth)*.38
 local n=#waveBars
 for i,b in ipairs(waveBars) do local center=1-math.abs((i-(n+1)/2)/((n+1)/2));local h=3+math.floor(smooth*17*(.62+.38*center)+.5);b.Size=UDim2.new(.045,0,0,h) end
end)

local function layout()
 camera=workspace.CurrentCamera or camera;local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
 local cw=math.clamp(math.floor(vp.X*.43),340,470);local ch=math.clamp(math.floor(vp.Y*.26),158,175)
 card.Size=UDim2.fromOffset(cw,ch)
 local coverSize=math.clamp(ch-50,92,110);cover.Size=UDim2.fromOffset(coverSize,coverSize)
 local left=14+coverSize+16;local right=46
 nowSmall.Position=UDim2.fromOffset(left,14);nowSmall.Size=UDim2.new(1,-left-right,0,16)
 nowTitle.Position=UDim2.fromOffset(left,31);nowTitle.Size=UDim2.new(1,-left-right,0,42);nowTitle.TextSize=(cw<390 and 15 or 18)
 nowMeta.Position=UDim2.fromOffset(left,74);nowMeta.Size=UDim2.new(1,-left-right,0,16)
 wave.Position=UDim2.fromOffset(left,94);wave.Size=UDim2.new(1,-left-right,0,21)
 local by=ch-38;playlistBtn.Position=UDim2.fromOffset(left,by);muteBtn.Position=UDim2.fromOffset(left+104,by)
 adminPrev.Position=UDim2.fromOffset(left+188,by);adminNext.Position=UDim2.fromOffset(left+240,by)
 local dw=math.clamp(math.floor(vp.X*.53),350,580);local dh=math.clamp(math.floor(vp.Y*.58),280,400);drawer.Size=UDim2.fromOffset(dw,dh)
 refreshAdmin()
end

local bound={}
local function bindSlotButton(slotName,onOpen)
 local menu=pg:FindFirstChild("BBYACommandMenuUI");local drawerMenu=menu and menu:FindFirstChild("FeatureDrawer");local slot=drawerMenu and drawerMenu:FindFirstChild(slotName,true)
 if not slot then return end
 for _,x in ipairs(slot:GetChildren()) do
  if x:IsA("TextButton") and not bound[x] then
   bound[x]=true
   x.Activated:Connect(function()task.defer(onOpen)end)
  end
 end
end
local function bindCommandMenu()
 bindSlotButton("Slot_MUSIC",openMusic)
 for _,slotName in ipairs({"Slot_BBYA","Slot_SUPPORT","Slot_TRAVEL","Slot_MESSAGE","Slot_COMMUNITY","Slot_DANCE","Slot_CARRY","Slot_FREECAM"}) do bindSlotButton(slotName,closeMusic) end
end
pg.ChildAdded:Connect(function()task.defer(bindCommandMenu)end)
if legacyMusicFrame then legacyMusicFrame:GetPropertyChangedSignal("Visible"):Connect(function()if legacyMusicFrame.Visible then task.defer(openMusic)end end) end
hub:GetPropertyChangedSignal("Visible"):Connect(function()if hub.Visible and legacyMusicFrame and legacyMusicFrame.Visible then task.defer(openMusic)end end)
player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()if layer.Visible then refreshCard();rebuildPlaylist();requestList(currentVenue()) end end)
player:GetAttributeChangedSignal("BBYAAdmin"):Connect(refreshAdmin)
player:GetAttributeChangedSignal("BBYAMusicMuted"):Connect(refreshCard)
ReplicatedStorage:GetAttributeChangedSignal("BBYAMusicCatalogReset"):Connect(function()
 if resetActive() then for _,s in pairs(state) do s.tracks={};s.title="";s.index=0;s.playing=false end end
 if layer.Visible then refreshCard();rebuildPlaylist() end
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(layout)end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(layout)end) end

task.defer(function()
 bindCommandMenu();layout();refreshCard()
 task.delay(.8,bindCommandMenu)
 task.delay(1.6,bindCommandMenu)
end)

print("[BBYA] Compact Music UI v7 online: Now Playing card / separate request drawer / 20Hz loudness wave / venue-aware")
