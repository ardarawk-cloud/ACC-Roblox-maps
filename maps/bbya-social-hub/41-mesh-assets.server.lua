-- BBYA SOCIAL HUB — OPTIONAL EXTERNAL MESH PASS
-- Premium live geometry must never depend on third-party Creator Store permissions.
-- This pass is intentionally non-blocking; deterministic venue/furniture is built in 42-main-club-realism.server.lua.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BBYA_ZERO_BUILD")

local old = root:FindFirstChild("MeshAssetPass")
if old then old:Destroy() end

local out = Instance.new("Folder")
out.Name = "MeshAssetPass"
out:SetAttribute("Mode", "OPTIONAL_EXTERNAL_ASSETS_DISABLED")
out:SetAttribute("Reason", "Live venue must render consistently without Creator Store runtime permission dependencies")
out.Parent = root

print("[BBYA] External runtime mesh loading disabled; deterministic premium geometry is authoritative")
