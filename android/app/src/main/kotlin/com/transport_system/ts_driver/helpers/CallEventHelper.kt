package com.transport_system.ts_driver.helpers

import android.content.Context
import android.util.ArrayMap
import android.util.Log
import com.transport_system.ts_driver.network.models.CallEventResponse
import com.transport_system.ts_driver.network.RetrofitClient
import com.transport_system.ts_driver.telecom.models.CallPayload
import com.transport_system.ts_driver.data_providers.MyDetails
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


object CallEventHelper {


    //
    fun callRinging(payload : CallPayload, context: Context){
        try {
            // retrieve my details from shared prefs
            val myDetails = MyDetails.loadFromSharedPrefs(context)
            if(myDetails != null){

                val eventDetails: MutableMap<String?, Any?> = ArrayMap()
                eventDetails["channelName"] = payload.channelName
                eventDetails["conversationId"] = payload.conversationId
                eventDetails["conversationType"] = payload.conversationType
                eventDetails["callType"] = payload.callType
                eventDetails["messageId"] = payload.messageId


                val dataToApi: MutableMap<String?, Any?> = ArrayMap()
                dataToApi["eventName"] = "call-ringing"
                dataToApi["eventDetails"] = eventDetails
                //
                val body = JSONObject(dataToApi).toString()
                    .toRequestBody("application/json; charset=utf-8".toMediaTypeOrNull())

                // get client
                RetrofitClient.getClient(myDetails.serverUrl!!).placeCallEvent("Bearer ${myDetails.token!!}", requestBody = body).enqueue(object : Callback<CallEventResponse> {
                    override fun onResponse(call: Call<CallEventResponse>, response: Response<CallEventResponse>) {
                    }

                    override fun onFailure(call: Call<CallEventResponse>, t: Throwable) {

                    }
                })
            }
        }
        catch (_:Exception){
        }
    }

    fun callRejected(payload : CallPayload, context: Context){
        try {
            // retrieve my details from shared prefs
            val myDetails = MyDetails.loadFromSharedPrefs(context)
            if(myDetails != null){

                val eventDetails: MutableMap<String?, Any?> = ArrayMap()
                eventDetails["channelName"] = payload.channelName
                eventDetails["conversationId"] = payload.conversationId
                eventDetails["conversationType"] = payload.conversationType
                eventDetails["callType"] = payload.callType
                eventDetails["messageId"] = payload.messageId


                val dataToApi: MutableMap<String?, Any?> = ArrayMap()
                dataToApi["eventName"] = "call-declined"
                dataToApi["eventDetails"] = eventDetails
                //
                val body = JSONObject(dataToApi).toString()
                    .toRequestBody("application/json; charset=utf-8".toMediaTypeOrNull())


                // get client
                RetrofitClient.getClient(myDetails.serverUrl!!).placeCallEvent("Bearer ${myDetails.token!!}", requestBody= body).enqueue(object : Callback<CallEventResponse> {
                    override fun onResponse(call: Call<CallEventResponse>, response: Response<CallEventResponse>) {
                    }

                    override fun onFailure(call: Call<CallEventResponse>, t: Throwable) {
                        Log.d("hashim",t.message,t.cause)
                    }
                })
            }


        }
        catch (e:Exception){
            Log.d("hashim",e.message,e)
        }
    }

    fun callTimeOut(payload : CallPayload, context: Context){
        try {
            // retrieve my details from shared prefs
            val myDetails = MyDetails.loadFromSharedPrefs(context)
            if(myDetails != null){

                val eventDetails: MutableMap<String?, Any?> = ArrayMap()
                eventDetails["channelName"] = payload.channelName
                eventDetails["conversationId"] = payload.conversationId
                eventDetails["conversationType"] = payload.conversationType
                eventDetails["callType"] = payload.callType
                eventDetails["messageId"] = payload.messageId


                val dataToApi: MutableMap<String?, Any?> = ArrayMap()
                dataToApi["eventName"] = "no-answer"
                dataToApi["eventDetails"] = eventDetails
                //
                val body = JSONObject(dataToApi).toString()
                    .toRequestBody("application/json; charset=utf-8".toMediaTypeOrNull())

                // get client
                RetrofitClient.getClient(myDetails.serverUrl!!).placeCallEvent("Bearer ${myDetails.token!!}", requestBody = body).enqueue(object : Callback<CallEventResponse> {
                    override fun onResponse(call: Call<CallEventResponse>, response: Response<CallEventResponse>) {

                    }

                    override fun onFailure(call: Call<CallEventResponse>, t: Throwable) {

                    }
                })
            }

        }
        catch (_:Exception){
        }
    }

    fun userBusy(payload : CallPayload, context: Context){
        try {
            // retrieve my details from shared prefs
            val myDetails = MyDetails.loadFromSharedPrefs(context)
            if(myDetails != null){

                    val eventDetails: MutableMap<String?, Any?> = ArrayMap()
                    eventDetails["channelName"] = payload.channelName
                    eventDetails["conversationId"] = payload.conversationId
                    eventDetails["conversationType"] = payload.conversationType
                    eventDetails["callType"] = payload.callType
                    eventDetails["messageId"] = payload.messageId


                    val dataToApi: MutableMap<String?, Any?> = ArrayMap()
                    dataToApi["eventName"] = "user-bueasy"
                    dataToApi["eventDetails"] = eventDetails
                    //
                    val body = JSONObject(dataToApi).toString()
                        .toRequestBody("application/json; charset=utf-8".toMediaTypeOrNull())


                    // get client
                    RetrofitClient.getClient(myDetails.serverUrl!!).placeCallEvent("Bearer ${myDetails.token!!}", requestBody= body).enqueue(object : Callback<CallEventResponse> {
                        override fun onResponse(call: Call<CallEventResponse>, response: Response<CallEventResponse>) {
                        }

                        override fun onFailure(call: Call<CallEventResponse>, t: Throwable) {
                        }
                    })

            }
        }
        catch (_:Exception){
        }
    }

    fun callEnded(payload : CallPayload, context: Context, duration : Int) {
        try {
            // retrieve my details from shared prefs
            val myDetails = MyDetails.loadFromSharedPrefs(context)
            if(myDetails != null){

                val eventDetails: MutableMap<String?, Any?> = ArrayMap()
                eventDetails["channelName"] = payload.channelName
                eventDetails["conversationId"] = payload.conversationId
                eventDetails["conversationType"] = payload.conversationType
                eventDetails["callType"] = payload.callType
                eventDetails["messageId"] = payload.messageId
                eventDetails["duration"] = duration


                val dataToApi: MutableMap<String?, Any?> = ArrayMap()
                dataToApi["eventName"] = "call-ended"
                dataToApi["eventDetails"] = eventDetails
                //
                val body = JSONObject(dataToApi).toString()
                    .toRequestBody("application/json; charset=utf-8".toMediaTypeOrNull())


                // get client
                RetrofitClient.getClient(myDetails.serverUrl!!).placeCallEvent("Bearer ${myDetails.token!!}", requestBody= body).enqueue(object : Callback<CallEventResponse> {
                    override fun onResponse(call: Call<CallEventResponse>, response: Response<CallEventResponse>) {
                    }

                    override fun onFailure(call: Call<CallEventResponse>, t: Throwable) {
                    }
                })
            }
        }
        catch (_:Exception){
        }
    }

    fun ongoingCallDeclined(payload : CallPayload, context: Context){
        try {
            // retrieve my details from shared prefs
            val myDetails = MyDetails.loadFromSharedPrefs(context)
            if(myDetails != null){

                val notificationPayload = payload.toMap().toMutableMap()
                notificationPayload["incomming_declined"] = true
                notificationPayload["call_placed_at"] = System.currentTimeMillis()


                val dataToApi: MutableMap<String?, Any?> = ArrayMap()
                dataToApi["eventName"] = "incomming-call-declined"
                dataToApi["eventDetails"] = notificationPayload
                //
                val body = JSONObject(dataToApi).toString()
                    .toRequestBody("application/json; charset=utf-8".toMediaTypeOrNull())


                // get client
                RetrofitClient.getClient(myDetails.serverUrl!!).placeCallEvent("Bearer ${myDetails.token!!}", requestBody= body).enqueue(object : Callback<CallEventResponse> {
                    override fun onResponse(call: Call<CallEventResponse>, response: Response<CallEventResponse>) {
                    }

                    override fun onFailure(call: Call<CallEventResponse>, t: Throwable) {
                    }
                })

            }
        }
        catch (_:Exception){
        }
    }

    fun callAccepted(payload : CallPayload, context: Context){
        try {
            // retrieve my details from shared prefs
            val myDetails = MyDetails.loadFromSharedPrefs(context)
            if(myDetails != null){

                val eventDetails: MutableMap<String?, Any?> = ArrayMap()
                eventDetails["channelName"] = payload.channelName
                eventDetails["conversationId"] = payload.conversationId
                eventDetails["conversationType"] = payload.conversationType
                eventDetails["callType"] = payload.callType
                eventDetails["messageId"] = payload.messageId


                val dataToApi: MutableMap<String?, Any?> = ArrayMap()
                dataToApi["eventName"] = "call-accepted"
                dataToApi["eventDetails"] = eventDetails
                //
                val body = JSONObject(dataToApi).toString()
                    .toRequestBody("application/json; charset=utf-8".toMediaTypeOrNull())

                // get client
                RetrofitClient.getClient(myDetails.serverUrl!!).placeCallEvent("Bearer ${myDetails.token!!}", requestBody= body).enqueue(object : Callback<CallEventResponse> {
                    override fun onResponse(call: Call<CallEventResponse>, response: Response<CallEventResponse>) {
                    }

                    override fun onFailure(call: Call<CallEventResponse>, t: Throwable) {
                    }
                })

            }
        }
        catch (_:Exception){
        }
    }

}