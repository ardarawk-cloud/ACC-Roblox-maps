-- BBYA SOCIAL HUB — VENUE-AWARE MENU MUSIC v4
-- One premium Music Suite, always bound to the player's actual venue.
-- MAIN/UNDERGROUND keep their native Music remote. VIP/FUNKOT/SKATEPARK/ROOFTOP
-- are bridged here so stale playlists never leak between venues and visible controls work.

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local LABELS={MAIN="CLUB",UNDERGROUND="UNDERGROUND",VIP="VIP",FUNKOT="FUNKOT",SKATEPARK="SKATEPARK",ROOFTOP="ROOFTOP",NONE="MUSIC"}
local ACCENT={VIP=Color3.fromRGB(232,181,82),FUNKOT=Color3.fromRGB(142,77,255),SKATEPARK=Color3.fromRGB(38,200,225),ROOFTOP=Color3.fromRGB(232,181,82)}
local WHITE=Color3.fromRGB(247,247,250)
local MUTED=Color3.fromRGB(146,150,164)
local CARD=Color3.fromRGB(21,22,30)
local REQUEST_BG=Color3.fromRGB(49,32,70)

local function currentVenue()
 local v=tostring(player:GetAttribute("BBYAAudioVenue") or "NONE")
 if v=="BASEMENT" then v="UNDERGROUND" end
 return LABELS[v] and v or "NONE"
end

local function isAdmin()
 return player:GetAttribute("BBYAAdmin")==true
  or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)
end

local function corner(o,r)
 local c=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,r or 8);c.Parent=o
 return c
end

local function label(p,n,t,pos,size,ts,col,align)
 local x=Instance.new("TextLabel")
 x.Name=n;x.BackgroundTransparency=1;x.Text=t;x.Position=pos;x.Size=size
 x.Font=Enum.Font.GothamBold;x.TextSize=ts or 8;x.TextColor3=col or WHITE
 x.TextXAlignment=align or Enum.TextXAlignment.Left;x.TextYAlignment=Enum.TextYAlignment.Center
 x.TextTruncate=Enum.TextTruncate.AtEnd;x.Parent=p
 return x
end

-- Command-menu venue label ---------------------------------------------------
local menuGui
local musicButton
local writing=false
local function resolveMenu()
 if menuGui and menuGui.Parent then return menuGui end
 menuGui=pg:FindFirstChild("BBYACommandMenuUI") or pg:WaitForChild("BBYACommandMenuUI",30)
 return menuGui
end
local function findMusicButton()
 local gui=resolveMenu();if not gui then return nil end
 if musicButton and musicButton.Parent and musicButton:GetAttribute("BBYACommandMenuId")=="MUSIC" then return musicButton end
 musicButton=nil
 for _,d in ipairs(gui:GetDescendants()) do
  if d:IsA("TextButton") and d:GetAttribute("BBYACommandMenuId")=="MUSIC" then musicButton=d;break end
 end
 return musicButton
end
local function updateMenuLabel()
 local b=findMusicButton();if not b then return end
 local text=LABELS[currentVenue()] or "MUSIC"
 if b.Text~=text then writing=true;b.Text=text;writing=false end
 b:SetAttribute("BBYAVenueAwareMusicLabel",text)
 if not b:GetAttribute("BBYAVenueAwareTextGuardV4") then
  b:SetAttribute("BBYAVenueAwareTextGuardV4",true)
  b:GetPropertyChangedSignal("Text"):Connect(function()if not writing then task.defer(updateMenuLabel) end end)
 end
end

-- Compact-panel mobile guard ------------------------------------------------
local currentCard,currentDrawer
local boundCard={}
local function viewport()
 camera=workspace.CurrentCamera or camera
 return (camera and camera.ViewportSize) or Vector2.new(1280,720)
end
local function findButton(parent,name)
 local b=parent and parent:FindFirstChild(name)
 return b and b:IsA("GuiButton") and b or nil
end
local function guardCard(card)
 if not card or not card.Parent then return end
 local vp=viewport();local cw=card.AbsoluteSize.X;local ch=card.AbsoluteSize.Y
 if cw<=0 then cw=card.Size.X.Offset end;if ch<=0 then ch=card.Size.Y.Offset end
 local maxW=math.max(286,vp.X-24)
 if cw>maxW then card.Size=UDim2.fromOffset(maxW,math.max(158,ch));cw=maxW end
 card.ClipsDescendants=true
 local playlist=findButton(card,"PlaylistButtonV7")
 local mute=findButton(card,"MuteButtonV7")
 local prev=findButton(card,"AdminPreviousV7")
 local nextB=findButton(card,"AdminNextV7")
 if not playlist or not mute or not prev or not nextB then return end
 local pad,gap,h=14,6,30;local total=math.max(258,cw-pad*2);local y=math.max(116,ch-42)
 if prev.Visible or nextB.Visible then
  local pw=math.clamp(math.floor(total*.13),42,58);local mw=math.clamp(math.floor(total*.22),60,82)
  local lw=math.max(92,total-(pw+pw+mw+gap*3));local x=pad
  playlist.Position=UDim2.fromOffset(x,y);playlist.Size=UDim2.fromOffset(lw,h);x+=lw+gap
  mute.Position=UDim2.fromOffset(x,y);mute.Size=UDim2.fromOffset(mw,h);x+=mw+gap
  prev.Position=UDim2.fromOffset(x,y);prev.Size=UDim2.fromOffset(pw,h);x+=pw+gap
  nextB.Position=UDim2.fromOffset(x,y);nextB.Size=UDim2.fromOffset(math.max(42,cw-pad-x),h)
 else
  local mw=math.clamp(math.floor(total*.36),74,120);local lw=total-gap-mw
  playlist.Position=UDim2.fromOffset(pad,y);playlist.Size=UDim2.fromOffset(lw,h)
  mute.Position=UDim2.fromOffset(pad+lw+gap,y);mute.Size=UDim2.fromOffset(mw,h)
 end
 card:SetAttribute("BBYAMobileControlsGuard","V4")
end
local function scanCompact()
 local club=pg:FindFirstChild("BBYAClubUI");local layer=club and club:FindFirstChild("BBYACompactMusicLayerV7")
 if not layer then return end
 local card=layer:FindFirstChild("CompactMusicCardV7");local drawer=layer:FindFirstChild("PlaylistDrawerV7")
 if card then
  currentCard=card
  if not boundCard[card] then boundCard[card]=true;card:GetPropertyChangedSignal("Size"):Connect(function()task.defer(function()guardCard(card)end)end) end
  guardCard(card)
 end
 if drawer then
  currentDrawer=drawer;local vp=viewport();local w=drawer.AbsoluteSize.X;local h=drawer.AbsoluteSize.Y
  if w>0 and h>0 and (w>vp.X-24 or h>vp.Y-24) then drawer.Size=UDim2.fromOffset(math.min(w,vp.X-24),math.min(h,vp.Y-24)) end
  drawer.ClipsDescendants=true;drawer:SetAttribute("BBYAMobileDrawerGuard","V4")
 end
end

-- Premium suite helpers -----------------------------------------------------
local function suiteParts()
 local suite=pg:FindFirstChild("BBYAMusicSuiteV1")
 if not suite then return nil end
 return suite,suite:FindFirstChild("LIBRARY",true),suite:FindFirstChild("NOW",true),suite:FindFirstChild("QUEUE",true)
end
local function directScroll(page)
 if not page then return nil end
 for _,d in ipairs(page:GetChildren()) do if d:IsA("ScrollingFrame") then return d end end
 return nil
end
local function anyScroll(page)
 if not page then return nil end
 for _,d in ipairs(page:GetDescendants()) do if d:IsA("ScrollingFrame") then return d end end
 return nil
end
local function findUpList(nowPage)
 if not nowPage then return nil end
 for _,d in ipairs(nowPage:GetDescendants()) do
  if d:IsA("ScrollingFrame") then
   local p=d.Parent;local t=p and p:FindFirstChild("Title")
   if t and t:IsA("TextLabel") and t.Text=="UP NEXT" then return d end
  end
 end
 return nil
end
local function chipValue(page,heading)
 if not page then return nil end
 for _,h in ipairs(page:GetDescendants()) do
  if h:IsA("TextLabel") and h.Name=="H" and h.Text==heading then
   local v=h.Parent and h.Parent:FindFirstChild("V")
   if v and v:IsA("TextLabel") then return v end
  end
 end
 return nil
end
local function clearRows(parent,prefix)
 if not parent then return end
 for _,d in ipairs(parent:GetChildren()) do if d:IsA("Frame") and d.Name:sub(1,#prefix)==prefix then d:Destroy() end end
end
local function fmt(sec)
 sec=math.max(0,math.floor(tonumber(sec) or 0));return string.format("%02d:%02d",math.floor(sec/60),sec%60)
end

-- Venue sources -------------------------------------------------------------
local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local vipRemote=remotes and remotes:FindFirstChild("VIPMusic")
local funkotRemote=remotes and remotes:FindFirstChild("FunkotMusic")
local skateControl=ReplicatedStorage:FindFirstChild("BBYASkateparkMusicControl") or ReplicatedStorage:WaitForChild("BBYASkateparkMusicControl",30)
local rooftopControl=ReplicatedStorage:FindFirstChild("BBYARooftopMusicControl") or ReplicatedStorage:WaitForChild("BBYARooftopMusicControl",30)
local cache={VIP={tracks={},state={}},FUNKOT={tracks={},state={}}}

local function normalizeList(list)
 local out={}
 for i,t in ipairs(type(list)=="table" and list or {}) do
  out[i]={title=tostring(t.title or ("Track "..i)),assetId=tostring(t.assetId or t.id or ""),playbackSpeed=tonumber(t.playbackSpeed) or 1,style=tostring(t.style or t.genre or "")}
 end
 return out
end
local function folderTracks(name)
 local folder=ReplicatedStorage:FindFirstChild(name);if not folder then return {} end
 local indexed={}
 for _,row in ipairs(folder:GetChildren()) do
  if row:IsA("StringValue") then
   local i=tonumber(row:GetAttribute("Index"))
   if i then indexed[i]={title=row.Value,assetId=tostring(row:GetAttribute("AssetId") or ""),playbackSpeed=tonumber(row:GetAttribute("PlaybackSpeed")) or 1} end
  end
 end
 local out={};for i=1,#indexed do if indexed[i] then table.insert(out,indexed[i]) end end
 return out
end
local function tracksFor(v)
 if v=="SKATEPARK" then return folderTracks("BBYASkateparkPlaylistCatalog") end
 if v=="ROOFTOP" then return folderTracks("BBYARooftopPlaylistCatalog") end
 if cache[v] then return cache[v].tracks end
 return {}
end
local function requestData(v)
 if v=="VIP" and vipRemote then vipRemote:FireServer("list")
 elseif v=="FUNKOT" and funkotRemote then funkotRemote:FireServer("list") end
end

if vipRemote then vipRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist" then cache.VIP.tracks=normalizeList(data)
 elseif kind=="state" and type(data)=="table" then cache.VIP.state=data end
end) end
if funkotRemote then funkotRemote.OnClientEvent:Connect(function(kind,data)
 if kind=="playlist" then cache.FUNKOT.tracks=normalizeList(data)
 elseif kind=="state" and type(data)=="table" then cache.FUNKOT.state=data end
end) end

local function venueState(v,tracks)
 local s={index=1,title="",playing=false,queue=0,nextRequest=0,sound=nil}
 if v=="SKATEPARK" then
  s.index=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkCurrentIndex")) or 1
  s.title=tostring(ReplicatedStorage:GetAttribute("BBYASkateparkCurrentTitle") or "")
  s.queue=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkQueueCount")) or 0
  s.nextRequest=tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkNextRequestIndex")) or 0
  s.sound=SoundService:FindFirstChild("BBYASkateparkMasterSound")
 elseif v=="ROOFTOP" then
  s.index=tonumber(ReplicatedStorage:GetAttribute("BBYARooftopCurrentIndex")) or 1
  s.title=tostring(ReplicatedStorage:GetAttribute("BBYARooftopCurrentTitle") or "")
  s.queue=tonumber(ReplicatedStorage:GetAttribute("BBYARooftopQueueCount")) or 0
  s.nextRequest=tonumber(ReplicatedStorage:GetAttribute("BBYARooftopNextRequestIndex")) or 0
  s.sound=SoundService:FindFirstChild("BBYARooftopMasterSound")
 elseif v=="VIP" then
  local c=cache.VIP.state
  s.index=tonumber(c.index or ReplicatedStorage:GetAttribute("BBYAVIPCurrentIndex")) or 1
  s.title=tostring(c.title or ReplicatedStorage:GetAttribute("BBYAVIPCurrentTitle") or "")
  s.playing=c.playing==true;s.sound=SoundService:FindFirstChild("BBYAVIPPlaylist")
 elseif v=="FUNKOT" then
  local c=cache.FUNKOT.state;local g=SoundService:FindFirstChild("BBYAFunkotMaster")
  s.index=tonumber(c.index or (g and g:GetAttribute("CurrentTrackIndex"))) or 1
  s.title=tostring(c.title or ReplicatedStorage:GetAttribute("BBYAFunkotCurrentTitle") or "")
  s.queue=tonumber(c.queue) or 0;s.playing=c.playing==true;s.sound=SoundService:FindFirstChild("BBYAFunkotRuntimeV6")
 end
 if s.title=="" and tracks[s.index] then s.title=tracks[s.index].title end
 if s.sound then s.playing=s.sound.IsPlaying end
 return s
end

local function sendRequest(v,i)
 if v=="SKATEPARK" and skateControl then skateControl:FireServer("request",i)
 elseif v=="ROOFTOP" and rooftopControl then rooftopControl:FireServer("request",i)
 elseif v=="VIP" and vipRemote and isAdmin() then vipRemote:FireServer("request",i)
 elseif v=="FUNKOT" and funkotRemote then funkotRemote:FireServer("request",i) end
end
local function sendTransport(v,action)
 if not isAdmin() then return end
 if v=="SKATEPARK" and skateControl then skateControl:FireServer(action)
 elseif v=="ROOFTOP" and rooftopControl then rooftopControl:FireServer(action)
 elseif v=="VIP" and vipRemote then vipRemote:FireServer(action=="prev" and "previous" or action)
 elseif v=="FUNKOT" and funkotRemote and action=="next" then funkotRemote:FireServer("next") end
end

-- All non-core venue rendering ---------------------------------------------
local transportBound={}
local lastSignature=""
local function rebuildLibrary(suite,lib,v,tracks,state)
 local list=directScroll(lib);if not list then return end
 clearRows(list,"Track_")
 local search=lib:FindFirstChildWhichIsA("TextBox",true);local q=string.lower(search and search.Text or "")
 local shown=0;local a=ACCENT[v] or WHITE
 for i,t in ipairs(tracks) do
  local meta=(v=="SKATEPARK" and math.abs((t.playbackSpeed or 1)-1)>.001) and string.format("%s • %.2fx",v,t.playbackSpeed) or v
  if q=="" or string.find(string.lower(t.title.." "..meta),q,1,true) then
   shown+=1
   local r=Instance.new("Frame");r.Name="Track_"..i;r.LayoutOrder=i;r.Size=UDim2.new(1,-2,0,42);r.BackgroundColor3=CARD;r.BorderSizePixel=0;r.Parent=list;corner(r,8)
   local playing=state.index==i and state.playing
   label(r,"No",string.format("%02d",i),UDim2.fromOffset(5,0),UDim2.fromOffset(34,42),7,playing and a or MUTED,Enum.TextXAlignment.Center)
   label(r,"Title",t.title,UDim2.fromOffset(45,3),UDim2.new(1,-180,0,21),9,WHITE)
   label(r,"Meta",meta,UDim2.fromOffset(45,22),UDim2.new(1,-180,0,15),6,MUTED)
   if playing then label(r,"Playing","PLAYING",UDim2.new(1,-204,0,0),UDim2.fromOffset(70,42),6,a,Enum.TextXAlignment.Center) end
   local b=Instance.new("TextButton");b.Name="Req";b.Text=(v=="VIP") and "PLAY" or "REQUEST";b.Position=UDim2.new(1,-118,0,6);b.Size=UDim2.fromOffset(104,30);b.BackgroundColor3=REQUEST_BG;b.BorderSizePixel=0;b.TextColor3=WHITE;b.Font=Enum.Font.GothamBold;b.TextSize=7;b.Parent=r;corner(b,8)
   local allowed=not playing and (v~="VIP" or isAdmin())
   b.Active=allowed;b.AutoButtonColor=allowed;if not allowed then b.TextColor3=MUTED end
   if allowed then b.Activated:Connect(function()sendRequest(v,i)end) end
  end
 end
 local metaLabel=lib:FindFirstChild("Meta");if metaLabel and metaLabel:IsA("TextLabel") then metaLabel.Text=string.format("%d / %d TRACKS",shown,#tracks) end
 local tv=chipValue(lib,"TRACKS");if tv then tv.Text=tostring(#tracks);tv.TextColor3=a end
 local vv=chipValue(lib,"VENUE");if vv then vv.Text=LABELS[v] or v;vv.TextColor3=a end
 local qv=chipValue(lib,"QUEUE");if qv then qv.Text=tostring(state.queue or 0) end
 local sv=suite:FindFirstChild("SV",true);if sv and sv:IsA("TextLabel") then sv.Text=tostring(#tracks).." TRACKS READY" end
end

local function mini(parent,name,no,titleText,meta,col)
 local r=Instance.new("Frame");r.Name=name;r.Size=UDim2.new(1,-2,0,46);r.BackgroundColor3=CARD;r.BorderSizePixel=0;r.Parent=parent;corner(r,8)
 label(r,"No",tostring(no),UDim2.fromOffset(4,0),UDim2.fromOffset(28,46),8,col or MUTED,Enum.TextXAlignment.Center)
 label(r,"T",titleText,UDim2.fromOffset(38,4),UDim2.new(1,-44,0,22),8,WHITE)
 label(r,"M",meta,UDim2.fromOffset(38,24),UDim2.new(1,-44,0,16),6,MUTED)
end

local function rebuildUpNext(nowPage,v,tracks,state)
 local list=findUpList(nowPage);if not list or #tracks==0 then return end
 clearRows(list,"Next_");local used={};local order=0;local a=ACCENT[v] or WHITE
 local function add(i,meta)
  if not tracks[i] or used[i] then return end;order+=1;used[i]=true;mini(list,"Next_"..order,order,tracks[i].title,meta,meta=="REQUEST QUEUE" and Color3.fromRGB(232,181,82) or a)
 end
 if state.nextRequest and state.nextRequest>0 then add(state.nextRequest,"REQUEST QUEUE") end
 local i=math.max(state.index or 1,1)
 while order<5 and order<#tracks do i=(i%#tracks)+1;add(i,"AUTO DJ") end
end

local function rebuildQueue(queuePage,v,tracks,state)
 local list=anyScroll(queuePage);if not list then return end
 clearRows(list,"Queue_")
 local meta=queuePage:FindFirstChild("Meta");if meta and meta:IsA("TextLabel") then meta.Text=tostring(state.queue or 0).." REQUESTS" end
 if (state.queue or 0)<=0 then mini(list,"Queue_Empty","--","REQUEST QUEUE KOSONG","Pilih lagu di Library lalu tekan REQUEST",MUTED)
 elseif state.nextRequest and state.nextRequest>0 and tracks[state.nextRequest] then mini(list,"Queue_1","01",tracks[state.nextRequest].title,"NEXT REQUEST",Color3.fromRGB(232,181,82))
 else mini(list,"Queue_Info","+",tostring(state.queue).." REQUEST","Antrean aktif di server",ACCENT[v] or WHITE) end
end

local function bindTransport(nowPage,v)
 if not nowPage then return end
 local nextB=nowPage:FindFirstChild("Next",true);local prev=nowPage:FindFirstChild("Prev",true)
 for _,pair in ipairs({{nextB,"next"},{prev,"prev"}}) do
  local b,action=pair[1],pair[2]
  if b and b:IsA("GuiButton") and not transportBound[b] then
   transportBound[b]=true
   b.Activated:Connect(function()
    local venueNow=currentVenue()
    if venueNow=="VIP" or venueNow=="FUNKOT" or venueNow=="SKATEPARK" or venueNow=="ROOFTOP" then sendTransport(venueNow,action) end
   end)
  end
 end
 if v=="VIP" or v=="SKATEPARK" or v=="ROOFTOP" then
  if nextB then nextB.Visible=isAdmin();nextB.Active=isAdmin() end
  if prev then prev.Visible=isAdmin();prev.Active=isAdmin() end
 elseif v=="FUNKOT" then
  if nextB then nextB.Visible=isAdmin();nextB.Active=isAdmin() end
  if prev then prev.Visible=false;prev.Active=false end
 end
end

local function refreshPeripheral(force)
 local v=currentVenue()
 if v=="MAIN" or v=="UNDERGROUND" or v=="NONE" then lastSignature="";return end
 local suite,lib,nowPage,queuePage=suiteParts();if not suite or not suite.Enabled or not lib or not nowPage then return end
 local tracks=tracksFor(v)
 if #tracks==0 then requestData(v);return end
 local state=venueState(v,tracks)
 local search=lib:FindFirstChildWhichIsA("TextBox",true)
 local signature=table.concat({v,#tracks,state.index,state.title,tostring(state.playing),state.queue,state.nextRequest,search and search.Text or ""},"|")
 if force or signature~=lastSignature then rebuildLibrary(suite,lib,v,tracks,state);lastSignature=signature end
 local trackLabel=nowPage:FindFirstChild("Track",true)
 if trackLabel and trackLabel:IsA("TextLabel") then trackLabel.Text=state.title~="" and state.title or "BELUM ADA LAGU" end
 local info=trackLabel and trackLabel.Parent;local meta=info and info:FindFirstChild("Meta");local st=info and info:FindFirstChild("State")
 if meta and meta:IsA("TextLabel") then meta.Text=(LABELS[v] or v).."  •  "..tostring(#tracks).." TRACKS" end
 if st and st:IsA("TextLabel") then st.Text=state.playing and "LIVE • PLAYING" or "STANDBY";st.TextColor3=state.playing and Color3.fromRGB(73,215,143) or MUTED end
 local elapsed=suite:FindFirstChild("Elapsed",true);local duration=suite:FindFirstChild("Duration",true)
 if elapsed and elapsed:IsA("TextLabel") then elapsed.Text=fmt(state.sound and state.sound.TimePosition or 0) end
 if duration and duration:IsA("TextLabel") then duration.Text=fmt(state.sound and state.sound.TimeLength or 0) end
 bindTransport(nowPage,v);rebuildUpNext(nowPage,v,tracks,state);rebuildQueue(queuePage,v,tracks,state)
 suite:SetAttribute("BBYAAllVenueMusicSuiteBridge","V4")
end

local function onVenueChanged()
 updateMenuLabel();scanCompact();local v=currentVenue();requestData(v);lastSignature="";task.defer(function()refreshPeripheral(true)end)
end
player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(onVenueChanged)
player:GetAttributeChangedSignal("BBYAAdmin"):Connect(function()lastSignature="";task.defer(function()refreshPeripheral(true)end)end)
pg.ChildAdded:Connect(function(child)if child.Name=="BBYACommandMenuUI" then menuGui=child;musicButton=nil end;task.defer(onVenueChanged)end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(scanCompact)end)

local acc=0
RunService.Heartbeat:Connect(function(dt)
 acc+=dt;if acc<.30 then return end;acc=0
 updateMenuLabel();scanCompact();refreshPeripheral(false)
end)

for i=0,12 do task.delay(i*.25,function()onVenueChanged()end) end
print("[BBYA] Venue-aware menu music v4 online: MAIN + UNDERGROUND native; VIP + FUNKOT + SKATEPARK + ROOFTOP bound to their own playlists")
