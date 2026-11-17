package com.appcues.flutter

import android.app.Activity
import android.app.UiModeManager
import android.content.ComponentCallbacks
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.content.res.Resources
import android.net.Uri
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import androidx.annotation.NonNull
import com.appcues.AnalyticType
import com.appcues.AnalyticsListener
import com.appcues.Appcues
import com.appcues.AppcuesFrameView
import com.appcues.LoggingLevel

import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.renderer.FlutterRenderer
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.Collections
import java.util.WeakHashMap
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/** AppcuesFlutterPlugin */
class AppcuesFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var methodChannel: MethodChannel
    private lateinit var analyticsChannel: EventChannel
    private lateinit var context: Context

    private lateinit var _renderer: FlutterRenderer
    internal val renderer: FlutterRenderer
        get() = _renderer

    private var _activity: Activity? = null
    internal val activity: Activity?
        get() = _activity

    // this implies the consumer must call "initialize" first, or they will get an error below
    private lateinit var implementation: Appcues

    private val elementTargeting = FlutterElementTargetingStrategy(this)

    private val mainScope = CoroutineScope(Dispatchers.Main)

    private var currentTheme: String = "system"
    private val wrapperViews = Collections.newSetFromMap(WeakHashMap<AppcuesWrapperView, Boolean>())
    private val styledOverlayViews = Collections.newSetFromMap(WeakHashMap<View, Boolean>())
    private var decorLayoutListener: ViewTreeObserver.OnGlobalLayoutListener? = null
    private var observedDecorView: View? = null

    private val componentCallbacks = object : ComponentCallbacks {
        override fun onConfigurationChanged(newConfig: Configuration) {
            if (currentTheme != "system") {
                mainScope.launch {
                    applyTheme()
                }
            }
        }

        override fun onLowMemory() {}
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        context.registerComponentCallbacks(componentCallbacks)
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "appcues_flutter")
        methodChannel.setMethodCallHandler(this)
        analyticsChannel = EventChannel(flutterPluginBinding.binaryMessenger, "appcues_analytics")
        _renderer = flutterPluginBinding.flutterEngine.renderer

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "AppcuesFrameView",
            AppcuesFrameViewFactory(this, flutterPluginBinding.binaryMessenger)
        )
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this._activity = binding.activity
        attachDecorViewObserver(binding.activity)
        applyTheme()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachDecorViewObserver()
        this._activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this._activity = binding.activity
        attachDecorViewObserver(binding.activity)
        applyTheme()
    }

    override fun onDetachedFromActivity() {
        detachDecorViewObserver()
        this._activity = null
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

                            val settingsHost = it["settingsHost"] as? String
                            if (settingsHost != null) {
                                this.apiSettingsPath = settingsHost
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

                            val theme = it["theme"] as? String
                            if (theme != null) {
                                currentTheme = theme
                            }
                        }
                        call.argument<HashMap<String, Any>>("additionalAutoProperties")?.let {
                            this.additionalAutoProperties = it
                        }
                    }
                    applyTheme()
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
                    Appcues.elementTargeting = elementTargeting
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
                implementation.anonymous()
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
            "setTargetElements" -> {
                var viewElements = call.argument<List<HashMap<String, Any>>>("viewElements");
                if (viewElements != null) {
                    elementTargeting.setTargetElements(viewElements)
                }
            }
            "setTheme" -> {
                val theme = call.argument<String>("theme")
                if (theme != null) {
                    currentTheme = theme
                    applyTheme()
                    result.success(null)
                } else {
                    result.badArgs("theme")
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context.unregisterComponentCallbacks(componentCallbacks)
        detachDecorViewObserver()
        methodChannel.setMethodCallHandler(null)
    }

    internal fun registerEmbed(frameId: String, frame: AppcuesFrameView) {
        implementation.registerEmbed(frameId, frame)
    }

    internal fun registerWrapperView(view: AppcuesWrapperView) {
        wrapperViews.add(view)
        applyThemeToWrapperView(view)
    }

    internal fun unregisterWrapperView(view: AppcuesWrapperView) {
        wrapperViews.remove(view)
    }

    internal fun applyThemeToWrapperView(view: AppcuesWrapperView) {
        val config = applyThemeToResources(view.context.resources)
        applyThemeToResources(view.contentView.context.resources)
        view.dispatchConfigurationChanged(config)
    }

    internal fun adjustConfiguration(baseConfig: Configuration): Configuration {
        val nightMode = resolveNightMode()
        val config = Configuration(baseConfig)
        config.uiMode = (config.uiMode and Configuration.UI_MODE_NIGHT_MASK.inv()) or nightMode
        return config
    }

    @Suppress("DEPRECATION")
    internal fun applyThemeToResources(resources: Resources): Configuration {
        val config = adjustConfiguration(resources.configuration)
        resources.updateConfiguration(config, resources.displayMetrics)
        return config
    }

    private fun resolveNightMode(): Int {
        return when (currentTheme) {
            "light" -> Configuration.UI_MODE_NIGHT_NO
            "dark" -> Configuration.UI_MODE_NIGHT_YES
            else -> {
                val uiModeManager = context.getSystemService(Context.UI_MODE_SERVICE) as? UiModeManager
                when (uiModeManager?.nightMode) {
                    UiModeManager.MODE_NIGHT_YES -> Configuration.UI_MODE_NIGHT_YES
                    UiModeManager.MODE_NIGHT_NO -> Configuration.UI_MODE_NIGHT_NO
                    else -> context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
                }
            }
        }
    }

    internal fun applyTheme() {
        styledOverlayViews.clear()
        activity?.let { act ->
            val config = applyThemeToResources(act.resources)
            dispatchConfigToNonFlutterViews(act.getParentView(), config)
        }
        wrapperViews.forEach { wrapperView ->
            applyThemeToWrapperView(wrapperView)
        }
    }

    private fun attachDecorViewObserver(act: Activity) {
        detachDecorViewObserver()
        val decorView = act.window?.decorView ?: return
        val listener = ViewTreeObserver.OnGlobalLayoutListener {
            val currentActivity = _activity ?: return@OnGlobalLayoutListener
            val parentView = currentActivity.getParentView()
            for (i in 0 until parentView.childCount) {
                val child = parentView.getChildAt(i)
                if (!containsFlutterView(child) && !styledOverlayViews.contains(child)) {
                    styledOverlayViews.add(child)
                    val config = applyThemeToResources(currentActivity.resources)
                    applyThemeToResources(child.context.resources)
                    child.dispatchConfigurationChanged(config)
                }
            }
        }
        decorView.viewTreeObserver.addOnGlobalLayoutListener(listener)
        decorLayoutListener = listener
        observedDecorView = decorView
    }

    private fun detachDecorViewObserver() {
        val view = observedDecorView
        val listener = decorLayoutListener
        if (view != null && listener != null && view.viewTreeObserver.isAlive) {
            view.viewTreeObserver.removeOnGlobalLayoutListener(listener)
        }
        decorLayoutListener = null
        observedDecorView = null
        styledOverlayViews.clear()
    }

    private fun containsFlutterView(view: View): Boolean {
        if (view is FlutterView) return true
        if (view is ViewGroup) {
            for (i in 0 until view.childCount) {
                if (containsFlutterView(view.getChildAt(i))) return true
            }
        }
        return false
    }

    private fun dispatchConfigToNonFlutterViews(view: View, config: Configuration) {
        if (view is FlutterView) return
        if (view is ViewGroup) {
            if (containsFlutterView(view)) {
                for (i in 0 until view.childCount) {
                    dispatchConfigToNonFlutterViews(view.getChildAt(i), config)
                }
            } else {
                styledOverlayViews.add(view)
                applyThemeToResources(view.context.resources)
                view.dispatchConfigurationChanged(config)
            }
        } else {
            applyThemeToResources(view.context.resources)
            view.dispatchConfigurationChanged(config)
        }
    }

    private fun Result.badArgs(names: String) {
        error("bad-args", "missing one or more required args", names)
    }
}
