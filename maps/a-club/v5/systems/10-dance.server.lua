-- [SYS-DANCE] DANCE / EMOTE / SYNC
local allowed={dance=true,dance2=true,dance3=true,wave=true,cheer=true,laugh=true,point=true}
local lastEmote={}
local lastAction={}
local FXRemote=sysRemote("FX")

local function ready(p,key,sec)
 local k=p.UserId..":"..key;local now=os.clock();if lastAction[k] and now-lastAction[k]<sec then return false end;lastAction[k]=now;return true
end
local function playEmote(p,name)
 local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if not h then return false end
 if name=="stop" then for _,tr in ipairs(h:GetPlayingAnimationTracks()) do tr:Stop(.15) end;lastEmote[p.UserId]=nil;return true end
 if not allowed[name] then return false end
 lastEmote[p.UserId]=name
 local ok=pcall(function() h:PlayEmote(name) end);return ok
end

DanceRemote.OnServerEvent:Connect(function(p,name)
 if typeof(name)~="string" or not ready(p,"dance",.14) then return end
 name=string.lower(name);if not (name=="stop" or allowed[name]) then return end
 playEmote(p,name)
end)

SyncRemote.OnServerEvent:Connect(function(p,targetId)
 if typeof(targetId)~="number" or not ready(p,"sync",.6) then return end
 local target=Players:GetPlayerByUserId(targetId);local a=p.Character and p.Character:FindFirstChild("HumanoidRootPart");local b=target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
 if not a or not b or (a.Position-b.Position).Magnitude>35 then NoticeRemote:FireClient(p,"No dancer nearby");return end
 local e=lastEmote[target.UserId];if e then playEmote(p,e);NoticeRemote:FireClient(p,"Synced with "..target.DisplayName) else NoticeRemote:FireClient(p,"That player is not dancing") end
end)

FXRemote.OnServerEvent:Connect(function(p,kind)
 if kind~="confetti" or not ready(p,"confetti",4) then return end
 local rootPart=p.Character and p.Character:FindFirstChild("HumanoidRootPart");if not rootPart then return end
 local Debris=game:GetService("Debris")
 for i=1,14 do
  local q=Instance.new("Part");q.Name="SYS-DANCE CONFETTI";q.Size=Vector3.new(.22,.22,.22);q.Material=Enum.Material.Neon;q.Color=Color3.fromHSV(i/14,.75,1);q.CanCollide=false;q.CanTouch=false;q.CFrame=rootPart.CFrame*CFrame.new(math.random(-3,3),math.random(3,7),math.random(-3,3));q.Parent=workspace;q.AssemblyLinearVelocity=Vector3.new(math.random(-8,8),math.random(10,18),math.random(-8,8));Debris:AddItem(q,2)
 end
end)
workspace:SetAttribute("BBYASystemDance","5.0")
