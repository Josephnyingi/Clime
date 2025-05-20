@echo off
setlocal

:: Step 1 - Start Emulator
echo 🔄 Launching emulator: my_pixel_5...
start "" "%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -avd my_pixel_5

:: Step 2 - Wait for emulator to boot (adjust time as needed)
echo ⏳ Waiting for emulator to boot up...
timeout /t 15 > NUL

:: Step 3 - Build and run Flutter app
echo 🚀 Running Flutter app...
flutter run

endlocal
pause
