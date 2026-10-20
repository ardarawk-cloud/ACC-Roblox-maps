-- NEON Studio Bridge v1
-- Safe, whitelist-only Roblox Studio local plugin.
-- Pulls commands from the public ACC-Roblox-maps command queue.
-- v1 is intentionally restricted to Workspace.NEON_BRIDGE_TEST.

local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")

local COMMAND_URL = "https://raw.githubusercontent.com/ardarawk-cloud/ACC-Roblox-maps/main/bridge/neon-studio/command.json"
local EXPECTED_PLACE_ID = 76001567401911
local POLL_SECONDS = 3

local toolbar = plugin:CreateToolbar("NEON Bridge")
local toggleButton = toolbar:CreateButton(
	"NEON Bridge",
	"Toggle NEON Studio Bridge",
	""
)
toggleButton.ClickableWhenViewportHidden = true

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	false,
	false,
	300,
	150,
	240,
	120
)
local widget = plugin:CreateDockWidgetPluginGui("NEONStudioBridgeWidgetV1", widgetInfo)
widget.Title = "NEON Studio Bridge"

local rootFrame = Instance.new("Frame")
rootFrame.Size = UDim2.fromScale(1, 1)
rootFrame.BackgroundColor3 = Color3.fromRGB(24, 27, 34)
rootFrame.BorderSizePixel = 0
rootFrame.Parent = widget

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 28)
title.Position = UDim2.fromOffset(8, 8)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(0, 230, 255)
title.Text = "NEON BRIDGE v1"
title.Parent = rootFrame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -16, 0, 74)
status.Position = UDim2.fromOffset(8, 40)
status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.TextWrapped = true
status.Font = Enum.Font.Code
status.TextSize = 13
status.TextColor3 = Color3.fromRGB(220, 225, 235)
status.Text = "OFF"
status.Parent = rootFrame

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -16, 0, 24)
hint.Position = UDim2.new(0, 8, 1, -30)
hint.BackgroundTransparency = 1
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Font = Enum.Font.Gotham
hint.TextSize = 11
hint.TextColor3 = Color3.fromRGB(145, 155, 170)
hint.Text = "Toolbar button: ON / OFF"
hint.Parent = rootFrame

local running = false
local workerToken = 0
local lastRevision = tonumber(plugin:GetSetting("NEONBridgeLastRevision_" .. tostring(game.PlaceId))) or 0

local function setStatus(text)
	status.Text = text
	print("[NEON Bridge] " .. text)
end

local function ensureTestFolder()
	local folder = workspace:FindFirstChild("NEON_BRIDGE_TEST")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "NEON_BRIDGE_TEST"
		folder.Parent = workspace
	end
	return folder
end

local function vec3(a, fallback)
	if type(a) ~= "table" or #a < 3 then
		return fallback
	end
	return Vector3.new(tonumber(a[1]) or 0, tonumber(a[2]) or 0, tonumber(a[3]) or 0)
end

local function color3(a, fallback)
	if type(a) ~= "table" or #a < 3 then
		return fallback
	end
	local r = tonumber(a[1]) or 255
	local g = tonumber(a[2]) or 255
	local b = tonumber(a[3]) or 255
	if r <= 1 and g <= 1 and b <= 1 then
		return Color3.new(r, g, b)
	end
	return Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
end

local function safeMaterial(name)
	if type(name) ~= "string" then
		return Enum.Material.SmoothPlastic
	end
	local ok, value = pcall(function()
		return Enum.Material[name]
	end)
	if ok and value then
		return value
	end
	return Enum.Material.SmoothPlastic
end

local function getByBridgeId(folder, id)
	for _, child in ipairs(folder:GetChildren()) do
		if child:GetAttribute("NeonBridgeId") == id then
			return child
		end
	end
	return nil
end

local function applyCreatePart(op)
	local folder = ensureTestFolder()
	local id = tostring(op.id or op.name or "unnamed")
	local p = getByBridgeId(folder, id)
	if not p then
		p = Instance.new("Part")
		p:SetAttribute("NeonBridgeId", id)
		p.Parent = folder
	end

	p.Name = tostring(op.name or id)
	p.Anchored = op.anchored ~= false
	p.CanCollide = op.canCollide ~= false
	p.Size = vec3(op.size, Vector3.new(4,4,4))

	local pos = vec3(op.position, Vector3.new(0,3,0))
	local rot = vec3(op.rotation, Vector3.new(0,0,0))
	p.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))

	p.Color = color3(op.color, Color3.fromRGB(0,230,255))
	p.Material = safeMaterial(op.material)
	p.Transparency = math.clamp(tonumber(op.transparency) or 0, 0, 1)

	if op.light == true then
		local light = p:FindFirstChild("BridgeLight")
		if not light then
			light = Instance.new("PointLight")
			light.Name = "BridgeLight"
			light.Parent = p
		end
		light.Color = p.Color
		light.Brightness = tonumber(op.lightBrightness) or 2
		light.Range = tonumber(op.lightRange) or 24
		light.Shadows = false
	else
		local old = p:FindFirstChild("BridgeLight")
		if old then old:Destroy() end
	end
end

local function applyDelete(op)
	local folder = ensureTestFolder()
	local id = tostring(op.id or "")
	if id == "" then return end
	local obj = getByBridgeId(folder, id)
	if obj then obj:Destroy() end
end

local function applyClear()
	local folder = ensureTestFolder()
	folder:ClearAllChildren()
end

local function applySelect(op)
	local folder = ensureTestFolder()
	local id = tostring(op.id or "")
	local obj = getByBridgeId(folder, id)
	if obj then
		Selection:Set({obj})
	end
end

local function applyOps(doc)
	local ops = doc.ops
	if type(ops) ~= "table" then return 0 end
	local count = 0
	for _, op in ipairs(ops) do
		if type(op) == "table" then
			local t = tostring(op.type or "")
			if t == "ping" then
				-- no scene mutation
			elseif t == "createPart" then
				applyCreatePart(op)
				count += 1
			elseif t == "delete" then
				applyDelete(op)
				count += 1
			elseif t == "clearTest" then
				applyClear()
				count += 1
			elseif t == "select" then
				applySelect(op)
			else
				warn("[NEON Bridge] blocked unknown op: " .. t)
			end
		end
	end
	return count
end

local function pollOnce()
	if game.PlaceId ~= EXPECTED_PLACE_ID then
		setStatus("BLOCKED\nWrong PlaceId: " .. tostring(game.PlaceId))
		return
	end

	local ok, body = pcall(function()
		return HttpService:GetAsync(COMMAND_URL, true)
	end)
	if not ok then
		setStatus("HTTP ERROR\nEnable HTTP Requests in Studio\n" .. tostring(body))
		return
	end

	local parsedOk, doc = pcall(function()
		return HttpService:JSONDecode(body)
	end)
	if not parsedOk or type(doc) ~= "table" then
		setStatus("INVALID COMMAND JSON")
		return
	end

	if tonumber(doc.targetPlaceId) ~= EXPECTED_PLACE_ID then
		setStatus("BLOCKED\nCommand target mismatch")
		return
	end

	local revision = tonumber(doc.revision) or 0
	if revision <= lastRevision then
		setStatus("ON • waiting\nrev " .. tostring(lastRevision) .. "\nPlace " .. tostring(game.PlaceId))
		return
	end

	local changed = applyOps(doc)
	lastRevision = revision
	plugin:SetSetting("NEONBridgeLastRevision_" .. tostring(game.PlaceId), lastRevision)
	setStatus("APPLIED rev " .. tostring(revision) .. "\nops " .. tostring(changed) .. "\nPlace " .. tostring(game.PlaceId))
end

local function stop()
	running = false
	workerToken += 1
	toggleButton:SetActive(false)
	setStatus("OFF\nlast rev " .. tostring(lastRevision))
end

local function start()
	if running then return end
	running = true
	workerToken += 1
	local myToken = workerToken
	toggleButton:SetActive(true)
	widget.Enabled = true
	setStatus("STARTING...")
	task.spawn(function()
		while running and workerToken == myToken do
			pollOnce()
			task.wait(POLL_SECONDS)
		end
	end)
end

toggleButton.Click:Connect(function()
	if running then stop() else start() end
end)

widget:BindToClose(function()
	widget.Enabled = false
end)

setStatus("OFF\nClick NEON Bridge in Plugins toolbar")
