package com.transport_system.ts_driver.clock_in_out_location

import android.annotation.SuppressLint
import android.app.Service
import android.content.Intent
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.os.Build
import androidx.core.app.NotificationCompat
import android.os.IBinder
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationResult
import com.transport_system.ts_driver.activities.MainActivity

class LocationService : Service() {

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private var isUpdatingLocation = false
    companion object {
        const val CHANNEL_ID = "LocationServiceChannel"
    }

    @SuppressLint("MissingPermission")
    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        val locationRequest = LocationRequest.create().apply {
            interval = 60000
            fastestInterval = 60000
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
            smallestDisplacement = 50f
        }

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                super.onLocationResult(locationResult)
                if (locationResult != null) {
                    for (location in locationResult.locations) {
                        val intent = Intent("LocationUpdate")
                        intent.putExtra("latitude", location.latitude.toDouble())
                        intent.putExtra("longitude", location.longitude.toDouble())
                        intent.putExtra("speed", location.speed.toDouble())
                        intent.putExtra("heading", location.bearing.toDouble())
                        FirebaseLocationLogUpdater().updateLocationInFirebase(this@LocationService,location)
                        LocalBroadcastManager.getInstance(this@LocationService).sendBroadcast(intent)
                    }
                }
            }
        }

        fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, null)
    }



    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        if (isUpdatingLocation) {
            println( "Location updates are already running.")
            return START_NOT_STICKY
        }
        createNotificationChannel()
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0, 
            notificationIntent, 
            pendingIntentFlags
        )

        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
        .setContentTitle("Navigator Active")
        .setContentText("Continuously updating your location for navigation.")
        .setSmallIcon(android.R.drawable.ic_dialog_info)
        .setContentIntent(pendingIntent)
        .setOngoing(true)
        .setPriority(NotificationCompat.PRIORITY_HIGH)
        .build()

        startForeground(1, notification)
        isUpdatingLocation = true
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Location Service Channel",
                NotificationManager.IMPORTANCE_MAX 
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }


    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        fusedLocationClient.removeLocationUpdates(locationCallback)
        isUpdatingLocation = false
        // stop foreground service and remove the notification.
        stopForeground(true)
        // stop the background service.
        stopSelf()
    }
}
