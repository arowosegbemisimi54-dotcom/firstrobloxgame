"""Run party behavior tests against the actual server source with service doubles.
Usage: python3 tests/run.py /path/to/luau
Studio multiplayer and visual checks are still required.
"""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
harness = (root / 'tests/party-harness.luau').read_text()
harness = harness.replace('-- INSERT_RULES', (root / 'src/shared/PartyRules.luau').read_text())
harness = harness.replace('-- INSERT_SERVER', (root / 'src/server/PartyService.server.luau').read_text())
with tempfile.TemporaryDirectory() as tmp:
    script = pathlib.Path(tmp) / 'party-tests.luau'
    script.write_text(harness)
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', str(script)], check=True)
