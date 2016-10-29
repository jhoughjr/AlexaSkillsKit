import Foundation

public class ResponseGenerator {
    public let standardResponse: StandardResponse
    public let sessionAttributes: [String: Any]
    
    public init(standardResponse: StandardResponse, sessionAttributes: [String: Any] = [:]) {
        self.standardResponse = standardResponse
        self.sessionAttributes = sessionAttributes
    }
    
    public func generateJSONObject() -> [String: Any] {
        var json: [String: Any] = ["version": "1.0"]

        json["sessionAttributes"] = sessionAttributes.isEmpty ? nil : sessionAttributes
        json["response"] = ResponseGenerator.generateStandardResponse(standardResponse)
        
        return json
    }
    
    public func generateJSON(options: JSONSerialization.WritingOptions = []) throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: generateJSONObject(), options: options)

        // JSONSerialization bug with Bools: https://bugs.swift.org/browse/SR-3013
        var dataString = String(data: data, encoding: .utf8)
        if options.contains(.prettyPrinted) {
            dataString = dataString?.replacingOccurrences(of: "\"shouldEndSession\": 0", with: "\"shouldEndSession\" : false")
        } else {
            dataString = dataString?.replacingOccurrences(of: "\"shouldEndSession\":0", with: "\"shouldEndSession\":false")
        }

        return dataString?.data(using: .utf8) ?? data
    }
}

extension ResponseGenerator {
    class func generateStandardResponse(_ standardResponse: StandardResponse) -> [String: Any] {
        var jsonResponse = [String: Any]()
        
        if let outputSpeech = standardResponse.outputSpeech {
            jsonResponse["outputSpeech"] = ResponseGenerator.generateOutputSpeech(outputSpeech)
        }
        
        if let reprompt = standardResponse.reprompt {
            let jsonOutputSpeech = ["outputSpeech": ResponseGenerator.generateOutputSpeech(reprompt)]
            jsonResponse["reprompt"] = jsonOutputSpeech
        }
        
        if let card = standardResponse.card {
            jsonResponse["card"] = ResponseGenerator.generateCard(card)
        }
        
        if !standardResponse.shouldEndSession {
            #if os(Linux)
                jsonResponse["shouldEndSession"] = NSNumber(booleanLiteral: standardResponse.shouldEndSession)
            #else
                jsonResponse["shouldEndSession"] = standardResponse.shouldEndSession
            #endif
        }
        
        return jsonResponse
    }
    
    class func generateOutputSpeech(_ outputSpeech: OutputSpeech) -> [String: Any] {
        switch outputSpeech {
        case .plain(let text): return ["type": "PlainText", "text": text]
        }
    }
    
    class func generateCard(_ card: Card) -> [String: Any] {
        switch card {
        case .simple(let title, let content):
            var jsonCard: [String: Any] = ["type": "Simple"]
            jsonCard["title"] = title
            jsonCard["content"] = content
            return jsonCard
        case .standard(let title, let text, let image):
            var jsonCard: [String: Any] = ["type": "Standard"]
            jsonCard["title"] = title
            jsonCard["text"] = text
            jsonCard["image"] = ["smallImageUrl": image?.smallImageUrl, "largeImageUrl": image?.largeImageUrl]
            return jsonCard
        }
    }
}
