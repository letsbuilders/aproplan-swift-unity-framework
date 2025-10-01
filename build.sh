#!/bin/bash
set -e   # exit immediately if any command fails

BUILD_DIR=.build
IOS_PROJECT=Unity/IOSDevice
SIM_PROJECT=Unity/IOSSimulator

xattr -rd com.apple.quarantine ${IOS_PROJECT}/
xattr -rd com.apple.quarantine ${SIM_PROJECT}/

build_project() {
    PROJECT_DIR=$1
    SDK=$2
    APP=$3

    xcodebuild build \
        -project "$PROJECT_DIR/Unity-iPhone.xcodeproj" \
        -scheme "Unity-iPhone" \
        -sdk $SDK \
        -configuration "Release" \
        -derivedDataPath ./$BUILD_DIR/$SDK \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        CODE_SIGNING_ALLOWED=NO

    OUT_PATH=./$BUILD_DIR/$SDK/Build/Products/Release-$SDK
    LIB_PATH=$OUT_PATH/UnityFramework.framework

    cp -R $OUT_PATH/$APP.app/Data $LIB_PATH
}

build_framework() {
    rm -rf ./Frameworks/UnityFramework.xcframework
    xcodebuild -create-xcframework \
        -framework ./$BUILD_DIR/iphoneos/Build/Products/Release-iphoneos/UnityFramework.framework \
        -framework ./$BUILD_DIR/iphonesimulator/Build/Products/Release-iphonesimulator/UnityFramework.framework \
        -output ./Frameworks/UnityFramework.xcframework
}

build_project ${IOS_PROJECT} iphoneos BimViewer
build_project ${SIM_PROJECT} iphonesimulator BimViewer

build_framework

zip -r -q ./Frameworks/UnityFramework.zip ./Frameworks/UnityFramework.xcframework
rm -rf ./Frameworks/UnityFramework.xcframework
