# Chromium iOS Blink Integration - Quick Reference

## What This Repository Provides

This repository contains a **complete architectural framework** for integrating Chromium's Blink rendering engine into iOS, replacing WKWebView with direct Blink usage.

## Status: Architecture Ready ✅

- ✅ GN build configuration files
- ✅ C++ bridge layer for Blink integration
- ✅ Metal compositor for GPU rendering
- ✅ iOS app with browser UI
- ✅ Entitlements for JIT compilation
- ✅ Build scripts and documentation

## What You Get

### 1. Build Configuration (`args.gn`)
```gn
target_os = "ios"
use_blink = true
enable_webkit = false
use_metal = true
```

### 2. C++ Integration Layer
```
ios/chrome/browser/web/
├── blink_web_view_bridge.h/mm    - C++ wrapper for Blink WebView
├── blink_web_view_controller.h/mm - Objective-C++ wrapper
├── metal_compositor.h/mm          - Metal rendering compositor
└── web_state.h/mm                 - Web state management
```

### 3. iOS App
- Browser UI with address bar and navigation
- Metal rendering layer
- Swift + Objective-C++ integration
- Proper entitlements for JIT/GPU

## Architecture Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     iOS App (Swift)                         │
│  ┌──────────────────────────────────────────────────┐      │
│  │  ViewController.swift                            │      │
│  │  - Address bar                                    │      │
│  │  - Navigation controls                            │      │
│  │  - Browser UI                                     │      │
│  └──────────────────────────────────────────────────┘      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         v
┌─────────────────────────────────────────────────────────────┐
│            Objective-C++ Bridge Layer                       │
│  ┌──────────────────────────────────────────────────┐      │
│  │  BlinkWebViewController                          │      │
│  │  - Manages Metal layer                            │      │
│  │  - Bridges Swift to C++                           │      │
│  │  - Handles view lifecycle                         │      │
│  └──────────────────────────────────────────────────┘      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         v
┌─────────────────────────────────────────────────────────────┐
│                C++ Blink Bridge Layer                       │
│  ┌──────────────────────────────────────────────────┐      │
│  │  BlinkWebViewBridge                              │      │
│  │  - Wraps blink::WebView                          │      │
│  │  - Navigation (LoadURL, GoBack, etc)             │      │
│  │  - Input event handling                           │      │
│  └──────────────────────────────────────────────────┘      │
└────────────────────────┬────────────────────────────────────┘
                         │
        ┌────────────────┴────────────────┐
        │                                  │
        v                                  v
┌──────────────────┐              ┌──────────────────┐
│ Metal Compositor │              │   WebState       │
│                  │              │                  │
│ - GPU rendering  │              │ - Page state     │
│ - CAMetalLayer   │              │ - History        │
│ - Frame output   │              │ - Loading state  │
└──────────────────┘              └──────────────────┘
        │
        v
┌─────────────────────────────────────────────────────────────┐
│              Blink Rendering Engine                         │
│              (from Chromium source)                         │
│  ┌──────────────────────────────────────────────────┐      │
│  │  - HTML/CSS parsing                              │      │
│  │  - JavaScript execution (V8)                     │      │
│  │  - Layout engine                                  │      │
│  │  - Compositor (cc/)                               │      │
│  │  - Network stack (//net)                         │      │
│  └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## How to Build

### Option 1: App Shell Only (No Blink)
```bash
cd ChromiumApp
xcodebuild -project ChromiumApp.xcodeproj -scheme ChromiumApp
```
Shows UI structure without actual Blink rendering.

### Option 2: Full Blink Integration
```bash
# 1. Get Chromium source (~100GB, 4+ hours)
mkdir ~/chromium && cd ~/chromium
fetch ios
cd src && gclient sync

# 2. Build with Blink
export CHROMIUM_SRC=~/chromium/src
./build-blink.sh
```
Complete Chromium browser with Blink rendering.

## Key Files

| File | Purpose |
|------|---------|
| `out/ios/args.gn` | GN build arguments for Blink on iOS |
| `BUILD.gn` | Root build configuration |
| `.gn` | GN configuration root |
| `ios/chrome/browser/web/BUILD.gn` | Blink integration build targets |
| `ios/chrome/browser/web/blink_web_view_bridge.h` | C++ Blink wrapper header |
| `ios/chrome/browser/web/blink_web_view_bridge.mm` | C++ Blink wrapper implementation |
| `ios/chrome/browser/web/metal_compositor.h` | Metal rendering header |
| `ios/chrome/browser/web/metal_compositor.mm` | Metal rendering implementation |
| `ChromiumApp/Entitlements.plist` | JIT/Metal entitlements |
| `ChromiumApp/ChromiumApp/Info.plist` | App configuration with entitlements |
| `build-blink.sh` | Automated build script |
| `BLINK_INTEGRATION.md` | Detailed integration guide |

## Requirements

### For App Shell
- macOS with Xcode 14+
- iOS 13.0+ device/simulator

### For Full Blink Build
- macOS 13.0+ (Ventura)
- Xcode 15.0+
- 100GB+ free disk space
- 16GB+ RAM
- Python 3.8+
- depot_tools (GN, Ninja)
- 4-6 hours for initial build

## Entitlements Required

```xml
<!-- For V8 JavaScript JIT -->
<key>com.apple.security.cs.allow-jit</key>
<true/>

<!-- For Blink dynamic code -->
<key>com.apple.security.cs.allow-unsigned-executable-memory</key>
<true/>

<!-- For Metal GPU -->
<key>com.apple.developer.metal</key>
<true/>
```

## Implementation Status

### ✅ Complete
- Build system configuration (GN)
- C++ bridge architecture
- Metal compositor structure
- iOS app UI
- Documentation
- Entitlements configuration

### ⚠️ Mock/Stub
- Actual Blink linking (requires Chromium source)
- Blink API calls (stubbed for demonstration)
- Network integration (needs //net)
- V8 initialization (needs Chromium build)

### 📝 To Complete
1. Build with full Chromium source tree
2. Link against actual Blink libraries
3. Implement real network stack integration
4. Add tab management
5. Implement settings/preferences
6. Add bookmark/history support

## Next Steps

1. **Test Current Build**: Build the iOS app to see UI structure
2. **Get Chromium Source**: If building with Blink, fetch source
3. **Run Build**: Execute `build-blink.sh` with Chromium source
4. **Sign and Deploy**: Code sign and install on device
5. **Test**: Verify browser functionality

## Documentation

- **[BLINK_INTEGRATION.md](BLINK_INTEGRATION.md)** - Complete integration guide
- **[BUILDING.md](BUILDING.md)** - General build instructions
- **[README.md](README.md)** - Project overview

## Support

- Review documentation files
- Check Chromium iOS build instructions
- Consult Blink renderer documentation

## License

BSD-style license (follows Chromium project licensing)
