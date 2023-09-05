import SwiftLSP
import SwiftNodes
import SwiftyToolz

@BackgroundActor
extension CodeSymbolArtifact
{
    convenience init(symbol: CodeSymbol,
                     linesOfEnclosingFile: [String],
                     pathInRootFolder: RelativeFilePath,
                     additionalReferences: inout [CodeSymbol.ReferenceLocation])
    {
        var graph = Graph<CodeArtifact.ID, CodeSymbolArtifact, Int>()
        var referencesByChildID = [CodeArtifact.ID: [CodeSymbol.ReferenceLocation]]()
        
        // create subsymbols recursively – RECURSION FIRST
        
        for childSymbol in (symbol.children ?? [])
        {
            var extraChildReferences = [CodeSymbol.ReferenceLocation]()
            
            let child = CodeSymbolArtifact(symbol: childSymbol,
                                           linesOfEnclosingFile: linesOfEnclosingFile,
                                           pathInRootFolder: pathInRootFolder,
                                           additionalReferences: &extraChildReferences)
            
            let childReferences = (childSymbol.references ?? []) + extraChildReferences
            
            referencesByChildID[child.id] = childReferences
            
            graph.insert(child)
        }
        
        // base case: create this symbol artifact
        
//        let fileName = pathInRootFolder.components.last ?? ""
//
//        if (fileName.contains("cookie_method_channel") || fileName.contains("cookie_method_call_handler")) {
//            for reference in (symbol.references ?? []) {
//                if reference.filePathRelativeToRoot.contains("app_method_channel.dart") {
//                    print("💥 found faulty reference:\nsource: \(reference.filePathRelativeToRoot) line \(reference.range.start.line + 1)\ntarget: \(pathInRootFolder.components.last ?? "nil") line \(symbol.range.start.line + 1) symbol \(symbol.name)")
//                }
//            }
//        }
        
        for (childID, childReferences) in referencesByChildID
        {
            for childReference in childReferences
            {
                if pathInRootFolder.string == childReference.filePathRelativeToRoot,
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
                            graph.add(1, toEdgeFrom: sibling.id, to: childID)
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
        
        graph.filterEssentialEdges()
        
        let code = getCode(of: symbol.range,
                           inFileLines: linesOfEnclosingFile)
        
        self.init(name: symbol.name,
                  kind: symbol.kind,
                  range: symbol.range,
                  selectionRange: symbol.selectionRange,
                  code: code ?? "",
                  subsymbolGraph: graph)
    }
}

func getCode(of range: LSPRange, inFileLines fileLines: [String]) -> String?
{
    guard fileLines.isValid(index: range.start.line),
          fileLines.isValid(index: range.end.line) else { return nil }
    
    return fileLines[range.start.line ... range.end.line].joined(separator: "\n")
}
