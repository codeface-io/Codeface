import SwiftNodes
import SwiftyToolz

@BackgroundActor
extension CodeFolderArtifact
{
    convenience init(codeFolder: CodeFolder,
                     pathInRootFolder: RelativeFilePath,
                     additionalReferences: inout [CodeSymbol.ReferenceLocation])
    {
        var referencesByChildID = [CodeArtifact.ID: [CodeSymbol.ReferenceLocation]]()
        var graph = Graph<CodeArtifact.ID, Part, Int>()
        
        // create child parts recursively – DEPTH FIRST
        
        for subfolder in (codeFolder.subfolders ?? [])
        {
            var extraReferences = [CodeSymbol.ReferenceLocation]()
            
            let child = Part(kind: .subfolder(.init(codeFolder: subfolder,
                                                    pathInRootFolder: pathInRootFolder.appending(subfolder.name),
                                                    additionalReferences: &extraReferences)))
            
            referencesByChildID[child.id] = extraReferences
            
            graph.insert(child)
        }
        
        for file in (codeFolder.files ?? [])
        {
            var extraReferences = [CodeSymbol.ReferenceLocation]()
            
            let child = Part(kind: .file(.init(codeFile: file,
                                               pathInRootFolder: pathInRootFolder.appending(file.name),
                                               additionalReferences: &extraReferences)))
            
            referencesByChildID[child.id] = extraReferences
            
            graph.insert(child)
        }
        
        // base case: create this folder artifact
        
        for (childID, childReferences) in referencesByChildID
        {
            for childReference in childReferences
            {
                let childReferencePath = RelativeFilePath(string: childReference.filePathRelativeToRoot)
                
                if pathInRootFolder.contains(childReferencePath)
                {
                    // we found a reference within the scope of this folder artifact that we initialize
                    
                    // search for a sibling that contains the reference location
                    for sibling in graph.values
                    {
                        if sibling.id == childID { continue } // not a sibling but the same child
                        
                        let siblingFilePath = pathInRootFolder.appending(sibling.name)
                        
                        if siblingFilePath.contains(childReferencePath)
                        {
                            // the sibling references (depends on) the child -> add edge and leave the for-loop
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
        
        self.init(name: codeFolder.name, partGraph: graph)
    }
}
