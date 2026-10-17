-- Two bounded rear-view renders. Only road and patrol copies are drawn, at 12 Hz.
local Mirrors={}
function Mirrors.create(vehicle,police,exterior)
 local feeds={}
 for _,glass in vehicle.mirrors do
  local surface=Instance.new("SurfaceGui"); surface.Name="Live rear-view mirror"; surface.Face=Enum.NormalId.Back; surface.CanvasSize=Vector2.new(180,240); surface.LightInfluence=0; surface.Parent=glass
  local viewport=Instance.new("ViewportFrame"); viewport.Size=UDim2.fromScale(1,1); viewport.BackgroundColor3=Color3.fromRGB(184,170,139); viewport.Ambient=Color3.fromRGB(175,161,136); viewport.LightColor=Color3.fromRGB(255,225,181); viewport.Visible=false; viewport.Parent=surface
  local world=Instance.new("WorldModel"); world.Parent=viewport
  local camera=Instance.new("Camera"); camera.FieldOfView=55; camera.Parent=viewport; viewport.CurrentCamera=camera
  for _,name in {"Highway Four","Highway desert verge"} do local original=exterior:FindFirstChild(name); if original then local copy=original:Clone(); copy.Parent=world end end
  local copies={}
  for _,unit in police do local copy=unit.model:Clone(); copy.Parent=world; table.insert(copies,{source=unit.model,model=copy}) end
  table.insert(feeds,{surface=surface,viewport=viewport,camera=camera,glass=glass,copies=copies})
 end
 local clock=0
 return {
  update=function(dt,enabled)
   clock+=dt
   for _,feed in feeds do feed.viewport.Visible=enabled end
   if not enabled or clock<1/12 then return end; clock=0
   local direction=-vehicle.model:GetPivot().LookVector
   for _,feed in feeds do
    local position=feed.glass.CFrame.Position
    feed.camera.CFrame=CFrame.lookAt(position,position+direction*70)
    for _,copy in feed.copies do copy.model:PivotTo(copy.source:GetPivot()) end
   end
  end,
  destroy=function() for _,feed in feeds do feed.surface:Destroy() end end,
 }
end
return Mirrors
