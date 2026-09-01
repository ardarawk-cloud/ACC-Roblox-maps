-- AFTER SCHOOL CITY — V0.9.2.2 CLOUD VISUAL AUDIT HARNESS
-- TEST ONLY. Never publish this harness. Cycles real Studio camera through representative world signage.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera
while not camera do
    Workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
    camera = Workspace.CurrentCamera
end

local deadline = os.clock() + 60
while Workspace:GetAttribute("ASC_GlobalSignageReadabilityPass") == nil and os.clock() < deadline do
    task.wait(0.2)
end

task.wait(2)

local gui = Instance.new("ScreenGui")
gui.Name = "ASC_CloudAuditHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 1000
gui.Parent = playerGui

local label = Instance.new("TextLabel")
label.Name = "AuditTarget"
label.Position = UDim2.fromOffset(10, 10)
label.Size = UDim2.fromOffset(330, 30)
label.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
label.BackgroundTransparency = 0.2
label.BorderSizePixel = 0
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.TextColor3 = Color3.fromRGB(245, 245, 245)
label.TextXAlignment = Enum.TextXAlignment.Left
label.Text = "ASC CLOUD AUDIT — WAITING"
label.Parent = gui

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    label.Text = "ASC CLOUD AUDIT — ROOT MISSING"
    return
end

local normals = {
    [Enum.NormalId.Front] = Vector3.new(0, 0, -1),
    [Enum.NormalId.Back] = Vector3.new(0, 0, 1),
    [Enum.NormalId.Right] = Vector3.new(1, 0, 0),
    [Enum.NormalId.Left] = Vector3.new(-1, 0, 0),
    [Enum.NormalId.Top] = Vector3.new(0, 1, 0),
    [Enum.NormalId.Bottom] = Vector3.new(0, -1, 0),
}

local function findTarget(needle)
    local upper = string.upper(needle)
    for _, surface in ipairs(root:GetDescendants()) do
        if surface:IsA("SurfaceGui") then
            for _, obj in ipairs(surface:GetDescendants()) do
                if obj:IsA("TextLabel") and string.find(string.upper(obj.Text or ""), upper, 1, true) then
                    local plate = surface.Adornee or surface.Parent
                    if plate and plate:IsA("BasePart") then
                        return plate, surface, obj
                    end
                end
            end
        end
    end
    return nil, nil, nil
end

local function frameTarget(name, needle)
    local plate, surface, text = findTarget(needle)
    label.Text = "ASC CLOUD AUDIT — " .. name
    if not plate then
        label.Text ..= " — NOT FOUND"
        warn("[ASC CLOUD HARNESS] target not found: " .. needle)
        return
    end

    local localNormal = normals[surface.Face] or Vector3.new(0, 0, -1)
    local normal = plate.CFrame:VectorToWorldSpace(localNormal).Unit
    local span = math.max(plate.Size.X, plate.Size.Y, plate.Size.Z)
    local distance = math.clamp(span * 0.95, 19, 42)
    local target = plate.Position
    local cameraPosition = target + normal * distance + Vector3.new(0, math.clamp(plate.Size.Y * 0.08, 0, 1.5), 0)

    camera.CameraType = Enum.CameraType.Scriptable
    camera.FieldOfView = 62
    camera.CFrame = CFrame.lookAt(cameraPosition, target)

    print(string.format(
        "[ASC CLOUD HARNESS] TARGET=%s TEXT=%s PART=%s SIZE=%s DIST=%.2f TEXTSCALED=%s TEXTSIZE=%s",
        name,
        tostring(text.Text),
        plate:GetFullName(),
        tostring(plate.Size),
        distance,
        tostring(text.TextScaled),
        tostring(text.TextSize)
    ))
end

local targets = {
    {name = "CITY PARK", needle = "CITY PARK"},
    {name = "SCHOOL", needle = "AFTER SCHOOL ACADEMY"},
    {name = "CANTEEN", needle = "STUDENT CANTEEN"},
    {name = "SKATE", needle = "SKATE"},
}

-- Repeat continuously so external cloud capture does not depend on exact startup timing.
while true do
    for _, target in ipairs(targets) do
        frameTarget(target.name, target.needle)
        task.wait(8)
    end
end
