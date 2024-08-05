package com.example.etc_test_project

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.SystemClock
import androidx.core.app.NotificationCompat
import java.util.*

class TimerService : Service() {

    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "TimerServiceChannel",
                "Timer Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val duration = intent?.getLongExtra("duration", 0L) ?: 0L
        val packageName = intent?.getStringExtra("packageName") ?: ""

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, 0)

        val notification: Notification = NotificationCompat.Builder(this, "TimerServiceChannel")
            .setContentTitle("App Blocker")
            .setContentText("Blocking $packageName for ${duration / 60000} minutes")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .build()

        startForeground(1, notification)

        // 타이머 설정
        Timer().schedule(object : TimerTask() {
            override fun run() {
                // 타이머가 끝나면 차단 해제
                // stopBlockingApp()
                stopSelf()
            }
        }, duration)

        return START_NOT_STICKY
    }

    // private fun stopBlockingApp() {
    //     val methodChannel = MethodChannel(FlutterEngine(this).dartExecutor, "com.example.appblocker/channel")
    //     methodChannel.invokeMethod("setBlockedApp", mapOf("packageName" to ""))
    // }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
