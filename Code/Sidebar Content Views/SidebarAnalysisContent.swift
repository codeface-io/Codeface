import SwiftUI
import CodefaceCore

struct SidebarAnalysisContent: View
{
    var body: some View
    {
        switch analysisVM.analysisState
        {
        case .succeeded(let rootArtifact):
            SidebarArtifactList(analysisVM: analysisVM,
                        rootArtifact: rootArtifact)
            .searchable(text: $searchTerm,
                        placement: .toolbar,
                        prompt: searchPrompt)
            .onSubmit(of: .search)
            {
                analysisVM.isTypingSearch = false
            }
            .onChange(of: searchTerm)
            {
                [searchTerm] newSearchTerm in
                
                guard searchTerm != newSearchTerm else { return }
                
                withAnimation(.easeInOut)
                {
                    analysisVM.userChanged(searchTerm: newSearchTerm)
                }
            }
            .onReceive(analysisVM.$isTypingSearch)
            {
                if $0 { searchTerm = analysisVM.appliedSearchTerm ?? "" }
            }
            
        case .running(let step):
            VStack
            {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(.bottom)
                
                Text("Loading " + analysisVM.projectName)
                
                Text(step.rawValue)
                    .foregroundColor(.secondary)
            }
            .padding()
        case .stopped:
            Text("Project analysis has been stopped without error. Maybe you wanna try reloading.")
                .padding()
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
        "Search in \(analysisVM.selectedArtifact?.codeArtifact.name ?? "Selected Artifact")"
    }
    
    @State private var searchTerm = ""
    
    @ObservedObject var analysisVM: ProjectProcessorViewModel
}
