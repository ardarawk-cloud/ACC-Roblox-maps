-- BBYA SOCIAL HUB — MUSIC PLAYER v5 SINGLE AUTHORITY
-- One compact presentation authority. Reads venue catalogs/remotes only; never mutates SoundId/Volume/PlaybackSpeed.
-- Viewer: PLAYLIST / REQUEST / FAV. Owner/admin adds NEXT.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local clubUI=pg:WaitForChild("BBYAClubUI",30);if not clubUI then return end
local hub=clubUI:WaitForChild("HubPanel",30);if not hub then return end
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30);if not remotes then return end
local mainRemote=remotes:WaitForChild("Music",30)
local stateRemote=remotes:WaitForChild("State",30)
local vipRemote=remotes:FindFirstChild("VIPMusic")
local funkotRemote=remotes:FindFirstChild("FunkotMusic")

local C={bg=Color3.fromRGB(8,9,13),panel=Color3.fromRGB(18,19,25),card=Color3.fromRGB(28,29,37),white=Color3.fromRGB(247,247,250),muted=Color3.fromRGB(147,151,164),line=Color3.fromRGB(73,76,89),pink=Color3.fromRGB(236,53,165),cyan=Color3.fromRGB(43,198,226),gold=Color3.fromRGB(232,183,86),purple=Color3.fromRGB(145,84,255),green=Color3.fromRGB(79,216,145)}
local VENUES={MAIN={label="CLUB",accent=C.pink},UNDERGROUND={label="UNDERGROUND",accent=C.cyan},VIP={label="VIP",accent=C.gold},FUNKOT={label="FUNKOT",accent=C.purple},SKATEPARK={label="SKATEPARK",accent=C.cyan},ROOFTOP={label="ROOFTOP",accent=C.gold},MALL={label="MALL",accent=C.gold},NIGHT_MARKET={label="PASAR MALAM",accent=C.gold},NONE={label="BBYA MUSIC",accent=C.purple}}
local FOLDERS={SKATEPARK="BBYASkateparkPlaylistCatalog",ROOFTOP="BBYARooftopPlaylistCatalog",MALL="BBYAMallPlaylistCatalog",NIGHT_MARKET="BBYANightMarketPlaylistCatalog"}
local ATTRS={SKATEPARK={"BBYASkateparkCurrentIndex","BBYASkateparkCurrentTitle","BBYASkateparkNextRequestIndex"},ROOFTOP={"BBYARooftopCurrentIndex","BBYARooftopCurrentTitle","BBYARooftopNextRequestIndex"},MALL={"BBYAMallCurrentIndex","BBYAMallCurrentTitle","BBYAMallNextRequestIndex"},NIGHT_MARKET={"BBYANightMarketCurrentIndex","BBYANightMarketCurrentTitle",nil}}
local SOUNDS={MAIN={"BBYAClubDeckA","BBYAClubDeckB"},UNDERGROUND={"BBYABasementDeckA","BBYABasementDeckB"},VIP={"BBYAVIPPlaylist"},FUNKOT={"BBYAFunkotRuntimeV6","BBYAFunkotDeck"},SKATEPARK={"BBYASkateparkMasterSound"},ROOFTOP={"BBYARooftopMasterSound","BBYARooftopPlaylist"},MALL={"BBYAMallMasterSound"},NIGHT_MARKET={"BBYANightMarketMasterSound"}}

local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,c,tr)local s=Instance.new("UIStroke");s.Color=c or C.line;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o;return s end
local function frame(p,n,pos,size,bg,tr,r)local f=Instance.new("Frame");f.Name=n;f.Position=pos or UDim2.new();f.Size=size or UDim2.new();f.BackgroundColor3=bg or C.panel;f.BackgroundTransparency=tr or .18;f.BorderSizePixel=0;f.Parent=p;if r then corner(f,r)end;return f end
local function label(p,n,t,pos,size,font,ts,col,align)local l=Instance.new("TextLabel");l.Name=n;l.BackgroundTransparency=1;l.Text=t;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=col or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.TextTruncate=Enum.TextTruncate.AtEnd;l.Parent=p;return l end
local function button(p,n,t,pos,size,bg)local b=Instance.new("TextButton");b.Name=n;b.Text=t;b.Position=pos or UDim2.new();b.Size=size or UDim2.new();b.BackgroundColor3=bg or C.card;b.BackgroundTransparency=.10;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=8;b.AutoButtonColor=true;b.Parent=p;corner(b,8);stroke(b,C.line,.58);return b end
local function isOwner()return player:GetAttribute("BBYAAdmin")==true or player:GetAttribute("BBYAOwner")==true or(game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)or string.lower(player.Name)=="nadmo97"end
local function venue()local v=tostring(player:GetAttribute("BBYAAudioVenue")or"NONE");if v=="BASEMENT"then v="UNDERGROUND"end;return VENUES[v]and v or"NONE"end
local function normalize(list)local out={};for i,t in ipairs(type(list)=="table"and list or{})do out[i]={title=tostring(t.title or("Track "..i)),artist=tostring(t.artist or t.style or t.genre or""),assetId=tostring(t.assetId or t.id or"")}end;return out end
local function catalog(name)local folder=ReplicatedStorage:FindFirstChild(name);local rows={};if not folder then return rows end;for _,v in ipairs(folder:GetChildren())do if v:IsA("StringValue")then table.insert(rows,{index=tonumber(v:GetAttribute("Index"))or 999,title=v.Value,artist=tostring(v:GetAttribute("Artist")or v:GetAttribute("Style")or""),assetId=tostring(v:GetAttribute("AssetId")or"")})end end;table.sort(rows,function(a,b)return a.index<b.index end);local out={};for _,r in ipairs(rows)do table.insert(out,{title=r.title,artist=r.artist,assetId=r.assetId})end;return out end

local cache={MAIN={tracks={},state={}},UNDERGROUND={tracks={},state={}},VIP={tracks={},state={}},FUNKOT={tracks={},state={}}}
local favorites={}
local function tracksFor(v)if FOLDERS[v]then return catalog(FOLDERS[v])end;return cache[v]and cache[v].tracks or{}end
local function soundFor(v)for _,n in ipairs(SOUNDS[v]or{})do local s=SoundService:FindFirstChild(n,true);if s and s:IsA("Sound")then return s end end end
local function stateFor(v,tracks)
 local s={index=1,title="",playing=false,nextRequest=0}
 if ATTRS[v]then local a=ATTRS[v];s.index=tonumber(ReplicatedStorage:GetAttribute(a[1]))or 1;s.title=tostring(ReplicatedStorage:GetAttribute(a[2])or"");s.nextRequest=a[3]and(tonumber(ReplicatedStorage:GetAttribute(a[3]))or 0)or 0
 elseif cache[v]then local c=cache[v].state or{};s.index=tonumber(c.index)or 1;s.title=tostring(c.title or"");s.playing=c.playing==true;s.nextRequest=tonumber(c.nextRequest)or 0 end
 if s.title==""and tracks[s.index]then s.title=tracks[s.index].title end
 local snd=soundFor(v);if snd then s.playing=snd.IsPlaying end
 return s,snd
end
local function remoteControl(v,action,index)
 if v=="MAIN"or v=="UNDERGROUND"then mainRemote:FireServer(action,index)
 elseif v=="VIP"and vipRemote then vipRemote:FireServer(action,index)
 elseif v=="FUNKOT"and funkotRemote then funkotRemote:FireServer(action,index)
 else local rn=({SKATEPARK="BBYASkateparkMusicControl",ROOFTOP="BBYARooftopMusicControl",MALL="BBYAMallMusicControl",NIGHT_MARKET="BBYANightMarketMusicControl"})[v];local r=rn and ReplicatedStorage:FindFirstChild(rn);if r and r:IsA("RemoteEvent")then r:FireServer(action,index)end end
end
local function requestList(v)if v=="MAIN"or v=="UNDERGROUND"then mainRemote:FireServer("list")elseif v=="VIP"and vipRemote then vipRemote:FireServer("list")elseif v=="FUNKOT"and funkotRemote then funkotRemote:FireServer("list")end end

local old=pg:FindFirstChild("BBYAMusicPlayerV5");if old then old:Destroy()end
for _,n in ipairs({"BBYAMusicSuiteV1","BBYACompactMusicLayerV7"})do local g=pg:FindFirstChild(n);if g then g:Destroy()end end
local gui=Instance.new("ScreenGui");gui.Name="BBYAMusicPlayerV5";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=930;gui.Enabled=false;gui.Parent=pg;gui:SetAttribute("BBYAUIAuthority","MUSIC_PLAYER_V5_SINGLE_AUTHORITY")
local shell=frame(gui,"MusicPanel",UDim2.new(1,-18,.5,18),UDim2.fromOffset(400,400),C.bg,.13,20);shell.AnchorPoint=Vector2.new(1,.5);local shellStroke=stroke(shell,C.purple,.20)
local hero=frame(shell,"Hero",UDim2.fromOffset(12,12),UDim2.new(1,-24,0,142),C.panel,.16,16)
local venueText=label(hero,"Venue","BBYA MUSIC",UDim2.fromOffset(14,10),UDim2.new(.52,0,0,16),Enum.Font.GothamBold,8,C.muted)
local title=label(hero,"NowPlaying","BELUM ADA LAGU",UDim2.fromOffset(14,30),UDim2.new(1,-62,0,28),Enum.Font.GothamBlack,16,C.white)
local stateText=label(hero,"State","STANDBY",UDim2.fromOffset(14,59),UDim2.new(.5,0,0,16),Enum.Font.GothamBold,8,C.green)
local close=button(hero,"Close","×",UDim2.new(1,-42,0,10),UDim2.fromOffset(30,30),C.card);close.TextSize=16
local wave=frame(hero,"Wave",UDim2.new(.60,0,0,55),UDim2.new(.34,0,0,38),C.panel,1);local bars={};for i=1,15 do local b=frame(wave,"B"..i,UDim2.new((i-.5)/15,0,1,0),UDim2.new(.04,0,0,7+((i*9)%20)),i%5==0 and C.cyan or C.white,.35,3);b.AnchorPoint=Vector2.new(.5,1);bars[i]=b end
local rail=frame(hero,"Progress",UDim2.fromOffset(14,102),UDim2.new(1,-28,0,4),C.card,0,3);local fill=frame(rail,"Fill",UDim2.new(),UDim2.new(0,0,1,0),C.purple,0,3)
local elapsed=label(hero,"Elapsed","00:00",UDim2.fromOffset(14,109),UDim2.fromOffset(58,14),Enum.Font.GothamBold,7,C.muted);local duration=label(hero,"Duration","00:00",UDim2.new(1,-72,0,109),UDim2.fromOffset(58,14),Enum.Font.GothamBold,7,C.muted,Enum.TextXAlignment.Right)

local body=frame(shell,"Body",UDim2.fromOffset(12,164),UDim2.new(1,-24,1,-214),C.panel,.24,14);stroke(body,C.line,.62)
local bodyTitle=label(body,"Title","UP NEXT",UDim2.fromOffset(12,6),UDim2.new(1,-24,0,20),Enum.Font.GothamBlack,10,C.white)
local list=Instance.new("ScrollingFrame");list.Position=UDim2.fromOffset(9,30);list.Size=UDim2.new(1,-18,1,-38);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.ScrollBarThickness=2;list.Parent=body;local ll=Instance.new("UIListLayout");ll.Padding=UDim.new(0,4);ll.Parent=list

local controls=frame(shell,"Controls",UDim2.new(0,12,1,-40),UDim2.new(1,-24,0,28),C.panel,1)
local controlButtons={};local ctl=Instance.new("UIListLayout");ctl.FillDirection=Enum.FillDirection.Horizontal;ctl.HorizontalAlignment=Enum.HorizontalAlignment.Center;ctl.Padding=UDim.new(0,5);ctl.Parent=controls
local function ctlButton(n,t,order)local b=button(controls,n,t,nil,UDim2.fromOffset(80,28),C.card);b.LayoutOrder=order;controlButtons[n]=b;return b end
local playlistB=ctlButton("Playlist","PLAYLIST",1);local requestB=ctlButton("Request","REQUEST",2);local favB=ctlButton("Fav","FAV",3);local nextB=ctlButton("Next","NEXT",4)

local mode="NOW";local currentTracks={};local currentState={};local activeSound=nil
local function favKey(v,i)return v..":"..tostring(i)end
local function clearRows()for _,c in ipairs(list:GetChildren())do if c:IsA("GuiObject")and c~=ll then c:Destroy()end end end
local function row(index,item,kind)
 local r=frame(list,"Row"..index,nil,UDim2.new(1,-2,0,32),C.card,.10,8);label(r,"Index",string.format("%02d",index),UDim2.fromOffset(7,0),UDim2.fromOffset(26,32),Enum.Font.GothamBlack,7,(VENUES[venue()]or VENUES.NONE).accent,Enum.TextXAlignment.Center);label(r,"Track",item.title or("Track "..index),UDim2.fromOffset(37,1),UDim2.new(1,-82,0,18),Enum.Font.GothamBold,8,C.white);label(r,"Meta",item.artist or"",UDim2.fromOffset(37,17),UDim2.new(1,-82,0,12),Enum.Font.Gotham,6,C.muted)
 if kind=="REQUEST"then local b=button(r,"Req","REQUEST",UDim2.new(1,-62,0,5),UDim2.fromOffset(56,22),Color3.fromRGB(54,34,83));b.TextSize=6;b.Activated:Connect(function()remoteControl(venue(),"request",index)end)else local k=favKey(venue(),index);local b=button(r,"Fav",favorites[k]and"♥"or"♡",UDim2.new(1,-30,0,5),UDim2.fromOffset(24,22),C.card);b.TextColor3=favorites[k]and C.pink or C.muted;b.Activated:Connect(function()if favorites[k]then favorites[k]=nil else favorites[k]=true end;b.Text=favorites[k]and"♥"or"♡";b.TextColor3=favorites[k]and C.pink or C.muted end)end
end
local function render()
 clearRows();local v=venue();if mode=="NOW"then bodyTitle.Text="UP NEXT";if #currentTracks==0 then row(0,{title="PLAYLIST LOADING...",artist=v},"UP");return end;local order={};local used={};local rq=tonumber(currentState.nextRequest)or 0;if rq>0 and currentTracks[rq]then table.insert(order,rq);used[rq]=true end;local cur=math.max(1,tonumber(currentState.index)or 1);while #order<3 and #order<#currentTracks do cur=(cur%#currentTracks)+1;if not used[cur]then table.insert(order,cur);used[cur]=true end end;for _,i in ipairs(order)do row(i,currentTracks[i],"UP")end;return end
 bodyTitle.Text=mode;if mode=="FAV"then for i,it in ipairs(currentTracks)do if favorites[favKey(v,i)]then row(i,it,"FAV")end end;return end;if #currentTracks==0 then row(0,{title="PLAYLIST LOADING...",artist=v},mode);return end;for i,it in ipairs(currentTracks)do row(i,it,mode)end
end
local function fmt(sec)sec=math.max(0,math.floor(tonumber(sec)or 0));return string.format("%02d:%02d",math.floor(sec/60),sec%60)end
local function syncButtons()local count=isOwner()and 4 or 3;nextB.Visible=isOwner();local w=math.max(1,controls.AbsoluteSize.X);local each=math.floor((w-5*(count-1))/count);for _,b in ipairs({playlistB,requestB,favB,nextB})do if b.Visible then b.Size=UDim2.fromOffset(each,28)end end end
local function refresh()
 local v=venue();currentTracks=tracksFor(v);currentState,activeSound=stateFor(v,currentTracks);local spec=VENUES[v]or VENUES.NONE;shellStroke.Color=spec.accent;venueText.Text=spec.label;venueText.TextColor3=spec.accent;local t=currentState.title;if t==""and currentTracks[currentState.index]then t=currentTracks[currentState.index].title end;title.Text=t~=""and t or"BELUM ADA LAGU";stateText.Text=currentState.playing and"LIVE • PLAYING"or"STANDBY";stateText.TextColor3=currentState.playing and C.green or C.muted;render();syncButtons()
end
local function setMode(m)mode=(mode==m)and"NOW"or m;render();for n,b in pairs(controlButtons)do local active=(n=="Playlist"and mode=="PLAYLIST")or(n=="Request"and mode=="REQUEST")or(n=="Fav"and mode=="FAV");b.BackgroundColor3=active and Color3.fromRGB(59,37,86)or C.card end end
playlistB.Activated:Connect(function()setMode("PLAYLIST")end);requestB.Activated:Connect(function()setMode("REQUEST")end);favB.Activated:Connect(function()setMode("FAV")end);nextB.Activated:Connect(function()if isOwner()then remoteControl(venue(),"next")end end)
local function roleLauncher(v)local g=pg:FindFirstChild("BBYARolePanelUI");local b=g and g:FindFirstChild("RolePanelOpen",true);if b then b.Visible=v end end
local function closePanel()gui.Enabled=false;local menu=pg:FindFirstChild("BBYACommandMenuUI");local mb=menu and menu:FindFirstChild("MenuButton",true);if mb then mb.Visible=true end;roleLauncher(true)end;close.Activated:Connect(closePanel)
local bound={};local function openPlayer()hub.Visible=false;gui.Enabled=true;mode="NOW";requestList(venue());roleLauncher(false);task.delay(.06,refresh)end
local function bindMenu()local m=pg:FindFirstChild("BBYACommandMenuUI");local slot=m and m:FindFirstChild("Slot_MUSIC",true);if not slot then return end;for _,b in ipairs(slot:GetDescendants())do if b:IsA("TextButton")and not bound[b]then bound[b]=true;b.Activated:Connect(openPlayer)end end end
pg.DescendantAdded:Connect(function(d)if d:IsA("TextButton")then task.defer(bindMenu)end end)

stateRemote.OnClientEvent:Connect(function(kind,data)local v=venue();if kind=="playlist"and type(data)=="table"and(v=="MAIN"or v=="UNDERGROUND")then cache[v].tracks=normalize(data)elseif kind=="music"and type(data)=="table"then local dv=tostring(data.venue or v);if dv=="BASEMENT"then dv="UNDERGROUND"end;if cache[dv]then cache[dv].state=data end end;if gui.Enabled then refresh()end end)
if vipRemote then vipRemote.OnClientEvent:Connect(function(kind,data)if kind=="playlist"then cache.VIP.tracks=normalize(data)elseif kind=="state"and type(data)=="table"then cache.VIP.state=data end;if gui.Enabled and venue()=="VIP"then refresh()end end)end
if funkotRemote then funkotRemote.OnClientEvent:Connect(function(kind,data)if kind=="playlist"then cache.FUNKOT.tracks=normalize(data)elseif kind=="state"and type(data)=="table"then cache.FUNKOT.state=data end;if gui.Enabled and venue()=="FUNKOT"then refresh()end end)end
player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()if gui.Enabled then mode="NOW";requestList(venue());task.delay(.05,refresh)end end)
ReplicatedStorage.DescendantAdded:Connect(function(d)if gui.Enabled and(d:IsA("StringValue")or d:IsA("RemoteEvent"))then task.delay(.04,refresh)end end);ReplicatedStorage.DescendantRemoving:Connect(function(d)if gui.Enabled and d:IsA("StringValue")then task.defer(refresh)end end)
for _,a in ipairs({"BBYASkateparkCurrentIndex","BBYASkateparkCurrentTitle","BBYARooftopCurrentIndex","BBYARooftopCurrentTitle","BBYAMallCurrentIndex","BBYAMallCurrentTitle","BBYANightMarketCurrentIndex","BBYANightMarketCurrentTitle"})do ReplicatedStorage:GetAttributeChangedSignal(a):Connect(function()if gui.Enabled then refresh()end end)end

local cam=workspace.CurrentCamera
local function layout()cam=workspace.CurrentCamera or cam;local vp=cam and cam.ViewportSize or Vector2.new(1280,720);local size=math.clamp(math.min(vp.Y-84,420),330,420);shell.Size=UDim2.fromOffset(size,size);shell.Position=UDim2.new(1,-18,.5,18);syncButtons()end
if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()cam=workspace.CurrentCamera;if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end;layout()end)
local acc=0;RunService.RenderStepped:Connect(function(dt)if not gui.Enabled then return end;acc+=dt;if acc<.12 then return end;acc=0;if activeSound and activeSound.Parent then local len=tonumber(activeSound.TimeLength)or 0;local pos=tonumber(activeSound.TimePosition)or 0;fill.Size=UDim2.new(len>0 and math.clamp(pos/len,0,1)or 0,0,1,0);elapsed.Text=fmt(pos);duration.Text=fmt(len);local loud=math.clamp((activeSound.PlaybackLoudness or 0)/500,0,1);for i,b in ipairs(bars)do b.Size=UDim2.new(.04,0,0,7+math.floor(loud*(8+((i*7)%18))))end end end)
task.defer(function()layout();bindMenu();refresh()end)
print("[BBYA] Music Player v5 online: single compact authority / live venue catalogs / viewer 3 controls + owner NEXT")