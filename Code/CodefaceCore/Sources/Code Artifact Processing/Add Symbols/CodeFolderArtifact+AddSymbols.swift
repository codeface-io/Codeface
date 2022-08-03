import SwiftLSP
import Foundation
import SwiftyToolz

public extension CodeFolderArtifact
{
    func addSymbolArtifacts(using server: LSP.ServerCommunicationHandler) async throws
    {
        for fileArtifact in files
        {
            try await fileArtifact.addSymbolArtifacts(using: server)
        }
        
        for subfolderArtifact in subfolders
        {
            try await subfolderArtifact.addSymbolArtifacts(using: server)
        }
    }
}
