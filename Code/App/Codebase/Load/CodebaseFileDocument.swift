import SwiftUI
import FoundationToolz
import UniformTypeIdentifiers

@available(macOS 11.0, *)
struct CodebaseFileDocument: FileDocument, Codable
{
    // load from file
    init(configuration: ReadConfiguration) throws
    {
        let selfData = try configuration.file.regularFileContents.unwrap()
        self = try CodebaseFileDocument(jsonData: selfData)
    }
    
    // write to file
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper
    {
        // avoid white space from pretty printing, avoid escaping slashes
        .init(regularFileWithContents: try encode(options: .withoutEscapingSlashes))
    }
    
    // store optional codebase
    init(codebase: CodeFolder? = nil)
    {
        self.codebase = codebase
    }
    
    var codebase: CodeFolder?
    static var readableContentTypes: [UTType] = [.codebase]
}

extension UTType
{
    static let codebase = UTType(exportedAs: "com.flowtoolz.codeface.codebase")
}
