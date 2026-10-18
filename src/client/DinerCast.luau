-- Original R15 diner characters. Faces are drawn locally, without catalog dependencies.
local Cast={}
local C=Color3.fromRGB
local V=Vector3.new
local people={
	{Name="Elias Reed · traveling surveyor",Skin=C(190,138,101),Hair=C(49,37,30),Shirt=C(174,164,137),Coat=C(67,64,53),Pants=C(57,53,46),Style="surveyor"},
	{Name="June Calder · roadside regular",Skin=C(224,173,136),Hair=C(115,56,34),Shirt=C(215,196,162),Coat=C(102,123,104),Pants=C(62,75,81),Style="regular"},
	{Name="Rosa Vale · server",Skin=C(157,103,74),Hair=C(43,29,25),Shirt=C(111,158,146),Coat=C(111,158,146),Pants=C(70,91,84),Style="server"},
	{Name="Leon Brooks · cook",Skin=C(119,80,57),Hair=C(36,31,29),Shirt=C(231,219,194),Coat=C(231,219,194),Pants=C(47,49,47),Style="cook"},
	{Name="Ida Mercer · newspaper reader",Skin=C(212,164,133),Hair=C(125,120,110),Shirt=C(201,180,150),Coat=C(113,78,62),Pants=C(62,65,69),Style="regular"},
	{Name="Walt Finch · counter customer",Skin=C(174,125,89),Hair=C(58,45,34),Shirt=C(149,163,159),Coat=C(75,90,88),Pants=C(48,56,64),Style="surveyor"},
}
local function makeFace(head,person,index)
	for _,child in head:GetChildren() do if child:IsA("Decal") or child:IsA("SurfaceGui") then child:Destroy() end end
	-- Welded facial geometry stays visible on curved heads, without a GUI
	-- being hidden inside the head mesh at the mouth and cheek edges.
	local face=Instance.new("Model"); face.Name="Animated character face"; face.Parent=head
	local front=-head.Size.Z/2-.045
	local function feature(name,x,y,w,h,color,depth)
		local p=Instance.new("Part"); p.Name=name; p.Size=V(w,h,depth or .065); p.Shape=Enum.PartType.Ball; p.Color=color; p.Material=Enum.Material.SmoothPlastic
		p.CanCollide,p.CanTouch,p.CanQuery,p.Massless=false,false,false,true
		local offset=CFrame.new(x,y,front); p.CFrame=head.CFrame*offset; p.Parent=face
		local joint=Instance.new("Weld"); joint.Part0=head; joint.Part1=p; joint.C0=offset; joint.Parent=p
		return p,joint
	end
	local eyes={}
	for _,side in {-1,1} do
		local x=side*.25
		local white=feature("Eye white",x,.12,.26,.22,C(246,237,215))
		local pupil,pupilJoint=feature("Expressive iris",x,.12,.11,.15,index==2 and C(55,91,66) or C(50,37,26),.095)
		local brow,browJoint=feature("Expressive eyebrow",x,.32,.30,.065,person.Hair)
		table.insert(eyes,{white=white,pupil=pupil,pupilJoint=pupilJoint,brow=browJoint,side=side,x=x})
	end
	feature("Sculpted nose",0,-.035,.11,.17,person.Skin:Lerp(C(91,54,34),.12),.16)
	local mouth=feature("Animated mouth",0,-.24,.39,.10,C(73,33,28),.09)
	local teeth=feature("Visible teeth",0,-.215,.29,.04,C(240,230,202),.12)
	if person.Style=="cook" then
		for _,side in {-1,1} do feature("Cook moustache",side*.12,-.14,.23,.065,person.Hair,.13) end
	elseif person.Style=="regular" then
		for _,side in {-1,1} do for i=1,3 do feature("Cheek freckle",side*(.27+i*.045),-.09+(i%2)*.035,.022,.022,C(149,89,59),.07) end end
	end
	return function(time,eating,reacting,emotion)
		local blink=(time+index*.83)%(3.3+index*.21)<.12
		for _,eye in eyes do
			eye.white.Size=V(.26,blink and .025 or (reacting and .26 or .22),.065)
			eye.pupil.Transparency=blink and 1 or 0
			eye.pupilJoint.C0=CFrame.new(eye.x+math.sin(time*.43+index)*.025,.12,front)
			eye.brow.C0=CFrame.new(eye.x,reacting and .34 or .32,front)*CFrame.Angles(0,0,reacting and eye.side*(emotion=="focused" and -.3 or .28) or math.sin(time*.6+index)*.08)
		end
		local chewing=eating and math.sin(time*1.6+index+1)>.35
		mouth.Size=V(reacting and .29 or .39,reacting and (emotion=="focused" and .07 or .19) or (chewing and .11+math.abs(math.sin(time*9))*.08 or .10),.09)
		teeth.Transparency=reacting and 1 or 0
	end
end
function Cast.dress(rig,index,role)
	local person=people[index]
	if role=="officer" then
		person=table.clone(person); person.Style="officer"
		person.Shirt=C(43,55,68); person.Coat=C(32,43,56); person.Pants=C(31,41,54)
	end
	rig.Name=person.Name
	local head=rig:FindFirstChild("Head")
	local torso=rig:FindFirstChild("UpperTorso") or rig:FindFirstChild("Torso")
	assert(head and torso,"Diner cast requires a humanoid head and torso")
	local clothes=Instance.new("Model"); clothes.Name="Original character wardrobe"; clothes.Parent=rig
	local function piece(body,name,size,offset,color,shape,material)
		if body==torso then
            local sx,sy,sz=body.Size.X/2,body.Size.Y/2,body.Size.Z
            size=V(size.X*sx,size.Y*sy,size.Z*sz)
            offset=CFrame.new(offset.Position.X*sx,offset.Position.Y*sy,offset.Position.Z*sz)*offset.Rotation
        end
        if body==head then
            -- Author in a 2 x 1 x 1 head space, then fit each actual R15 head.
            local sx,sy,sz=head.Size.X/2,head.Size.Y,head.Size.Z
            size=shape==Enum.PartType.Cylinder and V(size.X*sy,size.Y*sx,size.Z*sz) or V(size.X*sx,size.Y*sy,size.Z*sz)
            offset=CFrame.new(offset.Position.X*sx,offset.Position.Y*sy,offset.Position.Z*sz)*offset.Rotation
        end
        local p=Instance.new("Part"); p.Name,p.Size,p.Color=name,size,color; p.Material=material or Enum.Material.Fabric
		p.CanCollide,p.CanTouch,p.CanQuery,p.Massless=false,false,false,true
		p.CFrame=body.CFrame*offset; if shape then p.Shape=shape end; p.Parent=clothes
		local weld=Instance.new("WeldConstraint"); weld.Part0,weld.Part1,weld.Parent=body,p,p
		return p
	end
	for _,body in rig:GetChildren() do
		if body:IsA("BasePart") and body.Name~="HumanoidRootPart" then
			body.Color=(body.Name=="Head" or body.Name:find("Hand")) and person.Skin or ((body.Name:find("Leg") or body.Name:find("Foot")) and person.Pants or person.Shirt)
		end
	end
	-- The default description can contain BodyColors: keep it consistent with our palette.
	local bodyColors=rig:FindFirstChildOfClass("BodyColors")
	if bodyColors then bodyColors.HeadColor3=person.Skin; bodyColors.TorsoColor3=person.Shirt; bodyColors.LeftArmColor3=person.Shirt; bodyColors.RightArmColor3=person.Shirt; bodyColors.LeftLegColor3=person.Pants; bodyColors.RightLegColor3=person.Pants end
	local front=-torso.Size.Z/2-.025
	local boot=C(63,43,31)
	for _,side in {"Left","Right"} do
		local arm=rig:FindFirstChild(side.."LowerArm") or rig:FindFirstChild(side.." Arm")
		local leg=rig:FindFirstChild(side.."Foot") or rig:FindFirstChild(side.." Leg")
		if arm then
			piece(arm,"Exposed hand",V(arm.Size.X*1.01,.15,arm.Size.Z*1.01),CFrame.new(0,-arm.Size.Y*.44,0),person.Skin,nil,Enum.Material.SmoothPlastic)
			piece(arm,"Tailored shirt cuff",V(arm.Size.X*1.025,.15,arm.Size.Z*1.025),CFrame.new(0,-arm.Size.Y*.35,0),person.Shirt:Lerp(C(255,255,255),.13))
		end
		if leg then
			piece(leg,"Leather boot shaft",V(1.025,.42,1.025),CFrame.new(0,0,0),boot,nil,Enum.Material.Leather)
			piece(leg,"Rounded boot toe",V(1.03,.37,1.28),CFrame.new(0,-.1,-.14),boot,Enum.PartType.Ball,Enum.Material.Leather)
			piece(leg,"Boot welt",V(1.04,.07,1.21),CFrame.new(0,-leg.Size.Y*.5,-.08),C(104,77,45),nil,Enum.Material.Leather)
			piece(leg,"Boot heel",V(.85,.12,.4),CFrame.new(0,-leg.Size.Y*.5,.28),C(37,30,25))
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
	-- A continuous crown, rear panel and temples follow the head envelope.
	-- Small overlap hides seams; the forehead and face remain unobstructed.
	piece(head,"Fitted hair crown",V(2.06,.30,1.08),CFrame.new(0,.54,.015),person.Hair,Enum.PartType.Ball)
	piece(head,"Fitted rear hair",V(1.88,.55,.19),CFrame.new(0,.23,.48),person.Hair,Enum.PartType.Ball)
	for _,side in {-1,1} do
		piece(head,"Fitted temple hair",V(.23,.43,.77),CFrame.new(side*.91,.30,.11),person.Hair,Enum.PartType.Ball)
		piece(head,"Tapered sideburn",V(.12,.26,.19),CFrame.new(side*.94,.08,-.12),person.Hair,Enum.PartType.Ball)
	end
	if person.Style=="surveyor" then
		for _,side in {-1,1} do for i=1,5 do piece(torso,"Waistcoat pinstripe",V(.015,1.25,.012),CFrame.new(side*(.36+i*.105),-.1,front-.046),C(120,115,95)) end end
		piece(torso,"Narrow necktie",V(.13,.66,.08),CFrame.new(0,.4,front-.08),C(66,49,39))
		piece(head,"Felt hat brim",V(.10,2.55,1.85),CFrame.new(0,.67,0)*CFrame.Angles(0,0,math.pi/2),C(63,52,39),Enum.PartType.Cylinder)
		piece(head,"Pinched felt crown",V(1.65,.74,1.12),CFrame.new(0,.96,0),C(72,60,44),Enum.PartType.Ball)
		piece(head,"Hat ribbon",V(1.65,.12,1.12),CFrame.new(0,.77,0),C(34,30,25))
	elseif person.Style=="regular" or person.Style=="server" then
		piece(head,"Coiled hair bun",V(.60,.52,.48),CFrame.new(0,.28,.68),person.Hair,Enum.PartType.Ball)
		for i=1,4 do piece(head,"Swept hair wave",V(.55,.19,.29),CFrame.new(-.78+i*.31,.52,-.40)*CFrame.Angles(0,0,-.22),person.Hair,Enum.PartType.Ball) end
		for _,side in {-1,1} do piece(head,"Small brass earring",V(.09,.15,.07),CFrame.new(side*.91,-.2,0),C(202,160,71),Enum.PartType.Ball,Enum.Material.Metal) end
		if person.Style=="server" then
			piece(torso,"Ivory apron",V(1.32,1.07,.06),CFrame.new(0,-.53,front-.1),C(236,225,200))
			piece(torso,"Apron waistband",V(2.08,.13,1.08),CFrame.new(0,-.18,0),C(236,225,200))
			piece(torso,"Server name badge",V(.44,.18,.06),CFrame.new(-.55,.45,front-.1),C(230,215,168),nil,Enum.Material.Metal)
			piece(head,"Hair ribbon",V(.62,.12,.12),CFrame.new(0,.40,.86),C(111,158,146))
		end
	elseif person.Style=="officer" then
		piece(head,"Police cap band",V(2.03,.2,1.13),CFrame.new(0,.57,.02),C(25,32,43))
		piece(head,"Peaked police cap crown",V(2.12,.52,1.21),CFrame.new(0,.80,.02),C(39,50,63),Enum.PartType.Ball)
		piece(head,"Police cap visor",V(2.15,.10,.72),CFrame.new(0,.58,-.62),C(20,23,26),Enum.PartType.Ball,Enum.Material.Leather)
		piece(head,"Police cap brass badge",V(.20,.23,.055),CFrame.new(0,.79,-.59),C(192,161,78),nil,Enum.Material.Metal)
		piece(torso,"Uniform necktie",V(.13,.65,.07),CFrame.new(0,.4,front-.08),C(23,29,37))
	else
		piece(head,"Cook cap band",V(1.85,.21,1.15),CFrame.new(0,.56,0),C(238,231,209))
		piece(head,"Soft cook cap",V(1.92,.51,1.2),CFrame.new(0,.81,.08),C(238,231,209),Enum.PartType.Ball)
		piece(torso,"Cook apron",V(1.5,1.18,.08),CFrame.new(0,-.48,front-.13),C(215,207,183))
		for _,x in {-.3,.3} do for i=1,3 do piece(torso,"Double breasted button",V(.075,.075,.08),CFrame.new(x,.81-i*.18,front-.13),C(70,64,52),Enum.PartType.Ball) end end
	end
	return person.Name,makeFace(head,person,index)
end
return Cast
