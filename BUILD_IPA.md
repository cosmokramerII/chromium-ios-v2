# Building IPA for Chromium iOS v2

This guide explains how to build the IPA file for Chromium iOS v2.

## Prerequisites

### Required
- **macOS** (10.15 Catalina or later recommended)
- **Xcode** 15.0 or later
- **iOS SDK** 14.0 or later

### For Device Installation
- Apple Developer Account (free or paid)
- Valid signing certificate and provisioning profile
- OR: Tools like AltStore, Sideloadly, or similar

## Quick Build

### Option 1: Using the Build Script (Recommended)

```bash
./build.sh
```

This will:
1. Build the project in Release configuration
2. Create an archive
3. Export an IPA file to the `build/` directory

### Option 2: Using Xcode GUI

1. Open `ChromiumIOSv2.xcodeproj` in Xcode
2. Select "Any iOS Device (arm64)" as the destination
3. Go to Product → Archive
4. Once archived, click "Distribute App"
5. Choose distribution method (Development, Ad Hoc, or App Store)
6. Follow the export wizard

### Option 3: Manual xcodebuild Command

```bash
# Build archive
xcodebuild archive \
    -project ChromiumIOSv2.xcodeproj \
    -scheme ChromiumIOSv2 \
    -configuration Release \
    -archivePath build/ChromiumIOSv2.xcarchive \
    -sdk iphoneos

# Export IPA
xcodebuild -exportArchive \
    -archivePath build/ChromiumIOSv2.xcarchive \
    -exportPath build \
    -exportOptionsPlist ExportOptions.plist
```

## Code Signing

### For Personal/Testing Use (Free Account)

1. Open the project in Xcode
2. Select the project in the navigator
3. Go to "Signing & Capabilities" tab
4. Check "Automatically manage signing"
5. Select your Apple ID team
6. Build and install via Xcode

### For Distribution

1. Log in to [Apple Developer Portal](https://developer.apple.com)
2. Create an App ID for `org.chromium.chrome.ios.v2`
3. Create a Distribution Certificate
4. Create a Provisioning Profile
5. Download and install the certificate and profile
6. Configure signing in Xcode:
   - Uncheck "Automatically manage signing"
   - Select your Distribution certificate
   - Select your Provisioning Profile
7. Run the build script

## Installing the IPA

### Method 1: Using Xcode

1. Connect your iOS device
2. Open Xcode → Window → Devices and Simulators
3. Select your device
4. Drag and drop the IPA file onto the device

### Method 2: Using AltStore

1. Install [AltStore](https://altstore.io/)
2. Connect your device and computer to the same WiFi
3. Open AltStore on your device
4. Tap "+" and select the IPA file
5. Follow the installation prompts

### Method 3: Using Sideloadly

1. Download [Sideloadly](https://sideloadly.io/)
2. Connect your iOS device via USB
3. Drag the IPA file into Sideloadly
4. Enter your Apple ID
5. Click "Start"

### Method 4: Using Cydia Impactor (Legacy)

1. Download [Cydia Impactor](http://www.cydiaimpactor.com/)
2. Connect your device via USB
3. Drag the IPA file onto Cydia Impactor
4. Enter your Apple ID credentials

## Troubleshooting

### Build Errors

**Error: "No signing identity found"**
- Solution: Configure code signing in Xcode (see Code Signing section)

**Error: "The operation couldn't be completed"**
- Solution: Clean build folder (Product → Clean Build Folder) and try again

**Error: "SDK not found"**
- Solution: Install the latest Xcode from the Mac App Store

### Installation Errors

**Error: "Unable to install"**
- Solution: Check that your provisioning profile is valid and includes your device

**Error: "App not trusted"**
- Solution: Go to Settings → General → VPN & Device Management → Trust the developer

**Error: "Expired certificate"**
- Solution: Re-sign the IPA with a valid certificate

## Build Configurations

### Debug Build
```bash
xcodebuild -project ChromiumIOSv2.xcodeproj \
    -scheme ChromiumIOSv2 \
    -configuration Debug \
    -sdk iphonesimulator
```

### Release Build (Default)
```bash
./build.sh
```

## Advanced Options

### Creating Export Options Plist

Create a file named `ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string> <!-- or app-store, ad-hoc, enterprise -->
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>signingCertificate</key>
    <string>Apple Development</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>org.chromium.chrome.ios.v2</key>
        <string>YOUR_PROVISIONING_PROFILE_NAME</string>
    </dict>
</dict>
</plist>
```

### Continuous Integration

For automated builds, use fastlane:

```ruby
# Fastfile
lane :build do
  build_app(
    project: "ChromiumIOSv2.xcodeproj",
    scheme: "ChromiumIOSv2",
    configuration: "Release",
    export_method: "development"
  )
end
```

## Additional Resources

- [Xcode Help](https://help.apple.com/xcode/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [iOS App Distribution Guide](https://developer.apple.com/distribute/)
- [Code Signing Guide](https://developer.apple.com/support/code-signing/)

## Support

For issues or questions:
1. Check the GitHub Issues page
2. Review the README.md for feature documentation
3. Check CRASH_FIXES.md for technical details

## License

This project follows the Chromium project licensing terms.
