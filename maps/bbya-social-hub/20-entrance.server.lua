-- BBYA SOCIAL HUB — ENTRANCE VALIDATION BUILD v1.6
-- Scope lock: FACADE + OPENING + SIGNAGE/CROWN + LIGHTING ONLY.
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder")
root.Name="BBYA_ZERO_BUILD"
root.Parent=Workspace

local old=root:FindFirstChild("Entrance")
if old then old:Destroy() end

local model=Instance.new("Model")
model.Name="Entrance"
model.Parent=root

local C={
 black=Color3.fromRGB(9,8,12),
 charcoal=Color3.fromRGB(25,21,28),
 floor=Color3.fromRGB(71,58,63),
 pink=Color3.fromRGB(255,42,157),
 blue=Color3.fromRGB(0,174,255),
 warm=Color3.fromRGB(255,188,122),
 glass=Color3.fromRGB(50,34,55),
 pinkBody=Color3.fromRGB(72,18,48),
 blueBody=Color3.fromRGB(12,52,82)
}

local function part(name,size,cf,color,material,transparency,parent)
 local p=Instance.new("Part")
 p.Name=name
 p.Anchored=true
 p.CanCollide=true
 p.Size=size
 p.CFrame=cf
 p.Color=color
 p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0
 p.Parent=parent or model
 return p
end

local function neon(name,size,cf,color,parent)
 local p=part(name,size,cf,color or C.pink,Enum.Material.Neon,0,parent)
 p.CanCollide=false
 return p
end

local function pointLight(parent,color,brightness,range)
 local l=Instance.new("PointLight")
 l.Color=color
 l.Brightness=brightness
 l.Range=range
 l.Shadows=true
 l.Parent=parent
end

local function stroke(name,a,b,width)
 local mid=(a+b)/2
 local p=neon(name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt(mid,b),C.pink)
 pointLight(p,C.pink,.5,10)
end

local signModel=Instance.new("Model")
signModel.Name="EntranceSignage"
signModel.Parent=model

local FACE_THICK=.18
local DEFAULT_DEPTH=1.65

local function extrudedStroke(parent,name,x,y,zBase,w,h,rotDeg,faceColor,bodyColor,depth,glowBrightness,glowRange)
 depth=depth or DEFAULT_DEPTH
 local rotation=CFrame.Angles(0,0,math.rad(rotDeg or 0))
 local body=part(name.."Body",Vector3.new(w,h,depth),CFrame.new(x,y,zBase)*rotation,bodyColor or C.charcoal,Enum.Material.Metal,0,parent)
 body.CanCollide=false
 local faceZ=zBase-(depth*.5)-(FACE_THICK*.5)-.02
 local face=part(name.."Face",Vector3.new(math.max(.2,w*.88),math.max(.2,h*.88),FACE_THICK),CFrame.new(x,y,faceZ)*rotation,faceColor or C.pink,Enum.Material.Neon,0,parent)
 face.CanCollide=false
 pointLight(face,faceColor or C.pink,glowBrightness or 1.3,glowRange or 16)
 return body,face
end

local function H(x,y,w)return{k="h",x=x,y=y,w=w}end
local function V(x,y,h)return{k="v",x=x,y=y,h=h}end
local function D(x,y,l,r)return{k="d",x=x,y=y,l=l,r=r}end

local LETTERS={
 [" "]={w=3.0,h=10,segs={}},
 ["A"]={w=8.2,h=10,segs={V(1.2,5,8.8),V(7.0,5,8.8),H(4.1,9.1,6.4),H(4.1,5.1,5.8)}},
 ["B"]={w=8.2,h=10,segs={V(1.1,5,8.8),H(3.9,9.1,5.4),H(3.7,5.1,5.0),H(3.9,.9,5.4),V(6.5,7.1,2.8),V(6.5,2.9,2.8)}},
 ["C"]={w=8.0,h=10,segs={V(1.2,5,8.8),H(4.1,9.1,5.8),H(4.1,.9,5.8)}},
 ["H"]={w=8.4,h=10,segs={V(1.2,5,8.8),V(7.2,5,8.8),H(4.2,5.0,5.8)}},
 ["I"]={w=4.6,h=10,segs={H(2.3,9.1,3.8),H(2.3,.9,3.8),V(2.3,5,8.8)}},
 ["L"]={w=7.2,h=10,segs={V(1.2,5,8.8),H(3.8,.9,5.4)}},
 ["O"]={w=8.4,h=10,segs={V(1.2,5,8.8),V(7.2,5,8.8),H(4.2,9.1,5.8),H(4.2,.9,5.8)}},
 ["S"]={w=8.0,h=10,segs={H(4.0,9.1,5.8),H(4.0,5.0,5.2),H(4.0,.9,5.8),V(1.2,7.0,3.0),V(6.8,3.0,3.0)}},
 ["U"]={w=8.4,h=10,segs={V(1.2,5.3,8.2),V(7.2,5.3,8.2),H(4.2,.9,5.8)}},
 ["Y"]={w=8.4,h=10,segs={D(2.6,7.0,4.8,35),D(5.8,7.0,4.8,-35),V(4.2,2.6,4.6)}},
 ["2"]={w=8.0,h=10,segs={H(4.0,9.1,5.8),V(6.8,7.0,3.0),H(4.0,5.0,5.2),V(1.2,2.7,3.0),H(4.0,.9,5.8)}},
 ["4"]={w=8.0,h=10,segs={V(1.5,6.5,4.8),V(6.6,5.0,8.8),H(4.0,5.0,5.8)}},
 ["7"]={w=8.0,h=10,segs={H(4.0,9.1,5.8),D(5.4,4.8,8.4,25)}},
 ["/"]={w=6.2,h=10,segs={D(3.1,5.0,10.2,25)}}
}

local function measureText(text,scale,gap)
 local total=0
 for i=1,#text do
  local glyph=LETTERS[text:sub(i,i)] or LETTERS[" "]
  total=total+glyph.w
  if i<#text then total=total+gap end
 end
 return total*scale
end

local function drawText3D(parent,name,text,centerX,centerY,zBase,scale,gap,thickness,faceColor,bodyColor)
 local line=Instance.new("Model")
 line.Name=name
 line.Parent=parent
 local total=measureText(text,scale,gap)
 local cursor=centerX-(total*.5)
 for i=1,#text do
  local glyph=LETTERS[text:sub(i,i)] or LETTERS[" "]
  for si,seg in ipairs(glyph.segs) do
   local gx=cursor+(seg.x*scale)
   local gy=centerY+((seg.y-(glyph.h*.5))*scale)
   if seg.k=="h" then
    extrudedStroke(line,name.."_"..i.."_"..si,gx,gy,zBase,seg.w*scale,thickness*scale,0,faceColor,bodyColor,DEFAULT_DEPTH,1.35,16)
   elseif seg.k=="v" then
    extrudedStroke(line,name.."_"..i.."_"..si,gx,gy,zBase,thickness*scale,seg.h*scale,0,faceColor,bodyColor,DEFAULT_DEPTH,1.35,16)
   elseif seg.k=="d" then
    extrudedStroke(line,name.."_"..i.."_"..si,gx,gy,zBase,thickness*.9*scale,seg.l*scale,seg.r,faceColor,bodyColor,DEFAULT_DEPTH,1.35,16)
   end
  end
  cursor=cursor+(glyph.w+gap)*scale
 end
end

part("ArrivalForecourt",Vector3.new(96,1,34),CFrame.new(0,0,-59),C.floor,Enum.Material.Slate)
part("EntryPad",Vector3.new(78,1,16),CFrame.new(0,0,-39),C.floor,Enum.Material.Slate)
part("FacadeLeft",Vector3.new(24,24,10),CFrame.new(-33,12,-39),C.black)
part("FacadeRight",Vector3.new(24,24,10),CFrame.new(33,12,-39),C.black)
part("FacadeHeader",Vector3.new(50,16,10),CFrame.new(0,26,-39),C.black)

part("PortalLeft",Vector3.new(3,15,3),CFrame.new(-22.5,7.5,-43.2),C.charcoal,Enum.Material.Metal)
part("PortalRight",Vector3.new(3,15,3),CFrame.new(22.5,7.5,-43.2),C.charcoal,Enum.Material.Metal)
part("PortalTop",Vector3.new(48,3,3),CFrame.new(0,15,-43.2),C.charcoal,Enum.Material.Metal)
neon("PortalPinkTop",Vector3.new(44,.25,.3),CFrame.new(0,13.6,-44.8),C.pink)

local gl=part("GlassLeft",Vector3.new(16,13,.45),CFrame.new(-33,7,-44.2),C.glass,Enum.Material.Glass,.22);gl.CanCollide=false
local gr=part("GlassRight",Vector3.new(16,13,.45),CFrame.new(33,7,-44.2),C.glass,Enum.Material.Glass,.22);gr.CanCollide=false

-- Dark backplates; the lettering itself is now real Part geometry, not SurfaceGui text.
part("BBYABackplate",Vector3.new(84,15.5,.5),CFrame.new(0,28.6,-43.95),C.black,Enum.Material.SmoothPlastic,0,signModel)
part("SocialHubBackplate",Vector3.new(64,7.6,.5),CFrame.new(0,21.9,-43.95),C.black,Enum.Material.SmoothPlastic,0,signModel)
part("AlwaysOpenBackplate",Vector3.new(50,7.2,.5),CFrame.new(0,16.5,-43.95),C.black,Enum.Material.SmoothPlastic,0,signModel)

-- 3D EXTRUDED SIGNAGE: thick metal bodies + neon front faces.
drawText3D(signModel,"BBYA3D","BBYA",0,28.8,-44.0,1.78,1.0,1.6,C.pink,C.pinkBody)
drawText3D(signModel,"SocialHub3D","SOCIAL HUB",0,21.95,-44.0,.69,.78,1.35,C.pink,C.pinkBody)
drawText3D(signModel,"AlwaysOpen3D","24 / 7",0,16.55,-43.98,.90,.92,1.35,C.blue,C.blueBody)

local z=-44.7
local pts={Vector3.new(-7.5,36,z),Vector3.new(-6.2,41.3,z),Vector3.new(-2.5,38.2,z),Vector3.new(0,43.6,z),Vector3.new(2.5,38.2,z),Vector3.new(6.2,41.3,z),Vector3.new(7.5,36,z)}
for i=1,#pts-1 do stroke("CrownStroke"..i,pts[i],pts[i+1],.5) end
stroke("CrownBase",Vector3.new(-7.5,36,z),Vector3.new(7.5,36,z),.5)
stroke("CrownBase2",Vector3.new(-6.3,34.8,z),Vector3.new(6.3,34.8,z),.38)

for _,x in ipairs({-30,0,30}) do local w=neon("WarmFacade"..x,Vector3.new(7,.2,.35),CFrame.new(x,12,-44.5),C.warm);pointLight(w,C.warm,2.8,20) end
for _,x in ipairs({-16,16}) do local p=neon("PinkFacade"..x,Vector3.new(5,.18,.3),CFrame.new(x,17,-44.4),C.pink);pointLight(p,C.pink,1.8,14) end

local spawn=Instance.new("SpawnLocation")
spawn.Name="EntranceSpawn"
spawn.Anchored=true
spawn.Neutral=true
spawn.Size=Vector3.new(7,1,7)
spawn.CFrame=CFrame.lookAt(Vector3.new(0,1,-66),Vector3.new(0,12,-44))
spawn.Transparency=1
spawn.Parent=model

Lighting.ClockTime=20.2
Lighting.Brightness=3.2
Lighting.Ambient=Color3.fromRGB(72,52,72)
Lighting.OutdoorAmbient=Color3.fromRGB(42,31,46)
Lighting.EnvironmentDiffuseScale=.45
Lighting.EnvironmentSpecularScale=.5
for _,name in ipairs({"BBYAEntranceColor","BBYABloom"}) do local e=Lighting:FindFirstChild(name);if e then e:Destroy() end end
local cc=Instance.new("ColorCorrectionEffect")
cc.Name="BBYAEntranceColor"
cc.Brightness=.08
cc.Contrast=.03
cc.Saturation=.04
cc.TintColor=Color3.fromRGB(255,240,246)
cc.Parent=Lighting
local bloom=Instance.new("BloomEffect")
bloom.Name="BBYABloom"
bloom.Intensity=.38
bloom.Size=24
bloom.Threshold=1.05
bloom.Parent=Lighting

print("[BBYA] Entrance validation v1.6: BBYA / SOCIAL HUB / 24 / 7 converted to thick 3D extruded neon signage")