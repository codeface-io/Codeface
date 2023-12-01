import Foundation

func uploadBuild(of scheme: XcodeSchemeLocation,
                 withCredentials appStoreCredentials: AppStoreCredentials) throws {
    
    // MARK: Derived Inputs
    
    let project = "\(scheme.projectFolderPath)/\(scheme.projectName).xcodeproj"
    let uploadDirectory = "CI/Upload"
    let exportOptionsPlist = "\(uploadDirectory)/ExportOptions.plist"
    let byproductsDirectory = "\(uploadDirectory)/Byproducts"
    let archive = "\(byproductsDirectory)/\(scheme.projectName).xcarchive"
    let package = "\(byproductsDirectory)/\(scheme.projectName).pkg"
    
    // MARK: Run everything
    
    try deleteItem(at: byproductsDirectory) // Deleting all byproducts is optional
    
    try build(project: project,
              withScheme: scheme.name,
              asArchive: archive)
    
    try export(archive: archive,
               asPackage: package,
               exportOptionsPLIST: exportOptionsPlist)
    
    try upload(package: package,
               using: appStoreCredentials)
    
    print("🤖 Did upload \(package) to App Store Connect ✅")
}

struct XcodeSchemeLocation {
    let projectFolderPath: String
    let projectName: String
    let name: String
}

func build(project: String,
           withScheme scheme: String,
           asArchive archive: String) throws {
    print("🤖 Archiving \(project) to \(archive) ...")
    try deleteItem(at: archive)
    
    try run(command:
        """
        xcodebuild archive \
            -project \(project) \
            -archivePath \(archive) \
            -scheme \(scheme) \
            -sdk macosx \
            -destination 'platform=macOS,arch=arm64' \
            -destination 'platform=macOS,arch=x86_64' \
            -configuration Release \
            > /dev/null
        """
    )
}

func export(archive: String,
            asPackage package: String,
            exportOptionsPLIST: String) throws {
    print("🤖 Exporting \(archive) as \(package) ...")
    try deleteItem(at: package)
    let exportPath = URL(filePath: package).deletingLastPathComponent().relativePath
    
    try run(command:
        """
        xcodebuild -exportArchive \
            -archivePath \(archive) \
            -exportPath "\(exportPath)" \
            -exportOptionsPlist \(exportOptionsPLIST) \
            > /dev/null
        """
    )
}

func upload(package: String,
            using credentials: AppStoreCredentials) throws {
    print("🤖 Uploading \(package) to App Store Connect ...")
    
    try run(command: 
        """
        xcrun altool --upload-app \
            --type macos \
            --file \(package) \
            --username \(credentials.username) \
            --password \(credentials.password) \
            > /dev/null
        """
    )
}
