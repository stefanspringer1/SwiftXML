import Foundation
import SwiftXMLInterfaces

public class XMLDocument: XMLBranch {
    
    var xmlVersion = "1.0"
    var encoding: String? = nil
    var standalone: String? = nil
    
    var type: String? = nil
    var publicID: String? = nil
    var systemID: String? = nil
    
    func setEncoding(encoding: String?) {
        self.encoding = encoding
    }
    
    func setPubID(pubID: String?) {
        self.publicID = pubID
    }
    
    func setSystemID(systemID: String) {
        self.systemID = systemID
    }
    
    public var declarationsInInternalSubset = [XMLDeclarationInInternalSubset]()
    
    var internalEntityDeclarations = [String:XMLInternalEntityDeclaration]()
    var parameterEntityDeclarations = [String:XMLParameterEntityDeclaration]()
    var externalEntityDeclarations = [String:XMLExternalEntityDeclaration]()
    var unparsedEntityDeclarations = [String:XMLUnparsedEntityDeclaration]()
    var notationDeclarations = [String:XMLNotationDeclaration]()
    var elementDeclarations = [String:XMLElementDeclaration]()
    var attributeListDeclarations = [String:XMLAttributeListDeclaration]()
    
    var elements = [String:OfEqualName<XMLElement>]()
    var attributes = [String:OfEqualName<XMLAttribute>]()
    
    public override init() {
        // empty document
    }
    
    func elementsOfEqualName(name: String) -> OfEqualName<XMLElement> {
        if let ofEqualName = elements[name] {
            return ofEqualName
        }
        else {
            let ofEqualName = OfEqualName<XMLElement>(name: name)
            elements[name] = ofEqualName
            return ofEqualName
        }
    }
    
    func elementsOfEqualAttributeName(attributeName: String) -> OfEqualName<XMLAttribute> {
        if let ofEqualAttributeName = attributes[attributeName] {
            return ofEqualAttributeName
        }
        else {
            let ofEqualAttributeName = OfEqualName<XMLAttribute>(name: attributeName)
            attributes[attributeName] = ofEqualAttributeName
            return ofEqualAttributeName
        }
    }
    
    /*func printElementsOfName(name: String) {
        print("elements with name \"\(name)\":")
        if let ofTheName = elements[name] {
            var element: XMLElement? = ofTheName.first
            while let theElement = element {
                theElement.printXML()
                element = theElement.nextWithSameName
            }
        }
    }
    
    func printElementsWithAttribute(attributeName: String) {
        print("elements with attribute \"\(attributeName)\":")
        if let ofTheAttributeName = attributes[attributeName] {
            var attribute: XMLAttribute? = ofTheAttributeName.first
            while let theAttribute = attribute {
                theAttribute.element?.printXML()
                attribute = theAttribute.nextWithSameName
            }
        }
    }*/
    
    func registerAttribute(attribute: XMLAttribute) {
        elementsOfEqualAttributeName(attributeName: attribute.name).add(named: attribute)
    }
    
    func registerElement(element: XMLElement) {
        elementsOfEqualName(name: element.name).add(named: element)
        element.attributes?.values.forEach { attribute in
            registerAttribute(attribute: attribute)
        }
    }
    
    func unregisterAttribute(attribute: XMLAttribute) {
        if let ofEqualAttributeName = attributes[attribute.name] {
            ofEqualAttributeName.remove(named: attribute)
            if ofEqualAttributeName.isEmpty() {
                attributes[attribute.name] = nil
            }
        }
    }
    
    func unregisterElement(element: XMLElement) {
        if let ofEqualName = elements[element.name] {
            ofEqualName.remove(named: element)
            if ofEqualName.isEmpty() {
                elements[element.name] = nil
            }
        }
        element.attributes?.values.forEach { attribute in
            unregisterAttribute(attribute: attribute)
        }
    }
    
    func getType() -> String? {
        var node = firstChild
        while let theNode = node {
            if let element = node as? XMLElement {
                return element.name
            }
            node = theNode.next
        }
        return nil
    }
    
    func hasInternalSubset() -> Bool {
        return !internalEntityDeclarations.isEmpty ||
            !parameterEntityDeclarations.isEmpty ||
        !externalEntityDeclarations.isEmpty ||
        !unparsedEntityDeclarations.isEmpty ||
        !notationDeclarations.isEmpty ||
        !elementDeclarations.isEmpty ||
        !attributeListDeclarations.isEmpty
    }
    
    override func produceEntering(production: XMLProduction) {
        production.documentStart()
        production.xmlDeclaration(version: xmlVersion, encoding: encoding, standalone: standalone)
        let _hasInternalSubset = hasInternalSubset()
        production.documentTypeDeclarationBeforeInternalSubset(type: getType() ?? "?", publicID: publicID, systemID: systemID, hasInternalSubset: _hasInternalSubset)
        if _hasInternalSubset {
            production.documentTypeDeclarationInternalSubsetStart()
            production.getFormatter().sortedDeclarationsInInternalSubset(document: self).forEach { declaration in
                switch declaration {
                case let internalEntityDeclaration as XMLInternalEntityDeclaration: production.internalEntityDeclaration(name: internalEntityDeclaration.name, value: internalEntityDeclaration.value)
                case let parameterEntityDeclaration as XMLParameterEntityDeclaration: production.parameterEntityDeclaration(name: parameterEntityDeclaration.name, value: parameterEntityDeclaration.value)
                case let externalEntityDeclaration as XMLExternalEntityDeclaration: production.externalEntityDeclaration(name: externalEntityDeclaration.name, publicID: externalEntityDeclaration.publicID, systemID: externalEntityDeclaration.systemID)
                case let unparsedEntityDeclaration as XMLUnparsedEntityDeclaration: production.unparsedEntityDeclaration(name: unparsedEntityDeclaration.name, publicID: unparsedEntityDeclaration.publicID, systemID: unparsedEntityDeclaration.systemID, notation: unparsedEntityDeclaration.notationName)
                case let notationDeclaration as XMLNotationDeclaration: production.notationDeclaration(name: notationDeclaration.name, publicID: notationDeclaration.publicID, systemID: notationDeclaration.systemID)
                case let elementDeclaration as XMLElementDeclaration: production.elementDeclaration(name: elementDeclaration.name, text: elementDeclaration.text)
                case let attributeListDeclaration as XMLAttributeListDeclaration: production.attributeListDeclaration(name: attributeListDeclaration.name, text: attributeListDeclaration.text)
                default:
                    break
                }
            }
            production.documentTypeDeclarationInternalSubsetEnd()
        }
        production.documentTypeDeclarationAfterInternalSubset(type: getType() ?? type ?? "unknown", publicID: publicID, systemID: systemID, hasInternalSubset: _hasInternalSubset)
    }

    override func produceLeaving(production: XMLProduction) {
        production.documentEnd()
    }
}
