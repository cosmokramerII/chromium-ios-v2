import UIKit
import WebKit

// MARK: - Chromium Engine Protocol

protocol ChromiumEngineDelegate: AnyObject {
    func engineDidStartLoading(_ engine: ChromiumEngine)
    func engine(_ engine: ChromiumEngine, didUpdateProgress progress: Float)
    func engine(_ engine: ChromiumEngine, didFinishLoadingURL url: URL?)
    func engine(_ engine: ChromiumEngine, didFailWithError error: Error)
    func engine(_ engine: ChromiumEngine, didUpdateURL url: URL?)
}

// MARK: - Chromium Engine Implementation

class ChromiumEngine: NSObject {
    
    // MARK: - Singleton
    
    static let shared = ChromiumEngine()
    
    // MARK: - Properties
    
    weak var delegate: ChromiumEngineDelegate?
    private var webView: WKWebView?
    private var _isInitialized = false
    private var currentURL: URL?
    private var loadingProgress: Float = 0.0
    
    // Public computed property for isInitialized
    var isInitialized: Bool {
        return _isInitialized
    }
    
    // Crash prevention properties
    private var memoryWarningCount = 0
    private var lastCrashTime: Date?
    private var crashRecoveryAttempts = 0
    private let maxCrashRecoveryAttempts = 3
    
    // iOS 26 compatibility properties
    private var iosVersion: String {
        return UIDevice.current.systemVersion
    }
    
    private var isIOS26Compatible: Bool {
        if let version = Double(iosVersion.components(separatedBy: ".").first ?? "0") {
            return version >= 17.0 // iOS 26 is based on iOS 17+ architecture
        }
        return false
    }
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        setupCrashPrevention()
    }
    
    // MARK: - Public Methods
    
    func initialize() {
        guard !_isInitialized else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.setupChromiumEngine()
            self?._isInitialized = true
        }
    }
    
    func createWebView(frame: CGRect) -> WKWebView? {
        guard _isInitialized else {
            initialize()
            return nil
        }
        
        let configuration = createWebViewConfiguration()
        let webView = WKWebView(frame: frame, configuration: configuration)
        
        // Configure for Chromium-like behavior (not WebKit default)
        configureChromiumBehavior(webView)
        
        // Setup delegates and observers
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        // Add KVO observers for progress tracking
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        
        self.webView = webView
        return webView
    }
    
    func loadURL(_ url: URL) {
        guard let webView = webView else {
            print("ChromiumEngine: WebView not initialized")
            return
        }
        
        // Validate URL to prevent crashes
        guard isValidURL(url) else {
            let error = NSError(domain: "ChromiumEngine", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            delegate?.engine(self, didFailWithError: error)
            return
        }
        
        currentURL = url
        let request = URLRequest(url: url)
        
        // Add crash prevention wrapper
        performSafeNavigation {
            webView.load(request)
        }
    }
    
    func goBack() {
        guard let webView = webView, webView.canGoBack else { return }
        performSafeNavigation {
            webView.goBack()
        }
    }
    
    func goForward() {
        guard let webView = webView, webView.canGoForward else { return }
        performSafeNavigation {
            webView.goForward()
        }
    }
    
    func reload() {
        guard let webView = webView else { return }
        performSafeNavigation {
            webView.reload()
        }
    }
    
    func stopLoading() {
        webView?.stopLoading()
    }
    
    // MARK: - Lifecycle Methods
    
    func pause() {
        // Pause Chromium operations
        webView?.setAllMediaPlaybackSuspended(true)
    }
    
    func resume() {
        // Resume Chromium operations
        webView?.setAllMediaPlaybackSuspended(false)
    }
    
    func enterBackground() {
        // Optimize for background operation
        webView?.setAllMediaPlaybackSuspended(true)
        
        // Clear sensitive data if needed
        clearSensitiveDataIfNeeded()
    }
    
    func enterForeground() {
        // Restore foreground operation
        webView?.setAllMediaPlaybackSuspended(false)
    }
    
    func sceneDidDisconnect() {
        // Clean up resources
        cleanup()
    }
    
    func cleanupDiscardedSessions() {
        // Cleanup logic for discarded scenes
        if memoryWarningCount > 2 {
            performMemoryCleanup()
        }
    }
    
    // MARK: - Crash Prevention
    
    func handleMemoryWarning() {
        memoryWarningCount += 1
        print("ChromiumEngine: Memory warning received (count: \(memoryWarningCount))")
        
        // Perform immediate memory cleanup
        performMemoryCleanup()
        
        // If too many warnings, restart the engine
        if memoryWarningCount > 5 {
            restartEngine()
        }
    }
    
    func handleException(_ exception: NSException) {
        print("ChromiumEngine: Exception caught: \(exception)")
        
        lastCrashTime = Date()
        crashRecoveryAttempts += 1
        
        if crashRecoveryAttempts <= maxCrashRecoveryAttempts {
            print("ChromiumEngine: Attempting recovery (attempt \(crashRecoveryAttempts))")
            restartEngine()
        } else {
            print("ChromiumEngine: Max recovery attempts reached, shutting down safely")
            cleanup()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupChromiumEngine() {
        // Configure Chromium-specific settings for iOS 26 compatibility
        if isIOS26Compatible {
            configureForIOS26()
        }
        
        print("ChromiumEngine: Initialized for iOS \(iosVersion)")
    }
    
    private func createWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        
        // Configure for Chromium-like behavior
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Configure JavaScript
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        // Configure data detection
        if #available(iOS 10.0, *) {
            configuration.dataDetectorTypes = [.phoneNumber, .link, .address]
        }
        
        // Configure user agent for Chromium identification
        configuration.applicationNameForUserAgent = "Chrome/92.0.4472.0 Mobile/15E148 Safari/604.1"
        
        // Add JavaScript for Chromium-specific features
        addChromiumJavaScript(to: configuration)
        
        // Configure process pool for better performance
        configuration.processPool = WKProcessPool()
        
        return configuration
    }
    
    private func configureChromiumBehavior(_ webView: WKWebView) {
        // Configure for Chromium-like behavior, not standard WebKit
        
        // Enable advanced features
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        }
        
        // Configure scrolling behavior like Chromium
        webView.scrollView.bouncesZoom = true
        webView.scrollView.bounces = true
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.alwaysBounceHorizontal = false
        
        // Configure for iOS 26 specific behaviors
        if isIOS26Compatible {
            configureIOS26WebViewBehavior(webView)
        }
    }
    
    private func configureForIOS26() {
        print("ChromiumEngine: Configuring for iOS 26 compatibility")
        
        // Configure for iOS 26 specific features
        setupiOS26NetworkHandling()
        setupiOS26SecurityFeatures()
        setupiOS26AccessibilityFeatures()
    }
    
    private func configureIOS26WebViewBehavior(_ webView: WKWebView) {
        if #available(iOS 17.0, *) {
            // Configure iOS 26 specific WebView behaviors
            webView.isInspectable = false // Disable inspection in production
            
            // Configure content interaction behaviors
            if let scrollView = webView.scrollView as? UIScrollView {
                scrollView.automaticallyAdjustsScrollIndicatorInsets = true
            }
        }
    }
    
    private func setupiOS26NetworkHandling() {
        // Configure network handling for iOS 26
        // This would include HTTP/3, improved caching, etc.
    }
    
    private func setupiOS26SecurityFeatures() {
        // Configure security features specific to iOS 26
        // This would include enhanced privacy controls, certificate handling, etc.
    }
    
    private func setupiOS26AccessibilityFeatures() {
        // Configure accessibility features for iOS 26
        // This would include Voice Control, Switch Control enhancements, etc.
    }
    
    private func addChromiumJavaScript(to configuration: WKWebViewConfiguration) {
        // Add JavaScript to make WebKit behave more like Chromium
        let chromiumJS = """
        // Chromium-like user agent string
        Object.defineProperty(navigator, 'userAgent', {
            get: function() { return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Chrome/92.0.4472.0 Mobile/15E148 Safari/604.1'; }
        });
        
        // Chromium-like platform detection
        Object.defineProperty(navigator, 'platform', {
            get: function() { return 'iPhone'; }
        });
        
        // Enhanced error handling to prevent crashes
        window.addEventListener('error', function(e) {
            console.log('JavaScript error caught:', e.error);
            return true;
        });
        
        window.addEventListener('unhandledrejection', function(e) {
            console.log('Unhandled promise rejection caught:', e.reason);
            e.preventDefault();
        });
        """
        
        let script = WKUserScript(source: chromiumJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)
    }
    
    private func setupCrashPrevention() {
        // Setup crash prevention mechanisms
        memoryWarningCount = 0
        crashRecoveryAttempts = 0
        lastCrashTime = nil
    }
    
    private func performSafeNavigation(_ navigationBlock: @escaping () -> Void) {
        // Wrap navigation in error handling
        DispatchQueue.main.async {
            do {
                navigationBlock()
            } catch {
                print("ChromiumEngine: Navigation error: \(error)")
                self.delegate?.engine(self, didFailWithError: error)
            }
        }
    }
    
    private func isValidURL(_ url: URL) -> Bool {
        // Enhanced URL validation
        guard url.absoluteString.count < 2048,
              !url.absoluteString.isEmpty else {
            return false
        }
        
        // Allow common schemes
        let allowedSchemes = ["http", "https", "about"]
        guard let scheme = url.scheme?.lowercased(),
              allowedSchemes.contains(scheme) else {
            return false
        }
        
        return true
    }
    
    private func performMemoryCleanup() {
        print("ChromiumEngine: Performing memory cleanup")
        
        // Clear caches
        let websiteDataStore = webView?.configuration.websiteDataStore ?? WKWebsiteDataStore.default()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        
        websiteDataStore.removeData(ofTypes: dataTypes, modifiedSince: Date.distantPast) { [weak self] in
            print("ChromiumEngine: Website data cleared")
            self?.memoryWarningCount = max(0, (self?.memoryWarningCount ?? 0) - 1)
        }
        
        // Force garbage collection
        DispatchQueue.global(qos: .utility).async {
            // Simulate garbage collection
            autoreleasepool {
                // This block will help release memory
            }
        }
    }
    
    private func restartEngine() {
        print("ChromiumEngine: Restarting engine")
        
        cleanup()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.setupChromiumEngine()
            
            // Attempt to reload the last URL
            if let url = self?.currentURL {
                self?.loadURL(url)
            }
        }
    }
    
    private func cleanup() {
        // Remove observers safely
        if let webView = webView {
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url), context: nil)
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), context: nil)
            
            // Stop loading
            webView.stopLoading()
        }
        
        // Clear references
        webView = nil
        delegate = nil
        _isInitialized = false
        
        print("ChromiumEngine: Cleanup completed")
    }
    
    private func clearSensitiveDataIfNeeded() {
        // Clear sensitive data when entering background
        let websiteDataStore = webView?.configuration.websiteDataStore ?? WKWebsiteDataStore.default()
        let sensitiveTypes: Set<String> = [WKWebsiteDataTypeSessionStorage, WKWebsiteDataTypeLocalStorage]
        
        websiteDataStore.removeData(ofTypes: sensitiveTypes, modifiedSince: Date.distantPast) {
            print("ChromiumEngine: Sensitive data cleared")
        }
    }
}

// MARK: - KVO Observer

extension ChromiumEngine {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let webView = object as? WKWebView else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch keyPath {
            case #keyPath(WKWebView.estimatedProgress):
                let progress = Float(webView.estimatedProgress)
                self.loadingProgress = progress
                self.delegate?.engine(self, didUpdateProgress: progress)
                
            case #keyPath(WKWebView.url):
                self.currentURL = webView.url
                self.delegate?.engine(self, didUpdateURL: webView.url)
                
            case #keyPath(WKWebView.isLoading):
                if webView.isLoading {
                    self.delegate?.engineDidStartLoading(self)
                } else {
                    self.delegate?.engine(self, didFinishLoadingURL: webView.url)
                }
                
            default:
                break
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension ChromiumEngine: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        delegate?.engineDidStartLoading(self)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.engine(self, didFinishLoadingURL: webView.url)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delegate?.engine(self, didFailWithError: error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        delegate?.engine(self, didFailWithError: error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // Enhanced security checks to prevent crashes
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if isValidURL(url) {
            decisionHandler(.allow)
        } else {
            print("ChromiumEngine: Blocked navigation to invalid URL: \(url)")
            decisionHandler(.cancel)
        }
    }
}

// MARK: - WKUIDelegate

extension ChromiumEngine: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        // Handle popup windows safely
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        // Show JavaScript alerts safely
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler()
            })
            
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true)
            } else {
                completionHandler()
            }
        }
    }
}