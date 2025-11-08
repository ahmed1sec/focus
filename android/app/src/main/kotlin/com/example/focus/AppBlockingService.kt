package com.example.focus

import android.app.*
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import java.util.*

class AppBlockingService : Service() {
    
    private val handler = Handler(Looper.getMainLooper())
    private var monitoringRunnable: Runnable? = null
    private var blockedApps = mutableSetOf<String>()
    private var lastCheckedTime = System.currentTimeMillis()
    private var isServiceRunning = false
    
    companion object {
        const val CHANNEL_ID = "app_blocking_channel"
        const val NOTIFICATION_ID = 1
        var isRunning = false
        
        // App package names to monitor
        val APP_PACKAGES = mapOf(
            "YouTube" to "com.google.android.youtube",
            "Instagram" to "com.instagram.android",
            "Facebook" to "com.facebook.katana",
            "TikTok" to "com.zhiliaoapp.musically",
            "Snapchat" to "com.snapchat.android"
        )
    }
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "START_BLOCKING" -> {
                val apps = intent.getStringArrayListExtra("blocked_apps") ?: arrayListOf()
                startBlocking(apps)
            }
            "STOP_BLOCKING" -> {
                stopBlocking()
            }
        }
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "App Blocking Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors and blocks selected apps"
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun startBlocking(apps: List<String>) {
        blockedApps.clear()
        apps.forEach { appName ->
            APP_PACKAGES[appName]?.let { packageName ->
                blockedApps.add(packageName)
            }
        }
        
        if (blockedApps.isEmpty()) {
            stopBlocking()
            return
        }
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("FocusFlow Active")
            .setContentText("Blocking ${blockedApps.size} app(s)")
            .setSmallIcon(R.drawable.ic_notification)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
            
        startForeground(NOTIFICATION_ID, notification)
        isServiceRunning = true
        isRunning = true
        lastCheckedTime = System.currentTimeMillis()
        startMonitoring()
    }
    
    private fun startMonitoring() {
        if (monitoringRunnable != null) {
            handler.removeCallbacks(monitoringRunnable!!)
        }
        
        monitoringRunnable = object : Runnable {
            override fun run() {
                if (!isServiceRunning) return
                checkForBlockedApps()
                // Schedule next check
                if (isServiceRunning) {
                    handler.postDelayed(this, 1000) // Check every second
                }
            }
        }
        handler.post(monitoringRunnable!!)
    }
    
    private fun checkForBlockedApps() {
        if (!isServiceRunning) return
        
        try {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            if (usageStatsManager == null) {
                stopBlocking()
                return
            }
            
            val currentTime = System.currentTimeMillis()
            
            val usageStats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                currentTime - 5000, // Check last 5 seconds
                currentTime
            ) ?: return
            
            // Find the most recently used app that is blocked
            val recentApp = usageStats
                .filter { 
                    it.lastTimeUsed > lastCheckedTime && 
                    blockedApps.contains(it.packageName) &&
                    it.packageName != packageName // Don't block ourselves
                }
                .maxByOrNull { it.lastTimeUsed }
            
            recentApp?.let { stats ->
                showBlockingScreen(stats.packageName)
                // Update last checked time to prevent multiple triggers
                lastCheckedTime = currentTime + 3000 // Add 3 second buffer
            } ?: run {
                lastCheckedTime = currentTime
            }
        } catch (e: Exception) {
            // Handle permission errors or other issues
            e.printStackTrace()
        }
    }
    
    private fun showBlockingScreen(packageName: String) {
        val intent = Intent(this, BlockingActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("blocked_package", packageName)
        }
        startActivity(intent)
    }
    
    private fun stopBlocking() {
        isServiceRunning = false
        isRunning = false
        monitoringRunnable?.let { handler.removeCallbacks(it) }
        monitoringRunnable = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        isServiceRunning = false
        isRunning = false
        monitoringRunnable?.let { handler.removeCallbacks(it) }
    }
}