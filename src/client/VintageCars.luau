-- Original period-inspired silhouettes, not replicas or licensed vehicle models.
local Cars={names={"Two-tone coupe","Rounded roof-rack compact","Wood-trim estate wagon","Stepside pickup"}}
function Cars.build(p,wheel,variant)
 local V=Vector3.new
 local C=Color3.fromRGB
 local chrome=C(192,196,184)
 local dark=C(29,30,28)
 local glass=C(67,94,99)
 local cream=C(224,219,191)
 local function trim(name,size,pos,rotation)
  local item=p(name,size,pos,chrome,nil,rotation); item.Material=Enum.Material.Metal; return item
 end
 local function body(name,size,pos,color)
  return p(name,size,pos,color,Enum.PartType.Ball)
 end
 local function lamps(width,z,y)
  for _,side in {-1,1} do
   body("Round chrome headlight bezel",V(.8,.8,.25),V(side*width,y,z),chrome)
   body("Warm headlight lens",V(.58,.58,.12),V(side*width,y,z-.15),C(244,222,169))
  end
 end
 local function wheels(width,front,rear,radius,whitewall)
  for _,side in {-1,1} do
   for _,z in {front,rear} do
    wheel(side*width,z,radius)
    if whitewall then
     p("Whitewall tire ring",V(.59,radius*1.7,radius*1.7),V(side*width,radius-.7,z),cream,Enum.PartType.Cylinder)
     local hub=p("Polished inset hubcap",V(.62,radius*1.12,radius*1.12),V(side*width,radius-.7,z),chrome,Enum.PartType.Cylinder); hub.Material=Enum.Material.Metal
    end
   end
  end
 end
 local function cabin(width,y,z,length,roof)
  p("Passenger cabin",V(width,1.45,length),V(0,y,z),roof)
  body("Curved cabin roof",V(width+.15,.45,length+.25),V(0,y+.78,z),roof)
  p("Front windshield",V(width-.3,1.15,.08),V(0,y,z-length/2-.045),glass)
  p("Rear windshield",V(width-.4,1.0,.08),V(0,y,z+length/2+.045),glass)
  for _,side in {-1,1} do
   p("Side cabin glazing",V(.07,1.12,length-.35),V(side*(width/2+.045),y,z),glass)
   trim("Window lower chrome",V(.09,.07,length-.25),V(side*(width/2+.09),y-.57,z))
  end
 end
 if variant==1 then
  local paint=C(82,165,157)
  p("Coupe chassis",V(4.7,.45,10.5),V(0,.65,0),dark)
  body("Coupe sweeping body",V(4.7,2.1,10.2),V(0,1.65,0),paint)
  body("Coupe long rounded hood",V(4.4,1.0,4.2),V(0,2.1,-3),paint)
  cabin(3.65,3.05,.6,4.5,cream)
  for _,side in {-1,1} do
   body("Coupe rear pontoon fender",V(.95,1.4,4.3),V(side*2.02,1.5,2.65),paint)
   trim("Coupe sweeping side spear",V(.10,.10,8.4),V(side*2.37,1.65,0),CFrame.Angles(.05,0,0))
   for i=1,4 do body("Coupe hood vent porthole",V(.08,.20,.26),V(side*2.16,2.15,-3.6+i*.48),chrome) end
  end
  lamps(1.85,-4.75,1.9)
  trim("Coupe broad chrome bumper",V(4.9,.25,.35),V(0,.85,-5.1))
  for x=-1.4,1.4,.28 do trim("Coupe waterfall grille tooth",V(.13,.65,.16),V(x,1.35,-5.02)) end
  wheels(2.2,-3.25,3.15,1.08,true)
 elseif variant==2 then
  local paint=C(162,187,152)
  p("Compact short chassis",V(3.5,.35,7.3),V(0,.55,0),dark)
  body("Compact domed body",V(3.8,2.3,7.2),V(0,1.7,0),paint)
  body("Compact sloping bonnet",V(2.9,1.55,3.8),V(0,1.7,-2.4),paint)
  cabin(2.9,2.8,.35,3.5,paint)
  body("Compact rounded rear deck",V(3.1,1.4,2.8),V(0,2.1,2.5),paint)
  for _,side in {-1,1} do
   for _,z in {-2.2,2.2} do body("Compact separate bulbous fender",V(1.1,1.6,2.45),V(side*1.63,1.05,z),paint) end
   trim("Compact running board",V(.45,.10,3),V(side*1.86,.58,0))
   trim("Roof rack side rail",V(.07,.07,3.1),V(side*1.25,4.12,.35))
   for _,z in {-.9,1.6} do trim("Roof rack upright",V(.07,.45,.07),V(side*1.25,3.95,z)) end
  end
  for z=-.9,1.6,.5 do trim("Roof rack crossbar",V(2.5,.06,.06),V(0,4.12,z)) end
  trim("Compact bonnet center seam",V(.04,.05,2.2),V(0,2.4,-2.7),CFrame.Angles(.12,0,0))
  lamps(1.4,-3.25,1.65)
  trim("Compact chrome bumper",V(3.9,.16,.23),V(0,.70,-3.7))
  wheels(1.72,-2.2,2.2,.9,false)
 elseif variant==3 then
  local paint=C(145,168,136); local wood=C(151,93,52)
  p("Estate long chassis",V(4.7,.45,11.3),V(0,.65,0),dark)
  body("Estate long body",V(4.75,2.0,11.2),V(0,1.6,0),paint)
  body("Estate rounded hood",V(4.3,1,3.4),V(0,2.1,-3.8),paint)
  cabin(3.8,3.05,1.2,6.5,paint)
  for _,side in {-1,1} do
   p("Wagon wood belt panel",V(.09,.38,6.7),V(side*1.96,2.38,1.2),wood)
   for _,z in {-2.05,.0,2.0,4.45} do p("Wagon timber window pillar",V(.12,1.5,.16),V(side*1.98,3.03,z),wood) end
   trim("Wagon lower chrome moulding",V(.10,.09,9),V(side*2.36,1.30,.2))
   for _,z in {-.9,1.1} do trim("Wagon door handle",V(.13,.09,.36),V(side*2.1,2.2,z)) end
  end
  p("Estate tailgate wood inset",V(3.4,.45,.08),V(0,2.35,4.51),wood)
  lamps(1.8,-5.05,1.85)
  for y=1.1,1.65,.18 do trim("Wagon horizontal grille",V(3.4,.08,.16),V(0,y,-5.28)) end
  trim("Wagon bumper",V(4.9,.26,.3),V(0,.75,-5.5))
  wheels(2.23,-3.5,3.4,1.1,true)
 else
  local paint=C(169,44,33)
  p("Pickup ladder chassis",V(4.4,.5,10.2),V(0,.65,0),dark)
  body("Pickup rounded hood",V(4.2,1.8,3.5),V(0,1.9,-3.25),paint)
  cabin(3.8,3.1,-.85,2.7,paint)
  p("Open pickup bed floor",V(3.6,.18,4.6),V(0,1.2,2.7),C(112,83,52))
  for _,side in {-1,1} do
   p("Pickup bed side",V(.18,1.1,4.7),V(side*1.9,1.8,2.7),paint)
   trim("Pickup bed rail",V(.23,.1,4.8),V(side*1.9,2.4,2.7))
   body("Pickup rear stepside fender",V(1.2,1.4,2.8),V(side*2.0,1.2,3.2),paint)
   body("Pickup front fender",V(1.0,1.6,3.0),V(side*1.95,1.3,-3.2),paint)
   p("Pickup running step",V(.65,.15,1.8),V(side*2.1,.65,-.3),dark)
  end
  p("Pickup tailgate",V(3.8,1.15,.16),V(0,1.8,5),paint)
  for x=-1.5,1.5,.5 do trim("Bed floor strip",V(.035,.025,4.3),V(x,1.31,2.7)) end
  lamps(1.65,-4.7,1.85)
  for y=1.0,2.15,.23 do trim("Pickup horizontal grille bar",V(3.2,.11,.18),V(0,y,-4.82)) end
  trim("Pickup heavy bumper",V(4.7,.25,.3),V(0,.65,-5))
  wheels(2.13,-3.2,3.25,1.12,false)
 end
end
return Cars
