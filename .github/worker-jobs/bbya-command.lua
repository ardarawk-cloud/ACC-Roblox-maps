print("[BBYA_JOB_BEGIN:social-live-qc-005]")
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
print("STATE|running="..tostring(RunService:IsRunning()).."|studio="..tostring(RunService:IsStudio()))
local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
local social=remotes and remotes:FindFirstChild("SocialHangout")
print("REMOTE|folder="..tostring(remotes~=nil).."|social="..tostring(social~=nil).."|class="..tostring(social and social.ClassName or "nil"))
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
local floor=root and root:FindFirstChild("Floor1Features")
local dance=0
if floor then
 for i=1,3 do if floor:FindFirstChild("DanceInteract"..i) then dance+=1 end end
end
print("DANCE_PROMPTS|count="..tostring(dance))
local ps=Players:GetPlayers();local p=ps[1]
print("PLAYERS|count="..tostring(#ps))
if p then
 local pg=p:FindFirstChildOfClass("PlayerGui")
 local socialGui=pg and pg:FindFirstChild("BBYASocialHangoutUI")
 print("CLIENT_UI|gui="..tostring(socialGui~=nil))
 local launcher=nil;local panel=nil;local title=nil
 if socialGui then
  for _,d in ipairs(socialGui:GetDescendants()) do
   if d:IsA("TextButton") and tostring(d.Text):find("SOCIAL",1,true) then launcher=d end
   if d:IsA("TextLabel") and d.Text=="BBYA SOCIAL" then title=d;panel=d.Parent end
  end
 end
 print("CLIENT_UI|launcher="..tostring(launcher~=nil).."|panel="..tostring(panel~=nil))
 if launcher then print("LAUNCHER|text="..launcher.Text.."|visible="..tostring(launcher.Visible).."|abs="..tostring(launcher.AbsoluteSize)) end
 if panel then panel.Visible=true;print("PANEL|forced_open=true|abs="..tostring(panel.AbsoluteSize)) end
 local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if hrp then hrp.CFrame=CFrame.lookAt(Vector3.new(0,3,-2),Vector3.new(0,3,12));print("TELEPORT|ok=true") end
end
local cam=Workspace.CurrentCamera
if cam then cam.CameraType=Enum.CameraType.Scriptable;cam.FieldOfView=72;cam.CFrame=CFrame.lookAt(Vector3.new(0,7,-18),Vector3.new(0,5,10));print("CAMERA|set=true") end
task.wait(4)
print("[BBYA_JOB_END:social-live-qc-005]")
