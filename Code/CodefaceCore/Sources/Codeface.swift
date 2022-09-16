import LSPServiceKit
import Foundation
import SwiftLSP
import Combine
import SwiftyToolz

@MainActor
public class Codeface: ObservableObject
{
    public init() {}
    
    public func loadLastProjectIfNoneIsActive()
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
            try setAndStartActiveProcessor(with: ProjectLocationPersister.loadProjectLocation())
        }
        catch { log(error) }
    }
    
    public func loadNewActiveprocessor(for project: LSP.ProjectLocation)
    {
        do
        {
            try setAndStartActiveProcessor(with: project)
            try ProjectLocationPersister.persist(project)
        }
        catch { log(error) }
    }
    
    private func setAndStartActiveProcessor(with location: LSP.ProjectLocation) throws
    {
        projectProcessorVM?.selectedArtifact = nil
        
        Task
        {
            let processor = try ProjectProcessor(projectLocation: location)
            let processorVM = await ProjectProcessorViewModel(activeProcessor: processor)
            self.projectProcessorVM = processorVM
            
            self.projectDataObservation?.cancel()
            self.projectDataObservation = processorVM.$processorState.sink
            {
                if let projectData = $0.projectData
                {
                    self.projectData = projectData
                }
            }
            
            await processor.run()
        }
    }
    
    public var defaultProjectFileName: String
    {
        (projectProcessorVM?.projectDisplayName ?? "Project") + ".cf"
    }
    
    @Published public var projectProcessorVM: ProjectProcessorViewModel? = nil
    
    @Published public var projectData: CodeFolder?
    private var projectDataObservation: AnyCancellable?
}

public enum CodefaceStyle
{
    public static var accent: DynamicColor
    {
        .in(light: .bytes(0, 122, 255),
            darkness: .bytes(10, 132, 255))
    }
    
    public static var warningRed: DynamicColor
    {
        .in(light: .bytes(255, 59, 48),
            darkness: .bytes(255, 69, 58))
    }
}
