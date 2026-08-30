-- BBYA SOCIAL HUB — MUSIC SUITE VENUE BRIDGE v5
-- Replaces the retired legacy three-venue panel when BBYAMusicSuiteV1 is active.
-- Main/Underground stay owned by the Music Suite core. This bridge adds truthful
-- Funkot request/state plus Skatepark/Rooftop read-only catalogs without touching audio volumes.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local suite=pg:FindFirstChild("BBYAMusicSuiteV1") or pg:WaitForChild("BBYAMusicSuiteV1",10)
if not suite then
 warn("[BBYA] Music Suite venue bridge v5: suite missing; legacy UI intentionally retired in preview branch")
 return
end

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local funkotRemote=remotes:FindFirstChild("FunkotMusic") or remotes:WaitForChild("FunkotMusic",15)

local C={
 card=Color3.fromRGB(21,22,30),
 card2=Color3.fromRGB(29,30,40),
 white=Color3.fromRGB(247,247,250),
 muted=Color3.fromRGB(146,150,164),
 purple=Color3.fromRGB(142,77,255),
 pink=Color3.fromRGB(235,51,165),
 cyan=Color3.fromRGB(38,200,225),
 green=Color3.fromRGB(73,215,143),
 gold=Color3.fromRGB(232,181,82),
}
local ACCENT={FUNKOT=C.purple,SKATEPARK=C.cyan,ROOFTOP=C.gold,VIP=C.gold}
local SPECIAL={FUNKOT=true,SKATEPARK=true,ROOFTOP=true,VIP=true}

local function corner(o,r)
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=o;return c
end
local function stroke(o,col,tr)
 local s=Instance.new("UIStroke");s.Color=col or C.purple;s.Thickness=1;s.Transparency=tr or .6;s.Parent=o;return s
end
local function label(p,n,t,pos,size,font,ts,col,align)
 local x=Instance.new("TextLabel")
 x.Name=n;x.BackgroundTransparency=1;x.Text=t;x.Position=pos;x.Size=size
 x.Font=font or Enum.Font.Gotham;x.TextSize=ts or 8;x.TextColor3=col or C.white
 x.TextXAlignment=align or Enum.TextXAlignment.Left;x.TextYAlignment=Enum.TextYAlignment.Center
 x.TextTruncate=Enum.TextTruncate.AtEnd;x.Parent=p;return x
end
local function button(p,n,t,pos,size,bg)
 local b=Instance.new("TextButton")
 b.Name=n;b.Text=t;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.card2
 b.BackgroundTransparency=.04;b.BorderSizePixel=0;b.TextColor3=C.white
 b.Font=Enum.Font.GothamBold;b.TextSize=7;b.AutoButtonColor=true;b.Parent=p
 corner(b,8);stroke(b,C.purple,.62);return b
end

local function venue()
 local v=tostring(player:GetAttribute("BBYAAudioVenue") or "NONE")
 if v=="BASEMENT" then v="UNDERGROUND" end
 return v
end
local function isAdmin()
 return player:GetAttribute("BBYAAdmin")==true
  or (game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId)
end

local libPage=suite:FindFirstChild("LIBRARY",true)
local nowPage=suite:FindFirstChild("NOW",true)
local queuePage=suite:FindFirstChild("QUEUE",true)
if not libPage or not nowPage or not queuePage then
 warn("[BBYA] Music Suite venue bridge v5: expected pages missing")
 return
end

local searchBox
for _,d in ipairs(libPage:GetChildren()) do if d:IsA("TextBox") then searchBox=d break end end
local libList
for _,d in ipairs(libPage:GetChildren()) do if d:IsA("ScrollingFrame") then libList=d break end end
local libMeta=libPage:FindFirstChild("Meta")
local nowTitle=nowPage:FindFirstChild("Track",true)
local nowInfo=nowTitle and nowTitle.Parent
local nowState=nowInfo and nowInfo:FindFirstChild("State")
local nowMeta=nowInfo and nowInfo:FindFirstChild("Meta")
local prev=suite:FindFirstChild("Prev",true)
local nextB=suite:FindFirstChild("Next",true)
local statusValue=suite:FindFirstChild("SV",true)
local queueMeta=queuePage:FindFirstChild("Meta")
local queueList
for _,d in ipairs(queuePage:GetDescendants()) do if d:IsA("ScrollingFrame") then queueList=d break end end
local upList
for _,d in ipairs(nowPage:GetDescendants()) do if d:IsA("ScrollingFrame") then upList=d break end end
if not libList then
 warn("[BBYA] Music Suite venue bridge v5: library scroller missing")
 return
end

local function setChip(key,value,color)
 for _,d in ipairs(suite:GetDescendants()) do
  if d:IsA("TextLabel") and d.Name=="H" and string.upper(d.Text or "")==key then
   local v=d.Parent and d.Parent:FindFirstChild("V")
   if v and v:IsA("TextLabel") then v.Text=tostring(value);if color then v.TextColor3=color end end
   return
  end
 end
end

local function clearPrefix(parent,prefix)
 if not parent then return end
 for _,x in ipairs(parent:GetChildren()) do
  if x.Name:sub(1,#prefix)==prefix then x:Destroy() end
 end
end

local function mini(parent,name,no,titleText,meta,col)
 if not parent then return end
 local r=Instance.new("Frame")
 r.Name=name;r.Size=UDim2.new(1,-2,0,46);r.BackgroundColor3=C.card;r.BackgroundTransparency=.08;r.BorderSizePixel=0;r.Parent=parent
 corner(r,8)
 label(r,"No",tostring(no),UDim2.fromOffset(4,0),UDim2.fromOffset(28,46),Enum.Font.GothamBlack,8,col or C.purple,Enum.TextXAlignment.Center)
 label(r,"T",titleText,UDim2.fromOffset(38,4),UDim2.new(1,-44,0,22),Enum.Font.GothamBold,8,C.white)
 label(r,"M",meta,UDim2.fromOffset(38,24),UDim2.new(1,-44,0,16),Enum.Font.GothamBold,6,C.muted)
end

local funkotTracks={}
local funkotState={index=0,title="",playing=false,queue=0}

local function catalogRows(folderName)
 local folder=ReplicatedStorage:FindFirstChild(folderName)
 local rows={}
 if not folder then return rows end
 for _,v in ipairs(folder:GetChildren()) do
  if v:IsA("StringValue") then
   table.insert(rows,{
    index=tonumber(v:GetAttribute("Index")) or 999,
    title=v.Value,
    style="BBYA MUSIC",
    assetId=tostring(v:GetAttribute("AssetId") or ""),
   })
  end
 end
 table.sort(rows,function(a,b)return a.index<b.index end)
 return rows
end

local function rowsFor(v)
 if v=="FUNKOT" then return funkotTracks end
 if v=="SKATEPARK" then
  local rows=catalogRows("BBYASkateparkPlaylistCatalog")
  for _,r in ipairs(rows) do r.style="SKATE / ALT" end
  return rows
 end
 if v=="ROOFTOP" then
  local rows=catalogRows("BBYARooftopPlaylistCatalog")
  for _,r in ipairs(rows) do r.style="TROPICAL HOUSE" end
  return rows
 end
 return {}
end

local function currentIndexFor(v)
 if v=="FUNKOT" then return tonumber(funkotState.index) or 0 end
 if v=="SKATEPARK" then return tonumber(ReplicatedStorage:GetAttribute("BBYASkateparkCurrentIndex")) or 0 end
 if v=="ROOFTOP" then return tonumber(ReplicatedStorage:GetAttribute("BBYARooftopCurrentIndex")) or 0 end
 return 0
end
local function currentTitleFor(v)
 if v=="FUNKOT" then return tostring(funkotState.title or "") end
 if v=="SKATEPARK" then return tostring(ReplicatedStorage:GetAttribute("BBYASkateparkCurrentTitle") or "") end
 if v=="ROOFTOP" then return tostring(ReplicatedStorage:GetAttribute("BBYARooftopCurrentTitle") or "") end
 if v=="VIP" then return "VIP CHANNEL" end
 return ""
end
local function playingFor(v)
 if v=="FUNKOT" then return funkotState.playing==true end
 if v=="SKATEPARK" or v=="ROOFTOP" then return true end
 return false
end

local function rebuildSpecialLibrary()
 local v=venue();if not SPECIAL[v] then return end
 local rows=rowsFor(v)
 local q=string.lower(searchBox and searchBox.Text or "")
 local shown=0
 local current=currentIndexFor(v)
 local accent=ACCENT[v] or C.purple
 clearPrefix(libList,"Track_")

 for displayIndex,item in ipairs(rows) do
  local titleText=tostring(item.title or ("Track "..displayIndex))
  local meta=tostring(item.style or "BBYA MUSIC")
  if q=="" or string.find(string.lower(titleText.." "..meta),q,1,true) then
   shown+=1
   local actualIndex=tonumber(item.index) or displayIndex
   local r=Instance.new("Frame")
   r.Name="Track_"..tostring(actualIndex);r.LayoutOrder=displayIndex;r.Size=UDim2.new(1,-2,0,42)
   r.BackgroundColor3=C.card;r.BorderSizePixel=0;r.Parent=libList;corner(r,8)
   local isCurrent=current==actualIndex
   if isCurrent then stroke(r,accent,.25) end
   label(r,"No",string.format("%02d",actualIndex),UDim2.fromOffset(5,0),UDim2.fromOffset(34,42),Enum.Font.GothamBold,7,isCurrent and accent or C.muted,Enum.TextXAlignment.Center)
   label(r,"Title",titleText,UDim2.fromOffset(45,3),UDim2.new(1,-180,0,21),Enum.Font.GothamBold,9,C.white)
   label(r,"Meta",string.upper(meta),UDim2.fromOffset(45,22),UDim2.new(1,-180,0,15),Enum.Font.GothamBold,6,C.muted)
   if isCurrent then label(r,"Playing","PLAYING",UDim2.new(1,-204,0,0),UDim2.fromOffset(70,42),Enum.Font.GothamBold,6,accent,Enum.TextXAlignment.Center) end
   local canRequest=v=="FUNKOT" and funkotRemote~=nil
   local b=button(r,"Req",canRequest and "REQUEST" or "LIVE",UDim2.new(1,-118,0,6),UDim2.fromOffset(104,30),canRequest and Color3.fromRGB(49,32,70) or C.card2)
   if canRequest and not isCurrent then
    b.Activated:Connect(function()funkotRemote:FireServer("request",actualIndex)end)
   else
    b.Active=false;b.AutoButtonColor=false;b.TextColor3=C.muted
   end
  end
 end

 if #rows==0 then
  local msg=v=="VIP" and "VIP PLAYLIST BELUM AKTIF" or "PLAYLIST BELUM TERSEDIA"
  mini(libList,"Track_Empty","--",msg,"Venue channel tetap terisolasi",accent)
 end
 if libMeta then libMeta.Text=string.format("%d / %d TRACKS",shown,#rows) end
 if statusValue then statusValue.Text=tostring(#rows).." TRACKS READY" end
 setChip("TRACKS",#rows,accent)
end

local function rebuildSpecialUpNext()
 if not upList then return end
 local v=venue();if not SPECIAL[v] then return end
 clearPrefix(upList,"Next_")
 local rows=rowsFor(v)
 if #rows==0 then mini(upList,"Next_Empty","--","NO UPCOMING TRACK","Waiting for venue playlist",C.muted);return end
 local current=currentIndexFor(v)
 local accent=ACCENT[v] or C.purple
 local position=1
 for i,r in ipairs(rows) do if (tonumber(r.index) or i)==current then position=i break end end
 for n=1,math.min(5,#rows) do
  local idx=((position-1+n)%#rows)+1
  local item=rows[idx]
  mini(upList,"Next_"..n,n,tostring(item.title or ("Track "..idx)),v=="FUNKOT" and "AUTO DJ / REQUEST" or "AUTO DJ",accent)
 end
end

local function rebuildSpecialQueue()
 if not queueList then return end
 local v=venue();if not SPECIAL[v] then return end
 clearPrefix(queueList,"Queue_")
 local count=(v=="FUNKOT" and tonumber(funkotState.queue)) or 0
 if queueMeta then queueMeta.Text=tostring(count).." REQUESTS" end
 setChip("QUEUE",count,C.gold)
 if v~="FUNKOT" then
  mini(queueList,"Queue_Info","--","AUTO DJ VENUE","Request queue tidak tersedia di channel ini",ACCENT[v] or C.muted)
 elseif count<=0 then
  mini(queueList,"Queue_Empty","--","REQUEST QUEUE KOSONG","Pilih lagu di Library lalu tekan REQUEST",C.muted)
 else
  mini(queueList,"Queue_Info","+",tostring(count).." REQUEST", "Antrean Funkot aktif di server",C.gold)
 end
end

local function refreshSpecialNow()
 local v=venue();if not SPECIAL[v] then return end
 local rows=rowsFor(v)
 local title=currentTitleFor(v)
 if title=="" then title=v=="VIP" and "VIP CHANNEL" or "BELUM ADA LAGU" end
 local accent=ACCENT[v] or C.purple
 if nowTitle then nowTitle.Text=title end
 if nowMeta then nowMeta.Text=v.."  •  "..tostring(#rows).." TRACKS" end
 if nowState then
  local playing=playingFor(v)
  nowState.Text=playing and "LIVE • PLAYING" or (v=="VIP" and "STANDBY • ISOLATED" or "STANDBY")
  nowState.TextColor3=playing and C.green or C.muted
 end
 if prev then prev.Visible=isAdmin();prev.Active=(v=="FUNKOT" and funkotRemote~=nil);prev.AutoButtonColor=prev.Active end
 if nextB then nextB.Visible=isAdmin();nextB.Active=(v=="FUNKOT" and funkotRemote~=nil);nextB.AutoButtonColor=nextB.Active end
 setChip("VENUE",v,accent)
 rebuildSpecialUpNext();rebuildSpecialQueue()
end

local function refreshSpecial()
 if not SPECIAL[venue()] then return end
 rebuildSpecialLibrary();refreshSpecialNow()
end

if funkotRemote then
 funkotRemote.OnClientEvent:Connect(function(kind,data)
  if kind=="playlist" and type(data)=="table" then
   funkotTracks={}
   for i,item in ipairs(data) do
    funkotTracks[i]={index=i,title=tostring(item.title or ("Funkot Track "..i)),style=tostring(item.style or "FUNKOT")}
   end
   if venue()=="FUNKOT" then task.defer(refreshSpecial) end
  elseif kind=="state" and type(data)=="table" then
   funkotState.index=tonumber(data.index) or funkotState.index
   funkotState.title=tostring(data.title or funkotState.title or "")
   funkotState.playing=data.playing==true
   funkotState.queue=tonumber(data.queue) or 0
   if venue()=="FUNKOT" then task.defer(refreshSpecial) end
  end
 end)
end

if searchBox then searchBox:GetPropertyChangedSignal("Text"):Connect(function()if SPECIAL[venue()] then task.defer(rebuildSpecialLibrary) end end) end
if nextB then nextB.Activated:Connect(function()if venue()=="FUNKOT" and isAdmin() and funkotRemote then funkotRemote:FireServer("next") end end) end
if prev then prev.Activated:Connect(function()
 if venue()=="FUNKOT" and isAdmin() and funkotRemote and #funkotTracks>0 then
  local cur=math.max(tonumber(funkotState.index) or 1,1)
  local wanted=((cur-2)%#funkotTracks)+1
  funkotRemote:FireServer("play",wanted)
 end
end) end

local function requestVenueData()
 local v=venue()
 if v=="FUNKOT" and funkotRemote then funkotRemote:FireServer("list");funkotRemote:FireServer("state") end
 task.defer(refreshSpecial)
end
player:GetAttributeChangedSignal("BBYAAudioVenue"):Connect(function()task.defer(requestVenueData)end)
player:GetAttributeChangedSignal("BBYAAdmin"):Connect(function()task.defer(refreshSpecialNow)end)

for _,name in ipairs({"BBYASkateparkCurrentIndex","BBYASkateparkCurrentTitle","BBYASkateparkCurrentAssetId","BBYARooftopCurrentIndex","BBYARooftopCurrentTitle","BBYARooftopCurrentAssetId","BBYARooftopPlaylistCount"}) do
 ReplicatedStorage:GetAttributeChangedSignal(name):Connect(function()if SPECIAL[venue()] then task.defer(refreshSpecial) end end)
end
ReplicatedStorage.ChildAdded:Connect(function(child)
 if child.Name=="BBYASkateparkPlaylistCatalog" or child.Name=="BBYARooftopPlaylistCatalog" then task.delay(.1,refreshSpecial) end
end)

local acc=0
RunService.Heartbeat:Connect(function(dt)
 if not suite.Enabled or not SPECIAL[venue()] then return end
 acc+=dt;if acc<.35 then return end;acc=0
 refreshSpecial()
end)

task.defer(requestVenueData)
print("[BBYA] Music Suite venue bridge v5 online: legacy three-venue UI retired; Funkot requests + Skatepark/Rooftop catalogs unified")
