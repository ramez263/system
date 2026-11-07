package com.ramez.tunnel_plus.vpn.model

data class TrafficStats(
    val bytesIn: Long = 0L,
    val bytesOut: Long = 0L,
    val downloadSpeedBps: Long = 0L,
    val uploadSpeedBps: Long = 0L,
    val durationSeconds: Long = 0L
)
