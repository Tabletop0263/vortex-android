#!/bin/bash
# Bundle script - prepares the Android project for building
# This copies Rust libraries, assets, and configures the project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
JNI_LIBS_DIR="$PROJECT_ROOT/app/src/main/jniLibs/arm64-v8a"
RUST_TARGET_DIR="$PROJECT_ROOT/../vortex-src/target/aarch64-linux-android/release"

echo "========================================"
echo "Bundling Vortex Android Project"
echo "========================================"

# Create jniLibs directory
mkdir -p "$JNI_LIBS_DIR"

# Copy Rust libraries if they exist
if [ -d "$RUST_TARGET_DIR" ]; then
    echo "Copying Rust libraries from $RUST_TARGET_DIR..."
    cp "$RUST_TARGET_DIR"/libvortex_engine.so "$JNI_LIBS_DIR/" 2>/dev/null || true
    cp "$RUST_TARGET_DIR"/libvortex_client_recovered.so "$JNI_LIBS_DIR/libvortex_client.so" 2>/dev/null || true
    cp "$RUST_TARGET_DIR"/deps/*.so "$JNI_LIBS_DIR/" 2>/dev/null || true
    echo "Libraries copied:"
    ls -la "$JNI_LIBS_DIR"
else
    echo "WARNING: Rust target directory not found at $RUST_TARGET_DIR"
    echo "Run ./scripts/build_rust.sh first to build the Rust code"
    echo ""
    echo "NOTE: On ARM64 hosts (like Termux/proot), the NDK's clang is x86_64 only."
    echo "      Building native code requires x86_64 host (use GitHub Actions workflow)."
fi

# Verify assets
echo ""
echo "Assets directory:"
ls -la "$PROJECT_ROOT/app/src/main/assets/" 2>/dev/null || echo "No assets directory"

echo ""
echo "Bundle complete!"
echo "To build the APK, use GitHub Actions workflow or run on x86_64 machine:"
echo "  ./gradlew assembleDebug"
