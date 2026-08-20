-- Mountain Social Adventure QC gate
-- Fail-closed readiness validation. Never publishes by itself.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local report = {
    ready = true,
    errors = {},
    warnings = {},
    checkedAt = os.time(),
}

local function fail(msg)
    report.ready = false
    table.insert(report.errors, msg)
end

local function warn(msg)
    table.insert(report.warnings, msg)
end

local root = workspace:FindFirstChild("ACC_MountainSocial")
if not root then
    fail("Workspace.ACC_MountainSocial missing")
else
    local cps = root:FindFirstChild("Checkpoints")
    if not cps then
        fail("Checkpoints folder missing")
    else
        local count = 0
        for _,v in ipairs(cps:GetChildren()) do
            if v:IsA("BasePart") or v:IsA("Model") then count += 1 end
        end
        if count < 12 then fail("Expected at least 12 checkpoints, found "..count) end
    end

    if not root:FindFirstChild("Camps") then fail("Camps folder missing") end
    if not root:FindFirstChild("Summit") then fail("Summit area missing") end
    if not root:FindFirstChild("Secrets") then warn("Secrets folder missing") end
end

local remotes = ReplicatedStorage:FindFirstChild("ACC_MountainRemotes")
if not remotes then
    fail("ACC_MountainRemotes missing")
else
    for _,name in ipairs({"Carry","Weather","PhotoMode"}) do
        if not remotes:FindFirstChild(name) then fail("Remote missing: "..name) end
    end
end

workspace:SetAttribute("ACC_MountainReady", report.ready)
workspace:SetAttribute("ACC_MountainQCCheckedAt", report.checkedAt)
workspace:SetAttribute("ACC_MountainQCErrorCount", #report.errors)
workspace:SetAttribute("ACC_MountainQCWarningCount", #report.warnings)

if not report.ready then
    warn("Mountain remains fail-closed until QC errors are resolved")
end

print("[ACC Mountain QC] ready=", report.ready, "errors=", #report.errors, "warnings=", #report.warnings)
for _,e in ipairs(report.errors) do warn(e) end
