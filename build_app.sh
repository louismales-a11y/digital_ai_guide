#!/bin/bash
cd "$(dirname "$0")"

export JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"
export ANDROID_SDK_ROOT="/c/Users/lousc/AppData/Local/Android/Sdk"
export FLUTTER_ROOT="/c/Users/lousc/Downloads/flutter_windows_3.44.2-stable/flutter"
export PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$FLUTTER_ROOT/bin:$PATH"

echo "🔨 Building Digital AI Guide..."
flutter build apk --release

if [ $? -eq 0 ]; then
  VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
  FILENAME="digital-ai-guide-v${VERSION}.apk"
  cp build/app/outputs/flutter-apk/app-release.apk "build/app/outputs/flutter-apk/${FILENAME}"
  echo ""
  echo "✅ Build complete!"
  echo "📦 ${FILENAME}"
  ls -lh "build/app/outputs/flutter-apk/${FILENAME}"
else
  echo "❌ Build failed"
  exit 1
fi
