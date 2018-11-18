import SwiftyToolz

func warningColor(for linesOfCode: Int) -> Color.System
{
    if linesOfCode < 100 { return .green }
    else if linesOfCode < 200 { return .yellow }
    else if linesOfCode < 300 { return .orange }
    else { return .red }
}

struct CodeFileAnalytics
{
    init(file: CodeFile, loc: Int)
    {
        self.file = file
        self.linesOfCode = loc
    }
    
    let file: CodeFile
    let linesOfCode: Int
}
