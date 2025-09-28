# Chromium iOS v2

A Chromium-based web browser for iOS with iOS 26 compatibility and robust address bar functionality.

## Features

- **iOS 26 Compatible**: Updated deployment target and API usage for iOS 26
- **Crash-Free Address Bar**: Comprehensive crash prevention and memory management
- **Chromium-Based Engine**: Uses WKWebView configured for Chromium-like behavior
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
   - WKWebView configured for Chromium-like behavior
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

## iOS 26 Compatibility

- **Deployment Target**: Set to iOS 26.0
- **Modern API Usage**: Updated to use latest iOS APIs where available
- **WebKit Configuration**: Configured for iOS 26 WebKit features
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
- iOS 26.0 SDK
- Deployment target: iOS 26.0

## Installation

1. Open `ChromiumIOSv2.xcodeproj` in Xcode
2. Select your target device or simulator (iOS 26+)
3. Build and run the project

## Usage

The browser provides a familiar interface with:
- Back/Forward navigation buttons
- Refresh button
- Address bar with smart URL completion
- Progress indicator for page loads

Simply tap the address bar, enter a URL or search term, and press Go or Return to navigate.

## Technical Notes

### WebView Configuration
The browser uses WKWebView configured with Chromium-like settings:
- Custom user agent string identifying as Chromium-based
- JavaScript enabled
- Media playback without user interaction
- Proper process pool configuration

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

## License

This project is based on the Chromium project and follows the same licensing terms.