import SwiftUI
import FoundationToolz
import SwiftyToolz

extension XPCExecutable.Client
{
    struct TestView: View
    {
        var body: some View
        {
            Form
            {
                Button("Call XPC Service")
                {
                    callService()
                }
            }
        }
    }
}

private func callService()
{
    client.launchExecutable(with: .init(path: "/usr/bin/xcrun", arguments: ["sourcekit-lsp"]))
    {
        error in
        
        if let error
        {
            log("🛑 service failed to launch executable: " + error.readable.message)
        }
        else
        {
            log("✅ service did launch executable")
        }
    }
}

private let client = XPCExecutable.Client()
