package com.playvortex.vortex

import android.app.Activity
import android.app.AlertDialog
import android.content.DialogInterface
import android.os.Bundle
import android.util.Log
import android.widget.TextView
import android.view.Gravity
import android.view.ViewGroup

class VortexNativeActivity : Activity() {

    companion object {
        private const val TAG = "VortexNativeActivity"
        
        // Native methods - will be loaded if library exists
        @JvmStatic
        external fun startGameLoop()
        
        @JvmStatic
        external fun handleInput(event: android.view.MotionEvent): Boolean
    }

    private var nativeLoaded = false

    init {
        // Try to load native library
        try {
            System.loadLibrary("vortex-native")
            nativeLoaded = true
            Log.i(TAG, "Loaded libvortex-native.so")
        } catch (e: UnsatisfiedLinkError) {
            Log.w(TAG, "Native library not found: ${e.message}")
            nativeLoaded = false
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i(TAG, "VortexNativeActivity onCreate")
        
        if (nativeLoaded) {
            // Try to start game loop
            Thread {
                try {
                    startGameLoop()
                } catch (e: Exception) {
                    Log.e(TAG, "Game loop failed", e)
                    runOnUiThread { showError("Game engine error: ${e.message}") }
                }
            }.start()
        } else {
            // Show informative message
            showPlaceholderUI()
        }
    }

    private fun showPlaceholderUI() {
        val textView = TextView(this).apply {
            text = """
                Vortex Android Port
                
                ⚠️ Game engine not available
                
                The Vortex game (playvortex.io) is a Rust/Bevy
                native game. The full source code is not available
                for compilation.
                
                This APK contains only the Android wrapper.
                
                To run the actual game:
                1. Obtain full Vortex Rust source code
                2. Build for aarch64-linux-android
                3. Place .so files in jniLibs/arm64-v8a/
                4. Rebuild APK
                
                See LIMITATIONS.md for details.
            """.trimIndent()
            textSize = 16f
            gravity = Gravity.CENTER
            setPadding(48, 48, 48, 48)
        }
        setContentView(textView)
    }

    private fun showError(message: String) {
        AlertDialog.Builder(this)
            .setTitle("Vortex Error")
            .setMessage(message)
            .setPositiveButton("OK") { _, _ -> finish() }
            .setCancelable(false)
            .show()
    }

    override fun onTouchEvent(event: android.view.MotionEvent?): Boolean {
        if (nativeLoaded) {
            event?.let { handleInput(it) }
        }
        return super.onTouchEvent(event)
    }

    override fun onGenericMotionEvent(event: android.view.MotionEvent?): Boolean {
        if (nativeLoaded) {
            event?.let { handleInput(it) }
        }
        return super.onGenericMotionEvent(event)
    }
}
