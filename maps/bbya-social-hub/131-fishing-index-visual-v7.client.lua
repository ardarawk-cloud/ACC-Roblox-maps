-- BBYA MUSIC UI TEST — DANCE NATIVE SCROLL AUTHORITY v7
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- 92-freecam.client.lua owns the 212 catalog and every dance button/click callback.
-- v7 deliberately DOES NOT reparent dance buttons. Keeping rows inside the source
-- ScrollingFrame preserves their original Activated connections and makes touch input reliable.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local boundList
local boundRoot
local syncing=false

local function isDanceRow(o)
 return o:IsA("TextButton") and string.sub(o.Name or "",1,6)=="Dance_"
end

local function cleanupLegacyHosts(root)
 for _,name in ipairs({"DanceDirectPageHostV4","DanceDirectScrollHostV5","DanceDirectScrollHostV6","DanceDirectScrollHostV7"}) do
  local old=root:FindFirstChild(name)
  if old then old:Destroy() end
 end
end

local function syncRows(resetScroll)
 if syncing or not boundList or not boundList.Parent then return end
 syncing=true
 boundList.Visible=true
 boundList.Active=true
 boundList.ScrollingEnabled=true
 boundList.ScrollingDirection=Enum.ScrollingDirection.Y
 boundList.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable
 boundList.ScrollBarThickness=4
 boundList.ScrollBarImageColor3=Color3.fromRGB(244,48,149)
 boundList.AutomaticCanvasSize=Enum.AutomaticSize.None
 boundList.ClipsDescendants=true
 boundList.ZIndex=80

 local layout=boundList:FindFirstChildWhichIsA("UIListLayout")
 local count=0
 for _,b in ipairs(boundList:GetChildren()) do
  if isDanceRow(b) then
   count+=1
   b.Visible=true
   b.Active=true
   b.Selectable=true
   b.AutoButtonColor=true
   b.ZIndex=88
   b.Size=UDim2.new(1,-6,0,38)
   b.TextWrapped=false
   b.TextTruncate=Enum.TextTruncate.AtEnd
   b.TextSize=9
   b.BackgroundTransparency=.14
  end
 end

 local contentH=0
 if layout then contentH=layout.AbsoluteContentSize.Y+8 end
 boundList.CanvasSize=UDim2.fromOffset(0,math.max(contentH,boundList.AbsoluteSize.Y+2))
 if resetScroll then boundList.CanvasPosition=Vector2.new(0,0) end
 if boundRoot then
  boundRoot:SetAttribute("BBYADanceNativeScrollAuthority","V7")
  boundRoot:SetAttribute("BBYADanceVisibleRows",count)
  boundRoot:SetAttribute("BBYADanceBrowseMode","SCROLL")
 end
 syncing=false
end

local scheduled=false
local resetWanted=false
local function schedule(resetScroll)
 resetWanted=resetWanted or resetScroll==true
 if scheduled then return end
 scheduled=true
 task.delay(.06,function()
  scheduled=false
  local r=resetWanted
  resetWanted=false
  syncRows(r)
 end)
end

local function bind(root,list)
 if boundList==list and boundRoot==root then schedule(false);return end
 boundRoot=root
 boundList=list
 cleanupLegacyHosts(root)
 list.Visible=true
 list.ChildAdded:Connect(function(child)
  if isDanceRow(child) then schedule(false) end
 end)
 list:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()schedule(false)end)
 local layout=list:FindFirstChildWhichIsA("UIListLayout")
 if layout then layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()schedule(false)end) end
 schedule(true)
 print("[BBYA TEST] Dance native scroll v7 bound: source buttons remain clickable")
end

local function findUI()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("DancePanel")
 local root=panel and panel:FindFirstChild("BBYADanceCatalogV1")
 local list=root and root:FindFirstChild("DanceCatalogScroll")
 if root and list and list:IsA("ScrollingFrame") then bind(root,list);return true end
 return false
end

task.spawn(function()
 for _=1,180 do
  if findUI() then break end
  task.wait(.18)
 end
end)

pg.DescendantAdded:Connect(function(d)
 if d.Name=="DanceCatalogScroll" or isDanceRow(d) then task.defer(findUI) end
end)
