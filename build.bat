@echo off
REM Flutter Web Build Script for Windows
REM This script builds the Flutter web app and prepares it for deployment

echo ==========================================
echo Flutter Web Build Script
echo ==========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter not found!
    echo.
    echo Please install Flutter first. See FLUTTER_SETUP.md for instructions.
    echo Quick install: https://docs.flutter.dev/get-started/install/windows
    echo.
    pause
    exit /b 1
)

REM Display Flutter version
echo [INFO] Checking Flutter version...
flutter --version
echo.

REM Clean previous build
echo [INFO] Cleaning previous build...
flutter clean
echo.

REM Get dependencies
echo [INFO] Getting dependencies...
flutter pub get
echo.

REM Build web (release mode)
echo [INFO] Building web app (release mode)...
flutter build web --release
echo.

REM Check if build was successful
if %ERRORLEVEL% EQU 0 (
    echo ==========================================
    echo [SUCCESS] Build completed!
    echo ==========================================
    echo.
    echo Build output: build\web\
    echo.
    echo Next steps:
    echo 1. git add build/web
    echo 2. git commit -m "build: Update web build"
    echo 3. git push origin main
    echo.
) else (
    echo ==========================================
    echo [ERROR] Build failed!
    echo ==========================================
    echo.
    echo Please check the error messages above.
    echo.
)

pause
