-- BBYA MUSIC SUITE — NOW PLAYING CLEANUP v1
-- Removes the redundant green LIVE badge from the Now Playing hero.
-- The smaller playback status text remains, so the panel keeps state feedback without visual clutter.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local function clean()
 local suite=pg:FindFirstChild("BBYAMusicSuiteV1")
 if not suite then return end
 local pill=suite:FindFirstChild("LivePillV3",true)
 if pill then pill:Destroy() end
end

pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYAMusicSuiteV1" then
  task.defer(clean)
  task.delay(.1,clean)
  task.delay(.5,clean)
 end
end)

task.defer(clean)
task.delay(.2,clean)
task.delay(.8,clean)

print("[BBYA] Now Playing cleanup active — redundant LIVE badge removed")
