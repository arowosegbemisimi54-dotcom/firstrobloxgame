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
    'diner-integration': {'-- INSERT_TIMELINE': 'src/shared/DinerTimeline.luau', '-- INSERT_DINER': 'src/client/DinerOpening.luau', '-- INSERT_BROADCAST': 'src/client/DinerBroadcast.luau', '-- INSERT_AUDIO': 'src/client/DinerAudio.luau', '-- INSERT_ART': 'src/client/DinerArt.luau', '-- INSERT_PAINTINGS': 'src/client/DinerPaintings.luau', '-- INSERT_CAST': 'src/client/DinerCast.luau', '-- INSERT_OUTFIT': 'src/shared/WesternOutfit.luau', '-- INSERT_LANDSCAPE': 'src/client/LoadingLandscape.luau', '-- INSERT_LOADING': 'src/client/StoryLoading.luau'},
    'diner': {'-- INSERT_TIMELINE': 'src/shared/DinerTimeline.luau'},
    'character': {
        '-- INSERT_CATALOG': 'src/shared/CharacterCatalog.luau',
        '-- INSERT_CHARACTER_SERVER': 'src/server/CharacterService.server.luau',
    },
    'party': {
        '-- INSERT_RULES': 'src/shared/PartyRules.luau',
        '-- INSERT_SERVER': 'src/server/PartyService.server.luau',
    },
    'scenery': {'-- INSERT_DETAILS': 'src/client/DesertDetails.luau', '-- INSERT_TRAFFIC': 'src/client/DesertTraffic.luau'},
}
with tempfile.TemporaryDirectory() as tmp:
    for name, sources in suites.items():
        harness = (root / f'tests/{name}-harness.luau').read_text()
        for marker, source in sources.items():
            harness = harness.replace(marker, (root / source).read_text())
        script = pathlib.Path(tmp) / f'{name}-tests.luau'
        script.write_text(harness)
        subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', str(script)], check=True)
