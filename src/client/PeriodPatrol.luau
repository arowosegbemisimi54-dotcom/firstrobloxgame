-- Original late-1940s-inspired patrol sedan. Open cabin, opening front doors,
-- rounded fenders and a single rotating red beacon; no catalog vehicle assets.
local Patrol={}
function Patrol.build(part,origin,parent,index)
 local V,C=Vector3.new,Color3.fromRGB
 local model=Instance.new("Model"); model.Name="Highway patrol cruiser "..index; model.Parent=parent
 local black,chrome,rubber=C(22,29,32),C(178,188,184),C(27,29,28)
 local function p(name,size,pos,color,material,shape,where)
  local object=part(name,size,pos,color,material or Enum.Material.Metal,shape,where or model)
  object.Reflectance=material==Enum.Material.Glass and 0 or .08
  return object
 end
 local function rounded(name,size,pos,color) return p(name,size,pos,color,Enum.Material.Metal,Enum.PartType.Ball) end
 local function label(object,face,text,width,height)
  local gui=Instance.new("SurfaceGui"); gui.Face=face; gui.CanvasSize=Vector2.new(width or 700,height or 240); gui.LightInfluence=.85; gui.Parent=object
  local textLabel=Instance.new("TextLabel"); textLabel.Size=UDim2.fromScale(.9,.9); textLabel.Position=UDim2.fromScale(.05,.05); textLabel.BackgroundTransparency=1; textLabel.Text=text; textLabel.TextScaled=true; textLabel.Font=Enum.Font.SpecialElite; textLabel.TextColor3=C(232,226,202); textLabel.Parent=gui
 end
 p("Patrol ladder frame",V(4.5,.35,11.7),V(0,.6,0),rubber)
 p("Sedan lower body",V(4.9,.75,10.2),V(0,1.05,0),black)
 rounded("Sweeping sedan hood",V(4.7,1.05,4.8),V(0,2,-3.5),black)
 p("Hood lower apron",V(4.3,.55,3.8),V(0,1.65,-3.6),black)
 p("Hood center chrome seam",V(.06,.035,3.3),V(0,2.53,-3.5),chrome)
 rounded("Rounded rear deck",V(4.9,1.3,3.6),V(0,1.95,4.1),black)
 p("Open cabin floor",V(4.6,.15,5.6),V(0,1.22,.6),C(60,58,48))
 for _,x in {-1.05,1.05} do
  p("Patrol front seat",V(1.85,.35,1.55),V(x,1.65,-.1),C(85,66,43),Enum.Material.Leather)
  p("Patrol front seat back",V(1.85,1.5,.26),V(x,2.43,.68),C(85,66,43),Enum.Material.Leather)
 end
 p("Patrol rear bench cushion",V(4.1,.4,1.35),V(0,1.7,2.1),C(85,66,43),Enum.Material.Leather)
 p("Patrol rear bench back",V(4.1,1.5,.25),V(0,2.5,2.85),C(85,66,43),Enum.Material.Leather)
 p("Patrol dashboard",V(4.35,.5,.55),V(0,2.5,-1.65),C(62,64,58))
 local instrument=p("Patrol speed dial",V(.6,.6,.06),V(-1.05,2.55,-1.33),rubber)
 label(instrument,Enum.NormalId.Back,"MPH\n0  40  80",240,240)
 for i=1,20 do
  local a=i*math.pi/10
  p("Patrol steering rim",V(.18,.075,.075),V(-1.05+math.cos(a)*.46,2.8+math.sin(a)*.46,-1.03),rubber).CFrame*=CFrame.Angles(0,0,a+math.pi/2)
 end
 p("Patrol wheel spoke",V(.85,.06,.06),V(-1.05,2.8,-1.03),chrome)
 p("Period dash radio",V(.85,.45,.32),V(.9,2.65,-1.4),C(47,43,34))
 for _,x in {.6,1.2} do rounded("Radio tuning knob",V(.12,.12,.1),V(x,2.66,-1.2),chrome) end
 -- Glazing is inset between real pillars; there is no solid cabin box.
 for _,side in {-1,1} do
  local glass=p("Split patrol windshield",V(1.95,1.95,.09),V(side*1.03,3.78,-1.94),C(146,173,171),Enum.Material.Glass)
  glass.Transparency=.73; glass.CastShadow=false; glass.CFrame*=CFrame.Angles(-.16,0,0)
  p("Windshield outer pillar",V(.16,2.35,.16),V(side*2.1,3.82,-1.9),black).CFrame*=CFrame.Angles(-.16,0,0)
  p("Windshield chrome border",V(2.03,.07,.1),V(side*1.03,2.82,-2.1),chrome)
  p("Patrol windscreen wiper",V(.055,.72,.07),V(side*1.07,3.2,-2.13),rubber).CFrame*=CFrame.Angles(0,0,-.42)
  p("Rear quarter pillar",V(.2,2.35,.3),V(side*2.16,3.67,2.95),black).CFrame*=CFrame.Angles(.22,0,0)
  p("Sedan center pillar",V(.15,2.3,.18),V(side*2.29,3.7,.65),black)
  local quarter=p("Rear quarter glass",V(.08,1.78,1.75),V(side*2.23,3.77,1.9),C(146,173,171),Enum.Material.Glass); quarter.Transparency=.72; quarter.CastShadow=false
  p("Rear door skin",V(.16,1.25,2.2),V(side*2.38,2.05,1.9),black)
  p("Rear door chrome handle",V(.2,.09,.38),V(side*2.53,2.68,2.48),chrome)
  p("Rear door window sill",V(.18,.08,2.28),V(side*2.33,2.81,1.9),chrome)
 end
 p("Split screen center bar",V(.09,2.35,.12),V(0,3.78,-1.96),chrome).CFrame*=CFrame.Angles(-.16,0,0)
 local rear=p("Curved rear windscreen",V(3.7,1.7,.1),V(0,3.8,3),C(146,173,171),Enum.Material.Glass); rear.Transparency=.7; rear.CastShadow=false; rear.CFrame*=CFrame.Angles(.23,0,0)
 rounded("Domed steel sedan roof",V(4.65,.38,5.7),V(0,4.9,.55),black)
 for _,side in {-1,1} do
  p("Sedan rain gutter",V(.11,.09,5.6),V(side*2.25,4.76,.55),chrome)
  p("Sedan lower chrome moulding",V(.12,.11,9.4),V(side*2.5,1.29,.05),chrome)
  for _,z in {-3.55,3.45} do
   rounded("Separate pontoon fender",V(1.25,1.55,3.5),V(side*2.17,1.15,z),black)
   for step=0,10 do
    local a=step*math.pi/10
    p("Chrome wheel arch lip",V(.10,.13,.38),V(side*2.72,.43+math.sin(a)*1.3,z+math.cos(a)*1.3),chrome).CFrame*=CFrame.Angles(a,0,0)
   end
  end
  rounded("Round patrol headlight bezel",V(.96,.96,.24),V(side*1.93,2.02,-5.56),chrome)
  local lens=p("Patrol headlight lens",V(.72,.72,.12),V(side*1.93,2.02,-5.72),C(239,225,179),Enum.Material.Glass,Enum.PartType.Ball)
  local light=Instance.new("SpotLight"); light.Face=Enum.NormalId.Front; light.Color=C(255,226,170); light.Range=46; light.Angle=65; light.Brightness=.8; light.Parent=lens
 end
 p("Dark radiator mouth",V(3.45,.8,.12),V(0,1.3,-5.81),rubber)
 for i=-7,7 do p("Vertical patrol grille tooth",V(.12,.68,.15),V(i*.21,1.32,-5.9),chrome) end
 for _,y in {.87,1.76} do
  p("Swept chrome grille bar",V(4.2,.16,.24),V(0,y,-5.95),chrome)
  for _,side in {-1,1} do rounded("Curved grille return",V(.85,.2,.52),V(side*2.08,y,-5.72),chrome) end
 end
 rounded("Plain hood medallion",V(.32,.16,.06),V(0,2.01,-5.81),chrome)
 for _,z in {-6.13,5.9} do
  p("Heavy chrome patrol bumper",V(5.2,.27,.3),V(0,.65,z),chrome)
  for _,side in {-1,1} do rounded("Bumper curved corner",V(.6,.28,.8),V(side*2.48,.65,z+(z<0 and .25 or -.25)),chrome); p("Bumper over-rider",V(.19,.65,.26),V(side*1.45,.85,z+(z<0 and -.1 or .1)),chrome) end
 end
 local brakes={}
 for _,side in {-1,1} do table.insert(brakes,p("Patrol rear brake lens",V(.25,.45,.08),V(side*2.16,1.76,5.73),C(139,26,19),Enum.Material.Glass)) end
 local plate=p("County patrol license plate",V(1.2,.5,.05),V(0,.7,-6.32),C(27,33,32))
 label(plate,Enum.NormalId.Front,"COUNTY  •  4"..index,480,200)
 local wheels={}
 for _,side in {-1,1} do for _,z in {-3.55,3.45} do
  for _,spec in {{"Patrol rubber tire",.65,2.26,rubber,Enum.Material.Rubber},{"Thin patrol whitewall",.68,1.9,C(216,210,184),Enum.Material.SmoothPlastic},{"Black wheel inset",.70,1.55,rubber,Enum.Material.Metal},{"Domed chrome hubcap",.73,1.15,chrome,Enum.Material.Metal}} do
   local wheel=p(spec[1],V(spec[2],spec[3],spec[3]),V(side*2.48,.43,z),spec[4],spec[5],Enum.PartType.Cylinder)
   table.insert(wheels,{part=wheel,offset=CFrame.new(V(side*2.48,.43,z)),front=z<0})
  end
 end end
 local driver
 for _,side in {-1,1} do
  local door=Instance.new("Model"); door.Name=side<0 and "Patrol driver door" or "Patrol passenger door"; door.Parent=model
  local skin=p("Opening patrol door skin",V(.15,1.25,2.5),V(side*2.38,2.05,-.65),black,nil,nil,door)
  label(skin,side<0 and Enum.NormalId.Left or Enum.NormalId.Right,"NORTH COUNTY\n4"..index.."  •  POLICE",680,280)
  p("Door interior upholstery",V(.06,1.1,2.3),V(side*2.25,2.08,-.65),C(77,61,44),Enum.Material.Leather,nil,door)
  local glass=p("Opening patrol door window",V(.08,1.83,2.32),V(side*2.27,3.76,-.65),C(146,173,171),Enum.Material.Glass,nil,door); glass.Transparency=.73; glass.CastShadow=false
  for _,z in {-1.87,.57} do p("Opening door window pillar",V(.13,2.3,.12),V(side*2.29,3.68,z),black,nil,nil,door) end
  for _,y in {2.81,4.68} do p("Opening door window rail",V(.15,.08,2.53),V(side*2.29,y,-.65),chrome,nil,nil,door) end
  p("Door chrome handle",V(.22,.1,.43),V(side*2.52,2.63,.1),chrome,nil,nil,door)
  p("Manual window crank",V(.12,.28,.08),V(side*2.2,2.35,-.95),chrome,nil,nil,door).CFrame*=CFrame.Angles(.5,0,0)
  door.WorldPivot=CFrame.new(origin+V(side*2.38,1.9,-1.9))
  if side<0 then driver=door end
 end
 local spot=p("Cowl mounted search lamp",V(.52,.52,.55),V(-2.2,3.02,-2.32),chrome,Enum.Material.Metal,Enum.PartType.Ball)
 local search=Instance.new("SpotLight"); search.Face=Enum.NormalId.Front; search.Color=C(255,230,181); search.Angle=35; search.Range=38; search.Brightness=.7; search.Parent=spot
 p("Flexible whip aerial",V(.025,2.3,.025),V(2.1,5.32,2.3),rubber)
 p("Single beacon chrome base",V(.32,.94,.94),V(0,5.15,.35),chrome,nil,Enum.PartType.Cylinder).CFrame*=CFrame.Angles(0,0,math.pi/2)
 local dome=p("Single red glass police beacon",V(.8,.87,.8),V(0,5.52,.35),C(156,18,17),Enum.Material.Glass,Enum.PartType.Ball); dome.Transparency=.24
 local rotor=p("Rotating beacon reflector",V(.28,.32,.12),V(0,5.46,.35),C(242,72,43),Enum.Material.Neon)
 local beam=Instance.new("SpotLight"); beam.Face=Enum.NormalId.Front; beam.Color=C(255,44,26); beam.Angle=85; beam.Range=29; beam.Brightness=2.2; beam.Parent=rotor
 local glow=Instance.new("PointLight"); glow.Color=C(244,48,26); glow.Range=13; glow.Brightness=.35; glow.Parent=dome
 model.WorldPivot=CFrame.new(origin)
 local doorOffset=CFrame.new(-2.38,1.9,-1.9)
 model:PivotTo(CFrame.new(origin+V(-180-index*18,.7,140))*CFrame.Angles(0,-math.pi/2,0))
 return {model=model,light=glow,beacon=rotor,beaconOffset=CFrame.new(0,5.46,.35),brakes=brakes,
  x=-180-index*18,z=140,yaw=-math.pi/2,speed=0,wheels=wheels,radius=1.13,door=driver,doorOffset=doorOffset,
  driverSeat=CFrame.new(-.82,1.7,-.15),driverStep=CFrame.new(-3.6,1.8,-.35),driverExit=CFrame.new(-4.7,2.3,.9)}
end
return Patrol
