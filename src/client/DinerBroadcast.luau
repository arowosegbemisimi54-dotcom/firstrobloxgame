local Audio=require(script.Parent.DinerAudio)
local Broadcast={}
function Broadcast.create(parent,origin,dialogue)
 local V=Vector3.new
 local C=Color3.fromRGB
 local model=Instance.new("Model"); model.Name="Diner countertop radio"; model.Parent=parent
 local base=CFrame.new(origin+V(14,4.45,-6))*CFrame.Angles(0,math.pi/2,0)
 local function part(name,size,offset,color,material)
  local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=base*CFrame.new(offset); p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Parent=model; return p
 end
 local radio=part("Walnut diner radio",V(3.2,1.8,1.3),V(0,0,0),C(99,61,35),Enum.Material.Wood)
 part("Radio woven speaker",V(1.75,1.2,.06),V(-.48,0,-.68),C(56,48,36),Enum.Material.Fabric)
 for x=-1.25,.25,.15 do part("Radio speaker rib",V(.035,1.18,.035),V(x,0,-.73),C(153,123,76)) end
 local dial=part("Amber tuning dial",V(.91,.42,.06),V(.93,.46,-.69),C(219,171,83),Enum.Material.Neon)
 for _,x in {.65,1.2} do local knob=part("Radio tuning knob",V(.3,.3,.16),V(x,-.43,-.73),C(204,180,123),Enum.Material.Metal); knob.Shape=Enum.PartType.Ball end
 part("Radio dial needle",V(.025,.32,.02),V(.8,.46,-.735),C(169,45,30))
 local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Front; gui.CanvasSize=Vector2.new(300,100); gui.Parent=dial
 local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1); text.BackgroundTransparency=1; text.Text="BLOX AM\n540  800  1200"; text.TextColor3=C(54,42,29); text.TextScaled=true; text.Font=Enum.Font.SpecialElite; text.Parent=gui
 local audio=Audio.create(model,radio,dialogue)
 return {radio=radio,update=function(shot,time) audio.update(shot,time) end,destroy=function() audio.destroy(); model:Destroy() end}
end
return Broadcast
