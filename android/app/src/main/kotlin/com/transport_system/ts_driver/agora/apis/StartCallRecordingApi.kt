package com.transport_system.ts_driver.agora.apis

import com.transport_system.ts_driver.agora.models.StartCallRecordingParamsModel
import com.transport_system.ts_driver.agora.models.StartCallRecordingResponseModel
import com.transport_system.ts_driver.data_providers.MyDetails
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.network.RetrofitClient
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

object StartCallRecordingApi {


    fun startRecording(myDetails: MyDetails, messageId: Int, channelName:String, onSuccess : (StartCallRecordingResponseModel?) -> Unit){
        try {

            RetrofitClient.getClient(myDetails.serverUrl!!).startCallRecording("Bearer ${myDetails.token!!}", body = StartCallRecordingParamsModel(
                messageId = messageId,
                channelName = channelName,
                uid = generateRandomSixDigitNumber()
            )).enqueue(object :
                Callback<StartCallRecordingResponseModel> {
                override fun onResponse(call: Call<StartCallRecordingResponseModel>, response: Response<StartCallRecordingResponseModel>) {
                    onSuccess(response.body())
                }

                override fun onFailure(call: Call<StartCallRecordingResponseModel>, t: Throwable) {
                    onSuccess(null)
                }
            })
        }
        catch (e:Exception){
            AppLogger.log("Exception while starting call recording (try-catch) ===> ${e.message}")
            onSuccess(null)
        }
    }


    private fun generateRandomSixDigitNumber(): Int {
        return (100000..999999).random()
    }

}