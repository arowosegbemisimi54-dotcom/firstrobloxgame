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
   Space/LT brakes. Touch controls are provided. Gain 150 studs on the patrol
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
mission completion/interception, R6 runtime paths and cleanup. Rojo builds and
Luau compilation are also checked. The headless service doubles cannot validate
rendered camera composition, accessory alignment, touch layout or sound mixing.
Playtest those in Studio on desktop and a mobile viewport before publishing.
The authored primitive models and kinematic driving are a playable first pass,
not a finished vehicle physics simulation or final cinematic art pass.
