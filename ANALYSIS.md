# Vortex AppImage Analysis

## AppImage Information
- **File**: Vortex-linux-x86_64.AppImage (45.1 MB)
- **Architecture**: x86_64 (ELF 64-bit LSB pie executable)
- **Version**: 0.9.6 (from binary strings)
- **App ID**: io.playvortex.Vortex
- **Type**: Rust/Bevy game (NOT Electron)

## Extraction Results
- **Squashfs offset**: 944,632 bytes
- **Extracted to**: ./extracted/
- **Contents**: 
  - `/usr/bin/Vortex` - Main executable (110 MB, x86_64 ELF)
  - System libraries (libX11, libvulkan, etc.)
  - Desktop entry and icon

## Technology Stack (from binary analysis)

### Primary Engine
- **Bevy Engine** (Rust game engine) - ECS, rendering, input, audio
- **wgpu** - Cross-platform GPU abstraction (Vulkan/Metal/DX12/GL/WebGPU)
- **winit** - Window management
- **Luau** - Scripting language (Roblox's Lua variant)

### Key Crates Identified (from strings)
- `bevy_ecs`, `bevy_render`, `bevy_pbr`, `bevy_ui`, `bevy_text`
- `bevy_asset`, `bevy_audio`, `bevy_input`, `bevy_window`
- `wgpu`, `wgpu_core`, `wgpu_hal`
- `avian3d` - Physics engine (3D)
- `bevy_egui` - Immediate mode GUI
- `mlua` / `luau` - Scripting

### Networking
- Custom protocol (binary, likely TCP/UDP)
- Game server: `connect.playvortex.io:7777`
- Protocol includes: PlayerFrame, PlayerInfo, PlayerState, Packet types

### Game Features
- Multiplayer (avatar, chat, physics, ragdoll)
- Instance system (Workspace, ReplicatedStorage, etc.)
- Scripting (LocalScript, Script, ModuleScript)
- Map loading
- Social features (friends, parties)

## Architecture Analysis

### Main Process vs Renderer
**This is NOT Electron** - there's no main/renderer split. It's a single native Rust process using Bevy's ECS architecture:
- Single process with Bevy App
- ECS systems for: rendering, physics, networking, input, UI, scripting
- Runs entirely in Rust, no JavaScript/IPC boundary

### Native Modules / Dependencies
| Module | Purpose | Android Replacement |
|--------|---------|---------------------|
| wgpu (Vulkan) | GPU rendering | ✅ Native - wgpu supports Android/Vulkan |
| winit | Window/events | ✅ Native - winit supports Android |
| avian3d | 3D physics | ✅ Pure Rust - compiles to Android |
| bevy_ecs | ECS | ✅ Pure Rust |
| bevy_audio | Audio | ⚠️ Needs Android audio backend (cpal/rodio) |
| luau/mlua | Scripting | ✅ Pure Rust - compiles to Android |
| Native libs (X11, etc.) | Linux windowing | ❌ Not needed on Android (use winit/Android) |

### Electron API Mapping (N/A - Not Electron)
| Electron API | Bevy Equivalent | Android Mapping |
|--------------|-----------------|-----------------|
| BrowserWindow | bevy_window::Window | NativeActivity surface |
| ipcMain/ipcRenderer | ECS Events/Commands | N/A - single process |
| dialog | bevy_egui / native | Android dialogs via JNI |
| shell.openExternal | Application.openURL | Android Intent |
| app.getPath | std::env / dirs | Android Context.getFilesDir() |
| protocol handlers | Custom | Android Intent filters |
| tray/menu | bevy_ui / egui | Android ActionBar/Menu |

### Windows/Linux Specific Code
- X11/Wayland windowing (handled by winit)
- Vulkan loader (handled by wgpu)
- File paths (Linux `/home/user/...` → Android scoped storage)
- Desktop entry registration (Android manifest)
- AppImage update mechanism (Google Play / custom)

## Android Port Strategy

### Recommended Approach: NativeActivity + Rust
1. Compile entire Rust game for `aarch64-linux-android`
2. Use `android-activity` crate for NativeActivity bindings
3. Implement `android_main` entry point
4. Use wgpu's Vulkan backend for rendering
5. Use winit's Android backend for window/input
6. Minimal Kotlin/Java for:
   - Permissions handling
   - In-app purchases (if needed)
   - Platform-specific features (share, notifications)

### Entry Point Changes Needed
```rust
// Current (desktop)
fn main() {
    let config = BootstrapConfig::from_environment();
    // ... run bevy app
}

// Android (needs android-activity crate)
#[no_mangle]
fn android_main(app: android_activity::AndroidApp) {
    // Initialize logging
    // Create Bevy App with wgpu Vulkan + winit Android
    // Run game loop
}
```

### Asset Handling
- Embed assets in APK (`assets/` directory)
- Use `android-activity` asset API to read
- Or extract to app data dir on first run

### Permissions Needed
- INTERNET (game server connection)
- ACCESS_NETWORK_STATE
- WAKE_LOCK (keep screen on during gameplay)
- FOREGROUND_SERVICE (optional, for background networking)

## Source Code Status

### Available (Leaked Reconstruction)
- Data structures (Instance, Protocol, Avatar, Chat, Physics, etc.)
- Scripting VM interfaces (Luau)
- Network protocol definitions
- Game state machine

### Missing (Proprietary/Not Leaked)
- Bevy App setup and plugin registration
- Rendering pipeline setup (wgpu, shaders)
- Main game loop and systems
- Asset loading and management
- Networking implementation (client/server)
- Physics integration (avian3d setup)
- UI/UX implementation (menus, HUD)
- Input handling
- Audio system

## Conclusion

This is a **native Rust/Bevy game**, not an Electron app. The Android port requires:
1. Full game source code (not available - only partial reconstruction)
2. Rust Android toolchain setup
3. Bevy/wgpu/winit Android support (available in recent versions)
4. NativeActivity-based Android app wrapper

The extracted AppImage contains only the x86_64 binary - no separate assets or asar files.
The "source code" available online is a behavioral reconstruction from a leak, not the actual game source.
