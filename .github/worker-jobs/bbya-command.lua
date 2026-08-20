print("[BBYA_JOB_BEGIN:run-and-audit-floor1-002]")
local RunService = game:GetService("RunService")
print("STATE_BEFORE|running=" .. tostring(RunService:IsRunning()) .. "|studio=" .. tostring(RunService:IsStudio()))
local ok, err = pcall(function()
    if not RunService:IsRunning() then
        RunService:Run()
    end
end)
print("RUN_CALL|ok=" .. tostring(ok) .. "|err=" .. tostring(err))
task.wait(6)
print("STATE_AFTER|running=" .. tostring(RunService:IsRunning()))
local root = workspace:FindFirstChild("BBYA_ZERO_BUILD")
print("ROOT|exists=" .. tostring(root ~= nil))

local function report(pathLabel, obj)
    if not obj then
        print("OBJ|" .. pathLabel .. "|missing")
        return
    end
    if obj:IsA("BasePart") then
        local p = obj.Position
        local s = obj.Size
        print(string.format("OBJ|%s|class=%s|pos=%.2f,%.2f,%.2f|size=%.2f,%.2f,%.2f|collide=%s", pathLabel, obj.ClassName, p.X,p.Y,p.Z,s.X,s.Y,s.Z,tostring(obj.CanCollide)))
    else
        print("OBJ|" .. pathLabel .. "|class=" .. obj.ClassName .. "|desc=" .. tostring(#obj:GetDescendants()))
    end
end

if root then
    local core = root:FindFirstChild("Floor1Core")
    local club = root:FindFirstChild("MainClubRealism")
    local front = root:FindFirstChild("Floor1FrontPremium")
    report("Floor1Core", core)
    report("MainClubRealism", club)
    report("Floor1FrontPremium", front)

    if club then
        local arch = club:FindFirstChild("Architecture")
        local av = club:FindFirstChild("AudioVisual")
        local furn = club:FindFirstChild("Furniture")
        report("Club.Architecture", arch)
        report("Club.AudioVisual", av)
        report("Club.Furniture", furn)
        local stage = arch and arch:FindFirstChild("PremiumStage")
        local dj = av and av:FindFirstChild("DJBoothPremium")
        local bar = furn and furn:FindFirstChild("MainBarPremium")
        report("Club.Stage", stage)
        report("Club.DJ", dj)
        report("Club.Bar", bar)
        for _, pair in ipairs({
            {"StageDeck", stage and stage:FindFirstChild("StageDeck")},
            {"PortalBack", stage and stage:FindFirstChild("PortalBack")},
            {"LogoDisplay", stage and stage:FindFirstChild("LogoDisplay")},
            {"DJPlatform", dj and dj:FindFirstChild("DJPlatform")},
            {"BoothCenter", dj and dj:FindFirstChild("BoothCenter")},
            {"BoothTop", dj and dj:FindFirstChild("BoothTop")},
        }) do report("Club."..pair[1], pair[2]) end
    end

    if front then
        local photo = front:FindFirstChild("PhotoAreaPremium")
        local salon = front:FindFirstChild("SalonLookStudioPremium")
        report("Front.Photo", photo)
        report("Front.Salon", salon)
        for _, pair in ipairs({
            {"PhotoFloor", photo and photo:FindFirstChild("PhotoInsetFloor")},
            {"PhotoWall", photo and photo:FindFirstChild("PhotoWall")},
            {"PhotoBenchSeat", photo and photo:FindFirstChild("PhotoBenchSeat")},
            {"SalonFloor", salon and salon:FindFirstChild("SalonInsetFloor")},
            {"SalonBack", salon and salon:FindFirstChild("SalonBackFeature")},
        }) do report("Front."..pair[1], pair[2]) end
        if salon then
            for _, child in ipairs(salon:GetChildren()) do
                if child.Name:match("^SalonStation") then report("Front."..child.Name, child) end
            end
        end
    end
end
print("[BBYA_JOB_END:run-and-audit-floor1-002]")
