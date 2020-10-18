import Foundation
import SwiftyToolz

struct LSP
{
    enum Message
    {
        init(json: JSONObject) throws
        {
            if let nullableID = Message.getID(from: json) // request or response
            {
                if let result = try? json.any("result") // success response
                {
                    self = .response(.init(id: nullableID, result: .success(result)))
                }
                else if let _ = try? json.obj("error") // error response
                {
                    self = .response(.init(id: nullableID, result: .failure(Response.ResponseError())))
                }
                else // request
                {
                    guard case .value(let id) = nullableID else
                    {
                        throw "Invalid message JSON. Either it's a response with no error and no result, or it's a request/notification with a <null> id"
                    }
                    self = .request(.init(id: id,
                                          method: try json.str("method"),
                                          params: json["params"]))
                }
            }
            else // notification
            {
                self = .notification(.init(method: try json.str("method"),
                                           params: json["params"]))
            }
        }
        
        private static func getID(from messageJSON: JSONObject) -> NullableID?
        {
            guard let anyID = messageJSON["id"] else { return nil }
            
            switch anyID {
            case let string as String: return .value(.string(string))
            case let int as Int: return .value(.int(int))
            case is NSNull: return .null
            default: return nil
            }
        }
        
        func jsonObject() -> JSONObject
        {
            var json: JSONObject = ["jsonrpc": "2.0"]
            
            switch self
            {
            case .request(let request):
                json["id"] = request.id.json
                json["method"] = request.method
                json["params"] = request.params
            case .response(let response):
                json["id"] = response.id.json
                switch response.result
                {
                case .success(let anyResult):
                    json["result"] = anyResult
                case .failure(_):
                    json["error"] = JSONObject()
                }
            case .notification(let notification):
                json["method"] = notification.method
                json["params"] = notification.params
            }
            
            return json
        }
        
        case request(Request)
        case response(Response)
        case notification(Notification)
        
        struct Notification
        {
            init(method: String, params: JSON?)
            {
                self.method = method
                self.params = params
            }
            
            let method: String
            let params: JSON?
        }

        struct Response
        {
            init(id: NullableID, result: Result<JSON, ResponseError>)
            {
                self.id = id
                self.result = result
            }
            
            let id: NullableID
            
            let result: Result<JSON, ResponseError>
            
            struct ResponseError: Error
            {
                
            }
        }

        struct Request
        {
            init(id: ID, method: String, params: JSON?)
            {
                self.id = id
                self.method = method
                self.params = params
            }
            
            let id: ID
            let method: String
            let params: JSON?
        }
        
        enum NullableID
        {
            var json: JSON
            {
                switch self
                {
                case .value(let id): return id.json
                case .null: return NSNull()
                }
            }
            
            case value(ID), null
        }

        enum ID
        {
            var json: JSON
            {
                switch self
                {
                case .string(let string): return string
                case .int(let int): return int
                }
            }
            
            case string(String), int(Int)
        }
    }
    
    static func makeFrame(withContent content: Data) -> Data
    {
        let header = "Content-Length: \(content.count)\r\n\r\n".data!
        return header + content
    }
    
    static func extractContent(fromFrame frame: Data) throws -> Data
    {
        guard let separatorIndex = frame.firstIndex(of: [13, 10, 13, 10]) else
        {
            throw "Invalid LSP Frame: No header/content separator"
        }
        
        let contentIndex = separatorIndex + 4
        
        guard contentIndex < frame.count else
        {
            throw "Invalid LSP Frame: No content part"
        }
        
        return frame[contentIndex...]
    }
}
