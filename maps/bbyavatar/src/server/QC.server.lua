local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local failures = {}
local warnings = {}

local function waitChild(parent, name, kind, timeout)
    local child = parent:WaitForChild(name, timeout or 10)
    if not child then
        table.insert(failures, string.format("Missing %s after timeout: %s.%s", kind or "instance", parent:GetFullName(), name))
        return nil
    end
    return child
end

local root = waitChild(ReplicatedStorage, "BBYAVATAR", "folder", 10)
if root then
    local shared = waitChild(root, "Shared", "folder", 10)
    waitChild(root, "Remotes", "folder", 10)
    if shared then
        waitChild(shared, "CatalogConfig", "module", 10)
        waitChild(shared, "AvatarDescriptionBuilder", "module", 10)
    end
end

local showroom = waitChild(Workspace, "BBYAVATAR_SHOWROOM", "showroom", 15)
if showroom then
    local displays = waitChild(showroom, "DisplayPoints", "folder", 10)
    if displays and #displays:GetChildren() < 6 then
        table.insert(warnings, "Fewer than 6 catalog display points")
    end
    waitChild(showroom, "Mannequins", "folder", 10)
end

if game.PlaceId ~= 0 and game.PlaceId ~= 85866320744490 then
    table.insert(failures, "WRONG PLACE ID: " .. tostring(game.PlaceId))
end

for _, message in ipairs(warnings) do
    warn("[BBYAVATAR QC] WARN:", message)
end

if #failures > 0 then
    for _, message in ipairs(failures) do
        warn("[BBYAVATAR QC] FAIL:", message)
    end
    error(string.format("[BBYAVATAR QC] %d blocking issue(s)", #failures))
end

print(string.format("[BBYAVATAR QC] PASS (%d warning(s))", #warnings))
