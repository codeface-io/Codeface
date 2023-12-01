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
                HStack(alignment: .firstTextBaseline)
                {
                    Text("LSPService is \(lspServiceIsRunning ? "running" : "not running yet")")
                    
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
                Image(systemName: lspServiceIsRunning ? "checkmark.diamond.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(Color(lspServiceIsRunning ? NSColor.systemGreen : NSColor.systemYellow))
            }
            
            Label
            {
                Text("To see symbols and dependencies, you must (setup and) launch LSPService before importing code.")
            }
            icon:
            {
                Image(systemName: "info.circle")
            }
            
            Label
            {
                Text("If you want to analyze a Swift codebase, note that Apple's LSP server (SourceKit-LSP) does NOT support Xcode projects – only Swift packages.")
            }
            icon:
            {
                Image(systemName: "info.circle")
            }
            
            DocumentLink.lspService
            
            DocumentLink.wiki
        }
        .task { await checkLSPService() }
    }
    
    private func checkLSPService() async
    {
        lspServiceIsRunning = await LSPService.isRunning()
    }
    
    @State private var lspServiceIsRunning = false
}
