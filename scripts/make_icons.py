"""Installe les icônes de l'app à partir du jeu fourni (packaging/icon/trophy-icon/).

    python scripts/make_icons.py

Les fichiers du jeu ne sont jamais modifiés : ils sont recopiés tels quels là où chaque plateforme
les attend. Seul le bandeau Android TV est composé ici, car Android TV recommande d'y lire le nom
de l'app et celui du jeu n'en porte pas.

- Windows : `icon.ico`, transparent (exécutable, barre des tâches, installeur).
- Linux : `png/icon-512.png`, transparent.
- Android : icônes classiques, rondes et adaptatives, sur le fond cyan du jeu.
"""
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
PACK = ROOT / "packaging/icon/trophy-icon"
ANDROID = ROOT / "app/android/app/src/main/res"
FONT = ROOT / "app/assets/fonts/BarlowCondensed-ExtraBoldItalic.ttf"

# Couleurs du jeu (README.md) : fond cyan, bleu nuit, bleu.
BACKGROUND = (0x38, 0xD6, 0xFF)
NAVY = (0x01, 0x11, 0x28)
BLUE = (0x12, 0x3F, 0x7D)

DENSITIES = ("mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi")
LAUNCHER = ("ic_launcher.png", "ic_launcher_round.png", "ic_launcher_foreground.png")


def android_icons():
    for density in DENSITIES:
        folder = ANDROID / f"mipmap-{density}"
        folder.mkdir(exist_ok=True)
        for name in LAUNCHER:
            shutil.copyfile(PACK / f"android/mipmap-{density}/{name}", folder / name)
    (ANDROID / "mipmap-anydpi-v26").mkdir(exist_ok=True)
    for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
        shutil.copyfile(PACK / f"android/mipmap-anydpi-v26/{name}", ANDROID / f"mipmap-anydpi-v26/{name}")
    # Même couleur que `values/ic_launcher_background.xml` du jeu, sous le nom de fichier du projet :
    # deux fichiers définissant la même couleur feraient échouer la compilation.
    (ANDROID / "values").mkdir(exist_ok=True)
    (ANDROID / "values/colors.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
        f'    <color name="ic_launcher_background">#{"%02X%02X%02X" % BACKGROUND}</color>\n'
        "</resources>\n",
        encoding="utf-8",
    )
    (ANDROID / "drawable-xhdpi").mkdir(exist_ok=True)
    tv_banner().save(ANDROID / "drawable-xhdpi/banner.png")


def tv_banner():
    """Bandeau de l'écran d'accueil d'Android TV : le trophée à gauche, le nom à droite."""
    width, height = 640, 360
    banner = Image.new("RGBA", (width, height), BACKGROUND + (255,))
    trophy = Image.open(PACK / "png/icon-1024.png").convert("RGBA")
    trophy = trophy.crop(trophy.getchannel("A").getbbox())
    mark_height = 310
    mark_width = round(trophy.width * mark_height / trophy.height)
    banner.alpha_composite(trophy.resize((mark_width, mark_height), Image.LANCZOS), (40 + (220 - mark_width) // 2, 25))
    draw = ImageDraw.Draw(banner)
    font = ImageFont.truetype(FONT, 118)
    draw.text((450, 118), "CHUD", font=font, fill=NAVY, anchor="mm")
    draw.text((450, 232), "IPTV", font=font, fill=BLUE, anchor="mm")
    return banner.convert("RGB").resize((320, 180), Image.LANCZOS)


def main():
    shutil.copyfile(PACK / "png/icon-512.png", ROOT / "packaging/linux/chud-iptv.png")
    shutil.copyfile(PACK / "icon.ico", ROOT / "app/windows/runner/resources/app_icon.ico")
    android_icons()
    print("Icones installees")


if __name__ == "__main__":
    main()
