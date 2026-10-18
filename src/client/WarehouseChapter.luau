local Rules=require(game:GetService("ReplicatedStorage"):WaitForChild("GameShared").WarehouseRules)
local Drive=require(game:GetService("ReplicatedStorage"):WaitForChild("GameShared").EscapeRules)
local Motion=require(script.Parent.CharacterMotion)
local Chapter={}
function Chapter.create(ctx)
 local V,C=Vector3.new,Color3.fromRGB
 local origin,car,hero,ext,props=ctx.origin,ctx.car,ctx.hero,ctx.ext,ctx.props
 local set=ext.landscape.depot
 local state=Rules.new()
 local player=V(car.x,3,car.z)
 local elapsed=0
 local lastPhase=""
 local completed=false
 local originalStyle=hero.style
 local stepTravel=0
 local lastPlayer
 local markerTime=0
 local actionFrom
 local captionUntil=0
 local status=ctx.ui.make("TextLabel",{Name="Depot mission progress",Position=UDim2.new(.035,0,.14,72),Size=UDim2.new(.48,0,0,42),BackgroundTransparency=1,TextColor3=C(229,192,115),TextSize=16,Font=Enum.Font.SpecialElite,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},ctx.hud)
 local chapter=ctx.ui.make("TextLabel",{Name="Depot chapter slate",Position=UDim2.fromScale(.29,.12),Size=UDim2.fromScale(.42,.12),BackgroundTransparency=1,Text="HIGHWAY FOUR\nNO LOOSE ENDS",TextColor3=C(239,221,175),TextSize=27,Font=Enum.Font.SpecialElite,TextWrapped=true},ctx.hud)
 local bag=ext.part("Player carried cash bag",V(1.15,.95,1.9),V(0,-20,0),C(75,69,48),Enum.Material.Fabric,Enum.PartType.Ball,set.model); bag.Transparency=1
 local handle=ext.part("Player duffel handle",V(.6,.15,.18),V(0,-20,0),C(45,33,23),Enum.Material.Fabric,nil,set.model); handle.Transparency=1
 local function driverSide()
  return (ext.van:GetPivot()*CFrame.new(-4.6,3.1,-3.4)).Position-origin
 end
 local function clearTransparency()
  Motion.visibility(hero,false)
 end
 local function say(name)
  ctx.audio.say(name); ctx.subtitle.Text=Drive.lines[name]; captionUntil=elapsed+5.5
 end
 local function enterPhase()
  local phase=state.phase
  if phase==lastPhase then return end
  lastPhase=phase; actionFrom=player
  local film=phase=="establish" or phase=="watch"
  for _,bar in ctx.bars do bar.Visible=film end
  chapter.Visible=phase=="establish"
  ctx.objective.Visible=not film; ctx.hint.Visible=not film; status.Visible=not film
  ctx.subtitle.Visible=false
  clearTransparency()
  if phase=="establish" then ctx.audio.stop("engine"); ctx.audio.stop("siren"); ctx.doors(-1.1,0,0); player=driverSide()
  elseif phase=="gate" then say("depot")
  elseif phase=="opening" or phase=="closing" then ctx.audio.cue("door")
  elseif phase=="boarding" then ctx.doors(-1.1,0,0); ctx.audio.cue("door")
  elseif phase=="park" then ctx.doors(0,0,0); ctx.audio.cue("engine")
  elseif phase=="exiting" then
   ctx.doors(-1.1,0,1.6); ctx.audio.stop("engine"); say("unpack")
   for _,light in ext.vehicle.lights do light.beam.Enabled=false; light.lens.Material=Enum.Material.Glass end
  elseif phase=="unload" then ctx.doors(0,0,1.6)
  elseif phase=="shutter" then ctx.doors(0,0,0); say("shutters")
  elseif phase=="blackout" then ctx.audio.cue("door")
  elseif phase=="watch" then ctx.audio.cue("door"); ctx.audio.cue("siren"); ctx.subtitle.Text="Keep still. Let them pass."; captionUntil=elapsed+3
  end
 end
 local objectives={gate="Open the warehouse loading bay.",opening="Release the latch and slide the doors clear.",
  ["return"]="Get back into the van. Keep the loading lane clear.",boarding="Climb into the driver's seat.",
  park="Hide the van inside the painted bay. Face the rear wall and brake.",exiting="Unload the cash before the search patrol returns.",
  unload="Carry two bags to the pallet. Your crew will secure the other two.",lifting="Lift the duffel by its handle.",placing="Set the bag on the stash pallet.",
  shutter="All four bags secured. Close the loading-bay doors.",closing="Slide the doors shut.",blackout="Switch off the workshop lights before the patrol passes."}
 local function onFoot() return state.phase=="gate" or state.phase=="return" or state.phase=="unload" or state.phase=="shutter" or state.phase=="blackout" end
 local function updateCrew(dt)
  local unloading=state.search~=nil
  for i,person in props.crew do
   local pos,angle
   local carrying=false
   if not unloading then ctx.seatedCrew(person)
   else
    if i==2 or i==3 then
     local t=Rules.searchDuration-state.search-(i-2)*6
     local u=math.clamp(t/5.7,0,1)
     local lane=i==2 and 910 or 930
     local start=V(920+(i==2 and -2 or 2),3.85,193)
     local corner=V(lane,3.85,194)
     local endLane=V(lane,3.85,206)
     local finish=V(931+(i-2)*1.5,3.85,207)
     if u<.25 then pos=start:Lerp(corner,u/.25)
     elseif u<.65 then pos=corner:Lerp(endLane,(u-.25)/.4)
     else pos=endLane:Lerp(finish,(u-.65)/.35) end
     carrying=t>=0 and t<6
     angle=math.pi
     if u>=1 then pos=finish; angle=math.pi/2 end
    else
     local t=Rules.searchDuration-state.search
     local lane=i==1 and 908 or 932
     local start=V(i==1 and 918 or 922,3.85,193)
     local corner=V(lane,3.85,193)
     -- Guards exit through the rear and walk around, rather than through the van.
     pos=t<1.7 and start:Lerp(corner,math.clamp(t/1.7,0,1)) or corner:Lerp(V(lane,3.85,188),math.clamp((t-1.7)/1.2,0,1)); angle=0
    end
    ctx.pose(person,pos,angle,1,false)
    if not carrying then Motion.joint(person,"LeftShoulder",CFrame.Angles(.12,0,-.06)); Motion.joint(person,"LeftElbow",CFrame.Angles(.2,0,0)) end
    if person.bag then person.bag.Transparency=carrying and 0 or 1 end
    for _,p in person.baggage do p.Transparency=carrying and 0 or 1 end
   end
  end
 end
 local function updateCargo()
  for i,part in props.cargoBags do
   local hidden
   if i==1 then hidden=state.delivered>=1 or state.carrying or state.phase=="lifting"
   elseif i==4 then hidden=state.delivered>=2 or (state.delivered==1 and (state.carrying or state.phase=="lifting"))
   else hidden=state.search~=nil and Rules.searchDuration-state.search>=(i-2)*6 end
   part.Transparency=hidden and 1 or 0
  end
  set.bags(state.delivered+state.crewDelivered)
  local visible=state.carrying or state.phase=="lifting" or state.phase=="placing"
  bag.Transparency=visible and 0 or 1; handle.Transparency=bag.Transparency
  if visible then
   Motion.flush(hero)
   local hand=hero.rig:FindFirstChild("LeftHand")
   if hand then bag.CFrame=hand.CFrame*CFrame.new(0,-.7,0); handle.CFrame=hand.CFrame*CFrame.new(0,-.2,0) end
  end
 end
 local function updateView(dt,input)
  local phase=state.phase
  if phase=="establish" then
   local u=math.clamp(state.time/3.2,0,1); u=u*u*(3-2*u)
   ctx.view(V(887,13,151):Lerp(V(898,8,168),u),V(920,5,190),57,dt,false)
   chapter.TextTransparency=math.clamp((state.time-2.4)/.8,0,1)
  elseif phase=="watch" then
   if state.time<3 then ctx.view(V(940,4.8,165),V(920,2.8,140),53,dt,false)
   elseif state.time<6 then ctx.view(V(904,6,208),V(925,3.5,196),52,dt,false)
   else ctx.view(V(931,3.9,204),V(934,1.8,212),47,dt,false) end
  elseif phase=="park" then
   local angle=car.yaw+input.driveOrbit
   if input.firstPerson then
    local eye=(ext.van:GetPivot()*CFrame.new(-1.35,4.65,-4.1)).Position-origin
    ctx.view(eye,eye+V(-math.sin(angle)*10,-input.drivePitch*5,-math.cos(angle)*10),71,dt,false)
   else
    local radius=math.min(input.driveZoom,14)*math.cos(input.drivePitch)
    ctx.view(V(car.x+math.sin(angle)*radius,math.min(8.8,4+math.sin(input.drivePitch)*11),car.z+math.cos(angle)*radius),V(car.x,4,car.z),62,dt,true)
   end
  else
   local target=player+V(0,1.45,0)
   if input.firstPerson then
    local head=hero.rig:FindFirstChild("Head")
    if head then target=head.CFrame.Position-origin+V(0,.1,0) end
    ctx.view(target,target+V(-math.sin(input.yaw),-input.pitch,-math.cos(input.yaw)),69,dt,false)
   else
    local cam=target+V(math.sin(input.yaw)*7.5,1.5+input.pitch*3,math.cos(input.yaw)*7.5)
    if player.Z>184 then cam=V(math.clamp(cam.X,900,940),math.clamp(cam.Y,2,8.8),math.clamp(cam.Z,185,218)) end
    ctx.view(cam,target,63,dt,true)
   end
  end
 end
 local api={}
 local function blockedByVan(x,z)
  local dx,dz=x-car.x,z-car.z
  return math.abs(dx*math.cos(car.yaw)-dz*math.sin(car.yaw))<4 and math.abs(dx*math.sin(car.yaw)+dz*math.cos(car.yaw))<7
 end
 function api.driving() return state.phase=="park" end
 function api.interact()
  return Rules.interact(state,{x=player.X,z=player.Z},car)
 end
 function api.update(dt,input)
  if completed then return end
  elapsed+=dt; markerTime+=dt
  Rules.advance(state,dt); enterPhase()
  ctx.subtitle.Visible=elapsed<captionUntil
  ctx.objective.Text=objectives[state.phase] or ""
  if state.search then status.Text=string.format("CASH %d / 4    •    SEARCH PATROL: %02ds",state.delivered+state.crewDelivered,math.ceil(state.search))
  else status.Text=state.phase=="park" and "NO LOOSE ENDS  /  02 · HIDE THE VAN" or "NO LOOSE ENDS  /  01 · OPEN THE LOADING BAY" end
  status.TextColor3=state.search and state.search<15 and C(243,133,102) or C(229,192,115)
  if state.phase=="opening" then set.gate(math.clamp(state.time/1.3,0,1))
  elseif state.phase=="closing" then set.gate(1-math.clamp(state.time/1.5,0,1))
  else set.gate(state.open and 1 or 0) end
  set.lights(state.lights)
  if onFoot() then
   local forward,side=input.forward,input.side
   local direction=V(-math.sin(input.yaw)*forward+math.cos(input.yaw)*side,0,-math.cos(input.yaw)*forward-math.sin(input.yaw)*side)
   if direction.Magnitude>1 then direction=direction.Unit end
   local speed=state.carrying and 9 or (input.sprint and 19 or 11)
   local nextPos=player+direction*dt*speed
   if Rules.walkable(nextPos.X,player.Z,state.open) and not blockedByVan(nextPos.X,player.Z) then player=V(nextPos.X,player.Y,player.Z) end
   if Rules.walkable(player.X,nextPos.Z,state.open) and not blockedByVan(player.X,nextPos.Z) then player=V(player.X,player.Y,nextPos.Z) end
   player=V(player.X,3+math.clamp((player.Z-179)/5,0,1)*.85,player.Z)
   hero.style=state.carrying and "crew" or originalStyle
   local angle=direction.Magnitude>.1 and math.atan2(-direction.X,-direction.Z) or input.yaw
   ctx.pose(hero,player,angle,1,false)
   if lastPlayer then stepTravel+=(player-lastPlayer).Magnitude end; lastPlayer=player
   if stepTravel>3.4 then stepTravel=stepTravel%3.4; ctx.audio.cue("step") end
  elseif state.phase=="park" then
   car.speed=math.clamp(car.speed,-12,22)
   Drive.drive(car,input.forward,input.side,input.brake,dt,function(x,z) return Rules.drivable(car,x,z) end)
   car.speed=math.clamp(car.speed,-12,22)
   ctx.positionVehicle(ext.van,V(car.x,.7+math.clamp((car.z-179)/5,0,1)*.85,car.z),car.yaw)
   ctx.vehicleCabin(dt,input)
   ctx.seatHero(); ctx.audio.engine(car.speed)
  elseif state.phase=="boarding" then
   local seat=ext.van:GetPivot()*CFrame.new(-1.4,3.1,-3.45)
   hero.rig:PivotTo(CFrame.new(origin+actionFrom):Lerp(seat,math.clamp(state.time,0,1)))
   Motion.board(hero,state.time,true)
  elseif state.phase=="exiting" then
   local seat=ext.van:GetPivot()*CFrame.new(-1.4,3.1,-3.45)
   local u=math.clamp(state.time,0,1)
   player=(seat.Position-origin):Lerp(driverSide(),u)
   hero.rig:PivotTo(seat:Lerp(CFrame.new(origin+player)*CFrame.Angles(0,car.yaw,0),u))
   Motion.board(hero,1-u,false)
  else
   ctx.pose(hero,player,input.yaw,0,false)
   if state.phase=="lifting" or state.phase=="placing" then
    local bend=math.sin(math.clamp(state.time/.8,0,1)*math.pi)
    Motion.joint(hero,"Waist",CFrame.Angles(-bend*.5,0,0))
    Motion.joint(hero,"LeftShoulder",CFrame.Angles(.65*bend,0,-.1))
    for _,side in {"Left","Right"} do Motion.joint(hero,side.."Knee",CFrame.Angles(-.35*bend,0,0)) end
   elseif state.phase=="opening" or state.phase=="closing" then
    Motion.joint(hero,"RightShoulder",CFrame.Angles(1+math.sin(state.time*4)*.3,0,0)); Motion.joint(hero,"RightElbow",CFrame.Angles(.7,0,0)); Motion.joint(hero,"Waist",CFrame.Angles(-.15,0,0))
   end
  end
  updateCrew(dt); updateCargo()
  local target,prompt=Rules.target(state,car)
  set.markerGui.Enabled=target~=nil; set.marker.Transparency=target and .2 or 1
  if target then
   set.marker.CFrame=CFrame.new(origin+V(target.x,5.6+(ctx.reducedMotion() and 0 or math.sin(markerTime*2)*.12),target.z))
   set.markerLabel.Text=prompt
   local distance=math.sqrt((target.x-player.X)^2+(target.z-player.Z)^2)
   if state.phase=="park" then
    ctx.hint.Text=Rules.parked(car) and "E / X · Switch off engine and get out" or "WASD / stick · Align van in bay   Space / L2 · Brake"
   else ctx.hint.Text=distance<=3.4 and "E / X · "..prompt or string.format("%d studs · %s   |   Shift / L3 · Run",math.floor(distance),prompt) end
  else ctx.hint.Text=state.phase=="unload" and "Your crew is securing the remaining bags…" or "" end
  Motion.visibility(hero,input.firstPerson and state.phase~="establish" and state.phase~="watch")
  if state.phase=="watch" then
   -- Search cars cross the highway along their heading; no diagonal translation.
   for i,police in props.police do
    local x=825+state.time*30-(i-1)*32
    ctx.positionVehicle(police.model,V(x,.7,140),-math.pi/2); ctx.animateCruiser(police,0)
    local seat=(police.model:GetPivot()*police.driverSeat).Position-origin
    ctx.pose(props.officers[i],seat,-math.pi/2,0,true)
   end
  end
  Motion.flush(hero); updateView(dt,input)
  if state.phase=="complete" or state.phase=="failed" then
   completed=true; clearTransparency(); set.markerGui.Enabled=false; chapter.Visible=false; status.Visible=false
   ctx.audio.stop("siren"); ctx.subtitle.Visible=false; for _,bar in ctx.bars do bar.Visible=false end
   if state.phase=="complete" then ctx.complete() else ctx.failed(api.retry) end
  end
 end
 function api.retry()
  state=Rules.new(true); lastPhase=""; completed=false
  car.x=920; car.z=202; car.yaw=math.pi; car.speed=0; car.steer=0
  ctx.positionVehicle(ext.van,V(920,1.55,202),math.pi); player=driverSide(); lastPlayer=nil
  ctx.doors(0,0,1.6); ctx.objective.Visible=true; ctx.hint.Visible=true; status.Visible=true
 end
 function api.destroy()
  hero.style=originalStyle; clearTransparency(); set.markerGui.Enabled=false
  bag:Destroy(); handle:Destroy(); status:Destroy(); chapter:Destroy()
 end
 return api
end
return Chapter
