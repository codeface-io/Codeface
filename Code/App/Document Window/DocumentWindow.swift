import SwiftLSP
import Foundation
import Combine
import SwiftyToolz

@MainActor
public class DocumentWindow: ObservableObject
{
    public init()
    {
        _lastLocation = Published(initialValue: try? CodebaseLocationPersister.loadCodebaseLocation())
    }
    
    // MARK: - Load Processor for Codebase from Location
    
    public func loadProcessorForSwiftPackage(from folderURL: URL)
    {
        loadNewProcessor(forCodebaseFrom: .init(folder: folderURL,
                                                languageName: "Swift",
                                                codeFileEndings: ["swift"]))
    }
    
    public func loadProcessorForLastCodebaseIfNoneIsLoaded()
    {
        if CodebaseLocationPersister.hasPersistedLastCodebaseLocation,
            codebaseProcessor == nil
        {
            loadProcessorForLastCodebase()
        }
    }
    
    public func loadProcessorForLastCodebase()
    {
        do
        {
            try loadProcessor(forCodebaseFrom: CodebaseLocationPersister.loadCodebaseLocation())
        }
        catch { log(error.readable) }
    }
    
    public func loadNewProcessor(forCodebaseFrom location: LSP.CodebaseLocation)
    {
        do
        {
            try loadProcessor(forCodebaseFrom: location)
            try CodebaseLocationPersister.persist(location)
        }
        catch { log(error.readable) }
    }
    
    private func loadProcessor(forCodebaseFrom location: LSP.CodebaseLocation) throws
    {
        guard FileManager.default.itemExists(location.folder) else
        {
            throw "Project folder does not exist: " + location.folder.absoluteString
        }
        
        load(.didLocateCodebase(location))
        lastLocation = location
    }
    
    @Published public var lastLocation: LSP.CodebaseLocation?
    
    // MARK: - Load Processor for Codebase from File
    
    public func loadProcessor(forCodebaseFrom fileURL: URL)
    {
        guard let fileData = Data(from: fileURL) else
        {
            log(error: "Couldn't read codebase file")
            return
        }
        
        guard let codebase = CodeFolder(fileData) else
        {
            log(error: "Couldn't decode codebase")
            return
        }
        
        loadProcessor(for: codebase)
    }
    
    public func loadProcessor(for codebase: CodeFolder)
    {
        load(.didRetrieveCodebase(codebase))
        self.codebase = codebase
    }
    
    // MARK: - Load Processor
    
    private func load(_ state: CodebaseProcessorState)
    {
        selectedArtifact = nil
        codebaseProcessor.state = state
        bindCodebaseToProjectProcessorVM()
        
        codebaseProcessor.run()
    }
    
    // MARK: - Observable Codebase
    
    public var defaultProjectFileName: String
    {
        codebaseProcessor.codebaseDisplayName
    }
    
    private func bindCodebaseToProjectProcessorVM()
    {
        codebaseObservation?.cancel()
        codebaseObservation = codebaseProcessor.$state
            .map { $0.codebase }
            .assign(to: \.codebase, on: self)
    }
    
    private var codebaseObservation: AnyCancellable?
    @Published public private(set) var codebase: CodeFolder?
    
    // MARK: - Codebase Processor
    
    public private(set) lazy var codebaseProcessor: CodebaseProcessor =
    {
        CodebaseProcessor(selectionPublisher: $selectedArtifact)
    }()
    
    // MARK: - Selection View Model
    
    @Published public var selectedArtifact: ArtifactViewModel? = nil
    
    // MARK: - Import Views
    
    @Published public var isPresentingCodebaseLocator = false
    @Published public var isPresentingFolderImporter = false
    
    // MARK: - Display Options
    
    @Published public var showsLeftSidebar: Bool = true
    @Published public var showsRightSidebar: Bool = false
    
    @Published public var showLoC: Bool = false
    
    public func switchDisplayMode()
    {
        switch displayMode
        {
        case .code: displayMode = .treeMap
        case .treeMap: displayMode = .code
        }
    }
    
    @Published public var displayMode: DisplayMode = .treeMap
}
