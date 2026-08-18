-- BBYA Supporter Board Position Hotfix
-- Moves supporter displays away from the rooftop stair path.

task.spawn(function()
    local deadline = os.clock() + 20
    local board, donate

    repeat
        board = workspace:FindFirstChild("Top Supporters Board", true)
        donate = workspace:FindFirstChild("Donate Text Wall", true)
        if board and donate then break end
        task.wait(0.25)
    until os.clock() >= deadline

    if board and board:IsA("BasePart") then
        -- Arrival/lobby display wall, facing the main pedestrian flow.
        board.CFrame = CFrame.new(-46, 9, 73) * CFrame.Angles(0, math.rad(180), 0)
        board.CanCollide = false
    end

    if donate and donate:IsA("BasePart") then
        donate.CFrame = CFrame.new(-27, 6, 73) * CFrame.Angles(0, math.rad(180), 0)
        donate.CanCollide = false
    end
end)
