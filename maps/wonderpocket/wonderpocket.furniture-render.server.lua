local ReplicatedStorage=game:GetService("ReplicatedStorage")
local FurnitureAssets=require(ReplicatedStorage:WaitForChild("FurnitureAssets"))

local rendered=setmetatable({}, {__mode="k"})

local function renderCarrier(carrier)
    if not carrier:IsA("BasePart") or rendered[carrier] then return end
    local itemId=carrier:GetAttribute("WP_ItemId") or carrier.Name
    if not FurnitureAssets.IsKnown(itemId) then return end
    rendered[carrier]=true

    carrier.Transparency=1
    carrier.CastShadow=false
    local visual=FurnitureAssets.Create(itemId)
    if not visual then return end
    visual.Name="WP_FurnitureVisual"
    visual.Parent=carrier
    FurnitureAssets.RestoreAppearance(visual)
    visual:PivotTo(carrier.CFrame)

    carrier:GetPropertyChangedSignal("CFrame"):Connect(function()
        if carrier.Parent and visual.Parent then visual:PivotTo(carrier.CFrame) end
    end)
end

local function attachRoot(root)
    for _,obj in ipairs(root:GetDescendants()) do renderCarrier(obj) end
    root.DescendantAdded:Connect(function(obj)
        task.defer(renderCarrier,obj)
    end)
end

local root=workspace:FindFirstChild("WONDERPOCKET_Placed")
if root then attachRoot(root) end
workspace.ChildAdded:Connect(function(child)
    if child.Name=="WONDERPOCKET_Placed" then attachRoot(child) end
end)

print("[WONDERPOCKET] Canonical furniture world renderer ready")
