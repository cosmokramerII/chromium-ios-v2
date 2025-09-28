import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Create and configure the main browser view controller
        let browserViewController = BrowserViewController()
        let navigationController = UINavigationController(rootViewController: browserViewController)
        navigationController.isNavigationBarHidden = true
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // Configure for iOS 26 compatibility
        configureForIOS26Compatibility()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Clean up Chromium resources when scene disconnects
        ChromiumEngine.shared.sceneDidDisconnect()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Resume Chromium engine operations
        ChromiumEngine.shared.resume()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Pause Chromium engine operations
        ChromiumEngine.shared.pause()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Prepare for foreground operation
        ChromiumEngine.shared.enterForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save state and cleanup for background
        ChromiumEngine.shared.enterBackground()
    }
    
    // MARK: - iOS 26 Compatibility
    
    private func configureForIOS26Compatibility() {
        // Configure scene for iOS 26 specific features
        if #available(iOS 17.0, *) {
            // Enable iOS 26 specific window behaviors
            window?.windowScene?.sizeRestrictions?.minimumSize = CGSize(width: 320, height: 568)
            window?.windowScene?.sizeRestrictions?.maximumSize = CGSize(width: 2048, height: 2732)
        }
        
        // Configure trait collection handling for iOS 26
        configureTraitCollection()
    }
    
    private func configureTraitCollection() {
        if #available(iOS 17.0, *) {
            // Handle dynamic type size changes
            NotificationCenter.default.addObserver(
                forName: UIContentSizeCategory.didChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                // Update UI for accessibility changes
                self.window?.rootViewController?.view.setNeedsLayout()
            }
        }
    }
}