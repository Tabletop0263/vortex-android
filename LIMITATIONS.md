# Limitations and Stubs

## Overview
This Android port is a **structural skeleton** - it compiles and produces an APK, but the actual game logic cannot run because the full Rust/Bevy source code is not available. Only a partial decompilation/reconstruction exists.

## What Works (Compiles & Packages)

✅ **Android Project Structure**
- Gradle build system (Kotlin DSL)
- NativeActivity-based architecture
- Proper manifest with permissions
- Icons and resources
- JNI bridge (C++ → Rust stubs)

✅ **Build System**
- `./gradlew assembleDebug` produces APK
- Rust build script (ready for when source is available)
- Asset extraction script
- Bundle script

✅ **Architecture Ready For**
- Rust `aarch64-linux-android` compilation
- wgpu Vulkan rendering on Android
- winit Android window/input handling
- Bevy ECS game loop

---

## What's Stubbed / Missing (Cannot Run Actual Game)

### ❌ Full Game Source Code
**Status**: STUBBED - Only partial reconstruction available
- The leaked source (`vortex-src/`) is a **behavioral reconstruction** from a decompilation
- Contains: data structures, protocol definitions, scripting interfaces
- Missing: Bevy App setup, rendering pipeline, game systems, asset loading, networking implementation
- **Impact**: Game cannot actually run - only the Android wrapper compiles

### ❌ Rust Game Libraries (.so files)
**Status**: STUBBED - Placeholder library created
- `libvortex-native.so` is a minimal stub with empty JNI functions
- Real libraries would be: `libvortex_engine.so`, `libvortex_client.so`, plus dependencies
- **Impact**: APK installs but crashes on launch (no game code)

### ❌ Game Assets
**Status**: STUBBED - Only icon extracted
- No 3D models, textures, materials, audio, UI assets
- No Luau script bytecode or prelude
- **Impact**: Even with full source, game would have no content

### ❌ Luau Scripting VM Integration
**Status**: STUBBED - Interface definitions only
- Source has `ScriptRuntime`, `ScriptRuntimes` structs but no VM implementation
- Need: `mlua` or `luau` crate compiled for Android + game binding code
- **Impact**: User-generated content (scripts) won't work

### ❌ Networking Implementation
**Status**: STUBBED - Protocol definitions only
- Source has `Packet`, `PlayerFrame`, `PlayerState` structs
- Missing: Actual TCP/UDP connection, serialization, encryption, server handshake
- **Impact**: Cannot connect to playvortex.io servers

### ❌ Physics (avian3d)
**Status**: STUBBED - Data structures only
- Source has `Vec3Data`, physics-related structs
- Missing: avian3d plugin setup, collision systems, ragdoll simulation
- **Impact**: No physics simulation

### ❌ Rendering Pipeline
**Status**: STUBBED - Not in source at all
- No wgpu/Bevy render graph setup
- No shaders (WGSL), material system, PBR pipeline
- No UI rendering (bevy_ui / bevy_egui setup)
- **Impact**: Nothing renders

### ❌ Audio System
**Status**: STUBBED - Not in source
- No `bevy_audio` setup, no audio assets
- Android needs `cpal`/`rodio` backend configuration
- **Impact**: No sound

### ❌ Input Handling
**Status**: STUBBED - JNI bridge exists but no Rust implementation
- `VortexNativeActivity` forwards touch/events to native
- Rust side needs `winit` Android event handling + Bevy input systems
- **Impact**: No player control

### ❌ AppImage Update Mechanism
**Status**: STUBBED - Not applicable to Android
- Desktop uses AppImage delta updates
- Android would need: Google Play updates, or custom in-app update
- **Impact**: No auto-update (acceptable for debug build)

---

## Android-Specific Limitations

### ⚠️ Vulkan Requirement
- Bevy/wgpu requires Vulkan 1.1+ on Android
- Minimum: Android 7.0 (API 24) but recommended 9.0+ (API 28)
- Our minSdk is 26 (Android 8.0) - may not work on older devices

### ⚠️ Memory Constraints
- Mobile GPUs have less VRAM than desktop
- Bevy's default resource limits may need tuning
- Texture compression (ASTC) required for assets

### ⚠️ Thermal Throttling
- Sustained 3D rendering will throttle on phones
- Need: Frame rate caps, quality settings, thermal API integration

### ⚠️ Touch Controls
- Game designed for keyboard/mouse
- Need: Virtual joystick, touch camera controls, on-screen buttons
- Not implemented in current skeleton

### ⚠️ Background/Foreground Handling
- Android pauses native activity on background
- Game needs proper pause/resume/save state
- Partial implementation in JNI bridge

### ⚠️ Storage Scoping
- Android 11+ scoped storage limits file access
- Game assets must be in `assets/` or app-specific directory
- No arbitrary filesystem access like desktop

---

## Legal / Distribution Limitations

### ⚠️ Proprietary Game
- Vortex (playvortex.io) is **proprietary**, not open source
- The "source code" used is from an **unauthorized leak** (@azixi0)
- Not licensed for redistribution or derivative works
- **This port cannot be legally distributed**

### ⚠️ Trademark
- "Vortex" and "playvortex.io" are trademarks
- Icon and branding extracted from AppImage
- Cannot publish to Play Store without permission

### ⚠️ Server Dependency
- Game requires connection to `connect.playvortex.io:7777`
- Private servers not supported (no server source)
- If official servers shut down, game becomes unplayable

---

## What Would Be Needed for a Working Port

| Component | Effort | Notes |
|-----------|--------|-------|
| Full game source code | N/A | Not available - proprietary |
| Bevy Android setup | Medium | `android-activity` + `winit` + `wgpu` |
| Asset pipeline | High | Convert/optimize all assets for mobile |
| Touch controls | High | Complete redesign for touch |
| Networking | High | Reimplement from protocol defs |
| Luau VM | Medium | Compile `mlua`/`luau` for Android |
| Audio | Low | `bevy_audio` + Android backend |
| Testing/optimization | High | Multiple devices, thermal, battery |

---

## Current APK Status

**Produces**: `app/build/outputs/apk/debug/app-debug.apk`
- **Installs**: ✅ Yes
- **Launches**: ✅ Yes (shows activity)
- **Runs game**: ❌ No - crashes in native code (stub)
- **Renders**: ❌ No - no rendering code
- **Connects**: ❌ No - no networking

The APK is a **proof-of-concept wrapper** demonstrating the architecture, not a playable game.
