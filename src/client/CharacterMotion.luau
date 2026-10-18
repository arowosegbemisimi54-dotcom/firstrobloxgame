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
function Motion.visibility(person,firstPerson)
 if not person.viewParts then
  local parts,links={},{}
  local head=person.rig:FindFirstChild("Head")
  local attached={}; if head then attached[head]=true end
  for _,object in person.rig:GetDescendants() do
   if object:IsA("BasePart") then table.insert(parts,object); if head and object:IsDescendantOf(head) then attached[object]=true end
   elseif object:IsA("Weld") or object:IsA("WeldConstraint") then table.insert(links,object) end
  end
  -- Include fitted hair, facial pieces and hats, but not the articulated torso.
  for _=1,4 do for _,link in links do
   if link.Part0 and link.Part1 and (attached[link.Part0] or attached[link.Part1]) then attached[link.Part0]=true; attached[link.Part1]=true end
  end end
  person.viewParts=parts; person.headParts=attached
 end
 if person.viewFirstPerson==firstPerson then return end
 person.viewFirstPerson=firstPerson
 for _,part in person.viewParts do if part.Parent then part.LocalTransparencyModifier=firstPerson and person.headParts[part] and 1 or 0 end end
end
function Motion.sample(distance,speed,seated,style,time)
 local phase=distance*math.pi/3.4
 local moving=math.clamp(speed/9,0,1)
 local running=math.clamp((speed-9)/9,0,1)
 local amplitude=(.52+running*.56)*moving
 -- Briefly hold the contact extremes; recover quickly through the passing pose.
 local wave=math.sin(phase)
 local left=wave>=0 and wave^.82 or -(-wave)^.82; local right=-left
 local recoverLeft=math.max(0,-math.sin(phase-.25))
 local recoverRight=math.max(0,math.sin(phase-.25))
 local aim=style=="officer"
 local carry=style=="crew"
 return {
  LeftHip=seated and 1.35 or left*amplitude,
  RightHip=seated and 1.35 or right*amplitude,
  LeftKnee=seated and -1.35 or -recoverLeft*(.85+running*.85)*moving,
  RightKnee=seated and -1.35 or -recoverRight*(.85+running*.85)*moving,
  LeftAnkle=seated and 0 or -left*amplitude*.3,
  RightAnkle=seated and 0 or -right*amplitude*.3,
  LeftShoulder=seated and 1.0 or (aim and 1.1 or (carry and .1 or -left*amplitude*.95)),
  RightShoulder=seated and 1.0 or (aim and 1.3 or -right*amplitude*.95),
  LeftElbow=seated and .55 or (aim and .9 or (carry and .25 or .35+running*.85)),
  RightElbow=seated and .55 or (aim and .35 or .35+running*.85),
  lean=seated and -.05 or -.04-moving*.08-running*.25,
  twist=math.sin(phase-.15)*moving*(.09+running*.06),
  bob=seated and 0 or (math.abs(math.cos(phase))*2-1)*moving*(.035+running*.045),
  hipSpread=seated and 0 or moving*(.035+running*.045),
  shoulderSpread=seated and 0 or (aim and .03 or .07+moving*.08),
  roll=seated and 0 or math.sin(phase)*moving*.045,
  wrist=(seated or aim or carry) and 0 or math.sin(phase-.3)*moving*.10,
  glance=math.sin(time*.7)*((carry or aim) and .25 or .06),
 }
end
-- Shared full-body rotations for scene rigs and live R15 avatars.
function Motion.rotations(pose)
 local result={}
 for _,name in {"LeftHip","RightHip","LeftKnee","RightKnee","LeftAnkle","RightAnkle","LeftShoulder","RightShoulder","LeftElbow","RightElbow"} do
  local sign=name:find("Left") and -1 or 1
  local spread=name:find("Hip") and pose.hipSpread or (name:find("Shoulder") and pose.shoulderSpread or 0)
  result[name]=CFrame.Angles(pose[name],0,sign*(spread or 0))
 end
 result.Waist=CFrame.Angles(pose.lean,pose.twist,pose.roll or 0)
 result.Neck=CFrame.Angles(.03-pose.lean*.22,pose.glance-pose.twist*.4,-(pose.roll or 0)*.4)
 result.LeftWrist=CFrame.Angles(pose.wrist or 0,0,0)
 result.RightWrist=CFrame.Angles(-(pose.wrist or 0),0,0)
 return result
end
function Motion.apply(person,pose)
 for name,rotation in Motion.rotations(pose) do Motion.joint(person,name,rotation) end
end
function Motion.idle(person,time,reduced)
 local pose=Motion.sample(0,0,false,"idle",time)
 local breathe=reduced and 0 or math.sin(time*1.7)
 pose.lean=-.025+breathe*.015; pose.twist=breathe*.025
 pose.LeftShoulder=.07+breathe*.025; pose.RightShoulder=.04-breathe*.025
 pose.LeftElbow=.12; pose.RightElbow=.16
 pose.glance=reduced and 0 or math.sin(time*.45)*.12
 Motion.apply(person,pose)
end
function Motion.action(person,time,role,reacting)
 if reacting and not person.reactionStart then person.reactionStart=time end
 if not reacting then person.reactionStart=nil end
 local since=person.reactionStart and time-person.reactionStart or 0
 local reaction=reacting and math.clamp(since/.4,0,1) or 0
 local recoil=reacting and math.sin(since*11)*math.exp(-since*5) or 0
 local rhythm=math.sin(time*1.6+(person.index or 0))
 local working=role=="chef" or role=="waitress"
 local lean=working and -.12 or -.06
 if role=="chef" and not reacting then lean-=math.max(0,math.sin(time*2.4-.4))*.12 end
 Motion.joint(person,"Waist",CFrame.Angles(lean+reaction*.13+recoil*.10,rhythm*.035-reaction*.10,rhythm*.025))
 if working then
  Motion.joint(person,"LeftHip",CFrame.Angles(.04,0,-.04)); Motion.joint(person,"RightHip",CFrame.Angles(-.04,0,.04))
  Motion.joint(person,"LeftKnee",CFrame.Angles(-.08,0,0)); Motion.joint(person,"RightKnee",CFrame.Angles(-.08,0,0))
 end
 return reaction
end
function Motion.board(person,progress,driver)
 local u=math.clamp(progress,0,1)
 local lift=math.sin(u*math.pi)
 local settle=u*u*(3-2*u)
 Motion.joint(person,"Waist",CFrame.Angles(-.05-.38*lift,0,-.06*lift))
 Motion.joint(person,"Neck",CFrame.Angles(.10*lift,0,0))
 for _,side in {"Left","Right"} do
  local lead=side=="Left" and 1 or .45
  Motion.joint(person,side.."Hip",CFrame.Angles(1.35*settle+.45*lift*lead,0,0))
  Motion.joint(person,side.."Knee",CFrame.Angles(-1.35*settle-.65*lift*lead,0,0))
  Motion.joint(person,side.."Ankle",CFrame.Angles(-.1*lift,0,0))
  Motion.joint(person,side.."Shoulder",CFrame.Angles((driver and 1 or .15)*settle+.65*lift,0,side=="Left" and -.08*lift or .08*lift))
  Motion.joint(person,side.."Elbow",CFrame.Angles(.3+.3*lift,0,0))
 end
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
 -- Blend between idle, walk and run without popping the elbows or knees.
 person.motionSpeed=(person.motionSpeed or 0)+(speed-(person.motionSpeed or 0))*(1-math.exp(-math.max(dt,0)*14))
 if seated then person.motionSpeed=0 end
 if person.motionYaw and travel>0 and not seated then
  local turn=(yaw-person.motionYaw+math.pi)%(2*math.pi)-math.pi
  yaw=person.motionYaw+turn*(1-math.exp(-math.max(dt,0)*14))
 end
 person.motionYaw=yaw
 local pose=Motion.sample(person.distance,person.motionSpeed,seated,person.style,time)
 Motion.apply(person,pose)
 person.rig:PivotTo(CFrame.new(origin+pos+Vector3.new(0,pose.bob,0))*CFrame.Angles(0,yaw,0))
 if person.face then person.face(time,false,true,person.style=="officer" and "focused" or "urgent") end
end
return Motion
