-- Local chapter objective state, independent of rendering and frame rate.
local Rules={searchDuration=70,gate={x=910,z=179},stash={x=934,z=208},switch={x=930,z=186},parking={x=920,z=202}}
local function near(a,b,r) return (a.x-b.x)^2+(a.z-b.z)^2<=r*r end
function Rules.new(checkpoint)
 return {phase=checkpoint and "unload" or "establish",time=0,open=checkpoint or false,delivered=0,carrying=false,
  crewDelivered=0,search=checkpoint and Rules.searchDuration or nil,lights=true}
end
function Rules.parked(car)
 local heading=(car.yaw-math.pi+math.pi)%(2*math.pi)-math.pi
 return near(car,Rules.parking,3) and math.abs(car.speed)<1 and math.abs(heading)<.28
end
function Rules.target(s,car)
 if s.phase=="gate" then return Rules.gate,"Release the loading-bay latch"
 elseif s.phase=="return" then
  return {x=car.x-4.6*math.cos(car.yaw)-3.4*math.sin(car.yaw),z=car.z+4.6*math.sin(car.yaw)-3.4*math.cos(car.yaw)},"Get into the van"
 elseif s.phase=="park" then return Rules.parking,"Park inside, facing the rear wall"
 elseif s.phase=="unload" then
  if s.carrying then return Rules.stash,"Place the bag on the marked pallet" end
  if s.delivered<2 then return {x=car.x+math.sin(car.yaw)*8,z=car.z+math.cos(car.yaw)*8},"Take a cash bag" end
 elseif s.phase=="shutter" then return {x=910,z=186},"Close the loading-bay doors"
 elseif s.phase=="blackout" then return Rules.switch,"Switch off the workshop lights" end
 return nil,""
end
function Rules.interact(s,player,car)
 local target=Rules.target(s,car)
 if not target then return false end
 if s.phase=="park" then
  if not Rules.parked(car) then return false end
  s.phase="exiting"; s.time=0; return true
 end
 if not near(player,target,3.4) then return false end
 if s.phase=="gate" then s.phase="opening"
 elseif s.phase=="return" then s.phase="boarding"
 elseif s.phase=="unload" then s.phase=s.carrying and "placing" or "lifting"
 elseif s.phase=="shutter" then s.phase="closing"
 elseif s.phase=="blackout" then s.lights=false; s.phase="watch"
 else return false end
 s.time=0; return true
end
function Rules.advance(s,dt)
 if s.phase=="complete" or s.phase=="failed" then return end
 dt=math.max(0,dt); s.time+=dt
 local phase=s.phase
 local duration,nextPhase
 if phase=="establish" then duration=3.2; nextPhase="gate"
 elseif phase=="opening" then duration=1.3; nextPhase="return"
 elseif phase=="boarding" then duration=1; nextPhase="park"
 elseif phase=="exiting" then duration=1; nextPhase="unload"
 elseif phase=="lifting" or phase=="placing" then duration=.8; nextPhase="unload"
 elseif phase=="closing" then duration=1.5; nextPhase="blackout"
 elseif phase=="watch" then duration=8; nextPhase="complete" end
 if duration and s.time>=duration then
  s.phase=nextPhase; s.time=0
  if phase=="opening" then s.open=true
  elseif phase=="exiting" then s.search=Rules.searchDuration
  elseif phase=="lifting" then s.carrying=true
  elseif phase=="placing" then s.carrying=false; s.delivered+=1
  elseif phase=="closing" then s.open=false end
 end
 if s.search and s.phase~="watch" and s.phase~="complete" then
  s.search=math.max(0,s.search-dt)
  s.crewDelivered=math.min(2,math.floor((Rules.searchDuration-s.search)/6))
  if s.phase=="unload" and s.delivered==2 and s.crewDelivered==2 then s.phase="shutter"; s.time=0 end
  if s.search==0 and (s.open or s.lights) then s.phase="failed"; s.time=0 end
 end
end
function Rules.walkable(x,z,open)
 -- Character-sized clearances; scenery, workbench and cash pallet are solid.
 local yard=x>=895 and x<=945 and z>=151 and z<=181
 local interior=x>=900 and x<=940 and z>=185 and z<=218
 local doorway=open and x>=914 and x<=926 and z>=179 and z<=187
 if not (yard or interior or doorway) then return false end
 if x<910 and z>188 and z<198 then return false end -- supply crates
 if x>937 and z>195 then return false end -- tools/workbench
 if x>932 and z>209 then return false end -- deposited cash
 return true
end
function Rules.drivable(car,x,z)
 -- Test the full van footprint, not only its center, against the bay aperture.
 for _,side in {-3.25,3.25} do for _,endPoint in {-6.5,6.5} do
  local px=x+side*math.cos(car.yaw)+endPoint*math.sin(car.yaw)
  local pz=z-side*math.sin(car.yaw)+endPoint*math.cos(car.yaw)
  if not ((px>=895 and px<=945 and pz>=150 and pz<=182) or (px>=913 and px<=927 and pz>=178 and pz<=218)) then return false end
 end end
 return true
end
return Rules
