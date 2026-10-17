-- Pure chapter timing and driving rules: shared by runtime and headless checks.
local Rules={paymentDuration=1,boardingDuration=1.5,destination={x=920,z=163}}
Rules.shots={
 {name="truck",duration=2}, {name="reveal",duration=1.5},
 {name="unload",duration=6}, {name="approach",duration=4},
 {name="board",duration=1.5}, {name="warning",duration=3.5},
 {name="police",duration=11}, {name="burnout",duration=2},
 {name="escape",duration=4}, {name="bill",duration=4}, {name="title",duration=3},
}
Rules.lines={
 waitress="Did he say... Highway 4? Hey, hon, maybe we should lock the front—",
 unload="Move, move, MOVE! Ditch the truck! The cops have a visual on this rig!",
 board="Bag's secured! Get in, let's go!",
 warning="Sirens are getting closer—100 yards! Hit the gas! NOW!",
 police="Dispatch, we have located the primary suspect vehicle behind the diner on Highway 4! Vehicle is abandoned... repeat, SUSPECTS ARE FOOT-BAIL, WE HAVE LOST VISUAL!",
}
function Rules.new() return {phase="pay",time=0,shot=1,paid=false} end
function Rules.interact(state)
 if state.phase~="pay" then return false end
 state.phase="payment"; state.time=0; return true
end
function Rules.exit(state)
 if state.phase~="walk" or not state.paid then return false end
 state.phase="cinematic"; state.time=0; state.shot=1; return true
end
function Rules.advance(state,dt)
 dt=math.max(0,dt); state.time+=dt
 if state.phase=="payment" and state.time>=Rules.paymentDuration then
  state.paid=true; state.phase="stand"; state.time=0
 elseif state.phase=="stand" and state.time>=1 then state.phase="walk"; state.time=0
 elseif state.phase=="cinematic" then
  while state.phase=="cinematic" and state.time>=Rules.shots[state.shot].duration do
   state.time-=Rules.shots[state.shot].duration; state.shot+=1
   if state.shot>#Rules.shots then state.phase="drive"; state.time=0 end
  end
 end
end
function Rules.walkable(x,z)
 return (x>=-22 and x<=8 and z>=-31 and z<=32) or (math.abs(x)<=2.2 and z>=31 and z<=48)
end
function Rules.drivable(x,z)
 -- Expanded parked-car footprints include clearance for the panel van.
 for _,parked in {{-68,62},{-36,109},{12,109},{60,62}} do
  if math.abs(x-parked[1])<5.6 and math.abs(z-parked[2])<11.5 then return false end
 end
 return (x>=-230 and x<=1200 and z>=130 and z<=150)
  or (x>=54 and x<=77 and z>=-60 and z<=150)
  or (x>=-107 and x<=80 and z>=44 and z<=123)
  or (x>=900 and x<=940 and z>=130 and z<=165)
end
function Rules.drive(car,throttle,steer,brake,dt)
 dt=math.clamp(dt,0,.05)
 local acceleration=throttle*32-car.speed*(brake and 5 or (throttle==0 and 1.2 or .12))
 car.speed=math.clamp(car.speed+acceleration*dt,-22,78)
 car.yaw-=steer*math.clamp(car.speed/22,-1,1)*1.1*dt
 local x=car.x-math.sin(car.yaw)*car.speed*dt
 local z=car.z-math.cos(car.yaw)*car.speed*dt
 local collision=not Rules.drivable(x,z)
 if collision then car.speed=-car.speed*.2 else car.x=x; car.z=z end
 return collision
end
-- Two quarter-circle turns connect the highway, west service lane and rear yard.
-- Distance, heading and steering come from the same path, including braking.
function Rules.policeArrival(index,time)
 local lane=-105-(index-1)*12
 local start=-180-index*18
 local finish=-23-index*12
 local radius=18
 local first=lane-radius-start
 local vertical=156
 local last=finish-(lane+radius)
 local arc=radius*math.pi/2
 local length=first+arc+vertical+arc+last
 local duration=6.2+(index-1)*.35
 local braking=1.4
 local cruise=length/(duration-braking/2)
 local t=math.clamp(time,0,duration)
 local brakingTime=math.max(0,t-(duration-braking))
 local distance=cruise*(t-brakingTime*brakingTime/(2*braking))
 local speed=cruise*(1-brakingTime/braking)
 local x,z,dx,dz,steer
 steer=0
 if distance<first then x=start+distance; z=140; dx=1; dz=0
 elseif distance<first+arc then
  local a=(distance-first)/radius
  x=lane-radius+radius*math.sin(a); z=122+radius*math.cos(a)
  dx=math.cos(a); dz=-math.sin(a); steer=-.38
 elseif distance<first+arc+vertical then
  x=lane; z=122-(distance-first-arc); dx=0; dz=-1
 elseif distance<first+arc+vertical+arc then
  local a=(distance-first-arc-vertical)/radius
  x=lane+radius-radius*math.cos(a); z=-34-radius*math.sin(a)
  dx=math.sin(a); dz=-math.cos(a); steer=.38
 else
  x=lane+radius+distance-first-arc-vertical-arc; z=-52; dx=1; dz=0
 end
 return {x=x,z=z,yaw=math.atan2(-dx,-dz),speed=speed,steer=steer,stopped=time>=duration,duration=duration}
end
-- Pursuit advances along the cruiser's heading with bounded steering, rather
-- than translating diagonally toward the player's position.
function Rules.pursue(police,target,dt)
 dt=math.clamp(dt,0,.05)
 local dx,dz=target.x-police.x,math.clamp(target.z,133,147)-police.z
 local distance=math.sqrt(dx*dx+dz*dz)
 local desired=math.atan2(-dx,-dz)
 local error=(desired-police.yaw+math.pi)%(2*math.pi)-math.pi
 local desiredSpeed=distance<10 and 0 or 53*math.max(.28,1-math.abs(error)/math.pi)
 police.speed+=(desiredSpeed-police.speed)*math.min(1,dt*1.8)
 local turn=math.clamp(error,-.8*dt,.8*dt)*math.min(1,police.speed/12)
 police.yaw+=turn
 police.steer=-turn/math.max(dt,.001)*.4
 local x=police.x-math.sin(police.yaw)*police.speed*dt
 local z=police.z-math.cos(police.yaw)*police.speed*dt
 if z>=130 and z<=150 then police.x=x; police.z=z else police.speed=math.max(0,police.speed-60*dt) end
 return distance
end

function Rules.mission(mission,car,nearest,dt)
 if mission.result then return mission.result end
 if nearest>150 then mission.clearTime+=dt else mission.clearTime=0 end
 if mission.clearTime>=4 then mission.lost=true end
 if not mission.lost and nearest<17 and math.abs(car.speed)<8 then mission.bustTime+=dt else mission.bustTime=0 end
 if mission.bustTime>=4 then mission.result="caught" end
 local distance=math.sqrt((car.x-Rules.destination.x)^2+(car.z-Rules.destination.z)^2)
 if mission.lost and distance<13 and math.abs(car.speed)<6 then mission.result="safe" end
 return mission.result
end
return Rules
