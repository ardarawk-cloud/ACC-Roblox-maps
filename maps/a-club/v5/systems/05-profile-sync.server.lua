-- [SYS-PROFILE-SYNC] ATTRIBUTE -> LEADERSTATS CONSISTENCY
local function bindProfileSync(p)
 task.spawn(function()
  local ls=p:WaitForChild("leaderstats",20);if not ls then return end
  local function sync()
   local level=ls:FindFirstChild("Level");if level then level.Value=p:GetAttribute("BBYALevel") or level.Value end
   local likes=ls:FindFirstChild("Likes");if likes then likes.Value=p:GetAttribute("BBYALikes") or likes.Value end
   local donated=ls:FindFirstChild("Donated");if donated then donated.Value=p:GetAttribute("TotalDonated") or donated.Value end
  end
  p:GetAttributeChangedSignal("BBYALevel"):Connect(sync);p:GetAttributeChangedSignal("BBYALikes"):Connect(sync);p:GetAttributeChangedSignal("TotalDonated"):Connect(sync);sync()
 end)
end
Players.PlayerAdded:Connect(bindProfileSync);for _,p in ipairs(Players:GetPlayers()) do bindProfileSync(p) end
workspace:SetAttribute("BBYASystemProfileSync","5.0")
