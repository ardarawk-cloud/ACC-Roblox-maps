-- BBYA SOCIAL HUB — LEAD DANCE SYNC SERVER v1
-- Only managed role LEAD can drive crowd sync. One active LEAD sync session per server.
-- Carry participants are excluded so dance sync cannot break carry state.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder");remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local social=remotes:FindFirstChild("SocialHangout") or Instance.new("RemoteEvent");social.Name="SocialHangout";social.Parent=remotes

local SYNC_RADIUS=45
local active=nil
local sequence=0
local cooldown={}

local function isLead(p)return p and p:GetAttribute("BBYAHasLeadRole")==true and p:GetAttribute("BBYAManagedRole")=="LEAD" end
local function root(p)local c=p and p.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local r=c and c:FindFirstChild("HumanoidRootPart");if h and h.Health>0 and r then return r end end
local function carryBusy(p)return p and (p:GetAttribute("BBYACarryingUserId")~=nil or p:GetAttribute("BBYACarriedByUserId")~=nil) end
local function validAnimation(value)
 local s=tostring(value or "");local n=s:match("(%d+)");n=tonumber(n);if not n or n<=0 then return nil end;return tostring(math.floor(n))
end
local function followerSet(leader)
 local lr=root(leader);local out={};if not lr then return out end
 for _,p in ipairs(Players:GetPlayers()) do
  if p~=leader and not carryBusy(p) then local pr=root(p);if pr and (pr.Position-lr.Position).Magnitude<=SYNC_RADIUS then out[p.UserId]=p end end
 end
 return out
end
local function fireStop(state,reason)
 if not state then return end
 for uid in pairs(state.followers or {}) do local p=Players:GetPlayerByUserId(uid);if p then social:FireClient(p,"leadSyncStop",{leaderUserId=state.leaderUserId,reason=reason or "stopped",sequence=state.sequence}) end end
 local leader=Players:GetPlayerByUserId(state.leaderUserId);if leader then social:FireClient(leader,"leadSyncStatus",{active=false,count=0,message="SYNC OFF"}) end
end
local function stopActive(reason)
 local old=active;active=nil;if old then fireStop(old,reason) end
end
local function broadcastDance(leader,payload,isStart)
 if not isLead(leader) or carryBusy(leader) then return end
 local now=os.clock();if now-(cooldown[leader.UserId] or 0)<.08 then return end;cooldown[leader.UserId]=now
 local animId=validAnimation(payload and payload.animationId);if not animId then social:FireClient(leader,"leadSyncStatus",{active=active~=nil,message="PLAY A DANCE FIRST"});return end
 if active and active.leaderUserId~=leader.UserId then stopActive("new_lead") end
 sequence+=1
 local newFollowers=followerSet(leader)
 if active and active.leaderUserId==leader.UserId then
  for uid in pairs(active.followers) do if not newFollowers[uid] then local p=Players:GetPlayerByUserId(uid);if p then social:FireClient(p,"leadSyncStop",{leaderUserId=leader.UserId,reason="out_of_range",sequence=sequence}) end end end
 end
 active={leaderUserId=leader.UserId,followers={},animationId=animId,sequence=sequence}
 local tp=math.max(0,tonumber(payload and payload.timePosition) or 0)
 local serverTime=Workspace:GetServerTimeNow()
 for uid,p in pairs(newFollowers) do
  active.followers[uid]=true
  social:FireClient(p,"leadSyncDance",{leaderUserId=leader.UserId,leaderName=leader.DisplayName,animationId=animId,timePosition=tp,serverTime=serverTime,sequence=sequence})
 end
 social:FireClient(leader,"leadSyncStatus",{active=true,count=(function()local n=0;for _ in pairs(active.followers) do n+=1 end;return n end)(),message=(isStart and "SYNC ON" or "SYNC UPDATED")})
end

social.OnServerEvent:Connect(function(p,action,payload)
 if action=="leadSyncStart" then broadcastDance(p,type(payload)=="table" and payload or {},true)
 elseif action=="leadSyncDance" then if active and active.leaderUserId==p.UserId then broadcastDance(p,type(payload)=="table" and payload or {},false) end
 elseif action=="leadSyncStop" then if active and active.leaderUserId==p.UserId and isLead(p) then stopActive("lead_stop") end end
end)

local function wire(p)
 p:GetAttributeChangedSignal("BBYAManagedRole"):Connect(function()if active and active.leaderUserId==p.UserId and not isLead(p) then stopActive("role_removed") end end)
 p:GetAttributeChangedSignal("BBYAHasLeadRole"):Connect(function()if active and active.leaderUserId==p.UserId and not isLead(p) then stopActive("role_removed") end end)
end
for _,p in ipairs(Players:GetPlayers()) do wire(p) end
Players.PlayerAdded:Connect(wire)
Players.PlayerRemoving:Connect(function(p)cooldown[p.UserId]=nil;if active and active.leaderUserId==p.UserId then stopActive("lead_left") elseif active then active.followers[p.UserId]=nil end end)

game:BindToClose(function()stopActive("shutdown")end)
print("[BBYA] LEAD Dance Sync server v1 online: LEAD-only / 45-stud crowd / carry-safe")
