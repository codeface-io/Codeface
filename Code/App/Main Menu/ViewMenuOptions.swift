import SwiftUI

struct ViewButtons: View
{
    var body: some View
    {
        Button("\(displayOptions.showsLinesOfCode ? "Hide" : "Show") Lines of Code in Navigator")
        {
            displayOptions.showsLinesOfCode.toggle()
        }
        .keyboardShortcut("l", modifiers: .command)
        .disabled(analysis == nil)
        
        Button("\(displayOptions.showsLeftSidebar ? "Hide" : "Show") the Navigator")
        {
            withAnimation
            {
                displayOptions.showsLeftSidebar.toggle()
            }
        }
        .keyboardShortcut("0", modifiers: .command)
        .disabled(analysis == nil)

        Button("\(displayOptions.showsRightSidebar ? "Hide" : "Show") the Inspector")
        {
            withAnimation
            {
                displayOptions.showsRightSidebar.toggle()
            }
        }
        .keyboardShortcut("0", modifiers: [.option, .command])
        .disabled(analysis == nil)
        
        Button("\(displayOptions.showsSubscriptionPanel ? "Hide" : "Show") the Subscription Panel")
        {
            displayOptions.showsSubscriptionPanel.toggle()
        }
        .keyboardShortcut("s", modifiers: [.control, .command])
        .disabled(analysis == nil)
        
        Divider()
        
        Button("Switch to Next Display Mode")
        {
            analysis?.switchDisplayMode()
        }
        .keyboardShortcut(.rightArrow, modifiers: .command)
        .disabled(analysis == nil)

        Button("Switch to Previous Display Mode")
        {
            analysis?.switchDisplayMode()
        }
        .keyboardShortcut(.leftArrow, modifiers: .command)
        .disabled(analysis == nil)
    }
    
    private var analysis: CodebaseAnalysis?
    {
        codebaseProcessor.state.analysis
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
    @ObservedObject var displayOptions: WindowDisplayOptions
}
