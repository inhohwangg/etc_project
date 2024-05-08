package com.example.etc_test_project

import android.app.PendingIntent
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import com.google.android.gms.location.*
import com.example.etc_test_project.GeoFenceBroadcastReceiver
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager

class MainActivity : FlutterActivity() {
    private lateinit var geofencingClient: GeofencingClient

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // setContentView(R.layout.activity_main)
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
            // 여기에 지오펜스 설정을 추가합니다.
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
