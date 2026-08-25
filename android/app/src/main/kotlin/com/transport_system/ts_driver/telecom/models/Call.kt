package com.transport_system.ts_driver.telecom.models

import java.util.Date
import java.util.UUID

class Call(
    var uuid: UUID,
    var callPayload: CallPayload,
    var isOutGoing: Boolean
) {

    private var connectingDate: Date? = null
    private var connectedDate: Date? = null



    var hasStartedConnecting: Boolean
        get() = connectingDate != null
        set(value) {
            connectingDate = if (value) Date() else null
        }


    var hasConnected: Boolean
        get() = connectedDate != null
        set(value) {
            connectedDate = if (value) Date() else null
        }


    fun callStarted() {
        if (!hasStartedConnecting) {
            hasStartedConnecting = true
        }
    }

    fun callAccepted() {
        if (!hasStartedConnecting) {
            hasStartedConnecting = true
        }
    }

    fun callConnected() {
        if (!hasConnected) {
            hasConnected = true
        }
    }

    // Match by UUID when the payload has a usable one, else by conversationId (only one call is active).
    fun matches(payload: CallPayload): Boolean {
        val payloadUuid = try {
            payload.tempCallId?.let { UUID.fromString(it) }
        } catch (_: Exception) {
            null
        }
        if (payloadUuid != null && payloadUuid == uuid) return true
        val convoId = callPayload.conversationId
        return convoId != null && convoId == payload.conversationId
    }

}