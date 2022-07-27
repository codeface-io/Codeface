import Foundation
import SwiftyToolz

@MainActor
class CodeArtifactPresentationModel: Identifiable, ObservableObject, Equatable
{
    nonisolated static func == (lhs: CodeArtifactPresentationModel,
                    rhs: CodeArtifactPresentationModel) -> Bool
    {
        lhs === rhs
    }
    
    init(codeArtifact: CodeArtifact)
    {
        self.codeArtifact = codeArtifact
        
        // create child presentations for parts recursively
        self.children = codeArtifact.parts.map
        {
            CodeArtifactPresentationModel(codeArtifact: $0)
        }
    }
    
    var showsName: Bool { frameInScopeContent.width - (2 * Self.padding + fontSize) >= 4 * fontSize }
    
    var collapseHorizontally: Bool { frameInScopeContent.width <= fontSize + (2 * Self.padding) }
    
    var collapseVertically: Bool { frameInScopeContent.height <= fontSize + (2 * Self.padding) }
    
    var fontSize: Double
    {
        1.2 * sqrt(sqrt(frameInScopeContent.height * frameInScopeContent.width))
    }
    
    static var padding: Double = 16
    static var minWidth: Double = 30
    static var minHeight: Double = 30
    
    @Published var frameInScopeContent = LayoutFrame.zero
    
    var showsContent = true
    var contentFrame = LayoutFrame.zero
    
    struct LayoutFrame: Equatable
    {
        static var zero: LayoutFrame { .init(centerX: 0, centerY: 0, width: 0, height: 0) }
        
        init(centerX: Double, centerY: Double, width: Double, height: Double)
        {
            self.centerX = centerX
            self.centerY = centerY
            self.width = width
            self.height = height
        }
        
        init(x: Double, y: Double, width: Double, height: Double)
        {
            self.centerX = x + width / 2
            self.centerY = y + height / 2
            self.width = width
            self.height = height
        }
        
        var x: Double { centerX - width / 2 }
        var y: Double { centerY - height / 2 }
        
        let centerX: Double
        let centerY: Double
        let width: Double
        let height: Double
    }
    
    let children: [CodeArtifactPresentationModel]?
    
    nonisolated var id: String { codeArtifact.id }
    
    let codeArtifact: CodeArtifact
}

extension CodeFolderArtifact: CodeArtifact
{
    func sort()
    {
        for file in files
        {
            file.sort()
        }
        
        files.sort { $0.linesOfCode > $1.linesOfCode }
        
        for subfolder in subfolders
        {
            subfolder.sort()
        }
        
        subfolders.sort { $0.linesOfCode > $1.linesOfCode }
    }
    
    var parts: [CodeArtifact]
    {
        subfolders as [CodeArtifact] + files as [CodeArtifact]
    }
}

extension CodeFileArtifact: CodeArtifact
{
    var parts: [CodeArtifact] { symbols }
    
    func sort()
    {
        for symbol in symbols
        {
            symbol.sort()
        }
        
        symbols.sort { $0.positionInFile < $1.positionInFile }
    }
}

extension CodeSymbolArtifact: CodeArtifact
{
    var parts: [CodeArtifact] { subSymbols }
    
    func sort()
    {
        for subSymbol in subSymbols
        {
            subSymbol.sort()
        }
        
        subSymbols.sort { $0.positionInFile < $1.positionInFile }
    }
}

protocol CodeArtifact: AnyObject
{
    var metrics: Metrics { get set }
    
    var passesSearchFilter: Bool { get set }
    var containsSearchTermRegardlessOfParts: Bool? { get set }
    var partsContainSearchTerm: Bool? { get set }
    
    var parts: [CodeArtifact] { get }
    func sort()
    
    var name: String { get }
    var kindName: String { get }
    var code: String? { get }
    
    var id: String { get }
}

@MainActor
class CodeFolderArtifact: Identifiable, ObservableObject
{
    init(codeFolder: CodeFolder, scope: CodeFolderArtifact?)
    {
        self.codeFolderURL = codeFolder.url
        self.scope = scope
        
        self.subfolders = codeFolder.subfolders.map
        {
            CodeFolderArtifact(codeFolder: $0, scope: self)
        }
        
        self.files = codeFolder.files.map
        {
            CodeFileArtifact(codeFile: $0, scope: self)
        }
    }
    
    // Mark: - Metrics
    
    var metrics = Metrics()
    
    // Mark: - Search
    
    @Published var passesSearchFilter = true
    
    var containsSearchTermRegardlessOfParts: Bool?
    var partsContainSearchTerm: Bool?
    
    // Mark: - Tree Structure
    
    weak var scope: CodeFolderArtifact?
    
    var subfolders = [CodeFolderArtifact]()
    var files = [CodeFileArtifact]()
    
    // Mark: - Basics
    
    var name: String { codeFolderURL.lastPathComponent }
    var kindName: String { "Folder" }
    var code: String? { nil }
    
    let id = UUID().uuidString
    let codeFolderURL: URL
}

@MainActor
class CodeFileArtifact: Identifiable, ObservableObject
{
    init(codeFile: CodeFile, scope: CodeFolderArtifact?)
    {
        self.codeFile = codeFile
        self.scope = scope
    }
    
    // Mark: - Metrics
    
    var metrics = Metrics()
    
    // Mark: - Search
    
    @Published var passesSearchFilter = true
    
    var containsSearchTermRegardlessOfParts: Bool?
    var partsContainSearchTerm: Bool?
    
    // Mark: - Tree Structure
    
    weak var scope: CodeFolderArtifact?
    
    var symbols = [CodeSymbolArtifact]()
    
    // Mark: - Basics
    
    var name: String { codeFile.name }
    var kindName: String { "File" }
    var code: String? { codeFile.code }

    let id = UUID().uuidString
    let codeFile: CodeFile
}

@MainActor
class CodeSymbolArtifact: Identifiable, ObservableObject
{
    init(codeSymbol: CodeSymbol, scope: Scope)
    {
        self.codeSymbol = codeSymbol
        self.scope = scope
    }
    
    // Mark: - Metrics
    
    var metrics = Metrics()
    
    // Mark: - Search
    
    @Published var passesSearchFilter = true
    
    var containsSearchTermRegardlessOfParts: Bool?
    var partsContainSearchTerm: Bool?
    
    // Mark: - Tree Structure
    
    // TODO: scope reference ought to be weak
    var scope: Scope
    
    enum Scope
    {
        case file(CodeFileArtifact)
        case symbol(CodeSymbolArtifact)
    }
    
    var subSymbols = [CodeSymbolArtifact]()
    
    // Mark: - Basics
    
    var name: String { codeSymbol.name }
    var kindName: String { codeSymbol.kindName }
    var code: String? { codeSymbol.code }
    
    let id = UUID().uuidString
    let codeSymbol: CodeSymbol
}

struct Metrics
{
    var linesOfCode: Int?
    var sizeRelativeToAllPartsInScope: Double?
}
