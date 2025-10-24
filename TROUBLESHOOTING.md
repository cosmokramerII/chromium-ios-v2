# Troubleshooting Guide

This guide helps resolve common issues when building and integrating Chromium iOS with Blink.

## Table of Contents
- [Build System Issues](#build-system-issues)
- [Compilation Errors](#compilation-errors)
- [Runtime Issues](#runtime-issues)
- [Integration Problems](#integration-problems)
- [Performance Issues](#performance-issues)

## Build System Issues

### GN Configuration Errors

#### Problem: "Cannot find buildconfig file"
```bash
ERROR: Cannot find //build/config/BUILDCONFIG.gn
```

**Solution:**
Ensure you're building from within the Chromium source tree:
```bash
# Correct location
cd ~/chromium/src
gn gen out/ios

# If building standalone (not recommended)
export CHROMIUM_SRC=~/chromium/src
./build-blink.sh
```

#### Problem: "use_blink is not defined"
```bash
ERROR: Assignment had no effect: use_blink = true
```

**Solution:**
This variable may not exist in older Chromium versions. Check your Chromium version:
```bash
cd ~/chromium/src
git log --oneline -1
```
Ensure you're using a recent version that supports iOS builds.

### Ninja Build Failures

#### Problem: "Missing dependency: //third_party/blink/..."
```bash
ERROR: no such target: //third_party/blink/public/web
```

**Solution:**
Sync Chromium dependencies:
```bash
cd ~/chromium/src
gclient sync
```

#### Problem: Build takes too long (>6 hours)
**Solution:**
1. Use more CPU cores:
   ```bash
   ninja -C out/ios -j 8 chrome_public_bundle
   ```
2. Enable component builds (faster rebuilds):
   ```gn
   # In args.gn
   is_component_build = true
   ```
3. Use ccache for caching:
   ```bash
   brew install ccache
   export CCACHE_DIR=~/.ccache
   ```

## Compilation Errors

### C++ Header Issues

#### Problem: "blink/public/web/web_view.h: No such file"
```cpp
error: 'blink/public/web/web_view.h' file not found
```

**Solution:**
This is expected in the mock implementation. To use real Blink:
1. Build the full Chromium source
2. Link against `//third_party/blink/public/web`
3. Replace mock implementations with actual Blink API calls

The current implementation is a **framework/architecture demonstration**.

#### Problem: "base/logging.h: No such file"
```cpp
error: 'base/logging.h' file not found
```

**Solution:**
Ensure Chromium's base library is built:
```bash
ninja -C out/ios base
```

### Objective-C++ Issues

#### Problem: "Use of undeclared identifier 'gfx'"
```objc
error: use of undeclared identifier 'gfx'
```

**Solution:**
Add dependency in BUILD.gn:
```gn
deps = [
  "//ui/gfx",
  "//ui/gfx/geometry",
]
```

#### Problem: "ARC forbids explicit message send of 'release'"
```objc
error: ARC forbids explicit message send of 'release'
```

**Solution:**
Use `__bridge_retained` and `CFRelease` for C++ ownership:
```objc
metal_device_ = (__bridge_retained void*)device;
// Later:
CFRelease(metal_device_);
```

### Swift Bridging Issues

#### Problem: "Cannot find 'BlinkWebViewController' in scope"
```swift
error: cannot find 'BlinkWebViewController' in scope
```

**Solution:**
Create bridging header:
```objc
// ChromiumApp-Bridging-Header.h
#import "ios/chrome/browser/web/blink_web_view_controller.h"
```

Update Xcode project settings:
- Build Settings → Objective-C Bridging Header
- Set to: `$(PROJECT_DIR)/ChromiumApp/ChromiumApp-Bridging-Header.h`

## Runtime Issues

### Metal Compositor Errors

#### Problem: "Failed to create Metal device"
```log
ERROR: Failed to create Metal device - Metal may not be supported
```

**Solution:**
1. Check device support:
   ```swift
   import Metal
   if let device = MTLCreateSystemDefaultDevice() {
       print("Metal supported")
   }
   ```
2. Ensure Info.plist has Metal entitlement:
   ```xml
   <key>com.apple.developer.metal</key>
   <true/>
   ```
3. Test on physical device (Metal may not work in Simulator)

#### Problem: "Metal layer shows black screen"
```log
Metal compositor initialized but shows black screen
```

**Solution:**
1. Verify drawable size is set:
   ```objc
   layer.drawableSize = layer.bounds.size;
   ```
2. Check pixel format is supported:
   ```objc
   layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
   ```
3. Ensure frame is presented:
   ```objc
   [commandBuffer presentDrawable:drawable];
   [commandBuffer commit];
   ```

### Blink Initialization Errors

#### Problem: "Blink initialization failed"
```log
ERROR: Failed to initialize Blink WebView
```

**Solution:**
In the mock implementation, this indicates:
1. Invalid view size (width or height <= 0)
2. Check view constraints and layout

In a real implementation with Chromium source:
1. Ensure Blink platform is initialized:
   ```cpp
   blink::Platform::Initialize(platform_impl.get());
   ```
2. Check V8 initialization
3. Verify compositor threading is set up

### JIT Compilation Errors

#### Problem: "JIT compilation not supported"
```log
V8 JIT compilation failed
```

**Solution:**
1. Verify entitlements in Info.plist:
   ```xml
   <key>com.apple.security.cs.allow-jit</key>
   <true/>
   ```
2. Code sign with entitlements:
   ```bash
   codesign --force --sign "Apple Development" \
            --entitlements Entitlements.plist \
            ChromiumApp.app
   ```
3. For distribution, you may need:
   - Enterprise certificate
   - Provisioning profile with JIT entitlement
   - Or use jitless mode: `v8_enable_jitless = true`

## Integration Problems

### Xcode Project Issues

#### Problem: "File not found: blink_web_view_controller.mm"
```log
error: file not found: ios/chrome/browser/web/blink_web_view_controller.mm
```

**Solution:**
1. Ensure files are in correct location
2. Add to Xcode project:
   - Right-click project → Add Files
   - Select files from `ios/chrome/browser/web/`
   - Check "Copy items if needed"
   - Add to target

#### Problem: "Undefined symbols for architecture arm64"
```log
Undefined symbols for architecture arm64:
  "_OBJC_CLASS_$_BlinkWebViewController"
```

**Solution:**
1. Add .mm files to "Compile Sources" build phase
2. Check target membership for all files
3. Ensure C++ standard library is linked:
   - Build Settings → Other Linker Flags → Add `-lc++`

### Framework Search Paths

#### Problem: "Framework not found: Chromium"
```log
ld: framework not found Chromium
```

**Solution:**
Set framework search paths in Xcode:
```bash
FRAMEWORK_SEARCH_PATHS = $(inherited) ~/chromium/src/out/ios
```

Or via xcodebuild:
```bash
xcodebuild -project ChromiumApp.xcodeproj \
           FRAMEWORK_SEARCH_PATHS="~/chromium/src/out/ios"
```

## Performance Issues

### High Memory Usage

#### Problem: App uses >500MB RAM
```log
Memory Warning: 600MB used
```

**Solution:**
1. Enable symbol stripping in args.gn:
   ```gn
   symbol_level = 0
   strip_absolute_paths_from_debug_symbols = true
   ```
2. Use release build:
   ```gn
   is_debug = false
   is_official_build = true
   ```
3. Monitor with Instruments:
   ```bash
   open -a Instruments
   # Select "Leaks" or "Allocations" template
   ```

### Slow Startup Time

#### Problem: App takes >5 seconds to start
```log
App launch time: 6.2 seconds
```

**Solution:**
1. Profile with Time Profiler in Instruments
2. Delay Blink initialization:
   ```swift
   DispatchQueue.global(qos: .userInitiated).async {
       self.initializeBlink()
   }
   ```
3. Use lazy initialization
4. Cache Blink platform initialization

### Low Frame Rate

#### Problem: Rendering at <30 FPS
```log
Frame rate: 24 FPS (target: 60 FPS)
```

**Solution:**
1. Enable GPU acceleration in Metal compositor
2. Profile with GPU Driver template in Instruments
3. Reduce overdraw:
   ```gn
   # In args.gn
   enable_paint_preview = false
   ```
4. Use vsync:
   ```objc
   layer.displaySyncEnabled = YES;
   ```

## Validation and Testing

### Run Configuration Validator
```bash
./validate-config.sh
```

This checks:
- All required files exist
- Build configuration is correct
- Syntax is valid
- Entitlements are set

### Check Build Output
```bash
# List build artifacts
ls -lh out/ios/*.app

# Verify code signing
codesign -d -vv out/ios/ChromiumApp.app

# Check entitlements
codesign -d --entitlements - out/ios/ChromiumApp.app
```

### Debug Logging
Enable verbose logging:
```bash
# In C++ code
LOG(INFO) << "Detailed message";
LOG(WARNING) << "Warning message";
LOG(ERROR) << "Error message";

# Run with logging
./ChromiumApp --enable-logging --v=1
```

## Getting Help

### Check Logs
1. **Build logs**: `out/ios/build.log`
2. **Runtime logs**: Use Console.app on macOS
3. **Crash logs**: `~/Library/Logs/DiagnosticReports/`

### Useful Commands
```bash
# Check Chromium version
git -C ~/chromium/src log --oneline -1

# Verify GN configuration
gn args out/ios --list

# Check build targets
gn ls out/ios

# Describe specific target
gn desc out/ios //ios/chrome/browser/web:web
```

### Common Issues Checklist
- [ ] Using correct Chromium version (recent iOS build)
- [ ] All dependencies synced (`gclient sync`)
- [ ] Build files generated (`gn gen out/ios`)
- [ ] Correct architecture (arm64 for devices, x86_64 for simulator)
- [ ] Valid code signing certificate
- [ ] Entitlements properly configured
- [ ] Running on compatible iOS version (13.0+)
- [ ] Metal support available (physical device recommended)

### Resources
- [Chromium iOS Build Instructions](https://chromium.googlesource.com/chromium/src/+/main/docs/ios/build_instructions.md)
- [Blink Documentation](https://chromium.googlesource.com/chromium/src/+/main/third_party/blink/renderer/README.md)
- [Metal Programming Guide](https://developer.apple.com/metal/)
- [GN Reference](https://gn.googlesource.com/gn/+/main/docs/reference.md)

### Still Having Issues?
1. Check existing GitHub issues
2. Review build logs carefully
3. Verify all prerequisites are installed
4. Try a clean build:
   ```bash
   rm -rf out/ios
   gn gen out/ios
   ninja -C out/ios chrome_public_bundle
   ```

## Mock Implementation Notes

**Important**: This repository contains a **framework/architecture demonstration**.

The C++ bridge implementations are **mocked/stubbed** and will:
- ✅ Initialize successfully
- ✅ Accept commands (LoadURL, Resize, etc.)
- ✅ Return valid values
- ❌ NOT actually render web content
- ❌ NOT execute JavaScript
- ❌ NOT perform network requests

To enable actual Blink rendering:
1. Obtain full Chromium source tree (~100GB)
2. Build with `ninja -C out/ios chrome_public_bundle`
3. Link against compiled Blink libraries
4. Replace mock implementations with real Blink API calls

See [BLINK_INTEGRATION.md](BLINK_INTEGRATION.md) for complete integration steps.
