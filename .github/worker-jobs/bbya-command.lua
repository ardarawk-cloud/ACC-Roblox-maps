print("[BBYA_JOB_BEGIN:dj-wall-rear-opening-qc-003]")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()))
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
print("ROOT|exists="..tostring(root~=nil))
local shell=root and root:FindFirstChild("ShellAndDressing")
if shell then
 for _,name in ipairs({"L1RearCenter","L1RearCenterLeft","L1RearCenterTop","L1RearCenterBottom"}) do
  local o=shell:FindFirstChild(name)
  if o then o:Destroy() end
 end
 local function p(n,s,cf)
  local x=Instance.new("Part")
  x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Color=Color3.fromRGB(10,9,13);x.Material=Enum.Material.SmoothPlastic;x.Parent=shell
  return x
 end
 p("L1RearCenterLeft",Vector3.new(6,24,2),CFrame.new(-29,12,44))
 p("L1RearCenterTop",Vector3.new(58,7.375,2),CFrame.new(3,20.3125,44))
 p("L1RearCenterBottom",Vector3.new(58,3.375,2),CFrame.new(3,1.6875,44))
 print("REAR_OPENING|applied=true")
else
 print("REAR_OPENING|applied=false|reason=shell_missing")
end
local sys=root and root:FindFirstChild("DJWallMessageSystem")
local final=sys and sys:FindFirstChild("FinalMountedWall")
local wall=final and final:FindFirstChild("PrestigeLED")
print("WALL|exists="..tostring(wall~=nil))
if wall then
 local enabled=0
 for _,c in ipairs(wall:GetChildren()) do
  if c:IsA("SurfaceGui") then
   print("GUI|"..c.Name.."|enabled="..tostring(c.Enabled).."|face="..tostring(c.Face).."|desc="..tostring(#c:GetDescendants()))
   if c.Enabled then enabled+=1 end
  end
 end
 print("GUI_ENABLED|count="..tostring(enabled))
end
local ps=Players:GetPlayers();local player=ps[1]
if player then
 local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if hrp then hrp.CFrame=CFrame.lookAt(Vector3.new(3,4,14),Vector3.new(3,9,47));print("TELEPORT|ok=true") end
end
local cam=Workspace.CurrentCamera
if cam and wall then
 cam.CameraType=Enum.CameraType.Scriptable
 cam.CFrame=CFrame.lookAt(Vector3.new(3,9,10),wall.Position)
 local origin=cam.CFrame.Position
 local direction=wall.Position-origin
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
 local ex={};if player and player.Character then table.insert(ex,player.Character) end;params.FilterDescendantsInstances=ex
 local hit=Workspace:Raycast(origin,direction,params)
 if hit then
  print("RAYHIT|"..hit.Instance:GetFullName().."|distance="..string.format("%.2f",(hit.Position-origin).Magnitude))
  print("RAY_PASS|"..tostring(hit.Instance==wall or hit.Instance:IsDescendantOf(final)))
 else
  print("RAYHIT|none")
  print("RAY_PASS|false")
 end
end
task.wait(4)
print("[BBYA_JOB_END:dj-wall-rear-opening-qc-003]")
