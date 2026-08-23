-- BBYA SOCIAL HUB — MAIN CLUB FINAL AUTHORITY v2
-- Hard source/runtime authority: Main Club is nightclub-only.
-- Salon + Photo Studio belong in Mall GLOW LAB. No loose DJ-front furniture.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",60)
if not root then return end

root:SetAttribute("BBYAMainClubAuthority","FINAL_AUTHORITY_V2")
root:SetAttribute("BBYAClubPureNightclub",true)

local old=root:FindFirstChild("MainClubFinalAuthorityV1") or root:FindFirstChild("MainClubFinalAuthorityV2")
if old then old:Destroy() end
local out=Instance.new("Model")
out.Name="MainClubFinalAuthorityV2"
out:SetAttribute("Pass","MAINCLUB_FINAL_AUTHORITY_V2")
out:SetAttribute("LegacySalonGuard",true)
out:SetAttribute("LegacyPhotoGuard",true)
out:SetAttribute("DJGrounded",true)
out:SetAttribute("DJFrontClear",true)
out.Parent=root

local C={
 black=Color3.fromRGB(7,7,9),ink=Color3.fromRGB(14,13,17),charcoal=Color3.fromRGB(24,23,28),
 graphite=Color3.fromRGB(42,40,46),stone=Color3.fromRGB(83,79,86),fabric=Color3.fromRGB(39,35,42),
 plum=Color3.fromRGB(69,49,65),brass=Color3.fromRGB(184,139,84),warm=Color3.fromRGB(255,207,161),
}
local function part(name,size,cf,color,material,transparency,parent,collide)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true
 p.CastShadow=material~=Enum.Material.Neon;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out
 return p
end
local function model(name,parent)local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;return m end
local function ball(name,size,cf,color,parent,collide)local p=part(name,size,cf,color,Enum.Material.Fabric,0,parent,collide);p.Shape=Enum.PartType.Ball;return p end
local function cylinder(name,size,cf,color,material,parent,collide)local p=part(name,size,cf,color,material or Enum.Material.Metal,0,parent,collide);p.Shape=Enum.PartType.Cylinder;return p end
local function point(parent,color,brightness,range)local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=false;l.Parent=parent end
local function destroyChild(parent,name)
 if not parent then return false end
 local x=parent:FindFirstChild(name);if x then x:Destroy();return true end
 return false
end

local function purgeLegacy()
 local removed=0

 -- Primitive source rooms are no longer part of Floor 1.
 local core=root:FindFirstChild("Floor1Core")
 if core then
  for _,n in ipairs({"03_PhotoArea","04_SalonLookStudio"}) do if destroyChild(core,n) then removed+=1 end end
 end

 local front=root:FindFirstChild("Floor1FrontPremium")
 if front then
  for _,n in ipairs({"PhotoAreaPremium","SalonLookStudioPremium"}) do if destroyChild(front,n) then removed+=1 end end
 end

 local luxury=root:FindFirstChild("Floor1LuxuryFinish")
 if luxury then
  for _,n in ipairs({"EditorialPhotoRoom","LookLab"}) do if destroyChild(luxury,n) then removed+=1 end end
  local main=luxury:FindFirstChild("MainClub")
  if main then
   if destroyChild(main,"RearSocialRail") then removed+=1 end
  end
 end

 local ultra=root:FindFirstChild("Floor1UltraPremium")
 if ultra then
  for _,n in ipairs({"EditorialPhotoRefinement","LookLabRefinement"}) do if destroyChild(ultra,n) then removed+=1 end end
 end

 -- Old Floor 1 feature anchors must never reopen the retired rooms.
 local features=root:FindFirstChild("Floor1Features")
 if features then
  for _,d in ipairs(features:GetDescendants()) do
   local n=d.Name
   if n=="PhotoModeInteract" or n=="PhotoPrepInteract" or n=="LookWashInteract" or n=="DJRequestInteract" or n:match("^LookChairInteract") then
    d:Destroy();removed+=1
   end
  end
 end

 -- Keep AvatarEditorService/remotes alive for Mall, but remove the original club stations.
 local oldLook=root:FindFirstChild("LookLabAvatarEditorV1")
 if oldLook then
  for _,d in ipairs(oldLook:GetChildren()) do
   if d.Name:match("^LookLabStation") then d:Destroy();removed+=1 end
  end
 end

 -- Relocation pass owns Mall functions only; final authority owns club-side geometry.
 local prior=root:FindFirstChild("ClubPurityMallStudiosV1")
 if prior then
  for _,n in ipairs({"MainClubFrontExtension","DJGrounding"}) do if destroyChild(prior,n) then removed+=1 end end
 end

 -- Remove the old round cocktail pockets directly in front of / beside the DJ.
 local club=root:FindFirstChild("MainClubRealism")
 local furniture=club and club:FindFirstChild("Furniture")
 if furniture then
  for _,d in ipairs(furniture:GetChildren()) do
   if d.Name:match("^RearCocktail_") then d:Destroy();removed+=1 end
  end
 end

 -- No real Seat/VehicleSeat instances in the stage-front/DJ footprint.
 for _,d in ipairs(root:GetDescendants()) do
  if d:IsA("Seat") or d:IsA("VehicleSeat") then
   local p=d.Position
   if p.X>=-18 and p.X<=24 and p.Z>=28 and p.Z<=39 and p.Y<12 then d:Destroy();removed+=1 end
  end
 end
 return removed
end

-- Sweep immediately and through the whole boot window so script start order cannot revive old rooms.
local total=purgeLegacy()
task.spawn(function()
 for _=1,180 do total+=purgeLegacy();task.wait(.25) end
 out:SetAttribute("LegacyObjectsPurged",total)
 out:SetAttribute("AuthoritySweepComplete",true)
end)

local club=root:WaitForChild("MainClubRealism",45)
if club then
 -- Former salon/photo footprint becomes one continuous club lounge zone.
 local extension=model("PureClubFrontExtension",out)
 part("ClubFloorExtension",Vector3.new(25,.16,42),CFrame.new(-39,1.02,-14.5),Color3.fromRGB(22,22,27),Enum.Material.SmoothPlastic,0,extension,true).Reflectance=.08
 part("FloorBrassDatum",Vector3.new(.07,.035,39.5),CFrame.new(-26.65,1.115,-14.5),C.brass,Enum.Material.Metal,0,extension,false)
 part("CeilingExtension",Vector3.new(24,.42,40),CFrame.new(-39,13.0,-14.5),C.ink,Enum.Material.Slate,0,extension,false)
 for i,z in ipairs({-30,-20,-10,0}) do
  part("WallRecess"..i,Vector3.new(.48,8.3,8),CFrame.new(-50.0,6,z),C.ink,Enum.Material.Slate,0,extension,false)
  part("AcousticPanel"..i,Vector3.new(.22,6.7,6.7),CFrame.new(-49.72,6,z),C.fabric,Enum.Material.Fabric,0,extension,false)
  local cove=part("WarmCove"..i,Vector3.new(.08,5.8,.10),CFrame.new(-49.55,6,z-3.15),C.warm,Enum.Material.Neon,.36,extension,false)
  point(cove,C.warm,.14,7)
 end
 part("WallBrassDatum",Vector3.new(.08,.10,38),CFrame.new(-49.50,9.35,-14.5),C.brass,Enum.Material.Metal,0,extension,false)

 local function lounge(index,z)
  local m=model("ClubLoungeExtension"..index,extension)
  part("Rug",Vector3.new(13,.08,9.5),CFrame.new(-39,1.13,z),Color3.fromRGB(29,26,31),Enum.Material.Fabric,0,m,false)
  for n=1,3 do
   local zz=z-2.35+(n-1)*2.35
   ball("Seat"..n,Vector3.new(3.8,.82,2.2),CFrame.new(-44.0,1.72,zz),index==1 and C.fabric or C.plum,m,true)
   ball("Back"..n,Vector3.new(1.0,2.65,2.15),CFrame.new(-46.0,2.82,zz),index==1 and Color3.fromRGB(50,43,52) or Color3.fromRGB(78,56,72),m,false)
  end
  cylinder("TableFoot",Vector3.new(.12,1.8,1.8),CFrame.new(-36.2,.20,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,m,false)
  cylinder("TableStem",Vector3.new(1.12,.18,.18),CFrame.new(-36.2,.90,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,m,false)
  cylinder("TableTop",Vector3.new(.16,3.15,3.15),CFrame.new(-36.2,1.58,z)*CFrame.Angles(0,0,math.rad(90)),C.stone,Enum.Material.Marble,m,false)
  local glow=part("ToeGlow",Vector3.new(.08,.10,6.5),CFrame.new(-45.8,1.18,z),C.warm,Enum.Material.Neon,.42,m,false);point(glow,C.warm,.10,5)
 end
 lounge(1,-27);lounge(2,-13)

 -- Ground the existing DJ platform continuously to Floor 1. Top meets DJPlatform bottom exactly.
 local djBase=model("DJBoothGroundedBase",out)
 part("Core",Vector3.new(15.2,2.15,8.4),CFrame.new(3,2.05,34.3),C.black,Enum.Material.Metal,0,djBase,true)
 part("WingL",Vector3.new(5.8,2.15,7.6),CFrame.new(-6.9,2.05,34.5)*CFrame.Angles(0,math.rad(-11),0),C.charcoal,Enum.Material.Metal,0,djBase,true)
 part("WingR",Vector3.new(5.8,2.15,7.6),CFrame.new(12.9,2.05,34.5)*CFrame.Angles(0,math.rad(11),0),C.charcoal,Enum.Material.Metal,0,djBase,true)
 part("FrontFascia",Vector3.new(21.8,1.72,.42),CFrame.new(3,2.12,30.02),C.ink,Enum.Material.Metal,0,djBase,false)
 for i=1,9 do
  part("FrontRib"..i,Vector3.new(.14,1.15,.10),CFrame.new(-7+(i-1)*2.5,2.15,29.78),i==5 and C.brass or C.graphite,Enum.Material.Metal,0,djBase,false)
 end
 part("TopReveal",Vector3.new(19,.07,.08),CFrame.new(3,3.125,29.75),C.brass,Enum.Material.Metal,0,djBase,false)
end

-- Permanent late-object guard for all retired Floor 1 room generators.
root.DescendantAdded:Connect(function(d)
 task.defer(function()
  if not d.Parent then return end
  local p=d.Parent;local n=d.Name
  if p.Name=="Floor1Core" and (n=="03_PhotoArea" or n=="04_SalonLookStudio") then d:Destroy();return end
  if p.Name=="Floor1FrontPremium" and (n=="PhotoAreaPremium" or n=="SalonLookStudioPremium") then d:Destroy();return end
  if p.Name=="Floor1LuxuryFinish" and (n=="EditorialPhotoRoom" or n=="LookLab") then d:Destroy();return end
  if p.Name=="Floor1UltraPremium" and (n=="EditorialPhotoRefinement" or n=="LookLabRefinement") then d:Destroy();return end
  if p.Name=="Furniture" and n:match("^RearCocktail_") then d:Destroy();return end
 end)
end)

print("[BBYA] Main Club Final Authority v2 online: source rooms retired, DJ grounded, DJ-front furniture cleared")
