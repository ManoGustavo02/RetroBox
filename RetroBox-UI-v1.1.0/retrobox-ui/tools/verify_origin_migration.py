"""Verify preserved releases and the exact runtime scope of the account migration."""
from pathlib import Path
import hashlib
import json
import re

PROJECT = Path(__file__).resolve().parents[1]
REPO = PROJECT.parent.parent
OLD = 'ManoGustavo0/RetroBox'
NEW = 'ManoGustavo02/RetroBox'
fixture = json.loads((PROJECT / 'tests/fixtures/origin-migration-hashes.json').read_text())
for path, expected in fixture.items():
    assert hashlib.sha256((REPO / path).read_bytes()).hexdigest() == expected, f'Historical bytes changed: {path}'

source = (REPO / 'dist/releases/2.3.1/RetroBox.lua').read_text()
previous = (REPO / 'dist/releases/2.3.0/RetroBox.lua').read_text()
normalized = source.replace('-- RetroBox UI 2.3.1 |', '-- RetroBox UI 2.2.0 |', 1)
normalized = normalized.replace('local Library = { Version = "2.3.1"', 'local Library = { Version = "2.3.0"', 1)
normalized = normalized.replace(NEW, OLD)
assert normalized == previous, 'Runtime changes exceed header, version and default origin'
assert OLD not in source and NEW in source
current = (PROJECT / 'RetroBox.lua').read_text()
version = re.search(r'local Library = \{ Version = \"([^\"]+)\"', current)[1]
assert OLD not in current and NEW in current
assert (REPO / 'dist/releases' / version / 'RetroBox.lua').read_text() == current

bootstrap = (PROJECT / 'Loader.lua').read_bytes()
assert NEW.encode() in bootstrap and OLD.encode() not in bootstrap
assert bootstrap == (REPO / 'dist/Loader.lua').read_bytes() == (REPO / 'dist/bootstrap/v2.lua').read_bytes()
active = list(PROJECT.glob('README*.md')) + list((PROJECT / 'examples').glob('*.lua'))
active += [p for p in (PROJECT / 'docs').glob('*.md') if not p.name.startswith('RELEASE-') and p.name != 'VALIDATION.md']
active += [PROJECT / 'src/UpdateCore.lua', PROJECT / 'tools/validate_prompt.py', PROJECT / 'tests/executor-smoke.lua']
for p in active:
    assert OLD not in p.read_text(), f'Active file still uses the former origin: {p.relative_to(REPO)}'

print(f'Origin migration verified: {len(fixture)} historical files unchanged, {len(active)} active files checked, 2.3.1 migration limited to header/version/origin; active release consistent')
