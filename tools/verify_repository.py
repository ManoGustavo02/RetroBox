"""Check root documentation links, SVG assets and required repository files."""
from pathlib import Path
from urllib.parse import unquote, urlsplit
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
DOCUMENTS = ["README.md", "README.en.md", "SECURITY.md", "CONTRIBUTING.md", "SUPPORT.md", "docs/PUBLICATION.md", "docs/REPOSITORY-SETUP.md", "designer/README.md", "RetroBox-UI-v1.1.0/retrobox-ui/docs/DEVELOPMENT-TOOLS.md", "RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.5.md", "RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.5.1.md", "RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.5.2.md", "RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.6.md", "RetroBox-UI-v1.1.0/retrobox-ui/docs/API.md", "RetroBox-UI-v1.1.0/retrobox-ui/docs/RUNTIME.md"]
REQUIRED = DOCUMENTS + ["LICENSE", "assets/retrobox-banner.svg", "assets/retrobox-badges.svg", "assets/retrobox-banner.png", ".github/workflows/validate.yml", ".github/ISSUE_TEMPLATE/bug_report.yml", ".github/pull_request_template.md"]


def local_target(document, value):
    value = value.strip()
    if not value or value.startswith("#") or urlsplit(value).scheme or value.startswith("//"):
        return
    value = unquote(value.split("#", 1)[0].split("?", 1)[0])
    target = (document.parent / value).resolve()
    assert target.is_relative_to(ROOT), f"Link leaves the repository: {document}: {value}"
    assert target.exists(), f"Missing link target: {document}: {value}"


for name in REQUIRED:
    assert (ROOT / name).is_file(), f"Missing repository file: {name}"
links = 0
for name in DOCUMENTS:
    document = ROOT / name
    content = document.read_text()
    for value in re.findall(r"!?\[[^\]]*\]\(([^)]+)\)", content):
        local_target(document, value); links += 1
    for value in re.findall(r'\bsrc="([^"]+)"', content):
        local_target(document, value); links += 1

svg = ET.parse(ROOT / "assets/retrobox-banner.svg").getroot()
assert svg.tag == "{http://www.w3.org/2000/svg}svg"
for node in svg.iter():
    assert node.tag.rsplit("}", 1)[-1] not in {"script", "foreignObject"}, "Active SVG content is not permitted"
    assert not any(key.lower().startswith("on") for key in node.attrib), "Unexpected SVG event handler"
    for key, value in node.attrib.items():
        if key.rsplit("}", 1)[-1] == "href":
            assert value.startswith("#"), "External SVG assets are not permitted"
assert (ROOT / "assets/retrobox-banner.png").read_bytes().startswith(b"\x89PNG\r\n\x1a\n")
assert (ROOT / "LICENSE").read_bytes() == (ROOT / "RetroBox-UI-v1.1.0/retrobox-ui/LICENSE").read_bytes(), "Preserve the existing MIT license"
print(f"Repository checks passed: {len(REQUIRED)} required files, {links} links, passive SVG/PNG and preserved license")
