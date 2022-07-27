import SwiftLSP

extension CodeSymbolArtifact
{
    var positionInFile: Int
    {
        codeSymbol.range.start.line
    }
}
