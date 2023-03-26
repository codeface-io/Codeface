import SwiftUI
import SwiftyToolz

struct FindAndFilterMenuOptions: View
{
    var body: some View
    {
        Button("Find and Filter")
        {
            withAnimation(.easeInOut(duration: Search.toggleAnimationDuration))
            {
                analysis?.set(searchBarIsVisible: true)
            }
            
            withAnimation(.easeInOut(duration: Search.layoutAnimationDuration))
            {
                analysis?.set(fieldIsFocused: true)
            }
        }
        .disabled(analysis == nil)
        .keyboardShortcut("f")

        Button("Toggle the Search Filter")
        {
            guard let analysis else
            {
                log(warning: "When there's no analysis, this menu option shouldn't be displayed.")
                return
            }
            
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
        .disabled(analysis == nil)
        .keyboardShortcut("f", modifiers: [.shift, .command])
    }
    
    private var analysis: ArchitectureAnalysis?
    {
        codebaseProcessor.state.analysis
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
}
