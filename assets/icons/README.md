# App Icons

Replace the placeholder PNG files with real brand artwork before generating icons.

## Required files

| File | Size | Purpose |
|------|------|---------|
| `app_icon.png` | 1024x1024 px | Main icon (iOS + Android legacy) |
| `app_icon_foreground.png` | 1024x1024 px | Android adaptive icon foreground layer |

## Design guidelines

- **Background color**: `#F5F0EB` (warm beige, `AppColors.background`)
- **Primary brand color**: `#7B6B8A` (muted purple, `AppColors.primary`)
- **Style**: Minimalist pilates/wellness aesthetic — consider a simple lotus, wave, or abstract P lettermark
- **Safe zone for adaptive icon**: Keep main design within the inner 66% of the foreground image

## After replacing icons

1. Install packages: `flutter pub get`
2. Generate app icons: `dart run flutter_launcher_icons`
3. Generate splash screens: `dart run flutter_native_splash:create`
4. Test on device/emulator

## Reverting splash screen

To remove the custom splash: `dart run flutter_native_splash:remove`
