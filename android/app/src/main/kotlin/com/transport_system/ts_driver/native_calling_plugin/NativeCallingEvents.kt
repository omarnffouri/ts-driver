package com.transport_system.ts_driver.native_calling_plugin

enum class NativeCallingEvents {
    CALL_RECEIVED,
    CALL_PLACED,
    CALL_TIME,
    CALL_ENDED,
    CALL_DECLINED,
    CALL_NO_ANSWER,
    CALL_USER_BUSY,
    CALL_FAILED;

    fun getName(): String {
        return when (this) {
            CALL_RECEIVED -> "callReceived"
            CALL_PLACED -> "callPlaced"
            CALL_TIME -> "callTime"
            CALL_ENDED -> "callEnded"
            CALL_DECLINED -> "callDeclined"
            CALL_NO_ANSWER -> "callNoAnswer"
            CALL_USER_BUSY -> "callUserBusy"
            CALL_FAILED -> "callFailed"
        }
    }
}
