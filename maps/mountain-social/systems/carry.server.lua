local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local remotes=RS:FindFirstChild("ACC_MountainRemotes")or Instance.new("Folder");remotes.Name="ACC_MountainRemotes";remotes.Parent=RS
local remote=remotes:FindFirstChild("Carry")or Instance.new("RemoteEvent");remote.Name="Carry";remote.Parent=remotes
local active={};local carriedBy={};local cooldown={}
local function clear(carrier)local d=active[carrier];if not d then return end;if d.weld and d.weld.Parent then d.weld:Destroy()end;if d.targetHumanoid and d.targetHumanoid.Parent then d.targetHumanoid.PlatformStand=false;d.targetHumanoid.AutoRotate=true end;if d.target then carriedBy[d.target]=nil end;active[carrier]=nil end
local function validChar(p)local c=p.Character;if not c then return end;local h=c:FindFirstChildOfClass("Humanoid");local r=c:FindFirstChild("HumanoidRootPart");if not h or not r or h.Health<=0 then return end;return c,h,r end
remote.OnServerEvent:Connect(function(player,action,targetUserId)
 if os.clock()<(cooldown[player]or 0)then return end;cooldown[player]=os.clock()+.4
 if action=="drop" then clear(player);return end;if action~="carry"then return end
 if active[player]or carriedBy[player]then return end
 local target=Players:GetPlayerByUserId(tonumber(targetUserId)or 0);if not target or target==player or active[target]or carriedBy[target]then return end
 local _,h1,r1=validChar(player);local _,h2,r2=validChar(target);if not r1 or not r2 then return end
 if (r1.Position-r2.Position).Magnitude>10 then return end
 h2.PlatformStand=true;h2.AutoRotate=false;r2.CFrame=r1.CFrame*CFrame.new(1.4,.8,1.2)
 local weld=Instance.new("WeldConstraint");weld.Part0=r1;weld.Part1=r2;weld.Parent=r1
 active[player]={weld=weld,targetHumanoid=h2,target=target};carriedBy[target]=player
 h1.Died:Once(function()clear(player)end);h2.Died:Once(function()clear(player)end)
end)
Players.PlayerRemoving:Connect(function(p)if active[p]then clear(p)end;local carrier=carriedBy[p];if carrier then clear(carrier)end;cooldown[p]=nil end)
workspace:SetAttribute("ACC_CarrySystem","v1.9")