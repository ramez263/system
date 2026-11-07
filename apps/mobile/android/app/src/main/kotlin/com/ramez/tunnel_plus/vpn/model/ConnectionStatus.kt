package com.ramez.tunnel_plus.vpn.model

enum class ConnectionStatus(val value: String) {
    DISCONNECTED("disconnected"),
    PREPARING("preparing"),
    CONNECTING("connecting"),
    CONNECTED("connected"),
    RECONNECTING("reconnecting"),
    FAILED("failed");

    companion object {
        fun fromValue(value: String): ConnectionStatus {
            return entries.find { it.value.equals(value, ignoreCase = true) } ?: DISCONNECTED
        }
    }
}
