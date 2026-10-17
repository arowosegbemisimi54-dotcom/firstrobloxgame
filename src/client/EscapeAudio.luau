-- Sound cue slots accept experience-owned assets. Dialogue has subtitle fallback.
local Audio={}
-- Populate these with permitted audio assets in Studio for final Foley mixing.
Audio.assets={engine="",siren="",skid="",bell="",door="",bass="",wind=""}
function Audio.create(parent,lines)
 local folder=Instance.new("Folder"); folder.Name="Escape sound stage"; folder.Parent=parent
 local sources,voices={},{}
 local destroyed=false
 local output=Instance.new("AudioDeviceOutput"); output.Player=game:GetService("Players").LocalPlayer; output.Parent=folder
 local current
 local requested
 for name,text in lines do task.spawn(function()
  local source
  local ok=pcall(function()
   source=Instance.new("AudioTextToSpeech"); source.Name=name; source.Text=text; source.VoiceId=name=="waitress" and "2" or "1"; source.Volume=.6; source.Parent=folder
   local wire=Instance.new("Wire"); wire.SourceInstance=source; wire.TargetInstance=output; wire.Parent=folder
   source:LoadAsync()
  end)
  if destroyed or not ok then if source then source:Destroy() end else voices[name]=source; if requested==name then current=source; source:Play() end end
 end) end
 for name,id in Audio.assets do
  if id~="" then
   local s=Instance.new("Sound"); s.Name=name; s.SoundId=id; s.Volume=name=="engine" and .25 or .45; s.Looped=name=="engine" or name=="siren" or name=="wind"; s.Parent=folder; sources[name]=s
  end
 end
 -- Built-in UI/impact cues remain audible without external asset permissions.
 for name,spec in {bell={"electronicpingshort.wav",1.7,.2},door={"switch.wav",.65,.25},bass={"impact_generic.mp3",.5,.5}} do
  if not sources[name] then local s=Instance.new("Sound"); s.Name=name; s.SoundId="rbxasset://sounds/"..spec[1]; s.PlaybackSpeed=spec[2]; s.Volume=spec[3]; s.Parent=folder; sources[name]=s end
 end
 return {
  say=function(name) requested=name; if current then current:Pause() end; current=voices[name]; if current then current.TimePosition=0; current:Play() end end,
  cue=function(name) if sources[name] then sources[name]:Play() end end,
  stop=function(name) if sources[name] then sources[name]:Stop() end end,
  engine=function(speed) if sources.engine then sources.engine.PlaybackSpeed=.65+math.abs(speed)/85 end end,
  destroy=function() if destroyed then return end; destroyed=true; for _,v in voices do v:Pause() end; folder:Destroy() end,
 }
end
return Audio
