local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("WONDERPOCKET_Remotes")
local Placement = remotes:WaitForChild("Placement")

local bus = playerGui:FindFirstChild("WP_BuildCommand") or Instance.new("BindableEvent")
bus.Name = "WP_BuildCommand"
bus.Parent = playerGui

local activeItem, ghost = nil, nil
local rotation = 0
local sizes = {
    CloudBed=Vector3.new(6,2,4), StarLamp=Vector3.new(1.5,4,1.5), RainbowSofa=Vector3.new(6,2.5,2.5),
    BunnyChair=Vector3.new(2.5,3,2.5), ToyChest=Vector3.new(3,2,2), MiniAquarium=Vector3.new(4,3,2),
}

local function clearGhost()
    if ghost then ghost:Destroy() end
    ghost=nil;activeItem=nil;rotation=0
    player:SetAttribute("WP_BuildActive",false)
end

local function begin(itemId)
    clearGhost()
    if not sizes[itemId] then return end
    activeItem=itemId
    ghost=Instance.new("Part")
    ghost.Name="WP_Ghost_"..itemId
    ghost.Size=sizes[itemId]
    ghost.Anchored=true;ghost.CanCollide=false;ghost.CanTouch=false;ghost.CanQuery=false
    ghost.Transparency=.48;ghost.Material=Enum.Material.ForceField
    ghost.Color=Color3.fromRGB(110,225,255)
    ghost.Parent=workspace
    ghost:SetAttribute("WP_Valid",false)
    player:SetAttribute("WP_BuildActive",true)
end

local function buildSurfaces()
    local surfaces={}
    local plotIndex=tonumber(player:GetAttribute("WP_PlotIndex")) or 0
    local plots=workspace:FindFirstChild("WONDERPOCKET_PlayerPlots")
    local plot=plots and plotIndex>0 and plots:FindFirstChild("Plot"..plotIndex)
    if plot and plot:IsA("BasePart") then table.insert(surfaces,plot) end

    local homes=workspace:FindFirstChild("WONDERPOCKET_PlotHomes")
    local home=homes and homes:FindFirstChild(tostring(player.UserId))
    local floor=home and home:FindFirstChild("Floor")
    if floor and floor:IsA("BasePart") then table.insert(surfaces,floor) end
    return surfaces
end

local function raycastToBuildSurface(screenPos)
    local camera=workspace.CurrentCamera;if not camera then return nil end
    local surfaces=buildSurfaces()
    if #surfaces==0 then return nil end

    local ray=camera:ViewportPointToRay(screenPos.X,screenPos.Y)
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances=surfaces
    local result=workspace:Raycast(ray.Origin,ray.Direction*500,params)
    if not result or not result.Instance or not result.Instance:IsA("BasePart") then return nil end

    local supportTop=result.Instance.Position.Y+(result.Instance.Size.Y*.5)
    return Vector3.new(result.Position.X,supportTop,result.Position.Z)
end

local function footprintValid(position,size,degrees)
    local cx=tonumber(player:GetAttribute("WP_PlotCenterX"));local cz=tonumber(player:GetAttribute("WP_PlotCenterZ"))
    local hx=tonumber(player:GetAttribute("WP_PlotHalfX"));local hz=tonumber(player:GetAttribute("WP_PlotHalfZ"))
    if not (cx and cz and hx and hz) then return false end
    local quarter=math.floor((degrees/90)+.5)
    local sx,sz=size.X,size.Z
    if math.abs(quarter)%2==1 then sx,sz=sz,sx end
    return math.abs(position.X-cx)+sx/2<=hx and math.abs(position.Z-cz)+sz/2<=hz
end

RunService.RenderStepped:Connect(function()
    if not ghost or not activeItem then return end
    local camera=workspace.CurrentCamera;if not camera then return end
    local support
    if UserInputService.TouchEnabled then
        local vp=camera.ViewportSize
        support=raycastToBuildSurface(Vector2.new(vp.X*.5,vp.Y*.55))
    else
        support=raycastToBuildSurface(UserInputService:GetMouseLocation())
    end

    if not support then
        ghost:SetAttribute("WP_Valid",false)
        ghost.Color=Color3.fromRGB(255,105,115)
        return
    end

    local size=sizes[activeItem]
    local snapped=Vector3.new(
        math.floor(support.X+.5),
        support.Y+(size.Y*.5),
        math.floor(support.Z+.5)
    )
    local valid=footprintValid(snapped,size,rotation)
    ghost.CFrame=CFrame.new(snapped)*CFrame.Angles(0,math.rad(rotation),0)
    ghost.Color=valid and Color3.fromRGB(110,225,255) or Color3.fromRGB(255,105,115)
    ghost:SetAttribute("WP_Valid",valid)
end)

local function place()
    if ghost and activeItem and ghost:GetAttribute("WP_Valid") then Placement:FireServer("PLACE",activeItem,ghost.CFrame) end
end
local function rotate() if ghost then rotation=(rotation+90)%360 end end

UserInputService.InputBegan:Connect(function(input,processed)
    if processed or not ghost then return end
    if input.KeyCode==Enum.KeyCode.R then rotate()
    elseif input.UserInputType==Enum.UserInputType.MouseButton1 and not UserInputService.TouchEnabled then place()
    elseif input.KeyCode==Enum.KeyCode.Escape then clearGhost() end
end)

bus.Event:Connect(function(action,itemId)
    if action=="BEGIN" then begin(itemId)
    elseif action=="ROTATE" then rotate()
    elseif action=="PLACE" then place()
    elseif action=="CANCEL" then clearGhost() end
end)

Placement.OnClientEvent:Connect(function(action,ok,reason)
    if action=="RESULT" then
        if ok then player:SetAttribute("WP_LastBuildError","");clearGhost()
        else player:SetAttribute("WP_LastBuildError",tostring(reason or "FAILED")) end
    end
end)

print("[WONDERPOCKET] Own-surface mobile build preview loaded")
