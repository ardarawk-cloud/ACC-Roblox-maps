-- NEON Remote bootstrap (no loadstring)
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local url = "https://raw.githubusercontent.com/ardarawk-cloud/ACC-Roblox-maps/main/bridge/neon-studio/NEON_Studio_Bridge_FINAL.lua"

local ok, src = pcall(function()
	return HttpService:GetAsync(url, true)
end)
if not ok then
	error("NEON Remote bootstrap HTTP failed: "..tostring(src))
end

local module = Instance.new("ModuleScript")
module.Name = "NEON_REMOTE_RUNTIME"
module.Source = "return function(plugin)\n"..src.."\nend"
module.Parent = ServerStorage

local okRequire, runner = pcall(require, module)
if not okRequire then
	module:Destroy()
	error("NEON Remote bootstrap compile failed: "..tostring(runner))
end

local okRun, err = pcall(runner, plugin)
module:Destroy()
if not okRun then
	error("NEON Remote bootstrap runtime failed: "..tostring(err))
end
