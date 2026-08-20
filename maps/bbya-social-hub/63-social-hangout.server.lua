-- BBYA SOCIAL HUB — SOCIAL HANGOUT SERVER v1
-- Replaces floor dance prompts with modern social menu + consent-based carry.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes"
remotes.Parent=ReplicatedStorage

local social=remotes:FindFirstChild("SocialHangout") or Instance.new("RemoteEvent")
social.Name="SocialHangout"
social.Parent=remotes

local MAX_DISTANCE=12
local REQUEST_TTL=15
local pendingByCarrier={}
local pendingByTarget={}
local activeByCarrier={}
local activeByTarget={}
local requestCooldown={}

local function characterState(plr)
 local ch=plr and plr.Character
 if not ch then return end
 local hum=ch:FindFirstChildOfClass("Humanoid")
 local hrp=ch:FindFirstChild("HumanoidRootPart")
 if not hum or not hrp or hum.Health<=0 then return end
 return ch,hum,hrp
end

local function near(a,b,maxDist)
 local _,_,ar=characterState(a)
 local _,_,br=characterState(b)
 return ar and br and (ar.Position-br.Position).Magnitude<=(maxDist or MAX_DISTANCE)
end

local function fire(plr,kind,data)
 if plr and plr.Parent==Players then social:FireClient(plr,kind,data or {}) end
end

local function clearPendingForCarrier(userId,reason)
 local req=pendingByCarrier[userId]
 if not req then return end
 pendingByCarrier[userId]=nil
 if pendingByTarget[req.targetUserId]==userId then pendingByTarget[req.targetUserId]=nil end
 local carrier=Players:GetPlayerByUserId(userId)
 local target=Players:GetPlayerByUserId(req.targetUserId)
 if carrier and reason then fire(carrier,"requestClosed",{reason=reason}) end
 if target and reason=="cancelled" then fire(target,"requestClosed",{reason="cancelled"}) end
end

local function restorePair(state,reason)
 if not state or state.closed then return end
 state.closed=true
 local carrier=state.carrier
 local target=state.target
 if state.weld then state.weld:Destroy() end
 if state.connections then
  for _,c in ipairs(state.connections) do pcall(function()c:Disconnect()end) end
 end
 if state.partState then
  for part,old in pairs(state.partState) do
   if part and part.Parent then
    part.CanCollide=old.CanCollide
    part.Massless=old.Massless
   end
  end
 end
 local _,th,tr=characterState(target)
 if th then
  th.PlatformStand=state.platformStand or false
  th.AutoRotate=(state.autoRotate~=false)
 end
 if carrier then
  activeByCarrier[carrier.UserId]=nil
  carrier:SetAttribute("BBYACarryingUserId",nil)
 end
 if target then
  activeByTarget[target.UserId]=nil
  target:SetAttribute("BBYACarriedByUserId",nil)
 end
 if carrier and target and tr then
  local _,_,cr=characterState(carrier)
  if cr then
   tr.CFrame=cr.CFrame*CFrame.new(2.4,0,0)
   tr.AssemblyLinearVelocity=Vector3.zero
   tr.AssemblyAngularVelocity=Vector3.zero
  end
 end
 fire(carrier,"carryState",{active=false,reason=reason or "dropped"})
 fire(target,"carryState",{active=false,reason=reason or "dropped"})
end

local function dropPlayer(plr,reason)
 if not plr then return end
 local state=activeByCarrier[plr.UserId] or activeByTarget[plr.UserId]
 if state then restorePair(state,reason) end
end

local function startCarry(carrier,target)
 if not carrier or not target or carrier==target then return false,"invalid" end
 if activeByCarrier[carrier.UserId] or activeByTarget[carrier.UserId] or activeByCarrier[target.UserId] or activeByTarget[target.UserId] then return false,"busy" end
 if not near(carrier,target,MAX_DISTANCE) then return false,"too_far" end
 local _,ch,cr=characterState(carrier)
 local targetChar,th,tr=characterState(target)
 if not ch or not targetChar then return false,"character" end

 local state={carrier=carrier,target=target,connections={},partState={},platformStand=th.PlatformStand,autoRotate=th.AutoRotate}
 for _,d in ipairs(targetChar:GetDescendants()) do
  if d:IsA("BasePart") then
   state.partState[d]={CanCollide=d.CanCollide,Massless=d.Massless}
   d.CanCollide=false
   d.Massless=true
  end
 end
 th.Sit=false
 th.AutoRotate=false
 th.PlatformStand=true
 tr.AssemblyLinearVelocity=Vector3.zero
 tr.AssemblyAngularVelocity=Vector3.zero
 -- Behind the carrier, same facing direction; WeldConstraint preserves this offset.
 tr.CFrame=cr.CFrame*CFrame.new(0,1.35,1.55)
 local weld=Instance.new("WeldConstraint")
 weld.Name="BBYACarryWeld"
 weld.Part0=cr
 weld.Part1=tr
 weld.Parent=cr
 state.weld=weld

 activeByCarrier[carrier.UserId]=state
 activeByTarget[target.UserId]=state
 carrier:SetAttribute("BBYACarryingUserId",target.UserId)
 target:SetAttribute("BBYACarriedByUserId",carrier.UserId)

 table.insert(state.connections,ch.Died:Connect(function()restorePair(state,"carrier_down")end))
 table.insert(state.connections,th.Died:Connect(function()restorePair(state,"target_down")end))

 fire(carrier,"carryState",{active=true,role="carrier",otherUserId=target.UserId,otherName=target.DisplayName})
 fire(target,"carryState",{active=true,role="carried",otherUserId=carrier.UserId,otherName=carrier.DisplayName})
 return true
end

-- Remove the old three giant world-space Dance prompts once Floor1Features creates them.
task.spawn(function()
 local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
 if not root then return end
 for _=1,80 do
  local runtime=root:FindFirstChild("Floor1Features")
  if runtime then
   local removed=0
   for i=1,3 do
    local old=runtime:FindFirstChild("DanceInteract"..i)
    if old then old:Destroy();removed+=1 end
   end
   if removed>0 then print("[BBYA Social] removed legacy dance prompts: "..removed) end
   local any=false
   for i=1,3 do if runtime:FindFirstChild("DanceInteract"..i) then any=true end end
   if not any then break end
  end
  task.wait(.25)
 end
end)

social.OnServerEvent:Connect(function(plr,action,arg)
 if action=="requestCarry" then
  local now=os.clock()
  if now-(requestCooldown[plr.UserId] or 0)<2.5 then return end
  requestCooldown[plr.UserId]=now
  local targetId=tonumber(arg)
  local target=targetId and Players:GetPlayerByUserId(targetId)
  if not target or target==plr then fire(plr,"requestClosed",{reason="invalid"});return end
  if activeByCarrier[plr.UserId] or activeByTarget[plr.UserId] or activeByCarrier[target.UserId] or activeByTarget[target.UserId] then
   fire(plr,"requestClosed",{reason="busy"});return
  end
  if not near(plr,target,MAX_DISTANCE) then fire(plr,"requestClosed",{reason="too_far"});return end
  if pendingByTarget[target.UserId] and pendingByTarget[target.UserId]~=plr.UserId then
   fire(plr,"requestClosed",{reason="target_pending"});return
  end
  clearPendingForCarrier(plr.UserId)
  pendingByCarrier[plr.UserId]={targetUserId=target.UserId,expires=now+REQUEST_TTL}
  pendingByTarget[target.UserId]=plr.UserId
  fire(plr,"requestSent",{targetUserId=target.UserId,targetName=target.DisplayName})
  fire(target,"carryRequest",{carrierUserId=plr.UserId,carrierName=plr.DisplayName})
  task.delay(REQUEST_TTL,function()
   local req=pendingByCarrier[plr.UserId]
   if req and req.targetUserId==target.UserId and os.clock()>=req.expires then clearPendingForCarrier(plr.UserId,"expired") end
  end)
 elseif action=="acceptCarry" then
  local carrierId=tonumber(arg)
  local req=carrierId and pendingByCarrier[carrierId]
  if not req or req.targetUserId~=plr.UserId or req.expires<os.clock() then
   fire(plr,"requestClosed",{reason="expired"});return
  end
  local carrier=Players:GetPlayerByUserId(carrierId)
  clearPendingForCarrier(carrierId)
  if not carrier then fire(plr,"requestClosed",{reason="gone"});return end
  local ok,reason=startCarry(carrier,plr)
  if not ok then
   fire(carrier,"requestClosed",{reason=reason})
   fire(plr,"requestClosed",{reason=reason})
  end
 elseif action=="declineCarry" then
  local carrierId=tonumber(arg)
  local req=carrierId and pendingByCarrier[carrierId]
  if req and req.targetUserId==plr.UserId then
   clearPendingForCarrier(carrierId)
   local carrier=Players:GetPlayerByUserId(carrierId)
   fire(carrier,"requestClosed",{reason="declined",targetName=plr.DisplayName})
  end
 elseif action=="cancelCarryRequest" then
  clearPendingForCarrier(plr.UserId,"cancelled")
 elseif action=="dropCarry" then
  dropPlayer(plr,"dropped")
 end
end)

Players.PlayerRemoving:Connect(function(plr)
 clearPendingForCarrier(plr.UserId)
 local carrierId=pendingByTarget[plr.UserId]
 if carrierId then clearPendingForCarrier(carrierId,"gone") end
 dropPlayer(plr,"left")
end)

Players.PlayerAdded:Connect(function(plr)
 plr.CharacterAdded:Connect(function()
  task.defer(function()dropPlayer(plr,"respawn")end)
 end)
end)
for _,plr in ipairs(Players:GetPlayers()) do
 plr.CharacterAdded:Connect(function()task.defer(function()dropPlayer(plr,"respawn")end)end)
end

print("[BBYA] Social Hangout server v1 online: emote menu support + consent carry")
