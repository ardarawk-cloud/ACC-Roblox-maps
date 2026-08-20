local Players=game:GetService("Players")
local GuiService=game:GetService("GuiService")
local player=Players.LocalPlayer
local gui=player:WaitForChild("PlayerGui"):WaitForChild("BBYAVATAR_UI")

local function applyResponsiveLayout()
    local camera=workspace.CurrentCamera
    local viewport=camera and camera.ViewportSize or Vector2.new(1280,720)
    local compact=viewport.X < 900 or viewport.Y < 600

    local panel=gui:FindFirstChild("CatalogPanel")
    local openButton=gui:FindFirstChild("OpenCatalog")
    if panel then
        if compact then
            panel.Size=UDim2.fromScale(0.97,0.88)
            panel.Position=UDim2.fromScale(0.5,0.53)
        else
            panel.Size=UDim2.fromScale(0.92,0.82)
            panel.Position=UDim2.fromScale(0.5,0.5)
        end

        local header=panel:FindFirstChildWhichIsA("Frame")
        if header then
            for _,d in ipairs(header:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text=="Discover • Create • Save • Shop" then
                    d.Visible=not compact
                end
            end
        end
    end

    if openButton then
        openButton.AnchorPoint=Vector2.new(1,1)
        openButton.Position=compact and UDim2.new(1,-18,1,-92) or UDim2.fromScale(0.97,0.94)
        openButton.Size=compact and UDim2.fromOffset(118,44) or UDim2.fromOffset(132,48)
    end
end

applyResponsiveLayout()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.defer(applyResponsiveLayout)
end)

task.spawn(function()
    while gui.Parent do
        applyResponsiveLayout()
        task.wait(2)
    end
end)

print("[BBYAVATAR] Mobile responsive layer ready")
