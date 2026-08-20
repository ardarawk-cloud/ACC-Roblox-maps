-- BBYA SOCIAL HUB — DJ WALL MESSAGE CLIENT v2
-- Mobile-safe composer: respects Roblox top inset, sticky header/footer, scrollable body.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local wallRemote=remotes:WaitForChild("DJWall")

local old=pg:FindFirstChild("BBYADJWallUI")
if old then old:Destroy() end

local C={BG=Color3.fromRGB(8,8,11),PANEL=Color3.fromRGB(17,15,21),CARD=Color3.fromRGB(27,23,32),PINK=Color3.fromRGB(247,55,158),CYAN=Color3.fromRGB(32,190,215),GOLD=Color3.fromRGB(215,169,96),WHITE=Color3.fromRGB(244,243,247),MUTED=Color3.fromRGB(158,154,166),GREEN=Color3.fromRGB(62,205,124)}
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,t,tr)local s=Instance.new("UIStroke");s.Color=col or C.PINK;s.Thickness=t or 1;s.Transparency=tr or .35;s.Parent=o;return s end
local function label(parent,text,pos,size,font,ts,col,align)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 13;l.TextColor3=col or C.WHITE;l.TextWrapped=true;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=parent;return l
end
local function button(parent,text,pos,size,bg)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.CARD;b.BorderSizePixel=0;b.TextColor3=C.WHITE;b.Font=Enum.Font.GothamBold;b.TextSize=12;b.AutoButtonColor=true;b.Parent=parent;round(b,10);return b
end

local gui=Instance.new("ScreenGui")
gui.Name="BBYADJWallUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.DisplayOrder=35;gui.Parent=pg

local shade=Instance.new("Frame")
shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.45;shade.BorderSizePixel=0;shade.Visible=false;shade.Parent=gui

local panel=Instance.new("Frame")
panel.Name="DJWallComposerPanel";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.52);panel.Size=UDim2.fromOffset(520,430);panel.BackgroundColor3=C.BG;panel.BorderSizePixel=0;panel.Visible=false;panel.ClipsDescendants=true;panel.Parent=gui;round(panel,18);stroke(panel,C.PINK,1.3,.28)
local grad=Instance.new("UIGradient");grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(28,16,27)),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,9,13))});grad.Rotation=90;grad.Parent=panel

-- STICKY HEADER ---------------------------------------------------------------
local header=Instance.new("Frame")
header.Name="StickyHeader";header.Position=UDim2.fromOffset(0,0);header.Size=UDim2.new(1,0,0,72);header.BackgroundColor3=Color3.fromRGB(10,9,13);header.BackgroundTransparency=.08;header.BorderSizePixel=0;header.ZIndex=10;header.Parent=panel
label(header,"DJ WALL MESSAGE",UDim2.fromOffset(20,10),UDim2.new(1,-78,0,28),Enum.Font.GothamBlack,19,C.WHITE).ZIndex=11
label(header,"Ucapanmu tampil di layar besar belakang DJ",UDim2.fromOffset(20,38),UDim2.new(1,-78,0,19),Enum.Font.Gotham,9,C.MUTED).ZIndex=11
local close=button(header,"×",UDim2.new(1,-52,0,12),UDim2.fromOffset(36,36),Color3.fromRGB(34,30,39));close.TextSize=21;close.ZIndex=12
local headLine=Instance.new("Frame");headLine.Position=UDim2.new(0,16,1,-1);headLine.Size=UDim2.new(1,-32,0,1);headLine.BackgroundColor3=Color3.fromRGB(74,37,67);headLine.BorderSizePixel=0;headLine.ZIndex=11;headLine.Parent=header

-- STICKY FOOTER ---------------------------------------------------------------
local footer=Instance.new("Frame")
footer.Name="StickyFooter";footer.AnchorPoint=Vector2.new(0,1);footer.Position=UDim2.new(0,0,1,0);footer.Size=UDim2.new(1,0,0,66);footer.BackgroundColor3=Color3.fromRGB(10,9,13);footer.BackgroundTransparency=.04;footer.BorderSizePixel=0;footer.ZIndex=10;footer.Parent=panel
local footLine=Instance.new("Frame");footLine.Position=UDim2.fromOffset(16,0);footLine.Size=UDim2.new(1,-32,0,1);footLine.BackgroundColor3=Color3.fromRGB(74,37,67);footLine.BorderSizePixel=0;footLine.ZIndex=11;footLine.Parent=footer
local send=button(footer,"SEND TO DJ WALL  •  2 R$",UDim2.fromOffset(18,12),UDim2.new(1,-36,0,42),Color3.fromRGB(102,25,73));send.TextSize=12;send.ZIndex=12;stroke(send,C.PINK,1,.25)

-- SCROLLABLE BODY -------------------------------------------------------------
local body=Instance.new("ScrollingFrame")
body.Name="ComposerBody";body.Position=UDim2.fromOffset(0,72);body.Size=UDim2.new(1,0,1,-138);body.BackgroundTransparency=1;body.BorderSizePixel=0;body.Active=true;body.ScrollingEnabled=true;body.ScrollingDirection=Enum.ScrollingDirection.Y;body.ScrollBarThickness=5;body.ScrollBarImageColor3=C.PINK;body.ScrollBarImageTransparency=.15;body.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable;body.CanvasSize=UDim2.fromOffset(0,360);body.ZIndex=2;body.Parent=panel

local content=Instance.new("Frame")
content.Name="BodyContent";content.Position=UDim2.fromOffset(0,0);content.Size=UDim2.new(1,0,0,350);content.BackgroundTransparency=1;content.ZIndex=3;content.Parent=body

local pricePill=Instance.new("Frame");pricePill.Position=UDim2.fromOffset(20,12);pricePill.Size=UDim2.fromOffset(132,32);pricePill.BackgroundColor3=Color3.fromRGB(67,47,24);pricePill.BorderSizePixel=0;pricePill.ZIndex=4;pricePill.Parent=content;round(pricePill,10);stroke(pricePill,C.GOLD,1,.45)
local priceText=label(pricePill,"2 ROBUX",UDim2.fromOffset(10,0),UDim2.new(1,-20,1,0),Enum.Font.GothamBold,11,C.GOLD,Enum.TextXAlignment.Center);priceText.ZIndex=5
local filterPill=Instance.new("Frame");filterPill.Position=UDim2.fromOffset(162,12);filterPill.Size=UDim2.fromOffset(164,32);filterPill.BackgroundColor3=Color3.fromRGB(18,43,35);filterPill.BorderSizePixel=0;filterPill.ZIndex=4;filterPill.Parent=content;round(filterPill,10);stroke(filterPill,C.GREEN,1,.5)
local filterText=label(filterPill,"✓ ROBLOX FILTER",UDim2.fromOffset(8,0),UDim2.new(1,-16,1,0),Enum.Font.GothamBold,10,C.GREEN,Enum.TextXAlignment.Center);filterText.ZIndex=5

local momentTitle=label(content,"PILIH MOMEN",UDim2.fromOffset(20,59),UDim2.new(1,-40,0,18),Enum.Font.GothamBold,10,C.MUTED);momentTitle.ZIndex=4
local catsHolder=Instance.new("Frame");catsHolder.Position=UDim2.fromOffset(20,82);catsHolder.Size=UDim2.new(1,-40,0,42);catsHolder.BackgroundTransparency=1;catsHolder.ZIndex=4;catsHolder.Parent=content
local categories={{"BIRTHDAY","BIRTHDAY"},{"LOVE","LOVE"},{"SHOUTOUT","SHOUTOUT"},{"CUSTOM","CUSTOM"}}
local category="BIRTHDAY"
local catButtons={}
for i,c in ipairs(categories) do
 local w=.25
 local b=button(catsHolder,c[2],UDim2.new((i-1)*w,0,0,0),UDim2.new(w,-6,1,0),Color3.fromRGB(31,27,35));b.TextSize=10;b.ZIndex=5
 catButtons[c[1]]=b
 b.MouseButton1Click:Connect(function()
  category=c[1]
  for k,x in pairs(catButtons) do x.BackgroundColor3=(k==category) and Color3.fromRGB(91,28,66) or Color3.fromRGB(31,27,35) end
 end)
end
catButtons.BIRTHDAY.BackgroundColor3=Color3.fromRGB(91,28,66)

local writeTitle=label(content,"TULIS PESAN",UDim2.fromOffset(20,140),UDim2.new(1,-40,0,18),Enum.Font.GothamBold,10,C.MUTED);writeTitle.ZIndex=4
local box=Instance.new("TextBox")
box.Position=UDim2.fromOffset(20,164);box.Size=UDim2.new(1,-40,0,82);box.BackgroundColor3=Color3.fromRGB(22,19,27);box.BorderSizePixel=0;box.ClearTextOnFocus=false;box.MultiLine=true;box.Text="";box.PlaceholderText="Contoh: Happy birthday Nadya! Semoga malam ini seru 🎉";box.PlaceholderColor3=Color3.fromRGB(112,106,119);box.TextColor3=C.WHITE;box.Font=Enum.Font.GothamMedium;box.TextSize=12;box.TextWrapped=true;box.TextXAlignment=Enum.TextXAlignment.Left;box.TextYAlignment=Enum.TextYAlignment.Top;box.ZIndex=4;box.Parent=content;round(box,12);stroke(box,Color3.fromRGB(62,51,67),1,.4)
local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.PaddingRight=UDim.new(0,12);pad.PaddingTop=UDim.new(0,9);pad.PaddingBottom=UDim.new(0,9);pad.Parent=box
local count=label(content,"0 / 80",UDim2.new(1,-100,0,249),UDim2.fromOffset(80,18),Enum.Font.GothamBold,9,C.MUTED,Enum.TextXAlignment.Right);count.ZIndex=4

local preview=Instance.new("Frame");preview.Position=UDim2.fromOffset(20,278);preview.Size=UDim2.new(1,-40,0,54);preview.BackgroundColor3=Color3.fromRGB(13,12,17);preview.BorderSizePixel=0;preview.ZIndex=4;preview.Parent=content;round(preview,10);stroke(preview,C.CYAN,1,.72)
local previewText=label(preview,"Pesan akan difilter otomatis sebelum tampil.",UDim2.fromOffset(12,4),UDim2.new(1,-24,1,-8),Enum.Font.GothamMedium,10,C.MUTED);previewText.ZIndex=5

local toast=Instance.new("TextLabel");toast.AnchorPoint=Vector2.new(.5,1);toast.Position=UDim2.new(.5,0,1,-18);toast.Size=UDim2.fromOffset(430,44);toast.BackgroundColor3=Color3.fromRGB(12,11,15);toast.BackgroundTransparency=.02;toast.BorderSizePixel=0;toast.TextColor3=C.WHITE;toast.Font=Enum.Font.GothamMedium;toast.TextSize=11;toast.Visible=false;toast.ZIndex=50;toast.Parent=gui;round(toast,11);stroke(toast,C.PINK,1,.5)
local function showToast(t)toast.Text=t;toast.Visible=true;task.delay(3,function()if toast.Text==t then toast.Visible=false end end)end

local config={price=2,productConfigured=false,maxChars=80,admin=false}
local busy=false
local function refreshPrice()
 priceText.Text=config.admin and "OWNER TEST" or tostring(config.price or 2).." ROBUX"
 send.Text=config.admin and "TEST ON DJ WALL  •  FREE" or "SEND TO DJ WALL  •  "..tostring(config.price or 2).." R$"
end
local function openPanel(data)
 if type(data)=="table" then config=data end
 refreshPrice()
 shade.Visible=true;panel.Visible=true;body.CanvasPosition=Vector2.new(0,0)
 local targetPos=panel.Position
 panel.Position=UDim2.new(targetPos.X.Scale,targetPos.X.Offset,targetPos.Y.Scale+.035,targetPos.Y.Offset)
 panel.BackgroundTransparency=1
 TweenService:Create(panel,TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=targetPos,BackgroundTransparency=0}):Play()
end
local function closePanel()shade.Visible=false;panel.Visible=false;box:ReleaseFocus() end
close.MouseButton1Click:Connect(closePanel)
shade.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then closePanel() end end)

box:GetPropertyChangedSignal("Text"):Connect(function()
 local max=config.maxChars or 80
 if #box.Text>max then box.Text=box.Text:sub(1,max);box.CursorPosition=#box.Text+1 end
 count.Text=string.format("%d / %d",#box.Text,max)
 count.TextColor3=(#box.Text>=max) and C.GOLD or C.MUTED
 previewText.Text=(#box.Text>0) and box.Text or "Pesan akan difilter otomatis sebelum tampil."
 previewText.TextColor3=(#box.Text>0) and C.WHITE or C.MUTED
end)

send.MouseButton1Click:Connect(function()
 if busy then return end
 if #box.Text<2 then showToast("Tulis pesan dulu.");return end
 busy=true;send.Text="CHECKING MESSAGE..."
 wallRemote:FireServer("submit",{category=category,text=box.Text})
 task.delay(1.5,function()
  busy=false
  if panel.Visible then refreshPrice() end
 end)
end)

wallRemote.OnClientEvent:Connect(function(action,data)
 if action=="open" then openPanel(data)
 elseif action=="config" and type(data)=="table" then config=data;refreshPrice()
 elseif action=="toast" then busy=false;showToast(tostring(data));if panel.Visible then refreshPrice() end
 elseif action=="purchase" then busy=false;showToast("Pesan lolos filter. Selesaikan pembelian 2 Robux.")
 elseif action=="queued" then
  busy=false
  local pos=(type(data)=="table" and data.position) or 1
  showToast("Pesan masuk antrean DJ Wall #"..tostring(pos)..".")
  box.Text="";closePanel()
 end
end)

local function responsive()
 local vp=camera.ViewportSize
 local landscape=vp.X>=vp.Y
 local w=math.clamp(vp.X-40,300,520)
 local maxH=landscape and math.max(330,vp.Y-56) or math.max(420,vp.Y-74)
 local h=math.clamp(maxH,330,460)
 panel.Size=UDim2.fromOffset(w,h)
 panel.Position=UDim2.fromScale(.5,landscape and .54 or .52)
 body.Position=UDim2.fromOffset(0,72)
 body.Size=UDim2.new(1,0,1,-138)
 body.CanvasSize=UDim2.fromOffset(0,350)

 local narrow=w<420
 if narrow then
  pricePill.Size=UDim2.new(.46,-4,0,32)
  filterPill.Position=UDim2.new(.5,4,0,12)
  filterPill.Size=UDim2.new(.46,-4,0,32)
  for i,c in ipairs(categories) do
   local b=catButtons[c[1]]
   b.TextSize=9
  end
 else
  pricePill.Size=UDim2.fromOffset(132,32)
  filterPill.Position=UDim2.fromOffset(162,12)
  filterPill.Size=UDim2.fromOffset(164,32)
 end
 toast.Size=UDim2.fromOffset(math.min(430,vp.X-28),44)
end
responsive();camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive)
wallRemote:FireServer("config")
print("[BBYA] DJ Wall prestige composer v2 online: safe-area + sticky header/footer + scroll body")