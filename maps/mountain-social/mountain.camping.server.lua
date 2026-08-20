-- ACC Mountain Master v3.0 — functional camp recovery
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("ACC_MountainSocial",20); if not root then return end
local camps=root:WaitForChild("Camps",10); if not camps then return end
local function restore(player)
 player:SetAttribute("Stamina",100); player:SetAttribute("Temperature",100); player:SetAttribute("Oxygen",math.max(player:GetAttribute("Oxygen") or 0,80)); player:SetAttribute("Hydration",math.min(100,(player:GetAttribute("Hydration") or 100)+30)); player:SetAttribute("Hunger",math.min(100,(player:GetAttribute("Hunger") or 100)+20)); player:SetAttribute("LastCampRest",os.time())
end
local function wire(fire)
 if not fire:IsA("BasePart") or fire:FindFirstChild("RestPrompt") then return end
 local prompt=Instance.new("ProximityPrompt"); prompt.Name="RestPrompt"; prompt.ActionText="Rest & Warm Up"; prompt.ObjectText="Mountain Camp"; prompt.HoldDuration=1.2; prompt.MaxActivationDistance=13; prompt.RequiresLineOfSight=false; prompt.Parent=fire; prompt.Triggered:Connect(restore)
end
for _,d in ipairs(camps:GetDescendants()) do if d:IsA("BasePart") and (d.Name=="Campfire" or d:GetAttribute("CampfireReady")) then wire(d) end end
camps.DescendantAdded:Connect(function(d) if d:IsA("BasePart") and (d.Name=="Campfire" or d:GetAttribute("CampfireReady")) then task.defer(wire,d) end end)
Workspace:SetAttribute("ACC_MountainCamping","v3.0")
print("[ACC] Mountain v3 camp recovery ready")
