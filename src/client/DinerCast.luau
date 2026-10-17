-- Four original R6 characters. Faces are drawn locally, without catalog dependencies.
local Cast={}
local C=Color3.fromRGB
local V=Vector3.new
local people={
	{Name="Elias Reed · traveling surveyor",Skin=C(190,138,101),Hair=C(49,37,30),Shirt=C(174,164,137),Coat=C(67,64,53),Pants=C(57,53,46),Style="surveyor"},
	{Name="June Calder · roadside regular",Skin=C(224,173,136),Hair=C(115,56,34),Shirt=C(215,196,162),Coat=C(102,123,104),Pants=C(62,75,81),Style="regular"},
	{Name="Rosa Vale · server",Skin=C(157,103,74),Hair=C(43,29,25),Shirt=C(111,158,146),Coat=C(111,158,146),Pants=C(70,91,84),Style="server"},
	{Name="Leon Brooks · cook",Skin=C(119,80,57),Hair=C(36,31,29),Shirt=C(231,219,194),Coat=C(231,219,194),Pants=C(47,49,47),Style="cook"},
}
local function makeFace(head,person,index)
	for _,child in head:GetChildren() do if child:IsA("Decal") or child:IsA("SurfaceGui") then child:Destroy() end end
	local gui=Instance.new("SurfaceGui"); gui.Name="Animated character face"; gui.Face=Enum.NormalId.Front; gui.CanvasSize=Vector2.new(256,128); gui.LightInfluence=.25; gui.Parent=head
	local function mark(name,x,y,w,h,color,round)
		local f=Instance.new("Frame"); f.Name=name; f.Position=UDim2.fromOffset(x,y); f.Size=UDim2.fromOffset(w,h); f.BackgroundColor3=color; f.BorderSizePixel=0; f.Parent=gui
		if round then local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=f end
		return f
	end
	local eyes={}
	for _,x in {89,151} do
		local eye=mark("Eye white",x,48,18,11,C(241,233,212),true)
		local pupil=Instance.new("Frame"); pupil.Name="Hazel iris"; pupil.Size=UDim2.fromOffset(7,10); pupil.Position=UDim2.fromOffset(6,0); pupil.BackgroundColor3=index==2 and C(66,91,72) or C(58,42,30); pupil.BorderSizePixel=0; pupil.Parent=eye
		local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(1,0); corner.Parent=pupil
		local highlight=mark("Eye highlight",x+9,49,2,2,C(255,247,228),true)
		local brow=mark("Expressive eyebrow",x-2,39,22,4,person.Hair,true); brow.Rotation=x<128 and -5 or 5
		table.insert(eyes,{white=eye,pupil=pupil,brow=brow,highlight=highlight})
	end
	mark("Nose shadow",126,62,5,12,person.Skin:Lerp(C(70,39,25),.25),true)
	local mouth=mark("Animated mouth",116,88,26,4,C(82,43,34),true)
	mark("Lower lip",121,94,16,2,person.Skin:Lerp(C(151,73,57),.35),true)
	if person.Style=="cook" then
		for _,x in {112,130} do local m=mark("Cook moustache",x,81,18,5,person.Hair,true); m.Rotation=x==112 and -8 or 8 end
	elseif person.Style=="surveyor" then
		for i=1,9 do mark("Beard stubble",105+i*5,98+(i%2)*3,2,2,person.Hair,true) end
	elseif person.Style=="regular" then
		for _,x in {95,161} do for i=1,3 do mark("Freckle",x+i*3,71+(i%2)*3,2,2,C(153,88,55),true) end end
	end
	return function(time,eating)
		local phase=(time+index*.83)%(3.3+index*.21)
		local blink=phase<.12
		for _,eye in eyes do
			eye.white.Size=UDim2.fromOffset(18,blink and 2 or 11)
			eye.pupil.Visible=not blink; eye.highlight.Visible=not blink
			eye.pupil.Position=UDim2.fromOffset(6+math.sin(time*.43+index)*2,0)
			eye.brow.Rotation=math.sin(time*.6+index)*3
		end
		local chewing=eating and math.sin(time*1.6+index+1)>.35
		mouth.Size=UDim2.fromOffset(26,chewing and (4+math.abs(math.sin(time*9))*5) or 3)
	end
end
function Cast.dress(rig,index)
	local person=people[index]
	rig.Name=person.Name
	local head=rig:FindFirstChild("Head")
	local torso=rig:FindFirstChild("Torso")
	assert(head and torso,"Diner cast requires R6")
	local clothes=Instance.new("Model"); clothes.Name="Original character wardrobe"; clothes.Parent=rig
	local function piece(body,name,size,offset,color,shape,material)
		local p=Instance.new("Part"); p.Name,p.Size,p.Color=name,size,color; p.Material=material or Enum.Material.Fabric
		p.CanCollide,p.CanTouch,p.CanQuery,p.Massless=false,false,false,true
		p.CFrame=body.CFrame*offset; if shape then p.Shape=shape end; p.Parent=clothes
		local weld=Instance.new("WeldConstraint"); weld.Part0,weld.Part1,weld.Parent=body,p,p
		return p
	end
	for _,body in rig:GetChildren() do
		if body:IsA("BasePart") and body.Name~="HumanoidRootPart" then
			body.Color=body.Name=="Head" and person.Skin or (body.Name:find("Leg") and person.Pants or person.Shirt)
		end
	end
	-- The default description can contain BodyColors: keep it consistent with our palette.
	local bodyColors=rig:FindFirstChildOfClass("BodyColors")
	if bodyColors then bodyColors.HeadColor3=person.Skin; bodyColors.TorsoColor3=person.Shirt; bodyColors.LeftArmColor3=person.Shirt; bodyColors.RightArmColor3=person.Shirt; bodyColors.LeftLegColor3=person.Pants; bodyColors.RightLegColor3=person.Pants end
	local front=-torso.Size.Z/2-.025
	local boot=C(63,43,31)
	for _,side in {"Left","Right"} do
		local arm=rig:FindFirstChild(side.." Arm")
		local leg=rig:FindFirstChild(side.." Leg")
		if arm then
			piece(arm,"Exposed hand",V(1.015,.36,1.015),CFrame.new(0,-.82,0),person.Skin,nil,Enum.Material.SmoothPlastic)
			piece(arm,"Tailored shirt cuff",V(1.025,.15,1.025),CFrame.new(0,-.59,0),person.Shirt:Lerp(C(255,255,255),.13))
		end
		if leg then
			piece(leg,"Leather boot shaft",V(1.025,.42,1.025),CFrame.new(0,-.72,0),boot,nil,Enum.Material.Leather)
			piece(leg,"Rounded boot toe",V(1.03,.37,1.28),CFrame.new(0,-.88,-.14),boot,Enum.PartType.Ball,Enum.Material.Leather)
			piece(leg,"Boot welt",V(1.04,.07,1.21),CFrame.new(0,-1.02,-.08),C(104,77,45),nil,Enum.Material.Leather)
			piece(leg,"Boot heel",V(.85,.12,.4),CFrame.new(0,-1.08,.28),C(37,30,25))
			piece(leg,"Pressed trouser seam",V(.022,1.5,.018),CFrame.new(0,.18,-.515),person.Pants:Lerp(C(210,200,170),.16))
		end
	end
	for _,side in {-1,1} do
		piece(torso,"Fitted jacket panel",V(.75,1.55,.075),CFrame.new(side*.58,-.1,front),person.Coat)
		piece(torso,"Folded lapel",V(.26,.69,.08),CFrame.new(side*.27,.43,front-.045)*CFrame.Angles(0,0,-side*.29),person.Coat:Lerp(C(255,244,214),.12))
		piece(torso,"Collar point",V(.28,.26,.085),CFrame.new(side*.2,.8,front-.02)*CFrame.Angles(0,0,side*.32),person.Shirt:Lerp(C(255,255,255),.2))
		piece(torso,"Pocket welt",V(.44,.055,.09),CFrame.new(side*.58,-.3,front-.045),person.Coat:Lerp(C(20,20,20),.18))
	end
	for i=1,4 do piece(torso,"Mother of pearl button",V(.065,.065,.07),CFrame.new(0,.48-i*.29,front-.04),C(217,202,159),Enum.PartType.Ball) end
	piece(torso,"Leather belt",V(2.035,.14,1.035),CFrame.new(0,-.88,0),boot,nil,Enum.Material.Leather)
	piece(torso,"Brass belt buckle",V(.23,.19,.08),CFrame.new(0,-.88,front-.02),C(174,142,74),nil,Enum.Material.Metal)
	-- Hair follows the standard head rather than covering its face.
	piece(head,"Sculpted hair cap",V(1.9,.45,1.05),CFrame.new(0,.48,.06),person.Hair,Enum.PartType.Ball)
	for _,side in {-1,1} do piece(head,"Sideburn",V(.18,.43,.5),CFrame.new(side*.85,.21,.12),person.Hair,Enum.PartType.Ball) end
	if person.Style=="surveyor" then
		for _,side in {-1,1} do for i=1,5 do piece(torso,"Waistcoat pinstripe",V(.015,1.25,.012),CFrame.new(side*(.36+i*.105),-.1,front-.046),C(120,115,95)) end end
		piece(torso,"Narrow necktie",V(.13,.66,.08),CFrame.new(0,.4,front-.08),C(66,49,39))
		piece(head,"Felt hat brim",V(.10,2.55,1.85),CFrame.new(0,.67,0)*CFrame.Angles(0,0,math.pi/2),C(63,52,39),Enum.PartType.Cylinder)
		piece(head,"Pinched felt crown",V(1.65,.74,1.12),CFrame.new(0,.96,0),C(72,60,44),Enum.PartType.Ball)
		piece(head,"Hat ribbon",V(1.65,.12,1.12),CFrame.new(0,.77,0),C(34,30,25))
	elseif person.Style=="regular" or person.Style=="server" then
		piece(head,"Coiled hair bun",V(.77,.7,.7),CFrame.new(0,.36,.65),person.Hair,Enum.PartType.Ball)
		for i=1,4 do piece(head,"Swept hair wave",V(.62,.22,.4),CFrame.new(-.65+i*.31,.39,-.43)*CFrame.Angles(0,0,-.22),person.Hair,Enum.PartType.Ball) end
		for _,side in {-1,1} do piece(head,"Small brass earring",V(.09,.15,.07),CFrame.new(side*.91,-.2,0),C(202,160,71),Enum.PartType.Ball,Enum.Material.Metal) end
		if person.Style=="server" then
			piece(torso,"Ivory apron",V(1.32,1.07,.06),CFrame.new(0,-.53,front-.1),C(236,225,200))
			piece(torso,"Apron waistband",V(2.08,.13,1.08),CFrame.new(0,-.18,0),C(236,225,200))
			piece(torso,"Server name badge",V(.44,.18,.06),CFrame.new(-.55,.45,front-.1),C(230,215,168),nil,Enum.Material.Metal)
			piece(head,"Hair ribbon",V(.62,.12,.12),CFrame.new(0,.52,.87),C(111,158,146))
		end
	else
		piece(head,"Cook cap band",V(1.85,.21,1.15),CFrame.new(0,.56,0),C(238,231,209))
		piece(head,"Soft cook cap",V(1.92,.51,1.2),CFrame.new(0,.81,.08),C(238,231,209),Enum.PartType.Ball)
		piece(torso,"Cook apron",V(1.5,1.18,.08),CFrame.new(0,-.48,front-.13),C(215,207,183))
		for _,x in {-.3,.3} do for i=1,3 do piece(torso,"Double breasted button",V(.075,.075,.08),CFrame.new(x,.81-i*.18,front-.13),C(70,64,52),Enum.PartType.Ball) end end
	end
	return person.Name,makeFace(head,person,index)
end
return Cast
