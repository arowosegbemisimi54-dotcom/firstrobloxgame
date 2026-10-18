-- Render the same authored gait on live R15 players without changing physics,
-- movement controls, default airborne animations or higher-priority actions.
local Motion=require(script.Parent.CharacterMotion)
local Live={}
function Live.attach(rig)
 local humanoid=rig:FindFirstChildOfClass("Humanoid")
 local root=rig:FindFirstChild("HumanoidRootPart")
 if not humanoid or not root or not rig:FindFirstChild("UpperTorso") then return nil end
 local joints={}
 local function collect(item)
  if item:IsA("Motor6D") then joints[item.Name]=item end
 end
 for _,item in rig:GetDescendants() do collect(item) end
 local added=rig.DescendantAdded:Connect(collect)
 local saved={}
 local time,distance,speed=0,0,0
 local previous=root.Position
 local destroyed=false
 local function reset()
  for joint,transform in saved do if joint.Parent then joint.Transform=transform end end
  table.clear(saved)
 end
 return {
  reset=reset,
  update=function(dt)
   if destroyed then return end
   dt=math.clamp(dt,0,.1); time+=dt
   local delta=root.Position-previous; previous=root.Position
   local travel=math.sqrt(delta.X*delta.X+delta.Z*delta.Z)
   if travel<8 then distance+=travel end
   local state=humanoid:GetState()
   local grounded=state==Enum.HumanoidStateType.Running or state==Enum.HumanoidStateType.RunningNoPhysics or state==Enum.HumanoidStateType.Landed
   if not root.Parent or root.Anchored or humanoid.Health<=0 or humanoid.Sit or humanoid.PlatformStand or not grounded or humanoid.FloorMaterial==Enum.Material.Air then speed=0; return end
   local animator=humanoid:FindFirstChildOfClass("Animator")
   if animator then
    for _,track in animator:GetPlayingAnimationTracks() do
     if track.IsPlaying and track.Priority.Value>=Enum.AnimationPriority.Action.Value then return end
    end
   end
   local velocity=root.AssemblyLinearVelocity
   local target=math.sqrt(velocity.X*velocity.X+velocity.Z*velocity.Z)
   speed+=(target-speed)*(1-math.exp(-dt*14))
   local pose=Motion.sample(distance,speed,false,"player",time)
   local rotations=Motion.rotations(pose)
   rotations.Root=CFrame.new(0,pose.bob,0)
   rotations.RootJoint=rotations.Root
   local tool=rig:FindFirstChildOfClass("Tool")
   for name,rotation in rotations do
    local joint=joints[name]
    local arm=name:find("Shoulder") or name:find("Elbow") or name:find("Wrist")
    if joint and joint.Parent and not (tool and arm) then
     saved[joint]=joint.Transform
     joint.Transform=rotation
    end
   end
  end,
  destroy=function()
   if destroyed then return end
   destroyed=true; reset(); added:Disconnect()
  end,
 }
end
return Live
