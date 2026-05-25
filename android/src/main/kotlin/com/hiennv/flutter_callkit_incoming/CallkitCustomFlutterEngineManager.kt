package com.hiennv.flutter_callkit_incoming

import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import org.json.JSONObject

object CallkitCustomFlutterEngineManager {
    private const val TAG = "CallkitCustomFlutter"
    private const val ENGINE_ID_PREFIX = "callkit_custom_header_"

    fun hasCustomRoute(data: Bundle?): Boolean {
        return !data?.getString(
            CallkitConstants.EXTRA_CALLKIT_INCOMING_CUSTOM_WIDGET_ROUTE,
            ""
        ).isNullOrEmpty()
    }

    fun engineId(data: Bundle?): String {
        val callId = data?.getString(
            CallkitConstants.EXTRA_CALLKIT_ID,
            "callkit_incoming"
        ) ?: "callkit_incoming"
        return "$ENGINE_ID_PREFIX$callId"
    }

    fun routeWithPayload(data: Bundle?): String? {
        val route = data?.getString(
            CallkitConstants.EXTRA_CALLKIT_INCOMING_CUSTOM_WIDGET_ROUTE,
            ""
        ).orEmpty()
        if (route.isEmpty()) {
            return null
        }

        val payload = HashMap<String, Any?>()
        payload["id"] = data?.getString(CallkitConstants.EXTRA_CALLKIT_ID, "")
        payload["nameCaller"] = data?.getString(CallkitConstants.EXTRA_CALLKIT_NAME_CALLER, "")
        payload["handle"] = data?.getString(CallkitConstants.EXTRA_CALLKIT_HANDLE, "")
        payload["type"] = data?.getInt(CallkitConstants.EXTRA_CALLKIT_TYPE, 0)
        payload["avatar"] = data?.getString(CallkitConstants.EXTRA_CALLKIT_AVATAR, "")
        payload["extra"] = data?.getSerializable(CallkitConstants.EXTRA_CALLKIT_EXTRA)
        val customData = data?.getSerializable(
            CallkitConstants.EXTRA_CALLKIT_INCOMING_CUSTOM_WIDGET_DATA
        )
        payload["custom"] = if (customData is HashMap<*, *>) {
            customData
        } else {
            HashMap<String, Any?>()
        }

        val encodedPayload = Uri.encode(JSONObject(payload as Map<*, *>).toString())
        return if (route.contains("?")) {
            "$route&callkitData=$encodedPayload"
        } else {
            "$route?callkitData=$encodedPayload"
        }
    }

    fun prewarm(context: Context, data: Bundle?): String? {
        val routeWithPayload = routeWithPayload(data) ?: return null
        val engineId = engineId(data)
        val cache = FlutterEngineCache.getInstance()
        if (cache.get(engineId) != null) {
            return engineId
        }

        return try {
            val appContext = context.applicationContext
            val flutterLoader = FlutterInjector.instance().flutterLoader()
            flutterLoader.startInitialization(appContext)
            flutterLoader.ensureInitializationComplete(appContext, null)

            val engine = FlutterEngine(appContext)
            engine.navigationChannel.setInitialRoute(routeWithPayload)
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            engine.lifecycleChannel.appIsResumed()
            cache.put(engineId, engine)
            engineId
        } catch (error: Exception) {
            Log.e(TAG, "Unable to prewarm custom Flutter header engine", error)
            null
        }
    }

    fun refreshRoute(engineId: String, data: Bundle?) {
        val routeWithPayload = routeWithPayload(data) ?: return
        FlutterEngineCache.getInstance().get(engineId)?.let { engine ->
            engine.lifecycleChannel.appIsResumed()
            engine.navigationChannel.pushRoute(routeWithPayload)
        }
    }

    fun destroy(data: Bundle?) {
        destroy(engineId(data))
    }

    fun destroy(engineId: String?) {
        if (engineId.isNullOrEmpty()) {
            return
        }
        val cache = FlutterEngineCache.getInstance()
        val engine = cache.get(engineId)
        cache.remove(engineId)
        engine?.destroy()
    }
}
