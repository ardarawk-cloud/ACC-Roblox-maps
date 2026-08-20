-- BBYA SOCIAL HUB — COMMUNITY TAB v1
-- Persistent top-dock Community entry. Keeps external links off-platform by
-- directing guests to the official Social Links section on the BBYA game page.

local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local clubUI=pg:WaitForChild("BBYAClubUI",20)
if not clubUI then return end

local dock=clubUI:FindFirstChild("TopDock",true)
if not dock then return end

local C={
 panel=Color3.fromRGB(12,11,17),
 panel2=Color3.fromRGB(22,18,28),
 panel3=Color3.fromRGB(30,23,38),
 white=Color3.fromRGB(245,243,248),
 muted=Color3.fromRGB(169,162,177),
 cyan=Color3.fromRGB(29,199,226),
 pink=Color3.fromRGB(244,50,151),
 gold=Color3.fromRGB(231,183,88),
 green=Color3.fromRGB(75,210,132),
}

local function round(o,r)
 local c=Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,r or 10)
 c.Parent=o
 return c
end

local function stroke(o,col,t,tr)
 local s=Instance.new("UIStroke")
 s.Color=col or C.cyan
 s.Thickness=t or 1
 s.Transparency=tr or .45
 s.Parent=o
 return s
end

local function label(parent,text,pos,size,font,textSize,color,align)
 local l=Instance.new("TextLabel")
 l.BackgroundTransparency=1
 l.Text=text
 l.Position=pos
 l.Size=size
 l.Font=font or Enum.Font.Gotham
 l.TextSize=textSize or 16
 l.TextColor3=color or C.white
 l.TextWrapped=true
 l.TextXAlignment=align or Enum.TextXAlignment.Left
 l.TextYAlignment=Enum.TextYAlignment.Center
 l.Parent=parent
 return l
end

local function findDockButton(word)
 word=word:upper()
 for _,obj in ipairs(dock:GetChildren()) do
  if obj:IsA("TextButton") and tostring(obj.Text):upper():find(word,1,true) then return obj end
 end
end

local brand=findDockButton("BBYA")
local music=findDockButton("MUSIC")
local support=findDockButton("SUPPORT")
local travel=findDockButton("TRAVEL")
local message=dock:FindFirstChild("MessageTab") or findDockButton("MESSAGE")

local community=dock:FindFirstChild("CommunityTab")
if not community then
 community=Instance.new("TextButton")
 community.Name="CommunityTab"
 community.Text="COMMUNITY"
 community.BackgroundColor3=Color3.fromRGB(22,35,44)
 community.TextColor3=C.white
 community.Font=Enum.Font.GothamSemibold
 community.TextSize=11
 community.BorderSizePixel=0
 community.AutoButtonColor=true
 community.Parent=dock
 round(community,9)
 stroke(community,C.cyan,1,.42)
end

local existing=clubUI:FindFirstChild("CommunityOverlay")
if existing then existing:Destroy() end

local shade=Instance.new("Frame")
shade.Name="CommunityOverlay"
shade.Size=UDim2.fromScale(1,1)
shade.BackgroundColor3=Color3.fromRGB(0,0,0)
shade.BackgroundTransparency=.30
shade.BorderSizePixel=0
shade.Visible=false
shade.ZIndex=80
shade.Parent=clubUI

local panel=Instance.new("Frame")
panel.Name="CommunityPanel"
panel.AnchorPoint=Vector2.new(.5,.5)
panel.Position=UDim2.fromScale(.5,.54)
panel.BackgroundColor3=C.panel
panel.BorderSizePixel=0
panel.ZIndex=81
panel.Parent=shade
round(panel,18)
stroke(panel,Color3.fromRGB(69,55,78),1,.18)

local header=Instance.new("Frame")
header.Size=UDim2.new(1,0,0,74)
header.BackgroundColor3=C.panel2
header.BorderSizePixel=0
header.ZIndex=82
header.Parent=panel
round(header,18)
local headerMask=Instance.new("Frame")
headerMask.Position=UDim2.new(0,0,1,-20)
headerMask.Size=UDim2.new(1,0,0,20)
headerMask.BackgroundColor3=C.panel2
headerMask.BorderSizePixel=0
headerMask.ZIndex=82
headerMask.Parent=header

label(header,"BBYA COMMUNITY",UDim2.fromOffset(22,10),UDim2.new(1,-90,0,31),Enum.Font.GothamBlack,23,C.white).ZIndex=83
label(header,"OFFICIAL COMMUNITY HUB",UDim2.fromOffset(22,39),UDim2.new(1,-90,0,21),Enum.Font.GothamBold,11,C.cyan).ZIndex=83

local close=Instance.new("TextButton")
close.Text="×"
close.Position=UDim2.new(1,-55,0,14)
close.Size=UDim2.fromOffset(40,40)
close.BackgroundColor3=Color3.fromRGB(39,31,47)
close.TextColor3=C.white
close.Font=Enum.Font.GothamBold
close.TextSize=25
close.BorderSizePixel=0
close.ZIndex=84
close.Parent=header
round(close,12)

local body=Instance.new("ScrollingFrame")
body.Name="CommunityScroller"
body.Position=UDim2.fromOffset(14,88)
body.Size=UDim2.new(1,-28,1,-102)
body.BackgroundTransparency=1
body.BorderSizePixel=0
body.Active=true
body.ScrollingEnabled=true
body.ScrollingDirection=Enum.ScrollingDirection.Y
body.ElasticBehavior=Enum.ElasticBehavior.Always
body.ScrollBarThickness=5
body.ScrollBarImageColor3=C.cyan
body.ScrollBarImageTransparency=.18
body.CanvasSize=UDim2.fromOffset(0,560)
body.ZIndex=82
body.Parent=panel

local intro=Instance.new("Frame")
intro.Position=UDim2.fromOffset(0,0)
intro.Size=UDim2.new(1,-8,0,115)
intro.BackgroundColor3=C.panel2
intro.BorderSizePixel=0
intro.ZIndex=83
intro.Parent=body
round(intro,15)
stroke(intro,Color3.fromRGB(69,57,79),1,.40)
label(intro,"DISCORD COMMUNITY",UDim2.fromOffset(18,14),UDim2.new(1,-36,0,29),Enum.Font.GothamBlack,19,C.white).ZIndex=84
label(intro,"Event alerts • DJ nights • updates • feedback • hangout",UDim2.fromOffset(18,45),UDim2.new(1,-36,0,42),Enum.Font.GothamMedium,13,C.muted).ZIndex=84
local liveDot=label(intro,"●  COMMUNITY ONLINE",UDim2.fromOffset(18,86),UDim2.new(1,-36,0,18),Enum.Font.GothamBold,11,C.green)
liveDot.ZIndex=84

local join=Instance.new("Frame")
join.Position=UDim2.fromOffset(0,128)
join.Size=UDim2.new(1,-8,0,184)
join.BackgroundColor3=Color3.fromRGB(18,27,35)
join.BorderSizePixel=0
join.ZIndex=83
join.Parent=body
round(join,15)
stroke(join,C.cyan,1,.28)
label(join,"JOIN FROM THE BBYA GAME PAGE",UDim2.fromOffset(18,14),UDim2.new(1,-36,0,28),Enum.Font.GothamBlack,17,C.cyan).ZIndex=84
label(join,"1",UDim2.fromOffset(18,55),UDim2.fromOffset(30,30),Enum.Font.GothamBlack,16,C.gold,Enum.TextXAlignment.Center).ZIndex=84
label(join,"Open the BBYA Social Hub game page",UDim2.fromOffset(58,50),UDim2.new(1,-76,0,38),Enum.Font.GothamSemibold,13,C.white).ZIndex=84
label(join,"2",UDim2.fromOffset(18,96),UDim2.fromOffset(30,30),Enum.Font.GothamBlack,16,C.gold,Enum.TextXAlignment.Center).ZIndex=84
label(join,"Find the official Social Links section",UDim2.fromOffset(58,91),UDim2.new(1,-76,0,38),Enum.Font.GothamSemibold,13,C.white).ZIndex=84
label(join,"3",UDim2.fromOffset(18,137),UDim2.fromOffset(30,30),Enum.Font.GothamBlack,16,C.gold,Enum.TextXAlignment.Center).ZIndex=84
label(join,"Tap Discord and join the BBYA community",UDim2.fromOffset(58,132),UDim2.new(1,-76,0,38),Enum.Font.GothamSemibold,13,C.white).ZIndex=84

local why=Instance.new("Frame")
why.Position=UDim2.fromOffset(0,325)
why.Size=UDim2.new(1,-8,0,158)
why.BackgroundColor3=C.panel2
why.BorderSizePixel=0
why.ZIndex=83
why.Parent=body
round(why,15)
label(why,"WHY JOIN?",UDim2.fromOffset(18,13),UDim2.new(1,-36,0,25),Enum.Font.GothamBlack,16,C.pink).ZIndex=84
label(why,"• Early event announcements\n• Community polls & feedback\n• DJ / music updates\n• Meet other BBYA regulars\n• Creator & project updates",UDim2.fromOffset(18,43),UDim2.new(1,-36,0,100),Enum.Font.GothamMedium,13,C.muted).ZIndex=84

local note=label(body,"External links are available only through BBYA's official game-page Social Links.",UDim2.fromOffset(6,496),UDim2.new(1,-20,0,48),Enum.Font.GothamMedium,11,C.muted,Enum.TextXAlignment.Center)
note.ZIndex=84

local function setOpen(value)
 shade.Visible=value
 community.BackgroundColor3=value and Color3.fromRGB(23,84,101) or Color3.fromRGB(22,35,44)
end

community.MouseButton1Click:Connect(function()
 setOpen(not shade.Visible)
end)
close.MouseButton1Click:Connect(function()setOpen(false)end)

for _,btn in ipairs({brand,music,support,travel,message}) do
 if btn and btn:IsA("TextButton") then
  btn.MouseButton1Click:Connect(function()setOpen(false)end)
 end
end

shade.InputBegan:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
  local p=input.Position
  local absPos=panel.AbsolutePosition
  local absSize=panel.AbsoluteSize
  if p.X<absPos.X or p.X>absPos.X+absSize.X or p.Y<absPos.Y or p.Y>absPos.Y+absSize.Y then
   setOpen(false)
  end
 end
end)

local function layout()
 local vp=camera.ViewportSize
 local dockW=math.clamp(vp.X-16,360,940)
 dock.Size=UDim2.fromOffset(dockW,52)
 local pad=6
 local gap=4
 local brandW=math.clamp(dockW*.12,46,72)
 local rest=(dockW-pad*2-brandW-gap*5)/5
 local x=pad
 local function place(btn,width)
  if not btn then return end
  btn.Position=UDim2.fromOffset(x,6)
  btn.Size=UDim2.fromOffset(width,40)
  x+=width+gap
 end
 place(brand,brandW)
 place(music,rest)
 place(support,rest)
 place(travel,rest)
 place(message,rest)
 place(community,rest)

 local compact=vp.X<760
 if brand then brand.TextSize=compact and 9 or 12 end
 if music then music.Text=compact and "MUSIC" or "♫  MUSIC";music.TextSize=compact and 8 or 11 end
 if support then support.Text=compact and "SUPPORT" or "◇  SUPPORT";support.TextSize=compact and 8 or 11 end
 if travel then travel.Text=compact and "TRAVEL" or "⌖  TRAVEL";travel.TextSize=compact and 8 or 11 end
 if message then message.Text=compact and "MESSAGE" or "✦  MESSAGE";message.TextSize=compact and 8 or 11 end
 community.Text=compact and "COMM" or "◆  COMMUNITY"
 community.TextSize=compact and 8 or 11

 local pw=math.clamp(vp.X-28,330,560)
 local ph=math.clamp(vp.Y-155,430,560)
 panel.Size=UDim2.fromOffset(pw,ph)
 panel.Position=UDim2.fromScale(.5,vp.Y<650 and .56 or .54)
 body.CanvasSize=UDim2.fromOffset(0,560)
end

layout()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)

print("[BBYA] Community top-tab v1 online: Discord via official game-page Social Links")
