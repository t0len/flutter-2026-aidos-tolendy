# NOTES

`1.0.1+2` has two halves. `1.0.1` is versionName. People read it, and About shows it as `info.version`. `2` is versionCode. The Play Store reads it, and About shows it as `info.buildNumber`. The right half must go up on every upload. The store rejects a versionCode that is not higher than the last accepted one. The name can stay. Both numbers come from `pubspec.yaml` through `flutter.versionName` and `flutter.versionCode`. Hardcoding `versionCode = 1` in Gradle leaves About and the store on `(1)` after you bump the pubspec.

The upload key is `C:\Users\grana\upload-keystore.jks`. A second copy is `C:\Users\grana\key-backup\upload-keystore.jks`. Copy that file onto a USB stick that does not stay in this laptop. The password is not written here.

If the key and `kz.aidostolendy.users` had been committed, a classmate could sign an APK with the same id. A phone that already trusts that key would install it as an update and the new build could read the app's data. Play App Signing keeps the app signing key on Google's side. Devices trust Google's key, not the upload key. A leaked upload key can be used to upload, and Google can reset it. It cannot sign the APK people already installed. If the leaked key was the one devices already trust, because the app was shipped before Play App Signing, that applicationId is stuck to the leaked key.

Two commands that remove a file from history:

```
git filter-repo --path android/key.properties --invert-paths
git filter-repo --path upload-keystore.jks --invert-paths
```

`String.fromEnvironment` is fixed when the binary is compiled. A tester cannot change it without a new build. The developer host is stored in shared preferences and read on the next request, so one debug build can point at another host. That tile is inside `if (kDebugMode)`. A release build is the file a stranger installs. A host picker in it is a back door, and `kDebugMode` is false there, so the tile is not in the tree.

`releases/1.0.1+2/app-arm64-v8a-release.apk` is 17.2MB. `flutter build apk --debug` wrote `app-debug.apk` at 155.5MB. The symbols for the release build are `releases/1.0.1+2/symbols/`. Without them a crash is only an address:

```
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
#00 abs 00000000 virt 00000000 _kDartIsolateSnapshotInstructions+0x1a2b3c
```

```
flutter symbolize -i crash.txt -d releases/1.0.1+2/symbols
```

That turns the address back into a file and a line.

```
keytool -printcert -jarfile releases/1.0.1+2/app-arm64-v8a-release.apk
```

```
Owner: CN=Aidos Tolendy, OU=Users, O=Aidos Tolendy, L=Almaty, ST=Almaty, C=KZ
Issuer: CN=Aidos Tolendy, OU=Users, O=Aidos Tolendy, L=Almaty, ST=Almaty, C=KZ
Signature algorithm name: SHA384withRSA
Subject Public Key Algorithm: 2048-bit RSA key
```
