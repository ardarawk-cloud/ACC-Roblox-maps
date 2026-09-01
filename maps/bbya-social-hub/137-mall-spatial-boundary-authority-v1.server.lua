-- BBYA SOCIAL HUB — MALL SPATIAL BOUNDARY AUTHORITY v1
-- Final tenant-local spatial guard. Uses each tenant Floor CFrame/Size as the source of truth,
-- then pulls PremiumRetailGalleryV6 visual parts back inside that footprint when a previous
-- Mall pass places them offside. No global coordinates are used for tenant correction.
-- Mall architecture / Cinema / lift / atrium / audio / fishing / global Lighting / VIP /
-- economy and monetization logic are intentionally untouched.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",60)
if not root then return end

local mall=root:WaitForChild("BBYAMall",90)
if not mall then return end

-- v6 is the visual authority we are guarding. Waiting for it makes this pass deterministic.
if not mall:WaitForChild("MallPremiumGalleryV6",120) then
 warn("[MALL_BOUNDS] aborted: MallPremiumGalleryV6 missing")
 return
end

local requiredTenants={
 "Tenant_luma","Tenant_stride","Tenant_byte","Tenant_daily","Tenant_mono","Tenant_muse",
 "Tenant_north","Tenant_street","Tenant_page","Tenant_glow","Tenant_sound","Tenant_fit",
}

local old=mall:FindFirstChild("MallSpatialBoundaryAuthorityV1")
if old then old:Destroy() end
local authority=Instance.new("Model")
authority.Name="MallSpatialBoundaryAuthorityV1"
authority:SetAttribute("Pass","MALL_SPATIAL_BOUNDARY_AUTHORITY_V1")
authority:SetAttribute("SpatialBoundsSource","TENANT_FLOOR_CFRAME")
authority:SetAttribute("TenantLocalProjection",true)
authority:SetAttribute("CinemaUntouched",true)
authority:SetAttribute("AtriumUntouched",true)
authority:SetAttribute("GlobalLightingUntouched",true)
authority:SetAttribute("AudioUntouched",true)
authority:SetAttribute("FishingUntouched",true)
authority:SetAttribute("VIPUntouched",true)
authority:SetAttribute("EconomyUntouched",true)
authority.Parent=mall

local MARGIN=0.08
local EPS=0.01
local checked=0
local corrected=0
local oversized=0
local tenantsChecked=0

local function projectedHalfExtents(relativeCf,size)
 local h=size*0.5
 local r=relativeCf.RightVector
 local u=relativeCf.UpVector
 local l=relativeCf.LookVector
 local ex=math.abs(r.X)*h.X + math.abs(u.X)*h.Y + math.abs(l.X)*h.Z
 local ez=math.abs(r.Z)*h.X + math.abs(u.Z)*h.Y + math.abs(l.Z)*h.Z
 return ex,ez
end

local function clampGalleryPart(tenant,floor,p)
 local rel=floor.CFrame:ToObjectSpace(p.CFrame)
 local ex,ez=projectedHalfExtents(rel,p.Size)
 local halfX=floor.Size.X*0.5-MARGIN
 local halfZ=floor.Size.Z*0.5-MARGIN

 checked+=1
 p:SetAttribute("MallSpatialCheckedV1",true)

 -- Never silently resize geometry. An impossible fit becomes a hard QC signal.
 if ex>halfX+EPS or ez>halfZ+EPS then
  oversized+=1
  p:SetAttribute("MallSpatialOversizeV1",true)
  warn(string.format("[MALL_BOUNDS_OVERSIZE]|%s|%s|extent=%.3f,%.3f|limit=%.3f,%.3f",
   tenant.Name,p:GetFullName(),ex,ez,halfX,halfZ))
  return
 end

 local pos=rel.Position
 local minX=-halfX+ex
 local maxX= halfX-ex
 local minZ=-halfZ+ez
 local maxZ= halfZ-ez
 local nx=math.clamp(pos.X,minX,maxX)
 local nz=math.clamp(pos.Z,minZ,maxZ)

 if math.abs(nx-pos.X)>EPS or math.abs(nz-pos.Z)>EPS then
  local rotationOnly=rel-rel.Position
  local oldWorld=p.Position
  p.CFrame=floor.CFrame*(CFrame.new(nx,pos.Y,nz)*rotationOnly)
  corrected+=1
  p:SetAttribute("MallSpatialCorrectedV1",true)
  print(string.format("[MALL_BOUNDS]|%s|%s|old=%.3f,%.3f|new=%.3f,%.3f",
   tenant.Name,p.Name,oldWorld.X,oldWorld.Z,p.Position.X,p.Position.Z))
 end
end

for _,tenantName in ipairs(requiredTenants) do
 local tenant=mall:WaitForChild(tenantName,90)
 if not tenant then
  warn("[MALL_BOUNDS] missing tenant: "..tenantName)
 else
  local floor=tenant:FindFirstChild("Floor")
  local gallery=tenant:WaitForChild("PremiumRetailGalleryV6",90)
  if floor and floor:IsA("BasePart") and gallery then
   tenantsChecked+=1
   for _,d in ipairs(gallery:GetDescendants()) do
    if d:IsA("BasePart") then
     clampGalleryPart(tenant,floor,d)
    end
   end
  else
   warn("[MALL_BOUNDS] missing Floor/gallery for "..tenantName)
  end
 end
end

authority:SetAttribute("TenantCountChecked",tenantsChecked)
authority:SetAttribute("PartsChecked",checked)
authority:SetAttribute("OffsideCorrections",corrected)
authority:SetAttribute("OversizeViolations",oversized)
authority:SetAttribute("SpatialQCReady",tenantsChecked==#requiredTenants and oversized==0)

mall:SetAttribute("MallSpatialAuthority","V1_TENANT_FLOOR_CFRAME")
mall:SetAttribute("MallSpatialOffsideCorrections",corrected)
mall:SetAttribute("MallSpatialOversizeViolations",oversized)
mall:SetAttribute("MallSpatialQCReady",tenantsChecked==#requiredTenants and oversized==0)

print(string.format("[MALL_BOUNDS_DONE]|tenants=%d|checked=%d|corrected=%d|oversized=%d",
 tenantsChecked,checked,corrected,oversized))
