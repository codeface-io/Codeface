import FoundationToolz

extension LSPServiceAPI.Language.Name
{
    func connectToLSPServer() throws -> LSPServerAsyncConnection
    {
        try LSPServerAsyncConnection(connection: connectToLSPWebSocket())
    }
}
