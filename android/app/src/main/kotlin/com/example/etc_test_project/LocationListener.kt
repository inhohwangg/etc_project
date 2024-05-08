package com.example.etc_test_project

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.widget.Toast
import androidx.core.content.ContextCompat
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class MyLocationListener(private val context: Context) : LocationListener {

    private val locationManager: LocationManager =
        context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

    fun startLocationUpdates() {
        if (ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            locationManager.requestLocationUpdates(
                LocationManager.GPS_PROVIDER,
                5000L,
                1f,
                this
            )
        } else {
            Toast.makeText(context, "위치 권한이 필요합니다.", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onLocationChanged(location: Location) {
      // 대상 위치의 위도와 경도
      val targetLatitude = 37.422
      val targetLongitude = -122.084
      val targetLocation = Location("").apply {
          latitude = targetLatitude
          longitude = targetLongitude
      }
      val distance = location.distanceTo(targetLocation) // 현재 위치와 대상 위치 사이의 거리 계산

      // 대상 위치 내부로 들어온 경우 (예: 100미터 이내)
      if (distance <= 5) {
          sendApiRequest(location)
      }
    }

    private fun isInTargetLocation(location: Location): Boolean {
        // 여기에 특정 위치를 판단하는 로직을 구현합니다.
        // 예시를 위해 항상 true를 반환하게 했습니다.
        return true
    }

    private fun sendApiRequest(location: Location) {
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        val currentDateAndTime: String = dateFormat.format(Date())

        val client = OkHttpClient()
        val mediaType = "application/json; charset=utf-8".toMediaType()
        val json = """
            {
                "latitude": "${location.latitude}",
                "longitude": "${location.longitude}",
                "come_in_data": "$currentDateAndTime",
                "text": "출근"
            }
        """.trimIndent()
        val requestBody = json.toRequestBody(mediaType)

        val request = Request.Builder()
            .url("https://pb.fappworkspace.store/api/collections/geofence/records")
            .post(requestBody)
            .build()

        client.newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: okhttp3.Call, e: IOException) {
                // 실패 로직 처리
                e.printStackTrace()
            }

            override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                if (!response.isSuccessful) {
                    // 요청 실패 로직
                    throw IOException("Unexpected code $response")
                }
                // 요청 성공 로직
            }
        })
    }

    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {
        // GPS 상태 변경시 호출됩니다.
    }

    override fun onProviderEnabled(provider: String) {
        // GPS가 사용 가능 상태가 되었을 때 호출됩니다.
    }

    override fun onProviderDisabled(provider: String) {
        // GPS가 사용 불가능 상태가 되었을 때 호출됩니다.
    }
}
