package com.transport_system.ts_driver.agora.enums

enum class CallState(private val displayName: String) {
    IDLE("Calling..."),
    CALLING("Calling..."),
    RINGING("Ringing..."),
    DECLINED("Declined"),
    USER_BUSY("User Busy"),
    CONNECTING("Connecting..."),
    CONNECTED("Connected"),
    FAILED("Failed"),
    NOT_ANSWERED("Not Answered");

    // Method to get the display name
    fun getName(): String {
        return displayName
    }
}
