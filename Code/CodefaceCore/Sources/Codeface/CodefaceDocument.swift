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
                                                language: "Swift",
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
        catch { log(error) }
    }
    
    public func loadNewProcessor(forCodebaseFrom location: LSP.CodebaseLocation)
    {
        do
        {
            try loadProcessor(forCodebaseFrom: location)
            try CodebaseLocationPersister.persist(location)
        }
        catch { log(error) }
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
        projectProcessorVM?.selectedArtifact = nil
        
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
    
    // MARK: - Project Processor View Model
    
    public func switchDisplayMode()
    {
        projectProcessorVM?.switchDisplayMode()
    }
    
    func set(processorVM: ProjectProcessorViewModel)
    {
        self.projectProcessorVM = processorVM
    }
    
    @Published public private(set) var projectProcessorVM: ProjectProcessorViewModel? = nil
}