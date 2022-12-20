import SwiftUI
import FoundationToolz
import UniformTypeIdentifiers
import CodefaceCore

@available(macOS 11.0, *)
public struct CodebaseFileDocument: FileDocument, Codable
{
    // load from file
    public init(configuration: ReadConfiguration) throws
    {
        let selfData = try configuration.file.regularFileContents.unwrap()
        self = try CodebaseFileDocument(jsonData: selfData)
    }
    
    // write to file
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        // avoid white space from pretty printing, avoid escaping slashes
        .init(regularFileWithContents: try encode(options: .withoutEscapingSlashes))
    }
    
    // store optional codebase
    public init(codebase: CodeFolder? = nil)
    {
        self.codebase = codebase
    }
    
    public var codebase: CodeFolder?
    public static var readableContentTypes: [UTType] = [.codebase]
}

extension UTType
{
    static let codebase = UTType(exportedAs: "com.flowtoolz.codeface.codebase")
}
