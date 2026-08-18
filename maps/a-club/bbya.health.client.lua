-- BBYA SOCIAL HUB — QUEEN PLAYTEST HEALTH HUD v1.1
-- Owner-only diagnostics + non-destructive system smoke test. Hidden from normal guests.

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
button.Size=UDim2.fromOffset(104,30)
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
panel.Size=UDim2.fromOffset(330,410)
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

local liveBody=Instance.new("TextLabel")
liveBody.Size=UDim2.new(1,-24,0,142)
liveBody.Position=UDim2.fromOffset(12,42)
liveBody.BackgroundColor3=CARD
liveBody.BackgroundTransparency=.12
liveBody.Text="Loading..."
liveBody.TextColor3=WHITE
liveBody.Font=Enum.Font.Code
liveBody.TextSize=10
liveBody.TextXAlignment=Enum.TextXAlignment.Left
liveBody.TextYAlignment=Enum.TextYAlignment.Top
liveBody.TextWrapped=false
liveBody.Parent=panel
corner(liveBody,10)
local livePad=Instance.new("UIPadding")
livePad.PaddingLeft=UDim.new(0,10);livePad.PaddingRight=UDim.new(0,10);livePad.PaddingTop=UDim.new(0,8);livePad.PaddingBottom=UDim.new(0,8);livePad.Parent=liveBody

local run=Instance.new("TextButton")
run.Name="RunSystemTest"
run.Size=UDim2.new(1,-24,0,36)
run.Position=UDim2.fromOffset(12,194)
run.BackgroundColor3=Color3.fromRGB(48,25,58)
run.Text="RUN SYSTEM TEST"
run.TextColor3=CYAN
run.Font=Enum.Font.GothamBlack
run.TextSize=12
run.Parent=panel
corner(run,10)
stroke(run,CYAN,.45)

local resultTitle=Instance.new("TextLabel")
resultTitle.Size=UDim2.new(1,-24,0,22)
resultTitle.Position=UDim2.fromOffset(12,238)
resultTitle.BackgroundTransparency=1
resultTitle.Text="TEST RESULT • NOT RUN"
resultTitle.TextColor3=MUTED
resultTitle.Font=Enum.Font.GothamBold
resultTitle.TextSize=10
resultTitle.TextXAlignment=Enum.TextXAlignment.Left
resultTitle.Parent=panel

local scroll=Instance.new("ScrollingFrame")
scroll.Name="TestResults"
scroll.Size=UDim2.new(1,-24,0,132)
scroll.Position=UDim2.fromOffset(12,266)
scroll.BackgroundColor3=CARD
scroll.BackgroundTransparency=.12
scroll.BorderSizePixel=0
scroll.ScrollBarThickness=3
scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
scroll.CanvasSize=UDim2.new()
scroll.Parent=panel
corner(scroll,10)
local list=Instance.new("UIListLayout")
list.Padding=UDim.new(0,3)
list.SortOrder=Enum.SortOrder.LayoutOrder
list.Parent=scroll
local spad=Instance.new("UIPadding")
spad.PaddingLeft=UDim.new(0,8);spad.PaddingRight=UDim.new(0,8);spad.PaddingTop=UDim.new(0,7);spad.PaddingBottom=UDim.new(0,7);spad.Parent=scroll

local function yn(v) return v and "YES" or "NO" end
local function clearResults()
 for _,c in ipairs(scroll:GetChildren()) do
  if c:IsA("TextLabel") then c:Destroy() end
 end
end
local function addResult(order,text,color)
 local l=Instance.new("TextLabel")
 l.LayoutOrder=order
 l.Size=UDim2.new(1,-4,0,17)
 l.BackgroundTransparency=1
 l.Text=text
 l.TextColor3=color or WHITE
 l.Font=Enum.Font.Code
 l.TextSize=9
 l.TextXAlignment=Enum.TextXAlignment.Left
 l.TextTruncate=Enum.TextTruncate.AtEnd
 l.Parent=scroll
end

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
 local lastTest=tostring(Workspace:GetAttribute("BBYALastPlaytestStatus") or "NOT RUN")

 local good=validation=="PASS" and missing==0 and remotes~=nil
 button.Text=string.format("QC • %s",validation)
 button.TextColor3=good and GREEN or (validation=="WAIT" and GOLD or RED)

 liveBody.Text=table.concat({
  string.format("BUILD       %s",version),
  string.format("VALIDATION  %s",validation),
  string.format("MISSING     %s",missing>=0 and tostring(missing) or "?"),
  string.format("PROFILE     %s",profile),
  string.format("CROWD       %d / intensity %d",crowd,intensity),
  string.format("PARTY MODE  %s",yn(party)),
  string.format("REMOTES     %s",yn(remotes~=nil)),
  string.format("MUSIC BUS   %s",yn(musicOK~=nil)),
  string.format("MONETIZE    %s",monetization and "READY" or "PENDING"),
  string.format("LAST TEST   %s",lastTest),
 },"\n")
end

local running=false
run.Activated:Connect(function()
 if running then return end
 running=true
 run.Text="TESTING..."
 run.TextColor3=GOLD
 clearResults()
 resultTitle.Text="TEST RESULT • RUNNING"
 resultTitle.TextColor3=GOLD

 local remotes=ReplicatedStorage:FindFirstChild("BBYA_Remotes")
 local rf=remotes and remotes:FindFirstChild("RunPlaytestCheck")
 if not rf or not rf:IsA("RemoteFunction") then
  resultTitle.Text="TEST RESULT • FAIL"
  resultTitle.TextColor3=RED
  addResult(1,"FAIL  RunPlaytestCheck remote missing",RED)
  run.Text="RUN SYSTEM TEST";run.TextColor3=CYAN;running=false
  return
 end

 local ok,data=pcall(function() return rf:InvokeServer() end)
 if not ok or typeof(data)~="table" then
  resultTitle.Text="TEST RESULT • ERROR"
  resultTitle.TextColor3=RED
  addResult(1,"ERROR server test did not return data",RED)
 else
  resultTitle.Text="TEST RESULT • "..tostring(data.summary or "DONE")
  resultTitle.TextColor3=data.ok and GREEN or RED
  for i,row in ipairs(data.rows or {}) do
   local prefix=row.ok and "PASS" or "FAIL"
   local detail=row.detail~="" and (" • "..row.detail) or ""
   addResult(i,string.format("%s  %s%s",prefix,tostring(row.label or "?"),detail),row.ok and GREEN or RED)
  end
 end
 run.Text="RUN SYSTEM TEST"
 run.TextColor3=CYAN
 running=false
 refresh()
end)

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

print("[BBYA] Queen Playtest Health HUD v1.1 loaded • system test enabled")
