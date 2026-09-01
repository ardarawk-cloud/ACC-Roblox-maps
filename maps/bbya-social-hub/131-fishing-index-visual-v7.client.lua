-- BBYA MUSIC UI TEST — DANCE ROW RENDER HOTFIX v3
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Temporary host: FishingVisualIndex client slot is repurposed only on this isolated test branch.
-- Reason: the 212 catalog data/filter counts are correct, but UIListLayout loses the rows on mobile.
-- This patch removes that fragile layout and positions the existing catalog buttons manually.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local applying=false
local boundFrame=nil
local childAddedConn=nil
local childRemovedConn=nil
local scheduled=0

local function isDanceRow(obj)
 if not obj:IsA("TextButton") then return false end
 local n=obj.Name or ""
 return string.sub(n,1,6)=="Dance_" or string.sub(n,1,9)=="DanceRow_"
end

local function applyGrid(frame,resetScroll)
 if applying or not frame or not frame.Parent then return end
 applying=true

 -- Kill the UIListLayout that is producing the blank-list behavior on mobile.
 for _,child in ipairs(frame:GetChildren()) do
  if child:IsA("UIListLayout") or child:IsA("UIGridLayout") then
   child:Destroy()
  end
 end

 local rows={}
 for _,child in ipairs(frame:GetChildren()) do
  if isDanceRow(child) then table.insert(rows,child) end
 end
 table.sort(rows,function(a,b)
  local ao=a.LayoutOrder or 0
  local bo=b.LayoutOrder or 0
  if ao==bo then return a.Name<b.Name end
  return ao<bo
 end)

 local gapX=8
 local gapY=7
 local cellH=40
 for index,b in ipairs(rows) do
  local zero=index-1
  local col=zero%2
  local row=math.floor(zero/2)
  b.AnchorPoint=Vector2.new(0,0)
  b.Position=UDim2.new(col*.5,col==0 and 0 or gapX/2,0,row*(cellH+gapY))
  b.Size=UDim2.new(.5,-(gapX/2),0,cellH)
  b.Visible=true
  b.Active=true
  b.TextTransparency=0
  b.BackgroundTransparency=math.min(b.BackgroundTransparency,.14)
  b.ZIndex=70
 end

 local rowCount=math.ceil(#rows/2)
 local canvasH=math.max(1,rowCount*(cellH+gapY)+8)
 frame.AutomaticCanvasSize=Enum.AutomaticSize.None
 frame.ScrollingDirection=Enum.ScrollingDirection.Y
 frame.ScrollBarThickness=4
 frame.CanvasSize=UDim2.fromOffset(0,canvasH)
 frame.Visible=true
 frame.Active=true
 frame.ZIndex=68
 if resetScroll then frame.CanvasPosition=Vector2.new(0,0) end

 local root=frame.Parent
 if root then
  root.Visible=true
  root.ZIndex=60
 end

 local panel=root and root.Parent
 if panel then
  panel:SetAttribute("BBYADanceRenderHotfix","MANUAL_GRID_V3")
  panel:SetAttribute("BBYADanceVisibleRows",#rows)
 end
 applying=false
end

local function schedule(frame,resetScroll)
 scheduled+=1
 local token=scheduled
 task.defer(function()
  task.wait(.03)
  if token~=scheduled then return end
  applyGrid(frame,resetScroll)
  task.wait(.08)
  if token~=scheduled then return end
  applyGrid(frame,false)
 end)
end

local function bind(frame)
 if boundFrame==frame then return end
 if childAddedConn then childAddedConn:Disconnect() end
 if childRemovedConn then childRemovedConn:Disconnect() end
 boundFrame=frame
 childAddedConn=frame.ChildAdded:Connect(function(child)
  if isDanceRow(child) or child:IsA("UIListLayout") or child:IsA("UIGridLayout") then
   schedule(frame,true)
  end
 end)
 childRemovedConn=frame.ChildRemoved:Connect(function(child)
  if isDanceRow(child) then schedule(frame,true) end
 end)
 schedule(frame,true)
end

local function findAndBind()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("DancePanel")
 if not panel then return end
 local root=panel:FindFirstChild("BBYADanceCatalogV1") or panel:FindFirstChild("BBYADanceCatalogV2")
 if not root then return end
 local frame=root:FindFirstChild("DanceCatalogScroll")
 if frame and frame:IsA("ScrollingFrame") then bind(frame) end
end

pg.ChildAdded:Connect(function()task.defer(findAndBind)end)

task.spawn(function()
 for _=1,120 do
  findAndBind()
  if boundFrame then break end
  task.wait(.25)
 end
 if boundFrame then
  print("[BBYA TEST] Dance row render hotfix v3 active")
 else
  warn("[BBYA TEST] Dance row render hotfix v3: catalog frame not found")
 end
end)
