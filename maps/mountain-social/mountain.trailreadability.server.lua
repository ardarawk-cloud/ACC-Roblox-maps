-- v2.6 Trail readability without turning into an obby
local root=workspace:WaitForChild('ACC_MountainSocial',15);if not root then return end
local route={Vector3.new(0,22,690),Vector3.new(-132,75,555),Vector3.new(88,126,430),Vector3.new(212,182,300),Vector3.new(78,236,158),Vector3.new(-118,300,34),Vector3.new(-224,356,-106),Vector3.new(-74,414,-242),Vector3.new(116,470,-336),Vector3.new(204,526,-432),Vector3.new(94,575,-540),Vector3.new(0,620,-650)}
local folder=Instance.new('Folder');folder.Name='TrailReadability';folder.Parent=root
for i=2,#route-1 do
 local p=Instance.new('Part');p.Name='TrailCairn_'..i;p.Anchored=true;p.Size=Vector3.new(2.5,1.5,2.5);p.CFrame=CFrame.new(route[i]+Vector3.new(8,1,6));p.Material=Enum.Material.Rock;p.Color=Color3.fromRGB(97,98,94);p.CanCollide=true;p.Parent=folder
end
workspace:SetAttribute('ACC_TrailReadability','v2.6')