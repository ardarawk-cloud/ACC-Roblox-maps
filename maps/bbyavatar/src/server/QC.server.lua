local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local failures = {}
local warnings = {}

local function requireChild(parent, name, kind)
    local child = parent:FindFirstChild(name)
    if not child then
        table.insert(failures, string.format("Missing %s: %s.%s", kind or "instance", parent:GetFullName(), name))
        return nil
    end
    return child
end

local root = requireChild(ReplicatedStorage, "BBYAVATAR", "folder")
if root then
    local shared = requireChild(root, "Shared", "folder")
    requireChild(root, "Remotes", "folder")
    if shared then
        requireChild(shared, "CatalogConfig", "module")
        requireChild(shared, "AvatarDescriptionBuilder", "module")
    end
end

local showroom = requireChild(Workspace, "BBYAVATAR_SHOWROOM", "showroom")
if showroom then
    local displays = requireChild(showroom, "DisplayPoints", "folder")
    if displays and #displays:GetChildren() < 6 then
        table.insert(warnings, "Fewer than 6 catalog display points")
    end
    requireChild(showroom, "Mannequins", "folder")
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
