-- BBYA Social Hub visual readability hotfix v1.1
-- Fixes the current offside/overlap problem: signs stay on their boards and decorative structures do not cut through player sightlines.

local function oppositeFace(face)
 if face == Enum.NormalId.Front then return Enum.NormalId.Back end
 if face == Enum.NormalId.Back then return Enum.NormalId.Front end
 if face == Enum.NormalId.Left then return Enum.NormalId.Right end
 if face == Enum.NormalId.Right then return Enum.NormalId.Left end
 if face == Enum.NormalId.Top then return Enum.NormalId.Bottom end
 if face == Enum.NormalId.Bottom then return Enum.NormalId.Top end
 return nil
end

local function tuneLabel(label)
 if not label:IsA("TextLabel") then return end
 label.TextScaled = true
 label.TextWrapped = false
 label.ClipsDescendants = true
 label.TextStrokeTransparency = 0.35
 -- Give every word breathing room so text cannot touch/cross the board edge.
 label.Position = UDim2.fromScale(0.06,0.12)
 label.Size = UDim2.fromScale(0.88,0.76)
 local limit = Instance.new("UITextSizeConstraint")
 limit.Name = "BBYAReadabilityLimit"
 limit.MinTextSize = 10
 limit.MaxTextSize = 42
 limit.Parent = label
end

local function addBackFace(gui)
 if not gui:IsA("SurfaceGui") then return end
 local parent = gui.Parent
 if not parent or not parent:IsA("BasePart") then return end
 gui.AlwaysOnTop = false
 gui.LightInfluence = 0.15
 for _,d in ipairs(gui:GetDescendants()) do tuneLabel(d) end
 if gui:GetAttribute("BBYADoubleSided") then return end
 local opposite = oppositeFace(gui.Face)
 if not opposite then return end
 for _,child in ipairs(parent:GetChildren()) do
  if child:IsA("SurfaceGui") and child ~= gui and child.Face == opposite and child:GetAttribute("BBYASignMirror") then
   gui:SetAttribute("BBYADoubleSided",true)
   return
  end
 end
 local back=gui:Clone()
 back.Name=gui.Name.."_ReadableBack"
 back.Face=opposite
 back:SetAttribute("BBYASignMirror",true)
 back:SetAttribute("BBYADoubleSided",true)
 back.Parent=parent
 gui:SetAttribute("BBYADoubleSided",true)
end

local function cleanIntrusiveGeometry(root)
 for _,o in ipairs(root:GetDescendants()) do
  if o:IsA("BasePart") then
   local n=string.lower(o.Name)
   -- These long decorative rails/beams are the pieces visibly slicing through the room in mobile screenshots.
   if string.find(n,"upper rail") then
    o.CanCollide=false
    o.Transparency=1
   elseif string.find(n,"upper rail neon") then
    o.CanCollide=false
    o.Transparency=1
   end
  end
 end
end

for _,obj in ipairs(workspace:GetDescendants()) do
 if obj:IsA("SurfaceGui") then addBackFace(obj) end
end
cleanIntrusiveGeometry(workspace)

workspace.DescendantAdded:Connect(function(obj)
 task.defer(function()
  if not obj.Parent then return end
  if obj:IsA("SurfaceGui") then addBackFace(obj) end
  if obj:IsA("BasePart") then cleanIntrusiveGeometry(obj.Parent) end
 end)
end)

print("[BBYA] Visual readability v1.1 loaded: signs contained, sightlines cleared")
