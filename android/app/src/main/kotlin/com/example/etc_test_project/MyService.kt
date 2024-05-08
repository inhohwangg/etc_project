package com.example.etc_test_project

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationResult
import android.location.Location
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Call
import okhttp3.Callback
import okhttp3.Response
import java.io.IOException
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.Date
import android.app.AlarmManager
import android.app.PendingIntent
import android.os.SystemClock
import android.content.Context

class MyService : Service() {
    private val CHANNEL_ID = "ForegroundServiceChannel"
    private lateinit var locationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Foreground Service")
            .setContentText("Service is running...")
            .setSmallIcon(R.drawable.ic_notification)
            .build()
        startForeground(1, notification)

        locationClient = LocationServices.getFusedLocationProviderClient(this)
        startLocationUpdates()

        // WorkManager 작업 스케줄링
        val uploadWorkRequest = OneTimeWorkRequestBuilder<UploadWorker>().build()
        WorkManager.getInstance(this).enqueue(uploadWorkRequest)

        scheduleNextUpdate()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // 서비스가 명시적으로 시작될 때 호출됩니다.
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        // 클라이언트가 서비스에 바인드할 때 호출됩니다.
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        locationClient.removeLocationUpdates(locationCallback)
    }

    private fun startLocationUpdates() {
        val locationRequest = LocationRequest.create().apply {
            interval = 10000
            fastestInterval = 5000
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) { // '?를 제거해야 합니다.
                for (location in locationResult.locations){
                    // 위치 정보를 사용하여 필요한 작업을 수행합니다.
                    val transitionType = "ENTER"
                    test(location, transitionType)
                }
            }
        }

        try {
            locationClient.requestLocationUpdates(locationRequest, locationCallback, null)
        } catch (unlikely: SecurityException) {
            // 위치 권한이 없을 때의 처리
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Foreground Service Channel",
                NotificationManager.IMPORTANCE_HIGH
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun test(location: Location, transitionType: String) {
    val client = OkHttpClient()
    val mediaType = "application/json; charset=utf-8".toMediaType()

    val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
    val currentDateAndTime = dateFormat.format(Date())

    val content = """
            {
                "come_in_data": "$currentDateAndTime",
                "text": "출근(MyService)"
            }
        """.trimIndent()
    val body = content.toRequestBody(mediaType)
    
    val request = Request.Builder()
        .url("https://pb.fappworkspace.store/api/collections/geofence/records")
        .post(body)
        .build()

    client.newCall(request).enqueue(object : Callback {
        override fun onFailure(call: Call, e: IOException) {
            // Handle failure
            e.printStackTrace()
        }

        override fun onResponse(call: Call, response: Response) {
            if (!response.isSuccessful) {
                // 요청 실패 로직
                throw IOException("Unexpected code $response")
            }
            // 요청 성공 로직
        }
    })
    }

    private fun scheduleNextUpdate() {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, MyService::class.java) // 이 인텐트는 서비스를 다시 시작하기 위해 사용됩니다.
        val pendingIntent = PendingIntent.getService(
            this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val nextUpdateTimeMillis = System.currentTimeMillis() + 15 * 60 * 1000 // 다음 업데이트는 15분 후입니다.

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                nextUpdateTimeMillis,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                nextUpdateTimeMillis,
                pendingIntent
            )
        }
    }
}
