const fs=require('fs'),path=require('path');
const root=process.cwd();

// BBYAVATAR RESET BUILD
// Intentionally minimal: preserve only a neutral baseplate + spawn so the Place
// remains enterable while all previous catalog/showroom systems are removed from
// the production payload. Historical source files stay in git for reference but
// are not bundled into the live experience.
const server=`local W=game:GetService("Workspace")\nfor _,child in ipairs(W:GetChildren()) do\n if not child:IsA("Terrain") then child:Destroy() end\nend\nlocal base=Instance.new("Part")\nbase.Name="Baseplate"\nbase.Size=Vector3.new(256,1,256)\nbase.CFrame=CFrame.new(0,0,0)\nbase.Anchored=true\nbase.Material=Enum.Material.SmoothPlastic\nbase.Color=Color3.fromRGB(163,162,165)\nbase.TopSurface=Enum.SurfaceType.Smooth\nbase.BottomSurface=Enum.SurfaceType.Smooth\nbase.Parent=W\nlocal spawn=Instance.new("SpawnLocation")\nspawn.Name="Spawn"\nspawn.Size=Vector3.new(8,1,8)\nspawn.CFrame=CFrame.new(0,1.5,0)\nspawn.Anchored=true\nspawn.Neutral=true\nspawn.Parent=W\nprint("[BBYAVATAR] RESET SHELL READY")`;

const client=`-- BBYAVATAR reset shell. Intentionally empty.\n`;

const xml=`<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4"><External>null</External><External>nil</External><Item class="Workspace" referent="W"><Properties><string name="Name">Workspace</string></Properties></Item><Item class="Lighting" referent="L"><Properties><float name="Brightness">2</float><double name="ClockTime">14</double><string name="Name">Lighting</string></Properties></Item><Item class="ServerScriptService" referent="S"><Properties><string name="Name">ServerScriptService</string></Properties><Item class="Script" referent="R"><Properties><string name="Name">BBYAVATAR_Runtime</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${server}]]></ProtectedString></Properties></Item></Item><Item class="StarterPlayer" referent="P"><Properties><string name="Name">StarterPlayer</string></Properties><Item class="StarterPlayerScripts" referent="PS"><Properties><string name="Name">StarterPlayerScripts</string></Properties><Item class="LocalScript" referent="C"><Properties><string name="Name">BBYAVATAR_Client</string><bool name="Disabled">false</bool><ProtectedString name="Source"><![CDATA[${client}]]></ProtectedString></Properties></Item></Item></Item></roblox>`;
fs.writeFileSync(path.join(root,'maps/bbyavatar/place.rbxlx'),xml);
console.log('[BBYAVATAR] Built empty reset shell for new project');