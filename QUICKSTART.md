# Quick Start Guide

Get up and running with Chromium iOS in minutes!

## For Users - Installing the App

### Option 1: Using AltStore (Recommended for Non-Developers)

1. Install [AltStore](https://altstore.io/) on your iPhone/iPad
2. Add this source to AltStore:
   ```
   https://raw.githubusercontent.com/cosmokramerII/chromium-ios-v2/master/altstore-source.json
   ```
3. Browse and install Chromium from AltStore

### Option 2: From Pre-built IPA

1. Download the IPA from [Releases](https://github.com/cosmokramerII/chromium-ios-v2/releases)
2. Use a sideloading tool like:
   - AltStore
   - Sideloadly
   - Apple Configurator (for Mac)
3. Install the IPA on your device

## For Developers - Building from Source

### Prerequisites

- Mac with macOS 12+ and Xcode 14+
- Apple Developer Account (free account works for personal use)

### Quick Build Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/cosmokramerII/chromium-ios-v2.git
   cd chromium-ios-v2
   ```

2. **Open in Xcode**
   ```bash
   open ChromiumApp/ChromiumApp.xcodeproj
   ```

3. **Configure Signing**
   - Select the ChromiumApp target
   - Go to "Signing & Capabilities"
   - Select your Team
   - Xcode will handle the rest automatically

4. **Build and Run**
   - Connect your iPhone/iPad via USB
   - Select your device from the device menu
   - Click the Run button (▶️)
   - The app will build and install on your device

### Building an IPA

```bash
# From repository root
./build.sh
```

The IPA will be created as `chromium.ipa` in the repository root.

For detailed instructions, see [BUILDING.md](BUILDING.md)

## What's Included

This repository contains:
- ✅ Complete Xcode project
- ✅ Swift source code
- ✅ Build scripts
- ✅ CI/CD workflow (GitHub Actions)
- ✅ AltStore distribution configuration
- ✅ Comprehensive documentation

## Need Help?

- Check [BUILDING.md](BUILDING.md) for detailed build instructions
- See [README.md](README.md) for project overview
- Report issues on [GitHub Issues](https://github.com/cosmokramerII/chromium-ios-v2/issues)

## Next Steps

- Customize the app (change icon, colors, features)
- Add more functionality to ViewController.swift
- Build and test on your device
- Share with friends via AltStore or direct IPA distribution

## Common Issues

**"Untrusted Developer" on iPhone**
- Go to Settings > General > VPN & Device Management
- Trust your developer certificate

**Build fails in Xcode**
- Clean build folder (Shift+Cmd+K)
- Make sure you selected your Team in signing settings

**Can't run on device**
- Check that your device is registered in your Apple Developer account
- Make sure your provisioning profile is valid

Happy building! 🚀
