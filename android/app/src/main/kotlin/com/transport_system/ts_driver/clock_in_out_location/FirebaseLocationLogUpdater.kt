package com.transport_system.ts_driver.clock_in_out_location

import android.content.Context
import android.location.Location
import android.util.Log
import com.google.firebase.database.FirebaseDatabase
import com.transport_system.ts_driver.data_providers.MyDetails
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.time.format.DateTimeFormatter

class FirebaseLocationLogUpdater {

    fun updateLocationInFirebase(context: Context, location : Location){
        val myDetails : MyDetails = MyDetails.loadFromSharedPrefs(context) ?: return
        val clockInOutSession : ClockInOutSession = ClockInOutSession.loadFromSharedPrefs(context)
            ?: return
        val dataToUpdate = mapOf(
            "user_id" to myDetails.userId,
            "timestamp" to mapOf(".sv" to "timestamp"),
            "name" to "${myDetails.firstName} ${myDetails.lastName}",
            "lat" to location.latitude,
            "lng" to location.longitude,
        )
        updateLocationLog(myDetails,clockInOutSession, dataToUpdate)
        updateLiveLocation(myDetails,clockInOutSession, dataToUpdate)

    }

    // function to update live location in the Firebase
    @OptIn(DelicateCoroutinesApi::class)
    private fun updateLiveLocation(myDetails: MyDetails, clockInOutSession: ClockInOutSession, data : Map<String,Any?>){
        val root = if (clockInOutSession.isStagingServer == true)
            "user_tracking_live_Staging"
        else "user_tracking_live"

        GlobalScope.launch(Dispatchers.IO) {
            val liveRef = FirebaseDatabase.getInstance()
                .reference
                .child(root)
                .child(getCurrentDateInFormat())
                .child(myDetails.userId!!.toString())

            // updating live location
            try {

                liveRef.get().addOnCompleteListener {
                    if(it.isSuccessful){
                        val snapShot = it.result

                        if (snapShot.exists() && snapShot.value is Map<*, *>) {
                            val snapValue = snapShot.value as Map<*, *>
                            val firstKey = snapValue.keys.first()

                            // Document exists, update its data
                            if (firstKey == (clockInOutSession.sessionId!!)) {
                                liveRef.child(clockInOutSession.sessionId!!).updateChildren(data)
                            } else {
                                // Document exists, but with old collection, remove and create new
                                liveRef.removeValue()
                                liveRef.child(clockInOutSession.sessionId!!).setValue(data)
                            }
                        } else {
                            // If the document does not exist, create it
                            liveRef.child(clockInOutSession.sessionId!!).setValue(data)
                        }

                    }
                    else{
                        // If the document does not exist, create it
                        liveRef.child(clockInOutSession.sessionId!!).setValue(data)
                        Log.d("hashim","task not successful for live snapshot")
                    }
                }



            } catch (error:Exception) {
                Log.d("hashim",error.toString())
            }
        }


    }

    // function to update location log in the Firebase
    @OptIn(DelicateCoroutinesApi::class)
    private fun updateLocationLog(myDetails: MyDetails, clockInOutSession: ClockInOutSession, data : Map<String,Any?>){
        val root = if (clockInOutSession.isStagingServer == true)
         "user_tracking_logs_Staging"
        else "user_tracking_logs"

        GlobalScope.launch(Dispatchers.IO) {
            val logsRef = FirebaseDatabase.getInstance()
                .reference
                .child(root)
                .child(getCurrentDateInFormat())
                .child(myDetails.userId!!.toString())
                .child(clockInOutSession.sessionId!!)

            // updating log
            try {
                logsRef.push().setValue(data)
            } catch (error:Exception) {
                Log.d("hashim",error.toString())
            }
        }
    }

    private fun getCurrentDateInFormat(): String {
        val currentDate = LocalDate.now()
        val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd")
        return currentDate.format(formatter)
    }
}