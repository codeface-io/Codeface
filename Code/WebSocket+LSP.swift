import FoundationToolz
import Foundation
import SwiftyToolz

/// WebSocket with LSP in general. This shall be independent of the LSPBindings Library.
extension WebSocket
{
    func send<LSPMessage: Encodable>(lspMessage: LSPMessage)
    {
        send(LSP.makeFrame(withContent: lspMessage.encode()!))
        {
            $0.forSome { log($0) }
        }
    }
}
