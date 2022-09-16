import SwiftUI
import UniformTypeIdentifiers
import CodefaceCore

extension UTType
{
    static let codebase = UTType(exportedAs: "com.flowtoolz.codeface.codebase")
}

@available(macOS 11.0, *)
public struct CodebaseFileDocument: FileDocument
{
    public static var readableContentTypes: [UTType] = [.codebase]
    
    // load file
    public init(configuration: ReadConfiguration) throws
    {
        let codebaseData = try configuration.file.regularFileContents.unwrap()
        codebase = try CodeFolder(jsonData: codebaseData)
    }
    
    // write to file
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        .init(regularFileWithContents: try codebase.encodeForFileStorage())
    }
    
    public init(codebase: CodeFolder)
    {
        self.codebase = codebase
    }
    
    public let codebase: CodeFolder
}
