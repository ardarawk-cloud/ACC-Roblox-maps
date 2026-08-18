-- BBYA SOCIAL HUB — MASTER PLAN QC v3.0.1
-- Safety/collision post-check for the completion layer.

local ROOT_NAME = "BBYA Master Plan Completion v3"
local root = workspace:WaitForChild(ROOT_NAME, 20)
if not root then
	warn("[BBYA MASTER PLAN QC] completion root missing")
	return
end

local circulation = root:FindFirstChild("Natural Circulation")
if not circulation then
	warn("[BBYA MASTER PLAN QC] circulation folder missing")
	return
end

local C_BLACK = Color3.fromRGB(10, 10, 16)
local C_GLASS = Color3.fromRGB(66, 92, 120)

local function frameLift(name)
	local folder = circulation:FindFirstChild(name)
	if not folder then return end

	local shaft = folder:FindFirstChild(name .. " Shaft")
	if shaft and shaft:IsA("BasePart") then
		-- The original completion pass used a volume marker for the shaft.
		-- Make it non-blocking/invisible and build the visible frame around it.
		shaft.CanCollide = false
		shaft.CanTouch = false
		shaft.CanQuery = false
		shaft.Transparency = 1
	end

	if folder:FindFirstChild(name .. " Frame Post 1") then return end

	local centerX = string.find(name, "West") and -56 or 56
	local centerZ = 46
	local function p(n, size, cf, color, material, transparency, collide)
		local x = Instance.new("Part")
		x.Name = n
		x.Size = size
		x.CFrame = cf
		x.Anchored = true
		x.CanCollide = collide ~= false
		x.Color = color
		x.Material = material
		x.Transparency = transparency or 0
		x.TopSurface = Enum.SurfaceType.Smooth
		x.BottomSurface = Enum.SurfaceType.Smooth
		x.Parent = folder
		return x
	end

	local corners = {
		{-4.8, -4.8}, {4.8, -4.8}, {-4.8, 4.8}, {4.8, 4.8},
	}
	for i, c in ipairs(corners) do
		p(name .. " Frame Post " .. i, Vector3.new(0.7, 38, 0.7), CFrame.new(centerX + c[1], 20, centerZ + c[2]), C_BLACK, Enum.Material.Metal, 0, true)
	end

	p(name .. " Rear Glass", Vector3.new(8.9, 35, 0.35), CFrame.new(centerX, 20, centerZ + 4.65), C_GLASS, Enum.Material.Glass, 0.5, true)
	p(name .. " Roof", Vector3.new(10.4, 0.6, 10.4), CFrame.new(centerX, 39.1, centerZ), C_BLACK, Enum.Material.Metal, 0, true)
end

frameLift("West BBYA Lift")
frameLift("East BBYA Lift")

-- Non-colliding decorative signs/lights should never block walking routes.
for _, obj in ipairs(root:GetDescendants()) do
	if obj:IsA("BasePart") then
		local n = string.lower(obj.Name)
		if string.find(n, "sign") or string.find(n, "neon") or string.find(n, "accent") then
			obj.CanCollide = false
		end
	end
end

workspace:SetAttribute("BBYAMasterPlanQC", "3.0.1")
print("[BBYA MASTER PLAN QC] v3.0.1 loaded: lift shafts non-blocking, framed, decorative collisions cleared")
