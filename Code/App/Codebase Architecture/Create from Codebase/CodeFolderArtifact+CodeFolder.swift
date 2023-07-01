import SwiftNodes
import SwiftyToolz

@BackgroundActor
extension CodeFolderArtifact
{
    convenience init(codeFolder: CodeFolder,
                     pathInRootFolder: RelativeFilePath,
                     additionalReferences: inout [CodeSymbol.ReferenceLocation])
    {
        // use the first (sub-)folder that contains more than one thing
        
        var ultimateCodeFolder = codeFolder
        var ultmatePathInRootFolder = pathInRootFolder
        
        while let onlySubfolder = ultimateCodeFolder.containsExactlyOneSubfolder
        {
            ultimateCodeFolder = CodeFolder(name: ultimateCodeFolder.name + "/" + onlySubfolder.name,
                                            files: onlySubfolder.files ?? [],
                                            subfolders: onlySubfolder.subfolders ?? [])
            
            ultmatePathInRootFolder += onlySubfolder.name
        }
        
        // create child parts recursively – DEPTH FIRST
        
        var referencesByChildID = [CodeArtifact.ID: [CodeSymbol.ReferenceLocation]]()
        var graph = Graph<CodeArtifact.ID, Part, Int>()
        
        for subfolder in (ultimateCodeFolder.subfolders ?? [])
        {
            var extraReferences = [CodeSymbol.ReferenceLocation]()
            
            let child = Part(kind: .subfolder(.init(codeFolder: subfolder,
                                                    pathInRootFolder: ultmatePathInRootFolder + subfolder.name,
                                                    additionalReferences: &extraReferences)))
            
            referencesByChildID[child.id] = extraReferences
            
            graph.insert(child)
        }
        
        for file in (ultimateCodeFolder.files ?? [])
        {
            var extraReferences = [CodeSymbol.ReferenceLocation]()
            
            let child = Part(kind: .file(.init(codeFile: file,
                                               pathInRootFolder: ultmatePathInRootFolder + file.name,
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
                
                if ultmatePathInRootFolder.contains(childReferencePath)
                {
                    // we found a reference within the scope of this folder artifact that we initialize
                    
                    // search for a sibling that contains the reference location
                    for sibling in graph.values
                    {
                        if sibling.id == childID { continue } // not a sibling but the same child
                        
                        let siblingFilePath = ultmatePathInRootFolder + sibling.name
                        
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
        
        self.init(name: ultimateCodeFolder.name, partGraph: graph)
    }
}

extension CodeFolder
{
    var containsExactlyOneSubfolder: CodeFolder?
    {
        if !(files?.isEmpty ?? true) { return nil }
        guard let subfolders, subfolders.count == 1 else { return nil }
        return subfolders.first
    }
}
