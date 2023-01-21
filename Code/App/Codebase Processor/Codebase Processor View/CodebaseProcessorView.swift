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

        case .processCodebase(_, let progressFeedback):
            LoadingProgressView(primaryText: progressFeedback.primaryText,
                                secondaryText: progressFeedback.secondaryText).padding()
            
        case .processArchitecture(_, _, let progressFeedback):
            LoadingProgressView(primaryText: progressFeedback.primaryText,
                                secondaryText: progressFeedback.secondaryText).padding()
            
        case .analyzeArchitecture(let analysis):
            CodebaseAnalysisView(analysis: analysis)
            
        case .didFail(let errorMessage):
            ProcessingFailureView(errorMessage: errorMessage).padding()
        }
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
}
