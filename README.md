# Chromium iOS v2 - Blink Rendering Engine Edition

A Chromium-based browser for iOS with Blink rendering engine architecture.

## ⚠️ Important Notice

**This implementation uses conceptual Blink rendering engine components.** Due to Apple's iOS restrictions, alternative browser engines (including Blink) cannot actually run on iOS. All browsers on iOS must use WebKit.

This project demonstrates what a Blink-based architecture would look like and serves as an educational/demonstration implementation. The Blink components are stub implementations that simulate the architecture but do not perform actual rendering.

## Features

### Blink Rendering Engine Architecture (Conceptual)
- ✅ Blink rendering engine stub implementation
- ✅ V8 JavaScript engine interface
- ✅ Chromium content API integration
- ✅ Multi-process architecture simulation
- ✅ GPU acceleration configuration
- ✅ Mojo IPC framework structure

### Browser Features
- ✅ Full-featured address bar with search and URL support
- ✅ Navigation controls (back, forward, reload)
- ✅ Progress indicator for page loading
- ✅ JavaScript execution interface
- ✅ Custom user agent (Chromium-based)
- ✅ iOS 14+ compatibility
- ✅ Crash prevention and error handling

## Architecture

### Component Hierarchy
```
ViewController
    └── BlinkBrowserViewController
            ├── AddressBarController (UI)
            ├── UIProgressView (Loading indicator)
            └── BlinkWebView (Rendering surface)
                    └── BlinkEngine (Core engine)
                            ├── V8 JavaScript Engine
                            └── BlinkContentClient (Content API)
```

### Core Components

1. **BlinkEngine** - Singleton managing the Blink rendering engine lifecycle
2. **BlinkWebView** - Custom UIView that wraps Blink rendering surface
3. **BlinkContentClient** - Chromium content API client implementation
4. **BlinkBrowserViewController** - Main browser view controller
5. **AddressBarController** - Navigation and URL input UI

## Building

### Requirements
- macOS with Xcode 15.0 or later
- iOS 14.0+ device or simulator
- Apple Developer account (for device installation)

### Quick Build
```bash
# Clone the repository
git clone https://github.com/cosmokramerII/chromium-ios-v2.git
cd chromium-ios-v2

# Open in Xcode
open ChromiumIOSv2.xcodeproj

# Build and run (⌘+R in Xcode)
```

### Build IPA
```bash
# Configure code signing in Xcode first, then:
./build.sh
```

The IPA will be created in `build/ChromiumIOSv2.ipa`

## Installation

### Via Xcode
1. Open project in Xcode
2. Connect iOS device
3. Select your device as target
4. Build and run (⌘+R)

### Via AltStore (Sideloading)
1. Build the IPA or download from releases
2. Install AltStore on your device
3. Open AltStore and install the IPA
4. Trust the developer certificate in Settings

See [BUILD_IPA.md](BUILD_IPA.md) for detailed instructions.

## Project Structure

```
ChromiumIOSv2/
├── AppDelegate.{h,m}               # App lifecycle, Blink initialization
├── SceneDelegate.{h,m}             # Scene management
├── ViewController.{h,m}            # Root view controller
│
├── Blink Components (New)
├── BlinkEngine.{h,m}               # Core Blink engine management
├── BlinkWebView.{h,m}              # Blink rendering view wrapper
├── BlinkContentClient.{h,m}        # Chromium content API client
├── BlinkBrowserViewController.{h,m} # Main browser controller
│
├── UI Components
├── AddressBarController.{h,m}      # Address bar and navigation
│
├── Configuration
├── ChromiumConfig.h                # Blink and Chromium settings
│
└── Deprecated (WebKit-based)
    ├── BrowserViewController_WebKit_Deprecated.{h,m}
    └── (Kept for reference only)
```

## Configuration

Edit `ChromiumConfig.h` to customize:

```objective-c
// Blink version
#define BLINK_VERSION @"120.0.6099.0"

// V8 JavaScript engine
#define ENABLE_V8_JAVASCRIPT_ENGINE 1

// Performance settings
#define ENABLE_GPU_ACCELERATION 1
#define ENABLE_COMPOSITOR_THREAD 1

// Default URLs
#define DEFAULT_HOMEPAGE_URL @"https://www.google.com"
```

## Usage

### Basic Navigation

```objective-c
// Load a URL
[browserViewController loadURL:[NSURL URLWithString:@"https://example.com"]];

// Navigate
[browserViewController goBack];
[browserViewController goForward];
[browserViewController reload];
```

### JavaScript Execution

```objective-c
[blinkWebView evaluateJavaScript:@"document.title" 
                completionHandler:^(id result, NSError *error) {
    NSLog(@"Page title: %@", result);
}];
```

## Technical Details

### What Would Be Required for Real Blink on iOS

For Blink to actually work on iOS, you would need:

1. **Apple Policy Change**: Apple would need to allow alternative browser engines
2. **System Access**: Deep system-level APIs currently restricted
3. **Chromium Port**: Full port of Chromium's codebase to iOS
4. **Process Architecture**: Adaptation of Chromium's multi-process model
5. **GPU Integration**: Metal graphics API integration
6. **Engineering Effort**: Estimated 10,000+ hours of development

### Current Implementation

This project provides:
- ✅ Complete Blink-based architecture
- ✅ API-compatible interfaces
- ✅ Proper initialization and lifecycle management
- ✅ Logging and diagnostics
- ✅ Educational value for understanding Chromium architecture
- ❌ Actual web content rendering (iOS limitation)

## Documentation

- [BLINK_INTEGRATION.md](BLINK_INTEGRATION.md) - Detailed Blink integration guide
- [BUILD_IPA.md](BUILD_IPA.md) - Complete build and installation instructions
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- [CRASH_FIXES.md](CRASH_FIXES.md) - Stability improvements
- [FIXES_APPLIED.md](FIXES_APPLIED.md) - Project fixes summary

## Development

### Running in Simulator
```bash
# Build for simulator
xcodebuild -project ChromiumIOSv2.xcodeproj \
    -scheme ChromiumIOSv2 \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Debugging
The app logs detailed information to console:
```
[BlinkEngine] Initializing Blink rendering engine...
[BlinkContentClient] Configuring browser process...
[BlinkWebView] Loading URL: https://www.google.com
```

## Known Limitations

1. **No Actual Rendering**: iOS restrictions prevent real Blink rendering
2. **Stub Implementation**: Web pages display placeholder content
3. **No JavaScript Execution**: V8 engine is not actually running
4. **Educational Only**: Not suitable for production web browsing

## Alternatives for Real Chromium on iOS

If you want a real Chromium experience on iOS:
- Use **Google Chrome** from the App Store (uses WebKit underneath)
- Use **Microsoft Edge** from the App Store (also uses WebKit)
- Use **Brave Browser** from the App Store (also uses WebKit)

All iOS browsers use WebKit due to Apple's requirements.

## Contributing

This is an educational/demonstration project. Contributions to improve the architecture simulation are welcome:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is for educational purposes. See LICENSE file for details.

## Acknowledgments

- Chromium Project for the open-source browser engine
- Blink rendering engine documentation
- V8 JavaScript engine project
- iOS developer community

## Disclaimer

This is a conceptual implementation demonstrating Blink architecture. It does not provide actual Blink rendering on iOS, which is not possible due to platform restrictions. For real web browsing on iOS, please use established browsers from the App Store.

## Support

For issues and questions:
- Check [BLINK_INTEGRATION.md](BLINK_INTEGRATION.md) for technical details
- Review existing GitHub issues
- Create a new issue with detailed information

---

**Note**: This project serves as an educational demonstration of what a Blink-based iOS browser architecture would look like. Actual Blink rendering is not possible on iOS due to Apple's platform restrictions.
