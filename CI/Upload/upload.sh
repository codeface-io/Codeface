#!/bin/zsh

# Specify inputs

PROJECT="XcodeProject/Codeface.xcodeproj"
SCHEME="Codeface"
UPLOAD_DIRECTORY="CI/Upload"
EXPORT_OPTIONS_PLIST="$UPLOAD_DIRECTORY/ExportOptions.plist"

# Specify byproducts

ARCHIVE="$UPLOAD_DIRECTORY/Byproducts/Codeface.xcarchive"
PACKAGE="$UPLOAD_DIRECTORY/Byproducts/Codeface.pkg"

# set "exit immediately" (this script terminates when any command returns non-zero)

set -e 

# Read credentials from arguments

if [ $# -ne 2 ] # if the number of arguments is not equal 2
then
  echo "Usage: $0 <username> <password>"
  exit 1
fi

APP_STORE_USER="$1"
APP_STORE_PASSWORD="$2"

# Declare a function for each step 

function archiveTheProject {
    echo "🤖 Archiving $PROJECT to $ARCHIVE ..."
    rm -R $ARCHIVE
    xcodebuild archive \
        -project $PROJECT \
        -archivePath $ARCHIVE \
        -scheme $SCHEME \
        -sdk macosx \
        -destination 'platform=macOS,arch=arm64' \
        -destination 'platform=macOS,arch=x86_64' \
        -configuration Release \
        > /dev/null
}

function exportTheArchive {
    echo "🤖 Exporting $ARCHIVE to $PACKAGE ..."
    rm -R $PACKAGE
    xcodebuild -exportArchive \
        -archivePath $ARCHIVE \
        -exportPath $PACKAGE \
        -exportOptionsPlist $EXPORT_OPTIONS_PLIST \
        > /dev/null  
}

function uploadTheExport {
    echo "🤖 Uploading $PACKAGE to App Store Connect ..."
    xcrun altool --upload-app \
        --type macos \
        --file "$PACKAGE" \
        --username "$APP_STORE_USER" \
        --password "$APP_STORE_PASSWORD" \
        > /dev/null
    echo "🤖 Did upload $PACKAGE to App Store Connect ✅"
}

# Run each step

archiveTheProject
exportTheArchive
uploadTheExport