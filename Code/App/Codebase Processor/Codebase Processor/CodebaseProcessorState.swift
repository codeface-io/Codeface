import SwiftLSP

enum CodebaseProcessorState
{
    var analysis: CodebaseAnalysis?
    {
        if case .analyzeArchitecture(let analysis) = self { return analysis }
        return nil
    }
    
    case empty,
         didLocateCodebase(LSP.CodebaseLocation),
         retrieveCodebase(CodebaseRetrievalStep),
         didRetrieveCodebase(CodeFolder),
         generateArchitecture,
         calculateMetrics,
         createViewModels,
         analyzeArchitecture(CodebaseAnalysis),
         didFail(String)
    
    enum CodebaseRetrievalStep: String, Equatable
    {
        case readFolder = "Reading raw data from codebase folder",
             connectToLSPServer = "Connecting to LSP server",
             retrieveSymbolsAndRefs = "Retrieving symbols and their references from LSP server"
    }
}
