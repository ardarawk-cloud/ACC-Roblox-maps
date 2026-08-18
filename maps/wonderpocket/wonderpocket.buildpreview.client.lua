local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("WonderPocket_Remotes")
local Placement = remotes:WaitForChild("Placement")

local activeItem = nil
local ghost = nil
local rotation = 0
local sizes = {
    CloudBed=Vector3.new(6,2,4), StarLamp=Vector3.new(1.5,4,1.5), RainbowSofa=Vector3.new(6,2.5,2.5),
    BunnyChair=Vector3.new(2.5,3,2.5), ToyChest=Vector3.new(3,2,2), MiniAquarium=Vector3.new(4,3,2),
}

local function clearGhost()
    if ghost then ghost:Destroy(); ghost=nil end
    activeItem=nil
end

local function begin(itemId)
    clearGhost()
    if not sizes[itemId] then return end
    activeItem=itemId
    ghost=Instance.new("Part")
    ghost.Name="WP_Ghost_"..itemId
    ghost.Size=sizes[itemId]
    ghost.Anchored=true
    ghost.CanCollide=false
    ghost.CanTouch=false
    ghost.CanQuery=false
    ghost.Transparency=.5
    ghost.Material=Enum.Material.ForceField
    ghost.Parent=workspace
end

local function raycastToWorld(screenPos)
    local camera=workspace.CurrentCamera
    if not camera then return nil end
    local ray=camera:ViewportPointToRay(screenPos.X,screenPos.Y)
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={player.Character, ghost}
    local result=workspace:Raycast(ray.Origin,ray.Direction*500,params)
    return result and result.Position or nil
end

RunService.RenderStepped:Connect(function()
    if not ghost or not activeItem then return end
    local pos
    if UserInputService.TouchEnabled then
        local vp=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800,600)
        pos=raycastToWorld(Vector2.new(vp.X*.5,vp.Y*.58))
    else
        pos=raycastToWorld(UserInputService:GetMouseLocation())
    end
    if pos then
        local y=math.max(1,math.floor(pos.Y+.5))
        ghost.CFrame=CFrame.new(math.floor(pos.X+.5),y,math.floor(pos.Z+.5))*CFrame.Angles(0,math.rad(rotation),0)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not ghost then return end
    if input.KeyCode==Enum.KeyCode.R then
        rotation=(rotation+90)%360
    elseif input.UserInputType==Enum.UserInputType.MouseButton1 then
        Placement:FireServer("PLACE",activeItem,ghost.CFrame)
    elseif input.KeyCode==Enum.KeyCode.Escape then
        clearGhost()
    end
end)

local bind=Instance.new("BindableEvent")
bind.Name="WP_StartBuildPreview"
bind.Parent=script
bind.Event:Connect(begin)

Placement.OnClientEvent:Connect(function(action, ok)
    if action=="RESULT" and ok then clearGhost() end
end)

print("[WONDERPOCKET] Furniture ghost preview loaded")
