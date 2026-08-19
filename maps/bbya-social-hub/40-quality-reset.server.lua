local W=game:GetService("Workspace")
local root=W:WaitForChild("BBYA_ZERO_BUILD")

-- Hard quality reset: remove procedural props that were visually rejected in live inspection.
-- Structure, floors, walls, teleport targets, lighting system and gameplay systems remain intact.
local removeModels={
 "StageSoundStacks",
 "UndergroundFurnishAndLight",
 "BBYARealismPass",
 "RealismPass",
}
for _,name in ipairs(removeModels) do
 local obj=root:FindFirstChild(name)
 if obj then obj:Destroy() end
end

-- Strip blocky salon fixtures but preserve the salon room footprint for real mesh assets.
local floor1=root:FindFirstChild("Floor1Core")
if floor1 then
 local salon=floor1:FindFirstChild("04_SalonLookStudio")
 if salon then
  for _,obj in ipairs(salon:GetChildren()) do
   if string.find(obj.Name,"SalonConsole") then obj:Destroy() end
  end
 end
 -- Remove the old procedural DJ furniture only; keep stage geometry/sightline.
 local dj=floor1:FindFirstChild("06_DJBooth")
 if dj then
  for _,obj in ipairs(dj:GetChildren()) do
   if obj.Name=="DJDesk" or obj.Name=="DJDeskGlow" then obj:Destroy() end
  end
 end
end

-- Underground: preserve room shell, dance floor and the single approved opposite-DJ bar;
-- remove duplicate block furniture / fake equipment so it cannot stack again.
local ug=root:FindFirstChild("Underground")
if ug then
 local badPrefixes={"SideBench","SofaBack","Sub","Woofer","LaptopStand"}
 for _,obj in ipairs(ug:GetChildren()) do
  for _,prefix in ipairs(badPrefixes) do
   if string.sub(obj.Name,1,#prefix)==prefix then obj:Destroy();break end
  end
 end
end

-- Create invisible anchors for the upcoming real MeshPart asset replacement.
local slots=root:FindFirstChild("MeshAssetSlots") or Instance.new("Folder")
slots.Name="MeshAssetSlots";slots.Parent=root
local function anchor(name,cf)
 local a=slots:FindFirstChild(name) or Instance.new("Part")
 a.Name=name;a.Size=Vector3.new(.2,.2,.2);a.Transparency=1;a.CanCollide=false;a.Anchored=true;a.CFrame=cf;a.Parent=slots
end
anchor("Salon_Chair_A",CFrame.new(-44,1.2,-10))
anchor("Salon_Chair_B",CFrame.new(-44,1.2,-3))
anchor("Salon_Chair_C",CFrame.new(-44,1.2,4))
anchor("Salon_WashStation",CFrame.new(-34,1.2,3))
anchor("MainClub_DJ_Player_L",CFrame.new(-5,4.8,31))
anchor("MainClub_DJ_Mixer",CFrame.new(0,4.8,31))
anchor("MainClub_DJ_Player_R",CFrame.new(5,4.8,31))
anchor("Underground_DJ_Player_L",CFrame.new(-7,-8.5,31))
anchor("Underground_DJ_Mixer",CFrame.new(0,-8.5,31))
anchor("Underground_DJ_Player_R",CFrame.new(7,-8.5,31))
anchor("Underground_Lounge_L",CFrame.new(-43,-13.5,0))
anchor("Underground_Lounge_R",CFrame.new(43,-13.5,0))

print("[BBYA] QUALITY RESET active: rejected procedural props removed; mesh replacement anchors ready")