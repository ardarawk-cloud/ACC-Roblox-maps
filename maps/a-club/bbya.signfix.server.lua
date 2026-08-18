-- BBYA Social Hub sign orientation hotfix v1.0
-- Makes every SurfaceGui-backed venue sign readable from both sides.
local function oppositeFace(face)
 if face == Enum.NormalId.Front then return Enum.NormalId.Back end
 if face == Enum.NormalId.Back then return Enum.NormalId.Front end
 if face == Enum.NormalId.Left then return Enum.NormalId.Right end
 if face == Enum.NormalId.Right then return Enum.NormalId.Left end
 if face == Enum.NormalId.Top then return Enum.NormalId.Bottom end
 if face == Enum.NormalId.Bottom then return Enum.NormalId.Top end
 return nil
end

local function addBackFace(gui)
 if not gui:IsA("SurfaceGui") then return end
 local parent = gui.Parent
 if not parent or not parent:IsA("BasePart") then return end
 if gui:GetAttribute("BBYADoubleSided") then return end

 local opposite = oppositeFace(gui.Face)
 if not opposite then return end

 -- Do not duplicate if a matching BBYA back face already exists.
 for _,child in ipairs(parent:GetChildren()) do
  if child:IsA("SurfaceGui") and child ~= gui and child.Face == opposite and child:GetAttribute("BBYASignMirror") then
   gui:SetAttribute("BBYADoubleSided", true)
   return
  end
 end

 local back = gui:Clone()
 back.Name = gui.Name .. "_ReadableBack"
 back.Face = opposite
 back:SetAttribute("BBYASignMirror", true)
 back:SetAttribute("BBYADoubleSided", true)
 back.Parent = parent
 gui:SetAttribute("BBYADoubleSided", true)
end

local function scan(root)
 for _,obj in ipairs(root:GetDescendants()) do
  if obj:IsA("SurfaceGui") then
   addBackFace(obj)
  end
 end
end

scan(workspace)

workspace.DescendantAdded:Connect(function(obj)
 if obj:IsA("SurfaceGui") then
  task.defer(function()
   if obj.Parent then addBackFace(obj) end
  end)
 end
end)

print("[BBYA] Sign orientation hotfix loaded: venue signs are readable from front and back")
