#!/bin/bash
# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
# Build the Flutter app for web
flutter pub get
flutter build web