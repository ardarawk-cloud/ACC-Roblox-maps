-- BBYA SOCIAL HUB — MALL AVATAR FRAMING HOTFIX v1
-- TEST ONLY. Camera-only companion for 133 Mall Catalog.
-- Ignores accessory/mesh extents so layered clothing cannot shrink avatar preview.

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local BODY_NAMES={
 Head=true,UpperTorso=true,LowerTorso=true,HumanoidRootPart=true,
 LeftUpperArm=true,LeftLowerArm=true,LeftHand=true,
 RightUpperArm=true,RightLowerArm=true,RightHand=true,
 LeftUpperLeg=true,LeftLowerLeg=true,LeftFoot=true,
 RightUpperLeg=true,RightLowerLeg=true,RightFoot=true,
 Torso=true,["Left Arm"]=true,["Right Arm"]=true,["Left Leg"]=true,["Right Leg"]=true,
}

local function bodyBounds(model)
 local minV=Vector3.new(math.huge,math.huge,math.huge)
 local maxV=Vector3.new(-math.huge,-math.huge,-math.huge)
 local count=0
 for _,d in ipairs(model:GetDescendants()) do
  if d:IsA("BasePart") and BODY_NAMES[d.Name] then
   local p=d.Position
   local half=d.Size*.5
   minV=Vector3.new(math.min(minV.X,p.X-half.X),math.min(minV.Y,p.Y-half.Y),math.min(minV.Z,p.Z-half.Z))
   maxV=Vector3.new(math.max(maxV.X,p.X+half.X),math.max(maxV.Y,p.Y+half.Y),math.max(maxV.Z,p.Z+half.Z))
   count+=1
  end
 end
 if count<3 then return nil end
 return (minV+maxV)*.5,maxV-minV
end

local function frame(viewport,model)
 if not viewport or not model then return end
 local cam=viewport.CurrentCamera
 if not cam then return end
 local center,size=bodyBounds(model)
 if not center or not size then return end
 local root=model:FindFirstChild("HumanoidRootPart",true)
 local forward=root and root.CFrame.LookVector or Vector3.new(0,0,-1)
 forward=Vector3.new(forward.X,0,forward.Z)
 if forward.Magnitude<.01 then forward=Vector3.new(0,0,-1) else forward=forward.Unit end
 local h=math.clamp(size.Y,4.5,8.5)
 local w=math.clamp(math.max(size.X,size.Z),2.5,6)
 local target=center+Vector3.new(0,h*.01,0)
 local dist=math.max(h*1.75,w*2.0)
 cam.FieldOfView=34
 cam.CFrame=CFrame.lookAt(target+forward*dist,target,Vector3.yAxis)
end

local boundWorld=nil
local conns={}
local function disconnectAll()
 for _,c in ipairs(conns) do c:Disconnect() end
 table.clear(conns)
 boundWorld=nil
end

local function bindMall()
 disconnectAll()
 local gui=pg:FindFirstChild("BBYAMallRobuxCommerceUI")
 if not gui then return end
 local root=gui:FindFirstChild("CatalogRoot")
 local avatar=root and root:FindFirstChild("AvatarCard")
 local viewport=avatar and avatar:FindFirstChild("AvatarViewport")
 local world=viewport and viewport:FindFirstChildOfClass("WorldModel")
 if not viewport or not world then return end
 boundWorld=world
 local function refresh()
  if boundWorld~=world or not world.Parent then return end
  local model=world:FindFirstChildOfClass("Model")
  if not model then return end
  RunService.RenderStepped:Wait()
  frame(viewport,model)
  task.delay(.12,function()if model.Parent==world then frame(viewport,model)end end)
  task.delay(.35,function()if model.Parent==world then frame(viewport,model)end end)
 end
 table.insert(conns,world.ChildAdded:Connect(function()task.defer(refresh)end))
 table.insert(conns,world.DescendantAdded:Connect(function(d)if d:IsA("BasePart")then task.defer(refresh)end end))
 table.insert(conns,viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()task.defer(refresh)end))
 task.defer(refresh)
end

pg.ChildAdded:Connect(function(ch)
 if ch.Name=="BBYAMallRobuxCommerceUI" then task.delay(.1,bindMall) end
end)
pg.ChildRemoved:Connect(function(ch)
 if ch.Name=="BBYAMallRobuxCommerceUI" then disconnectAll() end
end)

task.defer(bindMall)
print("[BBYA] Mall avatar framing hotfix v1 online")