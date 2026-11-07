cmake_minimum_required(VERSION 3.22.1)
project("vortex-native" LANGUAGES C CXX)

# This is a placeholder CMake for the Rust/Bevy game
# The actual Rust code would be built with cargo and the resulting
# .so files would be placed in jniLibs/arm64-v8a/

# For now, create a minimal native library that provides JNI entry points
add_library(
    vortex-native
    SHARED
    src/main/cpp/native-lib.cpp
)

find_library(
    log-lib
    log
)

target_link_libraries(
    vortex-native
    ${log-lib}
    android
    EGL
    GLESv3
)

# Include directories
target_include_directories(vortex-native PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp/include
)
