import SwiftLSP
import Foundation
import Combine
import SwiftyToolz

@MainActor
public class Codeface: ObservableObject
{
    public init() {}
    
    // MARK: - Load Project from Location
    
    public func loadSwiftPackage(from folderURL: URL)
    {
        loadNewProject(from: .init(folder: folderURL,
                                   language: "Swift",
                                   codeFileEndings: ["swift"]))
    }
    
    public func loadLastProjectIfNoneIsLoaded()
    {
        if ProjectLocationPersister.hasPersistedLastProjectLocation, projectProcessorVM == nil
        {
            loadLastProject()
        }
    }
    
    public func loadLastProject()
    {
        do
        {
            try loadProject(from: ProjectLocationPersister.loadProjectLocation())
        }
        catch { log(error) }
    }
    
    public func loadNewProject(from location: LSP.ProjectLocation)
    {
        do
        {
            try loadProject(from: location)
            try ProjectLocationPersister.persist(location)
        }
        catch { log(error) }
    }
    
    private func loadProject(from location: LSP.ProjectLocation) throws
    {
        loadProject(with: try .init(projectLocation: location))
    }
    
    // MARK: - Load Project from File
    
    public func loadProject(from fileURL: URL)
    {
        guard let fileData = Data(from: fileURL) else
        {
            log(error: "Couldn't read project data file")
            return
        }
        
        guard let projectData = CodeFolder(fileData) else
        {
            log(error: "Couldn't decode project data")
            return
        }
        
        loadProject(from: projectData)
    }
    
    private func loadProject(from projectData: CodeFolder)
    {
        loadProject(with: .init(projectData: projectData))
        self.projectData = projectData
    }
    
    // MARK: - Load Project
    
    private func loadProject(with processor: ProjectProcessor)
    {
        projectProcessorVM?.selectedArtifact = nil
        
        Task
        {
            self.projectProcessorVM = await ProjectProcessorViewModel(processor: processor)
            self.bindProjectDataToProjectProcessorVM()
            await processor.run()
        }
    }
    
    // MARK: - Export Project Data
    
    public var defaultProjectFileName: String
    {
        (projectProcessorVM?.projectDisplayName ?? "Project")
    }
    
    private func bindProjectDataToProjectProcessorVM()
    {
        projectDataObservation?.cancel()
        projectDataObservation = projectProcessorVM?.$processorState
            .map { $0.projectData }
            .assign(to: \.projectData, on: self)
    }
    
    private var projectDataObservation: AnyCancellable?
    @Published public var projectData: CodeFolder?
    
    // MARK: - Project Processor View Model
    
    @Published public var projectProcessorVM: ProjectProcessorViewModel? = nil
}
