package com.example.etc_test_project

import android.content.Context
import android.content.Intent
import androidx.core.app.JobIntentService

class GeoFenceJobIntentService : JobIntentService() {
    companion object {
        private const val JOB_ID = 1000

        fun enqueueWork(context: Context, intent: Intent) {
            enqueueWork(context, GeoFenceJobIntentService::class.java, JOB_ID, intent)
        }
    }

    override fun onHandleWork(intent: Intent) {
        // 백그라운드에서 실행할 작업 처리
    }
}
