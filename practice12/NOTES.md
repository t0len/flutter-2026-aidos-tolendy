# NOTES

## Package verdicts

shared_preferences: verified publisher flutter.dev, released October 2026, all six platforms, 160 points, BSD-3-Clause, depends only on its own platform implementations, and that October release is the recent commit while issues stay in flutter/packages.

flutter_secure_storage: publisher steenbakker.dev, released September 2026, all six platforms, 160 points, BSD-3-Clause, depends on its platform packages plus meta, and that September release is the recent commit on mogol/flutter_secure_storage.

path_provider: verified publisher flutter.dev, released June 2026, five platforms and no web, 160 points, BSD-3-Clause, depends only on its own platform implementations, and the June release is older, so the commits are quieter than the others.

image_picker: verified publisher flutter.dev, released October 2026, all six platforms, 160 points, Apache-2.0 and BSD-3-Clause, depends only on its platform implementations, and that October release is the recent commit in flutter/packages.

permission_handler: publisher baseflow.com, released September 2026, Android, iOS, Windows and web, 160 points, MIT, depends on meta and its platform implementations, and that September release is the recent commit on baseflow/flutter-permission-handler.

url_launcher: verified publisher flutter.dev, released October 2026, all six platforms, 160 points, BSD-3-Clause, depends only on its platform implementations, and that October release is the recent commit in flutter/packages.

## The caret and the lock

`flutter pub add` wrote `http: ^1.6.0`. `pubspec.lock` resolved http to exactly 1.6.0.

`^1.2.0` accepts every version `>=1.2.0` and `<2.0.0`: 1.2.0, 1.2.1, 1.6.0, 1.9.9. It refuses 1.1.9 and anything below 1.2.0, and it refuses 2.0.0 and anything above, because on a 1.x version the caret may not change the first digit.

`http: 1.2.0` with the caret removed accepts only 1.2.0. `flutter pub get` then pins the lock to that exact version, and `flutter pub outdated` shows every newer http as unavailable. The caret goes back so the range stays open; the lock still records the version this app actually got.

`pubspec.lock` is committed because this is an app, the root of the graph. The caret in `pubspec.yaml` is the allowed range. The lock is the resolution, so a clone and CI build the same graph. A library leaves the lock uncommitted so its users can resolve; an app should not.

`flutter pub outdated`: cupertino_icons is 1.0.9 and 2.0.0 exists. It was not upgraded because the constraint is `^1.0.8`, which stops before 2.0.0. `flutter pub upgrade` cannot cross that major bump.

## Level 3 — where a token must not go

`prefs.setString('token', ...)` would write the token into shared preferences: a plain XML file in the app folder on Android, and a plist in the app container on iOS. A backup, a rooted device, or a cable can read that file. The token is not stored there. It goes through `SecureStore` into `flutter_secure_storage`, which is the Android Keystore and the iOS Keychain. It is never printed.

iOS may keep a Keychain item after the app is uninstalled, so a reinstall can come back already signed in. Android may invalidate Keystore keys when the lock screen is removed, and the next read of the token then fails.

## Level 5 — the No

On iOS the camera dialog appears once. The first No is already `permanentlyDenied`, so the next tap does not show the system dialog and our dialog opens instead. One No is enough.

The fourth photo-library state is `limited`: the user allowed only selected photos (iOS 14+). `restricted` is the other status the switch handles, when the OS itself will not let the user decide.
