extension ArtifactViewModel: Hashable
{
    nonisolated func hash(into hasher: inout Hasher)
    {
        hasher.combine(id)
    }
    
    nonisolated static func == (lhs: ArtifactViewModel,
                                rhs: ArtifactViewModel) -> Bool
    {
        lhs.id == rhs.id
    }
}
