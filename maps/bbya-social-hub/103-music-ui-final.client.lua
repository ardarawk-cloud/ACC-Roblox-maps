-- BBYA SOCIAL HUB — MUSIC PLAYER v4 CLEAN REBUILD
-- Rebuilt after repeated QC failure. One compact card only; no dashboard/sidebar/queue tabs.
-- Viewer controls: PLAYLIST / REQUEST / FAV. Owner/admin also gets NEXT.
-- Playlist data is read from existing venue authorities; this client NEVER changes SoundId, Volume or PlaybackSpeed.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local clubUI=pg:WaitForChild("BBYAClubUI",30);if not clubUI then return end
local hub=clubUI:WaitForChild("HubPanel",30);if not hub then return end
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30);if not remotes then return end
local music=remotes:WaitForChild("Music",30)
local stateRemote=remotes:WaitForChild("State",30)
local vipRemote=remotes:FindFirstChild("VIPMusic")
local funkotRemote=remotes:FindFirstChild("FunkotMusic")
local skateControl=ReplicatedStorage:FindFirstChild("BBYASkateparkMusicControl")
local rooftopControl=ReplicatedStorage:FindFirstChild("BBYARooftopMusicControl")
local mallControl=ReplicatedStorage:FindFirstChild("BBYAMallMusicControl")
local nightControl=ReplicatedStorage:FindFirstChild("BBYANightMarketMusicControl")

local C={bg=Color3.fromRGB(8,9,13),panel=Color3.fromRGB(18,19,25),card=Color3.fromRGB(28,29,37),white=Color3.fromRGB(247,247,250),muted=Color3.fromRGB(147,151,164),line=Color3.fromRGB(73,76,89),pink=Color3.fromRGB(236,53,165),cyan=Color3.fromRGB(43,198,226),gold=Color3.fromRGB(232,183,86),purple=Color3.fromRGB(145,84,255),green=Color3.fromRGB(79,216,145)}
local V={MAIN={label="CLUB",accent=C.pink},UNDERGROUND={label="UNDERGROUND",accent=C.cyan},VIP={label="VIP",accent=C.gold},FUNKOT={label="FUNKOT",accent=C.purple},SKATEPARK={label="SKATEPARK",accent=C.cyan},ROOFTOP={label="ROOFTOP",accent=C.gold},MALL={label="MALL",accent=C.gold},NIGHT_MARKET={label="PASAR MALAM",accent=C.gold},NONE={label="BBYA MUSIC",accent=C.purple}}
local FOLDERS={SKATEPARK="BBYASkateparkPlaylistCatalog",ROOFTOP="BBYARooftopPlaylistCatalog",MALL="BBYAMallPlaylistCatalog",NIGHT_MARKET="BBYANightMarketPlaylistCatalog"}
local STATE_ATTRS={
 SKATEPARK={"BBYASkateparkCurrentIndex","BBYASkateparkCurrentTitle","BBYASkateparkQueueCount","BBYASkateparkNextRequestIndex","BBYASkateparkMasterSound"},
 ROOFTOP={"BBYARooftopCurrentIndex","BBYARooftopCurrentTitle","BBYARooftopQueueCount","BBYARooftopNextRequestIndex","BBYARooftopMasterSound"},
 MALL={"BBYAMallCurrentIndex","BBYAMallCurrentTitle","BBYAMallQueueCount","BBYAMallNextRequestIndex","BBYAMallMasterSound"},
 NIGHT_MARKET={"BBYANightMarketCurrentIndex","BBYANightMarketCurrentTitle",nil,nil,"BBYANightMarketMasterSound"},
}
local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 10);x.Parent=o end
local function stroke(o,c,tr)local x=Instance.new("UIStroke");x.Color=c or C.line;x.Thickness=1;x.Transparency=tr or .45;x.Parent=o end
local function label(p,n,t,pos,size,font,ts,col,align)local x=Instance.new("TextLabel");x.Name=n;x.BackgroundTransparency=1;x.Text=t;x.Position=pos;x.Size=size;x.Font=font or Enum.Font.Gotham;x.TextSize=ts or 10;x.TextColor3=col or C.white;x.TextXAlignment=align or Enum.TextXAlignment.Left;x.TextYAlignment=Enum.TextYAlignment.Center;x.TextTruncate=Enum.TextTruncate.AtEnd;x.Parent=p;return x end
local function button(p,n,t,pos,size,bg)local b=Instance.new("TextButton");b.Name=n;b.Text=t;b.Position=pos or UDim2.new();b.Size=size or UDim2.new();b.BackgroundColor3=bg or C.card;b.BackgroundTransparency=.12;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=9;b.AutoButtonColor=true;b.Parent=p;corner(b,9);stroke(b,C.line,.58);return b end
local function frame(p,n,pos,size,bg,tr,r)local f=Instance.new("Frame");f.Name=n;f.Position=pos or UDim2.new();f.Size=size or UDim2.new();f.BackgroundColor3=bg or C.panel;f.BackgroundTransparency=tr or .18;f.BorderSizePixel=0;f.Parent=p;if r then corner(f,r)end;return f end

local function currentVenue()
 local v=tostring(player:GetAttribute("BBYAAudioVenue")or"NONE");if v=="BASEMENT"then v="UNDERGROUND"end
 return V[v]and v or"NONE"
end
local function isOwner()return player:GetAttribute("BBYAAdmin")==true or player:GetAttribute("BBYAOwner")==true or(game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)or string.lower(player.Name)=="nadmo97"end
local function folderTracks(name)
 local folder=ReplicatedStorage:FindFirstChild(name);if not folder then return{}end
 local indexed={}
 for _,row in ipairs(folder:GetChildren())do if row:IsA("StringValue")then local i=tonumber(row:GetAttribute("Index"));if i then indexed[i]={title=row.Value,assetId=tostring(row:GetAttribute("AssetId")or""),artist=tostring(row:GetAttribute("Artist")or""),style=tostring(row:GetAttribute("Style")or"")}end end end
 local out={};for i=1,#indexed do if indexed[i]then table.insert(out,indexed[i])end end;return out
end
local function normalize(list)
 local out={};for i,t in ipairs(type(list)=="table"and list or{})do out[i]={title=tostring(t.title or("Track "..i)),assetId=tostring(t.assetId or t.id or""),artist=tostring(t.artist or""),style=tostring(t.style or t.genre or"")}end;return out
end

local cache={MAIN={tracks={},state={}},UNDERGROUND={tracks={},state={}},VIP={tracks={},state={}},FUNKOT={tracks={},state={}}}
local favorites={}
local function favKey(v,i)return v..":"..tostring(i)end
local function venueTracks(v)
 if FOLDERS[v]then return folderTracks(FOLDERS[v])end
 return cache[v]and cache[v].tracks or{}
end
local function venueState(v,tracks)
 local s={index=1,title="",playing=false,queue=0,nextRequest=0,sound=nil}
 if STATE_ATTRS[v]then local a=STATE_ATTRS[v];s.index=tonumber(ReplicatedStorage:GetAttribute(a[1]))or 1;s.title=tostring(ReplicatedStorage:GetAttribute(a[2])or"");s.queue=a[3]and(tonumber(ReplicatedStorage:GetAttribute(a[3]))or 0)or 0;s.nextRequest=a[4]and(tonumber(ReplicatedStorage:GetAttribute(a[4]))or 0)or 0;s.sound=SoundService:FindFirstChild(a[5])
 elseif cache[v]then local c=cache[v].state or{};s.index=tonumber(c.index)or 1;s.title=tostring(c.title or"");s.playing=c.playing==true;s.queue=tonumber(c.queue)or 0;s.nextRequest=tonumber(c.nextRequest)or 0 end
 if s.title==""and tracks[s.index]then s.title=tracks[s.index].title end
 if s.sound and s.sound:IsA("Sound")then s.playing=s.sound.IsPlaying end
 return s
end
local function requestList(v)
 if v=="MAIN"or v=="UNDERGROUND"then music:FireServer("list")
 elseif v=="VIP"and vipRemote then vipRemote:FireServer("list")
 elseif v=="FUNKOT"and funkotRemote then funkotRemote:FireServer("list")end
end
local function requestTrack(v,i)
 if v=="MAIN"or v=="UNDERGROUND"then music:FireServer("request",i)
 elseif v=="VIP"and vipRemote then vipRemote:FireServer("request",i)
 elseif v=="FUNKOT"and funkotRemote then funkotRemote:FireServer("request",i)
 elseif v=="SKATEPARK"and skateControl then skateControl:FireServer("request",i)
 elseif v=="ROOFTOP"and rooftopControl then rooftopControl:FireServer("request",i)
 elseif v=="MALL"and mallControl then mallControl:FireServer("request",i)
 elseif v=="NIGHT_MARKET"and nightControl then nightControl:FireServer("request",i)end
end
local function ownerNext(v)
 if not isOwner()then return end
 if v=="MAIN"or v=="UNDERGROUND"then music:FireServer("next")
 elseif v=="VIP"and vipRemote then vipRemote:FireServer("next")
 elseif v=="FUNKOT"and funkotRemote then funkotRemote:FireServer("next")
 elseif v=="SKATEPARK"and skateControl then skateControl:FireServer("next")
 elseif v=="ROOFTOP"and rooftopControl then rooftopControl:FireServer("next")
 elseif v=="MALL"and mallControl then mallControl:FireServer("next")
 elseif v=="NIGHT_MARKET"and nightControl then nightControl:FireServer("next")end
end

local legacyCard=hub:FindFirstChild("PlayerCard",true);local legacy=legacyCard and legacyCard.Parent;if legacy then legacy.Visible=false end
local old=pg:FindFirstChild("BBYAMusicSuiteV1");if old then old:Destroy()end
local compact=clubUI:FindFirstChild("BBYACompactMusicLayerV7");if compact then compact:Destroy()end
local gui=Instance.new("ScreenGui");gui.Name="BBYAMusicSuiteV1";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=930;gui.Enabled=false;gui.Parent=pg;gui:SetAttribute("BBYAUIAuthority","MUSIC_PLAYER_V4_CLEAN_REBUILD")
local shell=frame(gui,"Shell",UDim2.fromScale(.5,.5),UDim2.fromOffset(420,420),C.bg,.10,22);shell.AnchorPoint=Vector2.new(.5,.5);local shellStroke=stroke(shell,C.purple,.20)
local hero=frame(shell,"Hero",UDim2.fromOffset(12,12),UDim2.new(1,-24,0,160),C.panel,.12,18)
local heroGrad=Instance.new("UIGradient");heroGrad.Color=ColorSequence.new(Color3.fromRGB(32,23,45),Color3.fromRGB(9,10,14));heroGrad.Rotation=125;heroGrad.Parent=hero
local venueLabel=label(hero,"Venue","BBYA MUSIC",UDim2.fromOffset(16,12),UDim2.new(.5,-20,0,18),Enum.Font.GothamBold,8,C.muted)
local title=label(hero,"Title","BELUM ADA LAGU",UDim2.fromOffset(16,31),UDim2.new(.72,-20,0,32),Enum.Font.GothamBlack,16,C.white);title.TextWrapped=true
local stateText=label(hero,"State","STANDBY",UDim2.fromOffset(16,63),UDim2.new(.55,-20,0,18),Enum.Font.GothamBold,8,C.green)
local close=button(hero,"Close","×",UDim2.new(1,-46,0,12),UDim2.fromOffset(34,34),C.card);close.TextSize=18
local wave=frame(hero,"Wave",UDim2.new(.57,0,0,56),UDim2.new(.36,0,0,46),C.panel,1);local waveBars={}
for i=1,18 do local b=frame(wave,"B"..i,UDim2.new((i-.5)/18,0,1,0),UDim2.new(.035,0,0,7+(i*7)%22),i%5==0 and C.cyan or C.white,.35,3);b.AnchorPoint=Vector2.new(.5,1);waveBars[i]=b end
local progress=frame(hero,"Progress",UDim2.fromOffset(16,112),UDim2.new(1,-32,0,4),C.card,0,4);local fill=frame(progress,"Fill",UDim2.new(),UDim2.new(0,0,1,0),C.purple,0,4)
local elapsed=label(hero,"Elapsed","00:00",UDim2.fromOffset(16,119),UDim2.fromOffset(58,14),Enum.Font.GothamBold,7,C.muted)
local duration=label(hero,"Duration","00:00",UDim2.new(1,-74,0,119),UDim2.fromOffset(58,14),Enum.Font.GothamBold,7,C.muted,Enum.TextXAlignment.Right)

local up=frame(shell,"UpNext",UDim2.fromOffset(12,182),UDim2.new(1,-24,0,152),C.panel,.24,16);stroke(up,C.line,.62)
label(up,"Title","UP NEXT",UDim2.fromOffset(14,8),UDim2.new(1,-28,0,20),Enum.Font.GothamBlack,11,C.white)
local upList=Instance.new("Frame");upList.Position=UDim2.fromOffset(10,34);upList.Size=UDim2.new(1,-20,1,-42);upList.BackgroundTransparency=1;upList.Parent=up
local upl=Instance.new("UIListLayout");upl.Padding=UDim.new(0,5);upl.Parent=upList

local content=frame(shell,"Content",UDim2.fromOffset(12,182),UDim2.new(1,-24,0,152),C.panel,.10,16);content.Visible=false
local contentTitle=label(content,"Title","PLAYLIST",UDim2.fromOffset(14,8),UDim2.new(1,-28,0,20),Enum.Font.GothamBlack,11,C.white)
local list=Instance.new("ScrollingFrame");list.Position=UDim2.fromOffset(10,34);list.Size=UDim2.new(1,-20,1,-42);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.ScrollBarThickness=3;list.Parent=content
local ll=Instance.new("UIListLayout");ll.Padding=UDim.new(0,5);ll.Parent=list

local controls=frame(shell,"Controls",UDim2.new(0,12,1,-70),UDim2.new(1,-24,0,58),C.panel,1)
local controlButtons={}
local function control(name,textValue,order)local b=button(controls,name,textValue,nil,UDim2.new(0,0,1,0),C.card);b.LayoutOrder=order;controlButtons[name]=b;return b end
local cl=Instance.new("UIListLayout");cl.FillDirection=Enum.FillDirection.Horizontal;cl.HorizontalAlignment=Enum.HorizontalAlignment.Center;cl.Padding=UDim.new(0,7);cl.Parent=controls
local playlistB=control("Playlist","PLAYLIST",1);local requestB=control("Request","REQUEST",2);local favB=control("Fav","FAV",3);local nextB=control("Next","NEXT",4)

local mode="NOW";local currentTracks={};local currentState={};local activeSound=nil
local function clearRows(parent)
 for _,c in ipairs(parent:GetChildren())do if c:IsA("Frame")or c:IsA("TextButton")then if not c:IsA("UIListLayout")then c:Destroy()end end end
end
local function makeRow(parent,index,item,kind)
 local r=frame(parent,"Row_"..tostring(index),nil,UDim2.new(1,-2,0,34),C.card,.08,9)
 local badge=frame(r,"Art",UDim2.fromOffset(4,4),UDim2.fromOffset(26,26),Color3.fromRGB(42,31,54),.05,7);label(badge,"N",string.format("%02d",index),UDim2.new(),UDim2.fromScale(1,1),Enum.Font.GothamBlack,7,(V[currentVenue()]or V.NONE).accent,Enum.TextXAlignment.Center)
 label(r,"T",tostring(item.title or("Track "..index)),UDim2.fromOffset(38,2),UDim2.new(1,-82,0,17),Enum.Font.GothamBold,8,C.white)
 local meta=tostring(item.artist or item.style or"");label(r,"M",meta,UDim2.fromOffset(38,17),UDim2.new(1,-82,0,13),Enum.Font.Gotham,6,C.muted)
 if kind=="REQUEST"then local b=button(r,"Action","REQUEST",UDim2.new(1,-66,0,5),UDim2.fromOffset(60,24),Color3.fromRGB(54,34,83));b.TextSize=7;b.Activated:Connect(function()requestTrack(currentVenue(),index)end)
 else local f=button(r,"Fav",favorites[favKey(currentVenue(),index)]and"♥"or"♡",UDim2.new(1,-34,0,5),UDim2.fromOffset(28,24),C.card);f.TextColor3=favorites[favKey(currentVenue(),index)]and C.pink or C.muted;f.Activated:Connect(function()local k=favKey(currentVenue(),index);if favorites[k]then favorites[k]=nil else favorites[k]={venue=currentVenue(),index=index,item=item}end;if mode~="NOW"then task.defer(function()controlButtons.Fav:SetAttribute("Refresh",os.clock())end)end end)end
 return r
end
local function renderUp()
 clearRows(upList);local tracks=currentTracks;local s=currentState;if #tracks==0 then local r=frame(upList,"Empty",nil,UDim2.new(1,-2,0,34),C.card,.18,9);label(r,"T","PLAYLIST LOADING...",UDim2.fromOffset(10,0),UDim2.new(1,-20,1,0),Enum.Font.GothamBold,8,C.muted);return end
 local used={};local order={};local first=tonumber(s.nextRequest)or 0;if first>0 and tracks[first]then table.insert(order,first);used[first]=true end
 local cur=math.max(tonumber(s.index)or 1,1);while #order<3 and #order<#tracks do cur=(cur%#tracks)+1;if not used[cur]then table.insert(order,cur);used[cur]=true end end
 for _,i in ipairs(order)do makeRow(upList,i,tracks[i],"UP")end
end
local function renderContent()
 clearRows(list);local v=currentVenue();contentTitle.Text=mode
 if mode=="FAV"then local arr={};for _,it in pairs(favorites)do if it.venue==v then table.insert(arr,it)end end;table.sort(arr,function(a,b)return a.index<b.index end);if #arr==0 then local r=frame(list,"Empty",nil,UDim2.new(1,-2,0,34),C.card,.18,9);label(r,"T","NO FAVORITES YET",UDim2.fromOffset(10,0),UDim2.new(1,-20,1,0),Enum.Font.GothamBold,8,C.muted);return end;for _,it in ipairs(arr)do makeRow(list,it.index,it.item,"PLAYLIST")end;return end
 if #currentTracks==0 then local r=frame(list,"Empty",nil,UDim2.new(1,-2,0,34),C.card,.18,9);label(r,"T","PLAYLIST LOADING...",UDim2.fromOffset(10,0),UDim2.new(1,-20,1,0),Enum.Font.GothamBold,8,C.muted);return end
 for i,it in ipairs(currentTracks)do makeRow(list,i,it,mode)end
end
local function syncControls()
 local owner=isOwner();nextB.Visible=owner;local count=owner and 4 or 3;local w=(controls.AbsoluteSize.X>0 and controls.AbsoluteSize.X or 396);local each=math.floor((w-7*(count-1))/count);for _,b in ipairs({playlistB,requestB,favB,nextB})do if b.Visible then b.Size=UDim2.fromOffset(each,58)end end
end
local function findSound(v)
 local names={MAIN={"BBYAClubDeckA","BBYAClubDeckB"},UNDERGROUND={"BBYABasementDeckA","BBYABasementDeckB"},VIP={"BBYAVIPPlaylist"},FUNKOT={"BBYAFunkotRuntimeV6","BBYAFunkotDeck"},SKATEPARK={"BBYASkateparkMasterSound"},ROOFTOP={"BBYARooftopMasterSound","BBYARooftopPlaylist"},MALL={"BBYAMallMasterSound"},NIGHT_MARKET={"BBYANightMarketMasterSound"}}
 for _,n in ipairs(names[v]or{})do local s=SoundService:FindFirstChild(n,true);if s and s:IsA("Sound")then return s end end
 return nil
end
local function fmt(sec)sec=math.max(0,math.floor(tonumber(sec)or 0));return string.format("%02d:%02d",math.floor(sec/60),sec%60)end
local function refresh()
 local v=currentVenue();currentTracks=venueTracks(v);currentState=venueState(v,currentTracks);local spec=V[v]or V.NONE;shellStroke.Color=spec.accent;venueLabel.Text=spec.label;venueLabel.TextColor3=spec.accent
 local t=currentState.title;if t==""and currentTracks[currentState.index]then t=currentTracks[currentState.index].title end;if t==""then t="BELUM ADA LAGU"end;title.Text=t;stateText.Text=currentState.playing and"LIVE • PLAYING"or"STANDBY";stateText.TextColor3=currentState.playing and C.green or C.muted;activeSound=findSound(v);renderUp();if mode~="NOW"then renderContent()end;syncControls()
end
local function setMode(newMode)
 if mode==newMode then mode="NOW"else mode=newMode end
 local now=mode=="NOW";up.Visible=now;content.Visible=not now;if not now then renderContent()end
 for n,b in pairs(controlButtons)do local active=(n=="Playlist"and mode=="PLAYLIST")or(n=="Request"and mode=="REQUEST")or(n=="Fav"and mode=="FAV");b.BackgroundColor3=active and Color3.fromRGB(59,37,86)or C.card end
end
playlistB.Activated:Connect(function()setMode("PLAYLIST")end);requestB.Activated:Connect(function()setMode("REQUEST")end);favB.Activated:Connect(function()setMode("FAV")end);nextB.Activated:Connect(function()ownerNext(currentVenue())end);close.Activated:Connect(function()gui.Enabled=false end)
controlButtons.Fav:GetAttributeChangedSignal("Refresh"):Connect(function()if mode=="FAV"then renderContent()end end)

stateRemote.OnClientEvent:Connect(function(kind,data)
 local v=currentVenue();if kind=="playlist"and type(data)=="table"and(v=="MAIN"or v=="UNDERGROUND")then cache[v].tracks=normalize(data);if gui.Enabled then refresh()end
 elseif kind=="music"and type(data)=="table"then local dv=tostring(data.venue or v);if dv=="BASEMENT"then dv="UNDERGROUND"end;if cache[dv]then cache[dv].state=data end;if gui.Enabled and dv==v then refresh()end end
end)
if vipRemote then vipRemote.OnClientEvent:Connect(function(kind,data)if kind=="playlist"then cache.VIP.tracks=normalize(data)elseif kind=="state"and type(data)=="table"then cache.VIP.state=data end;if gui.Enabled and currentVenue()=="VIP"then refresh()end end)end
if funkotRemote then funkotRemote.OnClientEvent:Connect(function(kind,data)if kind=="playlist"then cache.FUNKOT.tracks=normalize(data)elseif kind=="state"and type(data)=="table"then cache.FUNKOT.state=data end;if gui.Enabled and currentVenue()=="FUNKOT"then refresh()end end)end
player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()if gui.Enabled then mode="NOW";up.Visible=true;content.Visible=false;requestList(currentVenue());task.delay(.12,refresh)end end)
for _,a in ipairs({"BBYASkateparkCurrentIndex","BBYASkateparkCurrentTitle","BBYARooftopCurrentIndex","BBYARooftopCurrentTitle","BBYAMallCurrentIndex","BBYAMallCurrentTitle","BBYANightMarketCurrentIndex","BBYANightMarketCurrentTitle"})do ReplicatedStorage:GetAttributeChangedSignal(a):Connect(function()if gui.Enabled then refresh()end end)end
ReplicatedStorage.ChildAdded:Connect(function(child)if child.Name=="BBYASkateparkMusicControl"then skateControl=child elseif child.Name=="BBYARooftopMusicControl"then rooftopControl=child elseif child.Name=="BBYAMallMusicControl"then mallControl=child elseif child.Name=="BBYANightMarketMusicControl"then nightControl=child end;if gui.Enabled then task.delay(.05,refresh)end end)

local bound={}
local function openPlayer()if legacy then legacy.Visible=false end;hub.Visible=false;gui.Enabled=true;mode="NOW";up.Visible=true;content.Visible=false;requestList(currentVenue());task.delay(.08,refresh)end
local function bindMenu()
 local m=pg:FindFirstChild("BBYACommandMenuUI");local slot=m and m:FindFirstChild("Slot_MUSIC",true);if not slot then return end
 for _,b in ipairs(slot:GetDescendants())do if b:IsA("TextButton")and not bound[b]then bound[b]=true;b.Activated:Connect(openPlayer)end end
end
pg.DescendantAdded:Connect(function()task.defer(bindMenu)end);task.defer(bindMenu)

local cam=workspace.CurrentCamera
local function layout()
 cam=workspace.CurrentCamera or cam;local vp=cam and cam.ViewportSize or Vector2.new(1280,720);local max=math.min(vp.X-28,vp.Y-86);local size=math.clamp(max,330,430);shell.Size=UDim2.fromOffset(size,size);shell.Position=UDim2.new(.5,0,.5,18);syncControls()
end
if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()cam=workspace.CurrentCamera;if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout)end;layout()end)

local acc=0
RunService.RenderStepped:Connect(function(dt)
 if not gui.Enabled then return end;acc+=dt;if acc<.12 then return end;acc=0
 if activeSound and activeSound.Parent then local len=tonumber(activeSound.TimeLength)or 0;local pos=tonumber(activeSound.TimePosition)or 0;fill.Size=UDim2.new(len>0 and math.clamp(pos/len,0,1)or 0,0,1,0);elapsed.Text=fmt(pos);duration.Text=fmt(len);local loud=math.clamp((activeSound.PlaybackLoudness or 0)/500,0,1);for i,b in ipairs(waveBars)do b.Size=UDim2.new(.035,0,0,7+math.floor(loud*(8+((i*7)%20))))end end
end)

task.defer(function()layout();bindMenu();refresh();syncControls()end)
print("[BBYA] Music Player v4 CLEAN REBUILD online: compact card / playlist+request+fav / owner next / no audio mutation")