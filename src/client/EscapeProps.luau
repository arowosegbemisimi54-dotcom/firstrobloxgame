local Cast=require(script.Parent.DinerCast)
local Props={}
function Props.build(ctx)
 local V,C=Vector3.new,Color3.fromRGB
 local origin,ext=ctx.origin,ctx.exterior
 local folder=Instance.new("Model"); folder.Name="Highway Four escape cast and props"; folder.Parent=ctx.model
 local function p(name,size,pos,color,material,shape,parent)
  return ext.part(name,size,pos,color,material,shape,parent or folder)
 end
 local function paper(name,pos,denomination)
  local bill=p(name,V(1.1,.018,.5),pos,C(177,185,142),Enum.Material.Fabric)
  for _,side in {Enum.NormalId.Top,Enum.NormalId.Bottom} do
   local gui=Instance.new("SurfaceGui"); gui.Face=side; gui.CanvasSize=Vector2.new(600,270); gui.Parent=bill
   local border=Instance.new("Frame"); border.Size=UDim2.fromScale(.94,.86); border.Position=UDim2.fromScale(.03,.07); border.BackgroundTransparency=1; border.Parent=gui
   local stroke=Instance.new("UIStroke"); stroke.Thickness=5; stroke.Color=C(60,83,52); stroke.Parent=border
   local title=Instance.new("TextLabel"); title.Size=UDim2.fromScale(1,.25); title.BackgroundTransparency=1; title.Text="FEDERAL RESERVE NOTE"; title.TextColor3=C(50,72,44); title.Font=Enum.Font.SpecialElite; title.TextScaled=true; title.Parent=border
   for _,x in {0,.75} do local number=title:Clone(); number.Position=UDim2.fromScale(x,.3); number.Size=UDim2.fromScale(.25,.55); number.Text=denomination; number.Parent=border end
   local seal=Instance.new("TextLabel"); seal.Size=UDim2.fromScale(.4,.52); seal.Position=UDim2.fromScale(.3,.28); seal.BackgroundColor3=C(143,158,116); seal.Text="★\nLIBERTY"; seal.Font=Enum.Font.SpecialElite; seal.TextScaled=true; seal.TextColor3=C(53,76,47); seal.Parent=border
   local round=Instance.new("UICorner"); round.CornerRadius=UDim.new(1,0); round.Parent=seal
   local serial=title:Clone(); serial.Position=UDim2.fromScale(0,.8); serial.Size=UDim2.fromScale(1,.18); serial.Text="H 19400417 A  •  ONE HUNDRED DOLLARS"; serial.Parent=border
  end
  return bill
 end
 local receipt=p("Diner handwritten check",V(.62,.015,.95),V(-30.6,3.02,-7),C(231,218,180))
 local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Top; gui.CanvasSize=Vector2.new(280,430); gui.Parent=receipt
 local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1); text.Text="SUNSET DINER\nCHECK No. 0417\n──────────\nHot lunch    1.25\nCoffee        .10\nPie           .25\nTax           .05\n──────────\nTOTAL       $1.65\n\nThank you!"; text.Font=Enum.Font.SpecialElite; text.TextScaled=true; text.TextColor3=C(54,49,38); text.BackgroundTransparency=1; text.Parent=gui
 local payment=paper("Payment hundred dollar bill",V(-33.9,3.055,-6.4),"100"); payment.Transparency=1
 for _,g in payment:GetChildren() do if g:IsA("SurfaceGui") then g.Enabled=false end end
 local airborne=paper("Escaping hundred dollar bill",V(60,-20,-53),"100")
 local truck=ext.parked(4,V(-115,0,-55),-math.pi/2); truck.Name="Damaged primary getaway pickup"
 for _,obj in truck:GetDescendants() do
  if obj:IsA("BasePart") and (obj.Name:find("hood") or obj.Name:find("fender")) then obj.Color=C(91,78,62); obj.Material=Enum.Material.CorrodedMetal end
 end
 local function attach(model,name,size,at,color)
  local pivot=model:GetPivot()
  local obj=p(name,size,V(0,0,0),color,nil,nil,model); obj.CFrame=pivot*CFrame.new(at); return obj
 end
 for i=1,7 do attach(truck,"Tailgate bullet impact",V(.09,.09,.025),V(-1.4+i*.38,1.5+(i%3)*.2,5.1),C(18,18,17)) end
 local radiator=attach(truck,"Steaming radiator",V(.2,.2,.2),V(0,2,-4.5),C(70,70,65)); radiator.Transparency=1
 local function smoke(parent,rate,size)
  local emitter=Instance.new("ParticleEmitter"); emitter.Name="Cinematic smoke"; emitter.Texture="rbxasset://textures/particles/smoke_main.dds"; emitter.Rate=rate; emitter.Lifetime=NumberRange.new(1.5,3); emitter.Speed=NumberRange.new(1,3); emitter.SpreadAngle=Vector2.new(30,30); emitter.Acceleration=V(1,2,0); emitter.Color=ColorSequence.new(C(153,149,135)); emitter.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.25),NumberSequenceKeypoint.new(1,1)}); emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.6),NumberSequenceKeypoint.new(1,size)}); emitter.Parent=parent; return emitter
 end
 local steam=smoke(radiator,14,5)
 local exhaust=attach(ext.van,"Getaway rear tire smoke source",V(.1,.1,.1),V(2.8,.5,3.9),C(25,25,25)); exhaust.Transparency=1
 local burnout=smoke(exhaust,0,4)
 local function rig(index,name,masked)
  -- Crew/officers must not inherit a player's rig type, accessories or held props.
  local template=assert(ctx.rigTemplate,"Escape cast requires its R15 template")
  local character=template:Clone(); character.Name=name
  for _,obj in character:GetDescendants() do
   if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("Animator") then obj:Destroy()
   elseif obj:IsA("BasePart") then obj.CanCollide=false; obj.CanTouch=false; obj.CanQuery=false end
  end
  local humanoid=character:FindFirstChildOfClass("Humanoid")
  if humanoid then humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
  local _,face=Cast.dress(character,(index-1)%6+1); character.Name=name; character.Parent=folder
  local joints={}
  for _,obj in character:GetDescendants() do if obj:IsA("Motor6D") then joints[obj.Name]={joint=obj,base=obj.C0} end end
  local root=character:FindFirstChild("HumanoidRootPart"); root.Anchored=true; character.PrimaryPart=root
  local function wearable(body,name,size,offset,color)
   local obj=p(name,size,V(0,0,0),color,Enum.Material.Fabric,nil,character); obj.Anchored=false; obj.Massless=true; obj.CFrame=body.CFrame*offset
   local weld=Instance.new("WeldConstraint"); weld.Part0=body; weld.Part1=obj; weld.Parent=obj; return obj
  end
  local head=character:FindFirstChild("Head")
  local bag
  local baggage={}
  if masked then
   wearable(head,"Crew folded bandanna",V(1.12,.5,.14),CFrame.new(0,-.25,-.56),C(37+index*9,38+index*5,35))
   local arm=character:FindFirstChild("LeftHand")
   bag=wearable(arm,"Cash filled canvas duffel",V(1.1,.9,1.9),CFrame.new(0,-.75,0),C(76,70,48)); bag.Shape=Enum.PartType.Ball
   table.insert(baggage,wearable(arm,"Duffel leather handle",V(.6,.16,.15),CFrame.new(0,-.25,0),C(49,37,25)))
   table.insert(baggage,wearable(arm,"Duffel zipper",V(.05,.04,1.5),CFrame.new(0,-.3,0),C(178,159,105)))
  else
   for _,obj in character:GetDescendants() do if obj:IsA("BasePart") and (obj.Name:find("jacket") or obj.Name:find("trouser") or obj.Name:find("Torso") or obj.Name:find("Arm") or obj.Name:find("Leg")) then obj.Color=C(37,49,64) end end
   wearable(character.UpperTorso,"Officer brass badge",V(.2,.25,.04),CFrame.new(-.5,.45,-.61),C(191,153,70))
   local arm=character:FindFirstChild("RightHand")
   wearable(arm,"Period service revolver",V(.16,.19,.65),CFrame.new(0,-.15,-.28),C(49,51,51))
  end
  return {rig=character,face=face,joints=joints,style=masked and "crew" or "officer",bag=bag,baggage=baggage,index=index}
 end
 local crew,officers={},{}
 for i=1,4 do crew[i]=rig(i,"Masked crew "..i,true); crew[i].rig:PivotTo(CFrame.new(origin+V(-115,-30,-55))) end
 for i=1,2 do officers[i]=rig(i+1,"Highway patrol officer "..i,false); officers[i].rig:PivotTo(CFrame.new(origin+V(-115,-30,-55))) end
 local cargoBags={}
 for i=1,4 do
  local bag=attach(ext.van,"Stowed cash duffel "..i,V(1.1,.9,1.9),V((i%2)*1.3-.65,1.8,2.8+math.floor((i-1)/2)*1.8),C(76,70,48)); bag.Shape=Enum.PartType.Ball; bag.Transparency=1; cargoBags[i]=bag
 end
 local police={}
 for i=1,2 do
  local car=ext.parked(1,V(-180-i*18,0,140),-math.pi/2); car.Name="Highway patrol cruiser "..i
  for _,obj in car:GetDescendants() do if obj:IsA("BasePart") and obj.Name:find("Coupe") then obj.Color=C(28,33,36) end end
  local beacon=attach(car,"Red rotating police beacon",V(.65,.7,.65),V(0,4.25,.3),C(207,39,25)); beacon.Material=Enum.Material.Neon
  local light=Instance.new("PointLight"); light.Color=C(255,54,29); light.Range=19; light.Brightness=2; light.Parent=beacon
  local lamp=attach(car,"Cruiser spotlamp",V(.4,.4,.4),V(2,3,-1.4),C(213,210,179))
  local beam=Instance.new("SpotLight"); beam.Face=Enum.NormalId.Front; beam.Range=45; beam.Angle=55; beam.Brightness=2; beam.Parent=lamp
  local pivot=car:GetPivot()
  local wheels={}
  for _,obj in car:GetDescendants() do
   if obj:IsA("BasePart") and (obj.Name=="Parked tire" or obj.Name=="Parked hubcap" or obj.Name=="Whitewall tire ring" or obj.Name=="Polished inset hubcap") then
    local offset=pivot:ToObjectSpace(obj.CFrame)
    table.insert(wheels,{part=obj,offset=offset,front=offset.Position.Z<0})
   end
  end
  local door=Instance.new("Model"); door.Name="Patrol driver door"; door.Parent=car
  local hinge=pivot*CFrame.new(-1.94,2.5,-1.4)
  for _,spec in {{"Patrol door panel",V(.12,.9,2.3),V(-1.94,1.9,-.25),C(32,38,41)}, {"Patrol door window",V(.08,.95,2.1),V(-1.94,2.9,-.25),C(67,94,99)}, {"Patrol door handle",V(.18,.1,.35),V(-2.04,2.35,.52),C(192,196,184)}} do
   local item=attach(car,spec[1],spec[2],spec[3],spec[4]); item.Parent=door
  end
  door.WorldPivot=hinge
  police[i]={model=car,light=light,x=-180-i*18,z=140,yaw=-math.pi/2,speed=0,wheels=wheels,door=door,doorOffset=pivot:ToObjectSpace(hinge)}
 end
 return {cargoBags=cargoBags,folder=folder,payment=payment,airborne=airborne,truck=truck,steam=steam,burnout=burnout,crew=crew,officers=officers,police=police}
end
return Props
