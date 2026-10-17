-- Distance-driven R15 locomotion. Phase advances with travel, not the render clock.
local Motion={}
-- Scene rigs are kinematic: solve their complete joint tree after PivotTo.
-- This avoids cached model offsets and Humanoid/Animator evaluation undoing a
-- procedural pose between the render callback and the physics step.
function Motion.bind(person)
 local root=assert(person.rig:FindFirstChild("HumanoidRootPart"),"Scene rig needs a root")
 local edges={}
 for _,item in person.rig:GetDescendants() do
  if item:IsA("BasePart") then item.Anchored=true
  elseif item:IsA("Motor6D") or item:IsA("Weld") or item:IsA("WeldConstraint") then
   if item.Part0 and item.Part1 then
    local fixed=item:IsA("WeldConstraint")
    table.insert(edges,{joint=item,a=item.Part0,b=item.Part1,fixed=fixed,
     offset=fixed and item.Part0.CFrame:ToObjectSpace(item.Part1.CFrame) or nil})
    item.Enabled=false
    if item:IsA("Motor6D") then item.Transform=CFrame.new() end
   end
  end
 end
 local known={[root]=true}; local ordered={}
 for _=1,#edges do
  local added=false
  for _,edge in edges do
   if not edge.used and known[edge.a]~=known[edge.b] then
    edge.used=true; edge.reverse=known[edge.b]==true
    known[edge.a]=true; known[edge.b]=true
    table.insert(ordered,edge); added=true
   end
  end
  if not added then break end
 end
 person.poseLinks=ordered
end
function Motion.flush(person)
 if not person.poseLinks then Motion.bind(person) end
 for _,edge in person.poseLinks do
  if edge.joint.Parent and edge.a.Parent and edge.b.Parent then
   local offset=edge.fixed and edge.offset or edge.joint.C0*edge.joint.C1:Inverse()
   if edge.reverse then edge.a.CFrame=edge.b.CFrame*offset:Inverse()
   else edge.b.CFrame=edge.a.CFrame*offset end
  end
 end
end
function Motion.joint(person,name,rotation)
 local aliases={LeftShoulder="Left Shoulder",RightShoulder="Right Shoulder",LeftHip="Left Hip",RightHip="Right Hip"}
 local data=person.joints[name] or person.joints[aliases[name]]
 if data then data.joint.C0=data.base*rotation end
end
function Motion.sample(distance,speed,seated,style,time)
 local phase=distance*math.pi/3.4
 local moving=math.clamp(speed/9,0,1)
 local running=math.clamp((speed-9)/9,0,1)
 local amplitude=(.48+running*.32)*moving
 local left=math.sin(phase); local right=-left
 local aim=style=="officer"
 local carry=style=="crew"
 return {
  LeftHip=seated and 1.35 or left*amplitude,
  RightHip=seated and 1.35 or right*amplitude,
  LeftKnee=seated and -1.35 or -math.max(0,-left)*(.8+running*.65)*moving,
  RightKnee=seated and -1.35 or -math.max(0,-right)*(.8+running*.65)*moving,
  LeftAnkle=seated and 0 or -left*amplitude*.3,
  RightAnkle=seated and 0 or -right*amplitude*.3,
  LeftShoulder=seated and 1.0 or (aim and 1.1 or (carry and .1 or -left*amplitude*.8)),
  RightShoulder=seated and 1.0 or (aim and 1.3 or -right*amplitude*.8),
  LeftElbow=seated and .55 or (aim and .9 or (carry and .25 or .35+running*.7)),
  RightElbow=seated and .55 or (aim and .35 or .35+running*.7),
  lean=seated and -.05 or -.08-running*.12,
  twist=math.sin(phase)*moving*.07,
  bob=seated and 0 or math.abs(math.cos(phase))*moving*(.045+running*.055),
  glance=math.sin(time*.7)*((carry or aim) and .25 or .06),
 }
end
function Motion.pose(person,origin,pos,yaw,dt,seated,time)
 local previous=person.motionPosition
 local travel=previous and (pos-previous).Magnitude or 0
 if travel>8 then travel=0 end -- Scene cuts must not kick the gait forward.
 person.motionPosition=pos
 person.distance=(person.distance or 0)+travel
 local speed=dt>0 and travel/dt or 0
 -- Face the direction of travel; do not strafe a running cycle across the lot.
 if not seated and travel>.001 then
  local delta=pos-previous
  yaw=math.atan2(-delta.X,-delta.Z)
 end
 local pose=Motion.sample(person.distance,speed,seated,person.style,time)
 for _,joint in {"LeftHip","RightHip","LeftKnee","RightKnee","LeftAnkle","RightAnkle","LeftShoulder","RightShoulder","LeftElbow","RightElbow"} do Motion.joint(person,joint,CFrame.Angles(pose[joint],0,0)) end
 Motion.joint(person,"Waist",CFrame.Angles(pose.lean,pose.twist,0))
 Motion.joint(person,"Neck",CFrame.Angles(.03,pose.glance,0))
 person.rig:PivotTo(CFrame.new(origin+pos+Vector3.new(0,pose.bob,0))*CFrame.Angles(0,yaw,0))
 if person.face then person.face(time,false,true,person.style=="officer" and "focused" or "urgent") end
end
return Motion
