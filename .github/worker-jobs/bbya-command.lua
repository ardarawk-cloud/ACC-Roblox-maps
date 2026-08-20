print("[BBYA_JOB_BEGIN:dj-wall-render-deep-audit-002]")
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()))
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
print("ROOT|exists="..tostring(root~=nil))
local wall=nil
if root then
 local sys=root:FindFirstChild("DJWallMessageSystem")
 local final=sys and sys:FindFirstChild("FinalMountedWall")
 wall=final and final:FindFirstChild("PrestigeLED")
 print("SYSTEM|"..tostring(sys~=nil).."|FINAL="..tostring(final~=nil).."|WALL="..tostring(wall~=nil))
 if wall then
  local p,s=wall.Position,wall.Size
  print(string.format("WALL|pos=%.2f,%.2f,%.2f|size=%.2f,%.2f,%.2f|trans=%.2f|localTrans=%.2f",p.X,p.Y,p.Z,s.X,s.Y,s.Z,wall.Transparency,wall.LocalTransparencyModifier))
  print("WALLCF|look="..tostring(wall.CFrame.LookVector).."|right="..tostring(wall.CFrame.RightVector).."|up="..tostring(wall.CFrame.UpVector))
  for _,c in ipairs(wall:GetChildren()) do
   if c:IsA("SurfaceGui") then
    local first=c:FindFirstChildWhichIsA("GuiObject")
    local abs=first and first.AbsoluteSize or Vector2.new(-1,-1)
    local pos2=first and first.AbsolutePosition or Vector2.new(-1,-1)
    print("GUI|"..c.Name.."|enabled="..tostring(c.Enabled).."|face="..tostring(c.Face).."|always="..tostring(c.AlwaysOnTop).."|adornee="..tostring(c.Adornee and c.Adornee:GetFullName() or "nil").."|pps="..tostring(c.PixelsPerStud).."|maxdist="..tostring(c.MaxDistance).."|desc="..tostring(#c:GetDescendants()))
    print(string.format("GUIABS|%s|first=%s|visible=%s|abs=%.1f,%.1f|pos=%.1f,%.1f",c.Name,first and first.Name or "nil",tostring(first and first.Visible),abs.X,abs.Y,pos2.X,pos2.Y))
    for _,name in ipairs({"BBYARandomVisuals","MessageMode","IdleVisuals"}) do
     local o=c:FindFirstChild(name,true)
     if o and o:IsA("GuiObject") then
      print("GUINODE|"..c.Name.."|"..name.."|visible="..tostring(o.Visible).."|abs="..tostring(o.AbsoluteSize))
     end
    end
   elseif c:IsA("ProximityPrompt") then
    print("PROMPT|"..c.Name.."|enabled="..tostring(c.Enabled).."|dist="..tostring(c.MaxActivationDistance))
   end
  end
 end
end
local ps=Players:GetPlayers()
print("PLAYERS|count="..tostring(#ps))
local p=ps[1]
if p then
 local pg=p:FindFirstChildOfClass("PlayerGui")
 print("PLAYER|"..p.Name.."|PlayerGui="..tostring(pg~=nil).."|Composer="..tostring(pg and pg:FindFirstChild("BBYADJWallUI")~=nil))
 local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if hrp then hrp.CFrame=CFrame.lookAt(Vector3.new(3,4,14),Vector3.new(3,9,47));print("TELEPORT|ok=true") end
end
local cam=Workspace.CurrentCamera
if cam and wall then
 cam.CameraType=Enum.CameraType.Scriptable
 cam.CFrame=CFrame.lookAt(Vector3.new(3,9,10),wall.Position)
 local origin=cam.CFrame.Position
 local direction=wall.Position-origin
 local params=RaycastParams.new()
 params.FilterType=Enum.RaycastFilterType.Exclude
 local exclude={}
 if p and p.Character then table.insert(exclude,p.Character) end
 params.FilterDescendantsInstances=exclude
 local hit=Workspace:Raycast(origin,direction,params)
 print("CAMERA|pos="..tostring(origin).."|dist="..string.format("%.2f",direction.Magnitude))
 if hit then
  print("RAYHIT|"..hit.Instance:GetFullName().."|material="..tostring(hit.Material).."|pos="..tostring(hit.Position).."|distance="..string.format("%.2f",(hit.Position-origin).Magnitude))
 else
  print("RAYHIT|none")
 end
end
task.wait(3)
print("[BBYA_JOB_END:dj-wall-render-deep-audit-002]")
