-- BBYA SOCIAL HUB — ACTIVE MALL UI v1
-- Responsive directory/store/cinema interface for the rear BBYA Mall.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local event=remotes:WaitForChild("MallEvent",30)
local action=remotes:WaitForChild("MallAction",30)
if not event or not action then return end

local old=pg:FindFirstChild("BBYAMallUI");if old then old:Destroy() end
local gui=Instance.new("ScreenGui");gui.Name="BBYAMallUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=66;gui.Parent=pg
local C={bg=Color3.fromRGB(12,13,16),card=Color3.fromRGB(25,27,32),card2=Color3.fromRGB(35,37,43),line=Color3.fromRGB(65,68,76),white=Color3.fromRGB(246,245,242),muted=Color3.fromRGB(156,159,167),gold=Color3.fromRGB(211,166,86),pink=Color3.fromRGB(235,56,147),cyan=Color3.fromRGB(38,192,214),green=Color3.fromRGB(67,173,116)}
local function corner(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 10);x.Parent=o end
local function stroke(o,c,t,tr)local x=Instance.new("UIStroke");x.Color=c or C.line;x.Thickness=t or 1;x.Transparency=tr or .55;x.Parent=o end
local function label(parent,name,value,pos,size,font,ts,color)
 local l=Instance.new("TextLabel");l.Name=name;l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 11;l.TextColor3=color or C.white;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextWrapped=true;l.Parent=parent;return l
end
local function button(parent,name,value,pos,size,color)
 local b=Instance.new("TextButton");b.Name=name;b.Text=value;b.Position=pos;b.Size=size;b.BackgroundColor3=color or C.card2;b.BorderSizePixel=0;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.TextColor3=C.white;b.Parent=parent;corner(b,8);return b
end

local shade=Instance.new("Frame");shade.Name="Shade";shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.38;shade.BorderSizePixel=0;shade.Visible=false;shade.Parent=gui
local panel=Instance.new("Frame");panel.Name="Panel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.52);panel.Size=UDim2.fromOffset(760,520);panel.BackgroundColor3=C.bg;panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=gui;corner(panel,18);stroke(panel,C.gold,1,.42)
local accent=Instance.new("Frame");accent.Name="Accent";accent.Size=UDim2.new(1,0,0,4);accent.BackgroundColor3=C.gold;accent.BorderSizePixel=0;accent.Parent=panel;corner(accent,18)
local grad=Instance.new("UIGradient");grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,C.gold),ColorSequenceKeypoint.new(.5,C.pink),ColorSequenceKeypoint.new(1,C.cyan)});grad.Parent=accent
label(panel,"Brand","BBYA MALL",UDim2.fromOffset(22,18),UDim2.new(1,-100,0,28),Enum.Font.GothamBlack,22,C.white)
local subtitle=label(panel,"Subtitle","DIRECTORY",UDim2.fromOffset(22,48),UDim2.new(1,-100,0,20),Enum.Font.GothamBold,9,C.muted)
local close=button(panel,"Close","×",UDim2.new(1,-56,0,16),UDim2.fromOffset(36,36),C.card2);close.TextSize=20
local content=Instance.new("ScrollingFrame");content.Name="Content";content.Position=UDim2.fromOffset(18,82);content.Size=UDim2.new(1,-36,1,-100);content.BackgroundTransparency=1;content.BorderSizePixel=0;content.ScrollBarThickness=3;content.AutomaticCanvasSize=Enum.AutomaticSize.Y;content.CanvasSize=UDim2.new();content.Parent=panel
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=content

local function clear()
 for _,c in ipairs(content:GetChildren()) do if c~=layout then c:Destroy() end end
end
local function show()
 shade.Visible=true;panel.Visible=true
end
local function hide()
 shade.Visible=false;panel.Visible=false
end
close.MouseButton1Click:Connect(hide)
shade.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 then hide()end end)

local function tenantCard(t,i)
 local card=Instance.new("Frame");card.Name="Tenant_"..t.id;card.Size=UDim2.new(1,-4,0,70);card.BackgroundColor3=C.card;card.BorderSizePixel=0;card.LayoutOrder=i;card.Parent=content;corner(card,11);stroke(card,t.color or C.gold,1,.65)
 local bar=Instance.new("Frame");bar.Size=UDim2.new(0,4,1,-14);bar.Position=UDim2.fromOffset(7,7);bar.BackgroundColor3=t.color or C.gold;bar.BorderSizePixel=0;bar.Parent=card;corner(bar,3)
 label(card,"Name",t.name,UDim2.fromOffset(20,10),UDim2.new(1,-150,0,20),Enum.Font.GothamBold,12,C.white)
 label(card,"Meta",string.format("LEVEL %d  •  %s  •  %s",t.floor,t.cat,t.side or ""),UDim2.fromOffset(20,33),UDim2.new(1,-150,0,16),Enum.Font.GothamBold,8,C.muted)
 local guide=button(card,"Guide","GUIDE",UDim2.new(1,-112,.5,-17),UDim2.fromOffset(94,34),Color3.fromRGB(47,43,42));stroke(guide,t.color or C.gold,1,.58)
 guide.MouseButton1Click:Connect(function()action:FireServer("guide",t.id);hide()end)
end

local function renderDirectory(rows)
 clear();subtitle.Text="DIRECTORY • 4 LEVELS • ACTIVE TENANTS"
 local head=Instance.new("Frame");head.Size=UDim2.new(1,-4,0,56);head.BackgroundColor3=Color3.fromRGB(31,29,27);head.BorderSizePixel=0;head.LayoutOrder=0;head.Parent=content;corner(head,11);stroke(head,C.gold,1,.5)
 label(head,"Title","SHOP • EAT • PLAY • CINEMA",UDim2.fromOffset(18,9),UDim2.new(1,-36,0,20),Enum.Font.GothamBlack,13,C.gold)
 label(head,"Help","Use GUIDE while inside the mall for instant indoor wayfinding.",UDim2.fromOffset(18,31),UDim2.new(1,-36,0,16),Enum.Font.Gotham,9,C.muted)
 for i,t in ipairs(rows or {}) do tenantCard(t,i) end
 show()
end

local function renderStore(t)
 clear();subtitle.Text="STORE • LEVEL "..t.floor
 local hero=Instance.new("Frame");hero.Size=UDim2.new(1,-4,0,150);hero.BackgroundColor3=C.card;hero.BorderSizePixel=0;hero.Parent=content;corner(hero,14);stroke(hero,t.color or C.gold,1,.42)
 local banner=Instance.new("Frame");banner.Size=UDim2.new(0,8,1,-20);banner.Position=UDim2.fromOffset(10,10);banner.BackgroundColor3=t.color or C.gold;banner.BorderSizePixel=0;banner.Parent=hero;corner(banner,4)
 label(hero,"StoreName",t.name,UDim2.fromOffset(30,18),UDim2.new(1,-50,0,28),Enum.Font.GothamBlack,20,C.white)
 label(hero,"Category",string.format("%s • LEVEL %d • %s WING",t.cat,t.floor,t.side or "CENTRAL"),UDim2.fromOffset(30,50),UDim2.new(1,-50,0,20),Enum.Font.GothamBold,9,t.color or C.gold)
 label(hero,"Desc","This is an active BBYA Mall tenant. Browse the in-world displays, counters and interaction points, or use indoor guide to return here.",UDim2.fromOffset(30,78),UDim2.new(1,-50,0,44),Enum.Font.Gotham,10,C.muted)
 local guide=button(hero,"Guide","GUIDE ME HERE",UDim2.fromOffset(30,116),UDim2.fromOffset(140,26),Color3.fromRGB(47,43,42));stroke(guide,t.color or C.gold,1,.55)
 guide.MouseButton1Click:Connect(function()action:FireServer("guide",t.id);hide()end)
 local info=Instance.new("Frame");info.Size=UDim2.new(1,-4,0,96);info.BackgroundColor3=Color3.fromRGB(20,22,26);info.BorderSizePixel=0;info.Parent=content;corner(info,12)
 label(info,"InfoTitle","IN-STORE EXPERIENCE",UDim2.fromOffset(18,12),UDim2.new(1,-36,0,18),Enum.Font.GothamBold,10,C.white)
 label(info,"Info","Walk through the glass storefront. Displays, counters and browsing prompts are part of the live 3D tenant space.",UDim2.fromOffset(18,36),UDim2.new(1,-36,0,44),Enum.Font.Gotham,10,C.muted)
 show()
end

local function renderCinema(data)
 clear();subtitle.Text="CINEMA • SCREEN "..tostring(data.screen or "")
 local hero=Instance.new("Frame");hero.Size=UDim2.new(1,-4,0,88);hero.BackgroundColor3=Color3.fromRGB(36,25,28);hero.BorderSizePixel=0;hero.Parent=content;corner(hero,12);stroke(hero,Color3.fromRGB(192,62,67),1,.45)
 label(hero,"Cinema","BBYA CINEMA",UDim2.fromOffset(18,14),UDim2.new(1,-36,0,24),Enum.Font.GothamBlack,18,C.white)
 label(hero,"Screen","SCREEN "..tostring(data.screen or "").." • SHOWTIMES",UDim2.fromOffset(18,45),UDim2.new(1,-36,0,18),Enum.Font.GothamBold,9,Color3.fromRGB(235,110,110))
 for i,showtime in ipairs(data.shows or {}) do
  local card=Instance.new("Frame");card.Size=UDim2.new(1,-4,0,58);card.BackgroundColor3=C.card;card.BorderSizePixel=0;card.LayoutOrder=i;card.Parent=content;corner(card,10)
  label(card,"Show",showtime,UDim2.fromOffset(18,10),UDim2.new(1,-36,0,20),Enum.Font.GothamBold,11,C.white)
  label(card,"Meta","SCREEN "..tostring(data.screen or "").." • WALK-IN EXPERIENCE",UDim2.fromOffset(18,33),UDim2.new(1,-36,0,14),Enum.Font.GothamBold,8,C.muted)
 end
 show()
end

event.OnClientEvent:Connect(function(mode,data)
 if mode=="directory" then renderDirectory(data)
 elseif mode=="store" then renderStore(data)
 elseif mode=="cinema" then renderCinema(data)
 end
end)

local camera=workspace.CurrentCamera
local function responsive()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local phone=UserInputService.TouchEnabled or vp.Y<800
 local w=math.clamp(math.floor(vp.X*(phone and .90 or .66)),320,780)
 local h=math.clamp(math.floor(vp.Y*(phone and .78 or .72)),330,560)
 panel.Size=UDim2.fromOffset(w,h)
end
task.defer(responsive)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(responsive)end)
print("[BBYA] Mall UI v1 online: directory / tenant browse / cinema / indoor guide")

-- MALL KPOP UI / CLUB-BLEED GUARD -------------------------------------------
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local oldKpop=pg:FindFirstChild("BBYAMallKPOPUI");if oldKpop then oldKpop:Destroy() end
local kgui=Instance.new("ScreenGui");kgui.Name="BBYAMallKPOPUI";kgui.ResetOnSpawn=false;kgui.IgnoreGuiInset=true;kgui.DisplayOrder=72;kgui.Parent=pg
local kToggle=button(kgui,"MallKPOPToggle","MALL · KPOP",UDim2.new(1,-142,1,-74),UDim2.fromOffset(124,42),Color3.fromRGB(42,23,39));kToggle.Visible=false;stroke(kToggle,C.pink,1,.35)
local kPanel=Instance.new("Frame");kPanel.Name="MallKPOPPanel";kPanel.AnchorPoint=Vector2.new(1,1);kPanel.Position=UDim2.new(1,-18,1,-124);kPanel.Size=UDim2.fromOffset(330,430);kPanel.BackgroundColor3=C.bg;kPanel.BorderSizePixel=0;kPanel.Visible=false;kPanel.Parent=kgui;corner(kPanel,16);stroke(kPanel,C.pink,1,.35)
label(kPanel,"Title","MALL · KPOP",UDim2.fromOffset(18,14),UDim2.new(1,-70,0,24),Enum.Font.GothamBlack,17,C.white)
label(kPanel,"Bank","18 APPROVED · KPOP BANK",UDim2.fromOffset(18,39),UDim2.new(1,-70,0,18),Enum.Font.GothamBold,8,C.pink)
local kClose=button(kPanel,"Close","×",UDim2.new(1,-48,0,12),UDim2.fromOffset(32,32),C.card2);kClose.TextSize=18
local kNow=label(kPanel,"Now","NOW PLAYING · —",UDim2.fromOffset(18,65),UDim2.new(1,-36,0,34),Enum.Font.GothamBold,10,C.white)
local kQueue=label(kPanel,"Queue","QUEUE · 0",UDim2.fromOffset(18,96),UDim2.new(1,-36,0,18),Enum.Font.GothamBold,8,C.muted)
local kList=Instance.new("ScrollingFrame");kList.Name="KPOPList";kList.Position=UDim2.fromOffset(14,120);kList.Size=UDim2.new(1,-28,1,-134);kList.BackgroundTransparency=1;kList.BorderSizePixel=0;kList.ScrollBarThickness=3;kList.AutomaticCanvasSize=Enum.AutomaticSize.Y;kList.CanvasSize=UDim2.new();kList.Parent=kPanel
local kLayout=Instance.new("UIListLayout");kLayout.Padding=UDim.new(0,6);kLayout.SortOrder=Enum.SortOrder.LayoutOrder;kLayout.Parent=kList
local mallControl=ReplicatedStorage:FindFirstChild("BBYAMallMusicControl") or ReplicatedStorage:WaitForChild("BBYAMallMusicControl",30)
local lastCatalogSignature=""

local function insideMall()
 local char=player.Character
 local hrp=char and char:FindFirstChild("HumanoidRootPart")
 if not hrp then return false end
 local p=hrp.Position
 return p.Y>-4 and p.Y<68 and math.abs(p.X)<=98 and p.Z>=285 and p.Z<=445
end

local function clearKRows()
 for _,d in ipairs(kList:GetChildren()) do if d~=kLayout then d:Destroy() end end
end

local function rebuildKPOP()
 local folder=ReplicatedStorage:FindFirstChild("BBYAMallPlaylistCatalog")
 if not folder then return end
 local indexed={}
 for _,row in ipairs(folder:GetChildren()) do
  if row:IsA("StringValue") then
   local i=tonumber(row:GetAttribute("Index"))
   if i then indexed[i]=row end
  end
 end
 local sig=tostring(folder:GetAttribute("Count") or 0)..":"..tostring(#folder:GetChildren())
 if sig==lastCatalogSignature and #kList:GetChildren()>1 then return end
 lastCatalogSignature=sig
 clearKRows()
 for i=1,#indexed do
  local row=indexed[i]
  if row then
   local b=button(kList,"KPOP_"..i,string.format("%02d  %s",i,row.Value),UDim2.new(),UDim2.new(1,-4,0,38),C.card)
   b.LayoutOrder=i;b.TextXAlignment=Enum.TextXAlignment.Left;b.TextSize=10;stroke(b,C.pink,1,.75)
   b.MouseButton1Click:Connect(function()
    if mallControl and insideMall() then mallControl:FireServer("request",i) end
   end)
  end
 end
end

local function hideGenericClubMusic(hideIt)
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 if menu then
  for _,d in ipairs(menu:GetDescendants()) do
   if d:IsA("TextButton") and d:GetAttribute("BBYACommandMenuId")=="MUSIC" then
    if hideIt then
     if d:GetAttribute("BBYAMallKPOPPrevVisible")==nil then d:SetAttribute("BBYAMallKPOPPrevVisible",d.Visible) end
     d.Visible=false
     d:SetAttribute("BBYAMallMusicSuppressed",true)
    else
     local prev=d:GetAttribute("BBYAMallKPOPPrevVisible")
     if prev~=nil then d.Visible=prev==true;d:SetAttribute("BBYAMallKPOPPrevVisible",nil) end
     d:SetAttribute("BBYAMallMusicSuppressed",nil)
    end
   end
  end
 end
 local suite=pg:FindFirstChild("BBYAMusicSuiteV1")
 if suite and suite:IsA("ScreenGui") then
  if hideIt then
   if suite:GetAttribute("BBYAMallKPOPPrevEnabled")==nil then suite:SetAttribute("BBYAMallKPOPPrevEnabled",suite.Enabled) end
   suite.Enabled=false
  else
   local prev=suite:GetAttribute("BBYAMallKPOPPrevEnabled")
   if prev~=nil then suite.Enabled=prev==true;suite:SetAttribute("BBYAMallKPOPPrevEnabled",nil) end
  end
 end
end

local function setMallAudioLocal(enabled)
 local group=SoundService:FindFirstChild("BBYAMallMaster")
 if group and group:IsA("SoundGroup") then
  group.Volume=enabled and 1 or 0
  group:SetAttribute("LocalMallAudible",enabled)
 end
end

local function refreshKState()
 local title=tostring(ReplicatedStorage:GetAttribute("BBYAMallCurrentTitle") or "—")
 local idx=tonumber(ReplicatedStorage:GetAttribute("BBYAMallCurrentIndex")) or 0
 local q=tonumber(ReplicatedStorage:GetAttribute("BBYAMallQueueCount")) or 0
 kNow.Text=string.format("NOW PLAYING · %02d · %s",idx,title)
 kQueue.Text="QUEUE · "..q.."  ·  PLAYLIST: MALL / KPOP"
end

kToggle.MouseButton1Click:Connect(function()
 if insideMall() then kPanel.Visible=not kPanel.Visible;if kPanel.Visible then rebuildKPOP();refreshKState() end end
end)
kClose.MouseButton1Click:Connect(function()kPanel.Visible=false end)

local lastInside=false
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
 elapsed+=dt
 if elapsed<.20 then return end
 elapsed=0
 local inside=insideMall()
 if inside~=lastInside then
  lastInside=inside
  kToggle.Visible=inside
  if not inside then kPanel.Visible=false end
 end
 setMallAudioLocal(inside)
 hideGenericClubMusic(inside)
 if inside then rebuildKPOP();refreshKState() end
end)

print("[BBYA] Mall KPOP UI online: visible=MALL · KPOP, generic CLUB music suppressed inside Mall")
