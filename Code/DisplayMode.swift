import SwiftUI

struct DisplayModePicker: View
{
    var body: some View
    {
        Picker("Display Mode", selection: $displayMode)
        {
            ForEach(DisplayMode.allCases) { $0.label }
        }
        .pickerStyle(.segmented)
    }
    
    @Binding var displayMode: DisplayMode
}

private extension DisplayMode
{
    var label: some View
    {
        let content = labelText
        return Label(content.name, systemImage: content.systemImage)
    }
    
    private var labelText: (name: String, systemImage: String)
    {
        switch self
        {
        case .treeMap:
            return ("Tree Map", "rectangle.3.group")
        case .code:
            return ("Code", "chevron.left.forwardslash.chevron.right")
        }
    }
}

enum DisplayMode: String, CaseIterable, Identifiable
{
    var id: Self { self }
    
    case treeMap, code
}
