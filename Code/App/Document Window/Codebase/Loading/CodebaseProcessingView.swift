import SwiftUIToolzOLD
import SwiftUI
import CodefaceCore

struct CodebaseProcessingView: View
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
            CodebaseAnalysisView(rootArtifact: rootArtifact,
                                 codefaceDocument: codefaceDocument,
                                 processorVM: processorVM)
            
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
    
    @ObservedObject var codefaceDocument: DocumentWindow
    @ObservedObject var processorVM: ProjectProcessorViewModel
}
