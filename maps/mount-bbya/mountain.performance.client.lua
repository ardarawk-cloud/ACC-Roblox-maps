-- Mountain Social Adventure performance guard v2.8
local Players=game:GetService('Players');local RunService=game:GetService('RunService');local Lighting=game:GetService('Lighting')
local player=Players.LocalPlayer;local samples={};local elapsed=0;local low=false;local lodElapsed=0;local detailParts={}
local function avg()local t=0;for _,v in ipairs(samples)do t+=v end;return #samples>0 and t/#samples or 60 end
local function mode(on)
 if on==low then return end;low=on;player:SetAttribute('ACC_LowFX',on)
 local at=Lighting:FindFirstChildOfClass('Atmosphere');if at and on then at.Glare=math.min(at.Glare,.04) end
 for _,o in ipairs(workspace:GetDescendants())do
  if o:IsA('ParticleEmitter') then local base=o:GetAttribute('ACC_BaseRate');if base==nil then o:SetAttribute('ACC_BaseRate',o.Rate);base=o.Rate end;o.Rate=on and math.floor(base*.35) or base
  elseif o:IsA('PointLight') and o.Name~='SummitBeacon' then local b=o:GetAttribute('ACC_BaseBrightness');if b==nil then o:SetAttribute('ACC_BaseBrightness',o.Brightness);b=o.Brightness end;o.Brightness=on and b*.65 or b end
 end
end
local thresholds={MicroDetailV48=430,EnvironmentV49=520,ImmersiveV50=500,WorldLifeV51=540}
local function collectLOD()
 table.clear(detailParts)
 local root=workspace:FindFirstChild('ACC_MountainSocial');if not root then return end
 for folderName,dist in pairs(thresholds)do
  local folder=root:FindFirstChild(folderName)
  if folder then
   for _,o in ipairs(folder:GetDescendants())do
    if o:IsA('BasePart') then
     local maxSize=math.max(o.Size.X,o.Size.Y,o.Size.Z)
     if not o.CanCollide or maxSize<8 then table.insert(detailParts,{p=o,d=dist}) end
    end
   end
  end
 end
 player:SetAttribute('ACC_LODPartCount',#detailParts)
end
local function updateLOD()
 local c=player.Character;local hrp=c and c:FindFirstChild('HumanoidRootPart');if not hrp then return end
 if #detailParts==0 then collectLOD() end
 local pos=hrp.Position;local factor=low and .72 or 1
 for i=#detailParts,1,-1 do
  local item=detailParts[i];local p=item.p
  if not p or not p.Parent then table.remove(detailParts,i) else p.LocalTransparencyModifier=((p.Position-pos).Magnitude>item.d*factor) and 1 or 0 end
 end
end
task.delay(35,function()collectLOD();updateLOD()end)
RunService.RenderStepped:Connect(function(dt)
 elapsed+=dt;lodElapsed+=dt
 if dt>0 then table.insert(samples,math.min(120,1/dt));if #samples>90 then table.remove(samples,1)end end
 if elapsed>=4 then elapsed=0;local fps=avg();if fps<36 then mode(true)elseif fps>52 then mode(false)end end
 if lodElapsed>=2.5 then lodElapsed=0;updateLOD() end
end)
player:SetAttribute('ACC_PerformanceGuard','v2.8-local-lod')