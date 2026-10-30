# Local builds of this fork

Both FOSS and Google Play builds provide all premium features through `UnlockedUpgradeRepo` without a purchase or donation. Upgrade navigation opens an informational screen. Original billing implementations remain in the source, but are not bound as the feature-access repository.

## Windows build

From the repository folder, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\build-local.ps1 -Test
```

The script downloads and verifies portable Temurin JDK 21 and Android command-line tools, installs Android SDK 36, and builds a signed FOSS debug APK. The first run requires internet access and several GB of disk space. Review the SDK licenses when prompted. To explicitly accept them without prompting, add `-AcceptAndroidSdkLicenses`.

Output:

```text
app/build/outputs/apk/foss/debug/app-foss-debug.apk
```

Use `-Flavor Gplay` to build the Google Play variant. `-Test` also runs the feature-access regression test; omit it to build only the APK.

Downloaded tools, caches, and the debug keystore are under `.local/build-tools/`, which is ignored by Git. Keep this directory to reuse the tools and signing key. Back up `.local/build-tools/android-user/debug.keystore` privately if you need future builds to update an installed copy without uninstalling it. Do not commit the key.

Requires Android 8.0 or newer. This APK uses a local debug signing key and cannot update the official CAPod installation signed by its developer. Uninstalling the official app clears its local data. It also cannot update another custom build unless that build used the same signing key.

## Existing development environment

With JDK 21 and Android SDK 36 configured, the usual Gradle commands also work:

```powershell
.\gradlew.bat :app:assembleFossDebug
.\gradlew.bat :app:testFossDebugUnitTest --tests '*UnlockedUpgradeRepoTest'
```
