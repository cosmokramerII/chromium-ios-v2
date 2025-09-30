# Building Chromium iOS

This guide provides detailed instructions for building the Chromium iOS app and creating an IPA file.

## Prerequisites

### Required Software
- **macOS** 12.0 (Monterey) or later
- **Xcode** 14.0 or later
- **Xcode Command Line Tools**
- **Apple Developer Account** (for code signing)

### Installing Xcode

1. Download Xcode from the Mac App Store
2. Open Xcode and accept the license agreement
3. Install Command Line Tools:
   ```bash
   xcode-select --install
   ```

## Setting Up Code Signing

Before you can build an IPA, you need to configure code signing:

### 1. Add Your Apple ID to Xcode

1. Open Xcode
2. Go to **Xcode > Settings... > Accounts**
3. Click the **+** button at the bottom left
4. Sign in with your Apple ID
5. Select your account and click **Manage Certificates...**
6. Click **+** and select **Apple Development** or **iOS Distribution**

### 2. Configure the Project

1. Open `ChromiumApp/ChromiumApp.xcodeproj` in Xcode
2. Select the **ChromiumApp** project in the navigator
3. Select the **ChromiumApp** target
4. Go to the **Signing & Capabilities** tab
5. Check **Automatically manage signing**
6. Select your **Team** from the dropdown

### 3. Update Bundle Identifier (if needed)

If you get signing errors, you may need to change the bundle identifier:

1. In the same **Signing & Capabilities** tab
2. Change **Bundle Identifier** from `org.chromium.chrome.ios.dev` to something unique like `com.yourname.chromium`

## Building with the Build Script

The easiest way to build an IPA is using the provided build script:

```bash
# Make sure you're in the repository root
cd chromium-ios-v2

# Run the build script
./build.sh
```

### What the Build Script Does

1. Checks for macOS and Xcode
2. Cleans previous builds
3. Builds and archives the app
4. Creates an `ExportOptions.plist` if needed
5. Exports the IPA file
6. Copies the IPA to the repository root as `chromium.ipa`

### Updating ExportOptions.plist

After the first run, you'll need to update `ChromiumApp/ExportOptions.plist`:

1. Find your Team ID in Xcode (Settings > Accounts > your account > Manage Certificates)
2. Edit `ExportOptions.plist`
3. Replace `YOUR_TEAM_ID` with your actual Team ID

## Building Manually in Xcode

If you prefer to build manually:

### For Testing on Your Device

1. Connect your iOS device to your Mac
2. Open `ChromiumApp/ChromiumApp.xcodeproj`
3. Select your device from the device menu
4. Click the **Run** button (▶️) or press ⌘R
5. The app will build and install on your device

### For Creating an IPA

1. Open `ChromiumApp/ChromiumApp.xcodeproj`
2. Select **Any iOS Device (arm64)** as the destination
3. Go to **Product > Archive**
4. Wait for the archive to complete
5. In the Organizer window:
   - Click **Distribute App**
   - Choose distribution method:
     - **Ad Hoc** - for personal use and testing
     - **App Store Connect** - for App Store submission
     - **Development** - for development devices
   - Follow the wizard to export the IPA

## Building from Command Line

You can also build directly using `xcodebuild`:

### Build Only (no IPA)

```bash
cd ChromiumApp
xcodebuild -project ChromiumApp.xcodeproj \
           -scheme ChromiumApp \
           -configuration Release \
           -sdk iphoneos \
           build
```

### Create Archive

```bash
cd ChromiumApp
xcodebuild -project ChromiumApp.xcodeproj \
           -scheme ChromiumApp \
           -configuration Release \
           -archivePath build/ChromiumApp.xcarchive \
           -sdk iphoneos \
           archive
```

### Export IPA

```bash
cd ChromiumApp
xcodebuild -exportArchive \
           -archivePath build/ChromiumApp.xcarchive \
           -exportPath build \
           -exportOptionsPlist ExportOptions.plist
```

## Troubleshooting

### "No signing certificate found"

**Solution:**
1. Open Xcode Settings > Accounts
2. Select your Apple ID
3. Click "Manage Certificates"
4. Click "+" and add "Apple Development" certificate

### "Unable to install..."

**Solution:**
1. Go to iOS device Settings > General > VPN & Device Management
2. Trust your developer certificate

### "Build input file cannot be found"

**Solution:**
1. Clean build folder: Product > Clean Build Folder (⇧⌘K)
2. Delete derived data: rm -rf ~/Library/Developer/Xcode/DerivedData/*
3. Try building again

### "Provisioning profile doesn't match"

**Solution:**
1. Change bundle identifier to something unique
2. Delete old provisioning profiles
3. Let Xcode generate new profiles automatically

## Distribution Methods

### Ad Hoc Distribution
- For testing on specific devices
- Up to 100 devices
- Requires device UDIDs to be registered

### App Store Distribution
- For public release via the App Store
- Requires App Store Connect account
- Must pass App Review

### Development Distribution
- Only for development devices
- Unlimited devices in development mode
- Easiest for personal use

### Enterprise Distribution
- For internal company distribution
- Requires Enterprise Developer Program ($299/year)
- No device limit

## Continuous Integration

The repository includes a GitHub Actions workflow (`.github/workflows/build.yml`) that can automatically build the app when you push code.

To use it:

1. Add repository secrets in GitHub:
   - `BUILD_CERTIFICATE_BASE64` - Your p12 certificate
   - `P12_PASSWORD` - Certificate password
   - `BUILD_PROVISION_PROFILE_BASE64` - Provisioning profile
   - `KEYCHAIN_PASSWORD` - Temporary keychain password

2. Push a tag to trigger a release build:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

## Next Steps

- Customize the app icon in `Assets.xcassets/AppIcon.appiconset`
- Update app name and version in Info.plist
- Add more features to ViewController.swift
- Configure capabilities (Push Notifications, etc.)

## Support

For issues specific to building iOS apps, refer to:
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Xcode Help](https://help.apple.com/xcode/)
