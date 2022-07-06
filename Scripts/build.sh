#! /bin/sh

xcodebuild archive \
-scheme WCKit \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/WCKit.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild archive \
-scheme WCKit \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/WCKit.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild archive \
-scheme WCKit \
-configuration Release \
-destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' \
-archivePath './build/WCKit.framework-catalyst.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
-framework './build/WCKit.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/WCKit.framework' \
-framework './build/WCKit.framework-iphoneos.xcarchive/Products/Library/Frameworks/WCKit.framework' \
-framework './build/WCKit.framework-catalyst.xcarchive/Products/Library/Frameworks/WCKit.framework' \
-output './build/WCKit.xcframework'
