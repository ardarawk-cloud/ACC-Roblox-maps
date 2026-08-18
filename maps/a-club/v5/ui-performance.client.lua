-- [SYS-PERF CLIENT] BBYA V5 ADAPTIVE PERFORMANCE
local Lighting=game:GetService("Lighting")
local UIS=game:GetService("UserInputService")
local camera=workspace.CurrentCamera
local mobile=UIS.TouchEnabled or (camera and camera.ViewportSize.X<900)
local index=0
for _,d in ipairs(workspace:GetDescendants()) do
 if d:IsA("PointLight") and d.Name=="BBYA Decorative Light" then
  index+=1;d.Shadows=false
  if mobile then d.Enabled=index%2==1;d.Brightness=math.min(d.Brightness,.38);d.Range=math.min(d.Range,10) else d.Brightness=math.min(d.Brightness,.7);d.Range=math.min(d.Range,14) end
 elseif d:IsA("SurfaceLight") then d.Shadows=false;if mobile then d.Brightness=math.min(d.Brightness,.35);d.Range=math.min(d.Range,8) end end
end
local bloom=Lighting:FindFirstChild("BBYA V5 Bloom");if bloom and mobile then bloom.Intensity=math.min(bloom.Intensity,.32);bloom.Size=math.min(bloom.Size,20) end
player:SetAttribute("BBYAClientPerformanceProfile",mobile and "MOBILE" or "DESKTOP")
