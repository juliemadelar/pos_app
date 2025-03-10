@echo off
echo Rebuilding project...
flutter pub get
flutter clean
flutter build
echo Rebuild complete.
