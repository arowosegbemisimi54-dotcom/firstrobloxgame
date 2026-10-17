-- Original procedural starter clothing. The same geometry is used on the player,
-- the live wardrobe preview, and the item cards, without external asset IDs.
local Outfit = {}
local denim=Color3.fromRGB(57,68,76)
local leather=Color3.fromRGB(100,62,36)
local function piece(parent,body,name,size,offset,color,shape,material)
	local p=Instance.new("Part")
	p.Name,p.Size,p.Color=name,size,color
	p.Material=material or Enum.Material.Fabric
	p.CanCollide,p.CanTouch,p.CanQuery,p.Massless=false,false,false,true
	p.CFrame=body.CFrame*offset
	if shape then p.Shape=shape end
	p.Parent=parent
	local weld=Instance.new("WeldConstraint")
	weld.Part0,weld.Part1,weld.Parent=body,p,p
	return p
end
-- The brim overlaps the top of the head; the crown is a cattleman crease,
-- with raised side ridges and curled brim edges instead of a round dome.
function Outfit.addHat(parent,head,hat)
	local y=head.Size.Y*.40
	local width=head.Size.X*.82
	local depth=head.Size.Z*1.12
	piece(parent,head,"Shaped cowboy brim",Vector3.new(.09,head.Size.X*1.38,head.Size.Z*1.95),CFrame.new(0,y,-.035)*CFrame.Angles(0,0,math.pi/2),hat,Enum.PartType.Cylinder)
	piece(parent,head,"Cattleman crown base",Vector3.new(.42,width,depth),CFrame.new(0,y+.23,0)*CFrame.Angles(0,0,math.pi/2),hat,Enum.PartType.Cylinder)
	for _,side in {-1,1} do
		piece(parent,head,"Cattleman crown ridge",Vector3.new(width*.40,.30,depth*.87),CFrame.new(side*width*.23,y+.48,0),hat,Enum.PartType.Ball)
		piece(parent,head,"Curled western brim",Vector3.new(.45,.10,head.Size.Z*1.45),CFrame.new(side*head.Size.X*.59,y+.09,-.035)*CFrame.Angles(0,0,side*.35),hat)
	end
	piece(parent,head,"Recessed crown crease",Vector3.new(width*.18,.065,depth*.66),CFrame.new(0,y+.45,0),hat:Lerp(Color3.new(),.16))
	piece(parent,head,"Leather hat band",Vector3.new(.12,width*1.015,depth*1.015),CFrame.new(0,y+.10,0)*CFrame.Angles(0,0,math.pi/2),leather,Enum.PartType.Cylinder,Enum.Material.Leather)
	piece(parent,head,"Hat band brass clasp",Vector3.new(.13,.10,.06),CFrame.new(-width*.28,y+.10,-depth*.48),Color3.fromRGB(179,143,78),nil,Enum.Material.Metal)
end
function Outfit.apply(character,profile)
	local previous=character:FindFirstChild("WesternWardrobe")
	if previous then previous:Destroy() end
	for _,child in character:GetChildren() do
		if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then child:Destroy() end
	end
	local folder=Instance.new("Model")
	folder.Name,folder.Parent="WesternWardrobe",character
	local girl=profile.gender=="Girl"
	local shirt=girl and Color3.fromRGB(147,111,88) or Color3.fromRGB(134,133,104)
	local skin=character:FindFirstChild("Head") and character.Head.Color or Color3.fromRGB(203,163,122)
	local torso=character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not torso then folder:Destroy(); return end
	local outfit=profile.outfit
	for _,name in {"UpperTorso","LowerTorso","Torso","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","Left Arm","Right Arm"} do
		local body=character:FindFirstChild(name)
		if body then body.Color=shirt end
	end
	for _,name in {"LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","Left Leg","Right Leg"} do
		local body=character:FindFirstChild(name)
		if body then body.Color=denim end
	end
	for _,name in {"LeftFoot","RightFoot"} do
		local foot=character:FindFirstChild(name)
		if foot then foot.Color=leather end
	end
	for _,side in {"Left","Right"} do
		local arm=character:FindFirstChild(side.." Arm")
		if arm then
			piece(folder,arm,"Visible hand",Vector3.new(arm.Size.X*1.01,.32,arm.Size.Z*1.01),CFrame.new(0,-arm.Size.Y*.42,0),skin,nil,Enum.Material.SmoothPlastic)
			piece(folder,arm,"Rolled shirt cuff",Vector3.new(arm.Size.X*1.035,.15,arm.Size.Z*1.035),CFrame.new(0,-arm.Size.Y*.3,0),shirt:Lerp(Color3.new(1,1,1),.14))
		end
	end
	local front=-torso.Size.Z/2-.035
	piece(folder,torso,"Button placket",Vector3.new(.13,torso.Size.Y*.84,.07),CFrame.new(girl and .10 or 0,0,front),shirt:Lerp(Color3.new(),.18))
	for i=1,4 do
		piece(folder,torso,"Shirt button",Vector3.new(.065,.065,.06),CFrame.new(girl and .1 or 0,torso.Size.Y*(.43-i*.17),front-.05),Color3.fromRGB(68,52,39),Enum.PartType.Ball)
	end
	for _,side in {-1,1} do
		piece(folder,torso,"Open collar",Vector3.new(.38,.23,.08),CFrame.new(side*.22,torso.Size.Y*.37,front)*CFrame.Angles(0,0,side*.32),shirt:Lerp(Color3.new(1,1,1),.12))
		piece(folder,torso,"Pocket stitched edge",Vector3.new(.39,.025,.08),CFrame.new(side*.55,torso.Size.Y*.12+.15,front-.015),shirt:Lerp(Color3.new(1,1,1),.26))
		piece(folder,torso,"Worn pocket",Vector3.new(.38,.32,.065),CFrame.new(side*.55,torso.Size.Y*.12,front),shirt:Lerp(Color3.new(),.08))
	end
	local waist=character:FindFirstChild("LowerTorso") or torso
	piece(folder,waist,"Untucked ragged hem",Vector3.new(waist.Size.X*1.025,.25,waist.Size.Z*1.04),CFrame.new(0,-waist.Size.Y*.35,0)*CFrame.Angles(0,0,girl and .055 or -.07),shirt)
	for _,side in {"Left","Right"} do
		local leg=character:FindFirstChild(side.."LowerLeg") or character:FindFirstChild(side.." Leg")
		if leg then
			local z=-leg.Size.Z/2-.015
			local y=girl and .18 or -.05
			piece(folder,leg,"Torn denim opening",Vector3.new(leg.Size.X*.5,.13,.025),CFrame.new(0,y,z),skin)
			for i=1,3 do
				piece(folder,leg,"Frayed denim thread",Vector3.new(leg.Size.X*.62,.018,.03),CFrame.new(0,y-.07+i*.035,z-.018)*CFrame.Angles(0,0,(i-2)*.08),Color3.fromRGB(151,155,142))
			end
			if girl then piece(folder,leg,"Faded denim patch",Vector3.new(leg.Size.X*.36,.25,.03),CFrame.new(.13,-.2,z),Color3.fromRGB(90,102,109)) end
		end
		local foot=character:FindFirstChild(side.."Foot") or leg
		if foot then
			local bootY=character:FindFirstChild(side.."Foot") and 0 or -foot.Size.Y*.38
			piece(folder,foot,"Western boot",Vector3.new(foot.Size.X*1.025,.44,foot.Size.Z*1.035),CFrame.new(0,bootY-.04,-.03),leather,nil,Enum.Material.Leather)
			piece(folder,foot,"Rounded leather toe",Vector3.new(foot.Size.X*1.035,.35,foot.Size.Z*.8),CFrame.new(0,bootY-.13,-foot.Size.Z*.4),leather,Enum.PartType.Ball,Enum.Material.Leather)
			piece(folder,foot,"Boot stitched welt",Vector3.new(foot.Size.X*1.06,.045,foot.Size.Z*1.2),CFrame.new(0,bootY-.25,-.08),Color3.fromRGB(150,111,64),nil,Enum.Material.Leather)
			piece(folder,foot,"Stacked boot heel",Vector3.new(foot.Size.X*.86,.14,foot.Size.Z*.4),CFrame.new(0,bootY-.4,foot.Size.Z*.29),Color3.fromRGB(48,37,28),nil,Enum.Material.Leather)
			piece(folder,foot,"Boot sole",Vector3.new(foot.Size.X*1.12,.1,foot.Size.Z*1.16),CFrame.new(0,bootY-.3,-.03),Color3.fromRGB(48,37,28),nil,Enum.Material.Rubber)
		end
	end
	local head=character:FindFirstChild("Head")
	if head and outfit.Hat=="cowboy" then
		local hat=girl and Color3.fromRGB(112,77,49) or Color3.fromRGB(149,115,70)
		Outfit.addHat(folder,head,hat)
	end

end
function Outfit.dog()
	local model=Instance.new("Model")
	model.Name="Locked dog preview"
	local body=Instance.new("Part")
	body.Name,body.Size,body.Color,body.Anchored= "Body",Vector3.new(1,1,2),Color3.fromRGB(120,83,48),true
	body.CFrame=CFrame.new(0,1.1,0); body.Parent=model
	piece(model,body,"Head",Vector3.new(.9,.9,.9),CFrame.new(0,.55,-1),body.Color,Enum.PartType.Ball)
	piece(model,body,"Muzzle",Vector3.new(.55,.4,.65),CFrame.new(0,.35,-1.5),Color3.fromRGB(53,39,28))
	for _,x in {-.3,.3} do
		piece(model,body,"Ear",Vector3.new(.25,.7,.3),CFrame.new(x,.85,-1),Color3.fromRGB(53,39,28))
		for _,z in {-.65,.65} do piece(model,body,"Leg",Vector3.new(.25,.85,.3),CFrame.new(x,-.75,z),body.Color) end
	end
	piece(model,body,"Tail",Vector3.new(.18,1,.2),CFrame.new(0,.35,1.1)*CFrame.Angles(.8,0,0),body.Color)
	return model
end
return Outfit
