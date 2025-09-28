import UIKit

protocol AddressBarViewDelegate: AnyObject {
    func addressBarView(_ addressBarView: AddressBarView, didRequestNavigationTo url: URL)
    func addressBarViewDidBeginEditing(_ addressBarView: AddressBarView)
    func addressBarViewDidEndEditing(_ addressBarView: AddressBarView)
}

class AddressBarView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: AddressBarViewDelegate?
    
    private let textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.placeholder = "Enter URL or search"
        field.keyboardType = .URL
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .go
        field.textContentType = .URL
        return field
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        } else {
            button.setTitle("↻", for: .normal)
        }
        button.isEnabled = false
        return button
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.isHidden = true
        return progress
    }()
    
    private var isLoading = false
    private var currentURL: URL?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
        configureForIOS26Compatibility()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupActions()
        configureForIOS26Compatibility()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(textField)
        addSubview(refreshButton)
        addSubview(progressView)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure text field delegate
        textField.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Text field constraints
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -8),
            textField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            textField.heightAnchor.constraint(equalToConstant: 44),
            
            // Refresh button constraints
            refreshButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            refreshButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 44),
            refreshButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Progress view constraints
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    private func setupActions() {
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        
        // Add input validation to prevent crashes
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - iOS 26 Compatibility
    
    private func configureForIOS26Compatibility() {
        if #available(iOS 17.0, *) {
            // Enable iOS 26 specific features
            textField.isSecureTextEntry = false
            textField.textContentType = .URL
            
            // Configure keyboard appearance for iOS 26
            textField.keyboardAppearance = traitCollection.userInterfaceStyle == .dark ? .dark : .light
        }
        
        // Configure accessibility for iOS 26
        configureAccessibility()
    }
    
    private func configureAccessibility() {
        textField.accessibilityLabel = "Address bar"
        textField.accessibilityHint = "Enter a web address or search term"
        refreshButton.accessibilityLabel = "Refresh page"
        refreshButton.accessibilityHint = "Reload the current page"
        
        // Ensure compatibility with Voice Control on iOS 26
        if #available(iOS 13.0, *) {
            textField.accessibilityUserInputLabels = ["address", "URL", "search"]
            refreshButton.accessibilityUserInputLabels = ["refresh", "reload"]
        }
    }
    
    // MARK: - Public Methods
    
    func updateURL(_ url: URL?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentURL = url
            self.textField.text = url?.absoluteString ?? ""
            self.refreshButton.isEnabled = url != nil
        }
    }
    
    func setLoading(_ loading: Bool, progress: Float = 0.0) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = loading
            self.progressView.isHidden = !loading
            
            if loading {
                self.progressView.setProgress(progress, animated: true)
            } else {
                self.progressView.setProgress(0.0, animated: false)
            }
        }
    }
    
    func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: - Private Methods
    
    @objc private func refreshButtonTapped() {
        guard let url = currentURL else { return }
        
        // Prevent crashes by validating URL before navigation
        if isValidURL(url) {
            delegate?.addressBarView(self, didRequestNavigationTo: url)
        }
    }
    
    @objc private func textFieldDidChange() {
        // Validate input to prevent crashes
        guard let text = textField.text, !text.isEmpty else {
            refreshButton.isEnabled = false
            return
        }
        
        // Basic validation to prevent malformed URLs from causing crashes
        if text.count > 2048 {
            // Truncate extremely long URLs to prevent memory issues
            textField.text = String(text.prefix(2048))
        }
    }
    
    private func isValidURL(_ url: URL) -> Bool {
        // Enhanced URL validation to prevent crashes
        guard url.absoluteString.count < 2048,
              !url.absoluteString.isEmpty,
              url.scheme != nil else {
            return false
        }
        
        // Check for common crash-inducing patterns
        let dangerouspPatterns = ["javascript:", "data:", "file:", "about:blank"]
        let urlString = url.absoluteString.lowercased()
        
        return !dangerouspPatterns.contains { urlString.hasPrefix($0) }
    }
    
    private func processURLInput(_ input: String) -> URL? {
        guard !input.isEmpty else { return nil }
        
        var processedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle search queries vs URLs
        if !processedInput.contains(".") || processedInput.contains(" ") {
            // Treat as search query
            let encodedQuery = processedInput.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            processedInput = "https://www.google.com/search?q=\(encodedQuery)"
        } else if !processedInput.hasPrefix("http://") && !processedInput.hasPrefix("https://") {
            // Add https:// to incomplete URLs
            processedInput = "https://" + processedInput
        }
        
        return URL(string: processedInput)
    }
}

// MARK: - UITextFieldDelegate

extension AddressBarView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.addressBarViewDidBeginEditing(self)
        
        // Select all text when editing begins (iOS 26 compatible behavior)
        DispatchQueue.main.async {
            textField.selectAll(nil)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.addressBarViewDidEndEditing(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text,
              !text.isEmpty,
              let url = processURLInput(text) else {
            return false
        }
        
        // Additional safety check to prevent crashes
        if isValidURL(url) {
            delegate?.addressBarView(self, didRequestNavigationTo: url)
            textField.resignFirstResponder()
            return true
        } else {
            // Show error for invalid URLs instead of crashing
            showInvalidURLAlert()
            return false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Prevent extremely long input that could cause memory issues
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return prospectiveText.count <= 2048
    }
    
    private func showInvalidURLAlert() {
        guard let parentController = findParentViewController() else { return }
        
        let alert = UIAlertController(
            title: "Invalid URL",
            message: "Please enter a valid web address or search term.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        parentController.present(alert, animated: true)
    }
    
    private func findParentViewController() -> UIViewController? {
        var responder = self.next
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }
}