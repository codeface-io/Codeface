import SwiftUI
import CodefaceCore

struct SidebarAnalysisContent: View
{
    var body: some View
    {
        switch processorVM.processorState
        {
        case .didLocateProject:
            LoadingProgressView(primaryText: "Project Located",
                                secondaryText: "✅").padding()
        case .retrievingProjectData(let step):
            LoadingProgressView(primaryText: "Loading " + processorVM.projectDisplayName,
                                secondaryText: step.rawValue).padding()
        case .didRetrieveProjectData:
            LoadingProgressView(primaryText: "Project Data Complete",
                                secondaryText: "✅").padding()
        case .visualizingProjectArchitecture(let step):
            LoadingProgressView(primaryText: "Analyzing " + processorVM.projectDisplayName,
                                secondaryText: step.rawValue).padding()
        case .didVisualizeProjectArchitecture(_, let rootArtifact):
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
