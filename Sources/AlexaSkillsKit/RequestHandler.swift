import Foundation

public struct MessageError: Swift.Error, Equatable {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public static func ==(lhs: MessageError, rhs: MessageError) -> Bool {
        return lhs.message == rhs.message
    }
}

// "enum Result<T>" produced errors in Swift 4.0.3, so the non-template version below is a workaround

public enum StandardResult {
    case success(standardResponse: StandardResponse, sessionAttributes: [String: Any])
    case failure(MessageError)
}

public enum DataResult {
    case success(Data)
    case failure(MessageError)
}

public enum VoidResult {
    case success()
    case failure(MessageError)
}

public protocol RequestHandler {
    func handleLaunch(request: LaunchRequest, session: Session, next: @escaping (StandardResult) -> ())
    func handleIntent(request: IntentRequest, session: Session, next: @escaping (StandardResult) -> ())
    func handleSessionEnded(request: SessionEndedRequest, session: Session, next: @escaping (VoidResult) -> ())
}
