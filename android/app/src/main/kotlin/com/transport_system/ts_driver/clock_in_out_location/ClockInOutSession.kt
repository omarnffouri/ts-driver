package com.transport_system.ts_driver.clock_in_out_location

import android.content.Context

class ClockInOutSession  {
    companion object{
        private const val SessionId : String = "flutter.sessionId"
        private const val IsStagingServer : String = "flutter.isStagingServer"
        private const val SessionStartedAt : String = "flutter.sessionStartedAt"

        fun loadFromSharedPrefs(context : Context) : ClockInOutSession?{
            return try {
                val sharedPrefs = context.getSharedPreferences("FlutterSharedPreferences",Context.MODE_PRIVATE)
                val sessionId = sharedPrefs.getString(SessionId ,"")
                val isStagingServer = sharedPrefs.getBoolean(IsStagingServer,true)
                val sessionStartedAt = sharedPrefs.getLong(SessionStartedAt,0)
                if(sessionId.isNullOrEmpty()){
                    null
                } else{
                    val obj = ClockInOutSession()
                    obj.sessionId = sessionId
                    obj.isStagingServer = isStagingServer
                    obj.sessionStartedAt = sessionStartedAt
                    obj
                }
            } catch (_:Exception){
                null
            }
        }
    }


    var sessionId: String? = null
    var isStagingServer: Boolean? = null
    var sessionStartedAt : Long? = null

}

