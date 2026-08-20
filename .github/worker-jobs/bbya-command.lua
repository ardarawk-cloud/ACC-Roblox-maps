print("[BBYA_JOB_BEGIN:dj-wall-live-visual-audit-001]")
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()))
local root=workspace:FindFirstChild("BBYA_ZERO_BUILD")
print("ROOT|exists="..tostring(root~=nil))
local function report(label,obj)
 if not obj then print("OBJ|"..label.."|missing") return end
 if obj:IsA("BasePart") then
  local p=obj.Position local s=obj.Size
  print(string.format("OBJ|%s|%s|pos=%.2f,%.2f,%.2f|size=%.2f,%.2f,%.2f|trans=%.2f",label,obj.ClassName,p.X,p.Y,p.Z,s.X,s.Y,s.Z,obj.Transparency))
 else
  print("OBJ|"..label.."|"..obj.ClassName.."|desc="..tostring(#obj:GetDescendants()))
 end
end
if root then
 local sys=root:FindFirstChild("DJWallMessageSystem")
 report("DJWallMessageSystem",sys)
 local final=sys and sys:FindFirstChild("FinalMountedWall")
 report("FinalMountedWall",final)
 local wall=final and final:FindFirstChild("PrestigeLED")
 report("Final.PrestigeLED",wall)
 if wall then
  for _,c in ipairs(wall:GetChildren()) do
   if c:IsA("SurfaceGui") then
    print("GUI|"..c.Name.."|enabled="..tostring(c.Enabled).."|face="..tostring(c.Face).."|always="..tostring(c.AlwaysOnTop).."|adornee="..tostring(c.Adornee and c.Adornee:GetFullName() or "nil").."|desc="..tostring(#c:GetDescendants()))
    local idle=c:FindFirstChild("IdleVisuals",true)
    local random=c:FindFirstChild("BBYARandomVisuals",true)
    local msg=c:FindFirstChild("MessageMode",true)
    print("GUISTATE|idle="..tostring(idle and idle.Visible).."|random="..tostring(random and random.Visible).."|message="..tostring(msg and msg.Visible))
   elseif c:IsA("ProximityPrompt") then
    print("PROMPT|"..c.Name.."|enabled="..tostring(c.Enabled).."|dist="..tostring(c.MaxActivationDistance))
   end
  end
 end
 local club=root:FindFirstChild("MainClubRealism")
 if club then
  local oldLed=club:FindFirstChild("LEDWall",true)
  local oldLogo=club:FindFirstChild("LogoDisplay",true)
  report("Legacy.LEDWall",oldLed)
  report("Legacy.LogoDisplay",oldLogo)
 end
end
local ps=Players:GetPlayers()
print("PLAYERS|count="..tostring(#ps))
local p=ps[1]
if p then
 print("PLAYER|"..p.Name.."|gui="..tostring(p:FindFirstChildOfClass("PlayerGui")~=nil))
 local pg=p:FindFirstChildOfClass("PlayerGui")
 if pg then
  print("PLAYERGUI|BBYADJWallUI="..tostring(pg:FindFirstChild("BBYADJWallUI")~=nil))
 end
 local char=p.Character
 local hrp=char and char:FindFirstChild("HumanoidRootPart")
 if hrp then
  hrp.CFrame=CFrame.lookAt(Vector3.new(3,4,17),Vector3.new(3,8,47))
  print("TELEPORT|ok=true")
 end
end
local cam=workspace.CurrentCamera
if cam then
 cam.CFrame=CFrame.lookAt(Vector3.new(3,8,5),Vector3.new(3,9,47))
 print("CAMERA|set=true")
end
task.wait(2)
print("[BBYA_JOB_END:dj-wall-live-visual-audit-001]")
