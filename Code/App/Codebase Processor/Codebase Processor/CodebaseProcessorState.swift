import SwiftLSP

enum CodebaseProcessorState
{
    public var codebaseName: String?
    {
        switch self
        {
        case .didLocateCodebase(let location): return location.folder.lastPathComponent
        case .didRetrieveCodebase(let codebase): return codebase.name
        case .analyzingCodebaseArchitecture(let analysis): return analysis.rootArtifact.codeArtifact.name
        default: return nil
        }
    }
    
    public var codebase: CodeFolder?
    {
        switch self
        {
        case .didRetrieveCodebase(let codebase): return codebase
        default: return nil
        }
    }
    
    public var analysis: CodebaseAnalysis?
    {
        if case .analyzingCodebaseArchitecture(let analysis) = self { return analysis }
        return nil
    }
    
    case empty,
         didLocateCodebase(LSP.CodebaseLocation),
         retrievingCodebase(CodebaseRetrievalStep),
         didRetrieveCodebase(CodeFolder),
         visualizingCodebaseArchitecture(CodebaseArchitectureVisualizationStep),
         analyzingCodebaseArchitecture(CodebaseAnalysis),
         failed(String)
    
    public enum CodebaseRetrievalStep: String, Equatable
    {
        case readFolder = "Reading raw data from codebase folder",
             connectToLSPServer = "Connecting to LSP server",
             retrieveSymbolsAndRefs = "Retrieving symbols and their references from LSP server"
    }
    
    public enum CodebaseArchitectureVisualizationStep: String, Equatable
    {
        case generateArchitecture = "Extracting basic codebase architecture",
             addSiblingSymbolDependencies = "Adding dependencies between sibling symbols",
             calculateHigherLevelDependencies = "Calculating higher level dependencies",
             calculateMetrics = "Calculating metrics",
             sortCodeArtifacts = "Sorting code artifacts",
             createViewModels = "Generating code artifact view models"
    }
}
