-- BBYA SOCIAL HUB — IN-SESSION AVATAR SWITCH SERVER v2 CLEAN RELOAD
-- One authority: outfit selection replaces the character with the requested Roblox outfit in-session.
-- Player attributes/progression remain on Player; position is restored; no server rejoin is required.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")or Instance.new("Folder");remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("AvatarSwitch")or Instance.new("RemoteEvent");remote.Name="AvatarSwitch";remote.Parent=remotes
local applying={}

local function status(p,ok,msg,busy)if p and p.Parent then remote:FireClient(p,"status",{ok=ok,message=msg,busy=busy==true})end end
local function carryBusy(p)return p:GetAttribute("BBYACarryingUserId")~=nil or p:GetAttribute("BBYACarriedByUserId")~=nil end
local function waitRoot(p,timeout)
 local deadline=os.clock()+(timeout or 5)
 while os.clock()<deadline do local c=p.Character;local r=c and c:FindFirstChild("HumanoidRootPart");local h=c and c:FindFirstChildOfClass("Humanoid");if r and h and h.Health>0 then return r end;task.wait(.05)end
end
local function finish(p)if p then applying[p.UserId]=nil end end

local function applyOutfit(p,outfitId)
 if applying[p.UserId]then status(p,false,"Avatar masih diproses.",true);return end
 if carryBusy(p)then status(p,false,"Akhiri CARRY dulu sebelum ganti avatar.",false);return end
 outfitId=tonumber(outfitId);if not outfitId or outfitId<=0 then status(p,false,"Outfit tidak valid.",false);return end
 local oldRoot=p.Character and p.Character:FindFirstChild("HumanoidRootPart");if not oldRoot then status(p,false,"Avatar belum siap.",false);return end
 local oldCF=oldRoot.CFrame
 applying[p.UserId]=true;status(p,true,"Loading outfit…",true)
 local okDesc,desc=pcall(function()return Players:GetHumanoidDescriptionFromOutfitIdAsync(outfitId)end)
 if not okDesc or not desc then finish(p);status(p,false,"Outfit Roblox tidak tersedia.",false);return end

 -- A full in-session character reload is deliberate: it avoids partial ApplyDescription state
 -- and gives repeated switches the same clean path every time.
 local okLoad,err=pcall(function()p:LoadCharacterWithHumanoidDescriptionAsync(desc)end)
 if not okLoad then
  finish(p);status(p,false,"Gagal mengganti avatar. Coba lagi.",false);warn("[BBYA AvatarSwitch] reload failed",p.UserId,outfitId,err);return
 end
 local newRoot=waitRoot(p,6)
 if not newRoot then finish(p);status(p,false,"Avatar baru tidak selesai dimuat.",false);return end
 newRoot.CFrame=oldCF;newRoot.AssemblyLinearVelocity=Vector3.zero;newRoot.AssemblyAngularVelocity=Vector3.zero
 p:SetAttribute("BBYAActiveOutfitId",outfitId)
 finish(p);status(p,true,"Avatar berhasil diganti.",false)
end

remote.OnServerEvent:Connect(function(p,action,value)if action=="applyOutfit"then task.spawn(applyOutfit,p,value)end end)
Players.PlayerRemoving:Connect(function(p)applying[p.UserId]=nil end)
print("[BBYA] Avatar Switch server v2 online: clean in-session character reload / repeat-safe / position preserved")
