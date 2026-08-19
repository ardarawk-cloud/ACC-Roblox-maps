local W=game:GetService("Workspace")
local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder",W);root.Name="BBYA_ZERO_BUILD"
local old=root:FindFirstChild("SocialInteractions");if old then old:Destroy() end
local m=Instance.new("Model",root);m.Name="SocialInteractions"
local function anchor(n,pos)
 local p=Instance.new("Part");p.Name=n;p.Anchored=true;p.CanCollide=false;p.Transparency=1;p.Size=Vector3.new(2,2,2);p.CFrame=CFrame.new(pos);p.Parent=m;return p
end
local function prompt(part,action,obj,key)
 local q=Instance.new("ProximityPrompt");q.ActionText=action;q.ObjectText=obj;q.KeyboardKeyCode=key or Enum.KeyCode.E;q.HoldDuration=.15;q.MaxActivationDistance=10;q.RequiresLineOfSight=false;q.Parent=part;return q
end
local function tp(player,pos)
 local ch=player.Character;if not ch then return end
 local hrp=ch:FindFirstChild("HumanoidRootPart");if hrp then hrp.CFrame=CFrame.new(pos) end
end
-- reception interaction
local rec=anchor("ReceptionInteract",Vector3.new(0,3,-31));local rp=prompt(rec,"Check In","BBYA Reception")
rp.Triggered:Connect(function(plr) plr:SetAttribute("BBYACheckedIn",true) end)
-- selfie spot gives stable front-facing photo position
local photo=anchor("SelfieInteract",Vector3.new(-40,3,-31));local pp=prompt(photo,"Photo Spot","BBYA Selfie Area")
pp.Triggered:Connect(function(plr) tp(plr,Vector3.new(-40,2,-35)) end)
-- salon marker
local salon=anchor("SalonInteract",Vector3.new(-44,3,-12));local sp=prompt(salon,"Use Look Studio","BBYA Salon")
sp.Triggered:Connect(function(plr) plr:SetAttribute("BBYALookStudioVisited",true) end)
-- public vertical travel; keeps circulation off dance floor center
local l1=anchor("ToVIP",Vector3.new(51,3,-31));local p1=prompt(l1,"Go Up","VIP Level")
p1.Triggered:Connect(function(plr) tp(plr,Vector3.new(49,27,-28)) end)
local l2=anchor("VIPToL1",Vector3.new(49,27,-28));local p2=prompt(l2,"Go Down","Main Club")
p2.Triggered:Connect(function(plr) tp(plr,Vector3.new(51,3,-31)) end)
local roof=anchor("VIPToRoof",Vector3.new(50,27,-18));local p3=prompt(roof,"Go Up","Rooftop Pool")
p3.Triggered:Connect(function(plr) tp(plr,Vector3.new(43,47,-28)) end)
local down=anchor("RoofToVIP",Vector3.new(43,47,-28));local p4=prompt(down,"Go Down","VIP Level")
p4.Triggered:Connect(function(plr) tp(plr,Vector3.new(50,27,-18)) end)
-- DJ booth interaction flag reserved for later music controller
local dj=anchor("DJInteract",Vector3.new(0,5,21));local dp=prompt(dj,"Open Console","DJ Booth")
dp.Triggered:Connect(function(plr) plr:SetAttribute("BBYADJConsole",true) end)
-- rooftop social marker
local pool=anchor("PoolDeckInteract",Vector3.new(0,47,-12));local poolp=prompt(pool,"Hang Out","Pool DJ Deck")
poolp.Triggered:Connect(function(plr) plr:SetAttribute("BBYAPoolVisited",true) end)
print("[BBYA] social interactions + floor navigation online")