package com.appcues.flutter

import android.content.Context
import android.content.res.Configuration
import android.view.View
import android.widget.FrameLayout
import androidx.core.view.children
import com.appcues.AppcuesFrameView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class AppcuesFrameViewFactory(
    private val plugin: AppcuesFlutterPlugin,
    private val messenger: BinaryMessenger,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        plugin.applyThemeToResources(context.resources)
        val platformView = AppcuesPlatformView(context, plugin)

        platformView.wrapperView.eventChannel =
            EventChannel(messenger, "com.appcues.flutter/frame/$viewId")

        val creationParams = args as Map<String?, Any?>?
        creationParams?.let {
            val frameId = it["frameId"] as? String
            platformView.wrapperView.frameId = frameId
            if (frameId != null) {
                plugin.registerEmbed(frameId, platformView.wrapperView.contentView)
            }
        }

        return platformView
    }
}

internal class AppcuesPlatformView(
    context: Context,
    private val plugin: AppcuesFlutterPlugin,
) : PlatformView {
    val wrapperView = AppcuesWrapperView(context, plugin)

    override fun getView(): View {
        return wrapperView
    }

    override fun dispose() {
        plugin.unregisterWrapperView(wrapperView)
        wrapperView.cancelMeasureAndLayout()
    }
}

internal class AppcuesWrapperView(
    context: Context,
    private val plugin: AppcuesFlutterPlugin,
) : FrameLayout(context) {
    val contentView = AppcuesFrameView(context)
    internal var appliedNightMode: Int = plugin.resolveNightMode()
    private var isReRegistering = false
    private var lastWidth = 0
    private var lastHeight = 0
    private var hasMeasured = false

    private val clearReRegistering = Runnable {
        if (isReRegistering) {
            isReRegistering = false
            requestLayout()
        }
    }

    init {
        addView(contentView)
        plugin.registerWrapperView(this)
    }

    internal fun reRegisterEmbed() {
        val id = frameId ?: return
        if (lastHeight > 0) {
            isReRegistering = true
            removeCallbacks(clearReRegistering)
            postDelayed(clearReRegistering, 500)
        }
        plugin.registerEmbed(id, contentView)
    }

    override fun dispatchConfigurationChanged(newConfig: Configuration) {
        // Do not forward configuration changes to AppcuesFrameView's internal ComposeView,
        // as recomposing AppcuesComposition on LocalConfiguration changes resets its
        // un-remembered ExperienceCompositionState.isContentVisible to false and hides the embed.
        // Theme updates are handled via AppcuesFlutterPlugin.applyThemeToWrapperView.
    }

    var eventChannel: EventChannel? = null
        set(eventChannel) {
            field = eventChannel
            eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventSink?) {
                    eventSink = events
                    if (hasMeasured) {
                        sendSizeEvent(lastWidth, lastHeight)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
        }

    var frameId: String? = null

    private var eventSink: EventSink? = null

    override fun requestLayout() {
        super.requestLayout()
        post(measureAndLayout)
    }

    private val measureAndLayout = Runnable {
        // ComposeView throws if measured while detached. requestLayout posts this
        // runnable, and the platform view can leave the window before it runs.
        if (!isAttachedToWindow) return@Runnable

        val targetWidth = when {
            width > 0 -> width
            lastWidth > 0 -> lastWidth
            else -> resources.displayMetrics.widthPixels
        }
        measure(
            MeasureSpec.makeMeasureSpec(targetWidth, MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)
        )
        layout(left, top, right, bottom)
        // ensure that when we measure/layout we schedule a invalidate for the next loop for a re-draw
        postInvalidate()
    }

    internal fun cancelMeasureAndLayout() {
        removeCallbacks(measureAndLayout)
        removeCallbacks(clearReRegistering)
    }

    override fun onDetachedFromWindow() {
        cancelMeasureAndLayout()
        super.onDetachedFromWindow()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val specWidth = MeasureSpec.getSize(widthMeasureSpec)
        val effectiveWidthSpec = if (specWidth > 0) {
            widthMeasureSpec
        } else {
            val fallbackWidth = if (lastWidth > 0) lastWidth else resources.displayMetrics.widthPixels
            MeasureSpec.makeMeasureSpec(fallbackWidth, MeasureSpec.AT_MOST)
        }

        var maxWidth = 0
        var maxHeight = 0
        children.forEach {
            if (it.visibility != GONE) {
                it.measure(effectiveWidthSpec, MeasureSpec.UNSPECIFIED)
                maxWidth = maxWidth.coerceAtLeast(it.measuredWidth)
                maxHeight = maxHeight.coerceAtLeast(it.measuredHeight)
            }
        }

        if (maxHeight > 0) {
            isReRegistering = false
            removeCallbacks(clearReRegistering)
        } else if (isReRegistering && lastHeight > 0) {
            maxWidth = lastWidth
            maxHeight = lastHeight
        }

        val finalWidth = maxWidth.coerceAtLeast(specWidth).coerceAtLeast(suggestedMinimumWidth)
        val finalHeight = maxHeight.coerceAtLeast(suggestedMinimumHeight)
        lastWidth = finalWidth
        lastHeight = finalHeight
        hasMeasured = true
        setMeasuredDimension(finalWidth, finalHeight)

        sendSizeEvent(finalWidth, finalHeight)
    }

    private fun sendSizeEvent(widthPx: Int, heightPx: Int) {
        val density = resources.displayMetrics.density
        val reportedHeight = if (heightPx <= 0) 0.01 else heightPx.toDouble() / density
        val reportedWidth = widthPx.toDouble() / density
        eventSink?.success(
            mapOf(
                "height" to reportedHeight,
                "width" to reportedWidth,
            )
        )
    }
}
