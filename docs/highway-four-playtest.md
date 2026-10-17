# Highway Four chapter playtest

The radio opening now continues into the new chapter and has no skip controls,
as requested in Part 2. Existing menus, wardrobe selection and menu traffic are
unchanged. This remains the existing client-local story scene: party members
receive their own chapter, not a replicated shared driving session. No rewards
or persistent mission progress are granted by the local controller.

## Flow

1. Start Story / Play and let the radio opening finish.
2. Press E, controller X, or the mobile Pay button at the booth. Payment takes
   one second; the character then stands and moves into the aisle.
3. Walk down the aisle and through the glass front door. WASD/left stick moves;
   right mouse drag/right stick looks. V/right-stick click switches first-person
   and shoulder view. Touch players have directional buttons and drag-to-look.
4. The exterior sequence locks movement: damaged pickup arrival, panel van
   reveal, four masked crew, 1.5-second boarding, police, escape, banknote and
   title drop. Reduced Motion removes camera shake and speed-based FOV changes.
5. Drive west along Highway Four. WASD, left stick or RT accelerates; S reverses;
   Space/LT brakes. Right mouse drag, touch drag or the right stick rotates the camera; the mouse wheel zooms. V/right-stick click toggles the detailed cabin view with live patrol mirrors. Touch controls are provided. Gain 150 studs on the patrol
   for four seconds, then turn into OLD MOTOR DEPOT at the end of the route.
   Stop in its driveway to finish. Being stopped near patrol for four seconds
   gives an interception screen with a retry action.

The opening retains noon lighting. The new exterior sequence shifts to sunset
following the Part 2 notes. The black panel van uses the supplied vintage van as
inspiration, replacing the generic secondary car mentioned in the screenshot.

## Audio and validation limits

EscapeAudio.assets exposes engine, siren, skid, bell, door, bass and wind slots.
Engine/siren/skid/wind are intentionally empty until permitted experience-owned
Roblox audio IDs are supplied. Bell/door/title have built-in placeholder cues.
Dialogue uses optional Roblox AudioTextToSpeech, preloaded during scene loading,
with captions always available. Platform TTS permissions and timing need Studio
validation; these are not recorded actor performances.

Automated checks cover chapter timing, payment gating, doorway/road boundaries,
mission completion/interception, R15 runtime paths and cleanup. Rojo builds and
Luau compilation are also checked. The headless service doubles cannot validate
rendered camera composition, accessory alignment, touch layout or sound mixing.
Playtest those in Studio on desktop and a mobile viewport before publishing.
The R15 gait advances with distance and flexes knees, ankles, elbows and waist.
Crew members have separate boarding paths, bags and seats. Officers use a running
pose followed by a two-handed aim. The vehicle has a continuous roof, cabin,
steering wheel, speedometer and animated wheels. Mirrors render a limited set of
road/patrol copies at 12 Hz; they are rear-view displays, not full-world reflections.
The route includes dunes, sandstone shoulders, sagging telegraph wires, cacti,
and a timber stash house with a porch, water tank and rotating wind pump.
These are authored primitive models and kinematic driving, not final imported
vehicle meshes or a full tire/suspension physics simulation.

## Audio revision

Dispatcher/crew/server use different platform TTS voices and delivery rates;
dispatch adds equalization/compression. Quiet diner chatter and low static remain
under the news and hush when the emergency signal begins. Original procedural
WAVs and their generator are in assets/audio; upload those to Roblox and configure
DinerAudio.assets to replace the platform fallbacks. TTS is still synthetic,
not an original actor performance. EscapeAudio.recordings supports later licensed
or original recordings. No audio from the reference videos is included.

## Reference access

Both TikTok URLs and the YouTube Short supplied on 2026-10-17 were blocked by the
execution environment's HTTP proxy (403). Their contents were not viewed. The
changes above use the user's written notes and supplied screenshots; video-specific
handling adjustments await accessible clips.


### NPC hair, R15 pose and patrol follow-up

- Scene characters now solve their R15 joint tree and attached garments after
  each rendered model move. This includes reversed accessory welds. Scene parts
  are anchored and joints disabled so physics does not overwrite the authored
  walk, run, seated and aiming poses. Live player rigs are not modified by this
  scene-only solver.
- Hair crown, temples, rear panel, bun and headwear fit each NPC head's dimensions.
- Patrol arrival follows two tangent quarter-circle turns with distance-based
  wheel rotation, front wheel steering and final braking. Drivers stay seated
  until stopping, open their doors, step out and approach on foot. Pursuit uses
  bounded steering and forward motion instead of direct diagonal translation.
- Studio checks still required: inspect all diner customers and workers from
  front/side/rear; observe crew and player knees/boots over several strides;
  watch both cruisers turn and stop, then both officers exit and approach. Check
  garments and facial features follow joints throughout, including at low FPS.
  Automated tests cover transforms and path continuity, not final visual quality.
