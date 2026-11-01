"""Regenerate every documentation image with the current library version.

Illustrations are drawn from the real palettes and pixel icons in RetroBox.lua;
they are compositions, not Roblox screenshots. Run from any directory:

    python3 tools/build_docs_images.py
"""
from pathlib import Path
import importlib.util
import re
import runpy

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "RetroBox.lua").read_text()
VERSION = re.search(r'Version = "([^"]+)"', SOURCE).group(1)
ROLES = ["Background", "Surface", "Inset", "Text", "Muted", "Border", "Highlight", "Shadow", "Accent", "AccentText", "Success", "Danger"]


def load_package():
    spec = importlib.util.spec_from_file_location("retrobox_build_package", ROOT / "tools/build_package.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


PACKAGE = load_package()
ICONS = PACKAGE.ICONS


def theme(name):
    raw = re.search(r"Library\.Themes\." + name + r" = palette\(\{(.*?)\}\)", SOURCE, re.S).group(1)
    values = [tuple(map(int, m)) for m in re.findall(r"\{(\d+),(\d+),(\d+)\}", raw)]
    return dict(zip(ROLES, values))


def font(size):
    return ImageFont.truetype("DejaVuSansMono.ttf", size)


class Canvas:
    def __init__(self, size, colors, background):
        self.image = Image.new("RGB", size, background)
        self.draw = ImageDraw.Draw(self.image)
        self.colors = colors

    def color(self, role):
        return self.colors.get(role, role) if isinstance(role, str) else role

    def text(self, x, y, value, role="Text", size=15, anchor=None):
        self.draw.text((x, y), value, fill=self.color(role), font=font(size), anchor=anchor)

    def rect(self, box, role, outline=None, width=1):
        self.draw.rectangle(box, fill=self.color(role), outline=self.color(outline) if outline else None, width=width)

    def bevel(self, box, role="Surface", sunken=False):
        x1, y1, x2, y2 = box
        self.rect(box, role)
        bright, dark = ("Shadow", "Highlight") if sunken else ("Highlight", "Shadow")
        self.draw.line((x1, y2, x1, y1, x2, y1), fill=self.color(bright), width=2)
        self.draw.line((x1, y2, x2, y2, x2, y1), fill=self.color(dark), width=2)

    def icon(self, name, x, y, scale=2, foreground="Text"):
        roles = {"#": foreground, "a": "Accent", "h": "Highlight", "s": "Shadow", "m": "Muted", "g": "Success", "r": "Danger"}
        for row_index, row in enumerate(ICONS[name].split("/")):
            for column, char in enumerate(row):
                if char != ".":
                    px, py = x + column * scale, y + row_index * scale
                    self.draw.rectangle((px, py, px + scale - 1, py + scale - 1), fill=self.color(roles[char]))

    def window(self, box, title, icon="retrobox"):
        x1, y1, x2, y2 = box
        self.rect((x1 + 8, y1 + 8, x2 + 8, y2 + 8), "Shadow")
        self.bevel(box, "Background")
        self.rect((x1 + 4, y1 + 4, x2 - 4, y1 + 38), "Accent")
        self.icon(icon, x1 + 12, y1 + 9, 2, "AccentText")
        self.text(x1 + 44, y1 + 12, title, "AccentText", 15)
        for index, name in enumerate(("minimize", "maximize", "close")):
            bx = x2 - 104 + index * 32
            self.bevel((bx, y1 + 9, bx + 26, y1 + 33))
            self.icon(name, bx + 7, y1 + 15, 1)


def boot_frame(c, x, y, w, h, stage):
    """stage: 0 emblem/typing, 1 log in progress, 2 complete."""
    c.window((x, y, x + w, y + h), "Meu Script")
    c.rect((x + 3, y + 3, x + w - 3, y + h - 3), "Background")
    cx = x + w // 2
    scale = 3 if stage == 0 else 4
    c.icon("retrobox", cx - 6 * scale, y + 34 + (4 - scale) * 6, scale, "Accent")
    title = "Meu Scr" if stage == 0 else "Meu Script"
    c.text(cx, y + 104, title + ("█" if stage == 0 else ""), "Text", 20, anchor="ma")
    if stage > 0:
        c.text(cx, y + 133, "Farm demonstrativo · RetroBox UI v" + VERSION, "Muted", 11, anchor="ma")
    lx1, ly1, lx2, ly2 = x + 24, y + 158, x + w - 24, y + 262
    c.bevel((lx1, ly1, lx2, ly2), "Inset", sunken=True)
    lines = ["> RetroBox UI v" + VERSION + " · API 2", "> Tema Hacker · 76 ícones", "> Montando 3 abas · 18 controles", "> Preferências e perfis"]
    shown = {0: 0, 1: 3, 2: 4}[stage]
    for index in range(shown):
        ly = ly1 + 10 + index * 23
        c.text(lx1 + 10, ly, lines[index], "Text", 11)
        done = stage == 2 or index < shown - 1
        if done:
            c.text(lx2 - 10, ly, "[ OK ]", "Success", 11, anchor="ra")
        else:
            c.rect((lx1 + 14 + len(lines[index]) * 7, ly + 2, lx1 + 20 + len(lines[index]) * 7, ly + 13), "Accent")
    cells, filled = 24, {0: 0, 1: 15, 2: 24}[stage]
    bx1, by, bw = x + 24, y + 276, w - 96
    for index in range(cells):
        px = bx1 + index * bw / cells
        c.rect((int(px) + 1, by, int(px + bw / cells) - 1, by + 10), "Accent" if index < filled else "Border")
    c.text(x + w - 24, by - 3, "%03d%%" % round(filled / cells * 100), "Muted", 11, anchor="ra")
    if stage < 2:
        c.text(cx, by + 22, "Clique para pular", "Muted", 10, anchor="ma")
    sweep = {0: .22, 1: .62, 2: .9}[stage]
    sy = y + 3 + int((h - 6) * sweep)
    c.draw.line((x + 3, sy, x + w - 3, sy), fill=c.color("Highlight"), width=2)


def boot_screen():
    colors = theme("Hacker")
    c = Canvas((1280, 560), colors, colors["Shadow"])
    c.icon("retrobox", 40, 30, 4, "Accent")
    c.text(104, 34, "RETROBOX / BOOT SCREEN", "Accent", 26)
    c.text(106, 72, f"v{VERSION}  /  LoadingScreen padrão  /  pular com clique, Enter, Espaço ou Esc", "Muted", 13)
    labels = ["0,3 s · emblema e título digitado", "1,2 s · log e progresso em blocos", "2,0 s · pronto, fecha como CRT"]
    for index in range(3):
        x = 40 + index * 410
        boot_frame(c, x, 120, 380, 340, index)
        c.text(x, 482, labels[index], "Text", 13)
    c.text(40, 522, "Composição ilustrativa das cores reais do tema Hacker; confira a animação no executor.", "Muted", 12)
    c.image.save(ROOT / "docs/boot-screen.png", optimize=True)


def refined_controls():
    colors = theme("Retro98")
    c = Canvas((1280, 760), colors, "#F0EDDF")
    c.icon("retrobox", 40, 30, 4)
    c.text(104, 34, "RETROBOX / COMPONENTES 2.11", "Accent", 26)
    c.text(106, 72, f"v{VERSION}  /  Segmented · RangeSlider · Number · Callout · CodeBlock", "Muted", 13)
    c.window((40, 112, 1240, 700), "RetroBox · componentes refinados", "sliders")
    # Left column: choice and number controls.
    x, y = 70, 166
    c.bevel((x - 10, y - 10, 630, 680), "Surface")
    c.text(x, y, "Modo de seleção", "Text", 15)
    c.bevel((x, y + 28, 610, y + 60), "Inset", sunken=True)
    segments = ["Próximo", "Aleatório", "Menor vida"]
    width = (610 - x) / 3
    for index, name in enumerate(segments):
        sx = x + index * width
        if index == 1:
            c.bevel((int(sx) + 2, y + 30, int(sx + width) - 2, y + 58), "Accent")
        c.text(int(sx + width / 2), y + 37, name, "AccentText" if index == 1 else "Text", 13, anchor="ma")
    y += 90
    c.text(x, y, "Intervalo aleatório", "Text", 15)
    c.text(610, y + 2, "0.5s – 1.5s", "Muted", 12, anchor="ra")
    c.text(x, y + 22, "Mínimo e máximo, em segundos.", "Muted", 12)
    c.bevel((x, y + 50, 610, y + 60), "Inset", sunken=True)
    lo, hi = x + (610 - x) * .1, x + (610 - x) * .3
    c.rect((int(lo), y + 51, int(hi), y + 59), "Accent")
    for px in (lo, hi):
        c.bevel((int(px) - 6, y + 44, int(px) + 6, y + 66))
    y += 100
    c.text(x, y, "Quantidade", "Text", 15)
    c.bevel((x, y + 28, x + 32, y + 60)); c.text(x + 16, y + 33, "-", "Text", 18, anchor="ma")
    c.bevel((x + 38, y + 28, 572, y + 60), "Inset", sunken=True); c.text((x + 610) // 2, y + 36, "5 un.", "Text", 14, anchor="ma")
    c.bevel((578, y + 28, 610, y + 60)); c.text(594, y + 33, "+", "Text", 18, anchor="ma")
    y += 96
    c.rect((x, y, 610, y + 92), "Inset", outline="Border")
    c.rect((x, y, x + 4, y + 92), "Accent")
    c.icon("spark", x + 14, y + 12, 1, "Accent")
    c.text(x + 36, y + 9, "Modo educativo", "Text", 14)
    c.text(x + 36, y + 32, "Os valores só alteram esta interface.", "Muted", 12)
    c.text(x + 36, y + 50, "Nenhuma lógica de jogo é executada.", "Muted", 12)
    y += 112
    c.rect((x, y, 610, y + 66), "Inset", outline="Border")
    c.rect((x, y, x + 4, y + 66), "Danger")
    c.icon("warning", x + 14, y + 12, 1, "Danger")
    c.text(x + 36, y + 9, "Atenção", "Text", 14)
    c.text(x + 36, y + 32, "Kind = Info · Tip · Success · Warning · Danger", "Muted", 12)
    # Right column: code block.
    x = 670
    c.bevel((x - 10, 156, 1220, 680), "Surface")
    c.text(x, 166, "Valores atuais", "Text", 15)
    c.text(1120, 168, "LUA", "Muted", 11, anchor="ra")
    c.bevel((1130, 162, 1205, 186)); c.text(1167, 167, "Copiar", "Text", 12, anchor="ma")
    c.rect((x, 200, 1205, 470), "Inset", outline="Border")
    code = ['local mode = "Aleatório"', "local delay = {0.5, 1.5}", "local amount = 5", "", "-- SetCode / GetCode / Copy()", "-- setclipboard quando disponível"]
    for index, line in enumerate(code):
        c.text(x + 30, 212 + index * 20, str(index + 1), "Muted", 12, anchor="ra")
        c.text(x + 44, 212 + index * 20, line, "Accent" if line.startswith("--") else "Text", 12)
    c.text(x, 494, "Notificação com barra de tempo", "Text", 15)
    c.bevel((x, 522, 1205, 600))
    c.rect((x + 2, 524, x + 6, 598), "Success")
    c.icon("success", x + 16, 536, 1, "Success")
    c.text(x + 38, 532, "Modo", "Text", 13)
    c.text(x + 16, 560, "Selecionado: Aleatório", "Muted", 12)
    c.rect((x + 6, 594, x + 6 + int((1205 - x - 8) * .62), 597), "Success")
    c.text(x, 622, "Pulso de clique · check com salto · seleção elástica", "Muted", 12)
    c.text(40, 722, "Composição ilustrativa das cores reais do tema Retro98; a renderização final depende do executor.", "Muted", 12)
    c.image.save(ROOT / "docs/refined-controls.png", optimize=True)


if __name__ == "__main__":
    PACKAGE.pixel_catalog()
    PACKAGE.visual_concept()
    PACKAGE.dashboard_concept()
    runpy.run_path(str(ROOT / "tools/build_contrast_preview.py"), run_name="__main__")
    boot_screen()
    refined_controls()
    print(f"Documentation images regenerated for RetroBox {VERSION}")
