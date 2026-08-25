package com.transport_system.ts_driver.adapaters

import androidx.recyclerview.widget.DiffUtil
import com.transport_system.ts_driver.agora.models.CallUser

class CallUserDiffCallback(
    private val oldList: List<CallUser>,
    private val newList: List<CallUser>
) : DiffUtil.Callback() {

    override fun getOldListSize(): Int = oldList.size

    override fun getNewListSize(): Int = newList.size

    override fun areItemsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {
        return oldList[oldItemPosition].remoteId == newList[newItemPosition].remoteId
    }

    override fun areContentsTheSame(oldItemPosition: Int, newItemPosition: Int): Boolean {
        return oldList[oldItemPosition] == newList[newItemPosition]
    }
}