import SwiftUI

struct PrimaryToolbarButtons: View
{
    var body: some View
    {
        if let analysis
        {
            Button(systemImageName: "magnifyingglass")
            {
                withAnimation(.easeInOut(duration: Search.toggleAnimationDuration))
                {
                    analysis.toggleSearchBar()
                }
            }
            .help("Toggle the Search Filter (⇧⌘F)")
            
            UpdatingDisplayModePicker(analysis: analysis)
            
            Button(systemImageName: "sidebar.right")
            {
                withAnimation
                {
                    analysis.showsRightSidebar.toggle()
                }
            }
            .help("Toggle Inspector (⌥⌘0)")
        }
    }
    
    private var analysis: CodebaseAnalysis?
    {
        codebaseProcessor.state.analysis
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
}

struct UpdatingDisplayModePicker: View
{
    var body: some View
    {
        DisplayModePicker(displayMode: $analysis.displayMode)
    }
    
    @ObservedObject var analysis: CodebaseAnalysis
}
