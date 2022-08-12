import SwiftLSP
import Foundation
import SwiftyToolz

public extension CodeFolderArtifact
{
    func addSymbolArtifacts(using server: LSP.ServerCommunicationHandler) async throws
    {
        for part in partsByArtifactHash.values
        {
            switch part.kind
            {
            case .subfolder(let subfolder):
                try await subfolder.addSymbolArtifacts(using: server)
            case .file(let file):
                try await file.addSymbolArtifacts(using: server)
            }
        }
    }
}
