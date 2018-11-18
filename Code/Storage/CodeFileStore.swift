class CodeFileStore: Store<CodeFile>
{
    static let shared = CodeFileStore()
    
    private override init() {}
}
