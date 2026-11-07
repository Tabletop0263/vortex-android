#!/bin/bash
# Extract script for the Vortex AppImage
# This extracts the AppImage and prepares assets for Android

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APPIMAGE_PATH="${APPIMAGE_PATH:-$PROJECT_ROOT/../Vortex-linux-x86_64.AppImage}"
EXTRACT_DIR="$PROJECT_ROOT/../extracted"
ASSETS_DIR="$PROJECT_ROOT/app/src/main/assets"

echo "========================================"
echo "Extracting Vortex AppImage"
echo "========================================"

if [ ! -f "$APPIMAGE_PATH" ]; then
    echo "WARNING: AppImage not found at $APPIMAGE_PATH"
    echo "Skipping extraction. Using existing assets."
    exit 0
fi

# Find squashfs offset
echo "Finding squashfs offset..."
OFFSET=$(strings -t d "$APPIMAGE_PATH" | grep "hsqs" | tail -1 | awk '{print $1}')
if [ -z "$OFFSET" ]; then
    echo "ERROR: Could not find squashfs offset"
    exit 1
fi
echo "Found squashfs at offset: $OFFSET"

# Extract
echo "Extracting to $EXTRACT_DIR..."
rm -rf "$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR"
unsquashfs -o "$OFFSET" -d "$EXTRACT_DIR" "$APPIMAGE_PATH"

# Copy assets to Android project
echo "Copying assets to Android project..."
mkdir -p "$ASSETS_DIR"

# Copy any game assets from extracted AppImage
if [ -d "$EXTRACT_DIR/usr/share/vortex" ]; then
    cp -r "$EXTRACT_DIR/usr/share/vortex"/* "$ASSETS_DIR/" 2>/dev/null || true
fi

if [ -d "$EXTRACT_DIR/usr/lib/vortex" ]; then
    cp -r "$EXTRACT_DIR/usr/lib/vortex"/* "$ASSETS_DIR/" 2>/dev/null || true
fi

# Copy icon
cp "$EXTRACT_DIR/usr/share/icons/hicolor/512x512/apps/io.playvortex.Vortex.png" "$ASSETS_DIR/icon.png" 2>/dev/null || true

echo "Extraction complete!"
echo "Assets copied to: $ASSETS_DIR"
ls -la "$ASSETS_DIR"
