-- BBYA SOCIAL HUB — MALL LIVE CLIENT v4 / FUNCTIONAL POLISH v1
-- Mall-only UX authority: compact status HUD, accurate 20-stud floor tracking,
-- functional indoor directory for all 18 destinations, passport feedback,
-- and stable Avatar catalog preview framing. No venue/audio/global UI authority changes.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local event=remotes:WaitForChild("MallV2Event",30)
local mallAction=remotes:WaitForChild("MallAction",30)
if not event or not mallAction then return end

local old=pg:FindFirstChild("BBYAMallLiveUI")
if old then old:Destroy() end

local gui=Instance.new("ScreenGui")
gui.Name="BBYAMallLiveUI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=61
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui:SetAttribute("BBYAMallLiveAuthority","V4_FUNCTIONAL_POLISH_V1")
gui:SetAttribute("BBYAMallDirectoryAuthority","COMPACT_18_DESTINATIONS")
gui.Parent=pg

local C={
 bg=Color3.fromRGB(13,14,17),panel=Color3.fromRGB(24,25,29),panel2=Color3.fromRGB(34,35,40),
 white=Color3.fromRGB(245,244,240),muted=Color3.fromRGB(155,158,166),gold=Color3.fromRGB(214,170,91),
 green=Color3.fromRGB(64,181,119),cyan=Color3.fromRGB(70,190,215),line=Color3.fromRGB(63,66,73),
}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,c,t,tr)local s=Instance.new("UIStroke");s.Color=c or C.line;s.Thickness=t or 1;s.Transparency=tr or .55;s.Parent=o end
local function label(parent,name,text,pos,size,font,ts,color,align)
 local l=Instance.new("TextLabel")
 l.Name=name;l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham
 l.TextSize=ts or 10;l.TextColor3=color or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left
 l.TextYAlignment=Enum.TextYAlignment.Center;l.TextWrapped=true;l.Parent=parent;return l
end
local function button(parent,name,text,pos,size,bg)
 local b=Instance.new("TextButton")
 b.Name=name;b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.panel2;b.BackgroundTransparency=.04
 b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=9;b.AutoButtonColor=true;b.Parent=parent
 corner(b,8);stroke(b,C.line,1,.62);return b
end

-- Current geometry authority uses L1/L2/L3/L4 = 1/21/41/61 studs.
local FLOOR_Y={1,21,41,61}
local DESTINATIONS={
 {id="luma",name="LUMA FASHION",cat="Fashion",floor=1},{id="stride",name="STRIDE SNEAKERS",cat="Sneakers",floor=1},
 {id="byte",name="BYTE TECH",cat="Tech / UGC",floor=1},{id="daily",name="DAILY MARKET",cat="Food / Fun",floor=1},
 {id="mono",name="MONO HOME",cat="Lifestyle",floor=1},{id="muse",name="MUSE BEAUTY",cat="Beauty",floor=1},
 {id="north",name="NORTH LABEL",cat="Accessories",floor=2},{id="street",name="STREET UNIT",cat="Streetwear",floor=2},
 {id="page",name="PAGE & CO",cat="Books",floor=2},{id="glow",name="GLOW LAB",cat="LookLab / Photo",floor=2},
 {id="sound",name="SOUND ROOM",cat="Music",floor=2},{id="fit",name="FIT DISTRICT",cat="Sportswear",floor=2},
 {id="food",name="BBYA FOOD HALL",cat="Food Court",floor=3},{id="cafe",name="SKYLINE CAFE",cat="Cafe",floor=3},
 {id="arcade",name="PIXEL ARCADE",cat="Arcade",floor=3},{id="kids",name="LITTLE CITY",cat="Family",floor=3},
 {id="cinema",name="BBYA CINEMA",cat="Cinema",floor=4},{id="lounge",name="SKY LOUNGE",cat="Lounge / Events",floor=4},
}

local function nearestFloor(y)
 local best,bestDistance=1,math.huge
 for floor,floorY in ipairs(FLOOR_Y) do
  local d=math.abs(y-floorY)
  if d<bestDistance then best,bestDistance=floor,d end
 end
 return best
end

local function zoneFromPosition(pos)
 local level=nearestFloor(pos.Y)
 local zone="RETAIL"
 if pos.Z<315 then zone="ARRIVAL"
 elseif math.abs(pos.X)<34 and pos.Z>336 and pos.Z<394 then zone="ATRIUM"
 elseif level==3 and pos.Z>396 then zone="FOOD • PLAY"
 elseif level==4 and pos.Z>396 then zone="CINEMA • LOUNGE"
 elseif math.abs(pos.X)>48 then zone=pos.X<0 and "WEST" or "EAST" end
 return level,zone
end

local function isInsideMall(pos)
 return math.abs(pos.X)<=102 and pos.Z>=282 and pos.Z<=448 and pos.Y>=-4 and pos.Y<=88
end

-- Compact status HUD -----------------------------------------------------------
local hud=Instance.new("Frame")
hud.Name="MallHUD";hud.AnchorPoint=Vector2.new(.5,0);hud.Position=UDim2.new(.5,0,0,52);hud.Size=UDim2.fromOffset(330,60)
hud.BackgroundColor3=C.bg;hud.BackgroundTransparency=.08;hud.BorderSizePixel=0;hud.Visible=false;hud.Parent=gui
corner(hud,12);stroke(hud,C.gold,1,.48)

local brand=label(hud,"Brand","BBYA MALL",UDim2.fromOffset(14,7),UDim2.fromOffset(88,18),Enum.Font.GothamBlack,11,C.white)
local location=label(hud,"Location","L1 • ARRIVAL",UDim2.fromOffset(102,7),UDim2.new(1,-116,0,18),Enum.Font.GothamBold,9,C.gold,Enum.TextXAlignment.Right)
local status=label(hud,"Status","OPEN",UDim2.fromOffset(14,27),UDim2.fromOffset(72,14),Enum.Font.GothamBold,8,C.muted)
local directoryButton=button(hud,"DirectoryButton","DIRECTORY",UDim2.fromOffset(91,25),UDim2.fromOffset(88,18),C.panel2)
directoryButton.TextSize=8
local passportMeta=label(hud,"PassportMeta","0 / 5",UDim2.new(1,-58,0,27),UDim2.fromOffset(44,14),Enum.Font.GothamBold,8,C.muted,Enum.TextXAlignment.Right)

local pips=Instance.new("Frame")
pips.Name="PassportPips";pips.Position=UDim2.fromOffset(14,45);pips.Size=UDim2.new(1,-28,0,7);pips.BackgroundTransparency=1;pips.Parent=hud
local pipList={}
for i=1,5 do
 local p=Instance.new("Frame")
 p.Name="Pip"..i;p.Size=UDim2.new(.2,-4,1,0);p.Position=UDim2.new((i-1)*.2,0,0,0)
 p.BackgroundColor3=Color3.fromRGB(53,55,61);p.BorderSizePixel=0;p.Parent=pips;corner(p,4);table.insert(pipList,p)
end

-- Compact indoor directory -----------------------------------------------------
local directory=Instance.new("Frame")
directory.Name="MallDirectory";directory.AnchorPoint=Vector2.new(.5,0);directory.Position=UDim2.new(.5,0,0,120)
directory.Size=UDim2.fromOffset(340,350);directory.BackgroundColor3=C.bg;directory.BackgroundTransparency=.03
directory.BorderSizePixel=0;directory.Visible=false;directory.Parent=gui;corner(directory,12);stroke(directory,C.gold,1,.40)

local dirTitle=label(directory,"Title","MALL DIRECTORY",UDim2.fromOffset(12,7),UDim2.new(1,-58,0,24),Enum.Font.GothamBlack,12,C.white)
local dirClose=button(directory,"Close","×",UDim2.new(1,-38,0,5),UDim2.fromOffset(32,30),C.panel2);dirClose.TextSize=16
local dirMeta=label(directory,"Meta","L1 • 6 destinations",UDim2.fromOffset(12,31),UDim2.new(1,-24,0,18),Enum.Font.GothamMedium,8,C.muted)

local tabs=Instance.new("Frame")
tabs.Name="FloorTabs";tabs.Position=UDim2.fromOffset(10,54);tabs.Size=UDim2.new(1,-20,0,30);tabs.BackgroundTransparency=1;tabs.Parent=directory
local tabsLayout=Instance.new("UIListLayout")
tabsLayout.FillDirection=Enum.FillDirection.Horizontal;tabsLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center;tabsLayout.Padding=UDim.new(0,5);tabsLayout.Parent=tabs

local list=Instance.new("ScrollingFrame")
list.Name="DestinationList";list.Position=UDim2.fromOffset(10,91);list.Size=UDim2.new(1,-20,1,-101)
list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=3;list.ScrollBarImageColor3=C.gold
list.CanvasSize=UDim2.new();list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.Parent=directory
local listLayout=Instance.new("UIListLayout")
listLayout.Padding=UDim.new(0,6);listLayout.SortOrder=Enum.SortOrder.LayoutOrder;listLayout.Parent=list

local selectedFloor=1
local currentFloor=1
local floorButtons={}
local function clearRows()
 for _,child in ipairs(list:GetChildren()) do
  if child:IsA("TextButton") then child:Destroy() end
 end
end
local function updateFloorTabs()
 for floor,b in pairs(floorButtons) do
  local active=floor==selectedFloor
  b.BackgroundColor3=active and C.gold or C.panel2
  b.TextColor3=active and C.bg or C.white
  local s=b:FindFirstChildOfClass("UIStroke");if s then s.Transparency=active and .2 or .68 end
 end
end
local function renderDirectory()
 clearRows();updateFloorTabs();local shown=0
 for _,d in ipairs(DESTINATIONS) do
  if d.floor==selectedFloor then
   shown+=1
   local row=button(list,"Destination_"..d.id,string.format("%s\n%s   •   GO →",d.name,d.cat),UDim2.new(),UDim2.new(1,-4,0,46),C.panel)
   row.LayoutOrder=shown;row.TextXAlignment=Enum.TextXAlignment.Left;row.TextWrapped=true;row.TextSize=9
   local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,10);pad.PaddingRight=UDim.new(0,8);pad.Parent=row
   row.Activated:Connect(function()
    directory.Visible=false
    mallAction:FireServer("guide",d.id)
   end)
  end
 end
 dirMeta.Text=string.format("L%d • %d destination%s%s",selectedFloor,shown,shown==1 and "" or "s",selectedFloor==currentFloor and " • CURRENT" or "")
 list.CanvasPosition=Vector2.zero
end
for floor=1,4 do
 local b=button(tabs,"Floor"..floor,"L"..floor,UDim2.new(),UDim2.fromOffset(68,28),C.panel2)
 b.TextSize=9;floorButtons[floor]=b
 b.Activated:Connect(function()selectedFloor=floor;renderDirectory()end)
end

local banner=Instance.new("Frame")
banner.Name="PromoBanner";banner.AnchorPoint=Vector2.new(.5,0);banner.Position=UDim2.new(.5,0,0,118)
banner.Size=UDim2.fromOffset(300,40);banner.BackgroundColor3=C.bg;banner.BackgroundTransparency=.08
banner.BorderSizePixel=0;banner.Visible=false;banner.Parent=gui;corner(banner,10);stroke(banner,C.gold,1,.58)
local bannerText=label(banner,"Body","",UDim2.fromOffset(12,6),UDim2.new(1,-24,1,-12),Enum.Font.GothamBold,8,C.white,Enum.TextXAlignment.Center)
local bannerToken=0
local function showBanner(title,body)
 bannerToken+=1;local token=bannerToken
 bannerText.Text=(title and title~="" and (title.." • ") or "")..tostring(body or "")
 if directory.Visible then return end
 banner.Visible=true;banner.BackgroundTransparency=.08
 task.delay(3.3,function()
  if token~=bannerToken then return end
  local tw=TweenService:Create(banner,TweenInfo.new(.2),{BackgroundTransparency=1});tw:Play();tw.Completed:Wait()
  if token==bannerToken then banner.Visible=false end
 end)
end

local inside=false
local function setProgress(n,total,complete,last)
 total=tonumber(total) or 5
 local count=math.clamp(tonumber(n) or 0,0,total)
 passportMeta.Text=complete and "DONE" or string.format("%d / %d",count,total)
 passportMeta.TextColor3=complete and C.green or C.muted
 for i,p in ipairs(pipList) do p.BackgroundColor3=i<=count and (complete and C.green or C.gold) or Color3.fromRGB(53,55,61) end
 if last then showBanner("PASSPORT",last.."  "..count.."/"..total) end
end
setProgress(player:GetAttribute("BBYAMallPassport") or 0,5,player:GetAttribute("BBYAMallPassportComplete")==true,nil)

local function setInside(value)
 inside=value==true;hud.Visible=inside
 if not inside then directory.Visible=false;banner.Visible=false end
end

directoryButton.Activated:Connect(function()
 if not inside then return end
 if not directory.Visible then selectedFloor=currentFloor;renderDirectory() end
 directory.Visible=not directory.Visible
 if directory.Visible then banner.Visible=false end
end)
dirClose.Activated:Connect(function()directory.Visible=false end)

local camera=workspace.CurrentCamera
local function responsive()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local phone=UserInputService.TouchEnabled or vp.X<900 or vp.Y<650
 local hudW=phone and math.min(286,math.max(250,vp.X-20)) or 330
 hud.Size=UDim2.fromOffset(hudW,phone and 58 or 60)
 hud.Position=UDim2.new(.5,0,0,phone and 44 or 52)
 local dirW=math.min(phone and 292 or 340,math.max(250,vp.X-20))
 local dirY=phone and 108 or 120
 local dirH=math.max(205,math.min(phone and 320 or 350,vp.Y-dirY-14))
 directory.Position=UDim2.new(.5,0,0,dirY);directory.Size=UDim2.fromOffset(dirW,dirH)
 local tabW=math.floor((dirW-20-15)/4)
 for _,b in pairs(floorButtons) do b.Size=UDim2.fromOffset(tabW,28) end
 banner.Size=UDim2.fromOffset(phone and math.min(270,math.floor(vp.X*.72)) or 300,38)
 banner.Position=UDim2.new(.5,0,0,phone and 108 or 118)
end
task.defer(responsive)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(responsive)end)

event.OnClientEvent:Connect(function(mode,data)
 data=data or {}
 if mode=="presence" then setInside(data.inside==true)
 elseif mode=="passport" then setProgress(data.count,data.total,data.complete,data.last)
 elseif mode=="promo" then showBanner(data.title,data.body) end
end)

player:GetAttributeChangedSignal("BBYAInsideMall"):Connect(function()setInside(player:GetAttribute("BBYAInsideMall")==true)end)
player:GetAttributeChangedSignal("BBYAMallPassport"):Connect(function()
 setProgress(player:GetAttribute("BBYAMallPassport") or 0,5,player:GetAttribute("BBYAMallPassportComplete")==true,nil)
end)

-- Position remains the fallback truth because presence events/attributes can arrive late.
task.spawn(function()
 while gui.Parent do
  local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if hrp then
   local pos=hrp.Position
   local now=isInsideMall(pos)
   if now~=inside then setInside(now) end
   if now then
    local lvl,zone=zoneFromPosition(pos);currentFloor=lvl
    location.Text=string.format("L%d • %s",lvl,zone)
    if directory.Visible and selectedFloor==lvl then dirMeta.Text=string.format("L%d • CURRENT",lvl) end
    if player:GetAttribute("BBYAMallPassportComplete")==true then status.Text="EXPLORER";status.TextColor3=C.green
    else status.Text="OPEN";status.TextColor3=C.muted end
   end
  end
  task.wait(.35)
 end
end)

-- Mall avatar viewport framing stabilizer -------------------------------------
-- 133 owns catalog/commerce. This corrects only preview-camera framing using
-- avatar body parts, never accessory mesh bounds.
local BODY_NAMES={
 Head=true,UpperTorso=true,LowerTorso=true,HumanoidRootPart=true,
 LeftUpperArm=true,LeftLowerArm=true,LeftHand=true,RightUpperArm=true,RightLowerArm=true,RightHand=true,
 LeftUpperLeg=true,LeftLowerLeg=true,LeftFoot=true,RightUpperLeg=true,RightLowerLeg=true,RightFoot=true,
 Torso=true,["Left Arm"]=true,["Right Arm"]=true,["Left Leg"]=true,["Right Leg"]=true,
}
local previewConnections={}
local boundPreviewWorld=nil
local function clearPreviewConnections()
 for _,c in ipairs(previewConnections)do c:Disconnect()end
 table.clear(previewConnections);boundPreviewWorld=nil
end
local function bodyBounds(model)
 local minV=Vector3.new(math.huge,math.huge,math.huge);local maxV=Vector3.new(-math.huge,-math.huge,-math.huge);local count=0
 for _,d in ipairs(model:GetDescendants())do
  if d:IsA("BasePart")and BODY_NAMES[d.Name]then
   local p=d.Position;local half=d.Size*.5
   minV=Vector3.new(math.min(minV.X,p.X-half.X),math.min(minV.Y,p.Y-half.Y),math.min(minV.Z,p.Z-half.Z))
   maxV=Vector3.new(math.max(maxV.X,p.X+half.X),math.max(maxV.Y,p.Y+half.Y),math.max(maxV.Z,p.Z+half.Z));count+=1
  end
 end
 if count<3 then return nil end
 return (minV+maxV)*.5,maxV-minV
end
local function frameMallPreview(viewport,model)
 local cam=viewport and viewport.CurrentCamera;if not cam or not model then return end
 local center,size=bodyBounds(model);if not center or not size then return end
 local rootPart=model:FindFirstChild("HumanoidRootPart",true)
 local forward=rootPart and rootPart.CFrame.LookVector or Vector3.new(0,0,-1);forward=Vector3.new(forward.X,0,forward.Z)
 if forward.Magnitude<.01 then forward=Vector3.new(0,0,-1)else forward=forward.Unit end
 local h=math.clamp(size.Y,4.5,8.5);local w=math.clamp(math.max(size.X,size.Z),2.5,6);local target=center+Vector3.new(0,h*.01,0)
 cam.FieldOfView=34;cam.CFrame=CFrame.lookAt(target+forward*math.max(h*1.75,w*2),target,Vector3.yAxis)
end
local function bindMallPreview()
 clearPreviewConnections()
 local mall=pg:FindFirstChild("BBYAMallRobuxCommerceUI");local catalogRoot=mall and mall:FindFirstChild("CatalogRoot");local avatar=catalogRoot and catalogRoot:FindFirstChild("AvatarCard");local viewport=avatar and avatar:FindFirstChild("AvatarViewport");local world=viewport and viewport:FindFirstChildOfClass("WorldModel")
 if not viewport or not world then return end;boundPreviewWorld=world
 local function refresh()
  if boundPreviewWorld~=world or not world.Parent then return end;local model=world:FindFirstChildOfClass("Model");if not model then return end
  task.defer(function()if model.Parent==world then frameMallPreview(viewport,model)end end)
  task.delay(.12,function()if model.Parent==world then frameMallPreview(viewport,model)end end)
  task.delay(.35,function()if model.Parent==world then frameMallPreview(viewport,model)end end)
 end
 table.insert(previewConnections,world.ChildAdded:Connect(refresh));table.insert(previewConnections,world.DescendantAdded:Connect(function(d)if d:IsA("BasePart")then refresh()end end));table.insert(previewConnections,viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh));refresh()
end
pg.ChildAdded:Connect(function(ch)if ch.Name=="BBYAMallRobuxCommerceUI"then task.delay(.1,bindMallPreview)end end)
pg.ChildRemoved:Connect(function(ch)if ch.Name=="BBYAMallRobuxCommerceUI"then clearPreviewConnections()end end)
task.defer(bindMallPreview)

print("[BBYA] Mall Live Client v4 online: accurate 20-stud HUD + compact functional directory + stable catalog preview")
