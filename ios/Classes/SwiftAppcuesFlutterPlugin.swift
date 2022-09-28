import Flutter
import UIKit
import AppcuesKit

public class SwiftAppcuesFlutterPlugin: NSObject, FlutterPlugin {

    private var implementation: Appcues?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "appcues_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftAppcuesFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
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
            if let experienceId = call["experienceId"] {
                implementation.show(experienceID: experienceId) { success, _ in
                    result(success)
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
        return FlutterError(code: "badArgs", message: "missing one or more required args", details: names)
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
