package com.transport_system.ts_driver.telecom.managers

import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.telecom.PhoneAccount
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import androidx.core.content.ContextCompat
import com.transport_system.ts_driver.R
import com.transport_system.ts_driver.telecom.service.ConnectionService


object PhoneAccountManager {

    private const val PHONE_ACCOUNT_HANDLER_ID = "e7cf8f14-1c7f-48a2-8a22-8c8bc6a9685e"

    fun registerPhoneAccount(context: Context) {

        // check if already registered then no need to register again
        if (isPhoneAccountRegistered(context = context)) {
            return
        }

        // phone account handler
        val phoneAccountHandle = getPhoneAccountHandler(context = context)

        // creating and configuring phone account
        val phoneAccount = PhoneAccount.builder(phoneAccountHandle, "TS Admin")
            .setCapabilities(PhoneAccount.CAPABILITY_SELF_MANAGED)
            .setHighlightColor(
                ContextCompat.getColor(
                    context,
                    R.color.colorPrimary
                )
            ) // Optional UI color
            .setShortDescription("TS Admin VoIP Service")
            .build()

        // registering phone account
        getTelecomManager(context = context).registerPhoneAccount(phoneAccount)
    }

     fun getTelecomManager(context: Context): TelecomManager {
        return context.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
    }

    private fun isPhoneAccountRegistered(context: Context): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val telecomManager = getTelecomManager(context)
            val selfManagedPhoneAccounts = telecomManager.getOwnSelfManagedPhoneAccounts()
            return selfManagedPhoneAccounts.any { it.id == PHONE_ACCOUNT_HANDLER_ID }
        } else {
            return false
        }
    }

     fun getPhoneAccountHandler(context: Context): PhoneAccountHandle {
        val componentName = ComponentName(context, ConnectionService::class.java)
        return PhoneAccountHandle(componentName, PHONE_ACCOUNT_HANDLER_ID)
    }

}