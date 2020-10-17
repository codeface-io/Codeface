import FoundationToolz
import Foundation
import SwiftyToolz

extension WebSocket
{
    func send<LSPMessage: Encodable>(lspMessage: LSPMessage)
    {
        send(makeLSPFrame(withContent: lspMessage.encode()!))
        {
            $0.forSome { log($0) }
        }
    }
    
    private func makeLSPFrame(withContent content: Data) -> Data
    {
        log("Creating LSP base protocol frame with content:\n" + content.utf8String!)
        let header = "Content-Length: \(content.count)\r\n\r\n".data!
        return header + content
    }
}
