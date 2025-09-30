#!/bin/bash

# Build script for creating an IPA from the Chromium iOS app
# This script must be run on macOS with Xcode installed

set -e

echo "Building Chromium for iOS..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: This script must be run on macOS"
    exit 1
fi

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo "Error: xcodebuild not found. Please install Xcode."
    exit 1
fi

# Set variables
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ChromiumApp"
PROJECT_NAME="ChromiumApp"
SCHEME="ChromiumApp"
ARCHIVE_PATH="$PROJECT_DIR/build/$SCHEME.xcarchive"
EXPORT_PATH="$PROJECT_DIR/build"
EXPORT_OPTIONS_PLIST="$PROJECT_DIR/ExportOptions.plist"

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf "$PROJECT_DIR/build"

# Build the project
echo "Building archive..."
cd "$PROJECT_DIR"
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME" \
           -configuration Release \
           -archivePath "$ARCHIVE_PATH" \
           -sdk iphoneos \
           -destination "generic/platform=iOS" \
           clean archive

# Create ExportOptions.plist if it doesn't exist
if [ ! -f "$EXPORT_OPTIONS_PLIST" ]; then
    cat > "$EXPORT_OPTIONS_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
EOF
    echo "Created ExportOptions.plist - please update YOUR_TEAM_ID with your Apple Developer Team ID"
fi

# Export IPA
echo "Exporting IPA..."
xcodebuild -exportArchive \
           -archivePath "$ARCHIVE_PATH" \
           -exportPath "$EXPORT_PATH" \
           -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"

echo "Build complete!"
echo "IPA location: $EXPORT_PATH/$SCHEME.ipa"

# Copy IPA to repository root
if [ -f "$EXPORT_PATH/$SCHEME.ipa" ]; then
    cp "$EXPORT_PATH/$SCHEME.ipa" "$(dirname "$PROJECT_DIR")/chromium.ipa"
    echo "IPA copied to repository root as chromium.ipa"
fi
