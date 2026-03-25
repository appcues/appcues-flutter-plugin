import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        (UIApplication.shared.delegate as? AppDelegate)?.captureInitialLinkIfNeeded(from: connectionOptions)
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }

    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        for context in URLContexts {
            _ = appDelegate?.handleOpen(url: context.url)
        }
        super.scene(scene, openURLContexts: URLContexts)
    }
}
