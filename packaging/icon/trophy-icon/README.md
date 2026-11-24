# Trophy icon

Simple vector drawing, no embedded image or font. Transparent background except `icon-square`.

| File | Use |
|---|---|
| `svg/logo-small.svg` | Master file, 48 px and up |
| `svg/logo-tiny.svg` | Simplified version for 16 to 32 px |
| `svg/icon-macos.svg` | macOS tile |
| `svg/icon-square.svg` | Full square for iOS and stores |
| `icon.ico` / `icon.icns` | Windows / macOS |
| `favicon.svg` | Web favicon |
| `png/` | PNGs from 16 to 1024 px |

Colors: navy `#011128`, blue `#123f7d`, gold `#f9c83a`.

Prompt for Claude Code: "The `trophy-icon/` folder holds the app icon. Read its `README.md` and wire it in everywhere (executable, window, taskbar, favicon). Do not modify the files."

## Fond cyan `#38d6ff`

Le fond cyan remplace l'ancien fond bleu sur toutes les icônes qui exigent un fond. Les PNG de `png/`, `icon.ico` et `favicon.svg` restent transparents.

| Dossier | Usage |
|---|---|
| `android/` | À copier dans `app/src/main/res/` : icône adaptative (API 26+), PNG classiques et ronds pour toutes les densités, couleur de fond |
| `tv/` | Bannières Android TV 320x180, 1280x720 et 1920x1080 |
| `store/` | PNG sans transparence : App Store / iOS (1024), Play Store (512), `apple-touch-icon` (180), PWA maskable (512), tuile macOS |
| `svg/android-foreground.svg`, `svg/tv-banner.svg` | Sources vectorielles de ces formats |

Android TV recommande d'inclure le nom de l'application dans la bannière : ajoutez-le à `svg/tv-banner.svg` avant publication.

Manifeste Android : `android:icon="@mipmap/ic_launcher"`, `android:roundIcon="@mipmap/ic_launcher_round"` et, pour la TV, `android:banner="@drawable/banner"` avec `tv/banner-320x180.png` copié dans `res/drawable-xhdpi/banner.png`.
