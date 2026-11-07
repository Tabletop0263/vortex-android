#include <jni.h>
#include <android/log.h>
#include <android/native_activity.h>
#include <EGL/egl.h>
#include <GLES3/gl3.h>

#define LOG_TAG "VortexNative"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Forward declarations for Rust functions (to be implemented)
// These would be linked from the Rust compiled library
extern "C" {
    // Game initialization
    void vortex_init(ANativeActivity* activity, void* savedState, size_t savedStateSize);
    // Game main loop
    void vortex_main_loop(ANativeActivity* activity);
    // Handle input events
    int32_t vortex_handle_input(ANativeActivity* activity, AInputEvent* event);
    // Handle window changes
    void vortex_handle_window_change(ANativeActivity* activity, ANativeWindow* window);
    // Save state
    void* vortex_save_state(ANativeActivity* activity, size_t* outSize);
    // Cleanup
    void vortex_destroy(ANativeActivity* activity);
}

// Global state
static ANativeActivity* g_activity = nullptr;
static bool g_initialized = false;

// Native activity callbacks
void ANativeActivity_onCreate(ANativeActivity* activity, void* savedState, size_t savedStateSize) {
    LOGI("ANativeActivity_onCreate");
    g_activity = activity;
    
    // Set up callbacks
    activity->callbacks->onDestroy = [](ANativeActivity* activity) {
        LOGI("onDestroy");
        if (g_initialized) {
            vortex_destroy(activity);
            g_initialized = false;
        }
    };
    
    activity->callbacks->onStart = [](ANativeActivity* activity) {
        LOGI("onStart");
    };
    
    activity->callbacks->onResume = [](ANativeActivity* activity) {
        LOGI("onResume");
        if (!g_initialized && vortex_init) {
            vortex_init(activity, activity->savedState, activity->savedStateSize);
            g_initialized = true;
        }
    };
    
    activity->callbacks->onSaveInstanceState = [](ANativeActivity* activity, size_t* outSize) -> void* {
        LOGI("onSaveInstanceState");
        if (g_initialized && vortex_save_state) {
            return vortex_save_state(activity, outSize);
        }
        return nullptr;
    };
    
    activity->callbacks->onPause = [](ANativeActivity* activity) {
        LOGI("onPause");
    };
    
    activity->callbacks->onStop = [](ANativeActivity* activity) {
        LOGI("onStop");
    };
    
    activity->callbacks->onConfigurationChanged = [](ANativeActivity* activity) {
        LOGI("onConfigurationChanged");
    };
    
    activity->callbacks->onLowMemory = [](ANativeActivity* activity) {
        LOGI("onLowMemory");
    };
    
    activity->callbacks->onWindowFocusChanged = [](ANativeActivity* activity, int focused) {
        LOGI("onWindowFocusChanged: %d", focused);
    };
    
    activity->callbacks->onNativeWindowCreated = [](ANativeActivity* activity, ANativeWindow* window) {
        LOGI("onNativeWindowCreated");
        if (g_initialized && vortex_handle_window_change) {
            vortex_handle_window_change(activity, window);
        }
    };
    
    activity->callbacks->onNativeWindowDestroyed = [](ANativeActivity* activity, ANativeWindow* window) {
        LOGI("onNativeWindowDestroyed");
        if (g_initialized && vortex_handle_window_change) {
            vortex_handle_window_change(activity, nullptr);
        }
    };
    
    activity->callbacks->onInputQueueCreated = [](ANativeActivity* activity, AInputQueue* queue) {
        LOGI("onInputQueueCreated");
        activity->inputQueue = queue;
    };
    
    activity->callbacks->onInputQueueDestroyed = [](ANativeActivity* activity, AInputQueue* queue) {
        LOGI("onInputQueueDestroyed");
        activity->inputQueue = nullptr;
    };
    
    // Initialize the game if possible
    if (vortex_init) {
        vortex_init(activity, savedState, savedStateSize);
        g_initialized = true;
    }
}

// This would be called from Java to start the game loop
extern "C" JNIEXPORT void JNICALL
Java_com_playvortex_vortex_VortexNativeActivity_startGameLoop(JNIEnv* env, jobject thiz) {
    LOGI("startGameLoop called");
    if (g_initialized && vortex_main_loop && g_activity) {
        vortex_main_loop(g_activity);
    }
}

// Input handling from Java
extern "C" JNIEXPORT jboolean JNICALL
Java_com_playvortex_vortex_VortexNativeActivity_handleInput(JNIEnv* env, jobject thiz, jobject event) {
    // Would convert Java MotionEvent to AInputEvent and call vortex_handle_input
    return JNI_FALSE;
}

