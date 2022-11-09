import SwiftUI

struct LSPXPCServicePOC: View {
    var body: some View {
        Form {
            Button("Test Service") {
                client.callServiceExample()
            }
        }
    }
}

private let client = LSPXPCServiceClient()
