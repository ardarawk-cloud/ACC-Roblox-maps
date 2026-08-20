-- v2.3 Social Camp upgrade
local Players=game:GetService('Players')
local root=workspace:WaitForChild('ACC_MountainSocial',15);if not root then return end
local camps=root:FindFirstChild('Camps');if not camps then return end
for _,camp in ipairs(camps:GetChildren()) do
 local fire=camp:FindFirstChild('Campfire',true)
 if fire and fire:IsA('BasePart') then
  local p=fire:FindFirstChildOfClass('ProximityPrompt') or Instance.new('ProximityPrompt')
  p.ActionText='Rest';p.ObjectText='Campfire';p.HoldDuration=.5;p.MaxActivationDistance=10;p.RequiresLineOfSight=false;p.Parent=fire
  p.Triggered:Connect(function(plr)
   plr:SetAttribute('ACC_RestedAt',os.time());plr:SetAttribute('ACC_StaminaBoostUntil',os.time()+180)
  end)
 end
end
workspace:SetAttribute('ACC_SocialCamp','v2.3')