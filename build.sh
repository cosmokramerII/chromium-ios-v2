#!/bin/bash

# Build script for ChromiumIOSv2 (WebKit-based browser for iOS)
# Requires Xcode 15.0+ and iOS 14+ SDK

set -e

PROJECT_NAME="ChromiumIOSv2"
SCHEME_NAME="ChromiumIOSv2"
CONFIGURATION="Release"
SDK="iphoneos"
BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
IPA_PATH="$BUILD_DIR/$PROJECT_NAME.ipa"

echo "🚀 Building ChromiumIOSv2 (WebKit-based browser)..."

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found. Please install Xcode."
    echo "ℹ️  This script must be run on macOS with Xcode installed."
    exit 1
fi

# Check iOS SDK version
SDK_VERSION=$(xcodebuild -showsdks | grep iphoneos | tail -1 | sed 's/.*iphoneos//' | sed 's/[[:space:]]//g')
echo "📱 Using SDK: iphoneos$SDK_VERSION"

# Clean build directory
echo "🧹 Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build for device (archive)
echo "🏗️  Building archive for iOS devices..."
xcodebuild archive \
           -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration "$CONFIGURATION" \
           -archivePath "$ARCHIVE_PATH" \
           -sdk "$SDK" \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO \
           CODE_SIGNING_ALLOWED=NO \
           DEVELOPMENT_TEAM="" \
           PROVISIONING_PROFILE_SPECIFIER=""

echo "✅ Archive created successfully!"

# Export IPA
echo "📦 Exporting IPA..."

# Create export options plist for unsigned build
cat > "$BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF

# Note: For a signed IPA, you need to configure code signing in Xcode
# or provide a proper export options plist with signing identity and provisioning profile

xcodebuild -exportArchive \
           -archivePath "$ARCHIVE_PATH" \
           -exportPath "$BUILD_DIR" \
           -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" || {
    echo "⚠️  Export with signing failed. Creating unsigned IPA manually..."
    
    # Create unsigned IPA manually
    cd "$ARCHIVE_PATH/Products/Applications"
    mkdir -p Payload
    cp -r "$PROJECT_NAME.app" Payload/
    zip -r "../../../$PROJECT_NAME.ipa" Payload
    cd -
}

if [ -f "$IPA_PATH" ]; then
    echo "✅ IPA created successfully at: $IPA_PATH"
    echo "📊 IPA size: $(du -h "$IPA_PATH" | cut -f1)"
else
    echo "⚠️  IPA file not found at expected location"
    # Check if it was created with a different name
    IPA_FILE=$(find "$BUILD_DIR" -name "*.ipa" | head -1)
    if [ -n "$IPA_FILE" ]; then
        echo "✅ IPA found at: $IPA_FILE"
        echo "📊 IPA size: $(du -h "$IPA_FILE" | cut -f1)"
    else
        echo "❌ No IPA file was created"
    fi
fi

echo ""
echo "🎉 Build completed!"
echo ""
echo "📝 Note: To install this IPA on a device, you'll need:"
echo "   - A valid signing certificate and provisioning profile"
echo "   - Or use tools like AltStore, Sideloadly, or Xcode for installation"
echo ""
echo "🔧 To build with code signing:"
echo "   1. Open $PROJECT_NAME.xcodeproj in Xcode"
echo "   2. Select the project in the navigator"
echo "   3. Go to Signing & Capabilities tab"
echo "   4. Configure your Team and signing certificates"
echo "   5. Run this script again"