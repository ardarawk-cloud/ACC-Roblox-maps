-- BBYA V6 — PHYSICAL SPACE -> UI PROMPTS
-- Facilities open the matching social tool from the space itself; no giant instructional signs required.

local OpenPanel=net:FindFirstChild("OpenPanel") or Instance.new("RemoteEvent")
OpenPanel.Name="OpenPanel"
OpenPanel.Parent=net

local function bindPrompt(partName,actionText,objectText,panelName,mode)
    local target=workspace:FindFirstChild(partName,true)
    if not target or not target:IsA("BasePart") then
        warn("[BBYA V6 PROMPT] missing target",partName)
        return false
    end
    local old=target:FindFirstChild("BBYA OPEN PANEL")
    if old then old:Destroy() end
    local pr=Instance.new("ProximityPrompt")
    pr.Name="BBYA OPEN PANEL"
    pr.ActionText=actionText
    pr.ObjectText=objectText
    pr.HoldDuration=0
    pr.MaxActivationDistance=9
    pr.RequiresLineOfSight=false
    pr.Parent=target
    pr.Triggered:Connect(function(player)
        OpenPanel:FireClient(player,panelName,mode or "")
    end)
    target:SetAttribute("BBYAInteractiveFacility",panelName)
    return true
end

local bound=0
local specs={
    {"A3 LOOK PEDESTAL","OUTFIT CAM","LOOK STUDIO","PHOTO","OUTFIT"},
    {"A3 SELFIE PLATFORM","PHOTO CAM","SELFIE SPOT","PHOTO","OUTFIT"},
    {"A4 DANCE FLOOR","DANCE","CLUB FACILITY","DANCE",""},
    {"A4 DJ BOOTH","MUSIC","DJ BOOTH","MUSIC",""},
    {"D2 POOL DJ DESK","MUSIC","POOL DJ","MUSIC",""},
    {"D6 VIEW PLATFORM","FREECAM","CITY VIEW","PHOTO","FREECAM"},
}
for _,s in ipairs(specs) do if bindPrompt(s[1],s[2],s[3],s[4],s[5]) then bound+=1 end end

workspace:SetAttribute("BBYAV6PhysicalUIPrompts",bound)
