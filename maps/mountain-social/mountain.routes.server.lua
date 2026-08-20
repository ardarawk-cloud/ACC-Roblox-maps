-- ACC Mountain Master v3.0 — multi-route expedition network
local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("ACC_MountainSocial", 20)
if not root then warn("[Mountain:v3 routes] ACC_MountainSocial missing") return end
local existing = root:FindFirstChild("MasterRoutes")
if existing then existing:Destroy() end
local routesFolder = Instance.new("Folder"); routesFolder.Name = "MasterRoutes"; routesFolder.Parent = root
local function part(name,size,cf,material,color,parent,transparency)
 local p=Instance.new("Part"); p.Name=name; p.Anchored=true; p.Size=size; p.CFrame=cf; p.Material=material or Enum.Material.Ground; p.Color=color or Color3.fromRGB(102,88,68); p.Transparency=transparency or 0; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.CanCollide=true; p.Parent=parent; return p
end
local routeColors={GREEN=Color3.fromRGB(95,124,78),RED=Color3.fromRGB(127,82,66),BLACK=Color3.fromRGB(72,73,74)}
local routePoints={
 GREEN={Vector3.new(0,22,690),Vector3.new(130,70,565),Vector3.new(245,130,445),Vector3.new(270,195,300),Vector3.new(210,260,145),Vector3.new(190,330,-10),Vector3.new(160,405,-175),Vector3.new(116,470,-336)},
 RED={Vector3.new(0,22,690),Vector3.new(-85,78,555),Vector3.new(45,135,430),Vector3.new(-45,205,285),Vector3.new(-135,275,125),Vector3.new(-205,345,-60),Vector3.new(-120,410,-210),Vector3.new(116,470,-336)},
 BLACK={Vector3.new(78,236,158),Vector3.new(-175,305,85),Vector3.new(-300,365,-80),Vector3.new(-285,425,-235),Vector3.new(-115,465,-320),Vector3.new(116,470,-336)}
}
local function makeSegment(routeName,index,a,b,width)
 local delta=b-a; local distance=delta.Magnitude; local midpoint=(a+b)*.5
 local segment=part(string.format("%s_%02d",routeName,index),Vector3.new(width,2.4,distance),CFrame.lookAt(midpoint-Vector3.new(0,1.4,0),b-Vector3.new(0,1.4,0)),routeName=="BLACK" and Enum.Material.Slate or Enum.Material.Ground,routeColors[routeName],routesFolder,.04)
 segment:SetAttribute("RouteName",routeName); segment:SetAttribute("RouteIndex",index); segment:SetAttribute("Difficulty",routeName=="GREEN" and 1 or routeName=="RED" and 2 or 3); return segment
end
for routeName,points in pairs(routePoints) do
 local routeModel=Instance.new("Model"); routeModel.Name=routeName.."_TRAIL"; routeModel:SetAttribute("RouteName",routeName); routeModel:SetAttribute("Difficulty",routeName=="GREEN" and "SCENIC" or routeName=="RED" and "EXPEDITION" or "EXTREME"); routeModel.Parent=routesFolder
 for i=1,#points-1 do
  local a,b=points[i],points[i+1]; local width=routeName=="GREEN" and 16 or routeName=="RED" and 13 or 9; local delta=b-a; local side=Vector3.new(-delta.Z,0,delta.X); if side.Magnitude>0 then side=side.Unit end; local previous=a
  for sub=1,4 do local t=sub/4; local target=a:Lerp(b,t); local sway=math.sin((i*2.1+sub)*1.35)*(routeName=="GREEN" and 12 or routeName=="RED" and 9 or 5); target += side*sway; local s=makeSegment(routeName,(i-1)*4+sub,previous,target,width); s.Parent=routeModel; previous=target end
 end
end
local upper={Vector3.new(116,470,-336),Vector3.new(204,526,-432),Vector3.new(94,575,-540),Vector3.new(0,620,-650)}
local upperModel=Instance.new("Model"); upperModel.Name="UPPER_SHARED_ROUTE"; upperModel.Parent=routesFolder
for i=1,#upper-1 do local s=makeSegment("BLACK",100+i,upper[i],upper[i+1],12); s.Name="UPPER_"..i; s:SetAttribute("RouteName","SHARED_SUMMIT"); s.Parent=upperModel end
local selector=part("RouteSelector",Vector3.new(52,2,18),CFrame.new(0,25,654),Enum.Material.WoodPlanks,Color3.fromRGB(91,72,52),routesFolder,0); selector:SetAttribute("RouteSelector",true)
for i,routeName in ipairs({"GREEN","RED","BLACK"}) do local post=part("RoutePost_"..routeName,Vector3.new(3,12,3),CFrame.new(-14+(i-1)*14,32,650),Enum.Material.Wood,routeColors[routeName],routesFolder,0); post:SetAttribute("RouteName",routeName); post:SetAttribute("RouteLabel",routeName=="GREEN" and "SCENIC" or routeName=="RED" and "EXPEDITION" or "EXTREME") end
root:SetAttribute("RouteSystem","v3.0"); root:SetAttribute("RouteCount",3); Workspace:SetAttribute("ACC_MountainRoutes","v3.0")
print("[ACC] Mountain v3 multi-route network ready")
