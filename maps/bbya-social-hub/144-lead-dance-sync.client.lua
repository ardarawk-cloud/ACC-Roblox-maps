-- BBYA SOCIAL HUB — LEAD DANCE SYNC CLIENT v1
-- LEAD gets a larger side Dance panel with SYNC / UNSYNC controls. Standard players keep the normal Dance panel.
-- Followers play only the synced dance track; carry participants are ignored.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local social=remotes and remotes:WaitForChild("SocialHangout",30)
if not social then return end

local leadSyncActive=false
local latestLeadTrack=nil
local syncTrack=nil
local originalPanel=nil
local bar=nil
local statusLabel=nil
local boundAnimator=nil
local animationConn=nil
local runningConn=nil

local function isLead()return player:GetAttribute("BBYAHasLeadRole")==true and player:GetAttribute("BBYAManagedRole")=="LEAD" end
local function carryBusy()return player:GetAttribute("BBYACarryingUserId")~=nil or player:GetAttribute("BBYACarriedByUserId")~=nil end
local function humanoid()local c=player.Character;return c and c:FindFirstChildOfClass("Humanoid") end
local function animator()local h=humanoid();return h and h:FindFirstChildOfClass("Animator") end
local function animationId(track)
 if not track then return nil end
 local ok,a=pcall(function()return track.Animation end);if not ok or not a then return nil end
 local ok2,id=pcall(function()return a.AnimationId end);if not ok2 then return nil end
 return tostring(id or ""):match("(%d+)")
end
local function validDanceTrack(track)
 if not track then return false end
 local okLoop,looped=pcall(function()return track.Looped end);if not okLoop or not looped then return false end
 local okPriority,p=pcall(function()return track.Priority end);if okPriority and p~=Enum.AnimationPriority.Action and p~=Enum.AnimationPriority.Action2 and p~=Enum.AnimationPriority.Action3 and p~=Enum.AnimationPriority.Action4 then return false end
 return animationId(track)~=nil
end
local function stopSyncTrack()
 if syncTrack then pcall(function()syncTrack:Stop(.12)end);pcall(function()syncTrack:Destroy()end);syncTrack=nil end
end
local function sendCurrent(kind)
 if not isLead() then return end
 local track=latestLeadTrack
 if not validDanceTrack(track) then if statusLabel then statusLabel.Text="PLAY A DANCE FIRST" end;return end
 social:FireServer(kind,{animationId=animationId(track),timePosition=tonumber(track.TimePosition) or 0})
end
local function bindAnimator()
 local a=animator();if not a or a==boundAnimator then return end
 if animationConn then animationConn:Disconnect();animationConn=nil end;if runningConn then runningConn:Disconnect();runningConn=nil end
 boundAnimator=a
 animationConn=a.AnimationPlayed:Connect(function(track)
  task.delay(.06,function()
   if track and track.Parent~=nil and validDanceTrack(track) then
    latestLeadTrack=track
    if leadSyncActive and isLead() then sendCurrent("leadSyncDance") end
   end
  end)
 end)
 local h=humanoid();if h then runningConn=h.Running:Connect(function(speed)if speed>.45 and leadSyncActive and isLead() then leadSyncActive=false;social:FireServer("leadSyncStop",{});if statusLabel then statusLabel.Text="SYNC OFF • MOVED" end end end) end
end

local function stopFollower(reason)
 stopSyncTrack()
end
local function playFollower(data)
 if isLead() or carryBusy() then return end
 local h=humanoid();if not h or h.Health<=0 then return end
 local a=animator();if not a then a=Instance.new("Animator");a.Parent=h end
 stopSyncTrack()
 local anim=Instance.new("Animation");anim.AnimationId="rbxassetid://"..tostring(data.animationId or "")
 local ok,track=pcall(function()return a:LoadAnimation(anim)end);anim:Destroy();if not ok or not track then return end
 syncTrack=track
 pcall(function()track.Priority=Enum.AnimationPriority.Action;track.Looped=true;track:Play(.10)end)
 task.delay(.08,function()
  if syncTrack~=track then return end
  local elapsed=0;pcall(function()elapsed=math.max(0,workspace:GetServerTimeNow()-(tonumber(data.serverTime) or workspace:GetServerTimeNow()))end)
  pcall(function()track.TimePosition=math.max(0,(tonumber(data.timePosition) or 0)+elapsed)end)
 end)
end

local function removeBar()
 if bar then bar:Destroy();bar=nil;statusLabel=nil end
end
local function applyPanelMode()
 local g=pg:FindFirstChild("BBYASocialHangoutUI");local p=g and g:FindFirstChild("DancePanel",true);if not p or not p:IsA("Frame") then return false end
 local catalog=p:FindFirstChild("BBYADanceCatalogV1")
 if not originalPanel or originalPanel.panel~=p then originalPanel={panel=p,pos=p.Position,size=p.Size,catalogPos=catalog and catalog.Position or nil,catalogSize=catalog and catalog.Size or nil} end
 removeBar()
 if isLead() then
  p.Position=UDim2.new(1,-96,0,48);p.Size=UDim2.fromOffset(330,550);p:SetAttribute("BBYALeadDancePanel",true)
  for _,d in ipairs(p:GetChildren()) do if d:IsA("TextLabel") and string.find(string.upper(d.Text or ""),"DANCE",1,true) then d.Text="LEAD DANCE";break end end
  if catalog then catalog.Position=UDim2.fromOffset(14,92);catalog.Size=UDim2.new(1,-28,1,-104) end
  bar=Instance.new("Frame");bar.Name="LeadSyncBar";bar.Position=UDim2.fromOffset(14,48);bar.Size=UDim2.new(1,-28,0,36);bar.BackgroundTransparency=1;bar.Parent=p
  local function b(txt,x,w,col)local q=Instance.new("TextButton");q.Text=txt;q.Position=UDim2.fromOffset(x,0);q.Size=UDim2.fromOffset(w,34);q.BackgroundColor3=col;q.BorderSizePixel=0;q.TextColor3=Color3.fromRGB(245,245,248);q.Font=Enum.Font.GothamBold;q.TextSize=10;q.Parent=bar;local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,8);c.Parent=q;return q end
  local sync=b("SYNC",0,72,Color3.fromRGB(47,82,72));local unsync=b("UNSYNC",78,82,Color3.fromRGB(82,41,48))
  statusLabel=Instance.new("TextLabel");statusLabel.BackgroundTransparency=1;statusLabel.Position=UDim2.fromOffset(168,0);statusLabel.Size=UDim2.new(1,-168,0,34);statusLabel.Text="LEAD READY";statusLabel.TextColor3=Color3.fromRGB(170,172,184);statusLabel.Font=Enum.Font.GothamBold;statusLabel.TextSize=9;statusLabel.TextXAlignment=Enum.TextXAlignment.Right;statusLabel.Parent=bar
  sync.Activated:Connect(function()if not isLead() then return end;leadSyncActive=true;sendCurrent("leadSyncStart")end)
  unsync.Activated:Connect(function()if not isLead() then return end;leadSyncActive=false;social:FireServer("leadSyncStop",{});statusLabel.Text="SYNC OFF"end)
 else
  leadSyncActive=false
  if originalPanel and originalPanel.panel==p then p.Position=originalPanel.pos;p.Size=originalPanel.size;p:SetAttribute("BBYALeadDancePanel",false);if catalog and originalPanel.catalogPos then catalog.Position=originalPanel.catalogPos;catalog.Size=originalPanel.catalogSize end end
 end
 bindAnimator();return true
end

social.OnClientEvent:Connect(function(kind,data)
 data=type(data)=="table" and data or {}
 if kind=="leadSyncDance" then playFollower(data)
 elseif kind=="leadSyncStop" then stopFollower(data.reason)
 elseif kind=="leadSyncStatus" and isLead() then
  leadSyncActive=data.active==true
  if statusLabel then statusLabel.Text=leadSyncActive and ("SYNC • "..tostring(data.count or 0).." CROWD") or tostring(data.message or "SYNC OFF") end
 end
end)

player:GetAttributeChangedSignal("BBYAHasLeadRole"):Connect(function()if not isLead() and leadSyncActive then social:FireServer("leadSyncStop",{});leadSyncActive=false end;task.defer(applyPanelMode)end)
player:GetAttributeChangedSignal("BBYAManagedRole"):Connect(function()if not isLead() and leadSyncActive then social:FireServer("leadSyncStop",{});leadSyncActive=false end;task.defer(applyPanelMode)end)
player.CharacterAdded:Connect(function()stopSyncTrack();latestLeadTrack=nil;boundAnimator=nil;task.delay(.8,function()bindAnimator();applyPanelMode()end)end)
pg.ChildAdded:Connect(function(c)if c.Name=="BBYASocialHangoutUI" then task.defer(applyPanelMode);task.delay(.4,applyPanelMode)end end)

task.spawn(function()for _=1,40 do bindAnimator();if applyPanelMode() then break end;task.wait(.25) end end)
print("[BBYA] LEAD Dance Sync client v1 online: larger side panel + SYNC/UNSYNC + follower playback")
