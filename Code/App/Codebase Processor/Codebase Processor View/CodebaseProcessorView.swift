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
            
        case .didVisualizeCodebaseArchitecture(_, let rootArtifact):
            CodebaseAnalysisView(rootArtifact: rootArtifact,
                                 codefaceDocument: documentWindow,
                                 processorVM: codebaseProcessor)
            
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
    
    @ObservedObject var documentWindow: DocumentWindow
    @ObservedObject var codebaseProcessor: CodebaseProcessor
}
