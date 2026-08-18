-- BBYA SOCIAL HUB — REMOVE TREES v1.0
-- User-requested cleanup: remove tree/palm geometry entirely, not just collision.

-- Wait until all visual builders finish, then remove every BBYA tree/palm part they created.
task.wait(10)

local removed = 0
local function shouldRemove(obj)
	local n = string.lower(obj.Name)
	return string.find(n,"palm",1,true) ~= nil
		or string.find(n,"tree",1,true) ~= nil
end

-- Destroy folders/models first when their name clearly identifies a tree/palm.
local descendants = workspace:GetDescendants()
for i=#descendants,1,-1 do
	local obj = descendants[i]
	if obj.Parent and (obj:IsA("Folder") or obj:IsA("Model")) and shouldRemove(obj) then
		obj:Destroy()
		removed += 1
	end
end

-- Remove loose palm/tree parts created directly under visual folders.
descendants = workspace:GetDescendants()
for i=#descendants,1,-1 do
	local obj = descendants[i]
	if obj.Parent and obj:IsA("BasePart") and shouldRemove(obj) then
		obj:Destroy()
		removed += 1
	end
end

workspace:SetAttribute("BBYATreesRemoved",true)
workspace:SetAttribute("BBYATreesRemovedCount",removed)
print(string.format("[BBYA] Remove Trees v1.0 loaded — removed %d tree/palm objects",removed))
