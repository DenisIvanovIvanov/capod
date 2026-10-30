[CmdletBinding()]
param(
    [ValidateSet('Foss', 'Gplay')][string]$Flavor = 'Foss',
    [switch]$Test,
    [switch]$AcceptAndroidSdkLicenses
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$taskTools = Join-Path $PSScriptRoot '.local/build-tools'
New-Item -ItemType Directory -Force $taskTools | Out-Null

function Get-CheckedArchive([string]$Url, [string]$Path, [string]$Sha256) {
    if (!(Test-Path -LiteralPath $Path) -or (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash -ne $Sha256) {
        Write-Host "Downloading $Url"
        Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $Path
    }
    if ((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash -ne $Sha256) {
        throw "SHA-256 checksum mismatch: $Path"
    }
}

# Keep tools, Gradle caches, and the reusable debug signing key inside this ignored folder.
$taskJdkRoot = Join-Path $taskTools 'jdk'
$taskJava = Get-ChildItem -LiteralPath $taskJdkRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'bin/java.exe') } |
    Select-Object -First 1
if (!$taskJava) {
    $taskAsset = @(Invoke-RestMethod 'https://api.adoptium.net/v3/assets/latest/21/hotspot?architecture=x64&image_type=jdk&os=windows&vendor=eclipse')[0].binary.package
    $taskZip = Join-Path $taskTools 'jdk.zip'
    Get-CheckedArchive $taskAsset.link $taskZip $taskAsset.checksum
    Expand-Archive -LiteralPath $taskZip -DestinationPath $taskJdkRoot -Force
    $taskJava = Get-ChildItem -LiteralPath $taskJdkRoot -Directory | Select-Object -First 1
}
$env:JAVA_HOME = $taskJava.FullName
$env:PATH = "$env:JAVA_HOME/bin;$env:PATH"
$env:ANDROID_HOME = Join-Path $taskTools 'android-sdk'
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:ANDROID_USER_HOME = Join-Path $taskTools 'android-user'
$env:GRADLE_USER_HOME = Join-Path $taskTools 'gradle-cache'
$taskSdkManager = Join-Path $env:ANDROID_HOME 'cmdline-tools/latest/bin/sdkmanager.bat'
if (!(Test-Path -LiteralPath $taskSdkManager)) {
    $taskZip = Join-Path $taskTools 'android-tools.zip'
    Get-CheckedArchive 'https://dl.google.com/android/repository/commandlinetools-win-15859902_latest.zip' $taskZip '90ae805d20434428bffcb699c290860f19bb5f66a67e6b330067e3de801fb04a'
    $taskStage = Join-Path $taskTools 'android-tools-stage'
    Expand-Archive -LiteralPath $taskZip -DestinationPath $taskStage -Force
    New-Item -ItemType Directory -Force (Join-Path $env:ANDROID_HOME 'cmdline-tools') | Out-Null
    Move-Item -LiteralPath (Join-Path $taskStage 'cmdline-tools') -Destination (Join-Path $env:ANDROID_HOME 'cmdline-tools/latest')
}

if ($AcceptAndroidSdkLicenses) {
    1..20 | ForEach-Object { 'y' } | & $taskSdkManager "--sdk_root=$env:ANDROID_HOME" --licenses
} else {
    # Interactive on first use so the caller can review the SDK terms.
    & $taskSdkManager "--sdk_root=$env:ANDROID_HOME" --licenses
}
if ($LASTEXITCODE -ne 0) { throw 'Android SDK license setup failed.' }
& $taskSdkManager "--sdk_root=$env:ANDROID_HOME" 'platforms;android-36' 'build-tools;36.0.0' 'platform-tools'
if ($LASTEXITCODE -ne 0) { throw 'Android SDK package installation failed.' }

$taskGradleArgs = @(":app:assemble${Flavor}Debug", '--console=plain', '--max-workers=4')
if ($Test) {
    $taskGradleArgs += @(":app:test${Flavor}DebugUnitTest", '--tests', '*UnlockedUpgradeRepoTest')
}
Push-Location $PSScriptRoot
try {
    & ./gradlew.bat @taskGradleArgs
    if ($LASTEXITCODE -ne 0) { throw "Gradle failed with exit code $LASTEXITCODE" }
    $taskApk = Join-Path $PSScriptRoot "app/build/outputs/apk/$($Flavor.ToLowerInvariant())/debug/app-$($Flavor.ToLowerInvariant())-debug.apk"
    & (Join-Path $env:ANDROID_HOME 'build-tools/36.0.0/apksigner.bat') verify $taskApk
    if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed.' }
    Write-Host "APK: $taskApk"
} finally {
    Pop-Location
}
