import UIKit
import Flutter
import ContoursAI_SDK

@main
@objc class AppDelegate: FlutterAppDelegate {
    var navigationController: UINavigationController!
    let contoursSDK = ContoursAIFramework()
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        let controller = window?.rootViewController as! FlutterViewController
        self.navigationController = UINavigationController(rootViewController: controller)
        self.window?.rootViewController = self.navigationController
        self.window?.makeKeyAndVisible()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    override func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return ContoursAIFramework.shared.isLandscape ? .landscapeRight : .portrait
    }
}

