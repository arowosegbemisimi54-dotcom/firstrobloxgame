local Rules=(function()
-- INSERT_ESCAPE_RULES
end)()
local count=0
local function check(value,message) assert(value,message); count+=1; print("PASS: "..message) end
local s=Rules.new()
check(not Rules.exit(s),"unpaid player cannot trigger escape")
check(Rules.interact(s) and not Rules.interact(s),"payment interaction cannot be duplicated")
Rules.advance(s,.99); check(not s.paid,"payment requires its full one-second animation")
Rules.advance(s,.01); check(s.paid and s.phase=="stand","payment completes at one second")
check(not Rules.exit(s),"exit stays gated until standing is complete")
Rules.advance(s,1); check(s.phase=="walk" and Rules.exit(s),"walking player can trigger exterior once")
check(not Rules.exit(s),"cinematic cannot retrigger itself")
local board
for _,shot in Rules.shots do if shot.name=="board" then board=shot.duration end end
check(board==1.5,"crew boarding lasts exactly 1.5 seconds")
Rules.advance(s,100); check(s.phase=="drive","entire cinematic hands off into driving")
check(Rules.walkable(0,40) and not Rules.walkable(5,40) and not Rules.walkable(-30,0),"walking respects doorway and booth boundaries")
check(Rules.drivable(920,163) and not Rules.drivable(850,175),"safehouse driveway is reachable without driving through neighboring buildings")
check(not Rules.drivable(60,62) and Rules.drivable(68,62),"parked vehicles block driving while keeping the alley lane open")
local car={x=180,z=140,yaw=-math.pi/2,speed=0}
for _=1,120 do Rules.drive(car,1,0,false,1/60) end
check(car.x>220 and car.speed>50,"throttle advances vehicle along its heading")
for _=1,120 do Rules.drive(car,0,0,true,1/60) end
check(math.abs(car.speed)<.01,"brake brings vehicle to rest")
local edge={x=1199.9,z=140,yaw=-math.pi/2,speed=70}
check(Rules.drive(edge,1,0,false,.05) and edge.x==1199.9,"road boundary blocks vehicle instead of clipping through scenery")
local mission={clearTime=0,bustTime=0,lost=false}
local depot={x=920,z=163,speed=0}
check(not Rules.mission(mission,depot,80,1),"safehouse cannot complete while still pursued")
Rules.mission(mission,depot,180,3.9); check(not mission.lost,"escape requires sustained distance from patrol")
check(Rules.mission(mission,depot,180,.1)=="safe","lost patrol plus stopped vehicle at depot completes mission")
local caught={clearTime=0,bustTime=0,lost=false}
check(Rules.mission(caught,{x=300,z=140,speed=0},10,4)=="caught","stationary player near patrol can be intercepted")
for i=1,2 do
 local last=Rules.policeArrival(i,0)
 local aligned=true
 local bounded=true
 for step=1,650 do
  local current=Rules.policeArrival(i,step*.01)
  local dx,dz=current.x-last.x,current.z-last.z
  local distance=math.sqrt(dx*dx+dz*dz)
  if distance>.001 then
   local dot=(dx*(-math.sin(current.yaw))+dz*(-math.cos(current.yaw)))/distance
   if dot<.995 then aligned=false end
  end
  local turn=(current.yaw-last.yaw+math.pi)%(2*math.pi)-math.pi
  if math.abs(turn)>.06 then bounded=false end
  last=current
 end
 check(aligned and bounded,"patrol "..i.." follows continuous curved turns facing its travel direction")
 local parked=Rules.policeArrival(i,20)
 local stopped=Rules.policeArrival(i,parked.duration)
 check(parked.stopped and parked.speed<.00001 and math.abs(parked.x-stopped.x)<.00001 and math.abs(parked.x-(-23-i*12))<.001 and math.abs(parked.z+52)<.001,"patrol "..i.." brakes to a stable stop behind the diner")
end
local patrol={x=150,z=140,yaw=-math.pi/2,speed=40}
local target={x=250,z=146}
local forwardOnly=true
for _=1,120 do
 local x,z,yaw=patrol.x,patrol.z,patrol.yaw
 Rules.pursue(patrol,target,1/60)
 local dx,dz=patrol.x-x,patrol.z-z
 if math.abs(dx*math.cos(patrol.yaw)-dz*math.sin(patrol.yaw))>.00001 or math.abs(patrol.yaw-yaw)>.8/60+.00001 then forwardOnly=false end
end
check(forwardOnly and patrol.x>200,"pursuit steers and moves forward without diagonal strafing or instant heading changes")
print(count.." escape checks passed")
