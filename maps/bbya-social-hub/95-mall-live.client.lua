-- BBYA SOCIAL HUB — MALL LIVE CLIENT v3 / COMPACT HUD v7
-- Screenshot-driven mobile cleanup: centered compact Mall status instead of a large right-side card.

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

local old=pg:FindFirstChild("BBYAMallLiveUI")
if old then old:Destroy() end

local gui=Instance.new("ScreenGui")
gui.Name="BBYAMallLiveUI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=61
gui.Parent=pg

local C={
 bg=Color3.fromRGB(13,14,17),white=Color3.fromRGB(245,244,240),muted=Color3.fromRGB(155,158,166),
 gold=Color3.fromRGB(214,170,91),green=Color3.fromRGB(64,181,119),line=Color3.fromRGB(63,66,73)
}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,c,t,tr)local s=Instance.new("UIStroke");s.Color=c or C.line;s.Thickness=t or 1;s.Transparency=tr or .55;s.Parent=o end
local function label(parent,name,text,pos,size,font,ts,color,align)
 local l=Instance.new("TextLabel")
 l.Name=name;l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham
 l.TextSize=ts or 10;l.TextColor3=color or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left
 l.TextWrapped=true;l.Parent=parent;return l
end

local hud=Instance.new("Frame")
hud.Name="MallHUD"
hud.AnchorPoint=Vector2.new(.5,0)
hud.Position=UDim2.new(.5,0,0,52)
hud.Size=UDim2.fromOffset(330,60)
hud.BackgroundColor3=C.bg
hud.BackgroundTransparency=.08
hud.BorderSizePixel=0
hud.Visible=false
hud.Parent=gui
corner(hud,12);stroke(hud,C.gold,1,.48)

local brand=label(hud,"Brand","BBYA MALL",UDim2.fromOffset(14,8),UDim2.fromOffset(88,18),Enum.Font.GothamBlack,11,C.white)
local location=label(hud,"Location","L1 • ARRIVAL",UDim2.fromOffset(102,8),UDim2.new(1,-116,0,18),Enum.Font.GothamBold,9,C.gold,Enum.TextXAlignment.Right)
local status=label(hud,"Status","OPEN",UDim2.fromOffset(14,27),UDim2.fromOffset(82,14),Enum.Font.GothamBold,8,C.muted)
local passportMeta=label(hud,"PassportMeta","0 / 5",UDim2.new(1,-58,0,27),UDim2.fromOffset(44,14),Enum.Font.GothamBold,8,C.muted,Enum.TextXAlignment.Right)

local pips=Instance.new("Frame")
pips.Name="PassportPips";pips.Position=UDim2.fromOffset(14,45);pips.Size=UDim2.new(1,-28,0,7);pips.BackgroundTransparency=1;pips.Parent=hud
local pipList={}
for i=1,5 do
 local p=Instance.new("Frame")
 p.Name="Pip"..i;p.Size=UDim2.new(.2,-4,1,0);p.Position=UDim2.new((i-1)*.2,0,0,0)
 p.BackgroundColor3=Color3.fromRGB(53,55,61);p.BorderSizePixel=0;p.Parent=pips;corner(p,4);table.insert(pipList,p)
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

local function zoneFromPosition(pos)
 local level
 if pos.Y>=40 then level=4 elseif pos.Y>=26 then level=3 elseif pos.Y>=12 then level=2 else level=1 end
 local zone="RETAIL"
 if pos.Z<315 then zone="ARRIVAL"
 elseif math.abs(pos.X)<34 and pos.Z>336 and pos.Z<394 then zone="ATRIUM"
 elseif level==3 and pos.Z>396 then zone="FOOD • PLAY"
 elseif level==4 and pos.Z>396 then zone="CINEMA"
 elseif math.abs(pos.X)>48 then zone=pos.X<0 and "WEST" or "EAST" end
 return level,zone
end

local camera=workspace.CurrentCamera
local function responsive()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local phone=UserInputService.TouchEnabled or vp.Y<800
 hud.Size=UDim2.fromOffset(phone and 276 or 330,phone and 56 or 60)
 hud.Position=UDim2.new(.5,0,0,phone and 46 or 52)
 banner.Size=UDim2.fromOffset(phone and math.min(270,math.floor(vp.X*.72)) or 300,38)
 banner.Position=UDim2.new(.5,0,0,phone and 106 or 118)
end
task.defer(responsive)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(responsive)end)

event.OnClientEvent:Connect(function(mode,data)
 data=data or {}
 if mode=="presence" then
  inside=data.inside==true;hud.Visible=inside
 elseif mode=="passport" then
  setProgress(data.count,data.total,data.complete,data.last)
 elseif mode=="promo" then
  showBanner(data.title,data.body)
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
    local lvl,zone=zoneFromPosition(pos)
    location.Text=string.format("L%d • %s",lvl,zone)
    if player:GetAttribute("BBYAMallPassportComplete")==true then status.Text="EXPLORER";status.TextColor3=C.green
    else status.Text="OPEN";status.TextColor3=C.muted end
   end
  end
  task.wait(.4)
 end
end)

print("[BBYA] Mall Live Client v3 online: compact centered HUD v7")
