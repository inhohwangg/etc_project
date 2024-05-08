package com.example.etc_test_project

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.Date

class UploadWorker(
    context: Context,
    workerParams: WorkerParameters
): Worker(context, workerParams) {

    override fun doWork(): Result {
        try {
            val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
            val currentDateAndTime = dateFormat.format(Date()) // 현재 날짜와 시간을 계산

            val client = OkHttpClient()
            val mediaType = "application/json; charset=utf-8".toMediaType()
            val requestBody = """
                {
                    "come_in_data": "$currentDateAndTime",
                    "text": "UploadWorker"
                }
            """.trimIndent().toRequestBody(mediaType)
            val request = Request.Builder()
                .url("https://pb.fappworkspace.store/api/collections/geofence/records")
                .post(requestBody)
                .build()
            client.newCall(request).execute().use { response ->
                if (!response.isSuccessful) throw IOException("Unexpected code $response")

                // 처리 성공 로직...
            }
            return Result.success()
        } catch (e: Exception) {
            // 처리 실패 로직...
            return Result.failure()
        }
    }
}
