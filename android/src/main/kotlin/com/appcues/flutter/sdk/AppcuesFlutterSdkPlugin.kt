package com.appcues.flutter.sdk

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import com.appcues.Appcues

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

/** AppcuesFlutterSdkPlugin */
class AppcuesFlutterSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null

    // this implies the consumer must call "initialize" first, or they will get an error below
    private lateinit var appcues: Appcues

    private val mainScope = CoroutineScope(Dispatchers.Main)

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "appcues_flutter_sdk")
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
                    appcues = Appcues(context, accountId, applicationId)
                    result.success(null)
                } else {
                    result.badArgs("accountId, applicationId")
                }
            }
            "identify" -> {
                val userId = call.argument<String>("userId")
                if (userId != null) {
                    val properties = call.argument<HashMap<String, Any>>("properties");
                    appcues.identify(userId, properties)
                    result.success(null)
                } else {
                    result.badArgs("userId")
                }
            }
            "group" -> {
                val groupId = call.argument<String>("groupId")
                if (groupId != null) {
                    val properties = call.argument<HashMap<String, Any>>("properties");
                    appcues.group(groupId, properties)
                    result.success(null)
                } else {
                    result.badArgs("groupId")
                }
            }
            "track" -> {
                val eventName = call.argument<String>("name")
                if (eventName != null) {
                    val properties = call.argument<HashMap<String, Any>>("properties");
                    appcues.track(eventName, properties)
                    result.success(null)
                } else {
                    result.badArgs("name")
                }
            }
            "screen" -> {
                val title = call.argument<String>("title")
                if (title != null) {
                    val properties = call.argument<HashMap<String, Any>>("properties");
                    appcues.screen(title, properties)
                    result.success(null)
                } else {
                    result.badArgs("title")
                }
            }
            "anonymous" -> {
                val properties = call.argument<HashMap<String, Any>>("properties");
                appcues.anonymous(properties)
                result.success(null)
            }
            "reset" -> {
                appcues.reset()
                result.success(null)
            }
            "version" -> {
                result.success(appcues.version)
            }
            "debug" -> {
                activity?.let {
                    appcues.debug(it)
                }
                result.success(null)
            }
            "show" -> {
                val experienceId = call.argument<String>("experienceId")
                if (experienceId != null) {
                    mainScope.launch {
                        result.success(appcues.show(experienceId))
                    }

                } else {
                    result.badArgs("experienceId")
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
