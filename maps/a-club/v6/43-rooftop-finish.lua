-- BBYA V6 — ROOFTOP RESORT FINISH PASS
-- Warm tropical hospitality, city-view atmosphere, restrained BBYA accent. Never a second neon club.

-- Warm deck bollards define circulation without blocking it.
for _,cfg in ipairs({
    {-42,58},{-21,58},{21,58},{42,58},
    {-42,126},{42,126},{-58,74},{58,74},{-58,110},{58,110},
}) do
    local x,z=cfg[1],cfg[2]
    part(D2,"ROOF WARM BOLLARD "..x.." "..z,Vector3.new(.8,2.4,.8),CFrame.new(x,41.7,z),P.charcoal,Enum.Material.Metal,0,true,nil)
    local l=light(D2,"ROOF BOLLARD LIGHT "..x.." "..z,Vector3.new(x,42.5,z),P.warm,.55,7,nil)
    l.Parent:SetAttribute("BBYADecorativeLight",true)
end

-- Pool underwater glow: cyan water readability, low brightness, no rave language.
for _,x in ipairs({-22,0,22}) do
    for _,z in ipairs({82,101}) do
        local l=light(D2,"D2 POOL UNDERWATER "..x.." "..z,Vector3.new(x,39.6,z),Color3.fromRGB(103,211,226),.62,12,"13")
        l.Parent:SetAttribute("BBYADecorativeLight",true)
    end
end

-- Tropical planting groups around the resort perimeter.
for _,cfg in ipairs({{-43,69},{43,69},{-43,119},{43,119}}) do
    palm(D2,"D2 RESORT PALM "..cfg[1].." "..cfg[2],Vector3.new(cfg[1],41.5,cfg[2]),8,"13")
end
for _,cfg in ipairs({{-39,134},{39,134}}) do
    planter(D5,"D5 GREEN PLANTER "..cfg[1],Vector3.new(cfg[1],41.4,cfg[2]),Vector3.new(7,1.8,5),"16")
end

-- Cabana curtains as translucent side panels.
for _,x in ipairs({-33,-11,11,33}) do
    local l=part(D5,"D5 CABANA CURTAIN L "..x,Vector3.new(.18,5.5,8),CFrame.new(x-5,44.5,133),P.cream,Enum.Material.Fabric,.32,false,"16")
    local r=part(D5,"D5 CABANA CURTAIN R "..x,Vector3.new(.18,5.5,8),CFrame.new(x+5,44.5,133),P.cream,Enum.Material.Fabric,.32,false,"16")
    l.CanQuery=false;r.CanQuery=false
end

-- Sky Bar back wall shelves, warm bottles, not neon overload.
part(D3,"D3 BACKBAR",Vector3.new(1,8,34),CFrame.new(69.2,45,92),P.black,Enum.Material.Slate,0,false,"15")
for _,y in ipairs({43,45.5,48}) do
    part(D3,"D3 BACKBAR SHELF "..y,Vector3.new(.5,.3,28),CFrame.new(68.6,y,92),P.wood,Enum.Material.WoodPlanks,0,false,"15")
end
for _,z in ipairs({80,86,92,98,104}) do
    part(D3,"D3 BOTTLE "..z,Vector3.new(.7,1.7,.7),CFrame.new(68.2,46.5,z),Color3.fromRGB(112,72,51),Enum.Material.Glass,.18,false,"15")
end

-- View-deck city atmosphere: distant silhouettes with sparse warm windows.
-- Decorative only, non-collidable, far beyond the safety rail.
local skylineHeights={26,38,31,48,24,42,34,52,29,44,36}
for i,h in ipairs(skylineHeights) do
    local x=-75+(i-1)*15
    local z=-78-(i%3)*8
    local building=part(D6,"D6 CITY BLOCK "..i,Vector3.new(11,h,10),CFrame.new(x,40+h/2,z),Color3.fromRGB(12,14,20),Enum.Material.SmoothPlastic,0,false,"17")
    building.CanQuery=false
    for _,dy in ipairs({8,16,24}) do
        if dy<h-3 then
            local window=part(D6,"D6 CITY WINDOW "..i.." "..dy,Vector3.new(6,.22,.18),CFrame.new(x,40+dy,z+5.1),Color3.fromRGB(255,190,104),Enum.Material.Neon,.18,false,"17")
            window.CanQuery=false
        end
    end
end

-- Subtle warm photo-deck edge; one pink BBYA accent only.
neon(D6,"D6 VIEW WARM EDGE",Vector3.new(72,.12,.12),CFrame.new(0,41.15,46.8),P.warm,"17")
neon(D6,"D6 BBYA PHOTO ACCENT",Vector3.new(16,.1,.1),CFrame.new(0,48.8,48),P.pink,"17")

workspace:SetAttribute("BBYAV6RooftopFinish","TROPICAL_PREMIUM_PASS_1")
