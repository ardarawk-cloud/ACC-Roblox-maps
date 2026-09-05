-- BBYA SOCIAL HUB — AFK STATUS AUTHORITY v2
-- One AFK authority for automatic idle status + manual PARTY STUFF AFK SIGN.
-- Manual sign is a lightweight left-hand prop and never changes Humanoid movement, animations, dance, carry, tools, or camera.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("AFKStatus")
if remote and not remote:IsA("RemoteEvent") then remote:Destroy();remote=nil end
if not remote then remote=Instance.new("RemoteEvent");remote.Name="AFKStatus";remote.Parent=remotes end

local lastRequest={}
local SIGN_NAME="BBYAAFKSign"
local GRIP_NAME="BBYAAFKSignGrip"

local function clearTag(character)
 local head=character and character:FindFirstChild("Head")
 local tag=head and head:FindFirstChild("BBYAAFKTag")
 if tag then tag:Destroy() end
end

local function clearSign(character)
 if not character then return end
 local old=character:FindFirstChild(SIGN_NAME)
 if old then old:Destroy() end
 for _,handName in ipairs({"LeftHand","Left Arm","LeftLowerArm"}) do
  local hand=character:FindFirstChild(handName)
  local grip=hand and hand:FindFirstChild(GRIP_NAME)
  if grip then grip:Destroy() end
 end
end

local function leftHand(character)
 return character and (character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftLowerArm"))
end

local function part(parent,name,size,color,material)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.Color=color;p.Material=material or Enum.Material.Metal
 p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.CastShadow=false
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
 return p
end

local function weld(root,p,offset)
 p.CFrame=root.CFrame*offset
 local w=Instance.new("WeldConstraint");w.Part0=root;w.Part1=p;w.Parent=p
end

local function signFace(board,face)
 local sg=Instance.new("SurfaceGui");sg.Face=face;sg.AlwaysOnTop=false;sg.LightInfluence=.05;sg.PixelsPerStud=70;sg.Parent=board
 local bg=Instance.new("Frame");bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=Color3.fromRGB(15,15,19);bg.BackgroundTransparency=.08;bg.BorderSizePixel=0;bg.Parent=sg
 local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(235,184,74);stroke.Thickness=2;stroke.Transparency=.08;stroke.Parent=bg
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text="AFK";text.TextColor3=Color3.fromRGB(247,229,191);text.TextStrokeTransparency=.72;text.Font=Enum.Font.GothamBlack;text.TextScaled=true;text.Parent=bg
 local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(.12,0);pad.PaddingRight=UDim.new(.12,0);pad.PaddingTop=UDim.new(.12,0);pad.PaddingBottom=UDim.new(.12,0);pad.Parent=text
end

local function buildSign(player)
 local character=player.Character
 local hum=character and character:FindFirstChildOfClass("Humanoid")
 local hand=leftHand(character)
 if not character or not hum or hum.Health<=0 or not hand or not hand:IsA("BasePart") then return false end
 clearSign(character)
 local model=Instance.new("Model");model.Name=SIGN_NAME;model:SetAttribute("BBYAAFKManualSign",true);model.Parent=character
 local handle=part(model,"Handle",Vector3.new(.14,2.15,.14),Color3.fromRGB(93,76,55),Enum.Material.Wood)
 local board=part(model,"Board",Vector3.new(2.55,1.35,.12),Color3.fromRGB(22,22,27),Enum.Material.SmoothPlastic)
 weld(handle,board,CFrame.new(0,1.43,0))
 signFace(board,Enum.NormalId.Front);signFace(board,Enum.NormalId.Back)
 local offset=CFrame.new(-.12,-.86,-.18)*CFrame.Angles(0,0,math.rad(-7))
 handle.CFrame=hand.CFrame*offset
 local grip=Instance.new("Motor6D");grip.Name=GRIP_NAME;grip.Part0=hand;grip.Part1=handle;grip.C0=offset;grip.C1=CFrame.new();grip.Parent=hand
 return true
end

local function applyTag(player)
 local character=player.Character
 local head=character and character:FindFirstChild("Head")
 if not head then return end
 clearTag(character)
 if player:GetAttribute("BBYAAFK")~=true then return end
 local gui=Instance.new("BillboardGui")
 gui.Name="BBYAAFKTag";gui.Adornee=head;gui.Size=UDim2.fromOffset(92,24);gui.StudsOffset=Vector3.new(0,3.55,0)
 gui.AlwaysOnTop=true;gui.MaxDistance=70;gui.LightInfluence=0;gui.Parent=head
 local bg=Instance.new("Frame");bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=Color3.fromRGB(13,13,18);bg.BackgroundTransparency=.28;bg.BorderSizePixel=0;bg.Parent=gui
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=bg
 local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(235,184,74);stroke.Transparency=.28;stroke.Thickness=1;stroke.Parent=bg
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text="AFK";text.TextColor3=Color3.fromRGB(246,225,184);text.Font=Enum.Font.GothamBold;text.TextSize=11;text.Parent=bg
end

local function applyVisuals(player)
 applyTag(player)
 if player:GetAttribute("BBYAAFKManual")==true then buildSign(player) else clearSign(player.Character) end
end

local function setAutomatic(player,value)
 if player:GetAttribute("BBYAAFKManual")==true then return end
 value=value==true
 player:SetAttribute("BBYAAFK",value)
 player:SetAttribute("BBYAAFKSince",value and os.time() or 0)
 applyVisuals(player)
end

local function setManual(player,value)
 value=value==true
 player:SetAttribute("BBYAAFKManual",value)
 player:SetAttribute("BBYAAFK",value)
 player:SetAttribute("BBYAAFKSince",value and os.time() or 0)
 applyVisuals(player)
 remote:FireClient(player,"manualState",{active=value})
end

remote.OnServerEvent:Connect(function(player,action)
 local now=os.clock()
 if now-(lastRequest[player] or 0)<.16 then return end
 lastRequest[player]=now
 if type(action)=="boolean" then setAutomatic(player,action);return end
 action=tostring(action or "")
 if action=="manualToggle" then setManual(player,player:GetAttribute("BBYAAFKManual")~=true)
 elseif action=="manualOff" then setManual(player,false)
 end
end)

local function wire(player)
 player:SetAttribute("BBYAAFK",false);player:SetAttribute("BBYAAFKSince",0);player:SetAttribute("BBYAAFKManual",false)
 player.CharacterAdded:Connect(function(character)
  character:WaitForChild("Head",10);task.delay(.35,function()if player.Parent then applyVisuals(player) end end)
 end)
 player:GetAttributeChangedSignal("BBYAAFK"):Connect(function()task.defer(function()if player.Parent then applyTag(player) end end)end)
 player:GetAttributeChangedSignal("BBYAAFKManual"):Connect(function()task.defer(function()if player.Parent then applyVisuals(player) end end)end)
end

for _,player in ipairs(Players:GetPlayers()) do wire(player) end
Players.PlayerAdded:Connect(wire)
Players.PlayerRemoving:Connect(function(player)lastRequest[player]=nil end)

print("[BBYA] AFK authority v2 online: auto idle + manual held AFK SIGN / movement-animation-safe")