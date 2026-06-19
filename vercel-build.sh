#!/bin/bash
echo "Installing Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"
flutter config --enable-web
echo "Running Flutter doctor..."
flutter doctor
echo "Building Flutter Web Application..."
flutter build web --release
