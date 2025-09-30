# Chromium for iOS

A minimal iOS browser application based on Chromium with Blink rendering engine integration.

## 🎯 Blink Integration

This repository includes a complete architectural framework for integrating **Blink** (Chromium's rendering engine) directly into iOS, replacing WKWebView. See [BLINK_INTEGRATION.md](BLINK_INTEGRATION.md) for comprehensive documentation.

### Key Features
- **Direct Blink Integration**: Uses Chromium's Blink rendering engine instead of WebKit
- **Metal Compositor**: Hardware-accelerated rendering via Metal API
- **C++ Bridge Layer**: Native integration between Swift/Objective-C and Blink C++
- **Full Browser UI**: Address bar, navigation controls, and web content display
- **GN Build System**: Complete build configuration for Chromium integration

## Project Structure

```
chromium-ios-v2/
├── ios/chrome/browser/web/    # Blink integration layer
│   ├── BUILD.gn               # GN build configuration
│   ├── blink_web_view_bridge.h/mm     # C++ Blink wrapper
│   ├── blink_web_view_controller.h/mm # Objective-C++ wrapper
│   ├── metal_compositor.h/mm          # Metal rendering
│   ├── web_state.h/mm                 # Web state management
│   └── blink_web_view_bridge_unittest.mm # Unit tests
├── ChromiumApp/               # iOS app project
│   ├── ChromiumApp.xcodeproj  # Xcode project file
│   ├── Entitlements.plist     # JIT and Metal entitlements
│   └── ChromiumApp/           # Source code
│       ├── AppDelegate.swift
│       ├── SceneDelegate.swift
│       ├── ViewController.swift        # Browser UI
│       ├── Info.plist                  # App configuration
│       ├── ChromiumApp-Bridging-Header.h
│       ├── Assets.xcassets/
│       └── Base.lproj/
├── out/ios/                   # Build output directory
│   └── args.gn                # GN build arguments
├── build.sh                   # Legacy build script
├── build-blink.sh             # Blink integration build script
├── .gn                        # GN root configuration
├── BUILD.gn                   # Root build file
├── BLINK_INTEGRATION.md       # Blink integration guide
├── BUILDING.md                # Build instructions
├── altstore-source.json       # AltStore metadata
└── Icon.png                   # App icon

```

## Requirements

- macOS with Xcode 14.0 or later
- iOS 13.0 or later for deployment
- Apple Developer account (for signing and distribution)

### For Blink Integration Build
- Full Chromium source tree (~100GB)
- Python 3.8+
- GN and Ninja build tools
- 16GB+ RAM recommended
- See [BLINK_INTEGRATION.md](BLINK_INTEGRATION.md) for detailed requirements

## Building

### Standard iOS Build (Swift App Only)

For building the iOS app shell without full Blink integration:

### On macOS

1. Clone this repository:
   ```bash
   git clone https://github.com/cosmokramerII/chromium-ios-v2.git
   cd chromium-ios-v2
   ```

2. Run the build script:
   ```bash
   ./build.sh
   ```

3. The script will:
   - Clean previous builds
   - Build the Xcode project
   - Create an archive
   - Export the IPA file

4. The IPA will be created at `chromium.ipa` in the repository root.

### Blink Integration Build

For building with full Blink rendering engine:

1. **Get Chromium source** (one-time setup, ~4 hours):
   ```bash
   mkdir ~/chromium && cd ~/chromium
   fetch ios
   cd src
   gclient sync
   ```

2. **Run the Blink build script**:
   ```bash
   export CHROMIUM_SRC=~/chromium/src
   ./build-blink.sh
   ```

3. **Result**: `chromium-blink.ipa` with full Blink integration

See [BLINK_INTEGRATION.md](BLINK_INTEGRATION.md) for detailed instructions.

### Manual Build

If you prefer to build manually:

1. Open `ChromiumApp/ChromiumApp.xcodeproj` in Xcode
2. Select your development team in the project settings
3. Select Product > Archive
4. Export the archive as an IPA

## Code Signing

Before building, you need to configure code signing:

1. Open the Xcode project
2. Select the ChromiumApp target
3. Go to "Signing & Capabilities"
4. Select your development team
5. Xcode will automatically manage provisioning profiles

For distribution:
- Update `build.sh` with your Team ID
- Choose appropriate export method (ad-hoc, app-store, enterprise, or development)

## Installation

### Via AltStore

1. Add this repository source to AltStore:
   ```
   https://raw.githubusercontent.com/cosmokramerII/chromium-ios-v2/master/altstore-source.json
   ```

2. Install Chromium from AltStore

### Via Xcode

1. Connect your iOS device
2. Open the project in Xcode
3. Select your device as the target
4. Click Run

## Features

### Current Features
- Browser UI with address bar and navigation controls
- Architecture for Blink rendering engine integration
- Metal-based compositor for GPU-accelerated rendering
- C++ bridge layer for Chromium integration
- JIT entitlements for V8 JavaScript engine
- Compatible with iOS 13.0+
- Supports both iPhone and iPad

### Blink Integration Features
When built with full Chromium source:
- Direct Blink rendering (same as desktop Chrome)
- Full HTML5/CSS3 compliance
- Advanced web platform features
- Service Workers, WebGL, WebRTC
- Modern JavaScript engine (V8)

## Architecture

### Blink Integration Layer

The app uses a multi-layer architecture:

1. **Swift UI Layer** (`ViewController.swift`)
   - Browser interface and controls
   - User input handling

2. **Objective-C++ Bridge** (`blink_web_view_controller.mm`)
   - Bridges Swift to C++
   - Manages Metal layer for rendering

3. **C++ Blink Bridge** (`blink_web_view_bridge.mm`)
   - Wraps Blink WebView API
   - Handles navigation and rendering

4. **Metal Compositor** (`metal_compositor.mm`)
   - GPU rendering via Metal
   - Composites Blink output to screen

5. **Blink Renderer** (from Chromium source)
   - HTML/CSS parsing and layout
   - JavaScript execution (V8)
   - Rendering pipeline

See [BLINK_INTEGRATION.md](BLINK_INTEGRATION.md) for architecture details.

## Development

To develop and modify the app:

1. Open `ChromiumApp/ChromiumApp.xcodeproj` in Xcode
2. Make your changes to the Swift files
3. Test using the iOS Simulator or a physical device
4. Build and create IPA using the build script

## Troubleshooting

### Build Errors

If you encounter build errors:

1. Ensure Xcode Command Line Tools are installed:
   ```bash
   xcode-select --install
   ```

2. Clean the build folder in Xcode (Product > Clean Build Folder)

3. Verify your code signing configuration

### Blink Integration Issues

For Blink-specific issues:

1. **Missing Chromium source**: Ensure `CHROMIUM_SRC` is set correctly
2. **GN errors**: Verify depot_tools is in your PATH
3. **Build failures**: Check [BLINK_INTEGRATION.md](BLINK_INTEGRATION.md) troubleshooting section
4. **Runtime crashes**: Verify entitlements are properly signed

### Signing Errors

- Make sure you have a valid Apple Developer account
- Check that your development team is selected in Xcode
- Verify provisioning profiles are up to date

## License

This project structure is provided as-is for building iOS applications.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
