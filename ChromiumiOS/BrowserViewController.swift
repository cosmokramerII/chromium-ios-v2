import UIKit
import WebKit

class BrowserViewController: UIViewController {
    
    // MARK: - Properties
    
    private var addressBarView: AddressBarView!
    private var webView: WKWebView?
    private let chromiumEngine = ChromiumEngine.shared
    
    private var addressBarHeightConstraint: NSLayoutConstraint!
    private var webViewTopConstraint: NSLayoutConstraint!
    
    private let addressBarHeight: CGFloat = 80
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        configureChromiumEngine()
        loadHomePage()
        
        // Configure for iOS 26 compatibility
        configureForIOS26()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Ensure proper layout after appearing
        view.layoutIfNeeded()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup address bar
        addressBarView = AddressBarView()
        addressBarView.delegate = self
        addressBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addressBarView)
        
        // Create web view through Chromium engine
        createWebView()
    }
    
    private func setupConstraints() {
        addressBarHeightConstraint = addressBarView.heightAnchor.constraint(equalToConstant: addressBarHeight)
        
        NSLayoutConstraint.activate([
            // Address bar constraints
            addressBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addressBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addressBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addressBarHeightConstraint
        ])
        
        // Web view constraints will be set up in createWebView()
    }
    
    private func createWebView() {
        // Remove existing web view if any
        webView?.removeFromSuperview()
        
        // Create new web view with proper frame
        let webViewFrame = CGRect(x: 0, y: addressBarHeight, width: view.bounds.width, height: view.bounds.height - addressBarHeight)
        
        webView = chromiumEngine.createWebView(frame: webViewFrame)
        
        guard let webView = webView else {
            showError("Failed to create web view")
            return
        }
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        // Setup web view constraints
        webViewTopConstraint = webView.topAnchor.constraint(equalTo: addressBarView.bottomAnchor)
        
        NSLayoutConstraint.activate([
            webViewTopConstraint,
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Configure accessibility
        webView.accessibilityLabel = "Web content"
        webView.accessibilityHint = "Double tap to interact with web content"
    }
    
    private func configureChromiumEngine() {
        chromiumEngine.delegate = self
        
        // Ensure engine is initialized
        if !chromiumEngine.isInitialized {
            chromiumEngine.initialize()
        }
    }
    
    private func configureForIOS26() {
        if #available(iOS 17.0, *) {
            // Configure iOS 26 specific features
            setupiOS26Gestures()
            setupiOS26Notifications()
        }
        
        // Configure keyboard handling for iOS 26
        setupKeyboardHandling()
    }
    
    private func setupiOS26Gestures() {
        if #available(iOS 17.0, *) {
            // Add iOS 26 specific gesture recognizers
            let refreshGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleRefreshGesture))
            refreshGesture.direction = .down
            refreshGesture.numberOfTouchesRequired = 1
            view.addGestureRecognizer(refreshGesture)
        }
    }
    
    private func setupiOS26Notifications() {
        if #available(iOS 17.0, *) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAppWillEnterBackground),
                name: UIApplication.willResignActiveNotification,
                object: nil
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAppDidBecomeActive),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
        }
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Navigation Methods
    
    private func loadHomePage() {
        guard let url = URL(string: "https://www.google.com") else { return }
        navigateToURL(url)
    }
    
    private func navigateToURL(_ url: URL) {
        // Validate URL to prevent crashes
        guard isValidNavigationURL(url) else {
            showError("Invalid URL: \(url.absoluteString)")
            return
        }
        
        // Update address bar
        addressBarView.updateURL(url)
        
        // Navigate using Chromium engine
        chromiumEngine.loadURL(url)
    }
    
    private func isValidNavigationURL(_ url: URL) -> Bool {
        // Enhanced validation to prevent address bar crashes
        let scheme = url.scheme?.lowercased() ?? ""
        let allowedSchemes = ["http", "https", "about"]
        
        guard allowedSchemes.contains(scheme),
              url.absoluteString.count < 2048,
              !url.absoluteString.isEmpty else {
            return false
        }
        
        return true
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Error",
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    // MARK: - Gesture Handlers
    
    @objc private func handleRefreshGesture() {
        chromiumEngine.reload()
    }
    
    // MARK: - Notification Handlers
    
    @objc private func handleAppWillEnterBackground() {
        // Save state and prepare for background
        chromiumEngine.enterBackground()
    }
    
    @objc private func handleAppDidBecomeActive() {
        // Restore from background
        chromiumEngine.enterForeground()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.webViewTopConstraint.constant = -keyboardHeight / 2
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.webViewTopConstraint.constant = 0
            self?.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Memory Management
    
    func cleanup() {
        // This method is called by ChromiumEngine when needed
        webView?.removeFromSuperview()
        webView = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        cleanup()
    }
}

// MARK: - AddressBarViewDelegate

extension BrowserViewController: AddressBarViewDelegate {
    
    func addressBarView(_ addressBarView: AddressBarView, didRequestNavigationTo url: URL) {
        // This is the critical method that was causing crashes
        // Implement with comprehensive error handling
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Pre-navigation validation
            guard self.isValidNavigationURL(url) else {
                self.showError("Cannot navigate to invalid URL")
                return
            }
            
            // Ensure web view is ready
            guard self.webView != nil else {
                print("WebView not ready, recreating...")
                self.createWebView()
                
                // Retry navigation after web view creation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigateToURL(url)
                }
                return
            }
            
            // Perform safe navigation
            do {
                self.navigateToURL(url)
            } catch {
                print("Navigation error: \(error)")
                self.showError("Navigation failed: \(error.localizedDescription)")
            }
        }
    }
    
    func addressBarViewDidBeginEditing(_ addressBarView: AddressBarView) {
        // Handle address bar focus
        // Ensure UI is responsive during editing
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func addressBarViewDidEndEditing(_ addressBarView: AddressBarView) {
        // Handle address bar losing focus
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - ChromiumEngineDelegate

extension BrowserViewController: ChromiumEngineDelegate {
    
    func engineDidStartLoading(_ engine: ChromiumEngine) {
        DispatchQueue.main.async { [weak self] in
            self?.addressBarView.setLoading(true)
        }
    }
    
    func engine(_ engine: ChromiumEngine, didUpdateProgress progress: Float) {
        DispatchQueue.main.async { [weak self] in
            self?.addressBarView.setLoading(true, progress: progress)
        }
    }
    
    func engine(_ engine: ChromiumEngine, didFinishLoadingURL url: URL?) {
        DispatchQueue.main.async { [weak self] in
            self?.addressBarView.setLoading(false)
            self?.addressBarView.updateURL(url)
        }
    }
    
    func engine(_ engine: ChromiumEngine, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.addressBarView.setLoading(false)
            self?.showError("Loading failed: \(error.localizedDescription)")
        }
    }
    
    func engine(_ engine: ChromiumEngine, didUpdateURL url: URL?) {
        DispatchQueue.main.async { [weak self] in
            self?.addressBarView.updateURL(url)
        }
    }
}