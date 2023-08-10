package com.appcues.flutter

import android.content.Context
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
        val platformView = AppcuesPlatformView(context)

        platformView.wrapperView.eventChannel =
            EventChannel(messenger, "com.appcues.flutter/frame/$viewId")

        val creationParams = args as Map<String?, Any?>?
        creationParams?.let {
            val frameId = it["frameId"] as? String
            if (frameId != null) {
                plugin.registerEmbed(frameId, platformView.wrapperView.contentView)
            }
            platformView.wrapperView.frameId = frameId
        }

        return platformView
    }
}

internal class AppcuesPlatformView(context: Context) : PlatformView {
    val wrapperView = AppcuesWrapperView(context)

    override fun getView(): View {
        return wrapperView
    }

    override fun dispose() {}
}

internal class AppcuesWrapperView(context: Context) : FrameLayout(context) {
    val contentView = AppcuesFrameView(context)

    init {
        addView(contentView)
    }

    var eventChannel: EventChannel? = null
        set(eventChannel) {
            field = eventChannel
            eventChannel?.setStreamHandler(object: EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventSink?) {
                    eventSink = events
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
        measure(
            MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)
        )
        layout(left, top, right, bottom)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        var maxWidth = 0
        var maxHeight = 0
        children.forEach {
            if (it.visibility != GONE) {
                it.measure(widthMeasureSpec, MeasureSpec.UNSPECIFIED)
                maxWidth = maxWidth.coerceAtLeast(it.measuredWidth)
                maxHeight = maxHeight.coerceAtLeast(it.measuredHeight)
            }
        }
        val finalWidth = maxWidth.coerceAtLeast(suggestedMinimumWidth)
        val finalHeight = maxHeight.coerceAtLeast(suggestedMinimumHeight)
        setMeasuredDimension(finalWidth, finalHeight)

        val density = resources.displayMetrics.density
        eventSink?.success(finalHeight.toDouble() / density)
    }
}
