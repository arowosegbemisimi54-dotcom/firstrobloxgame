# Shirts and Skins

An original cinematic Roblox crime-adventure project by **MHIDE**. This first build implements the opening and Story Mode menu, not the missions or combat systems.

## Run in Roblox Studio

1. In GitHub Desktop, select `firstrobloxgame`, click **Fetch origin**, then **Pull origin**.
2. If Rojo is already serving this repository, it watches the updated files automatically. Otherwise open PowerShell in the repository folder and run (adjust the executable path if needed):
   ```powershell
   & "$env:USERPROFILE\Downloads\rojo-7.7.1-windows-x86_64\rojo.exe" serve
   ```
3. In Studio, open the saved game and connect **Plugins → Rojo** to `localhost:34872`. Review the initial sync. The project maps only `GameServer`, `GameShared`, and `GameClient`; it does not map your Workspace, terrain, or saved lighting.
4. Click **Play**, not Run. Local scripts and the interface need a player. Stop and restart Play after script changes to avoid duplicate menus from live editing.
5. The black opening shows **Story Mode**, then **Online**, with clicks. Choose Story Mode to see a five-second counter-clockwise camera orbit before the menu fades in.
6. Test before publishing. GitHub pulls and Rojo syncs do not publish a live Roblox game.

Keep PowerShell open during sync. Edit synced scripts in the repository, not inside Studio; Rojo can overwrite Studio edits to mapped objects. The root configuration uses UTF-8 without a BOM.

## Included

- Side-by-side, staggered opening choices on black, one second after client loading.
- Client-only desert set: one camper, extended awning, tent, table, rounded cacti, continuous triangulated sandstone ridges, sand drifts, and smoke. Its distant position keeps it separate from the Studio map.
- A weathered highway, abandoned LAST STOP gas station with boarded windows and old pumps, roadside signs, and sagging utility lines.
- Slow tumbleweeds enter at randomized 2–4 second intervals (normal effects), using a reusable pool of four. Low effects allows only one active weed, so appearances may be farther apart; reduced motion freezes rolling. Updates pause on the black mode-selection screen.
- Sunset lighting, slow camera orbit, cinematic bars, typewriter lettering, and mottled sand-colored menu buttons without list numbers. Rendering uses ordinary parts and no external model assets.
- Play: Solo, Duo, or Squad (up to four); roster and leader-controlled capacity.
- Invite: same-server party invitations with accept/decline, expiry, capacity checks, and leader transfer. Roblox friend invitations use the platform prompt when available; joining via a friend invitation does not automatically put someone in a party.
- Settings: menu sound, reduced camera/profile motion, and low effects. These settings last for the current session.
- A direct **Back** button returns to the black Story Mode / Online screen. Options also includes a return control.
- Animated circular Roblox avatar portrait; **Be Inspired** is directly underneath **Developed by MHIDE**.
- Mouse, touch, and selectable gamepad buttons; adaptive portrait layout.

## Deliberately unfinished

**Online** explains that the mode is coming later. **Begin Story** explains that the first playable mission is in development. The shop and profile panels describe their upcoming content; there are no purchases, unlocks, or persistent avatar changes yet. Vehicles, weapons, dogs, heists, dialogue choices, and gameplay animation are future milestones.

When actual destinations exist, set `OnlinePlaceId` and `StoryPlaceId` in `src/shared/Config.luau` to published **place IDs** within this experience. Keep them at `0` until then. The server uses a reserved server for a story party. Teleports must be tested in the published Roblox client, not Studio. Do not point a destination back to this menu place, which would loop the player back to the opening.

## Files

- `src/client/Main.client.luau`: opening, camera, UI, input, and menu interactions.
- `src/client/DesertScene.luau`: camper, vegetation, and temporary lighting.
- `src/client/DesertDetails.luau`: triangulated mountains, road, gas station, and pooled tumbleweed animation.
- `src/server/PartyService.server.luau`: authoritative party management and destination travel.
- `src/shared/Config.luau`: timing, sound, and future destination IDs.
- `src/shared/PartyRules.luau`: invitation and capacity rules.

The menu currently holds the player's camera and movement until travel. This is intentional for the menu place; no mission world is playable yet. Roblox's system menu remains available.

## Validation

Command-line checks:

```sh
rojo build default.project.json -o /tmp/shirts-and-skins.rbxlx
python3 tests/run.py /path/to/luau
```

The party tests run the actual server source with service doubles. The scenery tests run the detail module with lightweight geometry doubles and check a two-minute spawn simulation, object budgets, reduced-motion behavior, hidden-screen pauses, and cleanup. These do not validate rendered appearance. They cover capacity, leadership, invitations, expiry, disconnects, and destination gating; they do not replace Roblox engine testing. Compile scripts using `luau-compile` if installed. Plain `luau-analyze` needs Roblox type definitions to understand engine globals.

Required Studio acceptance checks:

- Play: verify the black opening, click timing, five-second orbit, menu fade, van framing, and readable text.
- Exercise every menu button; confirm unavailable features show explanations rather than errors.
- Test desktop, portrait/landscape device emulation, and gamepad navigation. Check the Output window for errors.
- Use Studio's multi-client server test with 2–4 players. Set Duo/Squad, invite, accept, decline, leave, disconnect the leader, and try joining a full party.
- Toggle sound, reduced motion, and low effects. Watch tumbleweeds for at least 30 seconds and verify sparse, slow motion.
- Use **Back** and re-enter Story Mode repeatedly: the opening must be black, each intro must last five seconds, and scenery must not duplicate.
- Check the station and mountain silhouettes during the orbit; verify the stacked credits and unnumbered sandy buttons at desktop and mobile sizes.
- Check performance on an actual lower-powered device. Rendering quality and sound behavior have not been verified in this cloud workspace, which cannot run Roblox Studio.
