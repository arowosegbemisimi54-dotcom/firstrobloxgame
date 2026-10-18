-- Original period workshop, with moving doors and tangible objective props.
local Set={}
function Set.build(part,origin,parent)
 local V,C=Vector3.new,Color3.fromRGB
 local model=Instance.new("Model"); model.Name="Playable depot workshop"; model.Parent=parent
 local function p(name,size,pos,color,material,shape,where) return part(name,size,pos,color,material,shape,where or model) end
 local wood,iron=C(104,77,48),C(62,68,65)
 local function sign(parent,text)
  local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Front; gui.CanvasSize=Vector2.new(520,140); gui.Parent=parent
  local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.Text=text; label.TextColor3=C(222,204,159); label.TextScaled=true; label.Font=Enum.Font.SpecialElite; label.Parent=gui
 end
 local doors={}
 for _,side in {-1,1} do
  local door=Instance.new("Model"); door.Name="Sliding loading door"; door.Parent=model
  for i=0,7 do p("Door tongue and groove board",V(.88,8.8,.32),V(920+side*3.6-3.2+i*.91,4.4,182.6),wood,Enum.Material.WoodPlanks,nil,door) end
  for _,y in {1.2,7.7} do p("Door iron strap",V(7.1,.19,.12),V(920+side*3.6,y,182.35),iron,Enum.Material.Metal,nil,door) end
  p("Recessed door handle",V(.12,.8,.3),V(920+side*.55,3.6,182.2),iron,Enum.Material.Metal,nil,door)
  door.WorldPivot=CFrame.new(origin+V(920+side*3.6,0,182.6))
  table.insert(doors,{model=door,base=door:GetPivot(),side=side})
 end
 p("Overhead door track",V(30,.25,.32),V(920,9.1,182.4),iron,Enum.Material.Metal)
 for _,at in {V(910,3.5,182.25),V(910,3.5,183.7)} do
  p("Door latch mounting plate",V(.55,.9,.12),at,iron,Enum.Material.Metal)
  p("Door latch handle",V(.12,.65,.2),at+V(0,0,-.12),C(192,171,114),Enum.Material.Metal)
 end
 local notice=p("Loading instructions",V(4,1.2,.12),V(908,6.2,182.3),C(59,69,58),Enum.Material.Wood)
 sign(notice,"KEEP CLEAR\nLOADING BAY")
 local ramp=p("Loading threshold ramp",V(14,.16,4.3),V(920,.42,181),C(116,112,99),Enum.Material.Concrete)
 ramp.CFrame*=CFrame.Angles(-.2,0,0)
 local parking={}
 for _,x in {915,925} do table.insert(parking,p("Painted van parking guide",V(.13,.02,19),V(x,.87,202),C(191,169,111))) end
 table.insert(parking,p("Painted parking stop",V(10,.02,.15),V(920,.87,212),C(191,169,111)))
 p("Workshop concrete floor",V(43,.18,37),V(920,.78,202),C(116,112,99),Enum.Material.Concrete)
 p("Mechanic workbench",V(2,2.5,15),V(940,2.1,205),wood,Enum.Material.Wood)
 p("Steel worktop",V(2.3,.14,15.3),V(940,3.4,205),iron,Enum.Material.Metal)
 p("Tool hanging board",V(.16,3.8,13),V(941.7,5.3,205),C(72,74,61),Enum.Material.Wood)
 for i=1,8 do
  p("Hanging wrench shaft",V(.15,1.3,.12),V(941.45,5.3,199+i*1.4),C(170,173,156),Enum.Material.Metal)
  p("Wrench open jaw",V(.16,.23,.35),V(941.4,6,199+i*1.4),C(170,173,156),Enum.Material.Metal)
 end
 for i=1,4 do
  p("Oil tin",V(.55,.8,.55),V(939.7,3.85,200+i*2.4),i%2==0 and C(137,51,34) or C(180,148,71),Enum.Material.Metal)
 end
 for _,x in {901.6,904} do
  for y=1.5,3.5,1 do
   p("Stacked spare tire",V(.8,2.3,2.3),V(x,y,213),C(31,33,30),Enum.Material.SmoothPlastic,Enum.PartType.Cylinder).CFrame*=CFrame.Angles(0,0,math.pi/2)
  end
 end
 local pallet=p("Marked cash pallet",V(5,.28,5),V(934,1,212),wood,Enum.Material.WoodPlanks)
 local tags=p("Stash tally board",V(4.5,1.5,.15),V(934,3.2,214.8),C(45,53,45),Enum.Material.Wood)
 sign(tags,"KEEP BELOW\nTHE WINDOWS")
 local switch=p("Porcelain light switch",V(.65,.95,.16),V(930,3.7,183.5),C(214,205,178),Enum.Material.SmoothPlastic)
 p("Light switch conduit",V(.1,5,.1),V(930,6.6,183.55),iron,Enum.Material.Metal)
 local toggle=p("Workshop toggle lever",V(.14,.42,.16),V(930,3.7,183.7),iron,Enum.Material.Metal)
 local lights={}
 for _,z in {191,211} do
  p("Workshop lamp cord",V(.06,2.2,.06),V(920,8.8,z),iron)
  local shade=p("Enamel workshop shade",V(1.9,.3,1.9),V(920,7.7,z),C(54,71,59),Enum.Material.Metal)
  local bulb=p("Warm workshop bulb",V(.5,.45,.5),V(920,7.4,z),C(255,214,144),Enum.Material.Neon,Enum.PartType.Ball)
  local light=Instance.new("PointLight"); light.Brightness=1.4; light.Range=24; light.Color=bulb.Color; light.Shadows=true; light.Parent=bulb
  table.insert(lights,{light=light,bulb=bulb})
 end
 local bags={}
 for i=1,4 do
  local bag=p("Secured canvas bag "..i,V(1.15,.95,1.9),V(933+(i%2)*1.5,1.65,211+math.floor((i-1)/2)*2),C(75,69,48),Enum.Material.Fabric,Enum.PartType.Ball); bag.Transparency=1
  local zip=p("Stash bag zipper "..i,V(.05,.04,1.4),V(933+(i%2)*1.5,2.1,211+math.floor((i-1)/2)*2),C(176,155,99),Enum.Material.Metal); zip.Transparency=1
  table.insert(bags,{bag,zip})
 end
 local marker=p("Warehouse objective beacon",V(.35,.35,.35),V(910,5,179),C(240,194,95),Enum.Material.Neon,Enum.PartType.Ball)
 local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(210,42); gui.StudsOffset=V(0,1,0); gui.AlwaysOnTop=true; gui.MaxDistance=95; gui.Parent=marker
 local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundColor3=C(22,25,22); label.BackgroundTransparency=.2; label.TextColor3=C(242,218,159); label.TextSize=16; label.Font=Enum.Font.SpecialElite; label.Parent=gui
 marker.Transparency=1; gui.Enabled=false
 return {model=model,marker=marker,markerLabel=label,markerGui=gui,
  gate=function(value) for _,door in doors do door.model:PivotTo(door.base*CFrame.new(door.side*7.4*value,0,0)) end end,
  lights=function(on) for _,item in lights do item.light.Enabled=on; item.bulb.Material=on and Enum.Material.Neon or Enum.Material.Glass end; toggle.CFrame=CFrame.new(origin+V(930,3.7,183.7))*CFrame.Angles(on and -.3 or .3,0,0) end,
  bags=function(count) for i,parts in bags do for _,object in parts do object.Transparency=i<=count and 0 or 1 end end end}
end
return Set
