package com.appcues.flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import com.appcues.Appcues
import com.appcues.LoggingLevel

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/** AppcuesFlutterPlugin */
class AppcuesFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null

    // this implies the consumer must call "initialize" first, or they will get an error below
    private lateinit var implementation: Appcues

    private val mainScope = CoroutineScope(Dispatchers.Main)

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "appcues_flutter")
        channel.setMethodCallHandler(this)
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
                val properties = call.argument<HashMap<String, Any>>("properties");
                implementation.group(groupId, properties)
                result.success(null)
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
                        result.success(implementation.show(experienceId))
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
        channel.setMethodCallHandler(null)
    }

    private fun Result.badArgs(names: String) {
        error("badArgs", "missing one or more required args", names)
    }
}
