$env:Path = "$env:Path;D:\flutter\bin"
$javaHome = (Get-ChildItem "C:\Program Files\Microsoft" -Filter "jdk-*" -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1).FullName
if ($javaHome) {
  $env:JAVA_HOME = $javaHome
  $env:Path = "$env:Path;$javaHome\bin"
}
$androidHome = "D:\Android\Sdk"
if (Test-Path $androidHome) {
  $env:ANDROID_HOME = $androidHome
  $env:ANDROID_SDK_ROOT = $androidHome
  $env:Path = "$env:Path;$androidHome\platform-tools;$androidHome\cmdline-tools\latest\bin"
}
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release --dart-define=API_BASE_URL=https://api.marqueeflow.com
