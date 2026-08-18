-- [SYS-PERF CLIENT] BBYA V5 ADAPTIVE PERFORMANCE + FINAL CLIENT STARTUP SYNC
local Lighting=game:GetService("Lighting")
local UIS=game:GetService("UserInputService")
local camera=workspace.CurrentCamera
local mobile=UIS.TouchEnabled or (camera and camera.ViewportSize.X<900)
local index=0
for _,d in ipairs(workspace:GetDescendants()) do
 local critical=d:GetAttribute("BBYACriticalFillLight")==true
 if d:IsA("PointLight") and d.Name=="BBYA Decorative Light" then
  index+=1;d.Shadows=false
  if mobile then d.Enabled=index%2==1;d.Brightness=math.min(d.Brightness,.38);d.Range=math.min(d.Range,10) else d.Brightness=math.min(d.Brightness,.7);d.Range=math.min(d.Range,14) end
 elseif d:IsA("PointLight") and critical then
  d.Shadows=false;d.Enabled=true
  if mobile then d.Brightness=math.min(d.Brightness,1.15);d.Range=math.min(d.Range,19) end
 elseif d:IsA("SurfaceLight") then
  d.Shadows=false
  if critical then d.Enabled=true;if mobile then d.Brightness=math.min(d.Brightness,1.18);d.Range=math.min(d.Range,19) end
  elseif mobile then d.Brightness=math.min(d.Brightness,.35);d.Range=math.min(d.Range,8) end
 end
end
local bloom=Lighting:FindFirstChild("BBYA V5 Bloom");if bloom and mobile then bloom.Intensity=math.min(bloom.Intensity,.30);bloom.Size=math.min(bloom.Size,19) end

-- ui-live intentionally uses a shared local boardFn. Resolve a rare startup race after all live UI is constructed.
if not boardFn and v5Remotes then boardFn=v5Remotes:WaitForChild("SupportBoard",10) end

player:SetAttribute("BBYAClientPerformanceProfile",mobile and "MOBILE_SHOWOFF_SAFE" or "DESKTOP")
player:SetAttribute("BBYAClientStartupSync",boardFn and "PASS" or "SUPPORT_BOARD_PENDING")
