-- Bounded, deterministic roadside detail and an original timber stash house.
local WarehouseSet=require(script.Parent.WarehouseSet)
local Landscape={}
function Landscape.build(part,origin,parent)
 local V,C=Vector3.new,Color3.fromRGB
 local model=Instance.new("Model"); model.Name="Highway Four landscape and timber stash house"; model.Parent=parent
 local function p(name,size,pos,color,material,shape)
  return part(name,size,pos,color,material,shape,model)
 end
 local function beam(name,a,b,width,color,material)
  local object=p(name,V(width,width,(b-a).Magnitude),(a+b)/2,color,material)
  object.CFrame=CFrame.lookAt(origin+(a+b)/2,origin+b); return object
 end
 local sand=C(155,127,86); local timber=C(110,82,51); local pale=C(157,128,86)
 -- Broad dunes and weathered rock crowns, kept clear of the driveable road.
 for i=1,42 do
  local x=-230+i*35; local side=i%2==0 and -1 or 1; local z=140+side*(125+i%4*32)
  local h=12+i%6*6
  local dune=p("Layered desert dune",V(95+i%4*18,h,85),V(x,h*.08-4,z),i%2==0 and sand or C(174,143,99),Enum.Material.Sand,Enum.PartType.Ball)
  dune.CFrame*=CFrame.Angles(.02,math.sin(i)*.7,.06)
  if i%3==0 then
   for j=1,3 do
    local rock=p("Weathered sandstone shoulder",V(26-j*4,22-j*3,25-j*4),V(x+j*8,4+j*4,z+side*j*5),C(131+j*9,103+j*7,77+j*4),Enum.Material.Sandstone,Enum.PartType.Ball)
    rock.CFrame*=CFrame.Angles(j*.17,i*.6,j*.14)
   end
  end
 end
 -- Wire sag is authored as short sections rather than a perfectly straight line.
 for x=170,1130,80 do
  p("Road telegraph pole",V(.6,21,.6),V(x,10.5,103),timber,Enum.Material.Wood)
  p("Telegraph crossarm",V(.2,.24,5),V(x,19.5,103),timber,Enum.Material.Wood)
  for _,z in {101,103,105} do
   p("Ceramic insulator",V(.19,.32,.19),V(x,19.8,z),C(182,190,177),Enum.Material.Glass)
   if x<1130 then
    for i=0,3 do
     local a,b=i/4,(i+1)/4
     beam("Sagging telegraph wire",V(x+a*80,19.8-math.sin(a*math.pi)*2,z),V(x+b*80,19.8-math.sin(b*math.pi)*2,z),.028,C(53,49,41),Enum.Material.Metal)
    end
   end
  end
 end
 for i=1,75 do
  local x=130+i*14.5; local z=140+(i%2==0 and -1 or 1)*(26+i%7*9)
  if not (x>870 and x<980 and z>150) then
   if i%3==0 then
    local h=2+i%4
    p("Saguaro trunk",V(h,.55,.55),V(x,h/2,z),C(77,99,57),Enum.Material.Grass,Enum.PartType.Cylinder).CFrame*=CFrame.Angles(0,0,math.pi/2)
    beam("Cactus raised arm",V(x,1.5,z),V(x+.9,1.9,z),.3,C(77,99,57),Enum.Material.Grass)
    p("Cactus arm tip",V(.35,1.1,.35),V(x+.9,2.4,z),C(77,99,57),Enum.Material.Grass,Enum.PartType.Ball)
   else
    for j=1,3 do local a=j*2.1; beam("Dry roadside grass",V(x,0,z),V(x+math.cos(a)*.6,.7+i%3*.2,z+math.sin(a)*.6),.055,C(151,133,81),Enum.Material.Grass) end
   end
  end
 end
 for _,x in {260,470,690,860} do
  p("Road reflector post",V(.18,2,.18),V(x,1,125),C(198,190,158),Enum.Material.Concrete)
  p("Amber reflector",V(.22,.2,.08),V(x,1.7,124.85),C(227,161,48),Enum.Material.Neon)
 end
 -- Original two-storey barn conversion. Front doorway remains open.
 local cx,cz=920,202
 p("Stash house stone foundation",V(44,1,38),V(cx,.35,cz),C(110,104,86),Enum.Material.Cobblestone)
 for y=1.2,16,.65 do
  local tint=C(113+math.floor(y*7)%22,83+math.floor(y*3)%17,49+math.floor(y*5)%13)
  for _,side in {-1,1} do
   p("Horizontal timber siding",V(14.5,.58,.22),V(cx+side*14,y,183),tint,Enum.Material.Wood)
   p("Barn side weatherboards",V(.22,.58,38),V(cx+side*22,y,cz),tint,Enum.Material.Wood)
  end
  p("Rear weatherboards",V(44,.58,.22),V(cx,y,221),tint,Enum.Material.Wood)
  if y>9 then p("Door header weatherboards",V(15,.58,.22),V(cx,y,183),tint,Enum.Material.Wood) end
 end
 for _,x in {-22,-7.5,7.5,22} do p("Exposed barn framing",V(.55,16,.55),V(cx+x,8,182.7),timber,Enum.Material.Wood) end
 p("Barn loft floor",V(43,.35,37),V(cx,10.1,cz),timber,Enum.Material.WoodPlanks)
 for _,side in {-1,1} do
  local roof=p("Pitched shingle roof",V(24.2,.4,41),V(cx+side*11.2,20,cz),C(83,73,57),Enum.Material.WoodPlanks)
  roof.CFrame*=CFrame.Angles(0,0,-side*math.atan(8/22))
  for z=183,221,3 do beam("Weathered roof batten",V(cx+side*.2,24,z),V(cx+side*23,15.9,z),.12,C(113,94,67),Enum.Material.Wood) end
  beam("Gable front rafter",V(cx,24,182),V(cx+side*23,16,182),.45,pale,Enum.Material.Wood)
  beam("Barn diagonal brace",V(cx+side*21,1,182.5),V(cx+side*8,8.5,182.5),.35,timber,Enum.Material.Wood)
  if side==1 then for y=16.6,23.5,.65 do local width=(24-y)/8*44; for _,z in {183,221} do p("Gable weatherboards",V(math.max(.2,width),.59,.2),V(cx,y,z),C(125,94,58),Enum.Material.Wood) end end end
 end
 p("Roof ridge cap",V(.5,.4,42),V(cx,24.3,cz),pale,Enum.Material.Wood)
 for _,x in {-15,15} do
  p("Loft dark window",V(4,4,.12),V(cx+x,12.7,182.6),C(39,49,44),Enum.Material.Glass)
  for _,dx in {-2,0,2} do p("Loft window mullion",V(.13,4.3,.2),V(cx+x+dx,12.7,182.45),pale,Enum.Material.Wood) end
  p("Window sill",V(4.5,.15,.4),V(cx+x,10.7,182.4),pale,Enum.Material.Wood)
 end
 local porch=p("Porch corrugated canopy",V(44,.25,13),V(cx,10.1,176),C(92,92,75),Enum.Material.CorrodedMetal); porch.CFrame*=CFrame.Angles(.08,0,0)
 for _,x in {-20,-8,8,20} do
  p("Porch support post",V(.5,9.5,.5),V(cx+x,4.75,170),timber,Enum.Material.Wood)
  beam("Porch knee brace",V(cx+x,7.4,170),V(cx+x+1.8,9.5,170),.24,pale,Enum.Material.Wood)
 end
 for i=1,9 do
  local x=cx-17+(i%3)*2; local z=190+math.floor((i-1)/3)*2
  p("Stacked supply crate",V(1.8,1.8,1.8),V(x,1.4+(i%2)*1.8,z),C(140,109,65),Enum.Material.WoodPlanks)
 end
 for _,x in {902,938} do
  local lantern=p("Porch lantern",V(.35,.65,.35),V(x,8,182),C(226,177,92),Enum.Material.Glass)
  local light=Instance.new("PointLight"); light.Color=lantern.Color; light.Brightness=.9; light.Range=14; light.Parent=lantern
 end
 local board=p("Stash house sign",V(13,2.4,.25),V(cx,14,182.4),C(58,77,65),Enum.Material.Wood)
 local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Front; gui.CanvasSize=Vector2.new(650,120); gui.Parent=board
 local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1); text.BackgroundTransparency=1; text.Text="OLD MOTOR DEPOT"; text.Font=Enum.Font.SpecialElite; text.TextScaled=true; text.TextColor3=C(195,168,111); text.Parent=gui
 -- Stave water tank on a braced tower.
 for _,x in {957,965} do for _,z in {193,201} do p("Water tower leg",V(.5,20,.5),V(x,10,z),timber,Enum.Material.Wood) end end
 for _,z in {193,201} do beam("Tank tower crossbrace",V(957,3,z),V(965,18,z),.25,pale,Enum.Material.Wood); beam("Tank tower crossbrace",V(965,3,z),V(957,18,z),.25,pale,Enum.Material.Wood) end
 p("Water tank platform",V(12,.35,12),V(961,20,197),timber,Enum.Material.WoodPlanks)
 p("Stave water tank",V(8,10,10),V(961,24.2,197),C(139,108,67),Enum.Material.WoodPlanks,Enum.PartType.Cylinder).CFrame*=CFrame.Angles(0,0,math.pi/2)
 for _,y in {21,24,27} do p("Iron tank hoop",V(.14,10.1,10.1),V(961,y,197),C(61,60,49),Enum.Material.Metal,Enum.PartType.Cylinder).CFrame*=CFrame.Angles(0,0,math.pi/2) end
 for y=2,19,.7 do p("Tower ladder rung",V(1.5,.12,.12),V(966,y,197),pale,Enum.Material.Wood) end
 -- Wind pump, with a bounded rotating rotor.
 for _,x in {877,883} do for _,z in {197,203} do beam("Windmill tower leg",V(x,0,z),V(880+(x-880)*.25,31,200+(z-200)*.25),.3,timber,Enum.Material.Wood) end end
 for y=3,27,6 do beam("Windmill cross brace",V(877,y,197),V(883,y+5,197),.18,pale,Enum.Material.Wood) end
 local rotor=Instance.new("Model"); rotor.Name="Turning wind pump"; rotor.Parent=model
 for i=1,12 do local a=i*math.pi/6; local blade=p("Wind pump blade",V(.8,4,.08),V(880+math.sin(a)*3.7,31+math.cos(a)*3.7,198),C(137,141,120),Enum.Material.CorrodedMetal); blade.CFrame*=CFrame.Angles(0,0,-a); blade.Parent=rotor end
 rotor.WorldPivot=CFrame.new(origin+V(880,31,198)); local rotorBase=rotor:GetPivot()
 local depot=WarehouseSet.build(part,origin,model)
 return {model=model,depot=depot,update=function(time,reduced) if not reduced then rotor:PivotTo(rotorBase*CFrame.Angles(0,0,time*.28)) end end}
end
return Landscape
