-- BBYA SOCIAL HUB — MALL LIVE CLIENT v2
-- Lightweight mall-only HUD: level/zone awareness, 5-zone passport progress,
-- rotating operational banner and photo booth flash feedback.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local event=remotes:WaitForChild("MallV2Event",30)
if not event then return end

local old=pg:FindFirstChild("BBYAMallLiveUI");if old then old:Destroy() end
local gui=Instance.new("ScreenGui");gui.Name="BBYAMallLiveUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=61;gui.Parent=pg
local C={bg=Color3.fromRGB(13,14,17),card=Color3.fromRGB(25,27,31),line=Color3.fromRGB(63,66,73),white=Color3.fromRGB(245,244,240),muted=Color3.fromRGB(155,158,166),gold=Color3.fromRGB(214,170,91),pink=Color3.fromRGB(235,56,147),cyan=Color3.fromRGB(38,192,214),green=Color3.fromRGB(64,181,119)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,c,t,tr)local s=Instance.new("UIStroke");s.Color=c or C.line;s.Thickness=t or 1;s.Transparency=tr or .55;s.Parent=o end
local function label(parent,name,text,pos,size,font,ts,color,align)
 local l=Instance.new("TextLabel");l.Name=name;l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=color or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextWrapped=true;l.Parent=parent;return l
end

local hud=Instance.new("Frame");hud.Name="MallHUD";hud.AnchorPoint=Vector2.new(1,0);hud.Position=UDim2.new(1,-16,0,64);hud.Size=UDim2.fromOffset(300,122);hud.BackgroundColor3=C.bg;hud.BackgroundTransparency=.08;hud.BorderSizePixel=0;hud.Visible=false;hud.Parent=gui;corner(hud,14);stroke(hud,C.gold,1,.42)
local accent=Instance.new("Frame");accent.Size=UDim2.new(0,4,1,-16);accent.Position=UDim2.fromOffset(8,8);accent.BackgroundColor3=C.gold;accent.BorderSizePixel=0;accent.Parent=hud;corner(accent,3)
label(hud,"Brand","BBYA MALL",UDim2.fromOffset(22,12),UDim2.new(1,-40,0,20),Enum.Font.GothamBlack,13,C.white)
local location=label(hud,"Location","LEVEL 1 • ARRIVAL",UDim2.fromOffset(22,34),UDim2.new(1,-40,0,17),Enum.Font.GothamBold,8,C.gold)
local status=label(hud,"Status","OPEN • ACTIVE MALL",UDim2.fromOffset(22,53),UDim2.new(1,-40,0,16),Enum.Font.GothamBold,8,C.muted)
label(hud,"PassportTitle","MALL PASSPORT",UDim2.fromOffset(22,76),UDim2.fromOffset(92,16),Enum.Font.GothamBold,8,C.white)
local passportMeta=label(hud,"PassportMeta","0 / 5",UDim2.new(1,-60,0,76),UDim2.fromOffset(40,16),Enum.Font.GothamBold,8,C.muted,Enum.TextXAlignment.Right)
local pips=Instance.new("Frame");pips.Name="PassportPips";pips.Position=UDim2.fromOffset(22,98);pips.Size=UDim2.new(1,-44,0,10);pips.BackgroundTransparency=1;pips.Parent=hud
local pipList={}
for i=1,5 do
 local p=Instance.new("Frame");p.Name="Pip"..i;p.Size=UDim2.new(.2,-4,1,0);p.Position=UDim2.new((i-1)*.2,0,0,0);p.BackgroundColor3=Color3.fromRGB(53,55,61);p.BorderSizePixel=0;p.Parent=pips;corner(p,5);table.insert(pipList,p)
end

local banner=Instance.new("Frame");banner.Name="PromoBanner";banner.AnchorPoint=Vector2.new(.5,0);banner.Position=UDim2.new(.5,0,0,58);banner.Size=UDim2.fromOffset(420,70);banner.BackgroundColor3=C.bg;banner.BackgroundTransparency=.04;banner.BorderSizePixel=0;banner.Visible=false;banner.Parent=gui;corner(banner,13);stroke(banner,C.gold,1,.38)
local bannerTitle=label(banner,"Title","BBYA MALL",UDim2.fromOffset(18,12),UDim2.new(1,-36,0,20),Enum.Font.GothamBlack,13,C.gold)
local bannerBody=label(banner,"Body","",UDim2.fromOffset(18,34),UDim2.new(1,-36,0,28),Enum.Font.GothamMedium,9,C.white)
local bannerToken=0
local function showBanner(title,body)
 bannerToken+=1;local my=bannerToken
 bannerTitle.Text=title or "BBYA MALL";bannerBody.Text=body or "";banner.Visible=true;banner.BackgroundTransparency=.04
 banner.Position=UDim2.new(.5,0,0,46)
 TweenService:Create(banner,TweenInfo.new(.22,Enum.EasingStyle.Quad),{Position=UDim2.new(.5,0,0,58)}):Play()
 task.delay(4.5,function()
  if my~=bannerToken then return end
  local tw=TweenService:Create(banner,TweenInfo.new(.25),{BackgroundTransparency=1,Position=UDim2.new(.5,0,0,48)});tw:Play();tw.Completed:Wait();if my==bannerToken then banner.Visible=false end
 end)
end

local flash=Instance.new("Frame");flash.Name="PhotoFlash";flash.Size=UDim2.fromScale(1,1);flash.BackgroundColor3=Color3.new(1,1,1);flash.BackgroundTransparency=1;flash.BorderSizePixel=0;flash.ZIndex=100;flash.Parent=gui
local function photoFlash()
 flash.BackgroundTransparency=.04
 TweenService:Create(flash,TweenInfo.new(.38,Enum.EasingStyle.Quad),{BackgroundTransparency=1}):Play()
end

local inside=false
local count=tonumber(player:GetAttribute("BBYAMallPassport")) or 0
local function setProgress(n,total,complete,last)
 count=math.clamp(tonumber(n) or 0,0,total or 5);total=total or 5
 passportMeta.Text=complete and "COMPLETE" or string.format("%d / %d",count,total)
 passportMeta.TextColor3=complete and C.green or C.muted
 for i,p in ipairs(pipList) do
  p.BackgroundColor3=i<=count and (complete and C.green or C.gold) or Color3.fromRGB(53,55,61)
 end
 if last then showBanner("MALL PASSPORT",last.." • CHECK-IN "..count.." / "..total) end
end
setProgress(count,5,player:GetAttribute("BBYAMallPassportComplete")==true,nil)

local function zoneFromPosition(pos)
 local level
 if pos.Y>=40 then level=4 elseif pos.Y>=26 then level=3 elseif pos.Y>=12 then level=2 else level=1 end
 local zone="RETAIL"
 if pos.Z<315 then zone="ARRIVAL"
 elseif math.abs(pos.X)<34 and pos.Z>336 and pos.Z<394 then zone="ATRIUM"
 elseif level==3 and pos.Z>396 then zone="FOOD • PLAY"
 elseif level==4 and pos.Z>396 then zone="CINEMA"
 elseif math.abs(pos.X)>48 then zone=pos.X<0 and "WEST WING" or "EAST WING" end
 return level,zone
end

local camera=workspace.CurrentCamera
local function responsive()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local phone=UserInputService.TouchEnabled or vp.Y<800
 hud.Size=UDim2.fromOffset(phone and 244 or 300,phone and 112 or 122)
 hud.Position=UDim2.new(1,-(phone and 8 or 16),0,phone and 54 or 64)
 banner.Size=UDim2.fromOffset(math.clamp(math.floor(vp.X*.72),280,420),phone and 64 or 70)
end
task.defer(responsive)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(responsive)end)

event.OnClientEvent:Connect(function(mode,data)
 data=data or {}
 if mode=="presence" then
  inside=data.inside==true;hud.Visible=inside
  if inside then showBanner("BBYA MALL","ACTIVE • 4 LEVELS • 18 DESTINATIONS • MALL PASSPORT") end
 elseif mode=="passport" then
  setProgress(data.count,data.total,data.complete,data.last)
 elseif mode=="promo" then
  showBanner(data.title,data.body)
 elseif mode=="photo_flash" then
  photoFlash()
 end
end)

player:GetAttributeChangedSignal("BBYAInsideMall"):Connect(function()
 inside=player:GetAttribute("BBYAInsideMall")==true;hud.Visible=inside
end)
player:GetAttributeChangedSignal("BBYAMallPassport"):Connect(function()
 setProgress(player:GetAttribute("BBYAMallPassport") or 0,5,player:GetAttribute("BBYAMallPassportComplete")==true,nil)
end)

task.spawn(function()
 while gui.Parent do
  local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if hrp then
   local pos=hrp.Position
   local now=math.abs(pos.X)<=100 and pos.Z>=282 and pos.Z<=448 and pos.Y>=-2 and pos.Y<=66
   if now~=inside then inside=now;hud.Visible=now end
   if now then
    local lvl,zone=zoneFromPosition(pos);location.Text=string.format("LEVEL %d • %s",lvl,zone)
    if player:GetAttribute("BBYAMallPassportComplete")==true then status.Text="MALL EXPLORER • PASSPORT COMPLETE";status.TextColor3=C.green
    else status.Text="OPEN • ACTIVE MALL";status.TextColor3=C.muted end
   end
  end
  task.wait(.45)
 end
end)

print("[BBYA] Mall Live Client v2 online: mall HUD / live zone / passport / promo / photo feedback")