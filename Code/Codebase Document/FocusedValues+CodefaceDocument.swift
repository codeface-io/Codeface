import SwiftUI
import CodefaceCore

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
