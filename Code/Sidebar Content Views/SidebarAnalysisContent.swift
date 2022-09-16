import SwiftUI
import CodefaceCore

struct SidebarAnalysisContent: View
{
    var body: some View
    {
        switch processorVM.processorState
        {
        case .didLocateProject:
            Text("Project has been located but loading has not started yet.")
                .padding()
        case .retrievingProjectData(let step):
            VStack
            {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(.bottom)
                
                Text("Loading " + processorVM.projectDisplayName)
                
                Text(step.rawValue)
                    .foregroundColor(.secondary)
            }
            .padding()
        case .didRetrieveProjectData:
            Text("Project data has been retrieved but analysis has not started yet.")
                .padding()
        case .visualizingProjectArchitecture(let step):
            VStack
            {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(.bottom)
                
                Text("Analyzing " + processorVM.projectDisplayName)
                
                Text(step.rawValue)
                    .foregroundColor(.secondary)
            }
            .padding()
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
                Text("An error occured during analysis:")
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
