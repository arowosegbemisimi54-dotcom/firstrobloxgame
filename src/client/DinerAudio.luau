-- Optional platform narration with subtitles always available. A single source
-- plays the news through the countertop radio.
local Audio={}
function Audio.create(parent,radio,dialogue)
 local folder=Instance.new("Folder"); folder.Name="Diner broadcast audio"; folder.Parent=parent
 local destroyed=false
 local voices={}
 local ambient={}
 local lastShot=0
 local lastClink=-1
 local strikes={}
 local function sound(where,name,speed,volume,loop)
  local s=Instance.new("Sound"); s.Name=name; s.SoundId="rbxasset://sounds/switch.wav"; s.PlaybackSpeed=speed; s.Volume=volume; s.Looped=loop or false; s.RollOffMinDistance=12; s.RollOffMaxDistance=110; s.Parent=where; return s
 end
 local stingers={}
 for _,source in {radio} do
  local tones={}; for _,pitch in {.8,1.25,1.7} do table.insert(tones,sound(source,"News stinger",pitch,.35)) end
  table.insert(stingers,tones)
 end
 local buzz=sound(radio,"Emergency signal buzz",.2,.10,true)
 local clink=sound(radio,"Diner silverware",2.7,.035)
 local function wire(source,target)
  local w=Instance.new("Wire"); w.SourceInstance=source; w.TargetInstance=target; w.Parent=folder
 end
 local function speech(text,voice,volume,targets,onReady)
  task.spawn(function()
   local ok,result=pcall(function()
    local source=Instance.new("AudioTextToSpeech"); source.Name="Diner spoken dialogue"; source.Text=text; source.VoiceId=voice; source.Volume=volume; source.Parent=folder
    for _,target in targets do wire(source,target) end
    source:LoadAsync()
    return source
   end)
   if destroyed then if ok and result then result:Destroy() end; return end
   if ok then onReady(result) end -- Missing platform access must never block the cutscene.
  end)
 end
 local ok=pcall(function()
  local emitters={}
  for _,position in {radio} do
   local emitter=Instance.new("AudioEmitter"); emitter.PositionInstance=position; emitter.AudioInteractionGroup="DinerOpening"; emitter.Parent=folder
   emitter:SetDistanceAttenuation({[0]=1,[60]=.8,[120]=0}); table.insert(emitters,emitter)
  end
  local listener=Instance.new("AudioListener"); listener.PositionInstance=workspace.CurrentCamera; listener.AudioInteractionGroup="DinerOpening"; listener.Parent=folder
  local output=Instance.new("AudioDeviceOutput"); output.Player=game:GetService("Players").LocalPlayer; output.Parent=folder; wire(listener,output)
  for shot,text in dialogue do speech(text,"1",.55,emitters,function(source) voices[shot]=source end) end
  speech("Could you pass the fries?", "2",.09,emitters,function(source) table.insert(ambient,source) end)
  speech("This coffee is good.", "3",.07,emitters,function(source) table.insert(ambient,source) end)
 end)
 local activeVoice
 return {
  update=function(shot,time)
   if destroyed then return end
   if shot~=lastShot then
    if activeVoice then activeVoice:Pause(); activeVoice=nil end
    for _,voice in ambient do voice:Pause() end
    strikes={}; buzz:Stop()
    if shot==7 then buzz:Play() end
    lastShot=shot
   end
   if shot<3 then
    local tick=math.floor(time/1.4)
    if tick~=lastClink then lastClink=tick; clink:Play() end
    if time>.3 and not strikes.ambient and #ambient>0 then strikes.ambient=true; ambient[(shot-1)%#ambient+1]:Play() end
   elseif shot==3 then
    for index=1,3 do if time>=(index-1)*.15 and not strikes[index] then
     strikes[index]=true; for _,tones in stingers do tones[index]:Play() end
    end end
   end
   if shot>=3 and shot<=6 and not activeVoice and voices[shot] then
    activeVoice=voices[shot]
    -- A late load joins the current line instead of starting stale dialogue.
    activeVoice.TimePosition=math.min(time,math.max(0,activeVoice.TimeLength-.1)); activeVoice:Play()
   end
  end,
  available=function() return ok end,
  destroy=function()
   destroyed=true
   for _,source in voices do source:Pause() end
   for _,source in ambient do source:Pause() end
   for _,tones in stingers do for _,tone in tones do tone:Destroy() end end
   buzz:Destroy(); clink:Destroy(); folder:Destroy()
  end,
 }
end
return Audio
