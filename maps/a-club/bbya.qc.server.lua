-- BBYA QC hotfix v1.7: functional button fallbacks + compact overhead titles
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Debris=game:GetService("Debris")

local remotes=ReplicatedStorage:WaitForChild("BBYA_Remotes")
local TP=remotes:WaitForChild("Teleport")
local FX=remotes:WaitForChild("FX")
local Dance=remotes:WaitForChild("Dance")
local Notice=remotes:FindFirstChild("Notice")

local spots={
 DANCE={"Dance Floor",CFrame.new(0,5,0)},
 VIP={"Left VIP Platform",CFrame.new(-30,8,8)},
 BAR={"BBYA Bar",CFrame.new(-31,6,24)},
 PHOTO={"Photo Wall",CFrame.new(31,6,25)},
 CHILL={"Chill Table",CFrame.new(31,6,-30)},
 DJ={"DJ Booth",CFrame.new(0,7,-39)},
 POOL={"Rooftop Pool",CFrame.new(0,24,35)},
}

local function resolveSpot(name)
 local cfg=spots[name]
 if not cfg then return nil end
 local obj=workspace:FindFirstChild(cfg[1],true)
 if obj and obj:IsA("BasePart") then
  return obj.CFrame*CFrame.new(0,obj.Size.Y/2+4,0)
 end
 return cfg[2]
end

-- Extra teleport listener is intentionally idempotent: guarantees a visible move even if legacy handler fails.
TP.OnServerEvent:Connect(function(plr,spot)
 if typeof(spot)~="string" or not plr.Character then return end
 local cf=resolveSpot(string.upper(spot));if not cf then return end
 plr.Character:PivotTo(cf)
 if Notice then Notice:FireClient(plr,"Moved to "..string.upper(spot)) end
end)

-- Guaranteed visual FX fallback.
FX.OnServerEvent:Connect(function(plr,kind)
 if kind~="confetti" then return end
 local root=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart");if not root then return end
 for i=1,24 do
  local p=Instance.new("Part");p.Name="BBYA QC Confetti";p.Size=Vector3.new(.22,.4,.12);p.Material=Enum.Material.Neon;p.Color=Color3.fromHSV(math.random(),.75,1);p.CanCollide=false;p.CFrame=root.CFrame*CFrame.new(math.random(-5,5),math.random(3,8),math.random(-5,5));p.Parent=workspace;p.AssemblyLinearVelocity=Vector3.new(math.random(-12,12),math.random(12,24),math.random(-12,12));Debris:AddItem(p,2.5)
 end
 if Notice then Notice:FireClient(plr,"Confetti!") end
end)

-- Dance acknowledgement/fallback. Default Roblox emotes are requested server-side and user gets feedback.
Dance.OnServerEvent:Connect(function(plr,name)
 if typeof(name)~="string" then return end
 local hum=plr.Character and plr.Character:FindFirstChildOfClass("Humanoid");if not hum then return end
 local ok=pcall(function()hum:PlayEmote(string.lower(name))end)
 if Notice then Notice:FireClient(plr,ok and ("Emote: "..string.upper(name)) or "Emote unavailable on this avatar") end
end)

local function compactTitles(char)
 task.wait(.5)
 local head=char:FindFirstChild("Head");if not head then return end
 for _,g in ipairs(head:GetChildren())do
  if g:IsA("BillboardGui") and (g.Name=="BBYATitleTag" or g.Name=="BBYACustomTitleTag") then
   g.Size=UDim2.fromOffset(92,18);g.StudsOffset=Vector3.new(0,2.7,0);g.MaxDistance=28
   local t=g:FindFirstChildOfClass("TextLabel");if t then t.TextScaled=true;local c=t:FindFirstChildOfClass("UITextSizeConstraint")or Instance.new("UITextSizeConstraint");c.MinTextSize=7;c.MaxTextSize=13;c.Parent=t end
  end
 end
end
Players.PlayerAdded:Connect(function(p)p.CharacterAdded:Connect(compactTitles)end)
for _,p in ipairs(Players:GetPlayers())do if p.Character then task.spawn(compactTitles,p.Character)end;p.CharacterAdded:Connect(compactTitles)end

print("[BBYA QC] v1.7 hotfix loaded: teleport/FX/dance fallbacks + compact titles")