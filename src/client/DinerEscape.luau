-- Local story chapter. Uses the existing isolated R15 scene; no shared-world rewards.
local RunService=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local Actions=game:GetService("ContextActionService")
local Lighting=game:GetService("Lighting")
local Rules=require(game:GetService("ReplicatedStorage"):WaitForChild("GameShared").EscapeRules)
local Props=require(script.Parent.EscapeProps)
local Audio=require(script.Parent.EscapeAudio)
local Motion=require(script.Parent.CharacterMotion)
local Escape={}
function Escape.prepare(ctx)
 local props=Props.build(ctx)
 local audio=Audio.create(ctx.model,Rules.lines)
 local disposed=false
 return {props=props,audio=audio,destroy=function()
  if disposed then return end; disposed=true; audio.destroy(); props.folder:Destroy()
 end}
end
function Escape.start(ctx)
 local V,C=Vector3.new,Color3.fromRGB
 local origin,ext,hero=ctx.origin,ctx.exterior,ctx.actors[1]
 local prepared=ctx.prepared or Escape.prepare(ctx)
 local props,audio=prepared.props,prepared.audio
 local state=Rules.new()
 local ui,root=ctx.ui,ctx.root
 local hud=ui.make("Frame",{Name="Highway Four chapter HUD",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=30},root)
 local function label(name,text,pos,size,fontSize)
  return ui.make("TextLabel",{Name=name,Text=text,Position=pos,Size=size,BackgroundColor3=C(20,21,19),BackgroundTransparency=.23,TextColor3=C(245,235,209),TextSize=fontSize,TextWrapped=true,Font=Enum.Font.SpecialElite,BorderSizePixel=0},hud)
 end
 local objective=label("Mission objective","Leave your payment on the table and step outside.",UDim2.fromScale(.035,.14),UDim2.new(.45,0,0,66),18)
 local subtitle=label("Escape dialogue","",UDim2.fromScale(.08,.73),UDim2.fromScale(.84,.13),20); subtitle.Visible=false
 local hint=label("Interaction hint","E / X · Leave payment",UDim2.fromScale(.32,.88),UDim2.fromScale(.36,.065),18)
 local bars={}
 for _,y in {0,1} do table.insert(bars,ui.make("Frame",{Size=UDim2.fromScale(1,.07),Position=UDim2.fromScale(0,y),AnchorPoint=Vector2.new(0,y),BackgroundColor3=C(0,0,0),BorderSizePixel=0,Visible=false},hud)) end
 local title=ui.make("TextLabel",{Name="Shirts and Skins title drop",Size=UDim2.fromScale(1,1),BackgroundColor3=C(0,0,0),Text="SHIRTS & SKINS",TextColor3=C(226,210,168),Font=Enum.Font.SpecialElite,TextScaled=true,Visible=false,ZIndex=40},hud)
 ui.make("UIPadding",{PaddingLeft=UDim.new(.1,0),PaddingRight=UDim.new(.1,0),PaddingTop=UDim.new(.38,0),PaddingBottom=UDim.new(.38,0)},title)
 ui.make("UITextSizeConstraint",{MaxTextSize=72,MinTextSize=20},title)
 local ended=false
 local connections={}
 local bound={}
 local held={}
 local moveStick=V(0,0,0)
 local lookStick=V(0,0,0)
 local yaw=math.pi
 local pitch=.12
 local firstPerson=false
 local driveOrbit=0
 local drivePitch=.3
 local driveZoom=19
 local frameDt=1/60
 local looking=false
 local originalMouse=Input.MouseBehavior
 local originalIcon=Input.MouseIconEnabled
 local heroPos=V(-31,2.65,-10.5)
 local elapsed=0
 local lastKey=""
 local shake=0
 local camera=workspace.CurrentCamera
 local initialCamera=camera.CFrame
 local vanCF=ext.van:GetPivot()
 local doorBase=ext.door:GetPivot()
 local driverOffset=vanCF:ToObjectSpace(ext.driverDoor:GetPivot())
 local passengerOffset=vanCF:ToObjectSpace(ext.passengerDoor:GetPivot())
 local cargoOffset=vanCF:ToObjectSpace(ext.cargoDoor:GetPivot())
 local car={x=290,z=140,yaw=-math.pi/2,speed=32}
 local mission={clearTime=0,bustTime=0,lost=false}
 local resultPanel
 local function positionVehicle(vehicle,pos,angle) vehicle:PivotTo(CFrame.new(origin+pos)*CFrame.Angles(0,angle,0)) end
 local function pose(person,pos,angle,walk,seated)
  Motion.pose(person,origin,pos,angle,frameDt,seated,elapsed)
 end
 local function vanish(person)
  -- Keep the seated crew inside the opaque cargo compartment, not outside the scene.
  person.rig:PivotTo(ext.van:GetPivot()*CFrame.new(0,3.2,1.5))
 end
 local function seatHero()
  local seat=ext.van:GetPivot()*CFrame.new(-1.4,3.1,-3.8)
  hero.rig:PivotTo(seat)
  for _,side in {"Left","Right"} do ctx.setJoint(hero,side.."Hip",CFrame.Angles(1.35,0,0)); ctx.setJoint(hero,side.."Knee",CFrame.Angles(-1.35,0,0)); ctx.setJoint(hero,side.."Elbow",CFrame.Angles(.55,0,0)); ctx.setJoint(hero,side.."Shoulder",CFrame.Angles(1,0,0)) end
 end
 local function doors(driver,passenger,cargo)
  vanCF=ext.van:GetPivot()
  ext.driverDoor:PivotTo(vanCF*driverOffset*CFrame.Angles(0,driver,0))
  ext.passengerDoor:PivotTo(vanCF*passengerOffset*CFrame.Angles(0,passenger,0))
  ext.cargoDoor:PivotTo(vanCF*cargoOffset*CFrame.Angles(0,cargo,0))
 end
 local function view(pos,target,fov,dt,smooth)
  local cf=CFrame.lookAt(origin+pos,origin+target)
  if not ctx.reducedMotion() and shake>0 then cf*=CFrame.Angles(math.sin(elapsed*71)*shake,math.sin(elapsed*53)*shake*.7,math.sin(elapsed*39)*shake*.35) end
  camera.CameraType=Enum.CameraType.Scriptable
  camera.CFrame=smooth and camera.CFrame:Lerp(cf,1-math.exp(-dt*8)) or cf
  camera.FieldOfView=fov
 end
 local function talk(name)
  subtitle.Text=Rules.lines[name] or ""; subtitle.Visible=subtitle.Text~=""; audio.say(name)
 end
 local function interact()
  if Rules.interact(state) then
   hint.Text="Leaving payment…"
   for _,p in hero.rig:GetChildren() do if p:IsA("BasePart") and (p.Name=="Utensil handle" or p.Name=="Fork shoulder" or p.Name=="Held fork tine") then p:Destroy() end end
  end
 end
 local function bind(name,keys,callback,touch,titleText,pos)
  local id="HighwayFour_"..name; table.insert(bound,id)
  Actions:BindActionAtPriority(id,function(_,inputState,input)
   if ended then return Enum.ContextActionResult.Pass end
   callback(inputState,input); return Enum.ContextActionResult.Sink
  end,touch,4000,table.unpack(keys))
  if touch then Actions:SetTitle(id,titleText); Actions:SetPosition(id,pos) end
 end
 local function key(name)
  return function(s) held[name]=s==Enum.UserInputState.Begin or s==Enum.UserInputState.Change end
 end
 bind("Forward",{Enum.KeyCode.W,Enum.KeyCode.Up},key("forward"),true,"▲",UDim2.fromScale(.16,.7))
 bind("Reverse",{Enum.KeyCode.S,Enum.KeyCode.Down},key("reverse"),true,"▼",UDim2.fromScale(.16,.87))
 bind("Left",{Enum.KeyCode.A,Enum.KeyCode.Left},key("left"),true,"◀",UDim2.fromScale(.07,.79))
 bind("Right",{Enum.KeyCode.D,Enum.KeyCode.Right},key("right"),true,"▶",UDim2.fromScale(.25,.79))
 bind("Brake",{Enum.KeyCode.Space,Enum.KeyCode.ButtonL2},key("brake"),true,"Brake",UDim2.fromScale(.84,.84))
 bind("Throttle",{Enum.KeyCode.ButtonR2},key("forward"),false)
 bind("Interact",{Enum.KeyCode.E,Enum.KeyCode.ButtonX},function(s) if s==Enum.UserInputState.Begin then interact() end end,true,"Pay",UDim2.fromScale(.84,.69))
 bind("View",{Enum.KeyCode.V,Enum.KeyCode.ButtonR3},function(s) if s==Enum.UserInputState.Begin and (state.phase=="walk" or state.phase=="drive") then firstPerson=not firstPerson end end,true,"View",UDim2.fromScale(.84,.54))
 bind("MoveStick",{Enum.KeyCode.Thumbstick1},function(s,input) moveStick=s==Enum.UserInputState.End and V(0,0,0) or input.Position end,false)
 bind("LookStick",{Enum.KeyCode.Thumbstick2},function(s,input) lookStick=s==Enum.UserInputState.End and V(0,0,0) or input.Position end,false)
 table.insert(connections,Input.InputBegan:Connect(function(input,processed) if not processed and input.UserInputType==Enum.UserInputType.MouseButton2 then looking=true end end))
 table.insert(connections,Input.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton2 then looking=false end end))
 table.insert(connections,Input.InputChanged:Connect(function(input,processed)
  if state.phase~="walk" and state.phase~="drive" then return end
  if input.UserInputType==Enum.UserInputType.MouseWheel and state.phase=="drive" then driveZoom=math.clamp(driveZoom-input.Position.Z*2,11,32) end
  local dragging=input.UserInputType==Enum.UserInputType.MouseMovement and (looking or firstPerson)
   or (input.UserInputType==Enum.UserInputType.Touch and not processed and input.Position.X>root.AbsoluteSize.X*.4)
  if dragging then
   if state.phase=="drive" then driveOrbit-=input.Delta.X*.004; drivePitch=math.clamp(drivePitch+input.Delta.Y*.003,-.22,1.1)
   else yaw-=input.Delta.X*.004; pitch=math.clamp(pitch+input.Delta.Y*.003,-.6,.65) end
  end
 end))
 local function clear()
  if ended then return end; ended=true
  for _,c in connections do c:Disconnect() end
  for _,name in bound do Actions:UnbindAction(name) end
  Input.MouseBehavior=originalMouse; Input.MouseIconEnabled=originalIcon
  for _,p in hero.rig:GetDescendants() do if p:IsA("BasePart") then p.LocalTransparencyModifier=0 end end
  prepared.destroy(); hud:Destroy()
 end
 local function startDrive()
  car={x=290,z=140,yaw=-math.pi/2,speed=32}; mission={clearTime=0,bustTime=0,lost=false}
  for i,police in props.police do police.x=195-i*25; police.z=140 end
  state.phase="drive"; state.time=0; title.Visible=false; subtitle.Visible=false
  objective.Visible=true; objective.Text="Lose the remaining local patrol units and reach the safehouse."
  hint.Text="WASD / stick · Drive   Drag / right stick · Look   V · Cabin"
  audio.cue("engine"); audio.cue("siren")
 end
 local function finishMission(result)
  audio.stop("siren"); audio.stop("engine"); state.phase="result"
  resultPanel=ui.make("Frame",{Size=UDim2.fromScale(.64,.28),Position=UDim2.fromScale(.18,.3),BackgroundColor3=C(23,24,21),BackgroundTransparency=.08,ZIndex=35},hud)
  ui.make("TextLabel",{Size=UDim2.fromScale(1,.55),BackgroundTransparency=1,Text=result=="safe" and "SAFEHOUSE REACHED\nChapter one complete" or "INTERCEPTED\nKeep moving to break pursuit.",Font=Enum.Font.SpecialElite,TextColor3=C(241,223,179),TextSize=24,TextWrapped=true,ZIndex=36},resultPanel)
  local button=ui.make("TextButton",{Size=UDim2.fromScale(.8,.28),Position=UDim2.fromScale(.1,.62),Text=result=="safe" and "Return to menu" or "Retry escape",Font=Enum.Font.SpecialElite,TextSize=20,TextColor3=C(241,223,179),BackgroundColor3=C(63,57,42),ZIndex=36},resultPanel)
  table.insert(connections,button.Activated:Connect(function()
   if result=="safe" then ctx.onFinish() else resultPanel:Destroy(); resultPanel=nil; startDrive() end
  end))
 end
 local function shotEnter(name)
  for _,bar in bars do bar.Visible=true end
  objective.Visible=false; hint.Visible=false; subtitle.Visible=false
  talk(name)
  if name=="truck" then audio.cue("engine"); audio.cue("skid"); shake=.012
  elseif name=="unload" then audio.cue("door")
  elseif name=="approach" then doors(-1.2,0,1.6)
  elseif name=="board" then audio.cue("engine")
  elseif name=="warning" then audio.cue("door"); doors(0,0,0)
  elseif name=="police" then audio.cue("siren"); audio.cue("skid"); shake=.01
  elseif name=="burnout" then props.burnout:Emit(45); audio.cue("skid"); shake=.018
  elseif name=="bill" then audio.stop("siren")
  elseif name=="title" then title.Visible=true; audio.cue("bass"); audio.stop("engine"); shake=0 end
 end
 local function cinema(name,t,duration,dt)
  local u=math.clamp(t/duration,0,1); local ease=u*u*(3-2*u)
  if name=="truck" then
   local x=-115+110*(1-(1-u)^3); positionVehicle(props.truck,V(x,.7,-55),-math.pi/2)
   view(V(18,7,-35),V(x,3,-55),60,dt,false)
   heroPos=V(0,3,44):Lerp(V(55,3,38),u); pose(hero,heroPos,-math.pi/2,1,false)
  elseif name=="reveal" then
   view(V(29,7,-29):Lerp(V(47,6,-30),ease),V(60,3,-53),53,dt,false)
   heroPos=V(55,3,38):Lerp(V(55,3,10),u); pose(hero,heroPos,0,1,false)
  elseif name=="unload" then
   view(V(10,6,-37):Lerp(V(20,5,-42),ease),V(2+u*28,3,-57),57,dt,false)
   heroPos=V(55,3,10):Lerp(V(55,3,-32),u); pose(hero,heroPos,0,1,false)
   for i,person in props.crew do local v=math.clamp((t-(i-1)*.35)/4.5,0,1); local pos=V(-5+(i%2)*3,3,-58-i):Lerp(V(46+i*1.5,3,-59+i*.7),v); pose(person,pos,-math.pi/2,v>0 and v<1 and 1 or 0,false) end
  elseif name=="approach" then
   heroPos=V(55,3,-32):Lerp(V(63,3,-58),ease); pose(hero,heroPos,0,1,false)
   view(V(70,6,-40),heroPos+V(0,1,0),54,dt,false)
   for i,person in props.crew do pose(person,V(48+i*1.5,3,-59+i*.7),-math.pi/2,0,false) end
  elseif name=="board" then
   seatHero(); doors(-1.2*(1-u),-1.1,1.6*(1-u))
   view(V(49,6,-65),V(60,3,-53),54,dt,false)
   for i,person in props.crew do
    if u<(i*.18+.2) then pose(person,V(48+i*1.5,3,-59+i*.7):Lerp(V(55,3,-53),u),-math.pi/2,1,false) else vanish(person) end
   end
  elseif name=="warning" then
   seatHero(); for _,person in props.crew do vanish(person) end
   view(V(69,5.6,-61),V(62,4.5,-53),48,dt,false)
  elseif name=="police" then
   view(V(0,105,26),V(0,0,-5),65,dt,false)
   for i,police in props.police do
    local a=math.clamp(t/5,0,1); local pos
    if a<.5 then pos=V(-180-i*18,.7,140):Lerp(V(-80-i*10,.7,65),a*2) else pos=V(-80-i*10,.7,65):Lerp(V(-23-i*12,.7,-52),a*2-1) end
    positionVehicle(police.model,pos,a<.6 and 0 or -math.pi/2)
    if t>5 then local v=math.clamp((t-5)/2,0,1); pose(props.officers[i],V(-23-i*12,3,-47):Lerp(V(-13-i*4,3,-49),v),-math.pi/2,v<1 and 1 or 0,false); ctx.setJoint(props.officers[i],"RightShoulder",CFrame.Angles(1.4,0,0)) end
   end
  elseif name=="burnout" then
   seatHero(); view(V(54,1.3,-58),V(62,1.7,-53),66,dt,false)
  elseif name=="escape" then
   local pos,angle
   if u<.3 then pos=V(60,.7,-53):Lerp(V(68,.7,-35),u/.3); angle=-math.pi+math.pi/2*(1-u/.3)
   elseif u<.75 then pos=V(68,.7,-35):Lerp(V(68,.7,140),(u-.3)/.45); angle=math.pi
   else pos=V(68,.7,140):Lerp(V(180,.7,140),(u-.75)/.25); angle=-math.pi/2 end
   positionVehicle(ext.van,pos,angle); seatHero(); for _,person in props.crew do vanish(person) end
   view(V(84,3,120),pos+V(0,2,0),65,dt,false)
  elseif name=="bill" then
   positionVehicle(ext.van,V(180+u*110,.7,140),-math.pi/2); seatHero(); for _,person in props.crew do vanish(person) end
   local billPos=V(173,2.5,140):Lerp(V(164,5.2,135),ease)+V(0,math.sin(u*math.pi)*2,0)
   local flutter=CFrame.new(origin+billPos)*CFrame.Angles(u*math.pi*3,0,math.sin(t*4)*.6)
   local lens=CFrame.lookAt(origin+billPos,origin+V(164,5.2,134.8))*CFrame.Angles(math.pi/2,0,0)
   props.airborne.CFrame=flutter:Lerp(lens,math.clamp((u-.7)/.3,0,1))
   view(V(164,5.2,134.8),billPos,43,dt,false)
  elseif name=="title" then
   positionVehicle(ext.van,V(290,.7,140),-math.pi/2); seatHero()
   view(V(271,11,140),V(299,3,140),65,dt,false)
   title.BackgroundTransparency=t>2 and math.clamp(t-2,0,1) or 0; title.TextTransparency=t>2 and math.clamp(t-2,0,1) or 0
  end
 end
 table.insert(connections,RunService.RenderStepped:Connect(function(rawDt)
  if ended then return end
  local dt=math.min(rawDt,.05); frameDt=dt; elapsed+=dt; shake=math.max(0,shake-dt*.012)
  Rules.advance(state,dt)
  for i=2,#ctx.actors do local actor=ctx.actors[i]; if actor.face then actor.face(elapsed,false,true) end; ctx.setJoint(actor,"Neck",CFrame.Angles(0,math.sin(elapsed*.5+i)*.15,0)) end
  for _,police in props.police do police.light.Brightness=math.sin(elapsed*12)>0 and 3 or .2 end
  local phase=state.phase
  local keyName=phase=="cinematic" and Rules.shots[state.shot].name or phase
  if keyName~=lastKey then
   lastKey=keyName
   if phase=="cinematic" then shotEnter(keyName)
   elseif phase=="walk" then talk("waitress"); hint.Text="WASD / stick · Walk   Drag / right mouse · Look   V · View"; objective.Text="Step outside through the glass entrance."
   elseif phase=="drive" then startDrive(); for _,bar in bars do bar.Visible=false end; hint.Visible=true
   end
  end
  if phase=="pay" then
   objective.Text="Leave your payment on the table and step outside."
   local cf=CFrame.lookAt(origin+V(-26,5.6,-15),origin+V(-31,3.5,-7))
   camera.CFrame=initialCamera:Lerp(cf,math.clamp(state.time/1.2,0,1)); camera.FieldOfView=58
  elseif phase=="payment" then
   local u=state.time/Rules.paymentDuration
   pose(hero,heroPos,math.pi,0,true); ctx.setJoint(hero,"RightShoulder",CFrame.Angles(.4+math.sin(u*math.pi)*1.1,0,-.2))
   props.payment.Transparency=0; for _,g in props.payment:GetChildren() do if g:IsA("SurfaceGui") then g.Enabled=true end end
   props.payment.CFrame=CFrame.new(origin+V(-31.5,3.8,-10):Lerp(V(-33.9,3.055,-6.4),math.clamp(u/.8,0,1)))
   view(V(-28,6,-5),V(-32,3,-7),48,dt,false)
  elseif phase=="stand" then
   props.payment.CFrame=CFrame.new(origin+V(-33.9,3.055,-6.4)); heroPos=V(-31,2.65,-10.5):Lerp(V(-21,3,-10.5),state.time)
   pose(hero,heroPos,-math.pi/2,1,false); view(heroPos+V(0,4,-8),heroPos+V(0,1,0),62,dt,true)
  elseif phase=="walk" then
   if state.time>5 then subtitle.Visible=false end
   yaw-=lookStick.X*dt*2; pitch=math.clamp(pitch-lookStick.Y*dt,-.6,.65)
   local forward=(held.forward and 1 or 0)-(held.reverse and 1 or 0)+moveStick.Y
   local side=(held.right and 1 or 0)-(held.left and 1 or 0)+moveStick.X
   local direction=V(-math.sin(yaw)*forward+math.cos(yaw)*side,0,-math.cos(yaw)*forward-math.sin(yaw)*side)
   if direction.Magnitude>1 then direction=direction.Unit end
   local nextPos=heroPos+direction*dt*13
   if Rules.walkable(nextPos.X,heroPos.Z) then heroPos=V(nextPos.X,3,heroPos.Z) end
   if Rules.walkable(heroPos.X,nextPos.Z) then heroPos=V(heroPos.X,3,nextPos.Z) end
   local angle=direction.Magnitude>.1 and math.atan2(-direction.X,-direction.Z) or yaw
   pose(hero,heroPos,angle,direction.Magnitude,false)
   if heroPos.Z>29 then ext.door:PivotTo(doorBase*CFrame.Angles(0,-math.pi/2,0)) end
   for _,p in hero.rig:GetDescendants() do if p:IsA("BasePart") then p.LocalTransparencyModifier=firstPerson and 1 or 0 end end
   Input.MouseBehavior=firstPerson and Enum.MouseBehavior.LockCenter or (looking and Enum.MouseBehavior.LockCurrentPosition or originalMouse); Input.MouseIconEnabled=not firstPerson
   local target=heroPos+V(0,1.5,0)
   if firstPerson then view(target,target+V(-math.sin(yaw),-pitch,-math.cos(yaw)),70,dt,false)
   else local cam=target+V(math.sin(yaw)*8,2+pitch*5,math.cos(yaw)*8); cam=V(math.clamp(cam.X,-35,34),cam.Y,math.clamp(cam.Z,-33,47)); view(cam,target,64,dt,true) end
   if heroPos.Z>=44 and Rules.exit(state) then
    audio.cue("bell"); subtitle.Visible=false; Input.MouseBehavior=originalMouse; Input.MouseIconEnabled=originalIcon
    for _,p in hero.rig:GetDescendants() do if p:IsA("BasePart") then p.LocalTransparencyModifier=0 end end
   end
  elseif phase=="cinematic" then
   Lighting.ClockTime=12+5.5*math.clamp((state.shot-1+state.time/2)/3,0,1)
   local shot=Rules.shots[state.shot]; cinema(shot.name,state.time,shot.duration,dt)
  elseif phase=="drive" then
   local throttle=math.clamp((held.forward and 1 or 0)-(held.reverse and 1 or 0)+moveStick.Y,-1,1)
   local steer=math.clamp((held.right and 1 or 0)-(held.left and 1 or 0)+moveStick.X,-1,1)
   if Rules.drive(car,throttle,steer,held.brake,dt) then shake=.015 end
   positionVehicle(ext.van,V(car.x,.7,car.z),car.yaw); seatHero(); for _,person in props.crew do vanish(person) end
   local nearest=math.huge
   for _,police in props.police do
    if not mission.lost then
     local dx=car.x-police.x; local dz=car.z-police.z; local distance=math.sqrt(dx*dx+dz*dz)
     local step=math.min(distance,dt*53)
     if distance>.01 then police.x+=dx/distance*step; police.z=math.clamp(police.z+dz/distance*step,130,150) end
     positionVehicle(police.model,V(police.x,.7,police.z),math.atan2(-dx,-dz)); nearest=math.min(nearest,distance)
    end
   end
   local result=Rules.mission(mission,car,nearest,dt)
   if mission.lost then audio.stop("siren"); objective.Text="Patrol lost. Reach OLD MOTOR DEPOT and stop in the driveway." end
   local distance=math.floor(math.sqrt((car.x-Rules.destination.x)^2+(car.z-Rules.destination.z)^2))
   hint.Text=string.format("%d mph  •  SAFEHOUSE %d studs %s  •  V: view · Drag: look",math.floor(math.abs(car.speed)*.65),distance,car.x<900 and "→ WEST" or "↑ DRIVEWAY")
   audio.engine(car.speed)
   driveOrbit-=lookStick.X*dt*2; drivePitch=math.clamp(drivePitch-lookStick.Y*dt,-.22,1.1)
   Input.MouseBehavior=looking and Enum.MouseBehavior.LockCurrentPosition or originalMouse
   local target=V(car.x,3.8,car.z); local angle=car.yaw+driveOrbit
   if firstPerson then
    local eye=(ext.van:GetPivot()*CFrame.new(-1.35,4.65,-4.1)).Position-origin
    view(eye,eye+V(-math.sin(angle)*10,-drivePitch*5,-math.cos(angle)*10),74,dt,false)
   else
    local radius=driveZoom*math.cos(drivePitch)
    view(target+V(math.sin(angle)*radius,math.max(1.2,math.sin(drivePitch)*driveZoom),math.cos(angle)*radius),target,ctx.reducedMotion() and 65 or 65+math.abs(car.speed)*.08,dt,true)
   end
   if result then finishMission(result) end
  end
 end))
 return clear
end
return Escape
