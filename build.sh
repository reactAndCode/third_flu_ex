#!/bin/bash
# Flutter Web Build Script for Unix/Git Bash
# This script builds the Flutter web app and prepares it for deployment

set -e  # Exit on error

echo "=========================================="
echo "Flutter Web Build Script"
echo "=========================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "[ERROR] Flutter not found!"
    echo ""
    echo "Please install Flutter first. See FLUTTER_SETUP.md for instructions."
    echo "Quick install: https://docs.flutter.dev/get-started/install/windows"
    echo ""
    exit 1
fi

# Display Flutter version
echo "[INFO] Checking Flutter version..."
flutter --version
echo ""

# Clean previous build
echo "[INFO] Cleaning previous build..."
flutter clean
echo ""

# Get dependencies
echo "[INFO] Getting dependencies..."
flutter pub get
echo ""

# Build web (release mode)
echo "[INFO] Building web app (release mode)..."
flutter build web --release
echo ""

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "=========================================="
    echo "[SUCCESS] Build completed!"
    echo "=========================================="
    echo ""
    echo "Build output: build/web/"
    echo ""
    echo "Next steps:"
    echo "1. git add build/web"
    echo "2. git commit -m 'build: Update web build'"
    echo "3. git push origin main"
    echo ""
else
    echo "=========================================="
    echo "[ERROR] Build failed!"
    echo "=========================================="
    echo ""
    echo "Please check the error messages above."
    echo ""
    exit 1
fi
