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

        case .retrievingCodebase(let step):
            LoadingProgressView(primaryText: "Loading " + codebaseProcessor.codebaseDisplayName,
                                secondaryText: step.rawValue).padding()

        case .didRetrieveCodebase:
            LoadingProgressView(primaryText: "Project Data Complete",
                                secondaryText: "✅").padding()

        case .visualizingCodebaseArchitecture(let step):
            LoadingProgressView(primaryText: "Analyzing " + codebaseProcessor.codebaseDisplayName,
                                secondaryText: step.rawValue).padding()
            
        case .analyzingCodebaseArchitecture(let analysis):
            CodebaseAnalysisView(analysis: analysis)
            
        case .failed(let errorMessage):
            ProcessingFailureView(errorMessage: errorMessage).padding()
        }
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
}
