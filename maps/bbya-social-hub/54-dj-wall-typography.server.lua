-- BBYA SOCIAL HUB — DJ WALL TYPOGRAPHY v1
-- Presentation-only layer: large adaptive premium type for paid wall messages.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then return end
local system=root:WaitForChild("DJWallMessageSystem",20)
if not system then return end
local screen=system:WaitForChild("PrestigeLED",20)
if not screen then return end

local function tuneGui(gui)
 if not gui or not gui:IsA("SurfaceGui") then return end
 local messageMode=gui:FindFirstChild("MessageMode",true)
 if not messageMode then return end
 local mainText=nil
 local category=nil
 local from=nil
 local footer=nil
 for _,obj in ipairs(messageMode:GetDescendants()) do
  if obj:IsA("TextLabel") then
   if tostring(obj.Text):find("BBYA LIVE MESSAGE",1,true) then category=obj
   elseif tostring(obj.Text):find("MAKE THE NIGHT YOURS",1,true) then footer=obj
   elseif obj.Text=="" and obj.Size.Y.Scale>=.30 then mainText=obj
   elseif obj.Text=="" and obj.Position.Y.Scale>=.60 then from=obj end
  end
 end
 if mainText then
  local premium=Enum.Font.Montserrat or Enum.Font.GothamBlack
  mainText.Font=premium
  mainText.TextScaled=true
  mainText.TextWrapped=true
  mainText.TextXAlignment=Enum.TextXAlignment.Center
  mainText.TextYAlignment=Enum.TextYAlignment.Center
  mainText.Position=UDim2.fromScale(.06,.22)
  mainText.Size=UDim2.fromScale(.88,.43)
  local old=mainText:FindFirstChildOfClass("UITextSizeConstraint")
  if old then old:Destroy() end
  local limit=Instance.new("UITextSizeConstraint")
  limit.MinTextSize=42
  limit.MaxTextSize=170
  limit.Parent=mainText
  local s=mainText:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
  s.Color=Color3.fromRGB(28,12,27);s.Thickness=2;s.Transparency=.25;s.Parent=mainText
 end
 if category then category.Font=Enum.Font.GothamBlack;category.TextSize=34;category.Position=UDim2.fromScale(.05,.055);category.Size=UDim2.fromScale(.90,.10) end
 if from then from.Font=Enum.Font.GothamBold;from.TextSize=27;from.Position=UDim2.fromScale(.08,.70);from.Size=UDim2.fromScale(.84,.09) end
 if footer then footer.TextSize=18;footer.Position=UDim2.fromScale(.08,.86);footer.Size=UDim2.fromScale(.84,.055) end
end

task.wait(.5)
tuneGui(screen:FindFirstChild("DJWallUI"))
tuneGui(screen:FindFirstChild("DJWallUI_OppositeFace"))
print("[BBYA] DJ Wall typography v1 online: adaptive premium large type")
