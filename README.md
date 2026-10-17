# Shirts and Skins

An original cinematic Roblox crime-adventure project by **MHIDE**. This build implements character creation, the opening, the Story Mode menu, and a starter wardrobe. Missions and combat are not implemented yet.

## Run in Roblox Studio

1. In GitHub Desktop, select `firstrobloxgame`, click **Fetch origin**, then **Pull origin**.
2. If Rojo is already serving this repository, it watches the updated files automatically. Otherwise open PowerShell in the repository folder and run (adjust the executable path if needed):
   ```powershell
   & "$env:USERPROFILE\Downloads\rojo-7.7.1-windows-x86_64\rojo.exe" serve
   ```
3. In Studio, open the saved game and connect **Plugins → Rojo** to `localhost:34872`. Review the initial sync. The project maps only `GameServer`, `GameShared`, and `GameClient`; it does not map your Workspace, terrain, or saved lighting.
4. Click **Play**, not Run. Local scripts and the interface need a player. Stop and restart Play after script changes to avoid duplicate menus from live editing.
5. Choose a character name, Boy/Girl, and personality. Then the black opening shows **Story Mode**, followed by **Online**, with clicks. Choose Story Mode to see a five-second counter-clockwise camera orbit before the menu fades in.
6. Test before publishing. GitHub pulls and Rojo syncs do not publish a live Roblox game.

Keep PowerShell open during sync. Edit synced scripts in the repository, not inside Studio; Rojo can overwrite Studio edits to mapped objects. The root configuration uses UTF-8 without a BOM.

## Included

- Character creation: 2–24 character name (duplicates allowed), Boy/Girl, and Friendly/Serious/Mysterious/Funny personality. Names are filtered on the server.
- Side-by-side, staggered opening choices on black, one second after character creation finishes.
- Client-only desert set: one camper, extended awning, tent, table, rounded cacti, continuous triangulated sandstone ridges, sand drifts, and smoke. Its distant position keeps it separate from the Studio map.
- A weathered highway, abandoned LAST STOP gas station with boarded windows and old pumps, roadside signs, and sagging utility lines.
- Slow tumbleweeds enter at randomized 2–4 second intervals (normal effects), using a reusable pool of four. Low effects allows only one active weed, so appearances may be farther apart; reduced motion freezes rolling. Updates pause on the black mode-selection screen.
- Sunset lighting, slow camera orbit, cinematic bars, typewriter lettering, and asymmetric text-only menu links without list numbers. Each link opens a separate page over the existing scenery. Rendering uses ordinary parts and no external model assets.
- Play: Solo, Duo, or Squad (up to four); roster and leader-controlled capacity.
- Invite: same-server party invitations with accept/decline, expiry, capacity checks, and leader transfer. Roblox friend invitations use the platform prompt when available; joining via a friend invitation does not automatically put someone in a party.
- Settings: menu sound, reduced camera/profile motion, and low effects. These settings last for the current session.
- A direct **Back** button returns to the black Story Mode / Online screen. Options also includes a return control.
- Animated circular Roblox avatar portrait; **Be Inspired** is directly underneath **Developed by MHIDE**.
- Separate wardrobe page: live, gently animated character on the left; visual 3D item cards on the right; drag/arrow controls for 360° rotation; short smoke puff on successful selection; 0.5-second cooldown enforced on both client and server.
- Original procedural western starter outfits with different boy/girl shirt colors and denim details, brown boots, and an optional cowboy hat. The same geometry is applied to the actual avatar and previews.
- Costume, Top, Bottom, Hat, Shoes, and Critter tabs. Starter garments and hat/no-hat are selectable. A bird costume and dog show locked previews until progression is implemented.
- Mouse, touch, and selectable gamepad buttons; adaptive portrait layout.

## Deliberately unfinished

**Online** explains that the mode is coming later. **Begin Story** explains that the first playable mission is in development. The shop has its own placeholder page; purchases and story reward unlocks are not implemented. Character details and clothing are retained in this server session and reapplied on respawn; they are not saved across rejoining or teleports yet. Personality is stored for future gameplay but has no story effects yet. Vehicles, weapons, dogs, heists, dialogue choices, and gameplay animation are future milestones.

When actual destinations exist, set `OnlinePlaceId` and `StoryPlaceId` in `src/shared/Config.luau` to published **place IDs** within this experience. Keep them at `0` until then. The server uses a reserved server for a story party. Teleports must be tested in the published Roblox client, not Studio. Do not point a destination back to this menu place, which would loop the player back to the opening.

Names are checked through Roblox TextService. A filtering outage in a published game blocks creation and offers retry. If filtering is unavailable in Studio, a safe **Studio Explorer** placeholder lets the rest of the flow be tested; the UI explains this. No unfiltered name is published. R15 is the intended character rig; final fit, idle animation, clothing appearance, and item-card framing need Studio validation.

## Files

- `src/client/Main.client.luau`: opening, camera, UI, input, and menu interactions.
- `src/client/DesertScene.luau`: camper, vegetation, and temporary lighting.
- `src/client/DesertDetails.luau`: triangulated mountains, road, gas station, and pooled tumbleweed animation.
- `src/server/PartyService.server.luau`: authoritative party management and destination travel.
- `src/client/CharacterFlow.luau`: name, character, and personality steps.
- `src/client/Wardrobe.luau`: visual wardrobe, rotation, smoke puff, and item cards.
- `src/server/CharacterService.server.luau`: name filtering, authoritative session profile, and clothing validation.
- `src/shared/CharacterCatalog.luau`: available items, locked items, and selection rules.
- `src/shared/WesternOutfit.luau`: shared outfit geometry used by avatars and previews.
- `src/shared/Config.luau`: timing, sound, and future destination IDs.
- `src/shared/PartyRules.luau`: invitation and capacity rules.

The menu currently holds the player's camera and movement until travel. This is intentional for the menu place; no mission world is playable yet. Roblox's system menu remains available.

## Validation

Command-line checks:

```sh
rojo build default.project.json -o /tmp/shirts-and-skins.rbxlx
python3 tests/run.py /path/to/luau
```

Character tests exercise the actual server source with service doubles: name validation/filter failure, duplicate names, identity choices, locked items, forged requests, isolated inventories, and cooldown. The party tests run the actual server source with service doubles. The scenery tests run the detail module with lightweight geometry doubles and check a two-minute spawn simulation, object budgets, reduced-motion behavior, hidden-screen pauses, and cleanup. These do not validate rendered appearance. They cover capacity, leadership, invitations, expiry, disconnects, and destination gating; they do not replace Roblox engine testing. Compile scripts using `luau-compile` if installed. Plain `luau-analyze` needs Roblox type definitions to understand engine globals.

Required Studio acceptance checks:

- Play: test each character-creation step, Back navigation, duplicate names in two clients, and invalid-name responses. Verify the black opening, click timing, five-second orbit, menu fade, van framing, and readable text.
- Exercise every menu button; confirm unavailable features show explanations rather than errors.
- Test desktop, portrait/landscape device emulation, and gamepad navigation. Check the Output window for errors.
- Use Studio's multi-client server test with 2–4 players. Set Duo/Squad, invite, accept, decline, leave, disconnect the leader, and try joining a full party.
- Toggle sound, reduced motion, and low effects. Watch tumbleweeds for at least 30 seconds and verify sparse, slow motion.
- Use **Back** and re-enter Story Mode repeatedly: the opening must be black, each intro must last five seconds, and scenery must not duplicate.
- Check the station and mountain silhouettes during the orbit; verify the stacked credits and unnumbered text-only links at desktop and mobile sizes.
- Open each menu link: only its page should appear, with the same scenery behind it. Back must restore the home menu.
- Open the profile: inspect both starter outfit variants, hat/no-hat, accurate item cards, 360° drag and arrow rotation, brief smoke puff, half-second cooldown, and locked costume/dog feedback. Reset the character and confirm the session outfit is reapplied.
- Check performance on an actual lower-powered device. Rendering quality and sound behavior have not been verified in this cloud workspace, which cannot run Roblox Studio.
