-- MOUNT BBYA — Phase 1 sign-facing hotfix v6.5.1
-- Runtime evidence: trail/POS1 boards were readable from the outbound side.
-- Scope: ONLY the three boards confirmed in owner screenshots.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("ACC_MountainSocial",60)
if not root then error("Mount BBYA sign hotfix: runtime root missing") end

local deadline=os.clock()+70
while root:GetAttribute("MountBBYAPhase1PremiumReady")~=true do
 if os.clock()>deadline then error("Mount BBYA sign hotfix: premium readiness timeout") end
 task.wait(.2)
end

local targets={
 {folder="ForestEdge",part="TrailMouthSign"},
 {folder="POS1",part="POS1Board"},
 {folder="MountBBYA_Phase1Premium",part="CP1MountBBYA"},
}

local fixed=0
for _,target in ipairs(targets) do
 local folder=root:FindFirstChild(target.folder)
 local board=folder and folder:FindFirstChild(target.part)
 local gui=board and board:FindFirstChildOfClass("SurfaceGui")
 if not gui then
  error(("Mount BBYA sign hotfix: missing SurfaceGui %s/%s"):format(target.folder,target.part))
 end
 gui.Face=Enum.NormalId.Back
 fixed+=1
end

if fixed~=#targets then error("Mount BBYA sign hotfix: incomplete board correction") end
root:SetAttribute("MountBBYASignFacingVersion","6.5.1")
root:SetAttribute("MountBBYASignFacingFixedCount",fixed)
root:SetAttribute("MountBBYASignFacingReady",true)
Workspace:SetAttribute("ACC_MountBBYA_SignFacing","INCOMING_HIKER_SIDE")
print("[MOUNT BBYA] sign-facing hotfix ready",fixed)
