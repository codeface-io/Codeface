extension LSPServiceAPI.Language.Name
{
    func makeLSPWebSocket() throws -> LSPWebSocket
    {
        try LSPWebSocket(webSocket: makeWebSocket())
    }
}
