@echo off
setlocal

echo 🔄 Checking emulator list...
flutter emulators

echo 🔄 Launching emulator: my_pixel_5...
start "" "%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -avd my_pixel_5

echo ⏳ Waiting for emulator to boot up...
timeout /t 20 > NUL

echo 🔍 Checking connected devices...
flutter devices

echo 🚀 Running Flutter app...
flutter run

endlocal
pause
