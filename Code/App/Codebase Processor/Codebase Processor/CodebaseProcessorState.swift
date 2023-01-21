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
         retrieveCodebase(String),
         processCodebase(CodeFolder, ProgressFeedback),
         processArchitecture(CodeFolder, CodeFolderArtifact, ProgressFeedback),
         analyzeArchitecture(CodebaseAnalysis),
         didFail(String)
    
    struct ProgressFeedback
    {
        let primaryText: String
        let secondaryText: String
    }
}
