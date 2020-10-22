extension LSPServiceAPI.Language.Name
{
    func connectToLSPWebSocket() throws -> LSPServiceWebSocket
    {
        try LSPServiceWebSocket(webSocket: connectToWebSocket())
    }
}
