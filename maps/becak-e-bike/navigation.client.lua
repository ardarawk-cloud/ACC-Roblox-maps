-- BECAK E-BIKE — Driver navigation v1.8
-- Compact mobile-safe guidance for passenger, cargo, garage and active destinations.
-- v1.8 prevents repeated delayed retarget callbacks near destinations.

local Players=game:GetService('Players')
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local Workspace=game:GetService('Workspace')
local RunService=game:GetService('RunService')

local player=Players.LocalPlayer
local pg=player:WaitForChild('PlayerGui')
local remotes=ReplicatedStorage:WaitForChild('BecakEBikeRemotes',20)
if not remotes then return end
local stateEvent=remotes:WaitForChild('State',10)
if not stateEvent then return end

local destinationPositions={
 ['Pasar Nusantara']=Vector3.new(-310,2,300),
 ['Sekolah Nusakarya']=Vector3.new(-300,2,-80),
 ['Rumah Sakit']=Vector3.new(100,2,250),
 ['Nusakarya Mall']=Vector3.new(170,2,80),
 ['Terminal Raya']=Vector3.new(390,2,60),
 ['Pantai Bahari']=Vector3.new(260,2,-350),
 ['Hotel Bahari']=Vector3.new(340,2,-220),
 ['Kawasan Industri']=Vector3.new(310,2,390),
}

local gui=Instance.new('ScreenGui')
gui.Name='BecakDriverNavigation'
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=false
gui.DisplayOrder=24
gui.Parent=pg

local pill=Instance.new('Frame')
pill.Name='GuidancePill'
pill.AnchorPoint=Vector2.new(.5,0)
pill.Position=UDim2.new(.5,0,0,66)
pill.Size=UDim2.fromOffset(310,50)
pill.BackgroundColor3=Color3.fromRGB(12,18,21)
pill.BackgroundTransparency=.08
pill.Visible=false
pill.Parent=gui
local pc=Instance.new('UICorner');pc.CornerRadius=UDim.new(0,16);pc.Parent=pill
local ps=Instance.new('UIStroke');ps.Color=Color3.fromRGB(47,170,93);ps.Transparency=.25;ps.Thickness=1;ps.Parent=pill

local arrow=Instance.new('TextLabel')
arrow.BackgroundTransparency=1
arrow.Position=UDim2.fromOffset(10,4)
arrow.Size=UDim2.fromOffset(42,42)
arrow.Text='↑'
arrow.TextColor3=Color3.fromRGB(105,238,145)
arrow.Font=Enum.Font.GothamBold
arrow.TextSize=30
arrow.Parent=pill

local title=Instance.new('TextLabel')
title.BackgroundTransparency=1
title.Position=UDim2.fromOffset(54,6)
title.Size=UDim2.new(1,-64,0,20)
title.Text='Navigasi'
title.TextColor3=Color3.fromRGB(245,247,248)
title.Font=Enum.Font.GothamBold
title.TextSize=13
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=pill

local detail=Instance.new('TextLabel')
detail.BackgroundTransparency=1
detail.Position=UDim2.fromOffset(54,27)
detail.Size=UDim2.new(1,-64,0,16)
detail.Text=''
detail.TextColor3=Color3.fromRGB(170,184,190)
detail.Font=Enum.Font.Gotham
detail.TextSize=11
detail.TextXAlignment=Enum.TextXAlignment.Left
detail.Parent=pill

local marker=Instance.new('Part')
marker.Name='BecakLocalWaypoint'
marker.Anchored=true
marker.CanCollide=false
marker.CanQuery=false
marker.CanTouch=false
marker.Transparency=1
marker.Size=Vector3.new(1,1,1)
marker.Parent=Workspace

local markerGui=Instance.new('BillboardGui')
markerGui.Name='WaypointBillboard'
markerGui.Size=UDim2.fromOffset(120,34)
markerGui.StudsOffset=Vector3.new(0,5,0)
markerGui.AlwaysOnTop=false
markerGui.MaxDistance=220
markerGui.Enabled=false
markerGui.Parent=marker
local markerText=Instance.new('TextLabel')
markerText.Size=UDim2.fromScale(1,1)
markerText.BackgroundColor3=Color3.fromRGB(20,126,65)
markerText.BackgroundTransparency=.12
markerText.TextColor3=Color3.new(1,1,1)
markerText.Font=Enum.Font.GothamBold
markerText.TextSize=11
markerText.TextWrapped=true
markerText.Parent=markerGui
local mc=Instance.new('UICorner');mc.CornerRadius=UDim.new(0,10);mc.Parent=markerText

local mode='idle'
local activeTripName=nil
local currentTargetPos=nil
local currentTargetName=nil
local nextRetargetAt=0
local RETARGET_COOLDOWN=.85

local function rootPart()
 local c=player.Character
 return c and c:FindFirstChild('HumanoidRootPart')
end

local function ownVehiclePosition()
 local root=Workspace:FindFirstChild('BecakEBike')
 local vehicles=root and root:FindFirstChild('Vehicles')
 if vehicles then
  for _,m in ipairs(vehicles:GetChildren()) do
   if m:IsA('Model') and m:GetAttribute('OwnerUserId')==player.UserId and m.PrimaryPart then
    return m.PrimaryPart.Position,m.PrimaryPart.CFrame
   end
  end
 end
 local rp=rootPart()
 return rp and rp.Position or nil,rp and rp.CFrame or nil
end

local function nearestPassenger()
 local root=Workspace:FindFirstChild('BecakEBike')
 local folder=root and root:FindFirstChild('Passengers')
 local origin=ownVehiclePosition()
 if not folder or not origin then return nil end
 local best,bestDist
 for _,p in ipairs(folder:GetChildren()) do
  if p:IsA('BasePart') and p.Transparency<.99 then
   local prompt=p:FindFirstChildOfClass('ProximityPrompt')
   if not prompt or prompt.Enabled then
    local d=(p.Position-origin).Magnitude
    if not bestDist or d<bestDist then best,bestDist=p,d end
   end
  end
 end
 return best,bestDist
end

local function landmark(name)
 local root=Workspace:FindFirstChild('BecakEBike')
 if not root then return nil end
 if name=='cargo' then
  local systems=root:FindFirstChild('MasterplanSystems')
  local jobs=systems and systems:FindFirstChild('CargoJobs')
  return jobs and jobs:FindFirstChild('CargoDepot')
 elseif name=='garage' then
  local ints=root:FindFirstChild('Interactives')
  return ints and (ints:FindFirstChild('Garage') or ints:FindFirstChild('RepairShop'))
 end
end

local function setTarget(pos,name,newMode)
 currentTargetPos=pos
 currentTargetName=name
 if newMode then mode=newMode end
 markerGui.Enabled=pos~=nil
 pill.Visible=pos~=nil
 if pos then
  marker.Position=pos+Vector3.new(0,1,0)
  markerText.Text=name or 'TUJUAN'
 end
end

local function chooseTarget()
 if activeTripName and destinationPositions[activeTripName] then
  setTarget(destinationPositions[activeTripName],activeTripName,'trip')
  return
 end
 local cargoName=player:GetAttribute('CargoDestination')
 if cargoName and destinationPositions[cargoName] then
  setTarget(destinationPositions[cargoName],cargoName,'cargo-active')
  return
 end
 if mode=='passenger' then
  local p=nearestPassenger()
  if p then setTarget(p.Position,'Penumpang terdekat','passenger') else setTarget(nil,nil) end
 elseif mode=='cargo' then
  local p=landmark('cargo');if p then setTarget(p.Position,'Cargo Depot','cargo') else setTarget(nil,nil) end
 elseif mode=='garage' then
  local p=landmark('garage');if p then setTarget(p.Position,'Garasi / Bengkel','garage') else setTarget(nil,nil) end
 else
  setTarget(nil,nil)
 end
end

local function retargetThrottled()
 local now=os.clock()
 if now<nextRetargetAt then return end
 nextRetargetAt=now+RETARGET_COOLDOWN
 chooseTarget()
end

local function hookPhone()
 local phoneGui=pg:WaitForChild('BecakDriverPhone',20)
 if not phoneGui then return end
 local function inspect(obj)
  if not obj:IsA('TextButton') then return end
  local txt=string.upper(obj.Text or '')
  if string.find(txt,'CARI PENUMPANG',1,true) then
   obj.MouseButton1Click:Connect(function() mode='passenger';chooseTarget() end)
  elseif string.find(txt,'ANTAR PAKET',1,true) or string.find(txt,'CARGO',1,true) then
   obj.MouseButton1Click:Connect(function() mode='cargo';chooseTarget() end)
  elseif string.find(txt,'GARASI',1,true) then
   obj.MouseButton1Click:Connect(function() mode='garage';chooseTarget() end)
  end
 end
 for _,o in ipairs(phoneGui:GetDescendants()) do inspect(o) end
 phoneGui.DescendantAdded:Connect(inspect)
end
task.spawn(hookPhone)

stateEvent.OnClientEvent:Connect(function(s)
 activeTripName=s and s.trip or nil
 chooseTarget()
end)
player:GetAttributeChangedSignal('CargoDestination'):Connect(chooseTarget)

local acc=0
RunService.RenderStepped:Connect(function(dt)
 acc+=dt
 if acc<.12 then return end
 acc=0
 if not currentTargetPos then
  if mode~='idle' then retargetThrottled() end
  return
 end
 local pos,cf=ownVehiclePosition()
 if not pos or not cf then return end
 local flat=Vector3.new(currentTargetPos.X-pos.X,0,currentTargetPos.Z-pos.Z)
 local dist=flat.Magnitude
 if dist<3 then arrow.Text='✓' else
  local localDir=cf:VectorToObjectSpace(flat.Unit)
  local angle=math.atan2(localDir.X,-localDir.Z)
  if math.abs(angle)<.45 then arrow.Text='↑'
  elseif angle>0 and angle<2.5 then arrow.Text='→'
  elseif angle<0 and angle>-2.5 then arrow.Text='←'
  else arrow.Text='↓' end
 end
 title.Text=currentTargetName or 'Tujuan'
 detail.Text=string.format('%d m • %s',math.floor(dist+.5),mode=='passenger' and 'jemput' or (string.find(mode,'cargo',1,true) and 'cargo' or (mode=='trip' and 'antar penumpang' or 'navigasi')))

 if mode=='passenger' and dist<12 and not activeTripName then
  retargetThrottled()
 elseif (mode=='trip' or mode=='cargo-active') and dist<22 then
  retargetThrottled()
 end
end)

Workspace:SetAttribute('ACC_BecakDriverNavigation','v1.7')
Workspace:SetAttribute('ACC_BecakDriverNavigationEnhancement','v1.8')
Workspace:SetAttribute('BecakNavigationRetargetThrottle','ON')
Workspace:SetAttribute('BecakNavigationRetargetCooldown',RETARGET_COOLDOWN)
