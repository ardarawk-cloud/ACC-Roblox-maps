-- BBYA SOCIAL HUB — OWNER SEAT CLEANUP
-- Owner request: clear the loose chairs/sofas from the main ground-floor club/social/VIP area.
-- Rooftop loungers, mezzanine seating and the Queen throne are intentionally preserved.

local removed=0
for _,obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Seat") then
        local n=obj.Name
        if string.find(n,"ATRIUM SOFA",1,true)
            or string.find(n,"CLUB WATCH SOFA",1,true)
            or string.find(n,"VIP EAST SOFA",1,true)
            or string.find(n,"VIP WEST SOFA",1,true)
            or string.find(n,"VIP QUEEN SOFA",1,true)
            or string.find(n,"ARRIVAL SEAT",1,true) then
            obj:Destroy()
            removed+=1
        end
    end
end

workspace:SetAttribute("BBYAGroundFloorSeatingCleared",true)
workspace:SetAttribute("BBYAGroundFloorSeatsRemoved",removed)
