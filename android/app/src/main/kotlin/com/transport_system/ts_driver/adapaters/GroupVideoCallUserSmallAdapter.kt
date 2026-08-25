package com.transport_system.ts_driver.adapaters

import android.annotation.SuppressLint
import android.view.LayoutInflater
import android.view.SurfaceView
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.ViewHolder
import com.squareup.picasso.Picasso
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.agora.models.CallUser
import com.transport_system.ts_driver.databinding.GroupVideoCallSmallItemViewBinding
import com.transport_system.ts_driver.helpers.AppLogger

class GroupVideoCallUserSmallAdapter(private val callUser: ArrayList<CallUser>) : RecyclerView.Adapter<GroupVideoCallUserSmallAdapter.ItemViewHolder>() {


    fun updateList(newUsers: List<CallUser>) {
        val diffResult = DiffUtil.calculateDiff(CallUserDiffCallback(callUser, newUsers))
        callUser.clear()
        callUser.addAll(newUsers)
        diffResult.dispatchUpdatesTo(this)
    }


    @SuppressLint("NotifyDataSetChanged")
    fun hardRefresh(){
        notifyDataSetChanged()
    }


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {
        return ItemViewHolder(GroupVideoCallSmallItemViewBinding.inflate(LayoutInflater.from(parent.context), parent, false))
    }

    override fun getItemCount(): Int {
        return callUser.size
    }

    override fun onBindViewHolder(holder: ItemViewHolder, position: Int) {
        val user = callUser[position]
        AppLogger.log("On bind called for the user ===> $${user.remoteId}")
        holder.binding.userName.text = user.participant?.name ?: ""
        holder.binding.userDesignation.text = user.participant?.userDesignation ?: ""
        try {
            Picasso.get().load(user.participant?.image).into(holder.binding.userImage)
        }
        catch (_:Exception){}


        try {
            holder.observeSafely(user.micMuted) { muted ->
                if(muted){
                    holder.binding.audioMuteIcon.visibility = View.VISIBLE
                    holder.binding.activeSpeakerIcon.visibility = View.GONE
                }
                else{
                    holder.binding.audioMuteIcon.visibility = View.GONE
                }
            }

            holder.observeSafely(user.videoMuted)  { muted ->
                AppLogger.log("Video mute called for uid : ${user.remoteId} mute : $muted")
                if(muted){
                    holder.binding.userVideoView.visibility = View.GONE
                    holder.binding.videoMuteIcon.visibility = View.VISIBLE
                    holder.binding.userImage.visibility = View.VISIBLE
                }
                else{
                    holder.binding.userVideoView.visibility = View.VISIBLE
                    holder.binding.videoMuteIcon.visibility = View.GONE
                    holder.binding.userImage.visibility = View.GONE

//                    holder.binding.userVideoView.removeAllViews()
//                    val surfaceView = SurfaceView(holder.itemView.context)
                    AgoraManager.instance.setupRemoteVideoView(surfaceView = holder.binding.userVideoView, uid = user.remoteId)
//                    holder.binding.userVideoView.addView(surfaceView)
                }
            }

            holder.observeSafely(user.isSpeaking)  { speaking ->
                holder.binding.activeSpeakerIcon.visibility = if(speaking) View.VISIBLE else View.GONE
            }
        }
        catch (e:Exception){
            AppLogger.log("Exception while listening for the mic/video mute and active state of user in group video call adapter ===> ${e.message}")
        }


        holder.binding.root.setOnClickListener {
            AgoraManager.instance.callViewModel.onRemoteUserSelected(user = user)
        }

    }

    override fun onViewAttachedToWindow(holder: ItemViewHolder) {
        super.onViewAttachedToWindow(holder)
        AppLogger.log("onViewAttachedToWindow called in small list view")
        holder.markAttached()
    }

    override fun onViewDetachedFromWindow(holder: ItemViewHolder) {
        super.onViewDetachedFromWindow(holder)
        AppLogger.log("onViewDetachedFromWindow called in small list view")
        holder.markDetached()
    }



    class ItemViewHolder(val binding: GroupVideoCallSmallItemViewBinding) : ViewHolder(binding.root), LifecycleOwner{

        private val lifecycleRegistry = LifecycleRegistry(this)
        private val activeObservers = mutableListOf<() -> Unit>()

        init {
            lifecycleRegistry.currentState = Lifecycle.State.INITIALIZED
        }

        fun markAttached() {
            lifecycleRegistry.currentState = Lifecycle.State.STARTED
        }

        fun markDetached() {
            activeObservers.forEach { it.invoke() }
            activeObservers.clear()
            lifecycleRegistry.currentState = Lifecycle.State.DESTROYED
        }

        fun <T> observeSafely(liveData: LiveData<T>, observer: Observer<T>) {
            liveData.observe(this) {
                observer.onChanged(it)
            }
            activeObservers.add { liveData.removeObserver(observer) }
        }

        override val lifecycle: Lifecycle
            get() = lifecycleRegistry

    }
}