import SwiftUI

struct SearchBarView: View
{
    var body: some View
    {
        HStack // whole bar
        {
            HStack // field & button
            {
                SearchField(analysis: analysis, artifactName: artifactName)
                
                Button("Done")
                {
                    withAnimation(.easeInOut(duration: Search.toggleAnimationDuration))
                    {
                        analysis.set(searchBarIsVisible: false)
                    }
                    
                    withAnimation(.easeInOut(duration: Search.layoutAnimationDuration))
                    {
                        analysis.set(fieldIsFocused: false)
                    }
                }
                .focusable(false)
                .buttonStyle(.plain)
                .padding([.leading, .trailing])
                .frame(maxHeight: .infinity)
                .overlay
                {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.primary.opacity(0.2), lineWidth: 0.5)
                }
                .help("Hide the search filter (⇧⌘F)")
            }
            .font(.system(size: CentralViewStyle.fontSize))
            .frame(height: 29)
            .padding(.top, 1)
            .padding(.bottom, 6)
            .padding([.leading, .trailing])
        }
        .frame(height: analysis.search.barIsShown ? nil : 0)
        .clipShape(Rectangle())
    }
    
    @ObservedObject var analysis: CodebaseAnalysis
    
    let artifactName: String
}
