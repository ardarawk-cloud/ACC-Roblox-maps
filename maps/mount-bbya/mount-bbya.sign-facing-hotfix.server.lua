-- MOUNT BBYA — Phase 1 sign-facing hotfix v6.5.2
-- Runtime evidence: the trail-start board still faced away from the player's incoming direction.
-- Scope: ONLY sign-facing correction. No terrain/road/house/lighting/system changes.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("ACC_MountainSocial",60)
if not root then error("Mount BBYA sign hotfix: runtime root missing") end

local deadline=os.clock()+70
while root:GetAttribute("MountBBYAPhase1PremiumReady")~=true do
 if os.clock()>deadline then error("Mount BBYA sign hotfix: premium readiness timeout") end
 task.wait(.2)
end

-- Owner runtime evidence confirms the trail-start board needs Front,
-- while the two POS1-side boards remain correct on Back.
local targets={
 {folder="ForestEdge",part="TrailMouthSign",face=Enum.NormalId.Front},
 {folder="POS1",part="POS1Board",face=Enum.NormalId.Back},
 {folder="MountBBYA_Phase1Premium",part="CP1MountBBYA",face=Enum.NormalId.Back},
}

local fixed=0
for _,target in ipairs(targets) do
 local folder=root:FindFirstChild(target.folder)
 local board=folder and folder:FindFirstChild(target.part)
 local gui=board and board:FindFirstChildOfClass("SurfaceGui")
 if not gui then
  error(("Mount BBYA sign hotfix: missing SurfaceGui %s/%s"):format(target.folder,target.part))
 end
 gui.Face=target.face
 fixed+=1
end

if fixed~=#targets then error("Mount BBYA sign hotfix: incomplete board correction") end
root:SetAttribute("MountBBYASignFacingVersion","6.5.2")
root:SetAttribute("MountBBYASignFacingFixedCount",fixed)
root:SetAttribute("MountBBYASignFacingReady",true)
Workspace:SetAttribute("ACC_MountBBYA_SignFacing","TRAIL_START_FRONT_POS1_BACK")
print("[MOUNT BBYA] sign-facing hotfix v6.5.2 ready",fixed)
