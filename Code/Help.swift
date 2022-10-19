import SwiftUI
import Foundation
import LSPServiceKit
import SwiftLSP

struct LSPServiceHint: View
{
    var body: some View
    {
        if !serverManager.serverIsWorking
        {
            VStack(alignment: .center)
            {
                Label
                {
                    Text("To see symbols and dependencies, you must (setup and) launch LSPService before importing a code folder:")
                        .multilineTextAlignment(.center)
                }
                icon:
                {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(NSColor.systemYellow))
                }
                
                LSPServiceHintLink()
            }
            .frame(maxWidth: 500)
        }
    }
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
}

struct LSPServiceHintLink: View
{    
    init(_ text: String = "How to Setup LSPService")
    {
        self.text = text
    }
    
    var body: some View
    {
        Link(destination: url)
        {
            Label(text, systemImage: "doc.text")
        }
    }
    
    private let text: String
    private let url = URL(string: "https://codeface.io/lspservice/index.html")!
}
