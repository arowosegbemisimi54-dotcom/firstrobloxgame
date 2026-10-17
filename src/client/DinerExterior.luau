-- Original roadside block shared by the window views and the playable exit.
local Cars=require(script.Parent.VintageCars)
local Van=require(script.Parent.GetawayVan)
local Landscape=require(script.Parent.EscapeLandscape)
local Exterior={}
function Exterior.build(parent,origin)
 local V=Vector3.new
 local C=Color3.fromRGB
 local model=Instance.new("Model"); model.Name="Sunset Diner roadside block"; model.Parent=parent
 local function part(name,size,pos,color,material,shape,where)
  local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=CFrame.new(origin+pos); p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; if shape then p.Shape=shape end; p.Parent=where or model; return p
 end
 local asphalt=C(81,77,67); local cream=C(220,207,169); local metal=C(165,169,157)
 part("Weathered parking court",V(210,.15,90),V(-15,-.05,80),asphalt,Enum.Material.Asphalt)
 part("Side parking court",V(74,.15,122),V(-77,-.05,-4),asphalt,Enum.Material.Asphalt)
 part("Rear escape alley",V(230,.15,28),V(0,-.05,-55),C(102,89,70),Enum.Material.Asphalt)
 part("East alley access",V(32,.15,210),V(64,-.05,40),asphalt,Enum.Material.Asphalt)
 part("Diner front sidewalk",V(86,.22,7),V(0,.04,39),C(177,169,148),Enum.Material.Concrete)
 for x=-90,70,16 do
  for _,z in {62,109} do
   part("Faded parking bay",V(.12,.02,15),V(x,.04,z),cream)
   part("Concrete wheel stop",V(8,.3,.7),V(x+7,.15,z+(z==62 and -7 or 7)),C(164,160,142),Enum.Material.Concrete)
  end
 end
 for z=-40,24,16 do part("Side parking divider",V(16,.02,.12),V(-88,.04,z),cream) end
 part("Highway desert verge",V(3200,.8,420),V(350,-.6,140),C(151,128,91),Enum.Material.Sand)
 for x=180,1080,90 do
  for _,z in {111,169} do
   part("Highway fence post",V(.2,2.3,.2),V(x,1.15,z),C(108,88,58),Enum.Material.Wood)
   if not (z==169 and x==900) then part("Weathered fence rail",V(89,.13,.13),V(x+44.5,1.4,z),C(117,99,70),Enum.Material.Wood) end
  end
  part("Route cottonwood trunk",V(.7,6,.7),V(x,3,205),C(97,76,49),Enum.Material.Wood)
  part("Route cottonwood canopy",V(9,8,9),V(x,8,205),C(91,109,61),Enum.Material.Grass,Enum.PartType.Ball)
 end
 part("Highway Four",V(3200,.14,28),V(350,-.03,140),C(61,61,56),Enum.Material.Asphalt)
 for x=-1100,1800,28 do part("Highway dash",V(12,.025,.18),V(x,.06,140),C(210,185,113)) end
 for _,z in {127,153} do part("Highway edge line",V(3200,.025,.13),V(350,.06,z),cream) end
 local function sign(name,text,pos,size)
  local board=part(name,V(size.X,size.Y,.3),pos,C(118,42,34),Enum.Material.Metal)
  for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
   local gui=Instance.new("SurfaceGui"); gui.Face=face; gui.CanvasSize=Vector2.new(600,300); gui.Parent=board
   local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.Text=text; label.TextColor3=cream; label.TextScaled=true; label.Font=Enum.Font.SpecialElite; label.Parent=gui
  end
 end
 part("Roadside sign pole",V(.65,22,.65),V(-83,11,98),metal,Enum.Material.Metal)
 sign("Sunset roadside sign","SUNSET\nDINER",V(-83,22,98),Vector2.new(15,7))
 sign("Diner exterior fascia","SUNSET DINER  •  HOT COFFEE",V(0,12.9,36.35),Vector2.new(48,1.6))
 -- Low-rise brick storefronts, workshop doors, sash windows and cloth awnings.
 local function building(x,z,w,h,d,name,color)
  part(name.." masonry",V(w,h,d),V(x,h/2,z),color,Enum.Material.Brick)
  part(name.." cornice",V(w+1,.5,d+1),V(x,h,z),cream)
  local front=z-d/2-.15
  for dx=-w/2+5,w/2-3,8 do
   part("Shop sash window",V(5,5,.12),V(x+dx,5,front),C(67,89,88),Enum.Material.Glass)
   part("Window center mullion",V(.1,5,.2),V(x+dx,5,front-.1),cream)
   if h>15 then part("Upper sash window",V(4,4,.1),V(x+dx,h-5,front),C(78,98,93),Enum.Material.Glass) end
  end
  part("Recessed shop door",V(3.2,6.7,.2),V(x,3.35,front-.05),C(70,66,51),Enum.Material.Wood)
  sign(name.." painted sign",name,V(x,10,front-.1),Vector2.new(w-3,2))
  for dx=-w/2+1,w/2-1,2 do
   local awning=part("Striped shop awning",V(2,.12,4),V(x+dx,8.5,front-1.7),math.floor(dx/2)%2==0 and cream or C(109,53,40),Enum.Material.Fabric); awning.CFrame*=CFrame.Angles(.12,0,0)
  end
 end
 building(-76,195,40,21,24,"MERCER GENERAL STORE",C(141,105,79))
 building(-20,197,38,17,26,"POST & TELEGRAPH",C(154,139,108))
 building(40,199,43,15,28,"FINCH MOTOR SERVICE",C(127,119,100))
 building(-150,-24,34,19,50,"ROADSIDE LODGE",C(158,130,99))
 -- Window-facing side of the lodge.
 for z=-42,-6,9 do part("Lodge side window",V(.15,5,4),V(-132.9,9,z),C(83,105,101),Enum.Material.Glass) end
 for _,x in {-113,111} do for z=-65,190,85 do
  part("Timber utility pole",V(.7,24,.7),V(x,12,z),C(91,69,45),Enum.Material.Wood)
  part("Utility crossarm",V(5,.2,.2),V(x,22,z),C(91,69,45),Enum.Material.Wood)
 end end
 for i=1,22 do
  local x=i%2==0 and -175 or 110; local z=-90+i*14
  part("Roadside tree trunk",V(.8,7,.8),V(x,3.5,z),C(97,76,49),Enum.Material.Wood)
  part("Dusty cottonwood canopy",V(10,9,9),V(x,10,z),C(81+i%3*8,102+i%4*5,58),Enum.Material.Grass,Enum.PartType.Ball)
 end
 local function parked(variant,pos,yaw)
  local car=Instance.new("Model"); car.Name=Cars.names[variant]; car.Parent=model
  local function p(name,size,at,color,shape,rotation)
   local obj=part(name,size,at,color,nil,shape,car); if rotation then obj.CFrame*=rotation end; return obj
  end
  local function wheel(x,z,r)
   p("Parked tire",V(.55,r*2,r*2),V(x,r-.7,z),C(28,28,26),Enum.PartType.Cylinder)
   p("Parked hubcap",V(.6,r*1.1,r*1.1),V(x,r-.7,z),metal,Enum.PartType.Cylinder)
  end
  Cars.build(p,wheel,variant); car.WorldPivot=CFrame.new(origin); car:PivotTo(CFrame.new(origin+pos+V(0,.7,0))*CFrame.Angles(0,yaw,0)); return car
 end
 for _,entry in {{1,-68,62,0},{2,-36,109,math.pi},{3,12,109,math.pi},{4,60,62,0},{2,-88,-15,math.pi/2}} do parked(entry[1],V(entry[2],0,entry[3]),entry[4]) end
 -- Service yard obscures the second vehicle from the public lot.
 part("Dumpster screen wall",V(1,7,26),V(43,3.5,-42),C(139,117,89),Enum.Material.Brick)
 part("Diner service dumpster",V(7,4.5,5),V(47,2.25,-40),C(61,77,59),Enum.Material.Metal)
 local lid=part("Dumpster lid",V(7.2,.25,5.2),V(47,4.6,-40),C(44,52,42),Enum.Material.Metal); lid.CFrame*=CFrame.Angles(.06,0,0)
 for _,z in {-46,-34} do part("Galvanized refuse can",V(2,3,2),V(47,1.5,z),metal,Enum.Material.Metal,Enum.PartType.Cylinder).CFrame*=CFrame.Angles(0,0,math.pi/2) end
 local vehicle=Van.build(part,origin,model)
 local van,driverDoor,passengerDoor,cargoDoor=vehicle.model,vehicle.driver,vehicle.passenger,vehicle.cargo
 local door=Instance.new("Model"); door.Name="Diner glass entrance"; door.Parent=model
 local glassDoor=part("Diner glass door",V(6,8,.12),V(0,4,36),C(183,211,207),Enum.Material.Glass,nil,door); glassDoor.Transparency=.7
 for _,x in {-3,3} do part("Door frame upright",V(.14,8,.2),V(x,4,36),metal,Enum.Material.Metal,nil,door) end
 for _,y in {0,4,8} do part("Door frame rail",V(6,.14,.2),V(0,y,36),metal,Enum.Material.Metal,nil,door) end
 part("Door pull",V(.15,1.1,.25),V(2,3.8,35.8),metal,Enum.Material.Metal,nil,door)
 door.WorldPivot=CFrame.new(origin+V(-3,0,36))
 -- Road continues to a reachable destination for the first driving objective.
 local landscape=Landscape.build(part,origin,model)
 part("Depot driveway",V(50,.1,45),V(920,0,166),asphalt,Enum.Material.Asphalt)
 return {landscape=landscape,vehicle=vehicle,model=model,van=van,driverDoor=driverDoor,passengerDoor=passengerDoor,cargoDoor=cargoDoor,door=door,part=part,parked=parked,origin=origin,
  vanStart=V(60,.7,-53),safehouse=V(920,0,163),exit=V(0,0,44)}
end
return Exterior
