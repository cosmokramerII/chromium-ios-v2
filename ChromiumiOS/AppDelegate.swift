import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Chromium engine with iOS 26 compatibility
        ChromiumEngine.shared.initialize()
        
        // Configure crash reporting and memory management
        configureCrashPrevention()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Clean up any resources related to discarded scenes
        ChromiumEngine.shared.cleanupDiscardedSessions()
    }
    
    // MARK: - Private Methods
    
    private func configureCrashPrevention() {
        // Set up memory warning handling
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            ChromiumEngine.shared.handleMemoryWarning()
        }
        
        // Configure exception handling for address bar crashes
        NSSetUncaughtExceptionHandler { exception in
            print("Uncaught exception: \(exception)")
            // Log the exception and attempt graceful recovery
            ChromiumEngine.shared.handleException(exception)
        }
    }
}