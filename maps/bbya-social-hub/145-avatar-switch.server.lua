-- BBYA SOCIAL HUB — IN-SESSION AVATAR SWITCH SERVER v1
-- Applies a Roblox outfit HumanoidDescription without leaving/rejoining the server.
-- Player progression/title/donation live on Player attributes/DataStores and are untouched.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder");remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("AvatarSwitch") or Instance.new("RemoteEvent");remote.Name="AvatarSwitch";remote.Parent=remotes
local cooldown={}

local function status(p,ok,msg)if p and p.Parent then remote:FireClient(p,"status",{ok=ok,message=msg}) end end
local function carryBusy(p)return p:GetAttribute("BBYACarryingUserId")~=nil or p:GetAttribute("BBYACarriedByUserId")~=nil end
local function applyOutfit(p,outfitId)
 local now=os.clock();if now-(cooldown[p.UserId] or 0)<2.5 then status(p,false,"Tunggu sebentar sebelum ganti avatar lagi.");return end;cooldown[p.UserId]=now
 if carryBusy(p) then status(p,false,"Akhiri CARRY dulu sebelum ganti avatar.");return end
 outfitId=tonumber(outfitId);if not outfitId or outfitId<=0 then status(p,false,"Outfit tidak valid.");return end
 local ch=p.Character;local hum=ch and ch:FindFirstChildOfClass("Humanoid");local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hum or hum.Health<=0 or not hrp then status(p,false,"Avatar belum siap.");return end
 local oldCF=hrp.CFrame
 local okOld,oldDesc=pcall(function()return hum:GetAppliedDescription()end);if not okOld or not oldDesc then status(p,false,"Avatar lama tidak dapat dibaca.");return end;oldDesc=oldDesc:Clone()
 status(p,true,"Loading outfit…")
 local okDesc,newDesc=pcall(function()return Players:GetHumanoidDescriptionFromOutfitIdAsync(outfitId)end)
 if not okDesc or not newDesc then status(p,false,"Outfit Roblox tidak tersedia.");return end
 for _,track in ipairs(hum:GetPlayingAnimationTracks()) do pcall(function()track:Stop(.1)end) end
 hum.Sit=false
 local okApply,err=pcall(function()hum:ApplyDescriptionAsync(newDesc)end)
 if not okApply then
  pcall(function()hum:ApplyDescriptionAsync(oldDesc)end)
  status(p,false,"Gagal menerapkan outfit; avatar lama dipulihkan.");warn("[BBYA AvatarSwitch] apply failed",p.UserId,outfitId,err);return
 end
 task.defer(function()
  local c=p.Character;local r=c and c:FindFirstChild("HumanoidRootPart")
  if r then r.CFrame=oldCF;r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero end
 end)
 p:SetAttribute("BBYAActiveOutfitId",outfitId)
 status(p,true,"Avatar berhasil diganti tanpa rejoin.")
end
remote.OnServerEvent:Connect(function(p,action,value)if action=="applyOutfit" then applyOutfit(p,value) end end)
Players.PlayerRemoving:Connect(function(p)cooldown[p.UserId]=nil end)
print("[BBYA] In-session Avatar Switch server v1 online")
