-- BBYA SOCIAL HUB — V5 UI POLISH v1.1
-- Screenshot-driven corrections: clear thumb controls, remove unsupported glyphs.

local function setRailButtons(frame, labels)
    local buttons = {}
    for _,child in ipairs(frame:GetChildren()) do
        if child:IsA("TextButton") then table.insert(buttons, child) end
    end
    for i,b in ipairs(buttons) do
        b.Text = labels[i] or b.Text
        b.TextSize = 10
        b.Size = UDim2.fromOffset(58, 44)
    end
end

setRailButtons(leftRail, {"DANCE","VIP","PHOTO","TP"})
setRailButtons(rightRail, {"MUSIC","SAWER","PROFILE","SET"})

local function safeTopButton()
    task.defer(function()
        if topOpen and topOpen.Parent then
            topOpen.Text = topDrawer.Visible and "ZONE ^" or "ZONE v"
        end
    end)
end
topDrawer:GetPropertyChangedSignal("Visible"):Connect(safeTopButton)
safeTopButton()

local function applyPolishLayout()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local v = camera.ViewportSize
    local mobile = UserInputService.TouchEnabled or v.X < 900

    -- Keep rails decisively above Roblox thumb controls.
    local railW = mobile and 66 or 74
    local railH = mobile and 220 or 250
    leftRail.Size = UDim2.fromOffset(railW, railH)
    rightRail.Size = UDim2.fromOffset(railW, railH)
    leftRail.Position = UDim2.new(0, 12, mobile and .38 or .42, 0)
    rightRail.Position = UDim2.new(1, -12, mobile and .38 or .42, 0)

    local panelW = math.clamp(v.X * (mobile and .40 or .34), 320, 500)
    local panelH = math.clamp(v.Y * .54, 290, 430)
    local centerY = mobile and .48 or .52
    for _,spec in pairs(panelSpecs) do
        local p = spec.panel
        p.Size = UDim2.fromOffset(panelW, panelH)
        p.AnchorPoint = Vector2.new(spec.origin == "RIGHT" and 1 or 0, .5)
        if spec.origin == "LEFT" then
            p.Position = UDim2.new(0, 12 + railW + 12, centerY, 0)
        else
            p.Position = UDim2.new(1, -(12 + railW + 12), centerY, 0)
        end
    end

    player:SetAttribute("BBYAUIThumbControlClearance", "PASS")
end

local polishCam = workspace.CurrentCamera
if polishCam then polishCam:GetPropertyChangedSignal("ViewportSize"):Connect(applyPolishLayout) end
applyPolishLayout()

player:SetAttribute("BBYAV5UIPolish", "1.1")
print("[BBYA] V5 UI polish 1.1 loaded • rails clear of joystick/jump • ASCII-safe labels")
