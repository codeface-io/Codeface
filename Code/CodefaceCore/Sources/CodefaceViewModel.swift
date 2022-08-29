import LSPServiceKit
import Combine
import SwiftyToolz

@MainActor
public class CodefaceViewModel: ObservableObject
{
    public init() {}
    
    public func loadLastProjectIfNoneIsActive()
    {
        if ProjectDescriptionPersister.hasPersistedLastProject, projectAnalysis == nil
        {
            loadLastActiveProject()
        }
    }
    
    public func loadLastActiveProject()
    {
        do
        {
            try setAndStartActiveAnalysis(with: ProjectDescriptionPersister.loadProjectConfig())
        }
        catch { log(error) }
    }
    
    public func loadNewActiveAnalysis(for project: LSPProjectDescription)
    {
        do
        {
            try setAndStartActiveAnalysis(with: project)
            try ProjectDescriptionPersister.persist(project)
        }
        catch { log(error) }
    }
    
    private func setAndStartActiveAnalysis(with project: LSPProjectDescription) throws
    {
        let analysis = try ProjectAnalysis(project: project)
        projectAnalysis = ProjectAnalysisViewModel(activeAnalysis: analysis)
        try analysis.start()
    }
    
    @Published public var projectAnalysis: ProjectAnalysisViewModel? = nil
}
