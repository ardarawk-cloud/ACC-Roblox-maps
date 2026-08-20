-- BBYA SOCIAL HUB — WORLD PROMPT CLEANUP v1
-- Menu-first UX: removes duplicate travel/message ProximityPrompts shown in-world.
local Workspace=game:GetService("Workspace")

local function shouldRemove(p)
 if not p:IsA("ProximityPrompt") then return false end
 if p.Name=="CreatePrestigeMessage" or p.Name=="RooftopAccessPrompt" then return true end
 local action=tostring(p.ActionText or "")
 local object=tostring(p.ObjectText or "")
 if action=="Go Up" or action=="Go Down" then
  if object=="VIP Level" or object=="Rooftop" or object=="Main Club" or object=="Basement" then return true end
 end
 return false
end

local function sweep()
 local removed=0
 for _,d in ipairs(Workspace:GetDescendants()) do
  if shouldRemove(d) then d:Destroy();removed+=1 end
 end
 return removed
end

task.spawn(function()
 local total=0
 for _=1,24 do total+=sweep();task.wait(.25) end
 print("[BBYA] Menu-first prompt cleanup removed "..total.." duplicate travel/message prompts")
end)
