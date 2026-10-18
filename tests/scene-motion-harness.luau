-- A complete connected R15 fixture, including the Humanoid neck/death lifecycle.
-- Unlike the lightweight chapter double, PivotTo moves every part and physics
-- can destroy joints. This is numerical validation, not a Roblox renderer.
local Vec={}
Vec.__index=function(v,key)
 if key=="Magnitude" then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z) end
 return Vec[key]
end
local function v(x,y,z) return setmetatable({X=x,Y=y,Z=z},Vec) end
function Vec.__add(a,b) return v(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
function Vec.__sub(a,b) return v(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
local Vector3={new=v}
local CF={}; CF.__index=CF
local function cf(p,r) return setmetatable({Position=p,r=r},CF) end
local function rotate(r,p) return v(r[1]*p.X+r[2]*p.Y+r[3]*p.Z,r[4]*p.X+r[5]*p.Y+r[6]*p.Z,r[7]*p.X+r[8]*p.Y+r[9]*p.Z) end
function CF.__mul(a,b)
 local r={}
 for row=0,2 do for col=0,2 do
  local value=0; for k=0,2 do value+=a.r[row*3+k+1]*b.r[k*3+col+1] end
  r[row*3+col+1]=value
 end end
 return cf(a.Position+rotate(a.r,b.Position),r)
end
function CF:Inverse()
 local r={self.r[1],self.r[4],self.r[7],self.r[2],self.r[5],self.r[8],self.r[3],self.r[6],self.r[9]}
 return cf(rotate(r,v(-self.Position.X,-self.Position.Y,-self.Position.Z)),r)
end
function CF:ToObjectSpace(other) return self:Inverse()*other end
local CFrame={}
function CFrame.new(x,y,z) return cf(type(x)=="table" and x or v(x or 0,y or 0,z or 0),{1,0,0,0,1,0,0,0,1}) end
function CFrame.Angles(x,y,z)
 local cx,sx,cy,sy,cz,sz=math.cos(x),math.sin(x),math.cos(y),math.sin(y),math.cos(z),math.sin(z)
 return cf(v(0,0,0),{cy*cz,-cy*sz,sy,cx*sz+sx*sy*cz,cx*cz-sx*sy*sz,-sx*cy,sx*sz-cx*sy*cz,sx*cz+cx*sy*sz,cx*cy})
end
local Motion=(function()
-- INSERT_MOTION
end)()
local count=0
local function check(ok,message) assert(ok,message); count+=1; print("PASS: "..message) end

local function r15(style)
 local all={}; local parts={}; local motors={}
 local rig={Name=style.." fixture",Parent=true,attributes={}}
 local function object(class,name)
  local obj={ClassName=class,Name=name,Parent=rig}
  function obj:IsA(kind) return class==kind or (kind=="BasePart" and (class=="MeshPart" or class=="Part")) end
  function obj:Destroy() self.Parent=nil end
  table.insert(all,obj); return obj
 end
 local function part(name,size,pos,class)
  local obj=object(class or "MeshPart",name); obj.Size=size; obj.CFrame=CFrame.new(pos); obj.Anchored=false
  parts[name]=obj; return obj
 end
 local root=part("HumanoidRootPart",v(2,2,1),v(0,0,0),"Part")
 local lower=part("LowerTorso",v(2,.5,1),v(0,-.75,0))
 local upper=part("UpperTorso",v(2,1.5,1),v(0,.25,0))
 local head=part("Head",v(2,1,1),v(0,1.5,0))
 local function motor(name,a,b,pivot)
  local obj=object("Motor6D",name); obj.Part0=a; obj.Part1=b
  obj.C0=a.CFrame:ToObjectSpace(CFrame.new(pivot)); obj.C1=b.CFrame:ToObjectSpace(CFrame.new(pivot))
  obj.Transform=CFrame.new(); obj.Enabled=true; motors[name]=obj; return obj
 end
 motor("Root",root,lower,v(0,-.5,0)); motor("Waist",lower,upper,v(0,-.5,0)); motor("Neck",upper,head,v(0,1,0))
 for _,side in {"Left","Right"} do
  local sign=side=="Left" and -1 or 1
  local thigh=part(side.."UpperLeg",v(1,1.1,1),v(sign*.5,-1.6,0))
  local shin=part(side.."LowerLeg",v(1,.95,1),v(sign*.5,-2.55,0))
  local foot=part(side.."Foot",v(1,.4,1.2),v(sign*.5,-3.1,-.1))
  motor(side.."Hip",lower,thigh,v(sign*.5,-1,0)); motor(side.."Knee",thigh,shin,v(sign*.5,-2.15,0)); motor(side.."Ankle",shin,foot,v(sign*.5,-3,0))
  local arm=part(side.."UpperArm",v(1,1.2,1),v(sign*1.5,.35,0))
  local forearm=part(side.."LowerArm",v(1,1.1,1),v(sign*1.5,-.65,0))
  local hand=part(side.."Hand",v(1,.5,1),v(sign*1.5,-1.45,0))
  motor(side.."Shoulder",upper,arm,v(sign*1.1,.9,0)); motor(side.."Elbow",arm,forearm,v(sign*1.5,-.25,0)); motor(side.."Wrist",forearm,hand,v(sign*1.5,-1.2,0))
 end
 local boot=part("Fitted boot",v(1.05,.45,1.25),v(-.5,-3.13,-.18),"Part")
 local weld=object("WeldConstraint","Boot weld"); weld.Part0=parts.LeftFoot; weld.Part1=boot; weld.Enabled=true
 local hat=part("Fitted hat",v(2,.4,1.2),v(0,2.2,0),"Part")
 local accessory=object("Weld","AccessoryWeld"); accessory.Part0=hat; accessory.Part1=head
 accessory.C0=CFrame.new(0,-.7,0); accessory.C1=CFrame.new(); accessory.Enabled=true
 local humanoid=object("Humanoid","Humanoid")
 humanoid.RequiresNeck=true; humanoid.BreakJointsOnDeath=true; humanoid.EvaluateStateMachine=true; humanoid.AutoRotate=true; humanoid.Health=100
 function rig:GetDescendants()
  local result={}; for i=#all,1,-1 do if all[i].Parent then table.insert(result,all[i]) end end; return result
 end
 function rig:FindFirstChild(name) return parts[name] end
 function rig:FindFirstChildOfClass(kind) if kind=="Humanoid" then return humanoid end end
 function rig:SetAttribute(name,value) self.attributes[name]=value end
 function rig:GetAttribute(name) return self.attributes[name] end
 function rig:GetPivot() return root.CFrame end
 function rig:PivotTo(target)
  local delta=target*root.CFrame:Inverse()
  for _,obj in all do if obj:IsA("BasePart") and obj.Parent then obj.CFrame=delta*obj.CFrame end end
  root.CFrame=target
 end
 rig.PrimaryPart=root
 local person={rig=rig,joints={},style=style}
 for name,joint in motors do person.joints[name]={joint=joint,base=joint.C0} end
 local function physics()
  local neck=motors.Neck
  if humanoid.EvaluateStateMachine and humanoid.RequiresNeck and (not neck.Parent or neck.Enabled==false) then humanoid.Health=0 end
  if humanoid.Health<=0 and humanoid.BreakJointsOnDeath then
   for _,obj in all do if obj:IsA("Motor6D") or obj:IsA("Weld") or obj:IsA("WeldConstraint") then obj:Destroy() end end
  end
 end
 return person,parts,motors,humanoid,physics
end

-- Prove that this double exercises the engine behavior absent from older tests.
do
 local _,_,joints,human,physics=r15("unprotected")
 joints.Neck.Enabled=false; physics()
 check(human.Health==0 and not joints.LeftKnee.Parent,"fixture reproduces Humanoid death and joint destruction after a disconnected neck")
end

for _,style in {"player","crew","officer"} do
 for _,fps in {30,60,120} do
  local person,parts,joints,human,physics=r15(style)
  Motion.bind(person); physics()
  check(human.Health>0 and joints.Neck.Parent and joints.LeftKnee.Parent,style.." keeps a connected R15 skeleton after the Humanoid update at "..fps.." FPS")
  local root=parts.HumanoidRootPart
  local origin=v(0,14000,0)
  local samples={}; local travel=0
  local function frame(speed,seated,time)
   travel+=speed/fps
   local turn=time>2 and math.pi/3 or 0
   Motion.pose(person,origin,v(travel,3,-time),turn,1/fps,seated,time)
   Motion.flush(person); physics()
   assert(human.Health>0 and joints.LeftHip.Parent,"skeleton died while posing")
   -- The drawn body must follow the complete root-to-limb chain, not just C0 changes.
   for _,joint in joints do
    local a=joint.Part0.CFrame*joint.C0
    local b=joint.Part1.CFrame*joint.C1
    assert((a.Position-b.Position).Magnitude<.00001,string.format("visible limb disconnected at %s: %.8f studs at %.3fs",joint.Name,(a.Position-b.Position).Magnitude,time))
   end
   local shoe=parts.LeftFoot.CFrame*CFrame.new(0,-.03,-.08)
   assert((parts["Fitted boot"].CFrame.Position-shoe.Position).Magnitude<.00001,"boot does not follow the ankle")
   local hat=parts.Head.CFrame*CFrame.new(0,.7,0)
   assert((parts["Fitted hat"].CFrame.Position-hat.Position).Magnitude<.00001,"hat does not follow the head")
   for _,name in {"LeftFoot","RightFoot","LeftLowerLeg","RightLowerLeg","LeftHand","RightHand","UpperTorso"} do
    local localCF=root.CFrame:ToObjectSpace(parts[name].CFrame)
    local sample=samples[name] or {first=localCF,delta=0}
    sample.delta=math.max(sample.delta,(sample.first.Position-localCF.Position).Magnitude)
    samples[name]=sample
   end
  end
  -- Seated-to-standing and a sustained run cover the diner-to-escape handoff.
  for i=1,fps do frame(0,true,i/fps) end
  for i=1,fps*2 do frame(i<fps and 9 or 19,false,1+i/fps) end
  samples={}
  for i=1,fps*3 do frame(19,false,3+i/fps) end
  check(samples.LeftFoot.delta>1 and samples.RightFoot.delta>1 and samples.LeftLowerLeg.delta>.5 and samples.RightLowerLeg.delta>.5 and samples.RightHand.delta>.1,style.." visibly articulates both legs and the free arm across seated, walk and run poses at "..fps.." FPS")
 end
end
print(count.." scene motion checks passed")
