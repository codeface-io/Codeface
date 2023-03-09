import SwiftLSP

enum CodebaseProcessorState
{
    var analysis: ArchitectureAnalysis?
    {
        if case .analyzeArchitecture(let analysis) = self { return analysis }
        return nil
    }
    
    case empty,
         didLocateCodebase(LSP.CodebaseLocation),
         retrieveCodebase(String),
         didJustRetrieveCodebase(CodeFolder),
         processCodebase(CodeFolder, ProgressFeedback),
         processArchitecture(CodeFolder, CodeFolderArtifact, ProgressFeedback),
         analyzeArchitecture(ArchitectureAnalysis),
         didFail(String)
    
    struct ProgressFeedback
    {
        let primaryText: String
        let secondaryText: String
    }
}
