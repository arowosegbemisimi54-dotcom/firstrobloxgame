-- Perspective desert vignette for the loading screen. Independent of world lighting.
local Landscape={}
function Landscape.create(screen,ui)
	local V=Vector3.new
	local C=Color3.fromRGB
	local viewport=ui.make("ViewportFrame",{Name="Desert loading landscape",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Ambient=C(123,98,83),LightColor=C(255,207,153),LightDirection=V(-1,-.3,-.6),ZIndex=41},screen)
	local world=Instance.new("WorldModel"); world.Parent=viewport
	local camera=Instance.new("Camera"); camera.FieldOfView=48; camera.Parent=viewport; viewport.CurrentCamera=camera
	local function part(name,size,position,color,shape,parent)
		local p=Instance.new("Part"); p.Name,p.Size,p.Color=name,size,color; p.Material=Enum.Material.Sand
		p.Anchored,p.CanCollide,p.CanTouch,p.CanQuery=true,false,false,false
		p.CFrame=CFrame.new(position); if shape then p.Shape=shape end; p.Parent=parent or world
		return p
	end
	local function triangle(a,b,c,color)
		local ab,ac,bc=b-a,c-a,c-b
		if ab:Dot(ab)>ac:Dot(ac) and ab:Dot(ab)>bc:Dot(bc) then a,c=c,a elseif ac:Dot(ac)>bc:Dot(bc) then a,b=b,a end
		ab,ac,bc=b-a,c-a,c-b
		if ac:Cross(ab).Magnitude<.001 then return end
		local right=ac:Cross(ab).Unit; local back=bc.Unit; local up=back:Cross(right).Unit
		for _,data in {{(a+b)/2,right,back,math.abs(ab:Dot(back))},{(a+c)/2,-right,-back,math.abs(ac:Dot(back))}} do
			local p=Instance.new("WedgePart"); p.Name="Wind eroded terrain"; p.Size=V(.025,math.abs(ab:Dot(up)),math.max(.025,data[4])); p.CFrame=CFrame.fromMatrix(data[1],data[2],up,data[3]); p.Color=color; p.Material=Enum.Material.Sandstone; p.Anchored=true; p.CanCollide=false; p.Parent=world
		end
	end
	-- Low, continuous foreground dunes and serrated distant ridges share vertices.
	local grid={}
	for row=0,14 do
		grid[row]={}
		for col=0,20 do
			local x=-180+col*18; local z=35-row*17
			local height=math.noise(x*.012,z*.016,7)*4-2
			if row>8 then height+=math.max(0,math.sin(col*.58+row*.4)+.6)*(row-8)*2.5+math.noise(col*.53,row*.4,12)*9 end
			grid[row][col]=V(x,height,z)
		end
	end
	for row=0,13 do for col=0,19 do
		local color=C(170,123,78):Lerp(C(107,99,109),math.clamp((row-5)/10,0,.65))
		color=color:Lerp(C(221,176,117),.1+math.noise(col,row,2)*.12)
		triangle(grid[row][col],grid[row][col+1],grid[row+1][col],color)
		triangle(grid[row][col+1],grid[row+1][col+1],grid[row+1][col],color)
	end end
	part("Remote asphalt ribbon",V(330,.04,8),V(0,.15,-42),C(63,59,55))
	for x=-156,156,13 do part("Faded highway dash",V(5,.015,.1),V(x,.18,-42),C(189,161,110)) end
	local function branch(name,a,b,width,color,parent)
		local p=part(name,V(width,width,(b-a).Magnitude),(a+b)/2,color,nil,parent)
		p.CFrame=CFrame.lookAt((a+b)/2,b); return p
	end
	for _,spec in {{-30,-23,4.7},{23,-19,3.4},{-48,-62,5},{53,-70,5.5}} do
		local x,z,h=spec[1],spec[2],spec[3]
		part("Saguaro trunk",V(.65,h,.65),V(x,h/2,z),C(65,77,49),Enum.PartType.Ball)
		for _,side in {-1,1} do
			branch("Saguaro arm",V(x,h*.5,z),V(x+side*.9,h*.6,z),.34,C(65,77,49))
			part("Saguaro finger",V(.36,h*.35,.36),V(x+side*.9,h*.75,z),C(65,77,49),Enum.PartType.Ball)
		end
	end
	for i=1,28 do
		local x=math.sin(i*7.3)*67; local z=-9-(i%7)*10
		part("Desert stone",V(.4+(i%4)*.17,.2+(i%3)*.12,.5),V(x,-.1,z),C(126+i%5*6,96+i%4*5,66),Enum.PartType.Ball)
	end
	local weed=Instance.new("Model"); weed.Name="Rolling tumbleweed"; weed.Parent=world
	for ring=1,7 do
		local tilt=CFrame.Angles(ring*.58,ring*.83,ring*.34)
		for i=1,12 do
			local a=i*math.pi/6; local b=(i+1)*math.pi/6
			local radius=.55+ring*.017
			local from=tilt:VectorToWorldSpace(V(math.cos(a)*radius,math.sin(a)*radius,0))
			local to=tilt:VectorToWorldSpace(V(math.cos(b)*radius,math.sin(b)*radius,0))
			branch("Dry tumbleweed twig",from,to,.025,C(139+ring*7,106+ring*5,66),weed)
		end
	end
	-- A fixed pivot makes rotation stable as the irregular branches turn.
	weed.WorldPivot=CFrame.new()
	return function(elapsed,reduced)
		local drift=reduced and 0 or math.sin(elapsed*.12)*.7
		camera.CFrame=CFrame.lookAt(V(8+drift,5,26),V(drift,2,-55))
		local travel=reduced and 0 or math.sin(elapsed*.23)*4
		weed:PivotTo(CFrame.new(5+travel,.85,7)*CFrame.Angles(0,0,reduced and 0 or -elapsed*.65))
	end
end
return Landscape
