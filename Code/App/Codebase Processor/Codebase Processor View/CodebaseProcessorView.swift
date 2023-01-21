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

        case .retrieveCodebase(let step):
            LoadingProgressView(primaryText: "Loading Codebase Data",
                                secondaryText: step.rawValue).padding()

        case .didRetrieveCodebase:
            LoadingProgressView(primaryText: "Codebase Data Load",
                                secondaryText: "✅").padding()
            
        case .generateArchitecture:
            LoadingProgressView(primaryText: "Generating Codebase Architecture",
                                secondaryText: "").padding()
            
        case .calculateMetrics:
            LoadingProgressView(primaryText: "Calculating Codebase Architecture Metrics",
                                secondaryText: "").padding()
            
        case .createViewModels:
            LoadingProgressView(primaryText: "Generating Codebase Architecture View Models",
                                secondaryText: "").padding()
            
        case .analyzeArchitecture(let analysis):
            CodebaseAnalysisView(analysis: analysis)
            
        case .didFail(let errorMessage):
            ProcessingFailureView(errorMessage: errorMessage).padding()
        }
    }
    
    @ObservedObject var codebaseProcessor: CodebaseProcessor
}
