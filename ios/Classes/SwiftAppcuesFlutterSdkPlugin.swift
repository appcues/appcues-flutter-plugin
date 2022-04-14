import Flutter
import UIKit
import AppcuesKit

public class SwiftAppcuesFlutterSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "appcues_flutter_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftAppcuesFlutterSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        // init is a special case, which creates the Appcues instance, must be done first
        if call.method == "initialize" {
            if let accountId = call["accountId"], let applicationId = call["applicationId"] {
                Appcues.shared = Appcues(config: Appcues.Config(accountID: accountId, applicationID: applicationId))
                result(nil)
            } else {
                result(missingArgs(names: "accountId, applicationId"))
            }
            return
        }

        guard let appcues = Appcues.shared else {
            result(FlutterError(code: "notInitialized",
                                message: "the initialize function must be called before any other Appcues SDK calls",
                                details: nil))
            return
        }

        switch call.method {
        case "identify":
            if let userId = call["userId"] {
                appcues.identify(userID: userId, properties: call.properties)
                result(nil)
            } else {
                result(missingArgs(names: "userId"))
            }
        case "group":
            if let groupId = call["groupId"] {
                appcues.group(groupID: groupId, properties: call.properties)
                result(nil)
            } else {
                result(missingArgs(names: "groupId"))
            }
        case "track":
            if let name = call["name"] {
                appcues.track(name: name, properties: call.properties)
                result(nil)
            } else {
                result(missingArgs(names: "name"))
            }
        case "screen":
            if let title = call["title"] {
                appcues.screen(title: title, properties: call.properties)
                result(nil)
            } else {
                result(missingArgs(names: "title"))
            }
        case "anonymous":
            appcues.anonymous(properties: call.properties)
            result(nil)
        case "reset":
            appcues.reset()
            result(nil)
        case "version":
            result(appcues.version())
        case "debug":
            appcues.debug()
            result(nil)
        case "show":
            if let experienceId = call["experienceId"] {
                appcues.show(experienceID: experienceId) { success, _ in
                    result(success)
                }
            } else {
                result(missingArgs(names: "experienceId"))
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

private extension Appcues {
    static var shared: Appcues?
}
