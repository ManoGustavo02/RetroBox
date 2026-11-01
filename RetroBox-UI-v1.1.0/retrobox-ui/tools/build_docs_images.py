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


def feedback_center():
    colors = theme("Hacker")
    c = Canvas((1280, 860), colors, colors["Shadow"])
    c.icon("notification", 40, 30, 4, "Accent")
    c.text(104, 34, "RETROBOX / CENTRAL DE IDEIAS", "Accent", 26)
    c.text(106, 72, f"v{VERSION}  /  cabeçalho, categorias, etapas, contador e confirmação de envio", "Muted", 13)
    c.window((40, 112, 1240, 820), "Central de Ideias", "notification")
    x1, x2 = 64, 1216
    # Header card.
    c.rect((x1, 168, x2, 236), "Surface", outline="Border")
    c.rect((x1, 168, x1 + 4, 236), "Accent")
    c.rect((x1 + 18, 180, x1 + 62, 224), "Accent")
    c.icon("notification", x1 + 28, 190, 2, "AccentText")
    c.text(x1 + 76, 180, "Central de Ideias", "Text", 19)
    c.text(x1 + 76, 208, "Sugira melhorias, peça um script ou relate um problema.", "Muted", 12)
    # Category cards.
    cards = [("gamepad", "Pedir script", "Para um jogo do Roblox"), ("spark", "Sugestão", "Melhorias e novas funções"),
             ("notification", "Feedback", "Conte sua experiência"), ("warning", "Relatar bug", "Algo não funcionou?")]
    width = (x2 - x1 - 36) // 4
    for index, (icon, title, desc) in enumerate(cards):
        cx = x1 + index * (width + 12)
        selected = index == 1
        c.rect((cx, 250, cx + width, 326), "Surface", outline="Accent" if selected else "Border", width=2 if selected else 1)
        if selected:
            c.rect((cx, 250, cx + width, 253), "Accent")
            c.icon("check", cx + width - 24, 262, 1, "Accent")
        c.rect((cx + 12, 262, cx + 40, 290), "Accent" if selected else "Inset")
        c.icon(icon, cx + 20, 270, 1, "AccentText" if selected else "Accent")
        c.text(cx + 50, 266, title, "Accent" if selected else "Text", 13)
        c.text(cx + 13, 300, desc, "Muted", 11)
    # Stepper.
    steps = [("Mensagem", "Done"), ("Diagnóstico", "Active"), ("Revisar", "Next")]
    sw = (x2 - x1 - 16) // 3
    c.rect((x1 + sw // 2, 359, x2 - sw // 2, 361), "Accent")
    for index, (name, state) in enumerate(steps):
        sx = x1 + index * (sw + 8)
        fill = {"Active": "Accent", "Done": "Surface", "Next": "Inset"}[state]
        c.rect((sx, 341, sx + sw, 379), fill, outline="Border" if state == "Next" else "Accent")
        c.rect((sx + 9, 349, sx + 31, 371), {"Active": "AccentText", "Done": "Success", "Next": "Border"}[state])
        if state == "Done":
            c.icon("check", sx + 14, 354, 1, "AccentText")
        else:
            c.text(sx + 20, 352, str(index + 1), "Accent" if state == "Active" else "Text", 12, anchor="ma")
        c.text(sx + 42, 352, name, {"Active": "AccentText", "Done": "Text", "Next": "Muted"}[state], 13)
    # Body: message + context column.
    c.rect((x1, 396, 820, 640), "Surface", outline="Border")
    c.text(x1 + 14, 408, "ESCREVA SUA MENSAGEM", "Muted", 12)
    c.rect((x1 + 14, 434, 806, 566), "Inset", outline="Accent")
    c.text(x1 + 26, 446, "Seria ótimo ter um modo escuro mais contrastado", "Text", 13)
    c.text(x1 + 26, 466, "e um atalho para abrir as configurações.", "Text", 13)
    c.text(x1 + 14, 580, "84 / 2000 caracteres", "Muted", 12)
    c.rect((x1 + 14, 604, 806, 607), "Border")
    c.rect((x1 + 14, 604, x1 + 14 + 40, 607), "Accent")
    c.rect((836, 396, x2, 640), "Surface", outline="Border")
    c.text(850, 408, "JOGO E JOGADOR", "Muted", 12)
    c.rect((850, 436, 914, 500), "Inset", outline="Border")
    c.icon("user", 870, 456, 2, "Muted")
    c.text(926, 444, "Jogo de demonstração", "Text", 13)
    c.text(926, 466, "Seu nome (@usuario)", "Muted", 12)
    c.text(850, 520, "STATUS DO ENVIO", "Muted", 12)
    c.text(850, 544, "Escreva sua ideia e confira a", "Muted", 12)
    c.text(850, 562, "prévia antes de enviar.", "Muted", 12)
    # Footer and success panel.
    c.bevel((x1, 656, 636, 698)); c.text(350, 670, "Editar mensagem", "Text", 13, anchor="ma")
    c.bevel((646, 656, x2, 698), "Accent"); c.text(931, 670, "Revisar envio", "AccentText", 13, anchor="ma")
    c.rect((x1, 714, x2, 796), "Surface", outline="Success")
    c.rect((x1, 714, x1 + 4, 796), "Success")
    c.rect((x1 + 18, 728, x1 + 58, 768), "Success")
    c.icon("check", x1 + 26, 736, 2, "AccentText")
    c.text(x1 + 72, 728, "Mensagem enviada!", "Success", 16)
    c.text(x1 + 72, 752, "Mensagem enviada. Obrigado por compartilhar sua ideia!", "Muted", 12)
    c.bevel((x2 - 190, 736, x2 - 14, 772)); c.text(x2 - 102, 747, "Escrever outra", "Text", 12, anchor="ma")
    c.text(40, 836, "Composição ilustrativa (tema Hacker). O painel verde aparece só após a confirmação do Discord.", "Muted", 12)
    c.image.save(ROOT / "docs/feedback-center.png", optimize=True)


def script_hub():
    colors = theme("Retro98")
    c = Canvas((1280, 560), colors, "#F0EDDF")
    c.icon("gamepad", 40, 30, 4)
    c.text(104, 34, "RETROBOX / SCRIPT HUB", "Accent", 26)
    c.text(106, 72, f"v{VERSION}  /  pílulas de status, selo do jogo atual e luz de execução", "Muted", 13)
    c.window((40, 112, 1240, 520), "Meu Hub", "gamepad")
    c.rect((60, 160, 420, 500), "Inset", outline="Border")
    c.text(74, 172, "BIBLIOTECA", "Text", 13)
    games = [("Jogo de exemplo", "2 scripts · jogo desta sessão", True), ("Outro jogo", "1 script", False), ("Simulador", "3 scripts", False)]
    for index, (name, meta, here) in enumerate(games):
        y = 204 + index * 66
        c.rect((70, y, 410, y + 58), "Surface" if index == 0 else "Inset", outline="Accent" if index == 0 else "Border")
        if index == 0:
            c.rect((70, y + 8, 73, y + 50), "Accent")
        c.rect((82, y + 9, 122, y + 49), "Background")
        c.icon("gamepad", 90, y + 17, 2, "Muted")
        c.text(134, y + 10, name, "Accent" if index == 0 else "Text", 13)
        c.text(134, y + 34, meta, "Muted", 10)
        if here:
            c.rect((360, y + 12, 400, y + 28), "Success")
            c.text(380, y + 14, "AQUI", "AccentText", 9, anchor="ma")
    scripts = [("Auto demonstração", "v1.0 · Developer", "Concluído", "Success"), ("Visual local", "v2.1 · Developer", "Executando", "Accent"), ("Ferramenta", "v0.9 · Developer", "Disponível", "Inset")]
    for index, (name, credit, state, role) in enumerate(scripts):
        y = 160 + index * 86
        c.rect((436, y, 1220, y + 78), "Surface" if index == 0 else "Inset", outline="Accent" if index == 0 else "Border")
        c.icon("code", 450, y + 12, 2, "Accent" if index == 0 else "Text")
        c.text(484, y + 10, name, "Accent" if index == 0 else "Text", 14)
        c.text(484, y + 34, credit, "Muted", 10)
        c.text(450, y + 54, "Descrição curta do script para o usuário.", "Muted", 11)
        width = len(state) * 7 + 14
        c.rect((1206 - width, y + 33, 1206, y + 51), role)
        c.text(1206 - width // 2, y + 36, state, "Accent" if role == "Inset" else "AccentText", 10, anchor="ma")
    c.rect((436, 424, 1220, 500), "Surface", outline="Border")
    c.rect((436, 424, 1220, 426), "Accent")
    c.rect((452, 446, 460, 454), "Success")
    c.text(470, 440, "Auto demonstração", "Text", 14)
    c.text(452, 466, "Pronto para executar · v1.0", "Muted", 11)
    c.bevel((940, 444, 1090, 482), "Accent"); c.text(1015, 455, "Executar script", "AccentText", 13, anchor="ma")
    c.bevel((1100, 444, 1206, 482)); c.text(1153, 455, "Informações", "Text", 11, anchor="ma")
    c.text(40, 536, "Composição ilustrativa (tema Retro98); o hub usa o próprio perfil de aparência.", "Muted", 12)
    c.image.save(ROOT / "docs/script-hub.png", optimize=True)


if __name__ == "__main__":
    PACKAGE.pixel_catalog()
    PACKAGE.visual_concept()
    PACKAGE.dashboard_concept()
    runpy.run_path(str(ROOT / "tools/build_contrast_preview.py"), run_name="__main__")
    boot_screen()
    refined_controls()
    feedback_center()
    script_hub()
    print(f"Documentation images regenerated for RetroBox {VERSION}")
