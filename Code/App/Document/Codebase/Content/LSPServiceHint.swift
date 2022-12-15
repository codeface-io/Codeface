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
                Text("To see symbols and dependencies, you must (setup and) launch LSPService before importing code.")
            }
            icon:
            {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(NSColor.systemYellow))
            }
            
            Label
            {
                Text("LSPService automatically detects SourceKit-LSP when Xcode is installed, but SourceKit-LSP does NOT support Xcode projects – only Swift packages.")
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
