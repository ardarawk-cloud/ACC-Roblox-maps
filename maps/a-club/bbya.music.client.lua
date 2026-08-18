-- BBYA Music Vault mobile panel v1.1
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=RS:WaitForChild("BBYA_Remotes")
local control=remotes:WaitForChild("MusicControl")
local stateRemote=remotes:WaitForChild("MusicState")

local gui=Instance.new("ScreenGui")
gui.Name="BBYA_MusicPanel"
gui.ResetOnSpawn=false
gui.DisplayOrder=30
gui.IgnoreGuiInset=false
gui.Parent=player:WaitForChild("PlayerGui")

local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,trans)local s=Instance.new("UIStroke");s.Transparency=trans or .65;s.Thickness=1;s.Parent=o end
local BG=Color3.fromRGB(13,12,19)
local CARD=Color3.fromRGB(31,25,39)
local PINK=Color3.fromRGB(255,82,205)
local CYAN=Color3.fromRGB(56,216,255)

-- Compact launcher at the TOP-RIGHT, below Roblox CoreGui.
local open=Instance.new("TextButton")
open.Name="MusicButton";open.Size=UDim2.fromOffset(48,48);open.AnchorPoint=Vector2.new(1,0);open.Position=UDim2.new(1,-18,0,58)
open.BackgroundColor3=BG;open.Text="♫";open.TextSize=24;open.TextColor3=PINK;open.Font=Enum.Font.GothamBlack;open.Parent=gui;corner(open,14);stroke(open,.5)

local frame=Instance.new("Frame")
frame.Name="Panel";frame.AnchorPoint=Vector2.new(1,0);frame.Position=UDim2.new(1,-16,0,114);frame.Size=UDim2.fromOffset(330,390)
frame.BackgroundColor3=BG;frame.BackgroundTransparency=.04;frame.Visible=false;frame.Parent=gui;corner(frame,16);stroke(frame,.45)

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-50,0,34);title.Position=UDim2.fromOffset(14,8);title.BackgroundTransparency=1;title.Text="BBYA MUSIC VAULT";title.TextColor3=PINK;title.Font=Enum.Font.GothamBlack;title.TextSize=18;title.TextXAlignment=Enum.TextXAlignment.Left;title.Parent=frame
local close=Instance.new("TextButton");close.Size=UDim2.fromOffset(30,30);close.Position=UDim2.new(1,-38,0,7);close.Text="×";close.TextSize=22;close.TextColor3=Color3.new(1,1,1);close.BackgroundColor3=CARD;close.Parent=frame;corner(close,8)

local now=Instance.new("Frame");now.Size=UDim2.new(1,-24,0,82);now.Position=UDim2.fromOffset(12,48);now.BackgroundColor3=CARD;now.Parent=frame;corner(now,12)
local nowTitle=Instance.new("TextLabel");nowTitle.Size=UDim2.new(1,-18,0,44);nowTitle.Position=UDim2.fromOffset(9,7);nowTitle.BackgroundTransparency=1;nowTitle.Text="NOW PLAYING\nStarting Auto-DJ...";nowTitle.TextColor3=Color3.new(1,1,1);nowTitle.TextWrapped=true;nowTitle.Font=Enum.Font.GothamBold;nowTitle.TextSize=13;nowTitle.TextXAlignment=Enum.TextXAlignment.Left;nowTitle.TextYAlignment=Enum.TextYAlignment.Top;nowTitle.Parent=now
local meta=Instance.new("TextLabel");meta.Size=UDim2.new(1,-18,0,22);meta.Position=UDim2.fromOffset(9,55);meta.BackgroundTransparency=1;meta.Text="AUTO-DJ • ALL";meta.TextColor3=CYAN;meta.Font=Enum.Font.Gotham;meta.TextSize=11;meta.TextXAlignment=Enum.TextXAlignment.Left;meta.Parent=now

local controls=Instance.new("Frame");controls.Size=UDim2.new(1,-24,0,42);controls.Position=UDim2.fromOffset(12,140);controls.BackgroundTransparency=1;controls.Parent=frame
local list=Instance.new("UIListLayout");list.FillDirection=Enum.FillDirection.Horizontal;list.Padding=UDim.new(0,6);list.Parent=controls
local function ctl(txt,cb,w)local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(w or 68,38);b.BackgroundColor3=CARD;b.Text=txt;b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextSize=12;b.Parent=controls;corner(b,9);b.Activated:Connect(cb);return b end
ctl("PLAY",function()control:FireServer("PLAY")end,62)
ctl("PAUSE",function()control:FireServer("PAUSE")end,62)
ctl("NEXT",function()control:FireServer("NEXT")end,62)
local localVolume=.65
ctl("VOL -",function()localVolume=math.max(0,localVolume-.1);control:FireServer("VOLUME",localVolume)end,58)
ctl("VOL +",function()localVolume=math.min(1,localVolume+.1);control:FireServer("VOLUME",localVolume)end,58)

local tabs=Instance.new("Frame");tabs.Size=UDim2.new(1,-24,0,38);tabs.Position=UDim2.fromOffset(12,192);tabs.BackgroundTransparency=1;tabs.Parent=frame
local tl=Instance.new("UIListLayout");tl.FillDirection=Enum.FillDirection.Horizontal;tl.Padding=UDim.new(0,6);tl.Parent=tabs
local function tab(txt,mode)local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(94,34);b.BackgroundColor3=CARD;b.Text=txt;b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextSize=11;b.Parent=tabs;corner(b,9);b.Activated:Connect(function()control:FireServer("MODE",mode)end)end
tab("ALL","ALL");tab("INDONESIA","INDONESIA");tab("INTERNATIONAL","INTERNATIONAL")

local scroll=Instance.new("ScrollingFrame");scroll.Size=UDim2.new(1,-24,1,-244);scroll.Position=UDim2.fromOffset(12,236);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=3;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=frame
local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.fromOffset(142,38);grid.CellPadding=UDim2.fromOffset(7,7);grid.Parent=scroll
local subs={"INDO_BOUNCE","STADIUM","BREAKBEAT","FUNKOT","KOPLO","HOUSE","BASS_HOUSE","EDM","TECHNO","PSYTRANCE","DNB","DISCO"}
for _,sub in ipairs(subs)do local b=Instance.new("TextButton");b.BackgroundColor3=CARD;b.Text=sub:gsub("_"," ");b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextSize=10;b.TextWrapped=true;b.Parent=scroll;corner(b,9);b.Activated:Connect(function()control:FireServer("SUBGENRE",sub)end)end

stateRemote.OnClientEvent:Connect(function(s)
 if typeof(s)~="table" then return end
 nowTitle.Text="NOW PLAYING\n"..tostring(s.title or "BBYA 24/7")
 local bits={}
 if s.sub and s.sub~="" then table.insert(bits,s.sub:gsub("_"," ")) end
 if s.status and s.status~="" then table.insert(bits,s.status) end
 if s.error and s.error~="" then table.insert(bits,s.error) end
 table.insert(bits,s.mode or "ALL")
 meta.Text=table.concat(bits," • ")
 meta.TextColor3=s.error and s.error~="" and Color3.fromRGB(255,130,130) or CYAN
 if typeof(s.volume)=="number" then localVolume=s.volume end
end)

open.Activated:Connect(function()frame.Visible=not frame.Visible end)
close.Activated:Connect(function()frame.Visible=false end)
print("[BBYA] Music Vault mobile panel v1.1 top launcher loaded")