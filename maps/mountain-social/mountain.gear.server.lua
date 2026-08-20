-- ACC Mountain Master v3.0 — basecamp gear/refill stations
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("ACC_MountainSocial",20); if not root then return end
local camp=root:WaitForChild("BasecampACC",20); if not camp then return end
local function station(name,pos,color,action,label,callback)
 local p=Instance.new("Part"); p.Name=name; p.Anchored=true; p.Size=Vector3.new(7,5,5); p.CFrame=CFrame.new(pos); p.Material=Enum.Material.WoodPlanks; p.Color=color; p.Parent=camp
 local prompt=Instance.new("ProximityPrompt"); prompt.ActionText=action; prompt.ObjectText=label; prompt.MaxActivationDistance=11; prompt.HoldDuration=.7; prompt.RequiresLineOfSight=false; prompt.Parent=p; prompt.Triggered:Connect(callback); return p
end
local base=Vector3.new(0,22,690)
station("WaterRefill",base+Vector3.new(-8,3,25),Color3.fromRGB(72,102,112),"Refill Water","Hydration Station",function(player) player:SetAttribute("Hydration",100) end)
station("RationStation",base+Vector3.new(1,3,25),Color3.fromRGB(113,91,63),"Eat Ration","Expedition Rations",function(player) player:SetAttribute("Hunger",100) end)
station("OxygenStation",base+Vector3.new(10,3,25),Color3.fromRGB(105,113,120),"Refill Oxygen","High-Altitude Gear",function(player) player:SetAttribute("Oxygen",100); player:SetAttribute("HasOxygenKit",true) end)
station("TrekkingGear",base+Vector3.new(19,3,25),Color3.fromRGB(74,88,68),"Equip Basic Gear","Ranger Gear Rack",function(player) player:SetAttribute("HasTrekkingGear",true); player:SetAttribute("Temperature",100) end)
Workspace:SetAttribute("ACC_MountainGear","v3.0")
print("[ACC] Mountain v3 gear/refill stations ready")
