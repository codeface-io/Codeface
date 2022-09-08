import LSPServiceKit
import Combine
import SwiftyToolz

@MainActor
public class CodefaceViewModel: ObservableObject
{
    public init() {}
    
    public func loadLastProjectIfNoneIsActive()
    {
        if ProjectLocationPersister.hasPersistedLastProject, projectAnalysis == nil
        {
            loadLastActiveProject()
        }
    }
    
    public func loadLastActiveProject()
    {
        do
        {
            try setAndStartActiveAnalysis(with: ProjectLocationPersister.loadProjectConfig())
        }
        catch { log(error) }
    }
    
    public func loadNewActiveAnalysis(for project: ProjectLocation)
    {
        do
        {
            try setAndStartActiveAnalysis(with: project)
            try ProjectLocationPersister.persist(project)
        }
        catch { log(error) }
    }
    
    private func setAndStartActiveAnalysis(with project: ProjectLocation) throws
    {
        projectAnalysis?.selectedArtifact = nil
        
        Task
        {
            let analysis = try ProjectProcessor(project: project)
            projectAnalysis = await ProjectAnalysisViewModel(activeAnalysis: analysis)
            try await analysis.start()
        }
    }
    
    @Published public var projectAnalysis: ProjectAnalysisViewModel? = nil
}
