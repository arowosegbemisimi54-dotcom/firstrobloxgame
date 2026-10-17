-- Pure chapter timing and driving rules: shared by runtime and headless checks.
local Rules={paymentDuration=1,boardingDuration=1.5}
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
 return (x>=-230 and x<=1200 and z>=130 and z<=150)
  or (x>=50 and x<=77 and z>=-60 and z<=150)
  or (x>=-107 and x<=80 and z>=42 and z<=123)
  or (x>=900 and x<=940 and z>=130 and z<=179)
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
function Rules.mission(mission,car,nearest,dt)
 if mission.result then return mission.result end
 if nearest>150 then mission.clearTime+=dt else mission.clearTime=0 end
 if mission.clearTime>=4 then mission.lost=true end
 if not mission.lost and nearest<17 and math.abs(car.speed)<8 then mission.bustTime+=dt else mission.bustTime=0 end
 if mission.bustTime>=4 then mission.result="caught" end
 local distance=math.sqrt((car.x-920)^2+(car.z-175)^2)
 if mission.lost and distance<13 and math.abs(car.speed)<6 then mission.result="safe" end
 return mission.result
end
return Rules
