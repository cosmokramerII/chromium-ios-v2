# Chromium for iOS

A minimal iOS browser application based on Chromium.

## Project Structure

```
chromium-ios-v2/
├── ChromiumApp/              # iOS app project
│   ├── ChromiumApp.xcodeproj # Xcode project file
│   └── ChromiumApp/          # Source code
│       ├── AppDelegate.swift
│       ├── SceneDelegate.swift
│       ├── ViewController.swift
│       ├── Info.plist
│       ├── Assets.xcassets/
│       └── Base.lproj/
├── build.sh                  # Build script for creating IPA
├── altstore-source.json      # AltStore metadata
└── Icon.png                  # App icon

```

## Requirements

- macOS with Xcode 14.0 or later
- iOS 13.0 or later for deployment
- Apple Developer account (for signing and distribution)

## Building the IPA

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

- Minimal iOS browser interface
- Based on iOS native WebKit
- Compatible with iOS 13.0+
- Supports both iPhone and iPad

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

### Signing Errors

- Make sure you have a valid Apple Developer account
- Check that your development team is selected in Xcode
- Verify provisioning profiles are up to date

## License

This project structure is provided as-is for building iOS applications.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
