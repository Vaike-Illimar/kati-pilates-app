# App Store & Google Play Submission Checklist

## Overview

This guide covers submitting the Kati Pilates app to both Apple App Store and Google Play Store.

---

## Prerequisites

- Apple Developer account (99 USD/year): [developer.apple.com](https://developer.apple.com)
- Google Play Developer account (25 USD one-time): [play.google.com/console](https://play.google.com/console)
- App ID / Bundle ID: `ee.katipilates.app`
- Xcode installed (latest stable)
- Android Studio installed

---

## App Metadata (Both Stores)

### App Name
`Kati Pilates`

### Short Description (Google Play, max 80 chars)
`Broneeri Kati pilateseklasside tunnid ja halda oma sessioonikaarti.`

### Full Description
```
Kati Pilates – lihtsaim viis oma pilateseklasside haldamiseks.

✓ Vaata tunniplaani ja broneeri tunnid kiiresti
✓ Haldab oma sessioonikaarti – näed alati järelejäänud tunde
✓ Püsirühma liikmed saavad automaatse broneeringu
✓ Ootejärjekord – saad teate, kui koht vabaneb
✓ Teavitused broneeringute ja kaardi kohta

Kati Pilates stuudio asub Tallinnas.
```

### Category
- App Store: **Health & Fitness**
- Google Play: **Health & Fitness**

### Keywords (App Store, comma-separated)
`pilates,treening,sport,broneerimine,stuudio,fitness,harjutus,Tallinn`

### Age Rating
- App Store: **4+**
- Google Play: **Everyone**

---

## iOS / App Store Submission

### Step 1: Configure Bundle ID in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select `Runner` target → **General**
3. Set **Bundle Identifier**: `ee.katipilates.app`
4. Set **Version**: `1.0.0`, **Build**: `1`

### Step 2: Configure Signing

1. In Xcode → **Signing & Capabilities**
2. Check **Automatically manage signing**
3. Select your **Team** from the dropdown
4. Xcode will create provisioning profile automatically

### Step 3: Add Required Capabilities

In **Signing & Capabilities**, add:
- **Push Notifications** (required for FCM)
- **Background Modes** → check **Remote notifications**

### Step 4: Add Privacy Descriptions to `Info.plist`

Add these keys to `ios/Runner/Info.plist`:
```xml
<!-- Photo library access for avatar upload -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Profiilipildi üleslaadimiseks</string>

<!-- Camera access for avatar photo -->
<key>NSCameraUsageDescription</key>
<string>Profiilipildi tegemiseks</string>
```

### Step 5: Set App Icon

1. Replace placeholder at `assets/icons/app_icon.png` with real 1024x1024 PNG (no transparency, no alpha)
2. Run: `flutter pub run flutter_launcher_icons`
3. Verify icons appear in Xcode → `Runner/Assets.xcassets/AppIcon.appiconset`

### Step 6: Build Release IPA

```bash
# From project root
flutter build ipa --release
```

The IPA will be at: `build/ios/archive/Runner.xcarchive`

Or use Xcode: **Product → Archive → Distribute App → App Store Connect**

### Step 7: Upload to App Store Connect

1. Open [App Store Connect](https://appstoreconnect.apple.com)
2. **My Apps** → **+** → **New App**
   - Platform: iOS
   - Name: `Kati Pilates`
   - Bundle ID: `ee.katipilates.app`
   - SKU: `kati-pilates-001`
3. Upload IPA via Xcode Organizer or Transporter app
4. Fill in:
   - Screenshots (required sizes: 6.7", 6.5", 5.5" iPhone; 12.9" iPad if applicable)
   - Description, keywords, support URL
   - Privacy policy URL (required — host a simple page)
5. Submit for review (typically 1-3 days)

### App Store Screenshots

Required for iPhone 6.7" (1290×2796 px) at minimum:
1. Schedule screen showing class list
2. Class detail / booking screen
3. My bookings screen
4. Session card screen
5. Profile / notifications screen

Use simulator: **iPhone 16 Pro Max** in Xcode, take screenshots with `Cmd+S`.

### Privacy Policy

Required for App Store. Minimum content:
- What data is collected (email, name, booking data)
- No selling to third parties
- Supabase as data processor
- Contact email for data requests

Host at e.g. `https://katipilates.ee/privacy`

---

## Android / Google Play Submission

### Step 1: Configure Package Name

In `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "ee.katipilates.app"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### Step 2: Add Privacy Permissions to AndroidManifest.xml

`android/app/src/main/AndroidManifest.xml` — verify these are present:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<!-- For Android < 13: -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
```

### Step 3: Set App Icon

1. Replace placeholder at `assets/icons/app_icon.png` with real 512x512+ PNG
2. Add foreground layer at `assets/icons/app_icon_foreground.png` (for adaptive icon)
3. Run: `flutter pub run flutter_launcher_icons`
4. Verify icons in `android/app/src/main/res/`

### Step 4: Build Release AAB

```bash
# Generate signing key (first time only)
keytool -genkey -v -keystore ~/kati-pilates-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias kati-pilates

# Add to android/key.properties (DO NOT commit this file)
# storePassword=<your_store_password>
# keyPassword=<your_key_password>
# keyAlias=kati-pilates
# storeFile=<path_to_keystore.jks>
```

Update `android/app/build.gradle` to use signing config:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Step 5: Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. **Create app** → Fill in details
3. Complete all required sections:
   - **App content**: Privacy policy URL, ads declaration (no ads), target audience
   - **Store listing**: Title, description, screenshots, feature graphic (1024×500 px)
   - **Content rating**: Complete questionnaire → rated Everyone
4. Go to **Testing → Internal testing** first to verify
5. Upload AAB in **Production → Releases**
6. Roll out (can start with 10% rollout)

### Google Play Screenshots

Required minimum: 2 phone screenshots (at least 320px on shortest side)
Recommended: same 5 screens as App Store.

---

## Post-Submission

### After App Store Approval
- Set release date or release immediately
- Illimar gets notified by Apple email

### After Google Play Approval
- Review typically takes 1-3 days for new apps
- Monitor **Android vitals** for crash reports

### Version Updates
For future updates:
- Increment `versionCode` (Android) and `CFBundleVersion` / Build number (iOS)
- `versionName` / `CFBundleShortVersionString` for user-visible version
- In `pubspec.yaml`: `version: 1.0.1+2` (version+build)

---

## Checklist Before Submission

- [ ] Real app icon (1024×1024 PNG, no alpha) in `assets/icons/app_icon.png`
- [ ] Splash screen image updated
- [ ] Privacy policy URL live and accessible
- [ ] Supabase project URL and anon key set (not placeholder)
- [ ] FCM configured (see `docs/fcm-setup.md`)
- [ ] All edge functions deployed (see `docs/deploy-edge-functions.md`)
- [ ] Deep links configured: `katipilates://` scheme
- [ ] Tested on real device (not just simulator)
- [ ] Release build tested (not debug)
- [ ] Screenshots taken and resized
- [ ] Keystore file backed up securely (Android)
