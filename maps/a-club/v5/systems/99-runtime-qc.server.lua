-- [SYS-QC] MASTER-PLAN RUNTIME QC
-- Runs after geometry/systems initialize; gives one-pass inspection status for founder review.
task.delay(8,function()
 local missing={};local rootMap=workspace:FindFirstChild("BBYA V5.2 MODULAR GREYBOX")
 local function need(name) if not workspace:FindFirstChild(name,true) then table.insert(missing,name) end end
 if not rootMap then table.insert(missing,"V5 ROOT") else
  for _,codeName in ipairs({"[A1] EXTERIOR / SPAWN","[A2] MAIN ENTRANCE / FACADE","[A3] LOBBY / ORIENTATION","[A4] MAIN CLUB / DANCE HALL","[A5] BAR ROOM","[A6] CHILL LOUNGE","[B1] WEST STAIR CORE","[B2] EAST STAIR CORE","[B3] LIFT CORE","[C1] VIP WEST MEZZANINE","[C2] VIP EAST MEZZANINE","[C3] QUEEN / VIP BRIDGES","[D1] ROOFTOP ARRIVAL / CIRCULATION","[D2] ROOFTOP WATER / POOL FOOTPRINT","[D3] SKY BAR PROGRAM","[D4] ROOFTOP CHILL / SUNSET SOCIAL","[D5] CABANA PROGRAM ZONES","[D6] PHOTO / VIEW DECK","[S1] SERVICE / RESTROOM / BACKSTAGE"}) do if not rootMap:FindFirstChild(codeName) then table.insert(missing,codeName) end end
 end
 for _,name in ipairs({"A2 | PREMIUM EXTERIOR BRAND","A4 | DJ BOOTH BODY","A4 | MAIN LED WALL","A5 | MAIN BAR COUNTER BODY","A6 | CHILL FEATURE WALL","B3 | LIFT CAR PLATFORM","C3 | QUEEN BACKDROP","D2 | POOL WATER","D3 | SKY BAR COUNTER BODY","D5 | WEST CABANA A ROOF","D6 | PHOTO BACKDROP","A3 | TOP SUPPORTERS BOARD"}) do need(name) end
 local lights=0;for _,d in ipairs(workspace:GetDescendants()) do if d:IsA("PointLight") and d.Name=="BBYA Decorative Light" then lights+=1 end end
 workspace:SetAttribute("BBYAV5QCMissing",#missing);workspace:SetAttribute("BBYAV5QCLights",lights);workspace:SetAttribute("BBYAV5QCStatus",#missing==0 and "PASS" or "WARN");workspace:SetAttribute("BBYAV5BuildReady",#missing==0)
 if #missing==0 then print("[BBYA QC] PASS • MASTER PLAN IMPLEMENTED • decorative lights",lights) else warn("[BBYA QC] WARN • missing:",table.concat(missing," | ")) end
end)
