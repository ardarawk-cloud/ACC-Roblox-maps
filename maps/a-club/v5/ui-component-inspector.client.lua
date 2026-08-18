-- [UI-QC-CODES] TWO-LEVEL ZONE + COMPONENT INSPECTOR
-- Example screenshot address: A4 / 06 DJ BOOTH. Keeps maintenance surgical without visible world debug boards.

phaseLine.Text="V5.3 MASTER • CODED"
zoneLine.Size=UDim2.new(1,-220,0,22)
zoneLine.TextSize=12
zoneLine.TextTruncate=Enum.TextTruncate.AtEnd

local qcRootName="BBYA V5.3 MASTER PLAN"
local qcAcc=0
local lastAddress=""

local function findInside(pos,parent,codeAttr,nameAttr,parentZone)
 local bestCode,bestName,bestVol
 for _,f in ipairs(parent:GetChildren()) do
  if f:IsA("Folder") then
   local code=f:GetAttribute(codeAttr)
   if code and (not parentZone or f:GetAttribute("BBYAParentZone")==parentZone) then
    local cx,cy,cz=f:GetAttribute("BBYACenterX"),f:GetAttribute("BBYACenterY"),f:GetAttribute("BBYACenterZ")
    local sx,sy,sz=f:GetAttribute("BBYASizeX"),f:GetAttribute("BBYASizeY"),f:GetAttribute("BBYASizeZ")
    if cx and cy and cz and sx and sy and sz then
     local yHalf=math.max(sy/2,5)
     if math.abs(pos.X-cx)<=sx/2 and math.abs(pos.Y-cy)<=yHalf and math.abs(pos.Z-cz)<=sz/2 then
      local vol=sx*math.max(sy,1)*sz
      if not bestVol or vol<bestVol then
       bestCode,bestName,bestVol=code,f:GetAttribute(nameAttr) or "AREA",vol
      end
     end
    end
   end
  end
 end
 return bestCode,bestName
end

local function updateQCAddress()
 local char=player.Character
 local hrp=char and char:FindFirstChild("HumanoidRootPart")
 local master=workspace:FindFirstChild(qcRootName)
 if not hrp or not master then return end
 local p=hrp.Position
 local zoneCode,zoneName=findInside(p,master,"BBYAZoneCode","BBYAZoneName")
 zoneCode,zoneName=zoneCode or "--",zoneName or "TRANSIT"
 local components=master:FindFirstChild("BBYA COMPONENT INDEX")
 local componentCode,componentName
 if components and zoneCode~="--" then
  componentCode,componentName=findInside(p,components,"BBYAComponentCode","BBYAComponentName",zoneCode)
 end
 local address=zoneCode.."|"..tostring(componentCode or "--")
 if address==lastAddress then return end
 lastAddress=address
 if componentCode then
  zoneLine.Text=zoneCode.." / "..componentCode.." • "..componentName
  inspector.Text="MACRO: ["..zoneCode.."] "..zoneName.."\nCOMPONENT: ["..componentCode.."] "..componentName.."\nScreenshot address: "..zoneCode.." / "..componentCode
 else
  zoneLine.Text="ZONE "..zoneCode.." • "..zoneName
  inspector.Text="CURRENT: ["..zoneCode.."] "..zoneName.."\nNo micro-component at this exact position."
 end
 player:SetAttribute("BBYACurrentZone",zoneCode)
 player:SetAttribute("BBYACurrentZoneName",zoneName)
 player:SetAttribute("BBYACurrentComponent",componentCode or "--")
 player:SetAttribute("BBYACurrentComponentName",componentName or "TRANSIT")
end

RunService.Heartbeat:Connect(function(dt)
 qcAcc+=dt
 if qcAcc>=.25 then qcAcc=0;updateQCAddress() end
end)

player:SetAttribute("BBYAUIInspectionSchema","MACRO_PLUS_COMPONENT")
