-- BBYAVATAR functional Photo Studio.
-- Local-only camera tools: no arbitrary asset execution, no screenshot upload, no user data collection.
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local photoConnection
local activePreset
local cleanViewToken = 0

local presets = {
    PORTRAIT = {distance = 7.2, height = 2.3, targetHeight = 2.5, fov = 36},
    FULL_BODY = {distance = 11.5, height = 1.8, targetHeight = 2.4, fov = 48},
    CLOSE_UP = {distance = 4.7, height = 2.8, targetHeight = 2.8, fov = 30},
}

local function getRig()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    return humanoid, rootPart
end

local function stopPhotoCamera()
    activePreset = nil
    if photoConnection then
        photoConnection:Disconnect()
        photoConnection = nil
    end
    local humanoid = getRig()
    camera.CameraType = Enum.CameraType.Custom
    if humanoid then camera.CameraSubject = humanoid end
    camera.FieldOfView = 70
end

local function startPhotoCamera(name)
    local preset = presets[name]
    if not preset then return end
    local humanoid, rootPart = getRig()
    if not humanoid or not rootPart then
        status.Text = "Avatar is not ready yet."
        return
    end

    activePreset = name
    if photoConnection then photoConnection:Disconnect() end
    camera.CameraType = Enum.CameraType.Scriptable
    camera.FieldOfView = preset.fov

    photoConnection = RunService.RenderStepped:Connect(function()
        if activePreset ~= name or not rootPart.Parent then return end
        local target = rootPart.Position + Vector3.new(0, preset.targetHeight, 0)
        local cameraPos = target + rootPart.CFrame.LookVector * preset.distance + Vector3.new(0, preset.height - preset.targetHeight, 0)
        camera.CFrame = CFrame.lookAt(cameraPos, target)
    end)
    status.Text = name:gsub("_", " ") .. " camera active. Use Roblox's screenshot controls when ready."
end

local function makePhotoButton(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 44)
    b.BackgroundColor3 = Color3.fromRGB(39, 42, 53)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Text = text
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 11)
    b.Activated:Connect(callback)
    return b
end

renderPhoto = function()
    clearContent()

    local h = Instance.new("TextLabel")
    h.BackgroundTransparency = 1
    h.Size = UDim2.new(1, 0, 0, 44)
    h.Font = Enum.Font.GothamBlack
    h.Text = "PHOTO STUDIO"
    h.TextColor3 = Color3.new(1, 1, 1)
    h.TextSize = 26
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.Parent = content

    local d = Instance.new("TextLabel")
    d.BackgroundTransparency = 1
    d.Position = UDim2.fromOffset(0, 44)
    d.Size = UDim2.new(1, 0, 0, 54)
    d.Font = Enum.Font.Gotham
    d.Text = "Frame your avatar with local camera presets, then use Roblox's own screenshot controls."
    d.TextWrapped = true
    d.TextColor3 = Color3.fromRGB(194, 199, 214)
    d.TextSize = 14
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.Parent = content

    local actions = Instance.new("Frame")
    actions.BackgroundTransparency = 1
    actions.Position = UDim2.fromOffset(0, 106)
    actions.Size = UDim2.new(1, 0, 0, 280)
    actions.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = actions

    makePhotoButton(actions, "PORTRAIT", function() startPhotoCamera("PORTRAIT") end)
    makePhotoButton(actions, "FULL BODY", function() startPhotoCamera("FULL_BODY") end)
    makePhotoButton(actions, "CLOSE-UP", function() startPhotoCamera("CLOSE_UP") end)
    makePhotoButton(actions, "RESET CAMERA", stopPhotoCamera)
    makePhotoButton(actions, "CLEAN VIEW • 4 SECONDS", function()
        if not activePreset then startPhotoCamera("PORTRAIT") end
        cleanViewToken += 1
        local token = cleanViewToken
        frame.Visible = false
        openButton.Visible = false
        status.Text = "Clean view active."
        task.delay(4, function()
            if cleanViewToken ~= token then return end
            openButton.Visible = true
            frame.Visible = true
            selectTab("PHOTO")
        end)
    end)
end

renderers.PHOTO = renderPhoto
close.Activated:Connect(function()
    cleanViewToken += 1
    openButton.Visible = true
    stopPhotoCamera()
end)

player.CharacterAdded:Connect(function()
    task.defer(stopPhotoCamera)
end)

print("[BBYAVATAR] Functional Photo Studio camera presets ready")
