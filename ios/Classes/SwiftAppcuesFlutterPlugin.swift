import Flutter
import UIKit
import AppcuesKit

public class SwiftAppcuesFlutterPlugin: NSObject, FlutterPlugin {

    private var implementation: Appcues?
    private var analyticsChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "appcues_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftAppcuesFlutterPlugin()
        instance.analyticsChannel = FlutterEventChannel(name: "appcues_analytics", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        // init is a special case, which creates the Appcues instance, must be done first
        if call.method == "initialize" {
            if let accountID = call["accountId"], let applicationID = call["applicationId"] {
                let config = Appcues.Config(accountID: accountID, applicationID: applicationID)

                if let arguments = call.arguments as? [String: Any],
                   let options = arguments["options"] as? [String: Any?] {

                    if let logging = options["logging"] as? Bool {
                        config.logging(logging)
                    }

                    if let apiHost = options["apiHost"] as? String, let url = URL(string: apiHost) {
                        config.apiHost(url)
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
                }
                implementation = Appcues(config: config)
                analyticsChannel?.setStreamHandler(self)
                result(nil)
            } else {
                result(missingArgs(names: "accountId, applicationId"))
            }
            return
        }

        guard let implementation = implementation else {
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
            implementation.anonymous(properties: call.properties)
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func missingArgs(names: String) -> FlutterError {
        return FlutterError(code: "bad-args", message: "missing one or more required args", details: names)
    }
}

extension SwiftAppcuesFlutterPlugin: AppcuesAnalyticsDelegate {
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
            "properties": formatProperties(properties),
            "isInternal": isInternal
        ])
    }

    /// Map any supported property types that `sendEvent` doesn't handle by default.
    private func formatProperties( _ properties: [String: Any]?) -> [String: Any] {
        guard var properties = properties else { return [:] }

        properties.forEach { key, value in
            switch value {
            case let date as Date:
                properties[key] = Int64((date.timeIntervalSince1970 * 1000).rounded())
            case let dict as [String: Any]:
                properties[key] = formatProperties(dict)
            case let arr as [Any]:
                properties[key] = formatProperties(arr)
            default:
                break
            }
        }

        return properties
    }

    private func formatProperties( _ properties: [Any]?) -> [Any] {
        guard var properties = properties else { return [] }

        properties.enumerated().forEach { index, value in
            switch value {
            case let date as Date:
                properties[index] = Int64((date.timeIntervalSince1970 * 1000).rounded())
            case let dict as [String: Any]:
                properties[index] = formatProperties(dict)
            case let arr as [Any]:
                properties[index] = formatProperties(arr)
            default:
                break
            }
        }

        return properties
    }
}

extension SwiftAppcuesFlutterPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        implementation?.analyticsDelegate = self
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        implementation?.analyticsDelegate = nil
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
