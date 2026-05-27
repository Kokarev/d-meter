# D-METER

Fuel density and escalation calculator for EN ISO workflows.
macOS desktop app built with Flutter.

## Features

- EN / UK localization with in-app switcher
- VAC / AIR density conversion (EN ISO 91-1)
- Density at temperature calculator (EN ISO 12185)
- Price escalation calculator
- Regression-tested business logic

## Stack

Flutter · Provider · Material 3 · SharedPreferences

## Setup

```bash
flutter pub get
flutter gen-l10n
flutter run -d macos
```

## Testing

```bash
flutter analyze   # must be clean
flutter test      # all tests must pass
```

## iOS (local install)

### Requirements
- Xcode 26+
- Apple ID (free)
- iPhone with Developer Mode enabled

### Steps
1. Open `ios/Runner.xcworkspace` in Xcode
2. Signing & Capabilities → Team → your Apple ID
3. Bundle Identifier → `com.kokarev.dmeter`
4. iPhone: Settings → Privacy & Security → Developer Mode → enable
5. Connect iPhone via cable
6. `flutter run -d <device-id>`

> Free Apple ID certificate expires after 7 days. Re-run to renew.

## Versioning

| Version | Description |
|---------|-------------|
| v1.0.0  | EN/UK localization baseline |
| v1.1.0  | Locale persistence + EN/УК switcher |
| v1.2.0  | Settings screen + version info |
| v1.2.1  | macOS minimum window constraints |
| v1.2.2  | Deterministic DMG build script |

## Standards

Formulas: EN ISO 91-1 · EN ISO 12185
Units: SI (kg/m³, kg/l, °C, m³, t)
Basis: VAC / AIR per ISO convention
