import SwiftUI

extension XPCExecutable
{
    struct ClientView: View
    {
        var body: some View
        {
            Form
            {
                Button("Test Service")
                {
                    client.callServiceExample()
                }
            }
        }
    }
}

private let client = XPCExecutable.Client()
