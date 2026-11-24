package app.chudiptv.chud_iptv

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

/// Mode radio : garde l'app en vie, le processeur et le Wi-Fi éveillés quand le téléphone est
/// verrouillé. La lecture elle-même reste dans libmpv.
class PlaybackService : Service() {
    private var wake: PowerManager.WakeLock? = null
    private var wifi: WifiManager.WifiLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            onStopRequested?.invoke()
            stopSelf()
            return START_NOT_STICKY
        }
        val notification = notification(
            intent?.getStringExtra(EXTRA_TITLE).orEmpty(),
            intent?.getStringExtra(EXTRA_TEXT).orEmpty(),
            intent?.getStringExtra(EXTRA_STOP).orEmpty(),
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(ID, notification)
        }
        acquireLocks()
        return START_NOT_STICKY
    }

    private fun notification(title: String, text: String, stopLabel: String): Notification {
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(NotificationChannel(CHANNEL, "Chud IPTV", NotificationManager.IMPORTANCE_LOW))
        val open = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val stop = PendingIntent.getService(
            this, 1,
            Intent(this, PlaybackService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        return Notification.Builder(this, CHANNEL)
            .setSmallIcon(android.R.drawable.ic_media_play)
            .setContentTitle(title)
            .setContentText(text)
            .setContentIntent(open)
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_TRANSPORT)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .addAction(Notification.Action.Builder(null, stopLabel, stop).build())
            .build()
    }

    private fun acquireLocks() {
        if (wake == null) {
            wake = getSystemService(PowerManager::class.java)
                .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "chud:radio")
                .apply { acquire() }
        }
        if (wifi == null) {
            val manager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            wifi = manager.createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "chud:radio").apply { acquire() }
        }
    }

    override fun onDestroy() {
        wake?.release()
        wifi?.release()
        super.onDestroy()
    }

    companion object {
        private const val ID = 1
        private const val CHANNEL = "playback"
        private const val ACTION_STOP = "app.chudiptv.STOP_RADIO"
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_TEXT = "text"
        private const val EXTRA_STOP = "stop"

        /// Prévient l'interface que l'utilisateur a touché « Arrêter » dans la notification.
        var onStopRequested: (() -> Unit)? = null

        fun start(context: Context, title: String, text: String, stopLabel: String) {
            context.startForegroundService(
                Intent(context, PlaybackService::class.java)
                    .putExtra(EXTRA_TITLE, title)
                    .putExtra(EXTRA_TEXT, text)
                    .putExtra(EXTRA_STOP, stopLabel),
            )
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, PlaybackService::class.java))
        }
    }
}
