package com.example.etc_test_project

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingEvent
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException

class GeoFenceBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val geofencingEvent = GeofencingEvent.fromIntent(intent)
        if (geofencingEvent?.hasError() == true) {
            Log.e("GeoFenceReceiver", "Geofencing Event Error: ${geofencingEvent.errorCode}")
            return
        }

        val geofenceTransition = geofencingEvent?.geofenceTransition
        if (geofenceTransition == Geofence.GEOFENCE_TRANSITION_ENTER || geofenceTransition == Geofence.GEOFENCE_TRANSITION_EXIT) {
            val transitionType = if (geofenceTransition == Geofence.GEOFENCE_TRANSITION_ENTER) "들어왔음" else "나갔음"
            sendApiRequest(context, transitionType)
        }
    }

    private fun sendApiRequest(context: Context, transitionType: String) {
        val client = OkHttpClient()
        val jsonMediaType = "application/json; charset=utf-8".toMediaType()
        val jsonData = """
            {
                "come_in_data": "exampleDateAndTime",
                "text": "GeoFenceBroadcastReceiver"
            }
        """.trimIndent()
        val requestBody = jsonData.toRequestBody(jsonMediaType)
        val request = Request.Builder()
            .url("https://pb.fappworkspace.store/api/collections/geofence/records")
            .post(requestBody)
            .build()

        client.newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: okhttp3.Call, e: IOException) {
                e.printStackTrace()
                // 에러 처리 로직
                sendNotification(context, "API 요청 실패: $transitionType")
            }

            override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                if (response.isSuccessful) {
                    // 성공 처리 로직
                    // UI 업데이트 등은 여기서 진행하면 안 됩니다. (UI 스레드가 아님)
                    sendNotification(context, "Geofence 이벤트 성공: $transitionType")
                } else {
                    // 실패 처리 로직
                    sendNotification(context, "API 요청 실패: $transitionType")
                }
            }
        })
    }

    private fun sendNotification(context: Context, message: String) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notificationChannelId = "geofence_channel_id"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(notificationChannelId, "Geofence Notifications", NotificationManager.IMPORTANCE_HIGH)
            notificationManager.createNotificationChannel(channel)
        }

        val notificationBuilder = NotificationCompat.Builder(context, notificationChannelId)
            .setSmallIcon(R.drawable.ic_notification) // 알림 아이콘 설정
            .setContentTitle("Geofence Event")
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)

        notificationManager.notify(0, notificationBuilder.build())
    }
}
