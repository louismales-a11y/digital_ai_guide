#!/bin/bash
cd "$(dirname "$0")"

# === AUTO VERSION BUMP ===
OLD_VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
MAJOR=$(echo $OLD_VERSION | cut -d'.' -f1)
MINOR=$(echo $OLD_VERSION | cut -d'.' -f2)
PATCH=$(echo $OLD_VERSION | cut -d'+' -f1 | cut -d'.' -f3)
BUILD=$(echo $OLD_VERSION | cut -d'+' -f2)

NEW_PATCH=$((PATCH + 1))
NEW_BUILD=$((BUILD + 1))
NEW_VERSION="${MAJOR}.${MINOR}.${NEW_PATCH}+${NEW_BUILD}"

# Update pubspec.yaml
sed -i "s/version: ${OLD_VERSION}/version: ${NEW_VERSION}/" pubspec.yaml

# === CONFIG ===
JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"
ANDROID_SDK_ROOT="/c/Users/lousc/AppData/Local/Android/Sdk"
FLUTTER_ROOT="/c/Users/lousc/Downloads/flutter_windows_3.44.2-stable/flutter"
PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$FLUTTER_ROOT/bin:$PATH"

# === UPDATE VERSION SERVICE ===
SED="sed -i"
$SED "s/static const String version = '.*';/static const String version = '${MAJOR}.${MINOR}.${NEW_PATCH}';/" lib/services/version_service.dart
$SED "s/static const int buildNumber = .*/static const int buildNumber = ${NEW_BUILD};/" lib/services/version_service.dart

echo "══════════════════════════════════════════════════"
echo "  Building Digital AI Guide v${NEW_VERSION}"
echo "  (was v${OLD_VERSION})"
echo "══════════════════════════════════════════════════"
echo ""

# === BUILD ANDROID ===
echo "🔨 Building Android APK..."
flutter build apk --release 2>&1 | tail -1
if [ $? -eq 0 ]; then
  cp build/app/outputs/flutter-apk/app-release.apk "build/app/outputs/flutter-apk/digital-ai-guide-v${NEW_VERSION}.apk"
  echo "✅ Android: digital-ai-guide-v${NEW_VERSION}.apk"
else
  echo "❌ Android build failed"
fi

# === BUILD WINDOWS ===
echo ""
echo "🔨 Building Windows EXE..."
flutter build windows --release 2>&1 | tail -1
if [ $? -eq 0 ]; then
  cd build/windows/x64/runner
  tar -czf "digital-ai-guide-windows-v${NEW_VERSION}.tar.gz" Release/
  echo "✅ Windows: digital-ai-guide-windows-v${NEW_VERSION}.tar.gz"
  cd ../../../..
else
  echo "❌ Windows build failed"
fi

# === SUMMARY ===
echo ""
echo "══════════════════════════════════════════════════"
echo "  Build Complete — v${NEW_VERSION}"
echo "══════════════════════════════════════════════════"
echo ""
echo "📱 Android: build/app/outputs/flutter-apk/digital-ai-guide-v${NEW_VERSION}.apk"
echo "💻 Windows: build/windows/x64/runner/digital-ai-guide-windows-v${NEW_VERSION}.tar.gz"
echo ""
