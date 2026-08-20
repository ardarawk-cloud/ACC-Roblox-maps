print("[BBYA_JOB_BEGIN:audit-runtime-001]")
local RunService = game:GetService("RunService")
print("STATE|running=" .. tostring(RunService:IsRunning()) .. "|studio=" .. tostring(RunService:IsStudio()))
local root = workspace:FindFirstChild("BBYA_ZERO_BUILD")
print("ROOT|exists=" .. tostring(root ~= nil))
if root then
    for _, name in ipairs({"Floor1Core","MainClubRealism","Floor1FrontPremium"}) do
        local obj = root:FindFirstChild(name)
        print("MODEL|" .. name .. "|exists=" .. tostring(obj ~= nil) .. (obj and ("|desc=" .. tostring(#obj:GetDescendants())) or ""))
    end
end
print("[BBYA_JOB_END:audit-runtime-001]")
