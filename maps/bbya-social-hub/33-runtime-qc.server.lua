local W=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
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

-- -----------------------------------------------------------------------------
-- REAL WITA WORLD CLOCK v1
-- Synchronizes only Lighting.ClockTime to Bali/WITA real time (UTC+8).
-- Existing venue brightness, ambience, local lights and post-processing stay untouched.
-- This intentionally overrides the old fixed 21.2 ClockTime from Venue Lighting v3.
-- -----------------------------------------------------------------------------
local WITA_OFFSET_SECONDS=8*60*60
local function syncWitaClock()
 local shifted=os.time()+WITA_OFFSET_SECONDS
 local t=os.date("!*t",shifted)
 local clock=t.hour+(t.min/60)+(t.sec/3600)
 Lighting.ClockTime=clock
 Lighting:SetAttribute("BBYARealTimeClock","WITA_UTC_PLUS_8_V1")
 Lighting:SetAttribute("BBYAWitaHour",t.hour)
 Lighting:SetAttribute("BBYAWitaMinute",t.min)
 return clock,t
end

task.spawn(function()
 -- Let one-shot venue lighting initialization finish first, then become the clock authority.
 task.wait(2)
 while true do
  local clock,t=syncWitaClock()
  if not Lighting:GetAttribute("BBYARealTimeClockAnnounced") then
   Lighting:SetAttribute("BBYARealTimeClockAnnounced",true)
   print(string.format("[BBYA] Real WITA clock v1 online: %02d:%02d WITA / ClockTime %.2f",t.hour,t.min,clock))
  end
  task.wait(15)
 end
end)
