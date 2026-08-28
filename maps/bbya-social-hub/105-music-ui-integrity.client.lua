-- BBYA MUSIC SUITE v1 — MOBILE LAYOUT GUARD v3
-- Visual-only hotfix for the premium Music Suite on short mobile-landscape viewports.
-- Keeps the existing music server/remotes untouched.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local gui=pg:WaitForChild("BBYAMusicSuiteV1",30)
if not gui then return end

local function find(name)
 return gui:FindFirstChild(name,true)
end

local brand=find("Brand")
local side=brand and brand.Parent
local venueText=find("Venue")
local venueCard=venueText and venueText.Parent
local navLib=find("NavLIBRARY")
local navNow=find("NavNOW")
local navQueue=find("NavQUEUE")
local nav=navLib and navLib.Parent
local navLayout=nav and nav:FindFirstChildWhichIsA("UIListLayout")
local statusValue=find("SV")
local status=statusValue and statusValue.Parent

local nowPage=find("NOW")
local nowTitle=find("Track")
local nowInfo=nowTitle and nowTitle.Parent
local nowCard=nowInfo and nowInfo.Parent
local nowMeta=nowInfo and nowInfo:FindFirstChild("Meta")
local nowState=nowInfo and nowInfo:FindFirstChild("State")
local mute=find("Mute")
local prev=find("Prev")
local nextB=find("Next")
local controls=mute and mute.Parent
local elapsed=find("Elapsed")
local duration=find("Duration")
local art=nowCard and nowCard:FindFirstChildWhichIsA("Frame")

local function getUpList()
 if not nowPage then return nil end
 for _,d in ipairs(nowPage:GetDescendants()) do
  if d:IsA("ScrollingFrame") then return d end
 end
 return nil
end
local upList=getUpList()
local up=upList and upList.Parent

local wave
if nowInfo then
 for _,d in ipairs(nowInfo:GetChildren()) do
  if d:IsA("Frame") then wave=d break end
 end
end

local function setButtonCompact(b,order)
 if not b then return end
 b.Size=UDim2.new(1,0,0,34)
 b.TextSize=8
 b.LayoutOrder=order
end

local applying=false
local function apply()
 if applying then return end
 applying=true
 local cam=workspace.CurrentCamera
 local vp=cam and cam.ViewportSize or Vector2.new(1280,720)
 local compact=vp.X<900 or vp.Y<520

 if compact then
  if side then side.Size=UDim2.new(0,150,1,0) end
  if brand then brand.Position=UDim2.fromOffset(14,10);brand.Size=UDim2.new(1,-28,0,24);brand.TextSize=17 end
  local sub=side and side:FindFirstChild("Sub")
  if sub then sub.Position=UDim2.fromOffset(14,32);sub.Size=UDim2.new(1,-28,0,13);sub.TextSize=6 end

  if venueCard then
   venueCard.Position=UDim2.fromOffset(11,52)
   venueCard.Size=UDim2.new(1,-22,0,44)
  end
  if venueText then venueText.Position=UDim2.fromOffset(10,4);venueText.Size=UDim2.new(1,-20,0,18);venueText.TextSize=8 end
  local hint=venueCard and venueCard:FindFirstChild("Hint")
  if hint then hint.Position=UDim2.fromOffset(10,22);hint.Size=UDim2.new(1,-20,0,14);hint.TextSize=5 end

  if nav then
   nav.Position=UDim2.fromOffset(11,106)
   nav.Size=UDim2.new(1,-22,0,110)
  end
  if navLayout then navLayout.Padding=UDim.new(0,4) end
  setButtonCompact(navLib,1)
  setButtonCompact(navNow,2)
  setButtonCompact(navQueue,3)

  -- Status is redundant on a short phone viewport and was covering QUEUE.
  if status then status.Visible=false end

  if art then art.Visible=false end
  if nowInfo then
   nowInfo.Position=UDim2.fromOffset(18,12)
   nowInfo.Size=UDim2.new(1,-36,0,104)
  end
  if nowState then nowState.Position=UDim2.fromOffset(0,0);nowState.Size=UDim2.new(1,0,0,16);nowState.TextSize=7 end
  if nowTitle then
   nowTitle.Position=UDim2.fromOffset(0,18)
   nowTitle.Size=UDim2.new(1,0,0,45)
   nowTitle.TextSize=12
  end
  if nowMeta then
   nowMeta.Position=UDim2.fromOffset(0,66)
   nowMeta.Size=UDim2.new(1,0,0,15)
   nowMeta.TextSize=6
  end
  if wave then wave.Visible=false end

  if elapsed then elapsed.Position=UDim2.new(0,18,1,-70);elapsed.Size=UDim2.new(.25,0,0,14);elapsed.TextSize=6 end
  if duration then duration.Position=UDim2.new(.75,-18,1,-70);duration.Size=UDim2.new(.25,0,0,14);duration.TextSize=6 end
  if controls then controls.Position=UDim2.new(0,18,1,-50);controls.Size=UDim2.new(1,-36,0,34) end
  if mute then mute.LayoutOrder=1;mute.TextSize=8 end
  if prev then prev.LayoutOrder=2;prev.TextSize=8 end
  if nextB then nextB.LayoutOrder=3;nextB.TextSize=8 end

  if up then
   local title=up:FindFirstChild("Title")
   if title then title.TextSize=9;title.Position=UDim2.fromOffset(12,7);title.Size=UDim2.new(1,-24,0,20) end
  end
  if upList then upList.Position=UDim2.fromOffset(10,31);upList.Size=UDim2.new(1,-20,1,-40) end
 else
  if status then status.Visible=true end
  if wave then wave.Visible=true end
  if mute then mute.LayoutOrder=1 end
  if prev then prev.LayoutOrder=2 end
  if nextB then nextB.LayoutOrder=3 end
 end

 applying=false
end

local cam=workspace.CurrentCamera
local function bindCamera()
 cam=workspace.CurrentCamera
 if cam then
  cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
   task.defer(apply)
   task.delay(.05,apply)
  end)
 end
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()bindCamera();task.defer(apply);task.delay(.05,apply)end)
bindCamera()

gui:GetPropertyChangedSignal("Enabled"):Connect(function()
 if gui.Enabled then
  task.defer(apply)
  task.delay(.05,apply)
  task.delay(.2,apply)
 end
end)

task.defer(apply)
task.delay(.15,apply)
task.delay(.6,apply)
print("[BBYA] Music Suite mobile layout guard v3 active — sidebar overlap removed")
