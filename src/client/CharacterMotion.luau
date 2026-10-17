-- Distance-driven R15 locomotion. Phase advances with travel, not the render clock.
local Motion={}
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
 local pose=Motion.sample(person.distance,speed,seated,person.style,time)
 for _,joint in {"LeftHip","RightHip","LeftKnee","RightKnee","LeftAnkle","RightAnkle","LeftShoulder","RightShoulder","LeftElbow","RightElbow"} do Motion.joint(person,joint,CFrame.Angles(pose[joint],0,0)) end
 Motion.joint(person,"Waist",CFrame.Angles(pose.lean,pose.twist,0))
 Motion.joint(person,"Neck",CFrame.Angles(.03,pose.glance,0))
 person.rig:PivotTo(CFrame.new(origin+pos+Vector3.new(0,pose.bob,0))*CFrame.Angles(0,yaw,0))
 if person.face then person.face(time,false,true,person.style=="officer" and "focused" or "urgent") end
end
return Motion
