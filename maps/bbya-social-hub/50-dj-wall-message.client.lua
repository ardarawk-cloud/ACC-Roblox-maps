-- BBYA MUSIC UI TEST — DJ WALL CLIENT v3 FUNCTION-ONLY
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Owns DJ Wall content + remote flow only. UI KERNEL owns outer geometry/visibility coordination.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local wallRemote=remotes:WaitForChild("DJWall")

local old=pg:FindFirstChild("BBYADJWallUI")
if old then old:Destroy() end

local C={BG=Color3.fromRGB(10,10,14),PANEL=Color3.fromRGB(19,17,24),CARD=Color3.fromRGB(29,25,34),PINK=Color3.fromRGB(247,55,158),WHITE=Color3.fromRGB(244,243,247),MUTED=Color3.fromRGB(158,154,166),GOLD=Color3.fromRGB(215,169,96)}
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,col,tr)local s=Instance.new("UIStroke");s.Color=col;s.Thickness=1;s.Transparency=tr or .45;s.Parent=o end
local function label(parent,text,pos,size,font,ts,col)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=col or C.WHITE;l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=parent;return l
end
local function button(parent,text,pos,size,bg)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=bg or C.CARD;b.BorderSizePixel=0;b.TextColor3=C.WHITE;b.Font=Enum.Font.GothamBold;b.TextSize=9;b.AutoButtonColor=true;b.Parent=parent;corner(b,9);return b
end

local gui=Instance.new("ScreenGui")
gui.Name="BBYADJWallUI";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=35;gui.Parent=pg

local panel=Instance.new("Frame")
panel.Name="DJWallComposerPanel";panel.AnchorPoint=Vector2.new(1,0);panel.Position=UDim2.new(1,-96,0,48);panel.Size=UDim2.fromOffset(240,500)
panel.BackgroundColor3=C.BG;panel.BackgroundTransparency=.22;panel.BorderSizePixel=0;panel.Visible=false;panel.ClipsDescendants=true;panel.Parent=gui
corner(panel,14);stroke(panel,C.PINK,.35)
panel:SetAttribute("BBYAOuterLayoutOwner","UI_KERNEL")

label(panel,"DJ WALL",UDim2.fromOffset(14,10),UDim2.new(1,-56,0,28),Enum.Font.GothamBlack,14,C.WHITE)
label(panel,"Message to the big screen behind DJ",UDim2.fromOffset(14,38),UDim2.new(1,-28,0,28),Enum.Font.Gotham,9,C.MUTED)
local close=button(panel,"×",UDim2.new(1,-42,0,8),UDim2.fromOffset(32,32),C.CARD);close.TextSize=18

local categories={{"BIRTHDAY","BIRTHDAY"},{"LOVE","LOVE"},{"SHOUTOUT","SHOUTOUT"},{"CUSTOM","CUSTOM"}}
local category="BIRTHDAY"
local cats=Instance.new("Frame");cats.Position=UDim2.fromOffset(12,74);cats.Size=UDim2.new(1,-24,0,40);cats.BackgroundTransparency=1;cats.Parent=panel
local catButtons={}
for i,c in ipairs(categories) do
 local b=button(cats,c[2],UDim2.new((i-1)*.25,0,0,0),UDim2.new(.25,-3,1,0),C.CARD)
 b.TextSize=8;catButtons[c[1]]=b
 b.Activated:Connect(function()
  category=c[1]
  for k,x in pairs(catButtons) do x.BackgroundColor3=(k==category) and Color3.fromRGB(91,28,66) or C.CARD end
 end)
end
catButtons.BIRTHDAY.BackgroundColor3=Color3.fromRGB(91,28,66)

local box=Instance.new("TextBox")
box.Position=UDim2.fromOffset(12,126);box.Size=UDim2.new(1,-24,0,120);box.BackgroundColor3=C.PANEL;box.BorderSizePixel=0;box.ClearTextOnFocus=false;box.MultiLine=true;box.Text=""
box.PlaceholderText="Write your message...";box.PlaceholderColor3=Color3.fromRGB(112,106,119);box.TextColor3=C.WHITE;box.Font=Enum.Font.GothamMedium;box.TextSize=10;box.TextWrapped=true;box.TextXAlignment=Enum.TextXAlignment.Left;box.TextYAlignment=Enum.TextYAlignment.Top;box.Parent=panel
corner(box,10);stroke(box,Color3.fromRGB(62,51,67),.45)
local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,10);pad.PaddingRight=UDim.new(0,10);pad.PaddingTop=UDim.new(0,8);pad.PaddingBottom=UDim.new(0,8);pad.Parent=box

local count=label(panel,"0 / 80",UDim2.new(1,-92,0,250),UDim2.fromOffset(78,18),Enum.Font.GothamBold,8,C.MUTED);count.TextXAlignment=Enum.TextXAlignment.Right
local send=button(panel,"SEND TO DJ WALL • 2 R$",UDim2.fromOffset(12,278),UDim2.new(1,-24,0,44),Color3.fromRGB(91,28,66));send.TextSize=9;stroke(send,C.PINK,.35)
local hint=label(panel,"Roblox filter applies before display.",UDim2.fromOffset(14,330),UDim2.new(1,-28,0,34),Enum.Font.Gotham,8,C.MUTED);hint.TextYAlignment=Enum.TextYAlignment.Top

local config={price=2,maxChars=80,admin=false}
local busy=false
local function refresh()
 send.Text=config.admin and "TEST ON DJ WALL • FREE" or ("SEND TO DJ WALL • "..tostring(config.price or 2).." R$")
end
local function showToast(text)
 local oldToast=gui:FindFirstChild("DJWallToast")
 if oldToast then oldToast:Destroy() end
 local t=label(gui,tostring(text),UDim2.new(.5,-150,1,-58),UDim2.fromOffset(300,38),Enum.Font.GothamBold,9,C.WHITE);t.Name="DJWallToast";t.BackgroundColor3=C.PANEL;t.BackgroundTransparency=.08;t.BorderSizePixel=0;t.TextXAlignment=Enum.TextXAlignment.Center;t.ZIndex=50;corner(t,9);stroke(t,C.PINK,.45);task.delay(2.5,function()if t.Parent then t:Destroy() end end)
end
local function openPanel(data)
 if type(data)=="table" then config=data end
 refresh();panel.Visible=true
end
local function closePanel()panel.Visible=false;box:ReleaseFocus()end
close.Activated:Connect(closePanel)

box:GetPropertyChangedSignal("Text"):Connect(function()
 local max=tonumber(config.maxChars) or 80
 if #box.Text>max then box.Text=box.Text:sub(1,max);box.CursorPosition=#box.Text+1 end
 count.Text=string.format("%d / %d",#box.Text,max)
end)

send.Activated:Connect(function()
 if busy then return end
 if #box.Text<2 then showToast("Tulis pesan dulu.");return end
 busy=true;send.Text="CHECKING MESSAGE..."
 wallRemote:FireServer("submit",{category=category,text=box.Text})
 task.delay(1.5,function()busy=false;if panel.Visible then refresh() end end)
end)

wallRemote.OnClientEvent:Connect(function(action,data)
 if action=="open" then openPanel(data)
 elseif action=="config" and type(data)=="table" then config=data;refresh()
 elseif action=="toast" then busy=false;showToast(tostring(data));if panel.Visible then refresh() end
 elseif action=="purchase" then busy=false;showToast("Pesan lolos filter. Selesaikan pembelian 2 Robux.");refresh()
 elseif action=="queued" then
  busy=false;local pos=(type(data)=="table" and data.position) or 1;showToast("Pesan masuk antrean DJ Wall #"..tostring(pos)..".");box.Text="";closePanel()
 end
end)

wallRemote:FireServer("config")
print("[BBYA TEST] DJ Wall client v3 function-only: UI Kernel owns outer geometry")
