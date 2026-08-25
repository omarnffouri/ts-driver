package com.transport_system.ts_driver.telecom.models
import android.os.Bundle


class CallPayload  {

    var conversationType: String? = null
    var callerName: String? = null
    var conversationId: Int? = null
    var messageId: Int? = null
    var callerId: Int? = null
    var callerModelType: String? = null
    var channelName: String? = null
    var callType: String? = null
    var callerImage: String? = null
    var callPlacedAt: String? = null
    var tempCallId: String? = null


    var receiverName : String? = null
    var receiverImage : String? = null


    fun isVideoCall() : Boolean{
        return callType == "video"
    }

    // Serialization to Map
    fun toMap(): Map<String, Any?> {
        val map: MutableMap<String, Any?> = HashMap()
        map[CONVERSATION_TYPE] = conversationType
        map[CALLER_NAME] = callerName
        map[CONVERSATION_ID] = conversationId?.toString()
        map[CALLER_ID] = callerId?.toString()
        map[CALLER_MODEL_MODEL] = callerModelType
        map[CHANNEL_NAME] = channelName
        map[CALL_TYPE] = callType
        map[CALLER_IMAGE] = callerImage
        map[MESSAGE_ID] = messageId?.toString()
        map[CALL_PLACED_AT] = callPlacedAt
        map[TEMP_CALL_ID] = tempCallId
        map[RECEIVER_NAME] = receiverName
        map[RECEIVER_IMAGE] = receiverImage
        return map
    }


    // Serialization to Bundle
    fun toBundle(): Bundle {
        val bundle = Bundle()
        bundle.putString(CONVERSATION_TYPE, conversationType)
        bundle.putString(CALLER_NAME, callerName)
        bundle.putInt(CONVERSATION_ID, conversationId ?: -1)
        bundle.putInt(MESSAGE_ID, messageId ?: -1)
        bundle.putInt(CALLER_ID, callerId ?: -1)
        bundle.putString(CALLER_MODEL_MODEL, callerModelType)
        bundle.putString(CHANNEL_NAME, channelName)
        bundle.putString(CALL_TYPE, callType)
        bundle.putString(CALLER_IMAGE, callerImage)
        bundle.putString(CALL_PLACED_AT, callPlacedAt)
        bundle.putString(TEMP_CALL_ID, tempCallId)
        bundle.putString(RECEIVER_NAME, receiverName)
        bundle.putString(RECEIVER_IMAGE, receiverImage)
        return bundle
    }

    companion object {


        // bundle keys
        const val CONVERSATION_TYPE = "conversationType"
        const val CALLER_NAME = "caller_name"
        const val CONVERSATION_ID = "conversationId"
        const val MESSAGE_ID = "messageId"
        const val CALLER_ID = "caller_id"
        const val CALLER_MODEL_MODEL = "caller_model_type"
        const val CHANNEL_NAME = "channelName"
        const val CALL_TYPE = "callType"
        const val CALLER_IMAGE = "caller_image"
        const val CALL_PLACED_AT = "call_placed_at"
        const val TEMP_CALL_ID = "temp_call_id"
        const val RECEIVER_NAME = "receiverName"
        const val RECEIVER_IMAGE = "receiverImage"


        // deserialization from Map
        fun fromMap(map: Map<String?, Any?>): CallPayload {
            val obj = CallPayload()
            obj.conversationType = (map[CONVERSATION_TYPE] as String?)
            obj.callerName = (map[CALLER_NAME] as String?)
            obj.conversationId = (map[CONVERSATION_ID] as String?)?.toIntOrNull()
            obj.messageId = (map[MESSAGE_ID] as String?)?.toIntOrNull()
            obj.callerId = (map[CALLER_ID] as String?)?.toIntOrNull()
            obj.callerModelType = (map[CALLER_MODEL_MODEL] as String?)
            obj.channelName = (map[CHANNEL_NAME] as String?)
            obj.callType = (map[CALL_TYPE] as String?)
            obj.callerImage = (map[CALLER_IMAGE] as String?)
            obj.callPlacedAt = (map[CALL_PLACED_AT] as String?)
            obj.tempCallId = (map[TEMP_CALL_ID] as String?)
            obj.receiverName = (map[RECEIVER_NAME] as String?)
            obj.receiverImage = (map[RECEIVER_IMAGE] as String?)
            return obj
        }


        // Deserialization from Bundle
        fun fromBundle(bundle: Bundle): CallPayload {
            val obj = CallPayload()
            obj.conversationType = bundle.getString(CONVERSATION_TYPE)
            obj.callerName = bundle.getString(CALLER_NAME)
            obj.conversationId = bundle.getInt(CONVERSATION_ID, -1).takeIf { it != -1 }
            obj.messageId = bundle.getInt(MESSAGE_ID, -1).takeIf { it != -1 }
            obj.callerId = bundle.getInt(CALLER_ID, -1).takeIf { it != -1 }
            obj.callerModelType = bundle.getString(CALLER_MODEL_MODEL)
            obj.channelName = bundle.getString(CHANNEL_NAME)
            obj.callType = bundle.getString(CALL_TYPE)
            obj.callerImage = bundle.getString(CALLER_IMAGE)
            obj.callPlacedAt = bundle.getString(CALL_PLACED_AT)
            obj.tempCallId = bundle.getString(TEMP_CALL_ID)
            obj.receiverName = bundle.getString(RECEIVER_NAME)
            obj.receiverImage = bundle.getString(RECEIVER_IMAGE)
            return obj
        }

    }
}

