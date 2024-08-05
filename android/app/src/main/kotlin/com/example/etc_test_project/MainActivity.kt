package com.example.etc_test_project

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.app.PendingIntent
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import com.google.android.gms.location.*
import androidx.annotation.NonNull
import android.util.Log
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager

class MainActivity : FlutterActivity() {
    private lateinit var geofencingClient: GeofencingClient
    private val CHANNEL = "com.example.appblocker/channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setBlockedApp") {
                val packageName = call.argument<String>("packageName")
                val duration = call.argument<Long>("duration")
                if (packageName != null) {
                    if (duration != null && duration > 0) {
                        startTimerService(duration, packageName)
                    }
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startTimerService(duration: Long, packageName: String) {
        val intent = Intent(this, TimerService::class.java)
        intent.putExtra("duration", duration)
        intent.putExtra("packageName", packageName)
        startService(intent)
    }

    private fun saveBlockedApp(packageName: String?) {
        val sharedPref = getSharedPreferences("AppBlockerPrefs", Context.MODE_PRIVATE)
        with(sharedPref.edit()) {
            putString("blockedApp", packageName)
            apply()
        }
        Log.d("AppBlocker", "Saved blocked app: $packageName") // 로그 추가
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        checkAndRequestBatteryOptimization()
        
        // 작업 스케줄링
        val uploadWorkRequest = OneTimeWorkRequestBuilder<UploadWorker>().build()
        WorkManager.getInstance(this).enqueue(uploadWorkRequest)

        geofencingClient = LocationServices.getGeofencingClient(this)
        addGeofence()
    }

    private fun checkAndRequestBatteryOptimization() {
        val powerManager = getSystemService(POWER_SERVICE) as PowerManager
        val packageName = packageName
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !powerManager.isIgnoringBatteryOptimizations(packageName)) {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
        }
    }

    private fun addGeofence() {
        val geofence = Geofence.Builder()
            .setRequestId("someGeofenceId")
            .setCircularRegion(
                37.422, // 예시 위도
                -122.084, // 예시 경도
                5f // 반경(m)
            )
            .setExpirationDuration(Geofence.NEVER_EXPIRE)
            .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER or Geofence.GEOFENCE_TRANSITION_EXIT)
            .build()

        val geofencingRequest = GeofencingRequest.Builder()
            .setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER)
            .addGeofence(geofence)
            .build()

        val intent = Intent(this, GeoFenceBroadcastReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        geofencingClient.addGeofences(geofencingRequest, pendingIntent)?.run {
            addOnSuccessListener {
                // 지오펜스 추가 성공 시 처리
            }
            addOnFailureListener {
                // 지오펜스 추가 실패 시 처리
            }
        }
    }
}
