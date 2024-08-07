package com.example.etc_test_project

import android.content.Context
import android.content.Intent
import androidx.work.Worker
import androidx.work.WorkerParameters

class AppBlockerWorker(context: Context, workerParams: WorkerParameters) : Worker(context, workerParams) {

    override fun doWork(): Result {
        val packageName = inputData.getString("packageName")

        if (packageName != null) {
            val intent = Intent("com.example.etc_test_project.UPDATE_BLOCKED_APPS")
            intent.putExtra("action", "remove_block")
            intent.putExtra("packageName", packageName)
            applicationContext.sendBroadcast(intent)
        }

        return Result.success()
    }
}
