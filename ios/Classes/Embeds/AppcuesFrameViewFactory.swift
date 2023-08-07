import Flutter
import UIKit
import AppcuesKit

class AppcuesFrameViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    private let plugin: SwiftAppcuesFlutterPlugin

    init(plugin: SwiftAppcuesFlutterPlugin, messenger: FlutterBinaryMessenger) {
        self.plugin = plugin
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return AppcuesPlatformView(
            plugin: plugin,
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }

    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}

class AppcuesPlatformView: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(
        plugin: SwiftAppcuesFlutterPlugin,
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        let args = args as? [String: Any]

        _view = WrapperView(
            plugin: plugin,
            binaryMessenger: messenger,
            frameID: args?["frameId"] as? String,
            viewIdentifier: viewId
        )
        super.init()
    }

    func view() -> UIView {
        return _view
    }
}


class WrapperView: UIView, FlutterStreamHandler {


    private let plugin: SwiftAppcuesFlutterPlugin
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?

    var frameID: String? = nil

    private weak var frameViewController: AppcuesFrameVC?

    init(
        plugin: SwiftAppcuesFlutterPlugin,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        frameID: String?,
        viewIdentifier viewId: Int64
    ) {
        self.plugin = plugin
        self.frameID = frameID

        if let messenger = messenger {
            eventChannel = FlutterEventChannel(name: "com.appcues.flutter/frame/\(viewId)", binaryMessenger: messenger)
        }

        super.init(frame: .zero)

        eventChannel?.setStreamHandler(self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let frameViewController = frameViewController {
            frameViewController.view.frame = bounds
        } else {
            setupFrame()
        }
    }

    private func setupFrame() {
        guard let parentVC = parentViewController,
              let frameID = frameID else {
            return
        }

        let frameVC = AppcuesFrameVC(parentView: self)
        parentVC.addChild(frameVC)
        addSubview(frameVC.view)
        frameVC.view.frame = bounds
        frameVC.didMove(toParent: parentVC)
        self.frameViewController = frameVC

        plugin.register(frameID: frameID, for: frameVC.frameView, on: frameVC)
    }

    func setIntrinsicSize(preferredContentSize: CGSize, isHidden: Bool) {
        let size: CGSize

        if isHidden {
            // When the frame is hidden, size this WrapperView to 0.
            size = .zero
        } else {
            if preferredContentSize == .zero {
                // When the frame is NOT hidden and the current size is 0, set a non-zero height,
                // which allows the content to start its layout algorithm and determine the required size.
                size = CGSize(width: 0, height: 1)
            } else {
                // When the frame is NOT hidden use the size calculated by the content.
                size = preferredContentSize
            }
        }

        eventSink?(size.height)
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

class AppcuesFrameVC: UIViewController {
    lazy var frameView = AppcuesFrameView()

    weak var parentView: WrapperView?

    init(parentView: WrapperView) {
        self.parentView = parentView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = frameView
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        parentView?.setIntrinsicSize(preferredContentSize: preferredContentSize, isHidden: frameView.isHidden)
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        preferredContentSize = container.preferredContentSize

        parentView?.setIntrinsicSize(preferredContentSize: preferredContentSize, isHidden: frameView.isHidden)
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
