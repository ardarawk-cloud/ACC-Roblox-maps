local W=game:GetService("Workspace")
local root=W:WaitForChild("BBYA_ZERO_BUILD")
-- Runtime QC: keep decorative parts non-collidable, validate critical zones, and avoid loose physics.
local critical={"Entrance","Floor1Core","UpperLevels","BasementBOH"}
for _,name in ipairs(critical) do if not root:FindFirstChild(name) then warn("[BBYA QC] Missing critical model: "..name) end end
for _,d in ipairs(root:GetDescendants()) do
 if d:IsA("BasePart") then
  d.Anchored=true
  local n=d.Name:lower()
  if n:find("neon") or n:find("glow") or n:find("accent") or n:find("rail") or n:find("light") or n:find("trim") or n:find("sightline") then d.CanCollide=false end
 end
end
-- Invisible fall protection below public footprint; does not alter visible architecture.
local safety=root:FindFirstChild("SafetyFloor")
if safety then safety:Destroy() end
safety=Instance.new("Part");safety.Name="SafetyFloor";safety.Anchored=true;safety.CanCollide=true;safety.Transparency=1;safety.Size=Vector3.new(150,1,120);safety.CFrame=CFrame.new(0,-18,0);safety.Parent=root
print("[BBYA QC] runtime validation complete")