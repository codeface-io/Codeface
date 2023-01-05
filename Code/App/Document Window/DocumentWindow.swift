import SwiftLSP
import Foundation
import Combine
import SwiftyToolz

@MainActor
class DocumentWindow: ObservableObject
{
    init()
    {
        _lastLocation = Published(initialValue: try? CodebaseLocationPersister.loadCodebaseLocation())
    }
    
    // MARK: - Load Processor for Codebase from Location
    
    func loadProcessorForSwiftPackage(from folderURL: URL)
    {
        loadNewProcessor(forCodebaseFrom: .init(folder: folderURL,
                                                languageName: "Swift",
                                                codeFileEndings: ["swift"]))
    }
    
    func loadProcessorForLastCodebaseIfNoneIsLoaded()
    {
        if CodebaseLocationPersister.hasPersistedLastCodebaseLocation
        {
            loadProcessorForLastCodebase()
        }
    }
    
    func loadProcessorForLastCodebase()
    {
        do
        {
            try loadProcessor(forCodebaseFrom: CodebaseLocationPersister.loadCodebaseLocation())
        }
        catch { log(error.readable) }
    }
    
    func loadNewProcessor(forCodebaseFrom location: LSP.CodebaseLocation)
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
    
    @Published var lastLocation: LSP.CodebaseLocation?
    
    // MARK: - Load Processor for Codebase from File
    
    func loadProcessor(forCodebaseFrom fileURL: URL)
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
    
    func loadProcessor(for codebase: CodeFolder)
    {
        load(.didRetrieveCodebase(codebase))
        self.codebase = codebase
    }
    
    // MARK: - Load Processor
    
    private func load(_ state: CodebaseProcessorState)
    {
        codebaseProcessor.state = state
        bindCodebaseToProjectProcessorVM()
        
        codebaseProcessor.run()
    }
    
    // MARK: - Observable Codebase
    
    var defaultProjectFileName: String
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
    @Published private(set) var codebase: CodeFolder?
    
    // MARK: - Codebase Processor
    
    let codebaseProcessor = CodebaseProcessor()
    
    // MARK: - Import Views
    
    @Published var isPresentingCodebaseLocator = false
    @Published var isPresentingFolderImporter = false
}
