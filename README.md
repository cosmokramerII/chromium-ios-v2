# Chromium iOS v2

A WebKit-based web browser for iOS with iOS 14+ compatibility and robust address bar functionality.

**Note**: Due to Apple's App Store requirements, all iOS browsers must use WebKit (WKWebView) as their rendering engine. While this browser is styled after Chromium and uses a Chrome-compatible user agent string for site compatibility, it uses Apple's WebKit engine, not Blink.

## 🎉 Project Status: Ready to Build!

All errors have been fixed! The project is now ready to build and create IPA files. See **[QUICKSTART.md](QUICKSTART.md)** for immediate build instructions.

**Recent Fixes:**
- ✅ Project structure corrected (proper .xcodeproj bundle)
- ✅ iOS deployment target fixed (iOS 14.0, was incorrectly iOS 26.0)
- ✅ Assets catalog added (AppIcon, AccentColor)
- ✅ Build script enhanced to create IPA files
- ✅ All configuration issues resolved

**Quick Build:** Run `./build.sh` on macOS with Xcode to create the IPA.

## Features

- **iOS 14+ Compatible**: Updated deployment target and API usage for iOS 14 and later
- **Crash-Free Address Bar**: Comprehensive crash prevention and memory management
- **WebKit-Based Engine**: Uses Apple's WKWebView (required for all iOS browsers)
- **Chrome-Compatible User Agent**: Configured for optimal site compatibility
- **Robust URL Handling**: Smart URL validation and search query detection
- **Thread-Safe Operations**: All UI updates are performed on the main thread
- **Modern iOS Design**: Uses Auto Layout and supports both iPhone and iPad

## Architecture

### Core Components

1. **AddressBarController**: Manages the address bar UI and URL input validation
   - Comprehensive crash prevention through proper memory management
   - Debounced text input to prevent excessive processing
   - Thread-safe URL updates
   - Smart URL validation and search query detection

2. **BrowserViewController**: Main browser interface with WebView integration
   - WKWebView (Apple's WebKit engine, required for iOS)
   - Progress tracking and loading state management
   - Proper delegate cleanup to prevent crashes

3. **ViewController**: Root view controller that manages the browser interface

## Crash Fixes Implemented

### Memory Management
- Proper deallocation methods with cleanup of delegates and observers
- Timer invalidation to prevent retain cycles
- KVO observer removal in dealloc methods

### Thread Safety
- All UI updates dispatched to main queue
- Thread-safe URL display updates
- Proper handling of concurrent operations

### Input Validation
- URL length limits to prevent buffer overflows
- Comprehensive URL validation and sanitization
- Graceful handling of nil and empty inputs

### Error Handling
- Proper error handling for WebView creation failures
- Network error presentation with user-friendly messages
- Graceful degradation when components fail to initialize

## iOS 14+ Compatibility

- **Deployment Target**: Set to iOS 14.0
- **Modern API Usage**: Updated to use latest iOS APIs where available
- **WebKit Configuration**: Configured for modern iOS WebKit features
- **Scene Support**: Full support for iOS 13+ scene-based lifecycle

## Testing

The project includes comprehensive unit tests for the address bar functionality:

- Crash prevention tests
- URL validation tests
- Threading safety tests
- Memory leak detection
- UI state management tests

## Build Requirements

- Xcode 15.0 or later
- iOS 14.0 SDK or later
- Deployment target: iOS 14.0

## Installation

### Quick Start
For a quick guide to building and installing the IPA, see **[QUICKSTART.md](QUICKSTART.md)**.

### Detailed Steps
1. Open `ChromiumIOSv2.xcodeproj` in Xcode
2. Select your target device or simulator (iOS 14+)
3. Configure code signing in "Signing & Capabilities"
4. Build and run the project

### Building IPA
```bash
./build.sh
```

For comprehensive build and installation instructions, see **[BUILD_IPA.md](BUILD_IPA.md)**.

### Validation
To verify the project is correctly configured:
```bash
./validate.sh
```

## Usage

The browser provides a familiar interface with:
- Back/Forward navigation buttons
- Refresh button
- Address bar with smart URL completion
- Progress indicator for page loads

Simply tap the address bar, enter a URL or search term, and press Go or Return to navigate.

## Technical Notes

### WebView Configuration
The browser uses Apple's WKWebView (WebKit engine) configured with optimal settings:
- Custom user agent string for Chrome compatibility with websites
- JavaScript enabled
- Media playback without user interaction
- Proper process pool configuration

**Important**: iOS browsers are required by Apple to use WebKit. This browser cannot use Blink (Chrome's engine) as it is not available on iOS.

### Address Bar Features
- Automatic HTTPS prefix addition
- Search query detection and Google search integration
- URL validation and error feedback
- Debounced input processing for performance

### Error Recovery
- Graceful handling of network errors
- WebView initialization failure recovery
- Memory pressure handling

## Contributing

When contributing to this project, please ensure:
1. All new code includes proper memory management
2. UI updates are performed on the main thread
3. Error handling is comprehensive
4. Unit tests are provided for new functionality
5. Run `./validate.sh` before submitting changes

## Documentation

- **[ENGINE_INFO.md](ENGINE_INFO.md)** - Detailed explanation of WebKit vs Blink
- **[QUICKSTART.md](QUICKSTART.md)** - Fast guide to build and install
- **[BUILD_IPA.md](BUILD_IPA.md)** - Comprehensive build instructions
- **[FIXES_APPLIED.md](FIXES_APPLIED.md)** - List of fixes and improvements
- **[CRASH_FIXES.md](CRASH_FIXES.md)** - Technical crash prevention details

## License

This project is inspired by the Chromium project's UI design. The browser uses Apple's WebKit engine as required by iOS App Store guidelines.