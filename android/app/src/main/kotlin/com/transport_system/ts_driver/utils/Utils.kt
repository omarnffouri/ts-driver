package com.transport_system.ts_driver.utils

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent


object Utils {


    private fun isDeviceLocked(context: Context): Boolean {
        val keyguardManager = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        return keyguardManager.isDeviceSecure
    }


    fun getMainActivityClass(context: Context): Class<*>? {
        val packageName = context.packageName
        val launchIntent = context.packageManager.getLaunchIntentForPackage(packageName)
        val className = launchIntent?.component?.className
        return try {
            className?.let{ Class.forName(it) }
        } catch (e: ClassNotFoundException) {
            e.printStackTrace()
            null
        }
    }


    fun backToForeground(applicationContext: Context, activity: Activity?) {
        val packageName = applicationContext.packageName
        val focusIntent = applicationContext.packageManager.getLaunchIntentForPackage(packageName)!!.cloneFilter()

        focusIntent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)

        if (activity != null) {
            activity.startActivity(focusIntent)
        } else {
            focusIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            applicationContext.startActivity(focusIntent)
        }
    }
}