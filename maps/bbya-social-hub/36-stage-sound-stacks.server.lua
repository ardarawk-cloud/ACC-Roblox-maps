local W=game:GetService("Workspace")
local root=W:WaitForChild("BBYA_ZERO_BUILD")
local old=root:FindFirstChild("StageSoundStacks");if old then old:Destroy() end
local m=Instance.new("Model",root);m.Name="StageSoundStacks"
local function part(n,size,cf,col,mat,parent)
 local p=Instance.new("Part");p.Name=n;p.Anchored=true;p.CanCollide=true;p.Size=size;p.CFrame=cf;p.Color=col;p.Material=mat or Enum.Material.Metal;p.Parent=parent or m;return p
end
local function neon(n,size,cf,col,parent)local p=part(n,size,cf,col,Enum.Material.Neon,parent);p.CanCollide=false;return p end
local function speakerStack(prefix,x,y,z,accent)
 local model=Instance.new("Model",m);model.Name=prefix
 local dark=Color3.fromRGB(12,13,17);local metal=Color3.fromRGB(38,42,50)
 for i=0,2 do
  local sy=y+i*4.2
  part(prefix.."Cab"..i,Vector3.new(6.8,3.8,4.8),CFrame.new(x,sy,z),dark,Enum.Material.Metal,model)
  local cone=part(prefix.."Cone"..i,Vector3.new(2.6,.6,2.6),CFrame.new(x,sy,z-2.48),metal,Enum.Material.Metal,model);cone.Shape=Enum.PartType.Cylinder;cone.CFrame=CFrame.new(x,sy,z-2.48)*CFrame.Angles(math.rad(90),0,0)
  neon(prefix.."Ring"..i,Vector3.new(3.2,.10,.18),CFrame.new(x,sy,z-2.83),accent,model)
 end
 part(prefix.."Top",Vector3.new(7.4,2.4,4.2),CFrame.new(x,y+13.5,z),dark,Enum.Material.Metal,model)
 neon(prefix.."TopGlow",Vector3.new(5.5,.15,.2),CFrame.new(x,y+13.5,z-2.15),accent,model)
 return model
end
-- Exact mirrored placement around DJ sightline X=0.
-- Main Club: same distance, height, depth and footprint on both sides.
speakerStack("MainClubLeft",-29,4.2,43.5,Color3.fromRGB(0,174,255))
speakerStack("MainClubRight",29,4.2,43.5,Color3.fromRGB(255,42,157))
-- Underground: exact mirror beside DJ stage.
speakerStack("UndergroundLeft",-27,-12.5,31.5,Color3.fromRGB(0,142,255))
speakerStack("UndergroundRight",27,-12.5,31.5,Color3.fromRGB(255,202,36))
print("[BBYA] Stage PA stacks realigned as exact left/right mirrors")