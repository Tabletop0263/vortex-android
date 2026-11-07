#!/bin/bash
# Build script for compiling Rust/Bevy game for Android
# This script assumes the full Rust source code is available in ../vortex-src/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
RUST_SRC_DIR="$PROJECT_ROOT/../vortex-src"  # Adjust path as needed
ANDROID_JNI_LIBS="$PROJECT_ROOT/app/src/main/jniLibs/arm64-v8a"

echo "Building Vortex Rust game for Android..."
echo "Rust source: $RUST_SRC_DIR"
echo "Output: $ANDROID_JNI_LIBS"

# Check if Rust source exists
if [ ! -d "$RUST_SRC_DIR" ]; then
    echo "ERROR: Rust source not found at $RUST_SRC_DIR"
    echo "Please place the full Vortex Rust source code there."
    exit 1
fi

# Ensure Android target is installed
echo "Checking Rust Android target..."
rustup target add aarch64-linux-android

# Create jniLibs directory
mkdir -p "$ANDROID_JNI_LIBS"

# Build the Rust project for Android
cd "$RUST_SRC_DIR"

# Build vortex-engine as a dynamic library
echo "Building vortex-engine..."
cargo build --package vortex-engine-recovered --target aarch64-linux-android --release

# Build vortex-client as a dynamic library
echo "Building vortex-client..."
cargo build --package vortex-client-recovered --target aarch64-linux-android --release

# Copy the built libraries
echo "Copying libraries to jniLibs..."
cp target/aarch64-linux-android/release/libvortex_engine.so "$ANDROID_JNI_LIBS/" 2>/dev/null || echo "libvortex_engine.so not found"
cp target/aarch64-linux-android/release/libvortex_client_recovered.so "$ANDROID_JNI_LIBS/libvortex_client.so" 2>/dev/null || echo "libvortex_client_recovered.so not found"

# Also copy any dependent .so files
find target/aarch64-linux-android/release/deps -name "*.so" -exec cp {} "$ANDROID_JNI_LIBS/" \; 2>/dev/null || true

echo "Rust build complete!"
echo "Libraries in $ANDROID_JNI_LIBS:"
ls -la "$ANDROID_JNI_LIBS"
