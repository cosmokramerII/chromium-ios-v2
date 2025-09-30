# Building Chromium iOS with Blink Integration

This document describes how to build the Chromium iOS app with Blink rendering engine instead of WebKit.

## Overview

This repository contains the architectural framework for integrating Blink (Chromium's rendering engine) into an iOS application. The integration replaces WKWebView with direct Blink WebView usage, composited through Metal.

## Architecture

### Components

1. **GN Build System** (`out/ios/args.gn`)
   - Configures Chromium build for iOS with Blink enabled
   - Disables WebKit
   - Enables Metal rendering

2. **C++ Bridge Layer** (`ios/chrome/browser/web/`)
   - `blink_web_view_bridge.h/mm` - C++ wrapper for Blink WebView
   - `blink_web_view_controller.h/mm` - Objective-C++ wrapper for Swift/ObjC
   - `web_state.h/mm` - Web state management (like WebContents)
   - `metal_compositor.h/mm` - Metal rendering compositor

3. **Swift UI Layer** (`ChromiumApp/`)
   - `ViewController.swift` - Main browser UI with address bar and controls
   - `Info.plist` - Updated with JIT and Metal entitlements

4. **Build Configuration** (`BUILD.gn`)
   - Defines build targets for Blink integration
   - Links against Blink libraries
   - Configures frameworks and dependencies

## Prerequisites

### System Requirements
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Python 3.8+
- At least 100GB free disk space
- 16GB RAM minimum (32GB recommended)

### Required Tools
```bash
# Install depot_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PATH:${HOME}/depot_tools"

# Install Ninja
brew install ninja

# Install other dependencies
brew install pkg-config gnu-tar
```

## Getting the Chromium Source

```bash
# Create a directory for Chromium
mkdir ~/chromium && cd ~/chromium

# Fetch Chromium source (this takes several hours)
fetch ios

# This will create a 'src' directory with the full Chromium source
cd src

# Sync dependencies
gclient sync
```

## Integrating This Repository

```bash
# Copy the iOS Chrome integration files
cp -r path/to/chromium-ios-v2/ios/chrome/browser/web \
      ~/chromium/src/ios/chrome/browser/

# Copy the GN args
mkdir -p ~/chromium/src/out/ios
cp path/to/chromium-ios-v2/out/ios/args.gn \
   ~/chromium/src/out/ios/
```

## Build Steps

### 1. Configure the Build

```bash
cd ~/chromium/src

# Generate build files
gn gen out/ios --args="target_os=\"ios\" use_blink=true enable_webkit=false"

# Or use the provided args.gn file
gn gen out/ios
```

### 2. Build the Framework

```bash
# Build the iOS Chrome bundle with Blink
ninja -C out/ios chrome_public_bundle

# This will take 2-4 hours on first build
# Subsequent incremental builds are much faster
```

### 3. Build the App

After the Chromium components are built, you can build the iOS app:

```bash
cd path/to/chromium-ios-v2/ChromiumApp

# Build with xcodebuild
xcodebuild -project ChromiumApp.xcodeproj \
           -scheme ChromiumApp \
           -configuration Release \
           -sdk iphoneos \
           -derivedDataPath ./build \
           FRAMEWORK_SEARCH_PATHS="~/chromium/src/out/ios" \
           HEADER_SEARCH_PATHS="~/chromium/src" \
           archive
```

## Configuration Details

### args.gn Settings

Key settings in `out/ios/args.gn`:

```gn
target_os = "ios"              # Target iOS platform
target_cpu = "arm64"           # Build for ARM64 (iPhone/iPad)
use_blink = true               # Enable Blink rendering engine
enable_webkit = false          # Disable WebKit
use_metal = true               # Use Metal for GPU rendering
ios_deployment_target = "13.0" # Minimum iOS version
v8_enable_jitless = false      # Enable JIT for V8 (requires entitlement)
```

### Info.plist Entitlements

Required entitlements for Blink/V8 JIT:

```xml
<key>com.apple.security.cs.allow-jit</key>
<true/>
<key>com.apple.security.cs.allow-unsigned-executable-memory</key>
<true/>
<key>com.apple.developer.metal</key>
<true/>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Code Signing

### Development Build

```bash
# Sign with development certificate
codesign --force --sign "Apple Development: Your Name (TEAMID)" \
         --entitlements Entitlements.plist \
         --deep \
         path/to/ChromiumApp.app
```

### Create Entitlements File

Create `Entitlements.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.developer.metal</key>
    <true/>
</dict>
</plist>
```

## Deployment

### Sideloading

1. Build the IPA:
```bash
cd path/to/chromium-ios-v2
./build.sh
```

2. Install via Xcode:
```bash
# Connect device
xcrun devicectl device install app --device <DEVICE_ID> chromium.ipa
```

3. Or use AltStore/Sideloadly for installation

### Enterprise Distribution

For enterprise distribution without App Store:

1. Enroll in Apple Developer Enterprise Program
2. Create enterprise provisioning profile
3. Update `ExportOptions.plist` with enterprise settings
4. Build and distribute the IPA

## Troubleshooting

### "Blink not found" Errors

Make sure you've built the full Chromium source:
```bash
cd ~/chromium/src
ninja -C out/ios blink
```

### JIT Compilation Errors

Ensure entitlements are properly signed:
```bash
codesign -d --entitlements - path/to/App.app
```

### Metal Rendering Issues

Check Metal device availability:
```swift
let device = MTLCreateSystemDefaultDevice()
print("Metal supported: \(device != nil)")
```

### Build Size Too Large

The build will be very large (1-2GB) due to Blink inclusion. To reduce:
- Enable symbol stripping: `strip_symbols = true`
- Use release build: `is_debug = false`
- Enable optimizations: `is_official_build = true`

## Performance Considerations

### Memory Usage
- Blink requires more memory than WKWebView
- Minimum recommended: 2GB available RAM on device
- Use memory pressure monitoring

### Battery Impact
- Direct Blink integration may use more power
- Implement proper lifecycle management
- Suspend/resume compositor appropriately

### Startup Time
- First launch initializes Blink runtime (~2-3 seconds)
- Consider showing splash screen during initialization

## Differences from WKWebView

### Advantages
- Full Chromium feature set
- Better standards compliance
- Access to latest web APIs
- Same rendering as Chrome

### Challenges
- Larger binary size (100-200MB increase)
- Higher memory usage
- More complex build process
- Requires JIT entitlements (may limit distribution)

## Next Steps

1. **Optimize Build Size**
   - Strip unused Blink features
   - Enable code optimization
   - Use dynamic frameworks

2. **Add Browser Features**
   - Tab management
   - Bookmarks
   - History
   - Settings

3. **Implement Web Platform APIs**
   - Service Workers
   - WebRTC
   - WebAssembly
   - WebGL

4. **Testing**
   - Add unit tests for bridge layer
   - Integration tests for rendering
   - Performance benchmarks

## Resources

- [Chromium iOS Development](https://chromium.googlesource.com/chromium/src/+/main/docs/ios/build_instructions.md)
- [Blink Documentation](https://chromium.googlesource.com/chromium/src/+/main/third_party/blink/renderer/README.md)
- [Metal Programming Guide](https://developer.apple.com/metal/)
- [iOS App Distribution](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

## Support

For issues specific to this integration:
- Check existing GitHub issues
- Review Chromium iOS documentation
- Consult Blink rendering documentation

## License

This integration framework follows the Chromium project's BSD-style license.
