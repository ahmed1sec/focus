package com.example.focus

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import kotlin.random.Random

class BlockingActivity : Activity() {
    
    private val motivationalQuotes = arrayOf(
        "Every minute spent scrolling is a minute stolen from your dreams.",
        "Focus on what matters. Your future self will thank you.",
        "Distraction is the enemy of progress.",
        "Time is your most valuable asset. Invest it wisely.",
        "Success is built one focused moment at a time.",
        "Your goals are waiting. Don't keep them waiting too long.",
        "Break the scroll, build your soul.",
        "Real life happens when you put the phone down.",
        "You have the power to choose focus over distraction.",
        "Every 'no' to distraction is a 'yes' to your dreams."
    )
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_blocking)
        
        val blockedPackage = intent.getStringExtra("blocked_package") ?: ""
        val appName = getAppNameFromPackage(blockedPackage)
        
        findViewById<TextView>(R.id.blocked_app_text).text = "$appName is blocked"
        findViewById<TextView>(R.id.quote_text).text = getRandomQuote()
        
        findViewById<Button>(R.id.close_button).setOnClickListener {
            // Go back to home screen
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(homeIntent)
            finish()
        }
        
        findViewById<Button>(R.id.open_focusflow_button).setOnClickListener {
            // Open FocusFlow app
            val launchIntent = packageManager.getLaunchIntentForPackage("com.example.focus")
            launchIntent?.let {
                it.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                startActivity(it)
            }
            finish()
        }
    }
    
    private fun getAppNameFromPackage(packageName: String): String {
        return when (packageName) {
            "com.google.android.youtube" -> "YouTube"
            "com.instagram.android" -> "Instagram"
            "com.facebook.katana" -> "Facebook"
            "com.zhiliaoapp.musically" -> "TikTok"
            "com.snapchat.android" -> "Snapchat"
            else -> "App"
        }
    }
    
    private fun getRandomQuote(): String {
        return motivationalQuotes[Random.nextInt(motivationalQuotes.size)]
    }
    
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Prevent going back to blocked app - redirect to home
        goToHome()
    }
    
    private fun goToHome() {
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        finish()
    }
}