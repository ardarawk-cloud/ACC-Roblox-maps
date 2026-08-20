-- BBYA SOCIAL HUB — DJ WALL MESSAGE CLIENT v1
-- Mobile-first composer for filtered prestige messages shown on the giant DJ wall.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local wallRemote=remotes:WaitForChild("DJWall")

local old=pg:FindFirstChild("BBYADJWallUI")
if old then old:Destroy() end

local C={BG=Color3.fromRGB(8,8,11),PANEL=Color3.fromRGB(17,15,21),CARD=Color3.fromRGB(27,23,32),PINK=Color3.fromRGB(247,55,158),CYAN=Color3.fromRGB(32,190,215),GOLD=Color3.fromRGB(215,169,96),WHITE=Color3.fromRGB(244,243,247),MUTED=Color3.fromRGB(158,154,166),GREEN=Color3.fromRGB(62,205,124),RED=Color3.fromRGB(224,84,93)}
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,t,tr)local s=Instance.new("UIStroke");s.Color=col or C.PINK;s.Thickness=t or 1;s.Transparency=tr or .35;s.Parent=o;return s end
local function label(parent,text,pos,size,font,ts,col,align)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 13;l.TextColor3=col or C.WHITE;l.TextWrapped=true;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=parent;return l
end
local function button(parent,text,pos,size,bg)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.CARD;b.BorderSizePixel=0;b.TextColor3=C.WHITE;b.Font=Enum.Font.GothamBold;b.TextSize=12;b.AutoButtonColor=true;b.Parent=parent;round(b,10);return b
end

local gui=Instance.new("ScreenGui")
gui.Name="BBYADJWallUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=35;gui.Parent=pg

local shade=Instance.new("Frame")
shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new(0,0,0);shade.BackgroundTransparency=.45;shade.BorderSizePixel=0;shade.Visible=false;shade.Parent=gui

local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.53);panel.Size=UDim2.fromOffset(520,470);panel.BackgroundColor3=C.BG;panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=gui;round(panel,18);stroke(panel,C.PINK,1.3,.28)
local grad=Instance.new("UIGradient");grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(28,16,27)),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,9,13))});grad.Rotation=90;grad.Parent=panel

label(panel,"DJ WALL MESSAGE",UDim2.fromOffset(22,16),UDim2.new(1,-82,0,30),Enum.Font.GothamBlack,20,C.WHITE)
label(panel,"Ucapanmu tampil di layar besar belakang DJ",UDim2.fromOffset(22,47),UDim2.new(1,-82,0,22),Enum.Font.Gotham,10,C.MUTED)
local close=button(panel,"×",UDim2.new(1,-54,0,16),UDim2.fromOffset(38,36),Color3.fromRGB(34,30,39));close.TextSize=22

local pricePill=Instance.new("Frame");pricePill.Position=UDim2.fromOffset(22,82);pricePill.Size=UDim2.fromOffset(132,32);pricePill.BackgroundColor3=Color3.fromRGB(67,47,24);pricePill.BorderSizePixel=0;pricePill.Parent=panel;round(pricePill,10);stroke(pricePill,C.GOLD,1,.45)
local priceText=label(pricePill,"2 ROBUX",UDim2.fromOffset(10,0),UDim2.new(1,-20,1,0),Enum.Font.GothamBold,11,C.GOLD,Enum.TextXAlignment.Center)
local filterPill=Instance.new("Frame");filterPill.Position=UDim2.fromOffset(164,82);filterPill.Size=UDim2.fromOffset(164,32);filterPill.BackgroundColor3=Color3.fromRGB(18,43,35);filterPill.BorderSizePixel=0;filterPill.Parent=panel;round(filterPill,10);stroke(filterPill,C.GREEN,1,.5)
label(filterPill,"✓ ROBLOX FILTER",UDim2.fromOffset(8,0),UDim2.new(1,-16,1,0),Enum.Font.GothamBold,10,C.GREEN,Enum.TextXAlignment.Center)

label(panel,"PILIH MOMEN",UDim2.fromOffset(22,128),UDim2.new(1,-44,0,20),Enum.Font.GothamBold,10,C.MUTED)
local catsHolder=Instance.new("Frame");catsHolder.Position=UDim2.fromOffset(22,151);catsHolder.Size=UDim2.new(1,-44,0,42);catsHolder.BackgroundTransparency=1;catsHolder.Parent=panel
local categories={{"BIRTHDAY","BIRTHDAY"},{"LOVE","LOVE"},{"SHOUTOUT","SHOUTOUT"},{"CUSTOM","CUSTOM"}}
local category="BIRTHDAY"
local catButtons={}
for i,c in ipairs(categories) do
 local w=.25
 local b=button(catsHolder,c[2],UDim2.new((i-1)*w,0,0,0),UDim2.new(w,-6,1,0),Color3.fromRGB(31,27,35));b.TextSize=10
 catButtons[c[1]]=b
 b.MouseButton1Click:Connect(function()
  category=c[1]
  for k,x in pairs(catButtons) do x.BackgroundColor3=(k==category) and Color3.fromRGB(91,28,66) or Color3.fromRGB(31,27,35) end
 end)
end
catButtons.BIRTHDAY.BackgroundColor3=Color3.fromRGB(91,28,66)

label(panel,"TULIS PESAN",UDim2.fromOffset(22,207),UDim2.new(1,-44,0,20),Enum.Font.GothamBold,10,C.MUTED)
local box=Instance.new("TextBox")
box.Position=UDim2.fromOffset(22,232);box.Size=UDim2.new(1,-44,0,96);box.BackgroundColor3=Color3.fromRGB(22,19,27);box.BorderSizePixel=0;box.ClearTextOnFocus=false;box.MultiLine=true;box.Text="";box.PlaceholderText="Contoh: Happy birthday Nadya! Semoga malam ini seru 🎉";box.PlaceholderColor3=Color3.fromRGB(112,106,119);box.TextColor3=C.WHITE;box.Font=Enum.Font.GothamMedium;box.TextSize=13;box.TextWrapped=true;box.TextXAlignment=Enum.TextXAlignment.Left;box.TextYAlignment=Enum.TextYAlignment.Top;box.Parent=panel;round(box,12);stroke(box,Color3.fromRGB(62,51,67),1,.4)
local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.PaddingRight=UDim.new(0,12);pad.PaddingTop=UDim.new(0,10);pad.PaddingBottom=UDim.new(0,10);pad.Parent=box
local count=label(panel,"0 / 80",UDim2.new(1,-102,0,332),UDim2.fromOffset(80,20),Enum.Font.GothamBold,9,C.MUTED,Enum.TextXAlignment.Right)

local preview=Instance.new("Frame");preview.Position=UDim2.fromOffset(22,357);preview.Size=UDim2.new(1,-44,0,42);preview.BackgroundColor3=Color3.fromRGB(13,12,17);preview.BorderSizePixel=0;preview.Parent=panel;round(preview,10);stroke(preview,C.CYAN,1,.72)
local previewText=label(preview,"Pesan akan difilter otomatis sebelum tampil.",UDim2.fromOffset(12,0),UDim2.new(1,-24,1,0),Enum.Font.GothamMedium,10,C.MUTED)

local send=button(panel,"SEND TO DJ WALL  •  2 R$",UDim2.fromOffset(22,411),UDim2.new(1,-44,0,42),Color3.fromRGB(102,25,73));send.TextSize=12;stroke(send,C.PINK,1,.25)

local toast=Instance.new("TextLabel");toast.AnchorPoint=Vector2.new(.5,1);toast.Position=UDim2.new(.5,0,1,-20);toast.Size=UDim2.fromOffset(430,44);toast.BackgroundColor3=Color3.fromRGB(12,11,15);toast.BackgroundTransparency=.02;toast.BorderSizePixel=0;toast.TextColor3=C.WHITE;toast.Font=Enum.Font.GothamMedium;toast.TextSize=11;toast.Visible=false;toast.Parent=gui;round(toast,11);stroke(toast,C.PINK,1,.5)
local function showToast(t)toast.Text=t;toast.Visible=true;task.delay(3,function()if toast.Text==t then toast.Visible=false end end)end

local config={price=2,productConfigured=false,maxChars=80,admin=false}
local busy=false
local function openPanel(data)
 if type(data)=="table" then config=data end
 priceText.Text=config.admin and "OWNER TEST" or tostring(config.price or 2).." ROBUX"
 send.Text=config.admin and "TEST ON DJ WALL  •  FREE" or "SEND TO DJ WALL  •  "..tostring(config.price or 2).." R$"
 shade.Visible=true;panel.Visible=true;panel.Position=UDim2.fromScale(.5,.57);panel.BackgroundTransparency=1
 TweenService:Create(panel,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.fromScale(.5,.53),BackgroundTransparency=0}):Play()
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
  if panel.Visible then send.Text=config.admin and "TEST ON DJ WALL  •  FREE" or "SEND TO DJ WALL  •  "..tostring(config.price or 2).." R$" end
 end)
end)

wallRemote.OnClientEvent:Connect(function(action,data)
 if action=="open" then openPanel(data)
 elseif action=="config" and type(data)=="table" then config=data
 elseif action=="toast" then busy=false;showToast(tostring(data));if panel.Visible then send.Text=config.admin and "TEST ON DJ WALL  •  FREE" or "SEND TO DJ WALL  •  "..tostring(config.price or 2).." R$" end
 elseif action=="purchase" then busy=false;showToast("Pesan lolos filter. Selesaikan pembelian 2 Robux.")
 elseif action=="queued" then
  busy=false
  local pos=(type(data)=="table" and data.position) or 1
  showToast("Pesan masuk antrean DJ Wall #"..tostring(pos)..".")
  box.Text="";closePanel()
 end
end)

local function responsive()
 local vp=workspace.CurrentCamera.ViewportSize
 local w=math.clamp(vp.X-34,300,520)
 local h=math.clamp(vp.Y-84,390,470)
 panel.Size=UDim2.fromOffset(w,h)
 if h<450 then
  panel.Position=UDim2.fromScale(.5,.52)
  box.Size=UDim2.new(1,-44,0,82)
  preview.Position=UDim2.fromOffset(22,343)
  send.Position=UDim2.fromOffset(22,395)
 end
 toast.Size=UDim2.fromOffset(math.min(430,vp.X-30),44)
end
responsive();workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive)
wallRemote:FireServer("config")
print("[BBYA] DJ Wall prestige composer v1 online")
