package com.transport_system.ts_driver.agora.models

import androidx.lifecycle.MutableLiveData
import com.transport_system.ts_driver.data_providers.models.common.ParticipantModel

class CallUser(
    val remoteId: Int,
    var participant: ParticipantModel? = null
) {
    var videoMuted: MutableLiveData<Boolean> = MutableLiveData(false)
    var micMuted: MutableLiveData<Boolean> = MutableLiveData(false)
    var isSpeaking: MutableLiveData<Boolean> = MutableLiveData(false)

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as CallUser
        return remoteId == other.remoteId && participant == other.participant
    }

    override fun hashCode(): Int {
        var result = remoteId
        result = 31 * result + (participant?.hashCode() ?: 0)
        return result
    }
}
