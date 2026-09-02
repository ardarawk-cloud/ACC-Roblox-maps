-- MOUNT BBYA — Phase 1 sign cleanup v6.5.3
-- Owner runtime evidence:
-- 1) trail-start board must face incoming hikers;
-- 2) POS1 had duplicate boards carrying the same information.
-- Scope: sign-facing + duplicate-sign cleanup only.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("ACC_MountainSocial",60)
if not root then error("Mount BBYA sign cleanup: runtime root missing") end

local deadline=os.clock()+70
while root:GetAttribute("MountBBYAPhase1PremiumReady")~=true do
 if os.clock()>deadline then error("Mount BBYA sign cleanup: premium readiness timeout") end
 task.wait(.2)
end

-- Trail start: readable from player's incoming direction.
local forest=root:FindFirstChild("ForestEdge")
local trailBoard=forest and forest:FindFirstChild("TrailMouthSign")
local trailGui=trailBoard and trailBoard:FindFirstChildOfClass("SurfaceGui")
if not trailGui then error("Mount BBYA sign cleanup: missing ForestEdge/TrailMouthSign") end
trailGui.Face=Enum.NormalId.Front

-- POS1: keep ONE authoritative branded board only.
local pos1=root:FindFirstChild("POS1")
local duplicate=pos1 and pos1:FindFirstChild("POS1Board")
if duplicate then duplicate:Destroy() end

local premium=root:FindFirstChild("MountBBYA_Phase1Premium")
local cp1Board=premium and premium:FindFirstChild("CP1MountBBYA")
local cp1Gui=cp1Board and cp1Board:FindFirstChildOfClass("SurfaceGui")
if not cp1Gui then error("Mount BBYA sign cleanup: missing MountBBYA_Phase1Premium/CP1MountBBYA") end
cp1Gui.Face=Enum.NormalId.Back

root:SetAttribute("MountBBYASignFacingVersion","6.5.3")
root:SetAttribute("MountBBYASignFacingFixedCount",2)
root:SetAttribute("MountBBYAPOS1BoardCount",1)
root:SetAttribute("MountBBYASignFacingReady",true)
Workspace:SetAttribute("ACC_MountBBYA_SignFacing","TRAIL_START_FRONT_SINGLE_POS1_BOARD")
print("[MOUNT BBYA] sign cleanup v6.5.3 ready")
