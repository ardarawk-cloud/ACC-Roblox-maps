-- v2.4 Exploration and secret discovery
local root=workspace:WaitForChild('ACC_MountainSocial',15);if not root then return end
local secrets=root:FindFirstChild('Secrets');if not secrets then return end
local routeHints={Vector3.new(-250,370,-150),Vector3.new(-290,430,-300),Vector3.new(-340,500,-455)}
for i,pos in ipairs(routeHints) do
 local p=Instance.new('Part');p.Name='SecretCairn_'..i;p.Anchored=true;p.Size=Vector3.new(3,2,3);p.CFrame=CFrame.new(pos);p.Material=Enum.Material.Rock;p.Color=Color3.fromRGB(92,94,91);p.CanCollide=true;p.Parent=secrets
 local glow=Instance.new('PointLight');glow.Range=5;glow.Brightness=.2;glow.Color=Color3.fromRGB(180,200,190);glow.Parent=p
end
local hidden=secrets:FindFirstChild('SecretSummit',true)
if hidden and hidden:IsA('BasePart') then hidden.Transparency=.65;hidden.CanCollide=true end
workspace:SetAttribute('ACC_Exploration','v2.4')