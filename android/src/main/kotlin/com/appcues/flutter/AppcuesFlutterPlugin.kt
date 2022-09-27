package com.appcues.flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import com.appcues.AnalyticType
import com.appcues.AnalyticsListener
import com.appcues.Appcues
import com.appcues.LoggingLevel

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/** AppcuesFlutterPlugin */
class AppcuesFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var methodChannel: MethodChannel
    private lateinit var analyticsChannel: EventChannel
    private lateinit var context: Context
    private var activity: Activity? = null

    // this implies the consumer must call "initialize" first, or they will get an error below
    private lateinit var implementation: Appcues

    private val mainScope = CoroutineScope(Dispatchers.Main)

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "appcues_flutter")
        methodChannel.setMethodCallHandler(this)
        analyticsChannel = EventChannel(flutterPluginBinding.binaryMessenger, "appcues_analytics")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        this.activity = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> {
                val accountId = call.argument<String>("accountId")
                val applicationId = call.argument<String>("applicationId")
                if (accountId != null && applicationId != null) {
                    implementation = Appcues(context, accountId, applicationId) {
                        call.argument<HashMap<String, Any?>>("options")?.let {
                            val logging = it["logging"] as? Boolean
                            if (logging != null) {
                                this.loggingLevel = if (logging) LoggingLevel.INFO else LoggingLevel.NONE
                            }

                            val apiHost = it["apiHost"] as? String
                            if (apiHost != null) {
                                this.apiBasePath = apiHost
                            }

                            val sessionTimeout = it["sessionTimeout"] as? Double
                            if (sessionTimeout != null) {
                                this.sessionTimeout = sessionTimeout.toInt()
                            }

                            val activityStorageMaxSize = it["activityStorageMaxSize"] as? Double
                            if (activityStorageMaxSize != null) {
                                this.activityStorageMaxSize = activityStorageMaxSize.toInt()
                            }

                            val activityStorageMaxAge = it["activityStorageMaxAge"] as? Double
                            if (activityStorageMaxAge != null) {
                                this.activityStorageMaxAge = activityStorageMaxAge.toInt()
                            }
                        }
                    }
                    analyticsChannel.setStreamHandler(object: EventChannel.StreamHandler {
                        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                            implementation.analyticsListener = object: AnalyticsListener {
                                override fun trackedAnalytic(
                                    type: AnalyticType,
                                    value: String?,
                                    properties: Map<String, Any>?,
                                    isInternal: Boolean
                                ) {
                                    events?.success(
                                        hashMapOf(
                                            "analytic" to type.name,
                                            "value" to (value ?: ""),
                                            "properties" to (properties ?: mapOf()),
                                            "isInternal" to isInternal,
                                        )
                                    )
                                }
                            }
                        }

                        override fun onCancel(arguments: Any?) {
                            implementation.analyticsListener = null
                        }

                    })
                    result.success(null)
                } else {
                    result.badArgs("accountId, applicationId")
                }
            }
            "identify" -> {
                val userId = call.argument<String>("userId")
                if (userId != null) {
                    val properties = call.argument<HashMap<String, Any>>("properties");
                    implementation.identify(userId, properties)
                    result.success(null)
                } else {
                    result.badArgs("userId")
                }
            }
            "group" -> {
                val groupId = call.argument<String>("groupId")
                if (groupId != null) {
                    val properties = call.argument<HashMap<String, Any>>("properties");
                    implementation.group(groupId, properties)
                    result.success(null)
                } else {
                    result.badArgs("groupId")
                }
            }
            "track" -> {
                val eventName = call.argument<String>("name")
                if (eventName != null) {
                    val properties = call.argument<HashMap<String, Any>>("properties");
                    implementation.track(eventName, properties)
                    result.success(null)
                } else {
                    result.badArgs("name")
                }
            }
            "screen" -> {
                val title = call.argument<String>("title")
                if (title != null) {
                    val properties = call.argument<HashMap<String, Any>>("properties");
                    implementation.screen(title, properties)
                    result.success(null)
                } else {
                    result.badArgs("title")
                }
            }
            "anonymous" -> {
                val properties = call.argument<HashMap<String, Any>>("properties");
                implementation.anonymous(properties)
                result.success(null)
            }
            "reset" -> {
                implementation.reset()
                result.success(null)
            }
            "version" -> {
                result.success(implementation.version)
            }
            "debug" -> {
                activity?.let {
                    implementation.debug(it)
                }
                result.success(null)
            }
            "show" -> {
                val experienceId = call.argument<String>("experienceId")
                if (experienceId != null) {
                    mainScope.launch {
                        val success = implementation.show(experienceId)
                        if (success) {
                            result.success(null)
                        } else {
                            result.error("show-experience-failure", "unable to show experience $experienceId", null)
                        }
                    }
                } else {
                    result.badArgs("experienceId")
                }
            }
            "didHandleURL" -> {
                val url = call.argument<String>("url")
                if (url != null) {
                    val activity = this.activity
                    if (activity != null) {
                        val uri = Uri.parse(url)
                        val intent = Intent(Intent.ACTION_VIEW)
                        intent.data = uri
                        result.success(implementation.onNewIntent(activity, intent))
                    } else {
                        result.error("no-activity", "unable to handle the URL, no current running Activity found", null)
                    }
                } else {
                    result.badArgs("url")
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
    }

    private fun Result.badArgs(names: String) {
        error("bad-args", "missing one or more required args", names)
    }
}
