-- BBYAVATAR functional Photo Studio.
-- Local-only camera tools: no arbitrary asset execution, no screenshot upload, no user data collection.
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local photoConnection
local activePreset
local cleanViewToken = 0
local orbitEnabled = false
local orbitStartedAt = 0
local photoRemote = root:FindFirstChild("TrackEvent")

local presets = {
    PORTRAIT = {distance = 7.2, height = 2.3, targetHeight = 2.5, fov = 36, yaw = 0},
    FULL_BODY = {distance = 11.5, height = 1.8, targetHeight = 2.4, fov = 48, yaw = 0},
    CLOSE_UP = {distance = 4.7, height = 2.8, targetHeight = 2.8, fov = 30, yaw = 0},
    THREE_QUARTER = {distance = 8.2, height = 2.2, targetHeight = 2.5, fov = 38, yaw = 28},
}

local function trackPhoto(eventName)
    if photoRemote and photoRemote:IsA("RemoteEvent") then
        pcall(function() photoRemote:FireServer(eventName) end)
    end
end

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
    orbitEnabled = false
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
        local yaw = math.rad(preset.yaw or 0)
        if orbitEnabled then
            yaw += (os.clock() - orbitStartedAt) * math.rad(16)
        end
        local forward = rootPart.CFrame.LookVector
        local horizontal = Vector3.new(forward.X, 0, forward.Z)
        if horizontal.Magnitude < 0.01 then horizontal = Vector3.new(0, 0, -1) end
        horizontal = horizontal.Unit
        local rotated = CFrame.fromAxisAngle(Vector3.yAxis, yaw):VectorToWorldSpace(horizontal)
        local cameraPos = target + rotated * preset.distance + Vector3.new(0, preset.height - preset.targetHeight, 0)
        camera.CFrame = CFrame.lookAt(cameraPos, target)
    end)
    trackPhoto("PHOTO_PRESET")
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
    trackPhoto("PHOTO_OPEN")

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
    d.Text = "Frame your avatar with local camera presets, 3/4 angles, and a slow orbit. Use Roblox's own screenshot controls."
    d.TextWrapped = true
    d.TextColor3 = Color3.fromRGB(194, 199, 214)
    d.TextSize = 14
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.Parent = content

    local actions = Instance.new("ScrollingFrame")
    actions.BackgroundTransparency = 1
    actions.Position = UDim2.fromOffset(0, 106)
    actions.Size = UDim2.new(1, 0, 1, -140)
    actions.AutomaticCanvasSize = Enum.AutomaticSize.Y
    actions.CanvasSize = UDim2.new()
    actions.ScrollBarThickness = 3
    actions.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = actions

    makePhotoButton(actions, "PORTRAIT", function() orbitEnabled = false; startPhotoCamera("PORTRAIT") end)
    makePhotoButton(actions, "FULL BODY", function() orbitEnabled = false; startPhotoCamera("FULL_BODY") end)
    makePhotoButton(actions, "CLOSE-UP", function() orbitEnabled = false; startPhotoCamera("CLOSE_UP") end)
    makePhotoButton(actions, "3/4 ANGLE", function() orbitEnabled = false; startPhotoCamera("THREE_QUARTER") end)
    local orbitButton
    orbitButton = makePhotoButton(actions, "SLOW ORBIT • OFF", function()
        if not activePreset then startPhotoCamera("FULL_BODY") end
        orbitEnabled = not orbitEnabled
        orbitStartedAt = os.clock()
        orbitButton.Text = orbitEnabled and "SLOW ORBIT • ON" or "SLOW ORBIT • OFF"
        status.Text = orbitEnabled and "Slow orbit active • tap again to freeze the angle." or "Orbit frozen."
        trackPhoto(orbitEnabled and "PHOTO_ORBIT_ON" or "PHOTO_ORBIT_OFF")
    end)
    makePhotoButton(actions, "RESET CAMERA", function()
        stopPhotoCamera()
        status.Text = "Camera reset."
        trackPhoto("PHOTO_RESET")
    end)
    makePhotoButton(actions, "CLEAN VIEW • 4 SECONDS", function()
        if not activePreset then startPhotoCamera("PORTRAIT") end
        cleanViewToken += 1
        local token = cleanViewToken
        frame.Visible = false
        openButton.Visible = false
        status.Text = "Clean view active."
        trackPhoto("PHOTO_CLEAN_VIEW")
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

print("[BBYAVATAR] Photo Studio v2 camera presets + orbit ready")