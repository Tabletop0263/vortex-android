#!/bin/bash
# Main build script for Vortex Android APK

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================"
echo "Building Vortex Android APK"
echo "========================================"

# Set up environment
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-/root/android-sdk}"
export ANDROID_NDK_HOME="${ANDROID_NDK_HOME:-$ANDROID_SDK_ROOT/ndk/26.1.10909125}"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools"

# Source Rust if available
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

echo "Environment:"
echo "  ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
echo "  ANDROID_NDK_HOME=$ANDROID_NDK_HOME"
echo "  Rust: $(which cargo 2>/dev/null || echo 'not in PATH')"

# Step 1: Build Rust code (if source available)
if [ -f "$SCRIPT_DIR/build_rust.sh" ]; then
    echo ""
    echo "Step 1: Building Rust code..."
    "$SCRIPT_DIR/build_rust.sh" || echo "Rust build failed or skipped (source may not be available or host is ARM64)"
fi

# Step 2: Bundle libraries
if [ -f "$SCRIPT_DIR/bundle.sh" ]; then
    echo ""
    echo "Step 2: Bundling libraries..."
    "$SCRIPT_DIR/bundle.sh" || echo "Bundle step completed with warnings"
fi

# Step 3: Build APK with Gradle
echo ""
echo "Step 3: Building APK with Gradle..."
cd "$PROJECT_ROOT"

# Make gradlew executable
chmod +x gradlew

# Build debug APK
./gradlew --no-daemon assembleDebug

echo ""
echo "========================================"
echo "Build complete!"
echo "========================================"

# Show APK info if it exists
APK_PATH="$PROJECT_ROOT/app/build/outputs/apk/debug/app-debug.apk"
if [ -f "$APK_PATH" ]; then
    echo "APK size: $(du -h "$APK_PATH" | cut -f1)"
    echo "APK path: $APK_PATH"
else
    echo "APK not found (build may have failed)"
    echo ""
    echo "NOTE: On ARM64 hosts, the build fails because:"
    echo "  1. Android SDK build-tools (aapt2) are x86_64 only"
    echo "  2. NDK clang is x86_64 only"
    echo ""
    echo "Use GitHub Actions workflow (.github/workflows/build.yml) for building."
    echo "It runs on GitHub's x86_64 runners and uploads APK as artifact."
fi
