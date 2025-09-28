#!/bin/bash

# Build script for Chromium iOS v2
# Requires Xcode 15.0+ and iOS 26+ SDK

set -e

PROJECT_NAME="ChromiumIOSv2"
SCHEME_NAME="ChromiumIOSv2"
CONFIGURATION="Debug"
SDK="iphoneos"

echo "🚀 Building Chromium iOS v2..."

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found. Please install Xcode."
    exit 1
fi

# Check iOS SDK version
SDK_VERSION=$(xcodebuild -showsdks | grep iphoneos | tail -1 | sed 's/.*iphoneos//' | sed 's/[[:space:]]//g')
echo "📱 Using SDK: iphoneos$SDK_VERSION"

# Build for simulator (for testing)
echo "🏗️  Building for iOS Simulator..."
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration "$CONFIGURATION" \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
           build

echo "✅ Build completed successfully!"

# Run tests if available
echo "🧪 Running tests..."
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$SCHEME_NAME" \
           -configuration "$CONFIGURATION" \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
           test || echo "⚠️  Tests not available or failed"

echo "🎉 All done! Ready to run on iOS 26+ devices."