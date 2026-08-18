-- BBYA Social Rank progression hotfix
-- Rank combines social activity level with verified lifetime support.

local Players=game:GetService("Players")

local function rankFor(player)
 local level=player:GetAttribute("BBYALevel") or 1
 local donated=player:GetAttribute("TotalDonated") or 0

 -- Support + activity prestige ranks
 if level>=25 and donated>=1000 then return "ROYAL ELITE" end
 if level>=15 and donated>=500 then return "NIGHT ARISTOCRAT" end
 if level>=8 and donated>=100 then return "ARISTOCRAT" end
 -- Social activity ranks
 if level>=20 then return "NIGHT ICON" end
 if level>=8 then return "SOCIALITE" end
 if level>=3 then return "REGULAR" end
 return "NEWBIE"
end

local function refresh(player)
 local char=player.Character
 local head=char and char:FindFirstChild("Head")
 if not head then return end
 local tag=head:FindFirstChild("BBYATitleTag")
 if not tag then return end
 local label=tag:FindFirstChildOfClass("TextLabel")
 if not label then return end
 label.Text=rankFor(player)
 label.TextScaled=false
 label.TextSize=10
 tag.Size=UDim2.fromOffset(94,16)
 tag.StudsOffset=Vector3.new(0,2.55,0)
 tag.MaxDistance=30
end

local function hook(player)
 player:GetAttributeChangedSignal("BBYALevel"):Connect(function() refresh(player) end)
 player:GetAttributeChangedSignal("TotalDonated"):Connect(function() refresh(player) end)
 player.CharacterAdded:Connect(function() task.wait(2);refresh(player) end)
 task.defer(function() task.wait(2);refresh(player) end)
end
Players.PlayerAdded:Connect(hook)
for _,p in ipairs(Players:GetPlayers()) do hook(p) end

print("[BBYA] Social ranks: NEWBIE > REGULAR > SOCIALITE > ARISTOCRAT > NIGHT ARISTOCRAT > ROYAL ELITE")