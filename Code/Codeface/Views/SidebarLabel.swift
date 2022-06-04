import SwiftUI

struct SidebarLabel: View
{
    var body: some View
    {
        Label
        {
            Text(artifact.name)
                .font(.system(.title3, design: .for(artifact)))
            
            if let loc = artifact.metrics.linesOfCode
            {
                Spacer()
                
                Text("\(loc)")
                    .foregroundColor(isSelected ? .primary : .linesOfCode(for: artifact))
            }
        }
        icon:
        {
            ArtifactIcon(artifact: artifact, isSelected: isSelected)
        }
    }
    
    @State var artifact: CodeArtifact
    let isSelected: Bool
}

@MainActor
private extension Color
{
    static func linesOfCode(for artifact: CodeArtifact) -> Color
    {
        switch artifact.kind
        {
        case .file:
            return warningForFile(linesOfCode: artifact.linesOfCode)
        default:
            return Color(NSColor.systemGray)
        }
    }
    
    private static func warningForFile(linesOfCode: Int) -> Color
    {
        if linesOfCode < 100 { return Color(NSColor.systemGreen) }
        else if linesOfCode < 200 { return Color(NSColor.systemYellow) }
        else if linesOfCode < 300 { return Color(NSColor.systemOrange) }
        else { return Color(NSColor.systemRed) }
    }
}
