-- BBYA SOCIAL HUB — WORLD PROMPT CLEANUP v2
-- Menu-first UX: Travel is the only navigation authority for duplicate world teleports.
local Workspace=game:GetService("Workspace")

local function shouldRemovePrompt(p)
 if not p:IsA("ProximityPrompt") then return false end
 if p.Name=="CreatePrestigeMessage" or p.Name=="RooftopAccessPrompt" then return true end
 local action=tostring(p.ActionText or "")
 local object=tostring(p.ObjectText or "")
 if action=="Go Up" or action=="Go Down" then
  if object=="VIP Level" or object=="Rooftop" or object=="Rooftop Pool" or object=="Main Club" or object=="Basement" then return true end
 end
 return false
end

local function shouldRemoveAccessPart(o)
 return o:IsA("BasePart") and o.Name=="RooftopAccess"
end

local function removeIfDuplicate(o)
 if not o or not o.Parent then return false end
 if shouldRemovePrompt(o) or shouldRemoveAccessPart(o) then
  o:Destroy()
  return true
 end
 return false
end

local function sweep()
 local removed=0
 for _,d in ipairs(Workspace:GetDescendants()) do
  if removeIfDuplicate(d) then removed+=1 end
 end
 return removed
end

task.defer(function()
 local total=sweep()
 print("[BBYA] Menu-first prompt cleanup v2 removed "..total.." duplicate world navigation objects")
end)

Workspace.DescendantAdded:Connect(function(d)
 if shouldRemovePrompt(d) or shouldRemoveAccessPart(d) then
  task.defer(function()
   if d.Parent then removeIfDuplicate(d) end
  end)
 end
end)
