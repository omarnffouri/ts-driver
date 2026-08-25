package com.transport_system.ts_driver.agora.apis

import android.content.Context
import com.transport_system.ts_driver.data_providers.MyDetails
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.network.RetrofitClient
import com.transport_system.ts_driver.network.models.RealtimeConfigResponse
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

// Self-heals a rotated realtime config on the call path: fetch the latest
// config, and only when `config_version` differs from the mirrored one, rewrite
// the local values (websocket + agora app id). Mirrors PusherManager's
// version-gated refresh so a cold-start call always joins with a fresh app id.
// `onComplete` always fires (success, mismatch-write, or failure) so the call
// flow proceeds and degrades to the existing prefs / hardcoded fallback.
object RealtimeConfigApi {

    fun sync(context: Context, onComplete: () -> Unit) {
        try {
            val myDetails = MyDetails.loadFromSharedPrefs(context)
            if (myDetails?.serverUrl == null || myDetails.token == null) {
                onComplete()
                return
            }

            RetrofitClient.getClient(myDetails.serverUrl!!)
                .getRealtimeConfiguration("Bearer ${myDetails.token!!}")
                .enqueue(object : Callback<RealtimeConfigResponse> {
                    override fun onResponse(
                        call: Call<RealtimeConfigResponse>,
                        response: Response<RealtimeConfigResponse>
                    ) {
                        try {
                            val data = response.body()?.data
                            val newVersion = data?.configVersion
                            val storedVersion = MyDetails.realtimeConfigVersion(context)
                            val agoraAppId = data?.agora?.appId

                            if (data != null &&
                                !newVersion.isNullOrEmpty() &&
                                newVersion != storedVersion
                            ) {
                                // Only persist (and advance config_version) when a
                                // usable agora app id was parsed — otherwise a parse
                                // miss / type drift would bump the stored version
                                // while leaving a stale app id, wedging the client on
                                // the old id under the new version. Skipping lets the
                                // next call retry.
                                if (agoraAppId.isNullOrEmpty()) {
                                    AppLogger.log("[Realtime] native config sync: agora app_id missing; not advancing version")
                                } else {
                                    MyDetails.storeRealtimeConfig(
                                        context = context,
                                        key = data.websocket?.key,
                                        host = data.websocket?.host,
                                        port = data.websocket?.port,
                                        authUrl = data.websocket?.authEndpoint,
                                        agoraAppId = agoraAppId,
                                        configVersion = newVersion,
                                    )
                                    AppLogger.log("[Realtime] native config synced (version $storedVersion -> $newVersion)")
                                }
                            }
                        } catch (e: Exception) {
                            AppLogger.log("[Realtime] native config sync parse error ===> ${e.message}")
                        }
                        onComplete()
                    }

                    override fun onFailure(call: Call<RealtimeConfigResponse>, t: Throwable) {
                        AppLogger.log("[Realtime] native config sync failed ===> ${t.message}")
                        onComplete()
                    }
                })
        } catch (e: Exception) {
            AppLogger.log("[Realtime] native config sync exception ===> ${e.message}")
            onComplete()
        }
    }
}
