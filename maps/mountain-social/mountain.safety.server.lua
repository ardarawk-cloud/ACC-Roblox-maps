-- Mountain Social Adventure v2.2 traversal safety
local Players=game:GetService("Players")
local root=workspace:WaitForChild("ACC_MountainSocial")
local checkpoints=root:WaitForChild("Checkpoints")
local route={Vector3.new(0,22,690),Vector3.new(-132,75,555),Vector3.new(88,126,430),Vector3.new(212,182,300),Vector3.new(78,236,158),Vector3.new(-118,300,34),Vector3.new(-224,356,-106),Vector3.new(-74,414,-242),Vector3.new(116,470,-336),Vector3.new(204,526,-432),Vector3.new(94,575,-540),Vector3.new(0,620,-650)}
local safety=Instance.new("Folder");safety.Name="TraversalSafety";safety.Parent=root
local function part(n,s,cf,tr,coll)local p=Instance.new("Part");p.Name=n;p.Anchored=true;p.Size=s;p.CFrame=cf;p.Transparency=tr or 1;p.CanCollide=coll~=false;p.CanTouch=true;p.Material=Enum.Material.Rock;p.Parent=safety;return p end
-- Invisible side guards only on steeper upper segments. They prevent accidental walk-off without turning the trail into an obby corridor.
for seg=6,#route-1 do local a,b=route[seg],route[seg+1];local d=b-a;local dist=d.Magnitude;local mid=(a+b)/2;local side=Vector3.new(-d.Z,0,d.X);if side.Magnitude>0 then side=side.Unit end;for _,sgn in ipairs({-1,1}) do local cf=CFrame.lookAt(mid+side*(seg<9 and 10 or 8)*sgn+Vector3.new(0,3,0),b+side*(seg<9 and 10 or 8)*sgn+Vector3.new(0,3,0));part("Guard_"..seg.."_"..sgn,Vector3.new(1.2,7,dist),cf,1,true)end end
local function cpPart(index)for _,p in ipairs(checkpoints:GetChildren())do if p:IsA("BasePart") and (tonumber(p:GetAttribute("CheckpointIndex"))==index or tonumber(p.Name:match("%d+"))==index)then return p end end end
local function recover(player)
 local char=player.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid");if not hrp or not hum or hum.Health<=0 then return end
 local idx=tonumber(player:GetAttribute("MountainCheckpoint") or player:GetAttribute("ACC_Checkpoint") or 1) or 1;idx=math.clamp(idx,1,12);local cp=cpPart(idx);if cp then hrp.AssemblyLinearVelocity=Vector3.zero;hrp.AssemblyAngularVelocity=Vector3.zero;hrp.CFrame=cp.CFrame+Vector3.new(0,5,0)end
end
-- Rescue plane beneath the playable mountain; touching it returns the hiker to the last checkpoint instead of killing progress.
local rescue=part("RescuePlane",Vector3.new(1800,4,1800),CFrame.new(0,-12,0),1,false);rescue.Touched:Connect(function(hit)local char=hit.Parent;local player=char and Players:GetPlayerFromCharacter(char);if player then task.defer(recover,player)end end)
-- Server position watchdog catches rare terrain slips below the expected route envelope.
task.spawn(function()while true do for _,player in ipairs(Players:GetPlayers())do local char=player.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");if hrp and hrp.Position.Y < -8 then recover(player)end end;task.wait(1.5)end end)
workspace:SetAttribute("ACC_TraversalSafety","v2.2")
root:SetAttribute("SafetyVersion","2.2")
print("[ACC] Mountain traversal safety v2.2 ready")