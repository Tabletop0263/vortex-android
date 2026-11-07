# Native Libraries (arm64-v8a)

This directory should contain the compiled Rust native libraries:

- `libvortex_engine.so` - Bevy game engine
- `libvortex_client.so` - Vortex game client
- `libvortex-native.so` - JNI bridge (minimal wrapper)

## Building Native Libraries

Due to the NDK only providing x86_64 host toolchains, **native compilation cannot be done on ARM64 hosts** (like Termux/proot-distro Ubuntu on Android).

### Option 1: GitHub Actions (Recommended)
The `.github/workflows/build.yml` workflow builds on GitHub's x86_64 runners:
```yaml
# Triggered on push to main, or manually via workflow_dispatch
```

### Option 2: Cross-compile from x86_64 machine
```bash
# On x86_64 Linux/macOS/Windows:
rustup target add aarch64-linux-android
cd vortex-src
cargo build --target aarch64-linux-android --release
cp target/aarch64-linux-android/release/libvortex_engine.so ../vortex-android/app/src/main/jniLibs/arm64-v8a/
cp target/aarch64-linux-android/release/libvortex_client_recovered.so ../vortex-android/app/src/main/jniLibs/arm64-v8a/libvortex_client.so
```

### Option 3: Use Android NDK ARM64 host tools (if available)
Download ARM64 NDK from: https://developer.android.com/ndk/downloads

## Current Status
- Placeholder libraries: NOT AVAILABLE (requires x86_64 host)
- Full game libraries: NOT AVAILABLE (requires full game source code)
- APK build: Requires GitHub Actions or x86_64 build machine

See `LIMITATIONS.md` for full details.
