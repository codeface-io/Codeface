import SwiftUIToolzOLD
import SwiftUI

struct CodebaseProcessorView: View
{
    var body: some View
    {
        switch codebaseProcessor.state
        {
        case .empty:
            EmptyProcesorView()

        case .didLocateCodebase:
            LoadingProgressView(primaryText: "Project Located",
                                secondaryText: "✅").padding()
        
        case .retrieveCodebase(let message):
            LoadingProgressView(primaryText: "Loading Codebase Data",
                                secondaryText: message).padding()
            
        case .didJustRetrieveCodebase:
            LoadingProgressView(primaryText: "Codebase Loaded",
                                secondaryText: "✅").padding()

        case .processCodebase(_, let progressFeedback):
            LoadingProgressView(primaryText: progressFeedback.primaryText,
                                secondaryText: progressFeedback.secondaryText).padding()
            
        case .processArchitecture(_, _, let progressFeedback):
            LoadingProgressView(primaryText: progressFeedback.primaryText,
                                secondaryText: progressFeedback.secondaryText).padding()
            
        case .analyzeArchitecture(let analysis):
            CodebaseAnalysisView(analysis: analysis,
                                     displayOptions: displayOptions)
            
        case .didFail(let errorMessage):
            ProcessingFailureView(errorMessage: errorMessage).padding()
        }
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
    @ObservedObject var displayOptions: WindowDisplayOptions
}
