package com.transport_system.ts_driver.network


import com.transport_system.ts_driver.agora.models.StartCallRecordingResponseModel
import com.transport_system.ts_driver.agora.models.StartCallRecordingParamsModel
import com.transport_system.ts_driver.network.models.CallEventResponse
import com.transport_system.ts_driver.network.models.RealtimeConfigResponse
import okhttp3.RequestBody
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.Field
import retrofit2.http.FormUrlEncoded
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Headers
import retrofit2.http.POST

interface ApiInterface {

    @Headers("Content-Type: application/json")
    @POST("chat/agora/call")
    fun placeCallEvent(
        @Header("Authorization") token: String,
        @Body requestBody: RequestBody
    ): Call<CallEventResponse>


    @Headers("Content-Type: application/json")
    @GET("admin/clock-in-out")
    fun clockInOut(
        @Header("Authorization") token: String
    ): Call<Void>


    @Headers("Content-Type: application/json")
    @GET("drivers/realtime-configuration")
    fun getRealtimeConfiguration(
        @Header("Authorization") token: String
    ): Call<RealtimeConfigResponse>



    @FormUrlEncoded
    @POST("chat/agora/token")
    fun getAgoraToken(
        @Header("Authorization") token: String,
        @Field("role") role:String,
        @Field("channelName") channelName:String,
        @Field("user") pid:Int,
    ): Call<String>


    @POST("chat/agora/startCallRecording")
    fun startCallRecording(
        @Header("Authorization") token: String,
        @Body body : StartCallRecordingParamsModel,
    ): Call<StartCallRecordingResponseModel>
}