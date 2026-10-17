local Audio=require(script.Parent.DinerAudio)
local Broadcast={}
function Broadcast.create(parent,origin,dialogue)
 local V=Vector3.new
 local C=Color3.fromRGB
 local model=Instance.new("Model"); model.Name="Blox News CRT and radio"; model.Parent=parent
 local tv=CFrame.new(origin+V(7,9.1,-12))*CFrame.Angles(0,math.pi/2,0)*CFrame.Angles(-.18,0,0)
 local function part(name,size,cf,color,where)
  local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Parent=where or model; return p
 end
 part("CRT ceiling bracket",V(.16,3.6,.16),CFrame.new(origin+V(7,12.6,-12)),C(51,49,46))
 part("Old CRT cabinet",V(5.4,3.9,3),tv,C(48,43,37))
 part("CRT lower speaker grille",V(4.5,.28,.1),tv*CFrame.new(0,-1.65,-1.53),C(26,26,24))
 for x=-2,2,.22 do part("Speaker slot",V(.055,.19,.025),tv*CFrame.new(x,-1.65,-1.59),C(84,80,68)) end
 local screen=part("CRT glass screen",V(4.7,2.9,.12),tv*CFrame.new(0,.12,-1.54),C(70,119,174)); screen.Material=Enum.Material.Neon
 local glow=Instance.new("SurfaceLight"); glow.Face=Enum.NormalId.Front; glow.Color=C(132,179,255); glow.Brightness=.5; glow.Range=15; glow.Parent=screen
 local radio=part("Diner countertop radio",V(2.5,1.3,1.2),CFrame.new(origin+V(16,4.1,-15)),C(101,68,43))
 part("Radio fabric grille",V(1.6,.8,.06),radio.CFrame*CFrame.new(-.25,0,-.64),C(56,48,36))
 for _,y in {-.25,.25} do local knob=part("Radio tuning knob",V(.22,.22,.12),radio.CFrame*CFrame.new(.9,y,-.65),C(203,181,129)); knob.Shape=Enum.PartType.Ball end
 local surface=Instance.new("SurfaceGui"); surface.Name="Blox News Live"; surface.Face=Enum.NormalId.Front; surface.CanvasSize=Vector2.new(960,600); surface.LightInfluence=0; surface.Parent=screen
 local function ui(kind,props,where)
  local p=Instance.new(kind); for k,v in props do p[k]=v end; p.Parent=where or surface; return p
 end
 local function label(text,pos,size,color,bg)
  return ui("TextLabel",{Text=text,Position=pos,Size=size,TextColor3=color,BackgroundColor3=bg or C(15,35,70),BackgroundTransparency=bg and 0 or 1,BorderSizePixel=0,Font=Enum.Font.GothamBold,TextScaled=true})
 end
 local backdrop=ui("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=C(15,35,70),BorderSizePixel=0})
 local viewport=ui("ViewportFrame",{Position=UDim2.fromScale(0,.12),Size=UDim2.fromScale(1,.71),BackgroundTransparency=1,Ambient=C(180,188,211),LightColor=C(255,245,220),LightDirection=V(-1,-1,-2)})
 local world=Instance.new("WorldModel"); world.Parent=viewport
 local camera=Instance.new("Camera"); camera.FieldOfView=38; camera.CFrame=CFrame.lookAt(V(0,3,-16),V(0,2.2,0)); camera.Parent=viewport; viewport.CurrentCamera=camera
 local studio=Instance.new("Model"); studio.Name="Broadcast studio set"; studio.Parent=world
 part("Blue news studio",V(16,9,.2),CFrame.new(0,3,2),C(18,58,128),studio)
 for _,x in {-6,6} do part("Red studio light column",V(.4,8,.3),CFrame.new(x,3,1.5),C(190,31,49),studio) end
 local anchor=Instance.new("Model"); anchor.Name="Bob Blockman R6 broadcast actor"; anchor.Parent=world
 part("Suit torso",V(2,2,1),CFrame.new(-2,2.2,0),C(35,43,59),anchor)
 part("White shirt",V(.5,1.3,.04),CFrame.new(-2,2.4,-.53),C(235,235,219),anchor)
 part("Red tie",V(.16,.9,.05),CFrame.new(-2,2.25,-.57),C(159,35,43),anchor)
 local head=part("Anchor head",V(1.5,1.2,1),CFrame.new(-2,3.8,0),C(197,149,108),anchor)
 part("Anchor swept hair",V(1.55,.25,1.02),CFrame.new(-2,4.4,.02),C(49,39,33),anchor)
 for _,x in {-2.3,-1.7} do part("Anchor eye",V(.08,.12,.025),CFrame.new(x,3.9,-.52),C(29,29,27),anchor) end
 local mouth=part("Speaking anchor mouth",V(.25,.06,.025),CFrame.new(-2,3.55,-.52),C(79,39,30),anchor)
 part("Headset earpiece",V(.18,.4,.38),CFrame.new(-2.83,3.8,0),C(27,28,30),anchor)
 part("Headset microphone",V(.6,.055,.06),CFrame.new(-2.5,3.57,-.62),C(27,28,30),anchor)
 local arms={}
 for _,side in {-1,1} do
  local arm=part("R6 suit arm",V(.75,1.8,.8),CFrame.new(-2+side*1.35,2.2,0),C(35,43,59),anchor); table.insert(arms,{part=arm,side=side})
  part("Suit trouser leg",V(.85,1.8,.85),CFrame.new(-2+side*.5,.3,0),C(31,37,49),anchor)
 end
 part("Highway digital map",V(5.5,4,.1),CFrame.new(3,2.6,1.65),C(26,89,104),studio)
 for i=1,8 do part("Map highway route",V(.24,.85,.05),CFrame.new(2.1+math.sin(i*.7)*1.1,.7+i*.42,1.55)*CFrame.Angles(0,0,.25),C(242,194,75),studio) end
 local truck=Instance.new("Model"); truck.Name="Eyewitness getaway truck"; truck.WorldPivot=CFrame.new(); truck.Parent=nil
 part("Getaway truck body",V(5,1.6,2.2),CFrame.new(0,1.4,0),C(58,67,57),truck)
 part("Truck cabin",V(2.2,1.4,2.1),CFrame.new(-.4,2.7,0),C(48,57,49),truck)
 part("Truck window",V(1.65,.85,.04),CFrame.new(-.4,2.8,-1.07),C(115,141,143),truck)
 for _,x in {-1.6,1.6} do local tire=part("Truck tire",V(1.1,1.1,.45),CFrame.new(x,.7,-1.05),C(25,24,22),truck); tire.Shape=Enum.PartType.Ball end

 local footage=Instance.new("Model"); footage.Name="Highway eyewitness location"
 part("Eyewitness road",V(30,.1,20),CFrame.new(0,0,0),C(76,71,63),footage)
 part("Eyewitness desert horizon",V(40,12,.3),CFrame.new(0,5,6),C(175,143,103),footage)
 for i=1,5 do part("Eyewitness distant ridge",V(7,4+i%3,.5),CFrame.new(-16+i*5,3,5)*CFrame.Angles(0,0,math.sin(i)*.22),C(140,112,88),footage) end
 for x=-12,12,5 do part("Eyewitness road marking",V(2,.03,.12),CFrame.new(x,.08,-1),C(224,196,129),footage) end
 local headline=label("COLD SODA • GOOD TIMES",UDim2.fromScale(.03,.02),UDim2.fromScale(.94,.09),C(255,242,213))
 local ticker=label("",UDim2.fromScale(0,.84),UDim2.fromScale(1,.16),C(255,255,255),C(183,26,41))
 local mapLabel=label("HIGHWAY 4  •  WESTBOUND",UDim2.fromScale(.54,.2),UDim2.fromScale(.43,.1),C(250,222,126)); mapLabel.Visible=false
 local ad=label("DUST TRAIL\nSODA\nICE COLD",UDim2.fromScale(.12,.18),UDim2.fromScale(.76,.6),C(255,237,182),C(26,109,117))
 local emergency=label("EMERGENCY\nBROADCAST SIGNAL",UDim2.fromScale(.03,.17),UDim2.fromScale(.94,.6),C(255,255,255),C(35,35,35)); emergency.Visible=false
 local flash=label("BLOX NEWS FLASH",UDim2.fromScale(.08,.35),UDim2.fromScale(.84,.25),C(255,255,255),C(178,26,45)); flash.Visible=false
 local noise={}
 for i=1,18 do table.insert(noise,ui("Frame",{Position=UDim2.fromScale(0,i/20),Size=UDim2.fromScale(1,.008),BackgroundColor3=C(200,201,195),BackgroundTransparency=.8,BorderSizePixel=0,Visible=false})) end
 local audio=Audio.create(model,screen,radio,dialogue)
 local destroyed=false
 local function update(shot,time,reduced)
  if destroyed then return end
  local news=shot>=3
  ad.Visible=not news; viewport.Visible=news and shot<7; mapLabel.Visible=news and shot~=4 and shot<7
  emergency.Visible=shot>=7 and time>=.4
  flash.Visible=shot==3 and time<.8
  headline.Text=shot<3 and "DUST TRAIL SODA" or (shot==7 and "BLOX NEWS • SIGNAL INTERRUPTED" or "BLOX NEWS LIVE • BOB BLOCKMAN")
  ticker.Text=shot>=6 and "SUSPECTS ARMED & DANGEROUS    •    STAY INSIDE    •    " or (news and "BREAKING NEWS    •    DOWNTOWN BANK HEIST    •    " or "REFRESH YOUR AFTERNOON")
  ticker.Position=UDim2.fromScale(reduced and 0 or -(time*.06% .35),.84); ticker.Size=UDim2.fromScale(1.4,.16)
  local eyewitness=shot==4 and time>10
  anchor.Parent=eyewitness and nil or world; truck.Parent=eyewitness and world or nil
  studio.Parent=eyewitness and nil or world; footage.Parent=eyewitness and world or nil
  if eyewitness then headline.Text="BLOX NEWS LIVE • EYEWITNESS FOOTAGE" end
  for index,strip in noise do
   strip.Visible=eyewitness or shot==7
   strip.BackgroundTransparency=eyewitness and .88 or .35
   strip.Position=UDim2.fromScale(0,((index*17+(reduced and 0 or math.floor(time*12)*7))%100)/100)
  end
  if eyewitness then truck:PivotTo(CFrame.new(4-(time*1.8%8),0,0)*CFrame.Angles(0,math.sin(time*4)*.025,0)) end
  if not reduced then
   mouth.Size=V(.25,news and (.05+math.abs(math.sin(time*12))*.13) or .05,.025)
   for _,arm in arms do arm.part.CFrame=CFrame.new(-2+arm.side*1.35,2.2,0)*CFrame.Angles(0,0,arm.side*(.10+math.sin(time*1.7)*.1)) end
  end
  if shot==7 then emergency.BackgroundColor3=(math.floor(time*8)%2==0 and C(35,35,35) or C(67,67,67)) end
  audio.update(shot,time)
 end
 -- Playback starts when the diner camera takes control.
 return {update=update,tv=screen,radio=radio,head=head,destroy=function() destroyed=true; audio.destroy(); anchor:Destroy(); truck:Destroy(); studio:Destroy(); footage:Destroy(); model:Destroy() end}
end
return Broadcast
