import SwiftUI
import Foundation
import LSPServiceKit
import SwiftLSP

struct LSPServiceHint: View
{
    var body: some View
    {
        List
        {
            Label
            {
                Text("To see symbols and dependencies, you need to launch LSPService before importing code.")
            }
            icon:
            {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(NSColor.systemYellow))
            }
            
            Label
            {
                HStack(alignment: .firstTextBaseline)
                {
                    Text("LSPService is\(lspServiceIsRunning ? "" : " not") running")
                    
                    Button
                    {
                        Task
                        {
                            await checkLSPService()
                        }
                    }
                    label:
                    {
                        Label("Check Again", systemImage: "arrow.clockwise")
                    }
                }
            }
            icon:
            {
                Image(systemName: lspServiceIsRunning ? "checkmark.diamond.fill" : "xmark.octagon.fill")
                    .foregroundColor(Color(lspServiceIsRunning ? NSColor.systemGreen : NSColor.systemRed))
            }
            
            HelpLink.lspService
            
            HelpLink.documentation
        }
        .task { await checkLSPService() }
    }
    
    private func checkLSPService() async
    {
        lspServiceIsRunning = await LSPService.isRunning()
    }
    
    @State private var lspServiceIsRunning = false
}

struct HelpLink: View
{
    static let lspService = HelpLink("How to Setup LSPService",
                                     urlString: "https://codeface.io/lspservice/index.html")
    
    static let documentation = HelpLink("General Codeface Documentation",
                                        urlString: "https://codeface.io/documentation/index.html")
    
    init(_ text: String, urlString: String)
    {
        self.text = text
        self.url = URL(string: urlString)!
    }
    
    var body: some View
    {
        Link(destination: url)
        {
            Label(text, systemImage: "doc.text")
        }
    }
    
    private let text: String
    private let url: URL
}
