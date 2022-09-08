import Foundation
import SwiftLSP

public extension CodeFolder
{
    var looksLikeAPackage: Bool
    {
        url.lastPathComponent.lowercased().contains("package")
        || files.contains { $0.name.lowercased().contains("package") }
    }
    
    func forEachFile(visit: (CodeFile) async throws -> Void) async rethrows
    {
        for subfolder in subfolders
        {
            try await subfolder.forEachFile(visit: visit)
        }
        
        for file in files
        {
            try await visit(file)
        }
    }
}

extension CodeSymbolData
{
    func retrieveReferences(in enclosingFile: LSPDocumentUri,
                            from server: LSP.ServerCommunicationHandler) async throws
    {
        guard kind != .Namespace else
        {
            // TODO: sourcekit-lsp detects many wrong dependencies onto namespaces which are Swift extensions ...
            return
        }
        
        // TODO: contact sourcekit-lsp team about this, maybe open an issue on github ...
        // sourcekit-lsp suggests a few wrong references where there is one of those issues: a) extension of Variable -> Var namespace declaration (plain wrong) b) class Variable -> namespace Var (wrong direction) or c) all range properties are -1 (invalid)
        
        lspReferences = try await server.requestReferences(forSymbolSelectionRange: selectionRange,
                                                           in: enclosingFile)
    }
}

extension CodeSymbolData
{
    func traverseDepthFirst(_ visit: (CodeSymbolData) async throws -> Void) async rethrows
    {
        for child in children { try await child.traverseDepthFirst(visit) }
        try await visit(self)
    }
}

public class CodeFolder: Codable
{
    internal init(url: URL, files: [CodeFile], subfolders: [CodeFolder]) {
        self.url = url
        self.files = files
        self.subfolders = subfolders
    }
    
    public let url: URL
    public let files: [CodeFile]
    public let subfolders: [CodeFolder]
}
