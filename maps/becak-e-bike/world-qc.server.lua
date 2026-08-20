-- BECAK E-BIKE — world readability/performance QC v1.7
-- Prevents billboard clutter and removes avoidable collision/query cost from decorative parts.

local Workspace=game:GetService('Workspace')
local root=Workspace:WaitForChild('BecakEBike',20)
if not root then return end

local function tuneBillboard(g)
 if not g:IsA('BillboardGui') then return end
 g.AlwaysOnTop=false
 if g.MaxDistance==0 or g.MaxDistance>80 then g.MaxDistance=60 end
 g.LightInfluence=.25
 local sx=math.min(g.Size.X.Offset>0 and g.Size.X.Offset or 150,160)
 local sy=math.min(g.Size.Y.Offset>0 and g.Size.Y.Offset or 40,44)
 g.Size=UDim2.fromOffset(sx,sy)
 for _,d in ipairs(g:GetDescendants()) do
  if d:IsA('TextLabel') then
   d.TextScaled=false
   d.TextSize=math.clamp(d.TextSize,10,13)
   d.TextWrapped=true
  end
 end
end

local function tunePart(p)
 if not p:IsA('BasePart') then return end
 local n=p.Name
 if string.find(n,'_Mark',1,true) or string.find(n,'District_',1,true) or string.find(n,'Destination_',1,true) or string.find(n,'CargoDrop_',1,true) then
  p.CanCollide=false
  p.CanTouch=false
  p.CanQuery=false
 end
 if string.find(n,'Traffic_',1,true) then
  p.CanCollide=false
  p.CanTouch=false
  p.CanQuery=false
  p.CastShadow=false
 end
end

for _,d in ipairs(root:GetDescendants()) do
 if d:IsA('BillboardGui') then tuneBillboard(d) elseif d:IsA('BasePart') then tunePart(d) end
end
root.DescendantAdded:Connect(function(d)
 task.defer(function()
  if d:IsA('BillboardGui') then tuneBillboard(d) elseif d:IsA('BasePart') then tunePart(d) end
 end)
end)

Workspace:SetAttribute('ACC_BecakWorldQC','v1.7')
print('[BECAK E-BIKE] world QC v1.7 ready')
