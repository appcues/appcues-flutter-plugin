package com.appcues.flutter

import android.app.Activity
import android.graphics.Rect
import android.os.Build
import android.util.Size
import android.view.View
import android.view.ViewGroup
import android.view.inspector.WindowInspector
import androidx.core.graphics.Insets
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.appcues.ElementSelector
import com.appcues.ElementTargetingStrategy
import com.appcues.Screenshot
import com.appcues.ViewElement
import io.flutter.plugin.common.MethodCall
import java.lang.reflect.Method

internal class FlutterElementSelector(var identifier: String?): ElementSelector {
    val isValid: Boolean
        get() = identifier != null

    override fun toMap(): Map<String, String> =
        mapOf(
            "identifier" to identifier,
        ).filterValues { it != null }.mapValues { it.value as String }

    override fun evaluateMatch(target: ElementSelector): Int {
        var weight = 0

        (target as? FlutterElementSelector)?.let {
            if (!it.identifier.isNullOrEmpty() && it.identifier == identifier) {
                weight += 1_000
            }
        }

        return weight
    }
}

internal fun Activity.getParentView(): ViewGroup {

    // try to find the most applicable topmost decorView to capture layout. Typically there is just a single
    // decorView on the Activity window. However, if something like a dialog modal has been shown, this can add another
    // window with another decorView on top of the Activity. If we want to support showing content above that layer, we need
    // to find the topmost decorView like below.

    val decorView = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        // this is the preferred method on API 29+ with the new WindowInspector function
        WindowInspector.getGlobalWindowViews().last()
    } else {
        @Suppress("SwallowedException", "TooGenericExceptionCaught")
        try {
            // this is the less desirable method for API 21-28, using reflection to try to get the root views
            val windowManagerClass = Class.forName("android.view.WindowManagerGlobal")
            val windowManager = windowManagerClass.getMethod("getInstance").invoke(null)
            val getViewRootNames: Method = windowManagerClass.getMethod("getViewRootNames")
            val getRootView: Method = windowManagerClass.getMethod("getRootView", String::class.java)
            val rootViewNames = getViewRootNames.invoke(windowManager) as Array<Any?>
            val rootViews = rootViewNames.map { getRootView(windowManager, it) as View }
            rootViews.last()
        } catch (_: Exception) {
            // if all else fails, use the decorView on the window, which is typically the only one
            window.decorView
        }
    }

    return decorView.rootView as ViewGroup
}

internal class FlutterElementTargetingStrategy(val plugin: AppcuesFlutterPlugin) : ElementTargetingStrategy {

    private var widgets: MutableMap<String, ViewElement> = mutableMapOf()

    override fun captureLayout(): ViewElement? {
        return plugin.activity?.getParentView()?.let {
            val actualPosition = Rect()
            it.getGlobalVisibleRect(actualPosition)

            val displayMetrics = it.context.resources.displayMetrics
            val density = displayMetrics.density

            return ViewElement(
                x = actualPosition.left.toDp(density),
                y = actualPosition.top.toDp(density),
                width = actualPosition.width().toDp(density),
                height = actualPosition.height().toDp(density),
                selector = null,
                displayName = null,
                type = this.javaClass.name,
                children = widgets.values.toList(),
            )
        }
    }

    override fun inflateSelectorFrom(properties: Map<String, String>): ElementSelector? {
        return FlutterElementSelector(
            identifier = properties["identifier"],
        ).let { if (it.isValid) it else null }
    }

    override fun captureScreenshot(): Screenshot? {
        return plugin.activity?.let { activity ->
            val view = activity.getParentView()
            val density = view.resources.displayMetrics.density

            // get the root level window insets, which will be used to apply a height correction
            // to the screenshot below
            val insets = ViewCompat.getRootWindowInsets(view)?.getInsets(WindowInsetsCompat.Type.systemBars())
                ?: Insets.NONE

            // This bitmap from the FlutterRenderer contains the top system bar but not the bottom
            val bitmap = plugin.renderer.bitmap

            // so bottom is subtracted from the screenshot height
            val width = view.width.toDp(density)
            val height = (view.height - insets.bottom).toDp(density)

            Screenshot(
                bitmap = bitmap,
                size = Size(width, height),
                // zero out the bottom insets for the screen capture builder usage
                insets = Insets.of(insets.left, insets.top, insets.right, 0)
            )
        }

    }

    fun targetElement(call: MethodCall) {
        val identifier = call.argument<String>("identifier")
        val x = call.argument<Double>("x")
        val y = call.argument<Double>("y")
        val width = call.argument<Double>("width")
        val height = call.argument<Double>("height")
        val type = call.argument<String>("type")

        if (identifier != null && x != null && y != null && width != null && height != null && type != null) {
            widgets[identifier] = ViewElement(
                x = x.toInt(),
                y = y.toInt(),
                width = width.toInt(),
                height = height.toInt(),
                type = type,
                selector = FlutterElementSelector(identifier),
                children = null,
                displayName = identifier
            )
        }
    }

    fun resetTargetElements() {
        widgets.clear()
    }
}

private fun Int.toDp(density: Float) =
    (this / density).toInt()
