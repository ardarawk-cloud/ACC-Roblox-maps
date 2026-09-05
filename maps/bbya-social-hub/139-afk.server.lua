-- BBYA SOCIAL HUB — AFK STATUS AUTHORITY v1
-- Server-authoritative AFK attribute + lightweight overhead status.
-- Does not stop animations, emotes, dance, carry, tools, Humanoid movement, or character states.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("AFKStatus")
if remote and not remote:IsA("RemoteEvent") then remote:Destroy();remote=nil end
if not remote then remote=Instance.new("RemoteEvent");remote.Name="AFKStatus";remote.Parent=remotes end

local lastRequest={}

local function clearTag(character)
 local head=character and character:FindFirstChild("Head")
 local tag=head and head:FindFirstChild("BBYAAFKTag")
 if tag then tag:Destroy() end
end

local function applyTag(player)
 local character=player.Character
 local head=character and character:FindFirstChild("Head")
 if not head then return end
 clearTag(character)
 if player:GetAttribute("BBYAAFK")~=true then return end

 local gui=Instance.new("BillboardGui")
 gui.Name="BBYAAFKTag"
 gui.Adornee=head
 gui.Size=UDim2.fromOffset(92,24)
 gui.StudsOffset=Vector3.new(0,3.55,0)
 gui.AlwaysOnTop=true
 gui.MaxDistance=70
 gui.LightInfluence=0
 gui.Parent=head

 local bg=Instance.new("Frame")
 bg.Size=UDim2.fromScale(1,1)
 bg.BackgroundColor3=Color3.fromRGB(13,13,18)
 bg.BackgroundTransparency=.18
 bg.BorderSizePixel=0
 bg.Parent=gui
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,8);corner.Parent=bg
 local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(235,184,74);stroke.Transparency=.28;stroke.Thickness=1;stroke.Parent=bg

 local text=Instance.new("TextLabel")
 text.Size=UDim2.fromScale(1,1)
 text.BackgroundTransparency=1
 text.Text="AFK"
 text.TextColor3=Color3.fromRGB(246,225,184)
 text.Font=Enum.Font.GothamBold
 text.TextSize=11
 text.Parent=bg
end

local function setAfk(player,value)
 value=value==true
 if player:GetAttribute("BBYAAFK")==value then return end
 player:SetAttribute("BBYAAFK",value)
 player:SetAttribute("BBYAAFKSince",value and os.time() or 0)
 applyTag(player)
end

remote.OnServerEvent:Connect(function(player,value)
 local now=os.clock()
 if now-(lastRequest[player] or 0)<.20 then return end
 lastRequest[player]=now
 setAfk(player,value==true)
end)

local function wire(player)
 player:SetAttribute("BBYAAFK",false)
 player:SetAttribute("BBYAAFKSince",0)
 player.CharacterAdded:Connect(function(character)
  character:WaitForChild("Head",10)
  task.delay(.25,function()if player.Parent then applyTag(player) end end)
 end)
 player:GetAttributeChangedSignal("BBYAAFK"):Connect(function()task.defer(function()if player.Parent then applyTag(player) end end)end)
end

for _,player in ipairs(Players:GetPlayers()) do wire(player) end
Players.PlayerAdded:Connect(wire)
Players.PlayerRemoving:Connect(function(player)lastRequest[player]=nil end)

print("[BBYA] AFK status authority v1 online: status-only / emote-dance-carry safe")
