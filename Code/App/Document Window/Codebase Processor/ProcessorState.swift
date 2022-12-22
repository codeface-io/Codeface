import CodefaceCore
import SwiftLSP

public enum ProcessorState
{
    public var codebaseName: String?
    {
        switch self
        {
        case .didLocateCodebase(let location): return location.folder.lastPathComponent
        case .didRetrieveCodebase(let codebase): return codebase.name
        case .didVisualizeCodebaseArchitecture(let codebase, _): return codebase.name
        default: return nil
        }
    }
    
    public var isEmpty: Bool
    {
        switch self
        {
        case .empty: return true
        default: return false
        }
    }
    
    public var codebase: CodeFolder?
    {
        switch self
        {
        case .didRetrieveCodebase(let codebase): return codebase
        case .didVisualizeCodebaseArchitecture(let codebase, _): return codebase
        default: return nil
        }
    }
    
    case empty,
         didLocateCodebase(LSP.CodebaseLocation),
         retrievingCodebase(CodebaseRetrievalStep),
         didRetrieveCodebase(CodeFolder),
         visualizingCodebaseArchitecture(CodebaseArchitectureVisualizationStep),
         didVisualizeCodebaseArchitecture(CodeFolder, ArtifactViewModel),
         failed(String)
    
    public enum CodebaseRetrievalStep: String, Equatable
    {
        case readFolder = "Reading raw data from codebase folder",
             connectToLSPServer = "Connecting to LSP server",
             retrieveSymbols = "Retrieving symbols from LSP server",
             retrieveReferences = "Retrieving symbol references from LSP server"
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
