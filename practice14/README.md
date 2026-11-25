# prac14

Users. One codebase, local and production. A release is the arm64 APK with every box below ticked.

```
flutter run
flutter run --dart-define=USE_FAKES=true
flutter run --dart-define-from-file=env/local.json
flutter build apk --release --dart-define-from-file=env/prod.json
```

The file you install:

```
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols --dart-define-from-file=env/prod.json
```

`releases/1.0.1+2/app-arm64-v8a-release.apk` is the phone build. `flutter build appbundle --release --dart-define-from-file=env/prod.json` produces an `.aab`. That file is for the Play Store. It does not install on a phone.

```
flutter analyze
No issues found!
```

```
dart format .
Formatted 32 files (0 changed)
```

```
flutter test
00:08 +9: All tests passed!
```

```
tool/check_layers.sh
```

## Pre-release

- [x] applicationId is reverse-domain — `build.gradle.kts`
- [x] minSdk, targetSdk, versionCode, versionName come from flutter.* — `build.gradle.kts`
- [x] pubspec version bumped — `pubspec.yaml`
- [x] `*.jks`, `*.keystore`, `android/key.properties`, `env/*.local.json` ignored — `.gitignore`
- [x] release signingConfig is release, minify on — `build.gradle.kts`
- [x] certificate is the upload key — `keytool`
- [x] fromEnvironment only in env.dart — `grep`
- [x] USE_FAKES, env/local.json, env/prod.json — `env.dart`
- [x] four commands above — `README.md`
- [x] About shows version, build, mode, Env.name, Env.host, licences — `about_screen.dart`
- [x] developer host switch only in kDebugMode — `settings_screen.dart`
- [x] adaptive icon, Android 12 splash, name Users — `AndroidManifest.xml`
- [x] INTERNET in the main manifest — `AndroidManifest.xml`
- [x] arm64 APK obfuscated, symbols archived — `releases/1.0.1+2`
