-- BECAK E-BIKE — Nusakarya street-life realism v1.0
-- Adds non-collision urban micro-detail around the existing city without touching drivability.
local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',30) if not root then return end
local world=root:WaitForChild('Nusakarya',30) if not world then return end
local old=world:FindFirstChild('CityRealismStreetLife') if old then old:Destroy() end
local folder=Instance.new('Folder');folder.Name='CityRealismStreetLife';folder.Parent=world
local function part(name,size,cf,color,material)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true;p.Color=color;p.Material=material or Enum.Material.Metal;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=folder;return p
end
local function cyl(name,h,r,cf,color,material)
 local p=part(name,Vector3.new(h,r*2,r*2),cf*CFrame.Angles(0,0,math.rad(90)),color,material);p.Shape=Enum.PartType.Cylinder;return p
end
local dark=Color3.fromRGB(57,61,63)
local warm=Color3.fromRGB(222,188,124)
local green=Color3.fromRGB(69,105,72)
local concrete=Color3.fromRGB(151,148,139)
local glass=Color3.fromRGB(116,148,158)
local clusters,pieces=0,0
for _,model in ipairs(world:GetChildren()) do
 if model:IsA('Model') then
  local body=model:FindFirstChild('Body')
  if body and body:IsA('BasePart') and body.Size.X>=18 and body.Size.Z>=12 then
   local s,cf=body.Size,body.CFrame
   local seed=math.abs(math.floor(cf.Position.X*.31+cf.Position.Z*.19))
   local front=-s.Z/2-1.65
   -- compact sidewalk furnishing; deliberately hugs facade so road envelope stays clear
   if seed%3==0 then
    local x=-s.X*.31
    cyl('Bollard',1.15,.12,cf*CFrame.new(x,-s.Y/2+.58,front),dark,Enum.Material.Metal)
    cyl('Bollard',1.15,.12,cf*CFrame.new(x+2.1,-s.Y/2+.58,front),dark,Enum.Material.Metal)
    part('BikeRack',Vector3.new(2.8,.12,.12),cf*CFrame.new(x+1.05,-s.Y/2+.72,front-.1),dark,Enum.Material.Metal)
    pieces+=3
   end
   if seed%4==1 then
    local x=s.X*.31
    part('Planter',Vector3.new(2.5,.75,.9),cf*CFrame.new(x,-s.Y/2+.38,front),concrete,Enum.Material.Concrete)
    for i=-1,1 do cyl('PlanterStem',1.25,.07,cf*CFrame.new(x+i*.65,-s.Y/2+1.05,front),green,Enum.Material.SmoothPlastic) end
    part('PlanterCrown',Vector3.new(2.15,.55,.72),cf*CFrame.new(x,-s.Y/2+1.62,front),green,Enum.Material.Grass)
    pieces+=5
   end
   if seed%5==2 then
    local x=s.X*.28
    part('CafeAwning',Vector3.new(4.8,.16,1.45),cf*CFrame.new(x,-s.Y/2+3.15,front-.25)*CFrame.Angles(math.rad(-8),0,0),warm,Enum.Material.Fabric)
    part('CafeCounter',Vector3.new(3.6,1.15,.72),cf*CFrame.new(x,-s.Y/2+.58,front+.05),dark,Enum.Material.Wood)
    local pane=part('MenuGlass',Vector3.new(1.35,1.8,.08),cf*CFrame.new(x+2.05,-s.Y/2+1.45,front+.08),glass,Enum.Material.Glass);pane.Transparency=.22
    pieces+=3
   end
   if seed%6==3 then
    local x=-s.X*.28
    cyl('StreetLampPole',4.5,.09,cf*CFrame.new(x,-s.Y/2+2.25,front-.25),dark,Enum.Material.Metal)
    part('StreetLampArm',Vector3.new(1.35,.09,.09),cf*CFrame.new(x+.55,-s.Y/2+4.45,front-.25),dark,Enum.Material.Metal)
    local lamp=part('StreetLamp',Vector3.new(.42,.22,.34),cf*CFrame.new(x+1.12,-s.Y/2+4.35,front-.25),warm,Enum.Material.Neon);lamp.CastShadow=false
    pieces+=3
   end
   clusters+=1
  end
 end
end
Workspace:SetAttribute('ACC_BecakCityRealismStreetLife','v1.0')
Workspace:SetAttribute('BecakStreetLifeFacadeSafe','ON')
Workspace:SetAttribute('BecakStreetLifeClusters',clusters)
Workspace:SetAttribute('BecakStreetLifePieces',pieces)
