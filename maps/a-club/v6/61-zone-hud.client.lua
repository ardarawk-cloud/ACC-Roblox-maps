-- BBYA V6 — LIVE INSPECTION ADDRESS
-- Reuses the compact top bar from 60-ui.client.lua. No new giant HUD.

local v6root=workspace:WaitForChild("BBYA V6 CLEANROOM",10)
local zoneFolder=v6root and v6root:FindFirstChild("ZONES")
local componentFolder=v6root and v6root:FindFirstChild("COMPONENTS")

local function insideBounds(pos,obj)
    local cx=obj:GetAttribute("BBYACenterX");local cy=obj:GetAttribute("BBYACenterY");local cz=obj:GetAttribute("BBYACenterZ")
    local sx=obj:GetAttribute("BBYASizeX");local sy=obj:GetAttribute("BBYASizeY");local sz=obj:GetAttribute("BBYASizeZ")
    if not (cx and cy and cz and sx and sy and sz) then return false end
    return math.abs(pos.X-cx)<=sx/2 and math.abs(pos.Y-cy)<=math.max(sy/2,7) and math.abs(pos.Z-cz)<=sz/2
end

local function findAddress(pos)
    local component=nil
    if componentFolder then
        for _,c in ipairs(componentFolder:GetChildren()) do
            if insideBounds(pos,c) then
                -- Prefer the smallest matching component when extents overlap.
                local volume=(c:GetAttribute("BBYASizeX") or 999)*(c:GetAttribute("BBYASizeY") or 999)*(c:GetAttribute("BBYASizeZ") or 999)
                if not component or volume<component.volume then component={obj=c,volume=volume} end
            end
        end
    end
    local zoneHit=nil
    if zoneFolder then
        for _,z in ipairs(zoneFolder:GetChildren()) do
            if insideBounds(pos,z) then
                local volume=(z:GetAttribute("BBYASizeX") or 999)*(z:GetAttribute("BBYASizeY") or 999)*(z:GetAttribute("BBYASizeZ") or 999)
                if not zoneHit or volume<zoneHit.volume then zoneHit={obj=z,volume=volume} end
            end
        end
    end
    return zoneHit and zoneHit.obj or nil,component and component.obj or nil
end

local last=""
RunService.RenderStepped:Connect(function()
    local char=player.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local z,c=findAddress(hrp.Position)
    local zCode=z and z:GetAttribute("BBYAZoneCode") or "--"
    local zName=z and z:GetAttribute("BBYAZoneName") or "TRANSIT"
    local cCode=c and c:GetAttribute("BBYAComponentCode") or nil
    local cName=c and c:GetAttribute("BBYAComponentName") or nil
    local key=zCode.."/"..tostring(cCode or "")
    if key==last then return end;last=key
    zone.Text=string.format("%s • %s",zCode,zName)
    if cCode and cName then build.Text=string.format("%s • %s",cCode,cName) else build.Text="V6 CLEANROOM" end
    player:SetAttribute("BBYAV6CurrentZone",zCode)
    player:SetAttribute("BBYAV6CurrentComponent",cCode or "")
end)

player:SetAttribute("BBYAV6AddressHUD",true)