-- BBYA SOCIAL HUB — DJ WALL CLIENT RENDER BRIDGE v1
-- Reads the authoritative server-side wall state and broadcasts a compact render state.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
if not remotes then return end
local wallRemote=remotes:WaitForChild("DJWall",30)
if not wallRemote then return end
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local system=root:WaitForChild("DJWallMessageSystem",30)
if not system then return end

local lastKey=""
local lastPush=0

local function findGui()
 local final=system:FindFirstChild("FinalMountedWall")
 if final then
  local screen=final:FindFirstChild("PrestigeLED")
  if screen then
   local gui=screen:FindFirstChild("DJWallUI")
   if gui and gui:IsA("SurfaceGui") then return gui end
  end
 end
 for _,obj in ipairs(system:GetDescendants()) do
  if obj:IsA("SurfaceGui") and obj.Name=="DJWallUI" then return obj end
 end
 return nil
end

local function readMessage(gui)
 local message=gui and gui:FindFirstChild("MessageMode",true)
 if not message or not message:IsA("GuiObject") then
  return {mode="idle"}
 end
 if not message.Visible then return {mode="idle"} end

 local category="BBYA LIVE MESSAGE"
 local mainText=""
 local from=""
 for _,obj in ipairs(message:GetDescendants()) do
  if obj:IsA("TextLabel") then
   local text=tostring(obj.Text or "")
   if text:find("BBYA",1,true) and text:find("MESSAGE",1,true) then
    category=text
   elseif text:find("FROM",1,true)==1 then
    from=text
   elseif not text:find("MAKE THE NIGHT YOURS",1,true) and obj.Size.Y.Scale>=.25 and #text>0 then
    mainText=text
   end
  end
 end
 return {mode="message",category=category,text=mainText,from=from}
end

task.spawn(function()
 while system.Parent do
  task.wait(.35)
  local state=readMessage(findGui())
  local key=table.concat({state.mode or "idle",state.category or "",state.text or "",state.from or ""},"|")
  if key~=lastKey or os.clock()-lastPush>2 then
   lastKey=key
   lastPush=os.clock()
   wallRemote:FireAllClients("wallRenderState",state)
  end
 end
end)

print("[BBYA] DJ wall render bridge v1 online")