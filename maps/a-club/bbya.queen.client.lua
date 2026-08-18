-- BBYA Queen mobile control panel v1.1
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local QUEEN_ID=4271188557
local player=Players.LocalPlayer
if player.UserId~=QUEEN_ID then return end
local remotes=ReplicatedStorage:WaitForChild("BBYA_Remotes")
local Admin=remotes:WaitForChild("QueenAdmin")
local Notice=remotes:WaitForChild("Notice")

local gui=Instance.new("ScreenGui");gui.Name="BBYA_QUEEN_UI";gui.ResetOnSpawn=false;gui.DisplayOrder=40;gui.IgnoreGuiInset=false;gui.Parent=player:WaitForChild("PlayerGui")
local open=Instance.new("TextButton");open.Size=UDim2.fromOffset(44,44);open.AnchorPoint=Vector2.new(1,0);open.Position=UDim2.new(1,-112,0,8);open.Text="Q";open.Font=Enum.Font.GothamBlack;open.TextSize=15;open.TextColor3=Color3.fromRGB(255,225,110);open.BackgroundColor3=Color3.fromRGB(55,22,68);open.Parent=gui;Instance.new("UICorner",open).CornerRadius=UDim.new(0,13)
local frame=Instance.new("Frame");frame.AnchorPoint=Vector2.new(1,0);frame.Position=UDim2.new(1,-8,0,58);frame.Size=UDim2.fromOffset(220,285);frame.BackgroundColor3=Color3.fromRGB(16,12,23);frame.BackgroundTransparency=.04;frame.Visible=false;frame.Parent=gui;Instance.new("UICorner",frame).CornerRadius=UDim.new(0,10)
local title=Instance.new("TextLabel");title.Size=UDim2.new(1,-38,0,32);title.Position=UDim2.fromOffset(8,4);title.BackgroundTransparency=1;title.Text="👑 BBYA QUEEN";title.TextColor3=Color3.fromRGB(255,220,90);title.Font=Enum.Font.GothamBlack;title.TextSize=16;title.TextXAlignment=Enum.TextXAlignment.Left;title.Parent=frame
local close=Instance.new("TextButton");close.Size=UDim2.fromOffset(28,28);close.Position=UDim2.new(1,-33,0,5);close.Text="×";close.TextSize=22;close.Font=Enum.Font.GothamBold;close.TextColor3=Color3.new(1,1,1);close.BackgroundColor3=Color3.fromRGB(60,35,72);close.Parent=frame;Instance.new("UICorner",close).CornerRadius=UDim.new(0,6)
local scroll=Instance.new("ScrollingFrame");scroll.Size=UDim2.new(1,-12,1,-44);scroll.Position=UDim2.fromOffset(6,38);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=3;scroll.CanvasSize=UDim2.new();scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.Parent=frame
local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,6);list.HorizontalAlignment=Enum.HorizontalAlignment.Center;list.Parent=scroll
local function btn(text,cb)local b=Instance.new("TextButton");b.Size=UDim2.new(1,-8,0,34);b.Text=text;b.Font=Enum.Font.GothamBold;b.TextSize=13;b.TextColor3=Color3.new(1,1,1);b.BackgroundColor3=Color3.fromRGB(48,30,62);b.Parent=scroll;Instance.new("UICorner",b).CornerRadius=UDim.new(0,7);b.MouseButton1Click:Connect(cb);return b end
local notice=Instance.new("TextLabel");notice.Size=UDim2.new(.7,0,0,34);notice.AnchorPoint=Vector2.new(.5,0);notice.Position=UDim2.new(.5,0,0,12);notice.BackgroundColor3=Color3.fromRGB(30,18,40);notice.BackgroundTransparency=.1;notice.TextColor3=Color3.fromRGB(255,230,140);notice.Font=Enum.Font.GothamBold;notice.TextSize=16;notice.TextWrapped=true;notice.Visible=false;notice.Parent=gui;Instance.new("UICorner",notice).CornerRadius=UDim.new(0,8)
local box=Instance.new("TextBox");box.Size=UDim2.new(1,-8,0,38);box.PlaceholderText="Announcement...";box.Text="";box.ClearTextOnFocus=false;box.Font=Enum.Font.Gotham;box.TextSize=13;box.TextColor3=Color3.new(1,1,1);box.PlaceholderColor3=Color3.fromRGB(160,145,175);box.BackgroundColor3=Color3.fromRGB(32,23,43);box.Parent=scroll;Instance.new("UICorner",box).CornerRadius=UDim.new(0,7)
btn("ANNOUNCE",function()if box.Text~=""then Admin:FireServer("announce",box.Text);box.Text=""end end)
btn("PARTY MODE",function()Admin:FireServer("party")end)
btn("NORMAL MODE",function()Admin:FireServer("normal")end)
btn("GO DJ",function()remotes.Teleport:FireServer("DJ")end)
btn("GO POOL",function()remotes.Teleport:FireServer("POOL")end)
btn("SPEED 32",function()Admin:FireServer("speed",32)end)
btn("SPEED NORMAL",function()Admin:FireServer("speednormal")end)
btn("CONFETTI",function()remotes.FX:FireServer("confetti")end)
open.MouseButton1Click:Connect(function()frame.Visible=not frame.Visible end);close.MouseButton1Click:Connect(function()frame.Visible=false end)
Notice.OnClientEvent:Connect(function(text)notice.Text=tostring(text);notice.Visible=true;task.delay(4,function()if notice.Text==tostring(text)then notice.Visible=false end end)end)
local cam=workspace.CurrentCamera
local function layout()local v=cam.ViewportSize;frame.Size=UDim2.fromOffset(220,math.min(285,v.Y-70));open.Position=UDim2.new(1,-112,0,8);frame.Position=UDim2.new(1,-8,0,58)end
layout();cam:GetPropertyChangedSignal("ViewportSize"):Connect(layout)
print("[BBYA] Queen mobile control panel v1.1 unified top-right loaded")