import SwiftyToolz

/**
 TODO:
 * translate initialization algorithm from symbol level to here and folder
 */

@BackgroundActor
extension CodeFileArtifact
{
    convenience init(codeFile: CodeFile, filePathRelativeToRoot: String)
    {
        self.init(name: codeFile.name,
                  codeLines: codeFile.lines)
        
        for codeSymbol in (codeFile.symbols ?? [])
        {
            var additionalReferences = [CodeSymbol.ReferenceLocation]()
            
            symbolGraph.insert(.init(symbol: codeSymbol,
                                     enclosingFile: codeFile,
                                     filePathRelativeToRoot: filePathRelativeToRoot,
                                     additionalReferences: &additionalReferences))
            
            let allReferences = (codeSymbol.references ?? []) + additionalReferences
        }
    }
}
