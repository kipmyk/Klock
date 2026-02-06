#!/bin/bash

# Exit on error
set -e

APP_NAME="Klock"
BUNDLE_ID="com.kipmyk.klock"
APP_BUNDLE="${APP_NAME}.app"
DMG_NAME="${APP_NAME}.dmg"

echo "🔨 Building ${APP_NAME} in release mode..."
swift build -c release

# Dynamically find the binary path
BIN_PATH=$(swift build -c release --show-bin-path)
EXECUTABLE="${BIN_PATH}/${APP_NAME}"

if [ ! -f "${EXECUTABLE}" ]; then
    echo "❌ Error: Executable not found at ${EXECUTABLE}"
    exit 1
fi

echo "📦 Creating app bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy the executable
cp "${EXECUTABLE}" "${APP_BUNDLE}/Contents/MacOS/"

# Copy Info.plist
cp "Info.plist" "${APP_BUNDLE}/Contents/"

echo "💿 Creating DMG..."
rm -f "${DMG_NAME}"
hdiutil create -volname "${APP_NAME}" -srcfolder "${APP_BUNDLE}" -ov -format UDZO "${DMG_NAME}"

echo "✅ Done! ${DMG_NAME} created successfully."

SHA256=$(shasum -a 256 "${DMG_NAME}" | awk '{print $1}')
echo "--------------------------------------------------"
echo "SHA256 Checksum for Homebrew Cask:"
echo "${SHA256}"
echo "--------------------------------------------------"
