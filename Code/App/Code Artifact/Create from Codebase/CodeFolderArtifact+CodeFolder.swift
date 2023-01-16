import SwiftNodes
import SwiftyToolz

@BackgroundActor
extension CodeFolderArtifact
{
    convenience init(codeFolder: CodeFolder,
                     filePathRelativeToRoot: String,
                     additionalReferences: inout [CodeSymbol.ReferenceLocation])
    {
        let filePathWithSlash = filePathRelativeToRoot.isEmpty ? "" : filePathRelativeToRoot + "/"
        
        var referencesByChildID = [CodeArtifact.ID: [CodeSymbol.ReferenceLocation]]()
        var graph = Graph<CodeArtifact.ID, Part>()
        
        // create child parts recursively – DEPTH FIRST
        
        for subfolder in (codeFolder.subfolders ?? [])
        {
            var extraReferences = [CodeSymbol.ReferenceLocation]()
            
            let child = Part(kind: .subfolder(.init(codeFolder: subfolder,
                                                   filePathRelativeToRoot: filePathWithSlash + subfolder.name, additionalReferences: &extraReferences)))
            
            referencesByChildID[child.id] = extraReferences
            
            graph.insert(child)
        }
        
        for file in (codeFolder.files ?? [])
        {
            var extraReferences = [CodeSymbol.ReferenceLocation]()
            
            let child = Part(kind: .file(.init(codeFile: file,
                                   filePathRelativeToRoot: filePathWithSlash + file.name,
                                   additionalReferences: &extraReferences)))
            
            referencesByChildID[child.id] = extraReferences
            
            graph.insert(child)
        }
        
        // base case: create this folder artifact
        
        for (childID, childReferences) in referencesByChildID
        {
            for childReference in childReferences
            {
                if childReference.filePathRelativeToRoot.hasPrefix(filePathRelativeToRoot)
                {
                    // we found a reference within the scope of this folder artifact that we initialize
                    
                    // search for a sibling that contains the reference location
                    for sibling in graph.values
                    {
                        if sibling.id == childID { continue } // not a sibling but the same child
                        
                        let siblingFilePath = filePathWithSlash + sibling.name
                        
                        if childReference.filePathRelativeToRoot.hasPrefix(siblingFilePath)
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
        
        self.init(name: codeFolder.name, partGraph: graph)
    }
}
