local Workspace = game:GetService("Workspace")

local ROOT_NAME = "BBYAVATAR_SHOWROOM"

local function part(name, size, cframe, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    return p
end

local old = Workspace:FindFirstChild(ROOT_NAME)
if old then
    old:Destroy()
end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = Workspace

local floor = part("Floor", Vector3.new(120, 1, 90), CFrame.new(0, 0, 0), Enum.Material.Marble)
floor.Parent = root

local backWall = part("BackWall", Vector3.new(120, 24, 1), CFrame.new(0, 12, -44.5), Enum.Material.SmoothPlastic)
backWall.Parent = root

local leftWall = part("LeftWall", Vector3.new(1, 24, 90), CFrame.new(-59.5, 12, 0), Enum.Material.SmoothPlastic)
leftWall.Parent = root

local rightWall = part("RightWall", Vector3.new(1, 24, 90), CFrame.new(59.5, 12, 0), Enum.Material.SmoothPlastic)
rightWall.Parent = root

local stage = part("FeaturedStage", Vector3.new(34, 2, 20), CFrame.new(0, 1.5, -25), Enum.Material.Neon)
stage.Parent = root

local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.CFrame = CFrame.new(0, 1.5, 30)
spawn.Anchored = true
spawn.Neutral = true
spawn.Parent = root

local displays = Instance.new("Folder")
displays.Name = "DisplayPoints"
displays.Parent = root

local positions = {
    Vector3.new(-40, 2, 8), Vector3.new(-20, 2, 8), Vector3.new(0, 2, 8), Vector3.new(20, 2, 8), Vector3.new(40, 2, 8),
    Vector3.new(-40, 2, -10), Vector3.new(-20, 2, -10), Vector3.new(20, 2, -10), Vector3.new(40, 2, -10),
}

for i, pos in ipairs(positions) do
    local pedestal = part(string.format("Display_%02d", i), Vector3.new(10, 1, 10), CFrame.new(pos), Enum.Material.Marble)
    pedestal.Parent = displays
end

print("[BBYAVATAR] Showroom generated")
