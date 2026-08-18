-- BBYA V5.2 CODED INSPECTION NAV UI
-- Uses the unified LEFT rail TP panel. Panel opens RIGHT and closes after a zone jump.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local inspectionNav = ReplicatedStorage:WaitForChild("BBYA_V5_InspectionNav", 15)

if inspectionNav and teleportP then
    local zoneScroll = Instance.new("ScrollingFrame")
    zoneScroll.Name = "ZoneGrid"
    zoneScroll.Position = UDim2.fromOffset(18, 126)
    zoneScroll.Size = UDim2.new(1, -36, 1, -144)
    zoneScroll.BackgroundTransparency = 1
    zoneScroll.BorderSizePixel = 0
    zoneScroll.ScrollBarThickness = 3
    zoneScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    zoneScroll.CanvasSize = UDim2.new()
    zoneScroll.Parent = teleportP

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(.5, -5, 0, 46)
    grid.CellPadding = UDim2.fromOffset(8, 8)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = zoneScroll

    local zones = {
        {"A1","EXTERIOR"},{"A2","ENTRANCE"},{"A3","LOBBY"},{"A4","MAIN CLUB"},{"A5","BAR"},{"A6","CHILL"},
        {"B1","WEST STAIR"},{"B2","EAST STAIR"},{"B3","LIFT"},
        {"C1","VIP WEST"},{"C2","VIP EAST"},{"C3","QUEEN / BRIDGE"},
        {"D1","ROOF ARRIVAL"},{"D2","POOL ZONE"},{"D3","SKY BAR"},{"D4","ROOF CHILL"},{"D5","CABANA"},{"D6","PHOTO / VIEW"},
        {"S1","SERVICE"},
    }

    for i,item in ipairs(zones) do
        local code,name = item[1],item[2]
        local b = button(zoneScroll, code.."\n"..name, code:sub(1,1) == "D" and CYAN or (code:sub(1,1) == "C" and GOLD or GREEN))
        b.LayoutOrder = i
        b.TextSize = 10
        b.TextWrapped = true
        b.Activated:Connect(function()
            inspectionNav:FireServer(code)
            notify("Inspection jump: "..code.." • "..name)
            teleportP.Visible = false
            activeKey = nil
        end)
    end

    player:SetAttribute("BBYAV5TPPanel", "CODED_INSPECTION")
end
