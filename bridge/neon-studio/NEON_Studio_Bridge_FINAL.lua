-- NEON Studio Bridge FINAL
-- Capability-complete visual authoring bridge for Place 76001567401911.
-- Commands are whitelisted. Loaded third-party assets are sandboxed by Roblox
-- and all scripts/prompts/click detectors are stripped before insertion.

local HttpService = game:GetService("HttpService")
local AssetService = game:GetService("AssetService")
local Selection = game:GetService("Selection")

local COMMAND_URL = "https://raw.githubusercontent.com/ardarawk-cloud/ACC-Roblox-maps/main/bridge/neon-studio/command.json"
local EXPECTED_PLACE_ID = 76001567401911
local POLL_SECONDS = 3
local ROOT_NAME = "NEON_BRIDGE_LIVE"

local toolbar = plugin:CreateToolbar("NEON Bridge")
local button = toolbar:CreateButton("NEON Bridge", "Start / Stop NEON Bridge FINAL", "")
button.ClickableWhenViewportHidden = true

local running = false
local token = 0
local lastRevision = tonumber(plugin:GetSetting("NEONFinalLastRevision_"..tostring(game.PlaceId))) or 0

local function root()
	local f = workspace:FindFirstChild(ROOT_NAME)
	if not f then
		f = Instance.new("Folder")
		f.Name = ROOT_NAME
		f.Parent = workspace
	end
	return f
end

local function v3(a, fallback)
	if type(a) ~= "table" or #a < 3 then return fallback end
	return Vector3.new(tonumber(a[1]) or 0, tonumber(a[2]) or 0, tonumber(a[3]) or 0)
end

local function cfFrom(op)
	local p = v3(op.position, Vector3.zero)
	local r = v3(op.rotation, Vector3.zero)
	return CFrame.new(p) * CFrame.Angles(math.rad(r.X), math.rad(r.Y), math.rad(r.Z))
end

local function color(a, fallback)
	if type(a) ~= "table" or #a < 3 then return fallback end
	local r,g,b = tonumber(a[1]) or 255, tonumber(a[2]) or 255, tonumber(a[3]) or 255
	if r <= 1 and g <= 1 and b <= 1 then return Color3.new(r,g,b) end
	return Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
end

local function material(name)
	if type(name) ~= "string" then return Enum.Material.SmoothPlastic end
	local ok, value = pcall(function() return Enum.Material[name] end)
	return ok and value or Enum.Material.SmoothPlastic
end

local function findId(id)
	for _, x in ipairs(root():GetChildren()) do
		if x:GetAttribute("NeonBridgeId") == id then return x end
	end
	return nil
end

local BLOCKED_CLASSES = {
	Script=true, LocalScript=true, ModuleScript=true,
	ClickDetector=true, ProximityPrompt=true,
}

local function sanitize(container)
	for _, d in ipairs(container:GetDescendants()) do
		if BLOCKED_CLASSES[d.ClassName] then
			d:Destroy()
		elseif d:IsA("BasePart") then
			d.Anchored = true
		end
	end
end

local function createPart(op)
	local id = tostring(op.id or op.name or "part")
	local p = findId(id)
	if p and not p:IsA("BasePart") then p:Destroy(); p=nil end
	if not p then
		p = Instance.new("Part")
		p:SetAttribute("NeonBridgeId", id)
		p.Parent = root()
	end
	p.Name = tostring(op.name or id)
	p.Anchored = op.anchored ~= false
	p.CanCollide = op.canCollide ~= false
	p.Size = v3(op.size, Vector3.new(4,4,4))
	p.CFrame = cfFrom(op)
	p.Color = color(op.color, Color3.fromRGB(0,230,255))
	p.Material = material(op.material)
	p.Transparency = math.clamp(tonumber(op.transparency) or 0,0,1)
end

local function loadAsset(op)
	local id = tostring(op.id or ("asset_"..tostring(op.assetId)))
	local old = findId(id)
	if old then old:Destroy() end

	local assetId = tonumber(op.assetId)
	assert(assetId and assetId > 0, "invalid assetId")

	local ok, wrapped = pcall(AssetService.LoadAssetAsync, AssetService, assetId)
	assert(ok and wrapped, "LoadAssetAsync failed: "..tostring(wrapped))

	sanitize(wrapped)
	wrapped.Name = tostring(op.name or id)
	wrapped:SetAttribute("NeonBridgeId", id)
	wrapped:SetAttribute("SourceAssetId", assetId)
	wrapped.Parent = root()

	local scale = tonumber(op.scale)
	if scale and scale > 0 and scale ~= 1 then
		pcall(function() wrapped:ScaleTo(scale) end)
	end
	wrapped:PivotTo(cfFrom(op))
	return wrapped
end

local function transform(op)
	local obj = findId(tostring(op.id or ""))
	if not obj then return end
	if obj:IsA("Model") then
		local scale = tonumber(op.scale)
		if scale and scale > 0 then pcall(function() obj:ScaleTo(scale) end) end
		obj:PivotTo(cfFrom(op))
	elseif obj:IsA("BasePart") then
		if op.size then obj.Size = v3(op.size,obj.Size) end
		obj.CFrame = cfFrom(op)
	end
end

local function setProps(op)
	local obj = findId(tostring(op.id or ""))
	if not obj then return end
	if obj:IsA("BasePart") then
		if op.color then obj.Color=color(op.color,obj.Color) end
		if op.material then obj.Material=material(op.material) end
		if op.transparency ~= nil then obj.Transparency=math.clamp(tonumber(op.transparency) or 0,0,1) end
		if op.canCollide ~= nil then obj.CanCollide=op.canCollide==true end
	elseif obj:IsA("Model") then
		for _,d in ipairs(obj:GetDescendants()) do
			if d:IsA("BasePart") then
				if op.material then d.Material=material(op.material) end
				if op.color then d.Color=color(op.color,d.Color) end
			end
		end
	end
end

local function addPointLight(op)
	local obj = findId(tostring(op.id or ""))
	if not obj then return end
	local host = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart",true)
	if not host then return end
	local l = host:FindFirstChild("NEON_Bridge_Light") or Instance.new("PointLight")
	l.Name="NEON_Bridge_Light"
	l.Color=color(op.color,host.Color)
	l.Brightness=tonumber(op.brightness) or 2
	l.Range=tonumber(op.range) or 24
	l.Shadows=op.shadows==true
	l.Parent=host
end

local function deleteId(op)
	local obj=findId(tostring(op.id or ""))
	if obj then obj:Destroy() end
end

local function clearRoot()
	root():ClearAllChildren()
end

local function selectId(op)
	local obj=findId(tostring(op.id or ""))
	if obj then Selection:Set({obj}) end
end

local function savePlace(op)
	local publish = op.publish == true
	local params = {PlaceId=EXPECTED_PLACE_ID, SaveWithoutPublish=not publish}
	local ok, err = pcall(function()
		AssetService:SavePlaceAsync(params)
	end)
	if not ok then warn("[NEON Bridge] savePlace failed:",err) end
end

local function apply(doc)
	if tonumber(doc.targetPlaceId) ~= EXPECTED_PLACE_ID then
		warn("[NEON Bridge] target mismatch")
		return
	end
	local rev=tonumber(doc.revision) or 0
	if rev <= lastRevision then return end

	for _,op in ipairs(doc.ops or {}) do
		local t=tostring(op.type or "")
		local ok,err=pcall(function()
			if t=="ping" then
			elseif t=="clear" or t=="clearTest" then clearRoot()
			elseif t=="createPart" then createPart(op)
			elseif t=="loadAsset" then loadAsset(op)
			elseif t=="transform" then transform(op)
			elseif t=="setProps" then setProps(op)
			elseif t=="addPointLight" then addPointLight(op)
			elseif t=="delete" then deleteId(op)
			elseif t=="select" then selectId(op)
			elseif t=="savePlace" then savePlace(op)
			else warn("[NEON Bridge] blocked op:",t)
			end
		end)
		if not ok then warn("[NEON Bridge] op failed",t,err) end
	end

	lastRevision=rev
	plugin:SetSetting("NEONFinalLastRevision_"..tostring(game.PlaceId),lastRevision)
	print("[NEON Bridge] APPLIED revision",lastRevision)
end

local function poll()
	local ok,body=pcall(function() return HttpService:GetAsync(COMMAND_URL,true) end)
	if not ok then warn("[NEON Bridge] HTTP:",body); return end
	local ok2,doc=pcall(function() return HttpService:JSONDecode(body) end)
	if ok2 and type(doc)=="table" then apply(doc) else warn("[NEON Bridge] bad JSON") end
end

local function start()
	if running then return end
	running=true; token+=1
	local mine=token
	button:SetActive(true)
	print("[NEON Bridge] FINAL ON")
	task.spawn(function()
		while running and token==mine do
			poll()
			task.wait(POLL_SECONDS)
		end
	end)
end

local function stop()
	running=false; token+=1
	button:SetActive(false)
	print("[NEON Bridge] FINAL OFF")
end

button.Click:Connect(function()
	if running then stop() else start() end
end)

print("[NEON Bridge] FINAL loaded; click toolbar button to start")
