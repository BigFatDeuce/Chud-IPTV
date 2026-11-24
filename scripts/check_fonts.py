"""Vérifie que les polices embarquées couvrent tous les caractères de toutes les langues.

    python scripts/check_fonts.py

Un caractère absent s'afficherait en carré vide : une langue n'est ajoutée que si ce script passe.
"""
import json
import re
import sys
from pathlib import Path

from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parent.parent
FONTS = ROOT / "app/assets/fonts"


def charset(name):
    return set(TTFont(FONTS / name).getBestCmap())


def main():
    body = charset("Inter.ttf")
    display = charset("BarlowCondensed-Bold.ttf")
    # Barlow se rabat sur Inter : seule compte la couverture d'Inter pour le texte courant.
    missing = {}
    display_fallback = {}
    for arb in sorted((ROOT / "app/lib/l10n").glob("app_*.arb")):
        lang = arb.stem[4:]
        data = json.loads(arb.read_text(encoding="utf-8"))
        text = "".join(v for k, v in data.items() if not k.startswith("@"))
        text = re.sub(r"\{[a-zA-Z]+[,}]", "", text)
        chars = {ord(c) for c in text} - {10}
        absent = sorted(c for c in chars if c not in body)
        if absent:
            missing[lang] = "".join(chr(c) for c in absent)
        fallback = sorted(c for c in chars if c not in display)
        if fallback:
            display_fallback[lang] = len(fallback)
    settings = (ROOT / "app/lib/screens/settings_screen.dart").read_text(encoding="utf-8")
    names = re.findall(r"^  '[a-z]{2}': '(.+)',$", settings, flags=re.M)
    absent = {c for n in names for c in n if ord(c) not in body}
    if absent:
        missing["noms des langues"] = "".join(sorted(absent))
    print("Repli de Barlow vers Inter, nombre de caractères :", display_fallback or "aucun")
    if missing:
        print("CARACTÈRES ABSENTS :", missing)
        sys.exit(1)
    print("Toutes les langues sont couvertes par Inter.")


if __name__ == "__main__":
    main()
