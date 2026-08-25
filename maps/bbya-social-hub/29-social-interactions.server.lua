local W=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder",W);root.Name="BBYA_ZERO_BUILD"
local old=root:FindFirstChild("SocialInteractions");if old then old:Destroy() end
local m=Instance.new("Model",root);m.Name="SocialInteractions"

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local feature=remotes:FindFirstChild("Feature") or Instance.new("RemoteEvent")
feature.Name="Feature";feature.Parent=remotes

local function anchor(n,pos)
 local p=Instance.new("Part");p.Name=n;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Transparency=1;p.Size=Vector3.new(2,2,2);p.CFrame=CFrame.new(pos);p.Parent=m;return p
end
local function prompt(part,action,obj,key)
 local q=Instance.new("ProximityPrompt");q.ActionText=action;q.ObjectText=obj;q.KeyboardKeyCode=key or Enum.KeyCode.E;q.HoldDuration=.15;q.MaxActivationDistance=10;q.RequiresLineOfSight=false;q.Parent=part;return q
end
local function tp(player,pos)
 local ch=player.Character;if not ch then return end
 local hrp=ch:FindFirstChild("HumanoidRootPart");if hrp then hrp.CFrame=CFrame.new(pos) end
end
local function isPresent(name)
 return root:FindFirstChild(name)~=nil
end
local function rooftopPresent()
 local upper=root:FindFirstChild("UpperLevels")
 return upper and upper:FindFirstChild("R_Rooftop")~=nil or false
end

-- Reception is information-only. Travel remains the only paid/instant navigation authority.
local rec=anchor("ReceptionInteract",Vector3.new(0,3,-31))
local rp=prompt(rec,"Venue Info","BBYA Concierge")
rp.Name="BBYAConciergePrompt"
rp.Triggered:Connect(function(plr)
 feature:FireClient(plr,"concierge",{
  title="BBYA CONCIERGE",
  venues={
   {name="MAIN CLUB",genre="Western / International",direction="Straight ahead from reception",access="FREE WALK-IN",status=isPresent("MainClubRealism") and "OPEN" or "LOADING"},
   {name="UNDERGROUND",genre="Breakbeat / Indo Bounce",direction="Lower level",access="TRAVEL ACCESS",status=isPresent("Underground") and "OPEN" or "LOADING"},
   {name="FUNKOT DISKOTIK",genre="Funkot",direction="Rear district",access="TRAVEL ACCESS",status=isPresent("FunkotClub") and "OPEN" or "LOADING"},
   {name="ROOFTOP",genre="Pool / Social",direction="Upper level",access="TRAVEL ACCESS",status=rooftopPresent() and "OPEN" or "LOADING"},
  },
  travelNote="Fast Travel uses the existing TRAVEL access system. Concierge never bypasses or discounts Travel."
 })
end)

-- Legacy vertical prompts are still created here but removed by WorldPromptCleanup v2,
-- keeping Travel as the navigation authority.
local l1=anchor("ToVIP",Vector3.new(51,3,-31));local p1=prompt(l1,"Go Up","VIP Level")
p1.Triggered:Connect(function(plr) tp(plr,Vector3.new(49,27,-28)) end)
local l2=anchor("VIPToL1",Vector3.new(49,27,-28));local p2=prompt(l2,"Go Down","Main Club")
p2.Triggered:Connect(function(plr) tp(plr,Vector3.new(51,3,-31)) end)
local roof=anchor("VIPToRoof",Vector3.new(50,27,-18));local p3=prompt(roof,"Go Up","Rooftop Pool")
p3.Triggered:Connect(function(plr) tp(plr,Vector3.new(43,47,-28)) end)
local down=anchor("RoofToVIP",Vector3.new(43,47,-28));local p4=prompt(down,"Go Down","VIP Level")
p4.Triggered:Connect(function(plr) tp(plr,Vector3.new(50,27,-18)) end)

-- Rooftop marker remains until the rooftop feature pass replaces it.
local pool=anchor("PoolDeckInteract",Vector3.new(0,47,-12));local poolp=prompt(pool,"Hang Out","Pool DJ Deck")
poolp.Triggered:Connect(function(plr) plr:SetAttribute("BBYAPoolVisited",true) end)

m:SetAttribute("ReceptionRole","BBYA_CONCIERGE_V1")
m:SetAttribute("TravelAuthorityUntouched",true)
print("[BBYA] social core online; Reception Check In retired -> BBYA Concierge Venue Info")
