package com.transport_system.ts_driver.data_providers

import android.content.Context


class MyDetails  {
    companion object{
        private const val TOKEN : String = "flutter.token"
        private const val FIRST_NAME  : String = "flutter.firstName"
        private const val LAST_NAME  : String = "flutter.lastName"
        private const val USER_ID  : String = "flutter.userId"
        private const val APPLICANT_ID  : String = "flutter.applicantId"
        private const val MODEL_TYPE  : String = "flutter.modelType"
        private const val IMAGE  : String = "flutter.image"
        private const val SERVER_URL : String = "flutter.serverUrl"

        // realtime (Pusher/Reverb) config mirrored from the server's
        // realtime-configuration by Dart (SharedPrefrencesHelper.storeRealtimeConfig).
        private const val REALTIME_KEY : String = "flutter.realtimeKey"
        private const val REALTIME_HOST : String = "flutter.realtimeHost"
        private const val REALTIME_PORT : String = "flutter.realtimePort"
        private const val REALTIME_AUTH_URL : String = "flutter.realtimeAuthUrl"
        private const val REALTIME_AGORA_APP_ID : String = "flutter.realtimeAgoraAppId"
        private const val REALTIME_CONFIG_VERSION : String = "flutter.realtimeConfigVersion"

        private fun prefs(context: Context) =
            context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        // Return null (not "") when blank so callers can use a plain Elvis fallback.
        fun realtimeKey(context: Context): String? =
            prefs(context).getString(REALTIME_KEY, null)?.takeIf { it.isNotEmpty() }

        fun realtimeHost(context: Context): String? =
            prefs(context).getString(REALTIME_HOST, null)?.takeIf { it.isNotEmpty() }

        // shared_preferences stores Dart ints as Long on Android.
        fun realtimePort(context: Context): Int? {
            val value = prefs(context).getLong(REALTIME_PORT, 0L)
            return if (value > 0L) value.toInt() else null
        }

        fun realtimeAuthUrl(context: Context): String? =
            prefs(context).getString(REALTIME_AUTH_URL, null)?.takeIf { it.isNotEmpty() }

        // Agora app id mirrored from the server's realtime-configuration; null
        // when blank so callers can fall back to the hardcoded per-env id.
        fun agoraAppId(context: Context): String? =
            prefs(context).getString(REALTIME_AGORA_APP_ID, null)?.takeIf { it.isNotEmpty() }

        fun realtimeConfigVersion(context: Context): String? =
            prefs(context).getString(REALTIME_CONFIG_VERSION, null)?.takeIf { it.isNotEmpty() }

        // Persist a freshly-fetched realtime config into the same Flutter prefs
        // Dart mirrors into, so a cold-start call can self-heal a rotated config
        // without Dart running. Keys/types match SharedPrefrencesHelper exactly
        // (shared_preferences stores Dart ints as Long).
        fun storeRealtimeConfig(
            context: Context,
            key: String?,
            host: String?,
            port: Int?,
            authUrl: String?,
            agoraAppId: String?,
            configVersion: String?,
        ) {
            val editor = prefs(context).edit()
            if (!key.isNullOrEmpty()) editor.putString(REALTIME_KEY, key)
            if (!host.isNullOrEmpty()) editor.putString(REALTIME_HOST, host)
            if (port != null && port > 0) editor.putLong(REALTIME_PORT, port.toLong())
            if (!authUrl.isNullOrEmpty()) editor.putString(REALTIME_AUTH_URL, authUrl)
            if (!agoraAppId.isNullOrEmpty()) editor.putString(REALTIME_AGORA_APP_ID, agoraAppId)
            if (!configVersion.isNullOrEmpty()) editor.putString(REALTIME_CONFIG_VERSION, configVersion)
            editor.apply()
        }



        fun loadFromSharedPrefs(context : Context) : MyDetails?{
            try {
                val sharedPrefs = context.getSharedPreferences("FlutterSharedPreferences",Context.MODE_PRIVATE)
                val token = sharedPrefs.getString(TOKEN ,"")
                val firstName = sharedPrefs.getString(FIRST_NAME ,"")
                val lastName = sharedPrefs.getString(LAST_NAME ,"")
                val userId = sharedPrefs.getLong(USER_ID ,0)
                val applicantId = sharedPrefs.getLong(APPLICANT_ID ,0)
                val modelType = sharedPrefs.getString(MODEL_TYPE,"")
                val image = sharedPrefs.getString(IMAGE,"")
                val serverUrl = sharedPrefs.getString(SERVER_URL,"")
                return if(token.isNullOrEmpty() || (userId <= 0) || (applicantId <= 0) || serverUrl.isNullOrEmpty()){
                    null
                } else{
                    val obj = MyDetails()
                    obj.token = token
                    obj.firstName = firstName
                    obj.lastName = lastName
                    obj.userId = userId
                    obj.applicantId = applicantId
                    obj.modelType = modelType
                    obj.image = image
                    obj.serverUrl = serverUrl
                    obj
                }
            }
            catch (_:Exception){
                return  null
            }
        }



        fun isProduction(context: Context): Boolean{
            return ((!isStaging(context = context)) && (!isDevelopment(context = context)))
        }


        fun isStaging(context: Context) : Boolean{
            val serverUrl = loadFromSharedPrefs(context = context)?.serverUrl ?: return true
            return serverUrl.contains("staging")
        }

        fun isDevelopment(context: Context) : Boolean {
            val serverUrl = loadFromSharedPrefs(context = context)?.serverUrl ?: return true
            return serverUrl.contains("dev")
        }
    }


    var token: String? = null
    var firstName: String? = null
    var lastName: String? = null
    var modelType: String? = null
    var image: String? = null
    var serverUrl: String? = null
    var userId: Long? = null
    var applicantId: Long? = null




}

