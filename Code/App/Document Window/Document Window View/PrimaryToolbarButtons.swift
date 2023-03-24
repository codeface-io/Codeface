import SwiftUI

struct PrimaryToolbarButtons: View
{
    var body: some View
    {
        if let analysis
        {
            Button(systemImageName: "magnifyingglass")
            {
                let searchBarWillBeVisible = !analysis.search.barIsShown
                
                withAnimation(.easeInOut(duration: Search.toggleAnimationDuration))
                {
                    analysis.set(searchBarIsVisible: searchBarWillBeVisible)
                }
                
                withAnimation(.easeInOut(duration: Search.layoutAnimationDuration))
                {
                    analysis.set(fieldIsFocused: searchBarWillBeVisible)
                }
            }
            .help("Toggle the Search Filter (⇧⌘F)")
            
            UpdatingDisplayModePicker(analysis: analysis)
            
            Button(systemImageName: "sidebar.right")
            {
                withAnimation
                {
                    displayOptions.showsRightSidebar.toggle()
                }
            }
            .help("Toggle Inspector (⌥⌘0)")
        }
    }
    
    private var analysis: ArchitectureAnalysis?
    {
        codebaseProcessor.state.analysis
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
    @Binding var displayOptions: AnalysisDisplayOptions
}

struct UpdatingDisplayModePicker: View
{
    var body: some View
    {
        DisplayModePicker(displayMode: $analysis.displayMode)
    }
    
    @ObservedObject var analysis: ArchitectureAnalysis
}
