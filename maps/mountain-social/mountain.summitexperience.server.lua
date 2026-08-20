-- v2.5 Summit experience
local root=workspace:WaitForChild('ACC_MountainSocial',15);if not root then return end
local summit=root:FindFirstChild('ACC_SummitMonument',true);if not summit or not summit:IsA('BasePart') then return end
local ring=Instance.new('Part');ring.Name='SummitPhotoRing';ring.Anchored=true;ring.Size=Vector3.new(28,1,28);ring.CFrame=CFrame.new(summit.Position+Vector3.new(0,-9,8));ring.Material=Enum.Material.Rock;ring.Color=Color3.fromRGB(90,92,90);ring.Transparency=.2;ring.CanCollide=true;ring.Parent=root
local beacon=Instance.new('PointLight');beacon.Name='SummitBeacon';beacon.Range=22;beacon.Brightness=.5;beacon.Color=Color3.fromRGB(235,220,185);beacon.Parent=summit
workspace:SetAttribute('ACC_SummitExperience','v2.5')