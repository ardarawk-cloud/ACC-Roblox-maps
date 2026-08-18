-- BBYA Music Vault premium mobile panel v2.1
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local remotes=RS:WaitForChild("BBYA_Remotes")
local control=remotes:WaitForChild("MusicControl")
local stateRemote=remotes:WaitForChild("MusicState")

local gui=Instance.new("ScreenGui")
gui.Name="BBYA_MusicPanel";gui.ResetOnSpawn=false;gui.DisplayOrder=30;gui.IgnoreGuiInset=false;gui.Parent=player:WaitForChild("PlayerGui")

local BG=Color3.fromRGB(10,9,16)
local CARD=Color3.fromRGB(24,20,32)
local CARD2=Color3.fromRGB(31,25,42)
local PINK=Color3.fromRGB(255,73,205)
local CYAN=Color3.fromRGB(46,218,255)
local GOLD=Color3.fromRGB(255,205,88)
local WHITE=Color3.fromRGB(245,242,250)
local MUTED=Color3.fromRGB(166,157,178)
local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end
local function stroke(o,color,trans,thick)local s=Instance.new("UIStroke");s.Color=color or PINK;s.Transparency=trans or .55;s.Thickness=thick or 1;s.Parent=o end
local function gradient(o,a,b,rot)local g=Instance.new("UIGradient");g.Color=ColorSequence.new(a,b);g.Rotation=rot or 0;g.Parent=o return g end

-- Compact launcher fixed at the extreme TOP-RIGHT corner.
local open=Instance.new("TextButton")
open.Name="MusicButton";open.Size=UDim2.fromOffset(44,44);open.AnchorPoint=Vector2.new(1,0);open.Position=UDim2.new(1,-8,0,8)
open.BackgroundColor3=BG;open.Text="♫";open.TextSize=22;open.TextColor3=PINK;open.Font=Enum.Font.GothamBlack;open.Parent=gui;corner(open,13);stroke(open,PINK,.35,1.2)

local frame=Instance.new("Frame")
frame.Name="Panel";frame.AnchorPoint=Vector2.new(1,0);frame.Position=UDim2.new(1,-8,0,58);frame.Size=UDim2.fromOffset(348,470)
frame.BackgroundColor3=BG;frame.BackgroundTransparency=.03;frame.Visible=false;frame.ClipsDescendants=true;frame.Parent=gui;corner(frame,20);stroke(frame,PINK,.35,1.2)

local glow=Instance.new("Frame");glow.Size=UDim2.new(1,0,0,5);glow.BackgroundColor3=PINK;glow.BorderSizePixel=0;glow.Parent=frame;gradient(glow,CYAN,PINK,0)
local title=Instance.new("TextLabel");title.Size=UDim2.new(1,-96,0,28);title.Position=UDim2.fromOffset(16,14);title.BackgroundTransparency=1;title.Text="BBYA MUSIC";title.TextColor3=WHITE;title.Font=Enum.Font.GothamBlack;title.TextSize=19;title.TextXAlignment=Enum.TextXAlignment.Left;title.Parent=frame
local live=Instance.new("TextLabel");live.Size=UDim2.fromOffset(58,22);live.Position=UDim2.new(1,-92,0,16);live.BackgroundColor3=Color3.fromRGB(45,23,48);live.Text="● LIVE";live.TextColor3=PINK;live.Font=Enum.Font.GothamBold;live.TextSize=10;live.Parent=frame;corner(live,8)
local close=Instance.new("TextButton");close.Size=UDim2.fromOffset(30,30);close.Position=UDim2.new(1,-38,0,12);close.Text="×";close.TextSize=22;close.TextColor3=WHITE;close.BackgroundColor3=CARD;close.Parent=frame;corner(close,9)

local hero=Instance.new("Frame");hero.Size=UDim2.new(1,-24,0,118);hero.Position=UDim2.fromOffset(12,54);hero.BackgroundColor3=CARD;hero.Parent=frame;corner(hero,16);stroke(hero,CYAN,.65,1)
local art=Instance.new("Frame");art.Size=UDim2.fromOffset(82,82);art.Position=UDim2.fromOffset(12,12);art.BackgroundColor3=Color3.fromRGB(38,26,48);art.Parent=hero;corner(art,14);gradient(art,PINK,CYAN,35)
local note=Instance.new("TextLabel");note.Size=UDim2.fromScale(1,1);note.BackgroundTransparency=1;note.Text="♫";note.TextColor3=WHITE;note.Font=Enum.Font.GothamBlack;note.TextSize=36;note.Parent=art
local nowSmall=Instance.new("TextLabel");nowSmall.Size=UDim2.new(1,-118,0,18);nowSmall.Position=UDim2.fromOffset(106,10);nowSmall.BackgroundTransparency=1;nowSmall.Text="NOW PLAYING";nowSmall.TextColor3=CYAN;nowSmall.Font=Enum.Font.GothamBold;nowSmall.TextSize=10;nowSmall.TextXAlignment=Enum.TextXAlignment.Left;nowSmall.Parent=hero
local nowTitle=Instance.new("TextLabel");nowTitle.Size=UDim2.new(1,-118,0,46);nowTitle.Position=UDim2.fromOffset(106,28);nowTitle.BackgroundTransparency=1;nowTitle.Text="Starting Auto-DJ...";nowTitle.TextColor3=WHITE;nowTitle.TextWrapped=true;nowTitle.Font=Enum.Font.GothamBlack;nowTitle.TextSize=15;nowTitle.TextXAlignment=Enum.TextXAlignment.Left;nowTitle.TextYAlignment=Enum.TextYAlignment.Top;nowTitle.Parent=hero
local meta=Instance.new("TextLabel");meta.Size=UDim2.new(1,-118,0,18);meta.Position=UDim2.fromOffset(106,76);meta.BackgroundTransparency=1;meta.Text="AUTO-DJ • ALL";meta.TextColor3=MUTED;meta.Font=Enum.Font.Gotham;meta.TextSize=10;meta.TextXAlignment=Enum.TextXAlignment.Left;meta.Parent=hero
local waveform=Instance.new("Frame");waveform.Size=UDim2.new(1,-118,0,16);waveform.Position=UDim2.fromOffset(106,96);waveform.BackgroundTransparency=1;waveform.Parent=hero
local bars={}
for i=1,18 do local b=Instance.new("Frame");b.AnchorPoint=Vector2.new(0,.5);b.Size=UDim2.fromOffset(5,math.random(4,14));b.Position=UDim2.new(0,(i-1)*7,.5,0);b.BorderSizePixel=0;b.BackgroundColor3=i%2==0 and CYAN or PINK;b.Parent=waveform;corner(b,2);bars[i]=b end
task.spawn(function()while gui.Parent do if frame.Visible then for _,b in ipairs(bars)do TweenService:Create(b,TweenInfo.new(.22),{Size=UDim2.fromOffset(5,math.random(4,15))}):Play()end end;task.wait(.24)end end)

local controls=Instance.new("Frame");controls.Size=UDim2.new(1,-24,0,50);controls.Position=UDim2.fromOffset(12,184);controls.BackgroundTransparency=1;controls.Parent=frame
local cl=Instance.new("UIListLayout");cl.FillDirection=Enum.FillDirection.Horizontal;cl.HorizontalAlignment=Enum.HorizontalAlignment.Center;cl.VerticalAlignment=Enum.VerticalAlignment.Center;cl.Padding=UDim.new(0,8);cl.Parent=controls
local function ctl(txt,cb,w,accent)local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(w or 48,44);b.BackgroundColor3=accent and Color3.fromRGB(55,26,62) or CARD;b.Text=txt;b.TextColor3=accent and PINK or WHITE;b.Font=Enum.Font.GothamBlack;b.TextSize=accent and 18 or 13;b.Parent=controls;corner(b,13);stroke(b,accent and PINK or Color3.fromRGB(88,76,102),accent and .45 or .75,1);b.Activated:Connect(cb);return b end
local localVolume=.65
ctl("−",function()localVolume=math.max(0,localVolume-.1);control:FireServer("VOLUME",localVolume)end,44)
ctl("▶",function()control:FireServer("PLAY")end,56,true)
ctl("Ⅱ",function()control:FireServer("PAUSE")end,48)
ctl("≫",function()control:FireServer("NEXT")end,48)
ctl("+",function()localVolume=math.min(1,localVolume+.1);control:FireServer("VOLUME",localVolume)end,44)
local vol=Instance.new("TextLabel");vol.Size=UDim2.new(1,-24,0,18);vol.Position=UDim2.fromOffset(12,234);vol.BackgroundTransparency=1;vol.Text="VOLUME 65%";vol.TextColor3=MUTED;vol.Font=Enum.Font.GothamBold;vol.TextSize=10;vol.TextXAlignment=Enum.TextXAlignment.Center;vol.Parent=frame
local floorLabel=Instance.new("TextLabel");floorLabel.Size=UDim2.new(1,-24,0,20);floorLabel.Position=UDim2.fromOffset(12,258);floorLabel.BackgroundTransparency=1;floorLabel.Text="SELECT FLOOR";floorLabel.TextColor3=MUTED;floorLabel.Font=Enum.Font.GothamBold;floorLabel.TextSize=10;floorLabel.TextXAlignment=Enum.TextXAlignment.Left;floorLabel.Parent=frame
local tabs=Instance.new("Frame");tabs.Size=UDim2.new(1,-24,0,40);tabs.Position=UDim2.fromOffset(12,280);tabs.BackgroundTransparency=1;tabs.Parent=frame
local tl=Instance.new("UIListLayout");tl.FillDirection=Enum.FillDirection.Horizontal;tl.Padding=UDim.new(0,6);tl.Parent=tabs
local activeTab=nil
local function tab(txt,mode,w)local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(w,36);b.BackgroundColor3=CARD;b.Text=txt;b.TextColor3=WHITE;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.Parent=tabs;corner(b,10);b.Activated:Connect(function()control:FireServer("MODE",mode);if activeTab then activeTab.BackgroundColor3=CARD;activeTab.TextColor3=WHITE end;b.BackgroundColor3=Color3.fromRGB(56,26,64);b.TextColor3=PINK;activeTab=b end);return b end
activeTab=tab("ALL","ALL",72);activeTab.BackgroundColor3=Color3.fromRGB(56,26,64);activeTab.TextColor3=PINK
tab("INDONESIA","INDONESIA",108);tab("INTERNATIONAL","INTERNATIONAL",126)
local genreLabel=Instance.new("TextLabel");genreLabel.Size=UDim2.new(1,-24,0,20);genreLabel.Position=UDim2.fromOffset(12,326);genreLabel.BackgroundTransparency=1;genreLabel.Text="GENRE";genreLabel.TextColor3=MUTED;genreLabel.Font=Enum.Font.GothamBold;genreLabel.TextSize=10;genreLabel.TextXAlignment=Enum.TextXAlignment.Left;genreLabel.Parent=frame
local scroll=Instance.new("ScrollingFrame");scroll.Size=UDim2.new(1,-24,1,-358);scroll.Position=UDim2.fromOffset(12,348);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=2;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=frame
local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.fromOffset(150,38);grid.CellPadding=UDim2.fromOffset(8,8);grid.Parent=scroll
local subs={"INDO_BOUNCE","STADIUM","BREAKBEAT","FUNKOT","KOPLO","HOUSE","BASS_HOUSE","EDM","TECHNO","PSYTRANCE","DNB","DISCO"}
for _,sub in ipairs(subs)do local b=Instance.new("TextButton");b.BackgroundColor3=CARD2;b.Text=sub:gsub("_"," ");b.TextColor3=WHITE;b.Font=Enum.Font.GothamBold;b.TextSize=10;b.TextWrapped=true;b.Parent=scroll;corner(b,10);stroke(b,Color3.fromRGB(85,72,98),.8,1);b.Activated:Connect(function()control:FireServer("SUBGENRE",sub)end)end
stateRemote.OnClientEvent:Connect(function(s)if typeof(s)~="table" then return end;nowTitle.Text=tostring(s.title or "BBYA 24/7");local bits={};if s.sub and s.sub~="" then table.insert(bits,s.sub:gsub("_"," ")) end;if s.status and s.status~="" then table.insert(bits,s.status) end;if s.error and s.error~="" then table.insert(bits,s.error) end;table.insert(bits,s.mode or "ALL");meta.Text=table.concat(bits," • ");meta.TextColor3=s.error and s.error~="" and Color3.fromRGB(255,125,125) or MUTED;if typeof(s.volume)=="number" then localVolume=s.volume;vol.Text="VOLUME "..math.floor(localVolume*100).."%" end;live.Text=s.playing and "● LIVE" or "● PAUSED";live.TextColor3=s.playing and PINK or GOLD end)
open.Activated:Connect(function()frame.Visible=not frame.Visible end)
close.Activated:Connect(function()frame.Visible=false end)
print("[BBYA] Premium Music Panel v2.1 extreme top-right loaded")