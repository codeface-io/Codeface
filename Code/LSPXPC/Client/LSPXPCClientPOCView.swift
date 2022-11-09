import SwiftUI

struct LSPXPCClientPOCView: View {
    var body: some View {
        Form {
            Button("Test Service") {
                client.callServiceExample()
            }
        }
    }
}

private let client = LSPXPCClient()
