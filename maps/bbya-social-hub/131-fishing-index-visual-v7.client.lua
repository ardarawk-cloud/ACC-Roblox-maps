-- BBYA MUSIC UI TEST — DANCE DIRECT SCROLL HOST v5
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Temporary host: FishingVisualIndex client slot is repurposed only on this isolated test branch.
-- The source 212 catalog/filter remains owned by 92-freecam.client.lua.
-- This patch MOVES generated dance buttons out of the source ScrollingFrame into a dedicated
-- manually-laid-out ScrollingFrame so mobile users can browse the whole catalog by swipe/scroll.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local boundRoot
local boundList
local boundStatus
local host
local rows={}
local busy=false
local generation=0

local function corner(o,r)
 local c=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,r or 8)
 c.Parent=o
end

local function isDanceRow(obj)
 return obj:IsA("TextButton") and string.sub(obj.Name or "",1,6)=="Dance_"
end

local function destroyOldRows()
 for _,b in ipairs(rows) do
  if b and b.Parent then b:Destroy() end
 end
 table.clear(rows)
end

local function ensureHost(root)
 if host and host.Parent==root then return end
 local old=root:FindFirstChild("DanceDirectPageHostV4")
 if old then old:Destroy() end
 local oldScroll=root:FindFirstChild("DanceDirectScrollHostV5")
 if oldScroll then oldScroll:Destroy() end

 host=Instance.new("ScrollingFrame")
 host.Name="DanceDirectScrollHostV5"
 host.BackgroundTransparency=1
 host.BorderSizePixel=0
 host.Position=UDim2.fromOffset(0,100)
 host.Size=UDim2.new(1,0,1,-108)
 host.ClipsDescendants=true
 host.ScrollBarThickness=4
 host.ScrollBarImageColor3=Color3.fromRGB(244,48,149)
 host.ScrollingDirection=Enum.ScrollingDirection.Y
 host.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable
 host.CanvasSize=UDim2.new()
 host.AutomaticCanvasSize=Enum.AutomaticSize.None
 host.Active=true
 host.ZIndex=80
 host.Parent=root
end

local function layoutRows()
 if not host then return end
 local width=host.AbsoluteSize.X
 local cols=width>=360 and 2 or 1
 local gap=8
 local rowH=40
 local pitch=rowH+gap
 local count=#rows
 local totalRows=math.ceil(count/cols)

 for i,b in ipairs(rows) do
  if b and b.Parent==host then
   local slot=i-1
   local col=slot%cols
   local row=math.floor(slot/cols)
   b.Visible=true
   b.Active=true
   b.AnchorPoint=Vector2.new(0,0)
   if cols==1 then
    b.Position=UDim2.fromOffset(0,row*pitch)
    b.Size=UDim2.new(1,-6,0,rowH)
   else
    b.Position=UDim2.new(col*.5,col==0 and 0 or 4,0,row*pitch)
    b.Size=UDim2.new(.5,-4,0,rowH)
   end
   b.ZIndex=88
   b.TextTransparency=0
   b.BackgroundTransparency=.10
  end
 end

 host.CanvasSize=UDim2.fromOffset(0,math.max(0,totalRows*pitch-gap+6))
 if boundRoot then
  boundRoot:SetAttribute("BBYADanceDirectScrollHost","V5")
  boundRoot:SetAttribute("BBYADanceVisibleRows",count)
  boundRoot:SetAttribute("BBYADanceBrowseMode","SCROLL")
 end
end

local function harvest(resetScroll)
 if busy or not boundList or not boundList.Parent or not boundRoot then return end
 busy=true
 ensureHost(boundRoot)

 destroyOldRows()

 local fresh={}
 for _,child in ipairs(boundList:GetChildren()) do
  if isDanceRow(child) then table.insert(fresh,child) end
 end
 table.sort(fresh,function(a,b)
  local ao=a.LayoutOrder or 0
  local bo=b.LayoutOrder or 0
  if ao==bo then return a.Name<b.Name end
  return ao<bo
 end)

 for _,b in ipairs(fresh) do
  b.Parent=host
  b.Visible=false
  table.insert(rows,b)
 end

 -- Source list stays alive because 92-freecam owns rendering/filtering,
 -- but the visible browsing surface is the dedicated scroll host above.
 boundList.Visible=false
 if resetScroll and host then host.CanvasPosition=Vector2.new(0,0) end
 layoutRows()
 busy=false
end

local function scheduleHarvest(resetScroll)
 generation+=1
 local token=generation
 task.delay(.08,function()
  if token~=generation then return end
  harvest(resetScroll)
 end)
 task.delay(.22,function()
  if token~=generation then return end
  local found=false
  if boundList then
   for _,c in ipairs(boundList:GetChildren()) do if isDanceRow(c) then found=true;break end end
  end
  if found then harvest(resetScroll) else layoutRows() end
 end)
end

local function bind(root,list,status)
 if boundList==list and boundRoot==root then return end
 boundRoot=root
 boundList=list
 boundStatus=status
 ensureHost(root)

 list.ChildAdded:Connect(function(child)
  if isDanceRow(child) then scheduleHarvest(true) end
 end)

 if status then
  status:GetPropertyChangedSignal("Text"):Connect(function()
   -- Category/search render has finished when status count changes.
   scheduleHarvest(true)
  end)
 end

 host:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutRows)
 scheduleHarvest(true)
 print("[BBYA TEST] Dance direct scroll host v5 bound")
end

local function findUI()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("DancePanel")
 local root=panel and panel:FindFirstChild("BBYADanceCatalogV1")
 if not root then return false end
 local list=root:FindFirstChild("DanceCatalogScroll")
 local status=root:FindFirstChild("DanceStatus")
 if list and list:IsA("ScrollingFrame") then
  bind(root,list,status)
  return true
 end
 return false
end

task.spawn(function()
 for _=1,160 do
  if findUI() then break end
  task.wait(.20)
 end
end)

pg.ChildAdded:Connect(function()
 task.delay(.1,findUI)
end)
