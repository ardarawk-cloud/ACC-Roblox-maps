-- BBYA SOCIAL HUB — OWNER HARD CLEANUP
-- Hard owner request: no lingering CLUB directional signs and no loose ground-floor chairs/sofas.
-- Preserve VIP partition/door, rooftop access, MENU, Support, Hybrid Auto DJ and street frontage.

local removedSeats=0
local removedSigns=0

local groundSeatPrefixes={
    "ARRIVAL SEAT",
    "ATRIUM SOFA",
    "CLUB WATCH SOFA",
    "VIP EAST SOFA",
    "VIP WEST SOFA",
    "VIP QUEEN SOFA",
}

local clubSignNames={
    ["ROUTE CLUB"]=true,
    ["CLUB ENTRY WAYFIND"]=true,
    ["CLUB SIGN"]=true,
}

local function startsWithAny(name,prefixes)
    for _,prefix in ipairs(prefixes) do
        if string.sub(name,1,#prefix)==prefix then
            return true
        end
    end
    return false
end

-- Collect first; destroying while walking GetDescendants can otherwise skip siblings.
local kill={}
for _,obj in ipairs(workspace:GetDescendants()) do
    local name=obj.Name
    if startsWithAny(name,groundSeatPrefixes) then
        table.insert(kill,{obj=obj,kind="seat"})
    elseif clubSignNames[name] then
        table.insert(kill,{obj=obj,kind="sign"})
    elseif obj:IsA("TextLabel") then
        local text=string.upper(obj.Text or "")
        if text=="CLUB  ←" or text=="CLUB ←" or text=="CLUB / DANCE" then
            local carrier=obj:FindFirstAncestorWhichIsA("BasePart")
            if carrier then
                table.insert(kill,{obj=carrier,kind="sign"})
            end
        end
    end
end

local destroyed={}
for _,row in ipairs(kill) do
    local obj=row.obj
    if obj and obj.Parent and not destroyed[obj] then
        destroyed[obj]=true
        obj:Destroy()
        if row.kind=="seat" then removedSeats+=1 else removedSigns+=1 end
    end
end

-- Verification attributes are intentionally strict: zero matching remnants means this cleanup passed.
local seatRemnants=0
local signRemnants=0
for _,obj in ipairs(workspace:GetDescendants()) do
    if startsWithAny(obj.Name,groundSeatPrefixes) then seatRemnants+=1 end
    if clubSignNames[obj.Name] then signRemnants+=1 end
    if obj:IsA("TextLabel") then
        local text=string.upper(obj.Text or "")
        if text=="CLUB  ←" or text=="CLUB ←" or text=="CLUB / DANCE" then signRemnants+=1 end
    end
end

workspace:SetAttribute("BBYAGroundFloorSeatingCleared",seatRemnants==0)
workspace:SetAttribute("BBYAGroundFloorSeatsRemoved",removedSeats)
workspace:SetAttribute("BBYAGroundFloorSeatRemnants",seatRemnants)
workspace:SetAttribute("BBYAClubDirectionalSignsCleared",signRemnants==0)
workspace:SetAttribute("BBYAClubDirectionalSignsRemoved",removedSigns)
workspace:SetAttribute("BBYAClubDirectionalSignRemnants",signRemnants)
workspace:SetAttribute("BBYAOwnerHardCleanup","NO_CLUB_SIGN_NO_GROUND_SEATS")
