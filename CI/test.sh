#!/bin/zsh

# Specify inputs

PROJECT="XcodeProject/Codeface.xcodeproj"
SCHEME="Codeface"

# Declare and run test function

function testTheProject {
    echo "🤖 Testing $PROJECT ..."
    xcodebuild clean build test \
        -project $PROJECT \
        -scheme $SCHEME \
        -sdk macosx \
        -destination 'platform=macOS,arch=arm64' \
        -configuration Debug \
        > /dev/null
}

testTheProject