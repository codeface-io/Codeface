import SwiftLSP
import Foundation
import Combine
import SwiftyToolz

@MainActor
public class CodefaceDocument: ObservableObject
{
    public init() {}
    
    // MARK: - Load Processor for Codebase from Location
    
    public func loadProcessorForSwiftPackage(from folderURL: URL)
    {
        loadNewProcessor(forCodebaseFrom: .init(folder: folderURL,
                                                languageName: "Swift",
                                                codeFileEndings: ["swift"]))
    }
    
    public func loadProcessorForLastCodebaseIfNoneIsLoaded()
    {
        if CodebaseLocationPersister.hasPersistedLastCodebaseLocation, projectProcessorVM == nil
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
        load(try .init(codebaseLocation: location))
    }
    
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
        load(.init(codebase: codebase))
        self.codebase = codebase
    }
    
    // MARK: - Load Processor
    
    private func load(_ processor: ProjectProcessor)
    {
        selectedArtifact = nil
        
        Task
        {
            self.set(processorVM: await ProjectProcessorViewModel(processor: processor)) 
            self.bindCodebaseToProjectProcessorVM()
            await processor.run()
        }
    }
    
    // MARK: - Observable Codebase
    
    public var defaultProjectFileName: String
    {
        (projectProcessorVM?.codebaseDisplayName ?? "Codebase")
    }
    
    private func bindCodebaseToProjectProcessorVM()
    {
        codebaseObservation?.cancel()
        codebaseObservation = projectProcessorVM?.$processorState
            .map { $0.codebase }
            .assign(to: \.codebase, on: self)
    }
    
    private var codebaseObservation: AnyCancellable?
    @Published public private(set) var codebase: CodeFolder?
    
    // MARK: - Selection View Model
    
    @Published public var selectedArtifact: ArtifactViewModel? = nil
    {
        didSet
        {
            guard oldValue !== selectedArtifact else { return }
//            print("selected \(selectedArtifact?.codeArtifact.name ?? "nil")")
            oldValue?.lastScopeContentSize = nil
            projectProcessorVM?.pathBar.select(selectedArtifact)
        }
    }
    
    // MARK: - Project Processor View Model
    
    func set(processorVM: ProjectProcessorViewModel)
    {
        self.projectProcessorVM = processorVM
    }
    
    @Published public private(set) var projectProcessorVM: ProjectProcessorViewModel? = nil
}
