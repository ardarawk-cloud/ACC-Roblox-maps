local Workspace=game:GetService("Workspace")

-- TRACK 01 ticket flow v1.1
-- Scope: ticket visibility / forward routing only. No unrelated environment changes.
local deadline=os.clock()+90
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_LOBBY_FLOW_CLEANUP_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
local architecture=world and world:FindFirstChild("Architecture")
if not (world and architecture) then return end
local cleanup=world:FindFirstChild("TRACK01_LobbyFlowCleanup_v1")
if not cleanup then return end

local function removePrompts(obj)
    if not obj then return end
    for _,d in ipairs(obj:GetDescendants()) do
        if d:IsA("ProximityPrompt") and (d.Name=="TRACK01LobbyPrompt" or d.ActionText=="CLAIM TICKET") then
            d:Destroy()
        end
    end
end

-- Retire the interaction at the back-corner legacy counter. The counter remains scenery.
local station=architecture:FindFirstChild("OldStation")
local oldCounter=station and station:FindFirstChild("TicketCounter")
removePrompts(oldCounter)
local oldStatus=cleanup:FindFirstChild("TicketStatus")
if oldStatus then oldStatus:Destroy() end
local oldForward=cleanup:FindFirstChild("TicketForwardValidator")
if oldForward then oldForward:Destroy() end

local C={
    black=Color3.fromRGB(16,17,17),
    charcoal=Color3.fromRGB(31,32,31),
    steel=Color3.fromRGB(91,92,88),
    cream=Color3.fromRGB(205,190,157),
    amber=Color3.fromRGB(223,145,62),
    green=Color3.fromRGB(74,126,83),
}
local function part(parent,name,size,cf,color,material,collide)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Metal
    p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=false
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
    return p
end
local function surfaceText(target,text,color)
    local gui=Instance.new("SurfaceGui")
    gui.Name="TicketForwardDisplay";gui.Face=Enum.NormalId.Left
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=52;gui.LightInfluence=0.15;gui.Parent=target
    local label=Instance.new("TextLabel")
    label.Name="StatusText";label.Size=UDim2.fromScale(1,1);label.BackgroundColor3=C.black;label.BackgroundTransparency=0.04
    label.BorderSizePixel=0;label.Text=text;label.TextColor3=color;label.TextScaled=true;label.TextWrapped=true;label.Font=Enum.Font.GothamBold;label.Parent=gui
    return label
end

-- Compact station-style validator placed on the natural forward route:
-- spawn (-38,-123) -> ticket (-31.5,-121) -> security (-16...) -> Platform 01.
local forward=Instance.new("Folder")
forward.Name="TicketForwardValidator";forward.Parent=cleanup
local pedestal=part(forward,"TicketPedestal",Vector3.new(1.4,3.2,2.4),CFrame.new(-31.5,2.65,-121.0),C.charcoal,Enum.Material.Metal,true)
part(forward,"TicketPedestalTop",Vector3.new(1.65,0.20,2.65),CFrame.new(-31.5,4.32,-121.0),C.steel,Enum.Material.Metal,false)
local display=part(forward,"TicketClaimDisplay",Vector3.new(0.16,1.35,4.2),CFrame.new(-30.72,5.15,-121.0),C.black,Enum.Material.Metal,false)
local label=surfaceText(display,"NIGHT TICKET  •  CLAIM",C.amber)

local prompt=Instance.new("ProximityPrompt")
prompt.Name="TRACK01LobbyPrompt";prompt.ActionText="CLAIM TICKET";prompt.ObjectText="NIGHT TICKET • TRACK 01"
prompt.HoldDuration=0.20;prompt.MaxActivationDistance=9;prompt.RequiresLineOfSight=false
prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.Parent=pedestal

prompt.Triggered:Connect(function(plr)
    if plr:GetAttribute("TRACK01_TICKET")==true then
        label.Text="TICKET READY  •  SECURITY →";label.TextColor3=C.green
        return
    end
    plr:SetAttribute("TRACK01_TICKET",true)
    label.Text="TICKET ISSUED  •  SECURITY →";label.TextColor3=C.green
    task.delay(2.4,function()
        if label.Parent then label.Text="NIGHT TICKET  •  CLAIM";label.TextColor3=C.amber end
    end)
end)

-- Future joins/respawns face the forward validator, never the back corner.
local spawn=root:FindFirstChild("TRACK01_SPAWN",true)
if spawn and spawn:IsA("BasePart") then
    local pos=Vector3.new(-38,2.05,-123)
    spawn.CFrame=CFrame.lookAt(pos,Vector3.new(-31.5,4.2,-121.0))
end

root:SetAttribute("LobbyFlowVersion","1.1.0")
root:SetAttribute("TicketFlowMode","FORWARD_VALIDATOR")
Workspace:SetAttribute("ACC_TRACK01_TICKET_FORWARD_FLOW_READY",true)
print("[TRACK 01] ticket flow v1.1 ready: forward validator -> security -> Platform 01")
