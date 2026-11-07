package com.playvortex.vortex

import android.app.NativeActivity
import android.os.Bundle
import android.util.Log
import android.view.MotionEvent
import android.view.View

class VortexNativeActivity : NativeActivity() {

    companion object {
        private const val TAG = "VortexNativeActivity"
        
        // Native methods
        @JvmStatic
        external fun startGameLoop()
        
        @JvmStatic
        external fun handleInput(event: MotionEvent): Boolean
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.i(TAG, "VortexNativeActivity onCreate")
        
        // Keep screen on
        window.addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        
        // Hide system UI for immersive experience
        hideSystemUI()
        
        // Start the game loop in a background thread
        Thread {
            startGameLoop()
        }.start()
    }

    override fun onResume() {
        super.onResume()
        Log.i(TAG, "onResume")
        hideSystemUI()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            hideSystemUI()
        }
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        event?.let {
            handleInput(it)
        }
        return super.onTouchEvent(event)
    }

    override fun onGenericMotionEvent(event: MotionEvent?): Boolean {
        event?.let {
            handleInput(it)
        }
        return super.onGenericMotionEvent(event)
    }

    private fun hideSystemUI() {
        window.decorView.systemUiVisibility = (
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_FULLSCREEN
        )
    }
}
