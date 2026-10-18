-- Original period panel van: open cabin, steel roof, working doors and instruments.
local Van={}
function Van.build(part,origin,parent)
 local V,C=Vector3.new,Color3.fromRGB
 local model=Instance.new("Model"); model.Name="Matte black getaway panel van"; model.Parent=parent
 local switches,lights,wipers={},{},{}
 local paint=C(34,39,35); local chrome=C(169,175,166); local rubber=C(27,28,26); local leather=C(90,64,40)
 local function p(name,size,pos,color,material,shape,where)
  return part(name,size,pos,color,material,shape,where or model)
 end
 p("Riveted ladder chassis",V(5.7,.35,12.5),V(0,.6,0),rubber,Enum.Material.Metal)
 p("Cab floor",V(5.6,.15,4.2),V(0,1.25,-4),C(82,78,64),Enum.Material.Metal)
 for _,x in {-2.88,2.88} do
  p("Pressed cargo side panel",V(.15,4.85,8.2),V(x,3.7,1.7),paint,Enum.Material.Metal)
  p("Roof rain gutter",V(.16,.12,12.3),V(x*1.05,6.19,0),chrome,Enum.Material.Metal)
  p("Side body rubbing strip",V(.18,.12,8.3),V(x,2.2,1.7),C(67,72,64),Enum.Material.Metal)
  for z=-1.8,5.4,1.2 do p("Panel rivet",V(.035,.055,.055),V(x*1.031,5.8,z),chrome,nil,Enum.PartType.Ball) end
  p("Cargo side bench",V(1.1,.38,6.5),V(x*.64,2.1,1.65),leather,Enum.Material.Leather)
 end
 for x=-2.7,2.7,.45 do p("Cargo floorboard",V(.43,.15,8.1),V(x,1.23,1.7),C(108+math.floor(x*4)%12,80,48),Enum.Material.Wood) end
 p("Cab rear bulkhead",V(5.6,4.9,.15),V(0,3.7,-2.3),paint,Enum.Material.Metal)
 -- Overlapping arched roof strips close the corners left exposed by the old oval.
 for i=0,12 do
  local x=-3+i*.5; local curve=math.max(0,1-(x/3.2)^2)
  local strip=p("Continuous steel roof",V(.55,.16,12.2),V(x,6.25+curve*.42,0),paint,Enum.Material.Metal)
  strip.CFrame*=CFrame.Angles(0,0,-x*.08)
 end
 for _,z in {-5.7,-2,1.8,5.6} do p("Roof seam",V(5.7,.06,.06),V(0,6.7,z),C(59,64,57),Enum.Material.Metal) end
 p("Cab front pressed steel",V(5.9,2.25,.25),V(0,2.35,-6.04),paint,Enum.Material.Metal)
 p("Front rounded shoulder",V(5.9,.5,.55),V(0,3.45,-5.92),paint,Enum.Material.Metal,Enum.PartType.Ball)
 for _,x in {-1.4,1.4} do
  local pane=p("Split van windshield",V(2.55,2.15,.08),V(x,4.83,-6.06),C(183,207,202),Enum.Material.Glass); pane.Transparency=.82; pane.CastShadow=false
  local wiper=Instance.new("Model"); wiper.Name="Working windshield wiper"; wiper.Parent=model
  p("Wiper spindle",V(.14,.14,.09),V(x,3.91,-6.14),chrome,Enum.Material.Metal,Enum.PartType.Ball,wiper)
  p("Windshield wiper arm",V(.055,1.15,.055),V(x,4.48,-6.14),chrome,Enum.Material.Metal,nil,wiper)
  p("Rubber wiper blade",V(.075,.75,.075),V(x,4.75,-6.18),rubber,Enum.Material.Rubber,nil,wiper)
  wiper.WorldPivot=CFrame.new(origin+V(x,3.91,-6.14))
  table.insert(wipers,wiper)
 end
 for _,x in {-2.88,0,2.88} do p("Windshield metal pillar",V(.13,2.75,.22),V(x,4.85,-6.05),chrome,Enum.Material.Metal) end
 p("Dashboard shelf",V(5.5,.22,.85),V(0,3.65,-5.42),C(68,70,61),Enum.Material.Metal)
 p("Instrument fascia",V(5.3,.75,.12),V(0,3.4,-4.97),C(58,62,55),Enum.Material.Metal)
 local needle
 for i,spec in {{-1.45,.65,"MPH"},{-.45,.4,"FUEL"},{.3,.4,"OIL"}} do
  local dial=p("Analog instrument "..spec[3],V(spec[2],spec[2],.065),V(spec[1],3.43,-4.88),rubber,nil,Enum.PartType.Ball)
  local face=Instance.new("SurfaceGui"); face.Face=Enum.NormalId.Back; face.CanvasSize=Vector2.new(240,240); face.Parent=dial
  local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1); text.Text=spec[3].."\n0  20  40\n60  80"; text.Font=Enum.Font.SpecialElite; text.TextScaled=true; text.BackgroundColor3=C(25,30,27); text.TextColor3=C(222,215,175); text.Parent=face
  local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(1,0); corner.Parent=text
  if i==1 then
   needle=Instance.new("Frame"); needle.Name="Speedometer needle"; needle.AnchorPoint=Vector2.new(.5,1); needle.Position=UDim2.fromScale(.5,.55); needle.Size=UDim2.fromScale(.025,.31); needle.BackgroundColor3=C(205,70,38); needle.BorderSizePixel=0; needle.Rotation=-110; needle.Parent=text
  end
 end
 for i,spec in {{"lights","LIGHTS · L"},{"wipers","WIPERS · B"}} do
  local switch=p("Dashboard "..spec[1].." switch",V(.18,.18,.16),V(.9+(i-1)*.55,3.25,-4.82),C(220,208,171),nil,Enum.PartType.Ball)
  switch.CanQuery=true; switches[spec[1]]=switch
  local plate=p("Dashboard "..spec[1].." label",V(.5,.15,.025),V(.9+(i-1)*.55,3.48,-4.81),paint)
  local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Back; gui.CanvasSize=Vector2.new(240,64); gui.Parent=plate
  local caption=Instance.new("TextLabel"); caption.Size=UDim2.fromScale(1,1); caption.Text=spec[2]; caption.TextScaled=true; caption.Font=Enum.Font.SpecialElite; caption.TextColor3=C(220,208,171); caption.BackgroundTransparency=1; caption.Parent=gui
 end
 p("Glovebox lid",V(1.3,.45,.04),V(1.6,3.45,-4.86),C(64,69,60),Enum.Material.Metal)
 p("Glovebox latch",V(.16,.08,.07),V(1.6,3.55,-4.82),chrome,Enum.Material.Metal)
 p("Floor shift lever",V(.09,1.25,.09),V(.3,1.9,-4.15),chrome,Enum.Material.Metal).CFrame*=CFrame.Angles(-.25,0,0)
 p("Gear knob",V(.22,.22,.22),V(.3,2.5,-4.3),C(69,49,32),Enum.Material.Wood,Enum.PartType.Ball)
 for _,x in {-1.4,1.4} do
  p("Stitched leather seat cushion",V(2.15,.4,1.5),V(x,2.35,-3.45),leather,Enum.Material.Leather)
  p("Cab seat back",V(2.15,1.55,.25),V(x,3.15,-2.62),leather,Enum.Material.Leather)
  for dx=-.75,.75,.3 do p("Seat stitch channel",V(.022,1.35,.025),V(x+dx,3.15,-2.77),C(135,102,65),Enum.Material.Fabric) end
 end
 for _,x in {-1.65,-1.1} do p("Driver floor pedal",V(.32,.09,.5),V(x,1.43,-5.25),rubber,Enum.Material.Rubber).CFrame*=CFrame.Angles(.3,0,0) end
 local wheel=Instance.new("Model"); wheel.Name="Turning steering wheel"; wheel.Parent=model
 local wheelCenter=V(-1.4,3.55,-4.48)
 for i=1,24 do local a=i*math.pi/12; local segment=p("Steering rim",V(.19,.095,.095),wheelCenter+V(math.cos(a)*.62,math.sin(a)*.62,0),C(56,38,24),Enum.Material.Wood,nil,wheel); segment.CFrame*=CFrame.Angles(0,0,a+math.pi/2) end
 for i=1,3 do local a=i*math.pi*2/3; local spoke=p("Steering spoke",V(.61,.055,.06),wheelCenter+V(math.cos(a)*.3,math.sin(a)*.3,0),chrome,Enum.Material.Metal,nil,wheel); spoke.CFrame*=CFrame.Angles(0,0,a) end
 p("Steering horn button",V(.2,.2,.1),wheelCenter,chrome,nil,Enum.PartType.Ball,wheel)
 wheel.WorldPivot=CFrame.new(origin+wheelCenter)
 local mirrors={}
 for _,side in {-1,1} do
  p("Mirror support arm",V(.65,.07,.07),V(side*3.15,4.5,-4.65),chrome,Enum.Material.Metal)
  local glass=p("Rearward wing mirror",V(.68,.95,.09),V(side*3.48,4.65,-4.65),C(129,155,155),Enum.Material.Metal)
  table.insert(mirrors,glass)
  p("Chrome headlamp rim",V(.95,.95,.2),V(side*2.05,2.5,-6.25),chrome,nil,Enum.PartType.Ball)
  local lens=p("Warm headlamp lens",V(.76,.76,.12),V(side*2.05,2.5,-6.38),C(237,222,170),Enum.Material.Glass,Enum.PartType.Ball)
  local beam=Instance.new("SpotLight"); beam.Face=Enum.NormalId.Front; beam.Angle=65; beam.Range=55; beam.Brightness=1.2; beam.Color=lens.Color; beam.Parent=lens; table.insert(lights,{beam=beam,lens=lens})
  p("Rear red tail lamp",V(.25,.45,.08),V(side*2.55,2.5,5.98),C(157,32,24),Enum.Material.Glass)
 end
 p("Radiator grille recess",V(2.45,2.4,.12),V(0,2.25,-6.24),rubber)
 for x=-1.1,1.1,.14 do p("Vertical chrome grille slat",V(.055,2.32,.16),V(x,2.25,-6.34),chrome,Enum.Material.Metal) end
 for _,z in {-6.4,6.1} do p("Chrome wraparound bumper",V(6.3,.28,.32),V(0,.95,z),chrome,Enum.Material.Metal) end
 local wheels={}
 for _,side in {-1,1} do
  for _,z in {-3.9,3.9} do
   local wheelModel=Instance.new("Model"); wheelModel.Name="Rolling van wheel"; wheelModel.Parent=model
   p("Van tire",V(.6,2.5,2.5),V(side*2.8,.55,z),rubber,Enum.Material.Rubber,Enum.PartType.Cylinder,wheelModel)
   p("Van wheel hub",V(.63,1.45,1.45),V(side*2.8,.55,z),chrome,Enum.Material.Metal,Enum.PartType.Cylinder,wheelModel)
   for i=1,5 do local a=i*math.pi*2/5; p("Wheel lug nut",V(.07,.11,.11),V(side*3.14,.55+math.cos(a)*.43,z+math.sin(a)*.43),C(81,86,79),Enum.Material.Metal,Enum.PartType.Ball,wheelModel) end
   wheelModel.WorldPivot=CFrame.new(origin+V(side*2.8,.55,z)); table.insert(wheels,{model=wheelModel,front=z<0})
   for a=0,math.pi,math.pi/10 do p("Wheel arch lip",V(.15,.17,.4),V(side*3.12,.55+math.sin(a)*1.42,z+math.cos(a)*1.42),paint,Enum.Material.Metal).CFrame*=CFrame.Angles(a,0,0) end
  end
 end
 local function door(side)
  local object=Instance.new("Model"); object.Name=side<0 and "Van driver door" or "Van passenger door"; object.Parent=model
  p("Door pressed lower panel",V(.13,2.1,2.8),V(side*3,2.45,-4.1),paint,Enum.Material.Metal,nil,object)
  p("Door interior leather",V(.04,1.65,2.4),V(side*2.9,2.5,-4.1),leather,Enum.Material.Leather,nil,object)
  local glass=p("Cab door glass",V(.09,1.8,2.55),V(side*3,4.8,-4.1),C(183,207,202),Enum.Material.Glass,nil,object); glass.Transparency=.82
  for _,z in {-5.55,-2.65} do p("Door window frame",V(.14,2.65,.13),V(side*3,4.7,z),chrome,Enum.Material.Metal,nil,object) end
  p("Exterior door handle",V(.15,.11,.45),V(side*3.12,3.45,-3.1),chrome,Enum.Material.Metal,nil,object)
  p("Entry running board",V(.65,.12,2.8),V(side*3.05,1,-4.1),rubber,Enum.Material.Metal)
  object.WorldPivot=CFrame.new(origin+V(side*3,1.4,-5.55)); return object
 end
 local driver,passenger=door(-1),door(1)
 local cargo=Instance.new("Model"); cargo.Name="Van rear cargo door"; cargo.Parent=model
 p("Rear hinged panel",V(5.8,4.85,.14),V(0,3.7,5.86),paint,Enum.Material.Metal,nil,cargo)
 p("Rear latch bar",V(.1,3.8,.13),V(0,3.7,5.99),chrome,Enum.Material.Metal,nil,cargo)
 cargo.WorldPivot=CFrame.new(origin+V(2.9,1.3,5.86))
 model.WorldPivot=CFrame.new(origin)
 model:PivotTo(CFrame.new(origin+V(60,.7,-53))*CFrame.Angles(0,-math.pi/2,0))
 return {switches=switches,lights=lights,wipers=wipers,wheels=wheels,model=model,driver=driver,passenger=passenger,cargo=cargo,wheel=wheel,needle=needle,mirrors=mirrors}
end
return Van
