-- BBYA MUSIC UI TEST — DANCE DIRECT PAGE HOST v4
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Temporary host: FishingVisualIndex client slot is repurposed only on this isolated test branch.
-- The source 212 catalog/filter remains owned by 92-freecam.client.lua.
-- This patch MOVES generated dance buttons out of ScrollingFrame into a plain Frame,
-- preserving their original Activated handlers while avoiding mobile canvas/layout failures.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local PAGE_SIZE=8
local boundRoot
local boundList
local boundStatus
local host
local prevBtn
local nextBtn
local pageLabel
local page=1
local rows={}
local busy=false
local generation=0

local function corner(o,r)
 local c=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,r or 8)
 c.Parent=o
end

local function stroke(o,color,transparency)
 local s=o:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
 s.Color=color or Color3.fromRGB(244,48,149)
 s.Thickness=1
 s.Transparency=transparency or .55
 s.Parent=o
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

 host=Instance.new("Frame")
 host.Name="DanceDirectPageHostV4"
 host.BackgroundTransparency=1
 host.Position=UDim2.fromOffset(0,100)
 host.Size=UDim2.new(1,0,1,-142)
 host.ClipsDescendants=true
 host.ZIndex=80
 host.Parent=root

 prevBtn=Instance.new("TextButton")
 prevBtn.Name="PagePrev"
 prevBtn.Text="‹ PREV"
 prevBtn.Position=UDim2.new(0,0,1,-36)
 prevBtn.Size=UDim2.fromOffset(78,32)
 prevBtn.BackgroundColor3=Color3.fromRGB(39,34,45)
 prevBtn.BorderSizePixel=0
 prevBtn.TextColor3=Color3.fromRGB(246,244,248)
 prevBtn.Font=Enum.Font.GothamSemibold
 prevBtn.TextSize=9
 prevBtn.ZIndex=90
 prevBtn.Parent=root
 corner(prevBtn,8);stroke(prevBtn,Color3.fromRGB(244,48,149),.62)

 nextBtn=prevBtn:Clone()
 nextBtn.Name="PageNext"
 nextBtn.Text="NEXT ›"
 nextBtn.Position=UDim2.new(1,-78,1,-36)
 nextBtn.Parent=root

 pageLabel=Instance.new("TextLabel")
 pageLabel.Name="DancePageLabel"
 pageLabel.BackgroundTransparency=1
 pageLabel.Position=UDim2.new(0,84,1,-36)
 pageLabel.Size=UDim2.new(1,-168,0,32)
 pageLabel.Text="PAGE 1 / 1"
 pageLabel.TextColor3=Color3.fromRGB(166,160,172)
 pageLabel.Font=Enum.Font.GothamMedium
 pageLabel.TextSize=9
 pageLabel.TextXAlignment=Enum.TextXAlignment.Center
 pageLabel.ZIndex=90
 pageLabel.Parent=root

 prevBtn.Activated:Connect(function()
  page=math.max(1,page-1)
  generation+=1
  task.defer(function() if host then host:SetAttribute("RefreshToken",generation) end end)
 end)
 nextBtn.Activated:Connect(function()
  local maxPage=math.max(1,math.ceil(#rows/PAGE_SIZE))
  page=math.min(maxPage,page+1)
  generation+=1
  task.defer(function() if host then host:SetAttribute("RefreshToken",generation) end end)
 end)
end

local function layoutRows()
 if not host then return end
 local maxPage=math.max(1,math.ceil(#rows/PAGE_SIZE))
 page=math.clamp(page,1,maxPage)
 local first=(page-1)*PAGE_SIZE+1
 local last=math.min(#rows,first+PAGE_SIZE-1)

 for i,b in ipairs(rows) do
  if b and b.Parent==host then
   local visible=i>=first and i<=last
   b.Visible=visible
   if visible then
    local slot=i-first
    local col=slot%2
    local row=math.floor(slot/2)
    b.AnchorPoint=Vector2.new(0,0)
    b.Position=UDim2.new(col*.5,col==0 and 0 or 4,0,row*48)
    b.Size=UDim2.new(.5,-4,0,40)
    b.ZIndex=88
    b.TextTransparency=0
    b.BackgroundTransparency=.10
    b.Active=true
   end
  end
 end

 if pageLabel then pageLabel.Text=string.format("PAGE %d / %d  •  %d ITEMS",page,maxPage,#rows) end
 if prevBtn then prevBtn.Visible=#rows>0;prevBtn.Active=page>1;prevBtn.TextTransparency=page>1 and 0 or .6 end
 if nextBtn then nextBtn.Visible=#rows>0;nextBtn.Active=page<maxPage;nextBtn.TextTransparency=page<maxPage and 0 or .6 end
 if boundRoot then
  boundRoot:SetAttribute("BBYADanceDirectPageHost","V4")
  boundRoot:SetAttribute("BBYADanceVisibleRows",#rows)
  boundRoot:SetAttribute("BBYADancePage",page)
 end
end

local function harvest(resetPage)
 if busy or not boundList or not boundList.Parent or not boundRoot then return end
 busy=true
 ensureHost(boundRoot)

 -- Remove previously harvested generation. New source rows are currently in boundList.
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

 -- Source ScrollingFrame stays alive for the original renderer, but never displays rows.
 boundList.Visible=false
 if resetPage then page=1 end
 layoutRows()
 busy=false
end

local function scheduleHarvest(resetPage)
 generation+=1
 local token=generation
 task.delay(.08,function()
  if token~=generation then return end
  harvest(resetPage)
 end)
 task.delay(.22,function()
  if token~=generation then return end
  -- Second pass catches rows created one frame later on slower mobile clients.
  local found=false
  if boundList then
   for _,c in ipairs(boundList:GetChildren()) do if isDanceRow(c) then found=true;break end end
  end
  if found then harvest(resetPage) else layoutRows() end
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

 host:GetAttributeChangedSignal("RefreshToken"):Connect(layoutRows)
 scheduleHarvest(true)
 print("[BBYA TEST] Dance direct page host v4 bound")
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