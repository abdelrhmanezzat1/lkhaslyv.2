package com.lakhsly.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import com.lakhsly.app.R

class NotificationChannelSetup {

    companion object {
        const val HIGH_IMPORTANCE_CHANNEL = "high_importance_channel"
        const val DEFAULT_CHANNEL = "default_channel"

        fun createNotificationChannels(context: Context) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // High importance channel for critical notifications
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val highImportanceChannel = NotificationChannel(
                    HIGH_IMPORTANCE_CHANNEL,
                    "High Importance Notifications",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Critical notifications for order updates and alerts"
                    enableVibration(true)
                    enableLights(true)
                    vibrationPattern = longArrayOf(0, 250, 250, 250)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                    // Use default notification sound
                    val audioAttributes = AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                    setSound(Uri.parse("android.resource://${context.packageName}/" + R.raw.notification_sound), audioAttributes)
                }
                notificationManager.createNotificationChannel(highImportanceChannel)

                // Default channel
                val defaultChannel = NotificationChannel(
                    DEFAULT_CHANNEL,
                    "Default Notifications",
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "General notifications"
                    enableVibration(true)
                    enableLights(true)
                }
                notificationManager.createNotificationChannel(defaultChannel)
            }
        }
    }
}
