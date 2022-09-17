import SwiftUI
import CodefaceCore

struct SidebarAnalysisContent: View
{
    var body: some View
    {
        switch processorVM.processorState
        {
        case .didLocateCodebase:
            LoadingProgressView(primaryText: "Project Located",
                                secondaryText: "✅").padding()
        case .retrievingCodebase(let step):
            LoadingProgressView(primaryText: "Loading " + processorVM.codebaseDisplayName,
                                secondaryText: step.rawValue).padding()
        case .didRetrieveCodebase:
            LoadingProgressView(primaryText: "Project Data Complete",
                                secondaryText: "✅").padding()
        case .visualizingCodebaseArchitecture(let step):
            LoadingProgressView(primaryText: "Analyzing " + processorVM.codebaseDisplayName,
                                secondaryText: step.rawValue).padding()
        case .didVisualizeCodebaseArchitecture(_, let rootArtifact):
            SidebarArtifactList(analysisVM: processorVM, rootArtifact: rootArtifact)
                .searchable(text: $searchTerm,
                            placement: .toolbar,
                            prompt: searchPrompt)
                .onSubmit(of: .search)
            {
                processorVM.isTypingSearch = false
            }
            .onChange(of: searchTerm)
            {
                [searchTerm] newSearchTerm in
                
                guard searchTerm != newSearchTerm else { return }
                
                withAnimation(.easeInOut)
                {
                    processorVM.userChanged(searchTerm: newSearchTerm)
                }
            }
            .onReceive(processorVM.$isTypingSearch)
            {
                if $0 { searchTerm = processorVM.appliedSearchTerm ?? "" }
            }
        case .failed(let errorMessage):
            VStack(alignment: .leading)
            {
                Text("An error occured while loading the codebase:")
                    .foregroundColor(Color(NSColor.systemRed))
                    .padding(.bottom)
                
                Text(errorMessage)
            }
            .padding()
        }
    }
    
    private var searchPrompt: String
    {
        "Search in \(processorVM.selectedArtifact?.codeArtifact.name ?? "Selected Artifact")"
    }
    
    @State private var searchTerm = ""
    
    @ObservedObject var processorVM: ProjectProcessorViewModel
}
