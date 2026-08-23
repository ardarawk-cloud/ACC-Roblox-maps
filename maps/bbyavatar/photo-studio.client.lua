-- BBYAVATAR functional Photo Studio v4.
-- Adds Roblox-native screenshot save/share while keeping camera tools local-only.
-- No capture bytes, gallery contents, or user-generated media are persisted by BBYAVATAR.
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CaptureService = game:GetService("CaptureService")
local camera = workspace.CurrentCamera
local photoConnection
local activePreset
local cleanViewToken = 0
local orbitEnabled = false
local orbitStartedAt = 0
local orbitDirection = 1
local captureBusy = false
local photoRemote = root:FindFirstChild("TrackEvent")
local originalFov = camera.FieldOfView

local presets = {
    PORTRAIT = {distance = 7.2, height = 2.3, targetHeight = 2.5, fov = 36, yaw = 0},
    FULL_BODY = {distance = 11.5, height = 1.8, targetHeight = 2.4, fov = 48, yaw = 0},
    CLOSE_UP = {distance = 4.7, height = 2.8, targetHeight = 2.8, fov = 30, yaw = 0},
    THREE_QUARTER_LEFT = {distance = 8.2, height = 2.2, targetHeight = 2.5, fov = 38, yaw = -28},
    THREE_QUARTER_RIGHT = {distance = 8.2, height = 2.2, targetHeight = 2.5, fov = 38, yaw = 28},
}

local grades = {
    NATURAL = {brightness = 0.00, contrast = 0.04, saturation = 0.00, tint = Color3.fromRGB(255,255,255)},
    WARM = {brightness = 0.01, contrast = 0.08, saturation = 0.05, tint = Color3.fromRGB(255,238,220)},
    COOL = {brightness = 0.00, contrast = 0.08, saturation = -0.02, tint = Color3.fromRGB(225,238,255)},
    MONO = {brightness = 0.02, contrast = 0.16, saturation = -1.00, tint = Color3.fromRGB(255,255,255)},
}

local photoGrade = Lighting:FindFirstChild("BBYAVATAR_PhotoGrade")
if not photoGrade then
    photoGrade = Instance.new("ColorCorrectionEffect")
    photoGrade.Name = "BBYAVATAR_PhotoGrade"
    photoGrade.Enabled = false
    photoGrade.Parent = Lighting
end

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

local function setGrade(name)
    local grade = grades[name]
    if not grade then
        photoGrade.Enabled = false
        status.Text = "Photo grade reset."
        return
    end
    photoGrade.Brightness = grade.brightness
    photoGrade.Contrast = grade.contrast
    photoGrade.Saturation = grade.saturation
    photoGrade.TintColor = grade.tint
    photoGrade.Enabled = true
    status.Text = name .. " photo grade active."
    trackPhoto("PHOTO_PRESET")
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
    camera.FieldOfView = originalFov or 70
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
            yaw += orbitDirection * (os.clock() - orbitStartedAt) * math.rad(16)
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
    status.Text = name:gsub("_", " ") .. " camera active."
end

local function takeNativeCapture(mode)
    if captureBusy then
        status.Text = "A capture is already being prepared."
        return
    end
    if not activePreset then startPhotoCamera("PORTRAIT") end
    captureBusy = true
    status.Text = mode == "SHARE" and "Preparing share-ready photo…" or "Preparing photo…"
    trackPhoto("PHOTO_CAPTURE_REQUEST")

    local ok, err = pcall(function()
        CaptureService:TakeScreenshotCaptureAsync(function(result, screenshotCapture)
            captureBusy = false
            if result ~= Enum.ScreenshotCaptureResult.Success or not screenshotCapture then
                status.Text = "Roblox could not capture this photo on the current device."
                trackPhoto("PHOTO_CAPTURE_FAILED")
                return
            end

            trackPhoto("PHOTO_CAPTURE_SUCCESS")
            if mode == "SHARE" then
                local shareOk = pcall(function()
                    local captureContent = Content.fromObject(screenshotCapture)
                    CaptureService:PromptShareCapture(
                        captureContent,
                        "bbyavatar-photo",
                        function()
                            status.Text = "Roblox share sheet opened for your photo."
                            trackPhoto("PHOTO_SHARE_ACCEPTED")
                        end,
                        function()
                            status.Text = "Photo sharing was cancelled."
                            trackPhoto("PHOTO_SHARE_DENIED")
                        end
                    )
                end)
                if not shareOk then
                    status.Text = "Native sharing is unavailable on this device."
                    trackPhoto("PHOTO_SHARE_DENIED")
                end
            else
                local saveOk = pcall(function()
                    CaptureService:PromptSaveCapturesToGallery({screenshotCapture}, function(results)
                        local accepted = results and results[screenshotCapture] == true
                        status.Text = accepted and "Photo saved to your Roblox captures." or "Photo save was cancelled."
                        trackPhoto(accepted and "PHOTO_SAVE_ACCEPTED" or "PHOTO_SAVE_DENIED")
                    end)
                end)
                if not saveOk then
                    status.Text = "Saving captures is unavailable on this device."
                    trackPhoto("PHOTO_SAVE_DENIED")
                end
            end
        end, {UICaptureMode = Enum.UICaptureMode.None})
    end)

    if not ok then
        captureBusy = false
        status.Text = "Native capture is unavailable right now."
        trackPhoto("PHOTO_CAPTURE_FAILED")
        warn("[BBYAVATAR] CaptureService screenshot failed:", err)
    end
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

local function makeSection(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,26)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.Text = text
    l.TextColor3 = Color3.fromRGB(166,172,194)
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
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
    d.Text = "Frame, grade, capture, save, and share your look using Roblox-native capture tools. BBYAVATAR never stores your photo."
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

    makeSection(actions, "FRAMING")
    makePhotoButton(actions, "PORTRAIT", function() orbitEnabled = false; startPhotoCamera("PORTRAIT") end)
    makePhotoButton(actions, "FULL BODY", function() orbitEnabled = false; startPhotoCamera("FULL_BODY") end)
    makePhotoButton(actions, "CLOSE-UP", function() orbitEnabled = false; startPhotoCamera("CLOSE_UP") end)
    makePhotoButton(actions, "3/4 LEFT", function() orbitEnabled = false; startPhotoCamera("THREE_QUARTER_LEFT") end)
    makePhotoButton(actions, "3/4 RIGHT", function() orbitEnabled = false; startPhotoCamera("THREE_QUARTER_RIGHT") end)

    makeSection(actions, "MOTION")
    local orbitButton
    orbitButton = makePhotoButton(actions, "SLOW ORBIT • OFF", function()
        if not activePreset then startPhotoCamera("FULL_BODY") end
        orbitEnabled = not orbitEnabled
        orbitStartedAt = os.clock()
        orbitButton.Text = orbitEnabled and "SLOW ORBIT • ON" or "SLOW ORBIT • OFF"
        status.Text = orbitEnabled and "Slow orbit active • tap again to freeze the angle." or "Orbit frozen."
        trackPhoto(orbitEnabled and "PHOTO_ORBIT_ON" or "PHOTO_ORBIT_OFF")
    end)
    makePhotoButton(actions, "REVERSE ORBIT", function()
        orbitDirection *= -1
        orbitStartedAt = os.clock()
        if not orbitEnabled then
            orbitEnabled = true
            if not activePreset then startPhotoCamera("FULL_BODY") end
        end
        status.Text = "Orbit direction reversed."
        trackPhoto("PHOTO_ORBIT_ON")
    end)

    makeSection(actions, "PHOTO GRADE")
    makePhotoButton(actions, "NATURAL", function() setGrade("NATURAL") end)
    makePhotoButton(actions, "WARM", function() setGrade("WARM") end)
    makePhotoButton(actions, "COOL", function() setGrade("COOL") end)
    makePhotoButton(actions, "MONO", function() setGrade("MONO") end)
    makePhotoButton(actions, "RESET GRADE", function() setGrade(nil) end)

    makeSection(actions, "ROBLOX CAPTURE")
    makePhotoButton(actions, "TAKE & SAVE PHOTO", function() takeNativeCapture("SAVE") end)
    makePhotoButton(actions, "TAKE & SHARE PHOTO", function() takeNativeCapture("SHARE") end)
    makePhotoButton(actions, "CLEAN VIEW • 6 SECONDS", function()
        if not activePreset then startPhotoCamera("PORTRAIT") end
        cleanViewToken += 1
        local token = cleanViewToken
        frame.Visible = false
        openButton.Visible = false
        status.Text = "Clean view active."
        trackPhoto("PHOTO_CLEAN_VIEW")
        task.delay(6, function()
            if cleanViewToken ~= token then return end
            openButton.Visible = true
            frame.Visible = true
            selectTab("PHOTO")
        end)
    end)
    makePhotoButton(actions, "RESET CAMERA", function()
        stopPhotoCamera()
        status.Text = "Camera reset."
        trackPhoto("PHOTO_RESET")
    end)
end

renderers.PHOTO = renderPhoto
close.Activated:Connect(function()
    cleanViewToken += 1
    openButton.Visible = true
    stopPhotoCamera()
    photoGrade.Enabled = false
end)

player.CharacterAdded:Connect(function()
    task.defer(function()
        captureBusy = false
        stopPhotoCamera()
        photoGrade.Enabled = false
    end)
end)

print("[BBYAVATAR] Photo Studio v4 Roblox-native capture + save/share ready")