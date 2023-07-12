import Flutter
import UIKit
import AppcuesKit

internal class FlutterElementSelector: AppcuesElementSelector {
    private enum CodingKeys: String, CodingKey {
        case appcuesID
    }

    let identifier: String

    init?(identifier: String?) {
        // must have at least one identifiable property to be a valid selector
        guard let identifier = identifier else {
            return nil
        }

        self.identifier = identifier
        super.init()
    }

    override func evaluateMatch(for target: AppcuesElementSelector) -> Int {
        guard let target = target as? FlutterElementSelector else {
            return 0
        }

        return identifier == target.identifier ? 10_000 : 0
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !identifier.isEmpty {
            try container.encode(identifier, forKey: .appcuesID)
        }
    }
}

@available(iOS 13.0, *)
internal class FlutterElementTargeting: AppcuesElementTargeting {

    private var widgets: [String: AppcuesViewElement] = [:]

    func captureLayout() -> AppcuesViewElement? {
        guard let captureWindow = UIApplication.shared.windows.first(where: { !$0.isAppcuesWindow }) else {
            return nil
        }

        return AppcuesViewElement(
            x: captureWindow.bounds.origin.x,
            y: captureWindow.bounds.origin.y,
            width: captureWindow.bounds.width,
            height: captureWindow.bounds.height,
            type: "\(type(of: captureWindow))",
            selector: nil,
            children: Array(widgets.values)
        )
    }

    func inflateSelector(from properties: [String: String]) -> AppcuesElementSelector? {
        return FlutterElementSelector(identifier: properties["appcuesID"])
    }

    func targetElement(properties: Dictionary<String, Any>) {

        guard let identifier = properties["identifier"] as? String,
            let x = properties["x"] as? Double,
            let y = properties["y"] as? Double,
            let width = properties["width"] as? Double,
            let height = properties["height"] as? Double,
            let type = properties["type"] as? String else {
            return
        }

        widgets[identifier] = AppcuesViewElement(
            x: CGFloat(x),
            y: CGFloat(y),
            width: CGFloat(width),
            height: CGFloat(height),
            type: type,
            selector: FlutterElementSelector(identifier: identifier),
            children: nil,
            displayName: identifier
        )
    }

    func resetTargetElements() {
        widgets.removeAll()
    }
}
