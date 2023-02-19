import XCTest
@testable import Codeface
import SwiftLSP
import SwiftyToolz

class CodefaceTests: XCTestCase
{
    @BackgroundActor func testHighlevelDependenciesAreDetectedInSpiteOfTrickyPathPrefix() throws
    {
        let range = LSPRange(start: .init(line: 0, character: 0),
                              end: .init(line: 10, character: 0))
        
        let classALSPSymbol = LSPDocumentSymbol(name: "ClassA",
                                                kind: 5,
                                                range: range,
                                                selectionRange: range)
        
        let referenceARange = LSPRange(start: .init(line: 1, character: 0),
                                       end: .init(line: 2, character: 0))
        
        let referenceA = CodeSymbol.ReferenceLocation(filePathRelativeToRoot: "AB/AB.swift",
                                                      range: referenceARange)
        
        let classA = try CodeSymbol(lspDocumentySymbol: classALSPSymbol,
                                    referenceLocations: [referenceA],
                                    children: [])
        
        let fileA = CodeFile(name: "A.swift",
                             code: "",
                             symbols: [classA])
        
        let folderA = CodeFolder(name: "A", files: [fileA])
        
        let classABLSPSymbol = LSPDocumentSymbol(name: "ClassAB",
                                                 kind: 5,
                                                 range: range,
                                                 selectionRange: range)
        
        let classAB = try CodeSymbol(lspDocumentySymbol: classABLSPSymbol,
                                     referenceLocations: [],
                                     children: [])
        
        let fileAB = CodeFile(name: "AB.swift",
                              code: "",
                              symbols: [classAB])
        
        let folderAB = CodeFolder(name: "AB", files: [fileAB])
        
        let folder = CodeFolder(name: "Root", subfolders: [folderA, folderAB])
        
        var extraReferences = [CodeSymbol.ReferenceLocation]()
        
        let folderArtifact = CodeFolderArtifact(codeFolder: folder,
                                                filePathRelativeToRoot: "",
                                                additionalReferences: &extraReferences)
        
        let nodes = folderArtifact.partGraph.nodes
        
        guard let idAB = nodes.first(where: { $0.value.name == "AB" })?.id,
              let idA = nodes.first(where: { $0.value.name == "A" })?.id
        else
        {
            throw "Could not find node IDs for subfolder artifacts"
        }
        
        XCTAssert(folderArtifact.partGraph.containsEdge(from: idAB, to: idA))
    }
}
