local Players=game:GetService("Players")

-- Owner-requested cleanup: remove the TRACK 01 admin button panel from runtime UI.
-- Server-side admin/PA systems remain untouched; this client script only prevents
-- the non-functional/cluttered button panel from appearing.
local player=Players.LocalPlayer
if not player then return end

local playerGui=player:WaitForChild("PlayerGui",20)
if not playerGui then return end

local legacy=playerGui:FindFirstChild("TRACK01_AdminPanel")
if legacy then
    legacy:Destroy()
end

print("[TRACK 01] admin button panel disabled by owner request")
