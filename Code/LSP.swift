import Foundation

struct LSPResponse
{
    init(json: JSONObject) throws
    {
        id = try .int(json.int("id"))
        
        if let _ = json.obj("error")
        {
            result = .failure(ResponseError())
        }
        else
        {
            result = try .success(json.any("result"))
        }
    }
    
    let jsonrpc = "2.0"
    
    let id: ID
    
    enum ID
    {
        case string(String), int(Int), empty
    }
    
    let result: Result<Any, ResponseError>
    
    struct ResponseError: Error
    {
        
    }
}

struct LSP
{
    static func makeFrame(withContent content: Data) -> Data
    {
        let header = "Content-Length: \(content.count)\r\n\r\n".data!
        return header + content
    }
    
    static func extractContent(fromFrame frame: Data) -> Data?
    {
        guard let separatorIndex = frame.firstIndex(of: [13, 10, 13, 10]) else { return nil }
        let contentIndex = separatorIndex + 4
        guard contentIndex < frame.count else { return nil }
        return frame[contentIndex...]
    }
}
