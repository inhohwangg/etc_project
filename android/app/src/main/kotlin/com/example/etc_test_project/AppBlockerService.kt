package com.example.etc_test_project

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngineCache
import java.util.*
import java.util.concurrent.TimeUnit

class AppBlockerService : Service() {

    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "AppBlockerServiceChannel",
                "App Blocker Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val durationMillis = intent?.getLongExtra("duration", 0L) ?: 0L
        val packageName = intent?.getStringExtra("packageName") ?: ""

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE)

        val notification: Notification = NotificationCompat.Builder(this, "AppBlockerServiceChannel")
            .setContentTitle("App Blocker")
            .setContentText("Blocking $packageName for ${durationMillis / 60000} minutes")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .build()

        startForeground(1, notification)

        // 타이머 설정
        Timer().schedule(object : TimerTask() {
            override fun run() {
                // 타이머가 끝나면 차단 해제
                stopBlockingApp(packageName)
                stopSelf()
            }
        }, durationMillis)

        // 백그라운드 작업 스케줄링 추가
        scheduleUnblockApp(packageName, durationMillis)

        return START_NOT_STICKY
    }

    private fun scheduleUnblockApp(packageName: String, durationMillis: Long) {
        val inputData = Data.Builder()
            .putString("packageName", packageName)
            .putLong("duration", durationMillis)
            .build()

        val workRequest = OneTimeWorkRequestBuilder<AppBlockerWorker>()
            .setInputData(inputData)
            .setInitialDelay(durationMillis, TimeUnit.MILLISECONDS)
            .build()

        WorkManager.getInstance(this).enqueue(workRequest)
        Log.d("AppBlockerService", "Scheduled background work to unblock $packageName after $durationMillis milliseconds")
    }

    private fun stopBlockingApp(packageName: String) {
        val intent = Intent("com.example.etc_test_project.UPDATE_BLOCKED_APPS")
        intent.putExtra("action", "remove_block")
        intent.putExtra("packageName", packageName)
        sendBroadcast(intent)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
