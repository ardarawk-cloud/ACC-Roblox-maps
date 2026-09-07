-- BBYA SOCIAL HUB — IN-SESSION AVATAR SWITCH SERVER v1.1 RAPID SAFE
-- Whole-avatar outfit replacement without rejoin. Rapid consecutive switching is supported
-- with one in-flight apply per player; player progression/title/donation attributes are untouched.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("AvatarSwitch") or Instance.new("RemoteEvent")
remote.Name="AvatarSwitch";remote.Parent=remotes

local lastApply={}
local applying={}
local MIN_INTERVAL=.65

local function status(p,ok,msg,busy)
 if p and p.Parent then remote:FireClient(p,"status",{ok=ok,message=msg,busy=busy==true}) end
end
local function carryBusy(p)
 return p:GetAttribute("BBYACarryingUserId")~=nil or p:GetAttribute("BBYACarriedByUserId")~=nil
end
local function reacquireRoot(p,timeout)
 local deadline=os.clock()+(timeout or 2)
 while os.clock()<deadline do
  local c=p.Character
  local r=c and c:FindFirstChild("HumanoidRootPart")
  if r and r:IsA("BasePart") then return r end
  task.wait(.05)
 end
end
local function applyDescription(hum,desc)
 local ok,err=pcall(function()
  if hum.ApplyDescriptionResetAsync then hum:ApplyDescriptionResetAsync(desc) else hum:ApplyDescriptionAsync(desc) end
 end)
 if ok then return true end
 local ok2,err2=pcall(function()hum:ApplyDescriptionAsync(desc)end)
 return ok2,err2 or err
end

local function applyOutfit(p,outfitId)
 if applying[p.UserId] then status(p,false,"Avatar masih diproses. Tunggu sebentar.",true);return end
 local now=os.clock()
 if now-(lastApply[p.UserId] or 0)<MIN_INTERVAL then status(p,false,"Tunggu sebentar lalu pilih outfit berikutnya.",false);return end
 if carryBusy(p) then status(p,false,"Akhiri CARRY dulu sebelum ganti avatar.",false);return end
 outfitId=tonumber(outfitId)
 if not outfitId or outfitId<=0 then status(p,false,"Outfit tidak valid.",false);return end

 local ch=p.Character
 local hum=ch and ch:FindFirstChildOfClass("Humanoid")
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hum or hum.Health<=0 or not hrp then status(p,false,"Avatar belum siap.",false);return end

 applying[p.UserId]=true
 lastApply[p.UserId]=now
 local oldCF=hrp.CFrame
 local okOld,oldDesc=pcall(function()return hum:GetAppliedDescription()end)
 if not okOld or not oldDesc then applying[p.UserId]=nil;status(p,false,"Avatar lama tidak dapat dibaca.",false);return end
 oldDesc=oldDesc:Clone()
 status(p,true,"Loading outfit…",true)

 local okDesc,newDesc=pcall(function()return Players:GetHumanoidDescriptionFromOutfitIdAsync(outfitId)end)
 if not okDesc or not newDesc then applying[p.UserId]=nil;status(p,false,"Outfit Roblox tidak tersedia.",false);return end

 for _,track in ipairs(hum:GetPlayingAnimationTracks()) do pcall(function()track:Stop(.08)end) end
 hum.Sit=false
 local okApply,err=applyDescription(hum,newDesc)
 if not okApply then
  pcall(function()applyDescription(hum,oldDesc)end)
  applying[p.UserId]=nil
  status(p,false,"Gagal menerapkan outfit; avatar lama dipulihkan.",false)
  warn("[BBYA AvatarSwitch] apply failed",p.UserId,outfitId,err)
  return
 end

 task.wait(.08)
 local r=reacquireRoot(p,2)
 if r then
  r.CFrame=oldCF
  r.AssemblyLinearVelocity=Vector3.zero
  r.AssemblyAngularVelocity=Vector3.zero
 end
 p:SetAttribute("BBYAActiveOutfitId",outfitId)
 applying[p.UserId]=nil
 status(p,true,"Avatar berhasil diganti • pilih outfit lain kapan saja.",false)
end

remote.OnServerEvent:Connect(function(p,action,value)
 if action=="applyOutfit" then task.spawn(applyOutfit,p,value) end
end)
Players.PlayerRemoving:Connect(function(p)lastApply[p.UserId]=nil;applying[p.UserId]=nil end)
print("[BBYA] In-session Avatar Switch server v1.1 online: rapid-safe reset apply / position preserved")
