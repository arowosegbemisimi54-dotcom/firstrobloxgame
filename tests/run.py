"""Run party and scenery behavior tests against actual source with service doubles.
Usage: python3 tests/run.py /path/to/luau
Studio multiplayer and visual checks are still required.
"""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
suites = {
    'scene-motion': {'-- INSERT_MOTION':'src/client/CharacterMotion.luau'},
    'warehouse': {'-- INSERT_WAREHOUSE_RULES':'src/shared/WarehouseRules.luau'},
    'escape': {'-- INSERT_ESCAPE_RULES':'src/shared/EscapeRules.luau'},
    'motion': {'-- INSERT_MOTION':'src/client/CharacterMotion.luau', '-- INSERT_LIVE_MOTION':'src/client/LiveCharacterMotion.luau'},
    'diner-integration': {'-- INSERT_PATROL':'src/client/PeriodPatrol.luau', '-- INSERT_WAREHOUSE_RULES':'src/shared/WarehouseRules.luau','-- INSERT_WAREHOUSE_SET':'src/client/WarehouseSet.luau','-- INSERT_WAREHOUSE_CHAPTER':'src/client/WarehouseChapter.luau', '-- INSERT_VAN':'src/client/GetawayVan.luau', '-- INSERT_MIRRORS':'src/client/VanMirrors.luau', '-- INSERT_ESCAPE_LANDSCAPE':'src/client/EscapeLandscape.luau', '-- INSERT_MOTION':'src/client/CharacterMotion.luau', '-- INSERT_ESCAPE':'src/client/DinerEscape.luau', '-- INSERT_ESCAPE_PROPS':'src/client/EscapeProps.luau', '-- INSERT_ESCAPE_AUDIO':'src/client/EscapeAudio.luau', '-- INSERT_ESCAPE_RULES':'src/shared/EscapeRules.luau', '-- INSERT_EXTERIOR': 'src/client/DinerExterior.luau', '-- INSERT_CARS': 'src/client/VintageCars.luau', '-- INSERT_TIMELINE': 'src/shared/DinerTimeline.luau', '-- INSERT_DINER': 'src/client/DinerOpening.luau', '-- INSERT_BROADCAST': 'src/client/DinerBroadcast.luau', '-- INSERT_AUDIO': 'src/client/DinerAudio.luau', '-- INSERT_ART': 'src/client/DinerArt.luau', '-- INSERT_PAINTINGS': 'src/client/DinerPaintings.luau', '-- INSERT_CAST': 'src/client/DinerCast.luau', '-- INSERT_OUTFIT': 'src/shared/WesternOutfit.luau', '-- INSERT_LANDSCAPE': 'src/client/LoadingLandscape.luau', '-- INSERT_LOADING': 'src/client/StoryLoading.luau'},
    'diner': {'-- INSERT_TIMELINE': 'src/shared/DinerTimeline.luau'},
    'character': {
        '-- INSERT_CATALOG': 'src/shared/CharacterCatalog.luau',
        '-- INSERT_CHARACTER_SERVER': 'src/server/CharacterService.server.luau',
    },
    'party': {
        '-- INSERT_RULES': 'src/shared/PartyRules.luau',
        '-- INSERT_SERVER': 'src/server/PartyService.server.luau',
    },
    'scenery': {'-- INSERT_DETAILS': 'src/client/DesertDetails.luau', '-- INSERT_TRAFFIC': 'src/client/DesertTraffic.luau', '-- INSERT_CARS': 'src/client/VintageCars.luau'},
}
with tempfile.TemporaryDirectory() as tmp:
    for name, sources in suites.items():
        harness = (root / f'tests/{name}-harness.luau').read_text()
        for marker, source in sorted(sources.items(), key=lambda item: -len(item[0])):
            harness = harness.replace(marker, (root / source).read_text())
        script = pathlib.Path(tmp) / f'{name}-tests.luau'
        script.write_text(harness)
        subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', str(script)], check=True)
