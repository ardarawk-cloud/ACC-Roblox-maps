-- [SYS-QC] MASTER-PLAN RUNTIME QC
-- Runs after geometry/systems initialize; gives one-pass inspection status for founder review.
task.delay(8,function()
 local missing={};local rootMap=workspace:FindFirstChild("BBYA V5.3 MASTER PLAN")
 local function need(name) if not workspace:FindFirstChild(name,true) then table.insert(missing,name) end end
 if not rootMap then table.insert(missing,"V5.3 ROOT") else
  for _,codeName in ipairs({"[A1] EXTERIOR / SPAWN","[A2] MAIN ENTRANCE / FACADE","[A3] LOBBY / ORIENTATION","[A4] MAIN CLUB / DANCE HALL","[A5] BAR ROOM","[A6] CHILL LOUNGE","[B1] WEST STAIR CORE","[B2] EAST STAIR CORE","[B3] LIFT CORE","[C1] VIP WEST MEZZANINE","[C2] VIP EAST MEZZANINE","[C3] QUEEN / VIP BRIDGES","[D1] ROOFTOP ARRIVAL / CIRCULATION","[D2] ROOFTOP WATER / POOL FOOTPRINT","[D3] SKY BAR PROGRAM","[D4] ROOFTOP CHILL / SUNSET SOCIAL","[D5] CABANA PROGRAM ZONES","[D6] PHOTO / VIEW DECK","[S1] SERVICE / RESTROOM / BACKSTAGE"}) do if not rootMap:FindFirstChild(codeName) then table.insert(missing,codeName) end end
  local components=rootMap:FindFirstChild("BBYA COMPONENT INDEX")
  if not components then table.insert(missing,"COMPONENT INDEX") else
   for _,code in ipairs({"01","02","03","04","05","06","07","08","09W","09E","10","11W","11E","12W","12E","13","14","15","16W","16E","17","18","19","20","21","22","23"}) do
    local found=false;for _,f in ipairs(components:GetChildren()) do if f:GetAttribute("BBYAComponentCode")==code then found=true;break end end
    if not found then table.insert(missing,"COMP "..code) end
   end
  end
 end
 for _,name in ipairs({"A2 | PREMIUM EXTERIOR BRAND","A4 | DJ BOOTH BODY","A4 | MAIN LED WALL","A5 | MAIN BAR COUNTER BODY","A6 | CHILL FEATURE WALL","B3 | LIFT CAR PLATFORM","C1 | PRIVATE 12W FRONT WALL","C2 | PRIVATE 12E FRONT WALL","C3 | QUEEN BACKDROP","D2 | POOL WATER","D3 | SKY BAR COUNTER BODY","D5 | WEST CABANA A ROOF","D6 | PHOTO BACKDROP","A3 | TOP SUPPORTERS BOARD"}) do need(name) end
 local lights=0;for _,d in ipairs(workspace:GetDescendants()) do if d:IsA("PointLight") and d.Name=="BBYA Decorative Light" then lights+=1 end end
 workspace:SetAttribute("BBYAV5QCMissing",#missing);workspace:SetAttribute("BBYAV5QCLights",lights);workspace:SetAttribute("BBYAV5QCStatus",#missing==0 and "PASS" or "WARN");workspace:SetAttribute("BBYAV5BuildReady",#missing==0);workspace:SetAttribute("BBYAV5QCSchema","V53_MACRO_MICRO")
 if #missing==0 then print("[BBYA QC] PASS • V5.3 MASTER PLAN • macro+micro codes • decorative lights",lights) else warn("[BBYA QC] WARN • missing:",table.concat(missing," | ")) end
end)
