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
        let args = args as? [String: Any]

        return AppcuesPlatformView(
            plugin: plugin,
            frameID: args?["frameId"] as? String,
            eventChannel: FlutterEventChannel(name: "com.appcues.flutter/frame/\(viewId)", binaryMessenger: messenger))
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
        frameID: String?,
        eventChannel: FlutterEventChannel
    ) {
        _view = WrapperView(
            plugin: plugin,
            frameID: frameID,
            eventChannel: eventChannel
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
        frameID: String?,
        eventChannel: FlutterEventChannel
    ) {
        self.plugin = plugin
        self.frameID = frameID
        self.eventChannel = eventChannel

        super.init(frame: .zero)

        eventChannel.setStreamHandler(self)
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
        // The height cannot be 0 otherwise the view might be removed
        let size = isHidden ? CGSize(width: 0, height: 0.01) : preferredContentSize

        eventSink?([
            "height": size.height,
            "width": size.width
        ])
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Only want to render the margins specified by the embed style
        viewRespectsSystemMinimumLayoutMargins = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        parentView?.setIntrinsicSize(preferredContentSize: preferredContentSize, isHidden: frameView.isHidden)
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        // Add frame margins to the calculated size. Need to do this because the margins must be set on the FrameView,
        // not the UIViewController it contains which manages the preferredContentSize
        let margins = frameView.directionalLayoutMargins

        preferredContentSize = CGSize(
            width: container.preferredContentSize.width + margins.leading + margins.trailing,
            height: container.preferredContentSize.height + margins.top + margins.bottom
        )

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
