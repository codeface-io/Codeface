import SwiftLSP
import FoundationToolz

extension LSPServiceAPI.Language.Name
{
    func connectToLSPServer() throws -> LSP.ServerConnection
    {
        try LSP.ServerConnection(synchronousConnection: connectToLSPWebSocket())
    }
}
