import SwiftNodes
import SwiftyToolz

@BackgroundActor
extension CodeSymbolArtifact
{
    convenience init(symbol: CodeSymbol,
                     enclosingFile: CodeFile,
                     filePathRelativeToRoot: String,
                     additionalReferences: inout [CodeSymbol.ReferenceLocation])
    {
        var graph = Graph<CodeArtifact.ID, CodeSymbolArtifact>()
        var referencesByChildID = [CodeArtifact.ID: [CodeSymbol.ReferenceLocation]]()
        
        // create subsymbols recursively – DEPTH FIRST
        
        for childSymbol in (symbol.children ?? [])
        {
            var extraChildReferences = [CodeSymbol.ReferenceLocation]()
            
            let child = CodeSymbolArtifact(symbol: childSymbol,
                                           enclosingFile: enclosingFile,
                                           filePathRelativeToRoot: filePathRelativeToRoot,
                                           additionalReferences: &extraChildReferences)
            
            let childReferences = (childSymbol.references ?? []) + extraChildReferences
            
            referencesByChildID[child.id] = childReferences
            
            graph.insert(child)
        }
        
        // base case: create this symbol artifact
        
        for (childID, childReferences) in referencesByChildID
        {
            for childReference in childReferences
            {
                if filePathRelativeToRoot == childReference.filePathRelativeToRoot,
                   symbol.range.contains(childReference.range)
                {
                    // we found a reference within the scope of this symbol artifact that we initialize
                    
                    // search for a sibling that contains the reference location
                    for sibling in graph.values
                    {
                        if sibling.id == childID { continue } // not a sibling but the same child
                        
                        if sibling.range.contains(childReference.range)
                        {
                            // the sibling references (depends on) the child -> add edge and leave for loop
                            graph.addEdge(from: sibling.id, to: childID)
                            break
                        }
                    }
                }
                else
                {
                    // we found an out-of-scope reference that we pass on to the caller
                    additionalReferences += childReference
                }
            }
        }
        
        let code = enclosingFile.lines[symbol.range.start.line ... symbol.range.end.line].joined(separator: "\n")
        
        self.init(name: symbol.name,
                  kind: symbol.kind,
                  range: symbol.range,
                  selectionRange: symbol.selectionRange,
                  code: code,
                  subsymbolGraph: graph)
    }
}
