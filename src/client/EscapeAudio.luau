-- Sound cue slots accept experience-owned assets. Dialogue has subtitle fallback.
local Audio={}
-- Populate these with permitted audio assets in Studio for final Foley mixing.
Audio.assets={engine="",siren="",skid="",bell="",door="",bass="",wind=""}
-- Experience-owned recordings can replace synthesis without changing the scene.
Audio.recordings={waitress="",unload="",board="",warning="",police=""}
local delivery={
 waitress={voice="2",speed=.98,volume=.55},
 unload={voice="3",speed=1.05,volume=.63},
 board={voice="1",speed=1.06,volume=.57},
 warning={voice="5",speed=1.04,volume=.61},
 police={voice="4",speed=.98,volume=.57},
}
function Audio.create(parent,lines)
 local folder=Instance.new("Folder"); folder.Name="Escape sound stage"; folder.Parent=parent
 local sources,voices={},{}
 local destroyed=false
 local output=Instance.new("AudioDeviceOutput"); output.Player=game:GetService("Players").LocalPlayer; output.Parent=folder
 local current
 local recordings={}
 local requested
 for name,text in lines do
  local recording=Audio.recordings[name]
  if recording and recording~="" then
   local sound=Instance.new("Sound"); sound.Name="Original dialogue "..name; sound.SoundId=recording; sound.Volume=.65; sound.Parent=folder; recordings[name]=sound
  else task.spawn(function()
  local source
  local ok=pcall(function()
   local spec=delivery[name] or delivery.unload
   source=Instance.new("AudioTextToSpeech"); source.Name=name
   source.Text=text:gsub("MOVE!", "Move!"):gsub("NOW!", "Now!"):gsub("SUSPECTS ARE FOOT%-BAIL, WE HAVE LOST VISUAL!", "Suspects are foot-bail. We have lost visual!")
   source.VoiceId=spec.voice; source.Speed=spec.speed; source.Volume=spec.volume; source.Parent=folder
   local function wire(from,to) local w=Instance.new("Wire"); w.SourceInstance=from; w.TargetInstance=to; w.Parent=folder end
   if name=="police" then
    local filter=Instance.new("AudioEqualizer"); filter.LowGain=-12; filter.MidGain=1.5; filter.HighGain=-8; filter.Parent=folder
    local compressor=Instance.new("AudioCompressor"); compressor.Threshold=-20; compressor.Ratio=2.5; compressor.Attack=.015; compressor.Release=.15; compressor.Parent=folder
    wire(source,filter); wire(filter,compressor); wire(compressor,output)
   else wire(source,output) end
   source:LoadAsync()
  end)
  if destroyed or not ok then if source then source:Destroy() end else voices[name]=source; if requested==name then current=source; source:Play() end end
 end) end end
 for name,id in Audio.assets do
  if id~="" then
   local s=Instance.new("Sound"); s.Name=name; s.SoundId=id; s.Volume=name=="engine" and .25 or .45; s.Looped=name=="engine" or name=="siren" or name=="wind"; s.Parent=folder; sources[name]=s
  end
 end
 -- Built-in UI/impact cues remain audible without external asset permissions.
 for name,spec in {step={"action_footsteps_plastic.mp3",.88,.12},bell={"electronicpingshort.wav",1.7,.2},door={"switch.wav",.65,.25},bass={"impact_generic.mp3",.5,.5}} do
  if not sources[name] then local s=Instance.new("Sound"); s.Name=name; s.SoundId="rbxasset://sounds/"..spec[1]; s.PlaybackSpeed=spec[2]; s.Volume=spec[3]; s.Parent=folder; sources[name]=s end
 end
 return {
  say=function(name) requested=name; if current then current:Pause() end; current=recordings[name] or voices[name]; if current then current.TimePosition=0; current:Play() end end,
  cue=function(name) if sources[name] then sources[name]:Play() end end,
  stop=function(name) if sources[name] then sources[name]:Stop() end end,
  engine=function(speed) if sources.engine then sources.engine.PlaybackSpeed=.65+math.abs(speed)/85 end end,
  destroy=function() if destroyed then return end; destroyed=true; for _,v in voices do v:Pause() end; for _,v in recordings do v:Stop() end; folder:Destroy() end,
 }
end
return Audio
