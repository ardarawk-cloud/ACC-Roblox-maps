-- BBYA navigation text hotfix v1.0
-- Important map navigation stays large/readable; overhead player titles remain independent.

task.wait(3)

local function tunePart(name,maxText,minText)
 local p=workspace:FindFirstChild(name,true)
 if not p or not p:IsA("BasePart") then return end
 p.CanCollide=false
 for _,g in ipairs(p:GetDescendants()) do
  if g:IsA("SurfaceGui") then
   g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
   g.PixelsPerStud=36
   g.LightInfluence=0
   for _,t in ipairs(g:GetDescendants()) do
    if t:IsA("TextLabel") or t:IsA("TextButton") then
     t.TextScaled=true
     t.TextWrapped=false
     t.TextXAlignment=Enum.TextXAlignment.Center
     t.TextYAlignment=Enum.TextYAlignment.Center
     t.TextStrokeTransparency=.2
     for _,c in ipairs(t:GetChildren()) do
      if c:IsA("UITextSizeConstraint") then c:Destroy() end
     end
     local c=Instance.new("UITextSizeConstraint")
     c.MinTextSize=minText or 26
     c.MaxTextSize=maxText or 64
     c.Parent=t
    end
   end
  end
 end
end

-- Main wayfinding must be readable from several studs away.
tunePart("Lobby Wayfinding",72,30)
tunePart("Pool Sign",64,28)
tunePart("BBYA Giant Sign",78,34)
tunePart("Arrival Motto",52,22)
tunePart("Stage Header",58,24)

-- Also repair common destination signs without touching player overhead tags.
for _,name in ipairs({
 "Left VIP Platform Sign","Right VIP Platform Sign","Queen Sign",
 "VIP Sign","Rooftop Sign","Club Sign","Bar Sign","Photo Sign 1","Photo Sign 2"
}) do
 tunePart(name,58,24)
end

print("[BBYA] navigation text hotfix applied: destination labels restored to readable size")