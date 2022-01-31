/*import Foundation

public enum XMessageType {
    case Info
    case Warning
    case Error
}

public typealias XStepName = String
public typealias XMessageID = String
public typealias XLanguage = String
public typealias XMessageText = String
public typealias XLocalizingMessage = [XLanguage:XMessageText]
public typealias XMessage = (XMessageID,XMessageType,XLocalizingMessage)
public typealias XMessages = [XMessageID:XMessage]

public protocol XMessagesHolder { }

public extension XMessagesHolder {
    var messages:[String:XMessage] {
        get {
            var messages = [String:XMessage]()
            Mirror(reflecting: self).children.forEach { child in
                if let message = child.value as? XMessage {
                    messages[message.0] = message
                }
            }
            return messages
        }
    }
}

public struct XStepError: LocalizedError {
    
    private let message: String

    public init(_ message: String) {
        self.message = message
    }
    
    public var errorDescription: String? {
        return message
    }
}

func format(_ _s: String, using arguments: [String]) -> String {
    var i = 0
    var s = _s
    arguments.forEach { argument in
        i += 1
        s = s.replacingOccurrences(of: "$\(i)", with: argument)
    }
    return s
}

func fillLocalizingMessage(message: XLocalizingMessage, languages: [XLanguage], with arguments: [String]) -> XLocalizingMessage {
    var localizingMessage = [String:String]()
    languages.forEach { language in
        localizingMessage[language] = format(message[language] ?? "?", using: arguments)
    }
    return localizingMessage
}

func localizingMessage(forID id: String, languages: [XLanguage], fixedMessage: String) -> MessageWithID {
    var localizingMessage = [String:String]()
    languages.forEach { language in
        localizingMessage[language] = fixedMessage
    }
    return MessageWithID(
        id: id,
        localizingMessage: localizingMessage
    )
}

public protocol XStepData: XMessagesHolder {
    var stepName: String { get }
}

extension XStepData
{
    func messageIDs() -> [String] {
        return Mirror(reflecting: self).children.compactMap{ $0.label }
    }
}

public class XStepDataCollector {
    var allMessages = [String:[XMessageID:XMessage]]()
    var _languages = Set<String>()
    public var languages: Set<String> {
        get {
            return _languages
        }
    }
    
    public init() {}
    
    public func collect(from stepData: XStepData) {
        let stepMessages = stepData.messages
        allMessages[stepData.stepName] = stepMessages
        stepData.messages.values.forEach { (_, _, lLocalizingMessage) in
            lLocalizingMessage.keys.forEach { language in
                _languages.insert(language)
            }
        }
    }
    
    public func writeAll(toFile path: String) {
        let fileManager = FileManager.default
    
        fileManager.createFile(atPath: path,  contents:Data("".utf8), attributes: nil)
        
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            writeAll(toFile: fileHandle)
        }
        else {
            print("ERROR: cannot write to [\(path)]");
        }
    }
    
    public func printAll() {
        writeAll(toFile: FileHandle.standardOutput)
    }
    
    public func writeAll(toFile fileHandle: FileHandle) {
        let languageList = _languages.sorted()
        fileHandle.write("\"Step\";\"Message ID\";\"Message Type\"".data(using: .utf8)!)
        languageList.forEach { language in
            fileHandle.write(";\"Message (\(language))\"".data(using: .utf8)!)
        }
        fileHandle.write("\r\n".data(using: .utf8)!)
        allMessages.keys.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
            .forEach { stepName in
                let stepNameEscaped = stepName.replacingOccurrences(of: "\"", with: "\"\"")
                if let messagesForStep = allMessages[stepName] {
                    messagesForStep.keys.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
                    .forEach { messageID in
                        let messageIDEscaped = messageID.replacingOccurrences(of: "\"", with: "\"\"")
                        if let (_,messageType,messagesForLanguages) = messagesForStep[messageID] {
                            fileHandle.write("\"\(stepNameEscaped)\";\"\(messageIDEscaped)\";\"\(messageType)\"".data(using: .utf8)!)
                            languageList.forEach { language in
                                let messageEscaped = (messagesForLanguages[language] ?? "").replacingOccurrences(of: "\"", with: "\"\"")
                                fileHandle.write(";\"\(messageEscaped)\"".data(using: .utf8)!)
                            }
                            fileHandle.write("\r\n".data(using: .utf8)!)
                        }
                    }
                }
            }
    }
}

public typealias LocalizingMessage = [String:String]

public struct MessageWithID {
    let id: String
    let localizingMessage: LocalizingMessage
}

open class XLogger {
    
    public let language = "de" // TODO
    public let languages: [XLanguage]
    
    public init(languages: Set<XLanguage>) {
        self.languages = languages.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }
    
    open func write(_ type: XMessageType, _ text: String) {
        if type == .Error {
            print(text, to: &standardError)
        }
        else {
            print(text)
        }
    }
    
    open func log(stepLevel: Int, step: String) {
        write(.Info, "\(String(repeating: " ", count: stepLevel<<1))step: \(step)")
    }
    
    open func pathInfo(forNode node: XNode?) -> String {
        let versions = node?.rpath?.reversed().map { (ref) -> String in (ref as? XElement)?.xpath ?? ref.parent?.xpath ?? "-" }.joined(separator: " -> ") ?? "-"
        let xpathCurrent = (node as? XElement)?.xpath ?? node?.parent?.xpath ?? "-"
        return "\(versions) -> \(xpathCurrent)"
    }
    
    open func fullMessage(
        _ type: XMessageType,
        stepLevel: Int,
        step: String,
        node: XNode?,
        message: String
    ) -> String {
        let typeInfo: String
        switch type {
        case .Info:
            typeInfo = "INFO"
        case .Warning:
            typeInfo = "WARNING"
        case .Error:
            typeInfo = "ERROR"
        }
        let source = node?.document?.source
        return "\(String(repeating: " ", count: (stepLevel+1)<<1))\(typeInfo) (\(step)\(source != nil ? ", \(source!)" : ""), \(pathInfo(forNode: node))): \(message)"
    }
    
    open func log(
        _ type: XMessageType,
        stepLevel: Int,
        step: String,
        node: XNode? = nil,
        message: String
    ) {
        let theFullMessage = fullMessage(
            type,
            stepLevel: stepLevel,
            step: step,
            node: node,
            message: message
        )
        if type == .Error {
            print(theFullMessage, to: &standardError)
        }
        else {
            print(theFullMessage)
        }
    }
    
    open func fullMessage(stepLevel: Int, node: XNode?, stepName: String, message: XMessage, arguments: [String]) -> (XMessageType,String) {
        let messageID: XMessageID = message.0
        let messageType: XMessageType = message.1
        let localizingMessage = fillLocalizingMessage(message: message.2, languages: languages, with: arguments)
        
        let typeInfo: String
        switch messageType {
        case .Info:
            typeInfo = "INFO"
        case .Warning:
            typeInfo = "WARNING"
        case .Error:
            typeInfo = "ERROR"
        }
        let source = node?.document?.source
        return (
            messageType,
            "\(String(repeating: " ", count: (stepLevel+1)<<1))\(typeInfo) (\(stepName) / \(messageID)\(source != nil ? ", \(source!)" : ""), \(pathInfo(forNode: node))): \(languages.map { language in "\(language): \(localizingMessage[language] ?? "?")" }.joined(separator: "; "))"
        )
    }
    
    open func log(stepLevel: Int, node: XNode? = nil, stepName: String, message: XMessage, arguments: String...) {
        let (theMessageType,theFullMessage) = fullMessage(stepLevel: stepLevel, node: node, stepName: stepName, message: message, arguments: arguments)
        write(theMessageType, theFullMessage)
    }
}
*/
