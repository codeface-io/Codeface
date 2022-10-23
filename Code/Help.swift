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
                    // TODO: use (alignment: .firstTextBaseline) on Ventura (https://stackoverflow.com/questions/72226626/baseline-alignment-of-buttons-in-swiftui-on-macos)
                    HStack {
                        Text("LSPService is\(lspServiceIsRunning ? "" : " not") running")
                        
                        Button {
                            checkLSPService()
                        } label: {
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
            .onAppear { checkLSPService() }
        }
    }
    
    private func checkLSPService() {
        Task {
            lspServiceIsRunning = await LSPService.isRunning()
        }
    }
    
    @State private var lspServiceIsRunning = false
    
    @ObservedObject private var serverManager = LSP.ServerManager.shared
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
