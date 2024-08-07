package com.example.etc_test_project

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class AppBlockerAccessibilityService : AccessibilityService() {

    private val blockedApps = mutableSetOf<String>()
    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val action = intent?.getStringExtra("action")
            val packageName = intent?.getStringExtra("packageName")
            Log.d("AppBlockerAccessibilityService", "Received broadcast: action=$action, packageName=$packageName")
            if (action != null && packageName != null) {
                when (action) {
                    "add_block" -> {
                        addBlockedApp(packageName)
                        Log.d("AppBlockerAccessibilityService", "Added block for $packageName")
                    }
                    "remove_block" -> {
                        removeBlockedApp(packageName)
                        Log.d("AppBlockerAccessibilityService", "Removed block for $packageName")
                    }
                }
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("AppBlockerAccessibilityService", "Service connected")
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
        }
        serviceInfo = info

        val filter = IntentFilter("com.example.etc_test_project.UPDATE_BLOCKED_APPS")
        registerReceiver(receiver, filter)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
			val packageName = event.packageName?.toString()
			if (packageName != null && blockedApps.contains(packageName)) {
					performGlobalAction(GLOBAL_ACTION_BACK)
					Log.d("AppBlockerAccessibilityService", "Blocked app $packageName is being closed")
    	}
		}

    override fun onInterrupt() {
        // 필요 시 구현
    }

    override fun onDestroy() {
        unregisterReceiver(receiver)
        super.onDestroy()
    }

    fun addBlockedApp(packageName: String) {
        blockedApps.add(packageName)
        updateServiceInfo()
    }

    fun removeBlockedApp(packageName: String) {
        blockedApps.remove(packageName)
        updateServiceInfo()
    }

    private fun updateServiceInfo() {
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            packageNames = blockedApps.toTypedArray()
        }
        serviceInfo = info
    }
}
