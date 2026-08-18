-- BBYA SOCIAL HUB — QUEEN PLAYTEST HEALTH HUD v1.0
-- Owner-only compact diagnostics for live playtest. Hidden from normal guests.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local QUEEN_USER_ID = 4271188557
if player.UserId ~= QUEEN_USER_ID then return end

local gui = Instance.new("ScreenGui")
gui.Name = "BBYA_QueenHealthHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 60
gui.Parent = player:WaitForChild("PlayerGui")

local BG = Color3.fromRGB(9,8,15)
local CARD = Color3.fromRGB(24,20,31)
local PINK = Color3.fromRGB(255,65,195)
local CYAN = Color3.fromRGB(55,220,255)
local GOLD = Color3.fromRGB(255,205,82)
local GREEN = Color3.fromRGB(92,230,148)
local RED = Color3.fromRGB(255,105,120)
local WHITE = Color3.fromRGB(245,242,250)
local MUTED = Color3.fromRGB(166,158,178)

local function corner(o,r)
 local c=Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,r or 10)
 c.Parent=o
end

local function stroke(o,color,trans)
 local s=Instance.new("UIStroke")
 s.Color=color or PINK
 s.Transparency=trans or .45
 s.Thickness=1
 s.Parent=o
end

local button=Instance.new("TextButton")
button.Name="HealthButton"
button.AnchorPoint=Vector2.new(.5,0)
button.Position=UDim2.new(.5,0,0,8)
button.Size=UDim2.fromOffset(96,30)
button.BackgroundColor3=BG
button.Text="QC • ..."
button.TextColor3=GOLD
button.Font=Enum.Font.GothamBlack
button.TextSize=11
button.Parent=gui
corner(button,10)
stroke(button,GOLD,.45)

local panel=Instance.new("Frame")
panel.Name="HealthPanel"
panel.AnchorPoint=Vector2.new(.5,0)
panel.Position=UDim2.new(.5,0,0,44)
panel.Size=UDim2.fromOffset(286,190)
panel.BackgroundColor3=BG
panel.BackgroundTransparency=.03
panel.Visible=false
panel.Parent=gui
corner(panel,14)
stroke(panel,PINK,.5)

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-24,0,28)
title.Position=UDim2.fromOffset(12,10)
title.BackgroundTransparency=1
title.Text="BBYA PLAYTEST HEALTH"
title.TextColor3=WHITE
title.Font=Enum.Font.GothamBlack
title.TextSize=14
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=panel

local body=Instance.new("TextLabel")
body.Size=UDim2.new(1,-24,1,-52)
body.Position=UDim2.fromOffset(12,42)
body.BackgroundColor3=CARD
body.BackgroundTransparency=.12
body.Text="Loading..."
body.TextColor3=WHITE
body.Font=Enum.Font.Code
body.TextSize=11
body.TextXAlignment=Enum.TextXAlignment.Left
body.TextYAlignment=Enum.TextYAlignment.Top
body.TextWrapped=false
body.Parent=panel
corner(body,10)

local pad=Instance.new("UIPadding")
pad.PaddingLeft=UDim.new(0,10)
pad.PaddingRight=UDim.new(0,10)
pad.PaddingTop=UDim.new(0,8)
pad.PaddingBottom=UDim.new(0,8)
pad.Parent=body

local function yn(v) return v and "YES" or "NO" end

local function refresh()
 local validation=tostring(Workspace:GetAttribute("BBYABuildValidation") or "WAIT")
 local version=tostring(Workspace:GetAttribute("BBYABuildVersion") or "?")
 local missing=tonumber(Workspace:GetAttribute("BBYABuildMissingCount") or -1)
 local profile=tostring(Workspace:GetAttribute("BBYAClientPerformanceProfile") or "?")
 local crowd=tonumber(Workspace:GetAttribute("BBYARealCrowdCount") or 0)
 local intensity=tonumber(Workspace:GetAttribute("BBYACrowdIntensity") or 0)
 local party=Workspace:GetAttribute("BBYAPartyMode")==true
 local monetization=Workspace:GetAttribute("BBYAMonetizationConfigured")==true
 local remotes=ReplicatedStorage:FindFirstChild("BBYA_Remotes")
 local musicOK=remotes and remotes:FindFirstChild("MusicControl") and remotes:FindFirstChild("MusicState")

 local good=validation=="PASS" and missing==0 and remotes~=nil
 button.Text=string.format("QC • %s",validation)
 button.TextColor3=good and GREEN or (validation=="WAIT" and GOLD or RED)

 body.Text=table.concat({
  string.format("BUILD       %s",version),
  string.format("VALIDATION  %s",validation),
  string.format("MISSING     %s",missing>=0 and tostring(missing) or "?"),
  string.format("PROFILE     %s",profile),
  string.format("CROWD       %d  / intensity %d",crowd,intensity),
  string.format("PARTY MODE  %s",yn(party)),
  string.format("REMOTES     %s",yn(remotes~=nil)),
  string.format("MUSIC BUS   %s",yn(musicOK~=nil)),
  string.format("MONETIZE    %s",monetization and "READY" or "PENDING"),
 },"\n")
end

button.Activated:Connect(function()
 panel.Visible=not panel.Visible
 if panel.Visible then refresh() end
end)

task.spawn(function()
 while gui.Parent do
  refresh()
  task.wait(1.5)
 end
end)

print("[BBYA] Queen Playtest Health HUD v1.0 loaded")
