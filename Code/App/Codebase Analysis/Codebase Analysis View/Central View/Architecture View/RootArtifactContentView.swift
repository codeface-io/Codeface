import SwiftUI
import SwiftyToolz

struct RootArtifactContentView: View
{
    var body: some View
    {
        GeometryReader
        {
            geo in
            
            // LoggingText("geo.size: " + geo.size.debugDescription)
            
            Group
            {
                if let showsContent = artifactVM.showsContent
                {
                    if showsContent
                    {
                        ArtifactContentView(artifactVM: artifactVM,
                                            pathBar: analysis.pathBar,
                                            ignoreSearchFilter: analysis.search.fieldIsFocused,
                                            bgBrightness: colorScheme == .dark ? 0 : 0.6)
                        .drawingGroup()
                    }
                    else
                    {
                        Center
                        {
                            Text("Couldn't find a layout that fits within \(Int(geo.size.width))×\(Int(geo.size.height)) points")
                                .padding(.bottom)
                            
                            if geo.size.width >= 500, geo.size.height >= 500
                            {
                                Text("Since this view is reasonably large, inability to fit the visualization in it MIGHT indicate that the \(artifactVM.codeArtifact.kindName.lowercased()) \"\(artifactVM.displayName)\" could have more organizational structure or balance.\nIn other words: Its content of currently \(artifactVM.parts.count) parts could potentially be organized into fewer or more equally sized organizational units.")
                                    .foregroundColor(.secondary)
                            }
                            else
                            {
                                Text("Try to make the window larger or inspector and sidebar smaller.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    }
                }
                else
                {
                    Center
                    {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            }
            .onAppear
            {
                 print("attempt to layout artifact \(artifactVM.codeArtifact.name) in view size \(geo.size.size) because view appeared")
                
                artifactVM.updateLayout(forScopeSize: geo.size.size,
                                        ignoreSearchFilter: analysis.search.fieldIsFocused)
            }
            .onChange(of: geo.size)
            {
                didChangeSize(to: $0.size)
            }
            .onReceive(
                observableSize.$size
                    .debounce(for: .seconds(secondsUntilEndOfSizeChange),
                              scheduler: DispatchQueue.main)
            )
            {
                didEndChangingSize(newSize: $0)
            }
            .onChange(of: artifactVM)
            {
                newArtifact in
                
                 print("attempt to layout newly selected artifact \(newArtifact.codeArtifact.name)")
                
                newArtifact.updateLayout(forScopeSize: geo.size.size,
                                         ignoreSearchFilter: analysis.search.fieldIsFocused)
            }
        }
    }
    
    @ObservedObject var artifactVM: ArtifactViewModel
    var analysis: CodebaseAnalysis
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - React to View Size Changes
    
    private func didEndChangingSize(newSize: Size)
    {
        print("attempt to layout \(artifactVM.displayName) after size changed to \(newSize)")
        
        withAnimation(.easeInOut(duration: 1))
        {
            artifactVM.updateLayout(forScopeSize: newSize,
                                    ignoreSearchFilter: analysis.search.fieldIsFocused)
        }
    }
    
    private let secondsUntilEndOfSizeChange = 0.1
    
    private func didChangeSize(to newSize: Size)
    {
        observableSize.size = newSize
    }
    
    @StateObject private var observableSize = ObservableSize()
    
    private class ObservableSize: ObservableObject
    {
        @Published var size: Size = .zero
    }
}

extension CGSize
{
    var size: Size { .init(width, height) }
}
