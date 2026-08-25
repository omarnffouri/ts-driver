package com.transport_system.ts_driver.helpers

import java.util.UUID

object UUIDHelper {

    fun parseUUID(uuid: String?): UUID {
        try {
            if (uuid == null) {
                return UUID.randomUUID()
            }
            return UUID.fromString(uuid)
        } catch (_: Exception) {
            return UUID.randomUUID()
        }
    }
}