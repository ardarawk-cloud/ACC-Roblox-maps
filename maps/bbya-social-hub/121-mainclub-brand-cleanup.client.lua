-- BBYA SOCIAL HUB — MAIN CLUB BRAND CLEANUP v1
-- Keeps the large BBYA MAIN CLUB identity dominant by removing the competing small "BBYA LIVE WAVE" copy.
-- Visual text only; audio-reactive behavior, SoundIds, routing and message mode are untouched.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local system=root:WaitForChild("DJWallMessageSystem",30)
if not system then return end
local final=system:WaitForChild("FinalMountedWall",30)
if not final then return end
local screen=final:WaitForChild("PrestigeLED",30)
if not screen then return end

local bound={}
local changing=false

local function sanitize(label)
 if not label or not label:IsA("TextLabel") then return end
 local up=string.upper(tostring(label.Text or ""))
 if up:find("BBYA",1,true) and up:find("LIVE WAVE",1,true) then
  changing=true
  label.Text="BBYA"
  changing=false
 end
 if not bound[label] then
  bound[label]=true
  label:GetPropertyChangedSignal("Text"):Connect(function()
   if not changing then task.defer(function()sanitize(label)end) end
  end)
 end
end

for _,d in ipairs(screen:GetDescendants()) do sanitize(d) end
screen.DescendantAdded:Connect(function(d)if d:IsA("TextLabel") then task.defer(function()sanitize(d)end) end end)

screen:SetAttribute("BBYAMainClubSingleBrand",true)
print("[BBYA] Main Club brand cleanup v1: competing BBYA LIVE WAVE copy removed; main signage remains dominant")
