import Flutter
import UIKit
import AppcuesKit

@available(*, unavailable, renamed: "AppcuesFlutterPlugin")
public typealias SwiftAppcuesFlutterPlugin = AppcuesFlutterPlugin

public class AppcuesFlutterPlugin: NSObject, FlutterPlugin {

    private static var implementation: Appcues?
    private static var currentTheme: String = "system"
    private static let wrapperViews = NSHashTable<WrapperView>.weakObjects()
    private static var windowObserver: NSObjectProtocol?
    private var analyticsChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "appcues_flutter", binaryMessenger: registrar.messenger())
        let instance = AppcuesFlutterPlugin()
        instance.analyticsChannel = FlutterEventChannel(name: "appcues_analytics", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        if #available(iOS 13.0, *) {
            Appcues.elementTargeting = FlutterElementTargeting()
        }

        if windowObserver == nil {
            windowObserver = NotificationCenter.default.addObserver(
                forName: UIWindow.didBecomeVisibleNotification,
                object: nil,
                queue: .main
            ) { notification in
                if #available(iOS 13.0, *), let window = notification.object as? UIWindow {
                    window.overrideUserInterfaceStyle = Self.userInterfaceStyle
                }
            }
        }

        let factory = AppcuesFrameViewFactory(plugin: instance, messenger: registrar.messenger())
        registrar.register(factory, withId: "AppcuesFrameView")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        // init is a special case, which creates the Appcues instance, must be done first
        if call.method == "initialize" {
            if let accountID = call["accountId"], let applicationID = call["applicationId"] {
                let config = Appcues.Config(accountID: accountID, applicationID: applicationID)
                var enableUniversalLinks = false

                if let arguments = call.arguments as? [String: Any] {

                    if let options = arguments["options"] as? [String: Any?] {
                        if let logging = options["logging"] as? Bool {
                            config.logging(logging)
                        }

                        if let apiHost = options["apiHost"] as? String, let url = URL(string: apiHost) {
                            config.apiHost(url)
                        }

                        if let settingsHost = options["settingsHost"] as? String, let url = URL(string: settingsHost) {
                            config.settingsHost(url)
                        }

                        if let sessionTimeout = options["sessionTimeout"] as? UInt {
                            config.sessionTimeout(sessionTimeout)
                        }

                        if let activityStorageMaxSize = options["activityStorageMaxSize"] as? UInt {
                            config.activityStorageMaxSize(activityStorageMaxSize)
                        }

                        if let activityStorageMaxAge = options["activityStorageMaxAge"] as? UInt {
                            config.activityStorageMaxAge(activityStorageMaxAge)
                        }

                        if let theme = options["theme"] as? String {
                            Self.currentTheme = theme
                        }

                        enableUniversalLinks = options["enableUniversalLinks"] as? Bool ?? false
                    }

                    if let additionalAutoProperties = arguments["additionalAutoProperties"] as? [String: Any?] {
                        config.additionalAutoProperties(additionalAutoProperties.compactMapValues { $0 })
                    }
                }

                config.enableUniversalLinks(enableUniversalLinks)

                Self.implementation = Appcues(config: config)
                Self.applyTheme()
                handleStoredNativePush()
                analyticsChannel?.setStreamHandler(self)
                result(nil)
            } else {
                result(missingArgs(names: "accountId, applicationId"))
            }
            return
        }

        if call.method == "setTheme" {
            if let theme = call["theme"] {
                Self.setTheme(theme)
                result(nil)
            } else {
                result(missingArgs(names: "theme"))
            }
            return
        }

        guard let implementation = Self.implementation else {
            result(FlutterError(code: "notInitialized",
                                message: "the initialize function must be called before any other Appcues SDK calls",
                                details: nil))
            return
        }

        switch call.method {
        case "identify":
            if let userId = call["userId"] {
                implementation.identify(userID: userId, properties: call.properties)
                result(nil)
            } else {
                result(missingArgs(names: "userId"))
            }
        case "group":
            implementation.group(groupID: call["groupId"], properties: call.properties)
            result(nil)
        case "track":
            if let name = call["name"] {
                implementation.track(name: name, properties: call.properties)
                result(nil)
            } else {
                result(missingArgs(names: "name"))
            }
        case "screen":
            if let title = call["title"] {
                implementation.screen(title: title, properties: call.properties)
                result(nil)
            } else {
                result(missingArgs(names: "title"))
            }
        case "anonymous":
            implementation.anonymous()
            result(nil)
        case "reset":
            implementation.reset()
            result(nil)
        case "version":
            result(implementation.version())
        case "debug":
            implementation.debug()
            result(nil)
        case "show":
            if let experienceID = call["experienceId"] {
                implementation.show(experienceID: experienceID) { success, error in
                    if success {
                        result(nil)
                    } else {
                        result(FlutterError(
                            code: "show-experience-failure",
                            message: "unable to show experience \(experienceID)",
                            details: error?.localizedDescription))
                    }
                }
            } else {
                result(missingArgs(names: "experienceId"))
            }
        case "didHandleURL":
            if let urlString = call["url"], let url = URL(string: urlString) {
                result(implementation.didHandleURL(url))
            } else {
                result(missingArgs(names: "url"))
            }

        case "setTargetElements":
            guard #available(iOS 13.0, *),
                  let flutterElementTargeting = Appcues.elementTargeting as? FlutterElementTargeting,
                  let viewElements = call.parameters?["viewElements"] as? Array<Dictionary<String, Any>> else {
                return
            }
            flutterElementTargeting.setTargetElements(viewElements: viewElements)
        default:
            result(FlutterMethodNotImplemented)
        }
    }


    internal func register(frameID: String, for view: AppcuesFrameView, on parentViewController: UIViewController) {
        Self.implementation?.register(frameID: frameID, for: view, on: parentViewController)
    }

    @available(iOS 13.0, *)
    internal static var userInterfaceStyle: UIUserInterfaceStyle {
        switch currentTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return .unspecified
        }
    }

    internal static func registerWrapperView(_ view: WrapperView) {
        wrapperViews.add(view)
        if #available(iOS 13.0, *) {
            view.applyTheme(userInterfaceStyle)
        }
    }

    private static func setTheme(_ theme: String) {
        currentTheme = theme
        applyTheme()
    }

    private static func applyTheme() {
        guard #available(iOS 13.0, *) else { return }
        let style = userInterfaceStyle
        let updateBlock = {
            let sceneWindows = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
            let windows = sceneWindows.isEmpty ? UIApplication.shared.windows : sceneWindows
            for window in windows {
                window.overrideUserInterfaceStyle = style
                window.rootViewController?.presentedViewController?.overrideUserInterfaceStyle = style
            }
            for wrapperView in wrapperViews.allObjects {
                wrapperView.applyTheme(style)
            }
        }
        if Thread.isMainThread {
            updateBlock()
        } else {
            DispatchQueue.main.async(execute: updateBlock)
        }
    }

    private func missingArgs(names: String) -> FlutterError {
        return FlutterError(code: "bad-args", message: "missing one or more required args", details: names)
    }
}

extension AppcuesFlutterPlugin {
    private static var pushToken: Data?
    private static var notificationResponse: UNNotificationResponse?

    @objc
    public static func setPushToken(_ deviceToken: Data?) {
        guard let impl = Self.implementation else {
            Self.pushToken = deviceToken
            return
        }

        impl.setPushToken(deviceToken)
    }

    @objc
    public static func didReceiveNotification(response: UNNotificationResponse, completionHandler: @escaping () -> Void) -> Bool {
        guard let impl = Self.implementation else {
            Self.notificationResponse = response
            return false
        }

        return impl.didReceiveNotification(response: response, completionHandler: completionHandler)
    }

    // To be called at setup
    private func handleStoredNativePush() {
        if let pushToken = Self.pushToken {
            Self.implementation?.setPushToken(pushToken)
        }
        if let notification = Self.notificationResponse {
            _ = Self.implementation?.didReceiveNotification(response: notification, completionHandler: {})
        }
    }
}

extension AppcuesFlutterPlugin: AppcuesAnalyticsDelegate {
    public func didTrack(analytic: AppcuesKit.AppcuesAnalytic, value: String?, properties: [String : Any]?, isInternal: Bool) {
        let analyticName: String
        switch analytic {
        case .event:
            analyticName = "EVENT"
        case .screen:
            analyticName = "SCREEN"
        case .identify:
            analyticName = "IDENTIFY"
        case .group:
            analyticName = "GROUP"
        }

        eventSink?([
            "analytic": analyticName,
            "value": value ?? "",
            "properties": properties ?? [:],
            "isInternal": isInternal
        ])
    }
}

extension AppcuesFlutterPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        Self.implementation?.analyticsDelegate = self
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        Self.implementation?.analyticsDelegate = nil
        return nil
    }
}

private extension FlutterMethodCall {
    var parameters: Dictionary<String, Any>? {
        arguments as? Dictionary<String, Any>
    }

    var properties: Dictionary<String, Any>? {
        parameters?["properties"] as? Dictionary<String, Any>
    }

    func getParam(_ name: String) -> String? {
        guard let parameters = parameters else { return nil }
        return parameters[name] as? String
    }

    subscript(index: String) -> String? {
        get {
            getParam(index)
        }
    }
}
