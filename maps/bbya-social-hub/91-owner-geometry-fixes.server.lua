-- BBYA SOCIAL HUB — OWNER GEOMETRY FIXES v1
-- Targeted late fixes only: remove obstructing old lift core, close entrance lower corner holes,
-- and guarantee the two owner-rejected pink VIP floor paths stay absent.
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end

-- 5) The old 10x44x10 LiftCore reads as a giant pillar from the VIP approach.
task.spawn(function()
 local upper=root:WaitForChild("UpperLevels",30);if not upper then return end
 local circ=upper:FindFirstChild("VerticalCirculation") or upper:WaitForChild("VerticalCirculation",10)
 if circ then
  local lift=circ:FindFirstChild("LiftCore")
  if lift then lift:Destroy() end
  if #circ:GetChildren()==0 then circ:Destroy() end
 end
end)

-- 6) Close only the lower left/right gaps between the 90-stud entrance facade and 120-stud shell.
task.spawn(function()
 local entrance=root:WaitForChild("Entrance",30);if not entrance then return end
 local old=entrance:FindFirstChild("OwnerLowerCornerFill");if old then old:Destroy() end
 local m=Instance.new("Model");m.Name="OwnerLowerCornerFill";m.Parent=entrance
 for _,x in ipairs({-52.5,52.5}) do
  local p=Instance.new("Part");p.Name=x<0 and "LowerFrontCornerLeft" or "LowerFrontCornerRight"
  p.Size=Vector3.new(15,8,10);p.CFrame=CFrame.new(x,4,-39);p.Color=Color3.fromRGB(9,8,12);p.Material=Enum.Material.Metal
  p.Anchored=true;p.CanCollide=true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=m
 end
 m:SetAttribute("ClosedLowerFrontCornerHoles",true)
end)

-- 4) Late safety guard in case an older neon pass races the corrected source.
task.spawn(function()
 local upper=root:WaitForChild("UpperLevels",30);if not upper then return end
 local vip=upper:WaitForChild("L2_VIP_Level",30);if not vip then return end
 local active=vip:WaitForChild("VIPMinimalStanding",30);if not active then return end
 local precise=active:WaitForChild("PreciseInnerFloorNeon",30)
 if precise then
  local removedPaths={South=false,West=false}
  for _,obj in ipairs(precise:GetChildren()) do
   if obj:IsA("BasePart") then
    if obj.Name:match("^South_") then removedPaths.South=true;obj:Destroy()
    elseif obj.Name:match("^West_") then removedPaths.West=true;obj:Destroy() end
   end
  end
  precise:SetAttribute("OwnerPinkPathsRemoved",(removedPaths.South and 1 or 0)+(removedPaths.West and 1 or 0))
 end
 local oldColored=active:FindFirstChild("TriangleCeilingLight")
 if oldColored then oldColored:Destroy() end
end)

print("[BBYA] Owner geometry fixes v1 online: VIP obstruction / entrance lower corners / pink path guard")
