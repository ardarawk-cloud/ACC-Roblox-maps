-- BBYA SOCIAL HUB — MAIN CLUB INTERACTION CLEANUP v1
-- Removes redundant world DJ request/Sit prompts and makes Main Club lounge seats auto-seat on approach.
-- Music requests remain available through the menu UI.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end

local old = root:FindFirstChild("MainClubInteractionCleanupV1")
if old then old:Destroy() end

local out = Instance.new("Model")
out.Name = "MainClubInteractionCleanupV1"
out:SetAttribute("Pass", "AUTO_SEAT_AND_REDUNDANT_PROMPT_CLEANUP_V1")
out:SetAttribute("AUTO_SEAT", true)
out:SetAttribute("DJWorldRequestPromptRemoved", true)
out.Parent = root

local debounce = {}
local runtime
local runtimeGuard

local function isRedundantPrompt(prompt)
	if not prompt:IsA("ProximityPrompt") then return false end
	local action = tostring(prompt.ActionText or "")
	local object = tostring(prompt.ObjectText or "")
	local parentName = prompt.Parent and prompt.Parent.Name or ""

	if parentName == "DJRequestInteract" then return true end
	if action == "Request Track" and object == "DJ Booth" then return true end
	if action == "Sit" and object == "VIP Banquette" then return true end
	return false
end

local function stripPrompts()
	runtime = root:FindFirstChild("Floor1Features") or runtime
	if not runtime then return end

	for _, d in ipairs(runtime:GetDescendants()) do
		if isRedundantPrompt(d) then d:Destroy() end
	end

	if not runtimeGuard then
		runtimeGuard = runtime.DescendantAdded:Connect(function(d)
			if isRedundantPrompt(d) then
				task.defer(function()
					if d.Parent and isRedundantPrompt(d) then d:Destroy() end
				end)
			end
		end)
	end
end

local function playerFromHit(hit)
	if not hit then return nil, nil end
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then return nil, nil end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil, nil end
	return Players:GetPlayerFromCharacter(character), humanoid
end

local function bindAutoSeat(seat)
	if not seat:IsA("Seat") then return end
	if seat:GetAttribute("BBYAMainClubAutoSeatBound") then return end
	seat:SetAttribute("BBYAMainClubAutoSeatBound", true)

	local trigger = Instance.new("Part")
	trigger.Name = "AutoSeatTrigger_" .. seat.Name
	trigger.Size = Vector3.new(2.5, 3.2, 2.8)
	trigger.CFrame = CFrame.new(seat.Position + seat.CFrame.LookVector * 2.0 + Vector3.new(0, 0.65, 0))
	trigger.Transparency = 1
	trigger.Anchored = true
	trigger.CanCollide = false
	trigger.CanTouch = true
	trigger.CanQuery = false
	trigger:SetAttribute("BBYAAutoSeatTrigger", true)
	trigger.Parent = out

	trigger.Touched:Connect(function(hit)
		local player, humanoid = playerFromHit(hit)
		if not player or not humanoid or humanoid.Health <= 0 then return end
		if humanoid.SeatPart then return end
		if seat.Occupant then return end

		local now = os.clock()
		local last = debounce[player.UserId] or 0
		if now - last < 1.75 then return end
		debounce[player.UserId] = now

		seat:Sit(humanoid)
	end)
end

local function bindExistingSeats()
	runtime = root:FindFirstChild("Floor1Features") or runtime
	if not runtime then return end

	for _, d in ipairs(runtime:GetDescendants()) do
		if d:IsA("Seat") and d.Name:match("^VIPSeat") then
			bindAutoSeat(d)
		end
	end
end

local function refresh()
	stripPrompts()
	bindExistingSeats()
end

-- Floor1Features is created by an earlier server pass; retry briefly for deterministic ordering.
for i = 1, 12 do
	task.delay((i - 1) * 0.35, refresh)
end

root.ChildAdded:Connect(function(child)
	if child.Name == "Floor1Features" then
		if runtimeGuard then runtimeGuard:Disconnect(); runtimeGuard = nil end
		runtime = child
		task.defer(refresh)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	debounce[player.UserId] = nil
end)

print("[BBYA] Main Club interaction cleanup v1 online: auto-seat lounges / DJ world request prompt removed / menu request preserved")
