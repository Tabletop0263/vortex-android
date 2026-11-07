# Vortex Android

Android port of the Vortex game (playvortex.io) - a Roblox-like gaming platform built with Rust/Bevy.

## Project Structure

```
vortex-android/
├── app/                    # Android app module
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/playvortex/vortex/  # Kotlin code
│   │   │   ├── cpp/                         # JNI C++ bridge
│   │   │   ├── jniLibs/arm64-v8a/           # Rust .so libraries (built separately)
│   │   │   ├── assets/                      # Game assets
│   │   │   └── AndroidManifest.xml
│   ├── build.gradle.kts
│   └── CMakeLists.txt
├── scripts/
│   ├── extract.sh      # Extract AppImage and copy assets
│   ├── build_rust.sh   # Build Rust code for Android
│   ├── bundle.sh       # Bundle libraries and assets
│   └── build.sh        # Main build script
├── gradle/
├── build.gradle.kts
├── settings.gradle.kts
└── gradlew
```

## Prerequisites

- Android SDK (cmdline-tools, platform-tools, build-tools, platform-34)
- Android NDK (r26+)
- Rust with `aarch64-linux-android` target
- Gradle 8.5+ (wrapper included)
- JDK 17+

### Termux / proot-distro Ubuntu Setup

```bash
# Install dependencies
apt-get update && apt-get install -y \
    openjdk-17-jdk-headless \
    git \
    cmake \
    ninja-build \
    pkg-config \
    libssl-dev \
    clang \
    lld \
    squashfs-tools \
    imagemagick

# Install Android SDK
mkdir -p $HOME/android-sdk/cmdline-tools
cd $HOME/android-sdk/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-11076708_latest.zip
mv cmdline-tools latest
export ANDROID_SDK_ROOT=$HOME/android-sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# Install SDK components
sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "ndk;26.1.10909125"

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustup target add aarch64-linux-android
```

## Build Instructions

### 1. Extract AppImage Assets (optional)
```bash
./scripts/extract.sh
```

### 2. Build Rust Code for Android
```bash
# Place full Vortex Rust source in ../vortex-src/
./scripts/build_rust.sh
```

### 3. Bundle Libraries and Assets
```bash
./scripts/bundle.sh
```

### 4. Build APK
```bash
./scripts/build.sh
# OR manually:
./gradlew assembleDebug
```

The APK will be at: `app/build/outputs/apk/debug/app-debug.apk`

## Architecture

This is a **Rust/Bevy game**, not an Electron app. The Android port uses:

1. **NativeActivity** - Android's native app framework for games
2. **Rust compiled to .so** - The Bevy game engine and game logic compiled for `aarch64-linux-android`
3. **JNI Bridge** - Minimal Kotlin/C++ glue code to interface with Android lifecycle
4. **Vulkan/OpenGL ES** - Rendering via Bevy's wgpu backend

### Key Components

- `VortexNativeActivity.kt` - Main activity extending NativeActivity
- `native-lib.cpp` - JNI bridge calling Rust entry points
- Rust entry points needed:
  - `vortex_init()` - Initialize game engine
  - `vortex_main_loop()` - Run game loop
  - `vortex_handle_input()` - Handle touch/input events
  - `vortex_handle_window_change()` - Handle surface changes
  - `vortex_save_state()` - Save game state
  - `vortex_destroy()` - Cleanup

## Limitations

⚠️ **IMPORTANT**: The available source code is a **partial decompilation/reconstruction** (from playvortex.io source leak), not the full game source. Key missing pieces:

1. **Full Bevy game loop** - The reconstructed source only has data structures/protocols
2. **Rendering code** - Bevy/wgpu rendering setup not in source
3. **Asset loading** - Game assets (models, textures, sounds) not in source
4. **Networking** - Game server protocol implementation incomplete
5. **Luau scripting** - Scripting VM integration not in source

### What Would Be Needed for a Complete Port

1. Full Vortex game source code (not just the leaked reconstruction)
2. Bevy 0.14+ with Android support (wgpu Vulkan backend)
3. All game assets (3D models, textures, audio, UI)
4. Luau VM compiled for Android
5. Game server connection implementation

## License

This project is based on Vortex (playvortex.io). The original game is proprietary.
This Android port is for educational/research purposes only.

The source code reconstruction used here was leaked by @azixi0 and is not officially licensed.
