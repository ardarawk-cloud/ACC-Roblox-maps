-- BBYA SOCIAL HUB — LEAD DANCE SYNC SERVER v2
-- Only managed role LEAD can drive crowd sync. One active LEAD sync session per server.
-- Adds server-clamped dance speed replication; carry participants remain excluded.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder");remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local social=remotes:FindFirstChild("SocialHangout") or Instance.new("RemoteEvent");social.Name="SocialHangout";social.Parent=remotes

local SYNC_RADIUS=45
local MIN_SPEED=.50
local MAX_SPEED=1.75
local active=nil
local sequence=0
local cooldown={}

local function isLead(p)return p and p:GetAttribute("BBYAHasLeadRole")==true and p:GetAttribute("BBYAManagedRole")=="LEAD" end
local function root(p)local c=p and p.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local r=c and c:FindFirstChild("HumanoidRootPart");if h and h.Health>0 and r then return r end end
local function carryBusy(p)return p and (p:GetAttribute("BBYACarryingUserId")~=nil or p:GetAttribute("BBYACarriedByUserId")~=nil) end
local function validAnimation(value)local s=tostring(value or "");local n=s:match("(%d+)");n=tonumber(n);if not n or n<=0 then return nil end;return tostring(math.floor(n))end
local function clampSpeed(value)return math.clamp(tonumber(value) or 1,MIN_SPEED,MAX_SPEED)end
local function followerSet(leader)
 local lr=root(leader);local out={};if not lr then return out end
 for _,p in ipairs(Players:GetPlayers()) do if p~=leader and not carryBusy(p) then local pr=root(p);if pr and (pr.Position-lr.Position).Magnitude<=SYNC_RADIUS then out[p.UserId]=p end end end
 return out
end
local function fireStop(state,reason)
 if not state then return end
 for uid in pairs(state.followers or {}) do local p=Players:GetPlayerByUserId(uid);if p then social:FireClient(p,"leadSyncStop",{leaderUserId=state.leaderUserId,reason=reason or "stopped",sequence=state.sequence}) end end
 local leader=Players:GetPlayerByUserId(state.leaderUserId);if leader then social:FireClient(leader,"leadSyncStatus",{active=false,count=0,message="SYNC OFF",speed=state.speed or 1}) end
end
local function stopActive(reason)local old=active;active=nil;if old then fireStop(old,reason) end end
local function countFollowers(state)local n=0;for _ in pairs(state and state.followers or {}) do n+=1 end;return n end

local function broadcastDance(leader,payload,isStart)
 if not isLead(leader) or carryBusy(leader) then return end
 local now=os.clock();if now-(cooldown[leader.UserId] or 0)<.08 then return end;cooldown[leader.UserId]=now
 local animId=validAnimation(payload and payload.animationId);if not animId then social:FireClient(leader,"leadSyncStatus",{active=active~=nil,message="PLAY A DANCE FIRST",speed=active and active.speed or clampSpeed(payload and payload.speed)});return end
 if active and active.leaderUserId~=leader.UserId then stopActive("new_lead") end
 sequence+=1
 local newFollowers=followerSet(leader)
 if active and active.leaderUserId==leader.UserId then for uid in pairs(active.followers) do if not newFollowers[uid] then local p=Players:GetPlayerByUserId(uid);if p then social:FireClient(p,"leadSyncStop",{leaderUserId=leader.UserId,reason="out_of_range",sequence=sequence}) end end end end
 local speed=clampSpeed(payload and payload.speed or (active and active.speed) or 1)
 active={leaderUserId=leader.UserId,followers={},animationId=animId,sequence=sequence,speed=speed}
 local tp=math.max(0,tonumber(payload and payload.timePosition) or 0);local serverTime=Workspace:GetServerTimeNow()
 for uid,p in pairs(newFollowers) do active.followers[uid]=true;social:FireClient(p,"leadSyncDance",{leaderUserId=leader.UserId,leaderName=leader.DisplayName,animationId=animId,timePosition=tp,serverTime=serverTime,sequence=sequence,speed=speed}) end
 social:FireClient(leader,"leadSyncStatus",{active=true,count=countFollowers(active),message=(isStart and "SYNC ON" or "SYNC UPDATED"),speed=speed})
end

local function setSpeed(leader,value)
 if not active or active.leaderUserId~=leader.UserId or not isLead(leader) then return end
 active.speed=clampSpeed(value);sequence+=1;active.sequence=sequence
 for uid in pairs(active.followers) do local p=Players:GetPlayerByUserId(uid);if p then social:FireClient(p,"leadSyncSpeed",{leaderUserId=leader.UserId,speed=active.speed,sequence=sequence}) end end
 social:FireClient(leader,"leadSyncStatus",{active=true,count=countFollowers(active),message="SPEED "..string.format("%.2fx",active.speed),speed=active.speed})
end

social.OnServerEvent:Connect(function(p,action,payload)
 if action=="leadSyncStart" then broadcastDance(p,type(payload)=="table" and payload or {},true)
 elseif action=="leadSyncDance" then if active and active.leaderUserId==p.UserId then broadcastDance(p,type(payload)=="table" and payload or {},false) end
 elseif action=="leadSyncSpeed" then setSpeed(p,type(payload)=="table" and payload.speed or payload)
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
print("[BBYA] LEAD Dance Sync server v2 online: LEAD-only / speed 0.50x-1.75x / carry-safe")