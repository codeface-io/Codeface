import SwiftUI
import CodefaceCore

struct CodefaceDocumentView: View
{
    var body: some View
    {
        CodefaceDocumentContentView(codefaceDocument: codefaceDocument)
            .focusedSceneValue(\.document, codefaceDocument)
            .onReceive(codefaceDocument.$codebase) {
                if let updatedCodebase = $0
                {
                    codebaseFile.codebase = updatedCodebase
                }
            }
            .onAppear {
                if let codebase = codebaseFile.codebase
                {
                    codefaceDocument.loadProcessor(for: codebase)
                }
            }
    }
    
    @StateObject private var codefaceDocument = CodefaceDocument()
    @Binding var codebaseFile: CodebaseFileDocument
}

extension FocusedValues
{
    var document: CodefaceDocument?
    {
        get { self[DocumentFocusedValues.self] }
        set { self[DocumentFocusedValues.self] = newValue }
    }
    
    private struct DocumentFocusedValues: FocusedValueKey
    {
        typealias Value = CodefaceDocument
    }
}
