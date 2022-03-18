//
//  Document.swift
//
//  Created 2021 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation

final class XValue {
    var value: String
    
    init(_ value: String) {
        self.value = value
    }
}

public final class XDocument: XNode, XBranchInternal {

    var _firstContent: XContent? = nil
    
    var _lastContent: XContent? = nil
    
    var _document: XDocument?
    
    var _lastInTree: XNode!
    
    var _sourcePath: String? = nil
    
    public override var r: XDocument? { get { super.r as? XDocument } }
    public override var rr: XDocument? { get { super.rr as? XDocument } }
    
    public var attached = Attachments()
    
    public var sourcePath: String? {
        get {
            return _sourcePath
        }
    }
    
    public func saveVersion() {
        _ = clone(pointingFromClone: true)
    }
    
    public var xmlVersion = "1.0"
    public var encoding: String? = nil
    public var standalone: String? = nil
    
    var type: String? = nil
    public var publicID: String? = nil
    public var systemID: String? = nil
    
    var attributeValueChangedActions = [String:(XElement,String?,String?)->()]()
    
    func attributeValueChanged(element: XElement, name: String, oldValue: String?, newValue: String?) {
        attributeValueChangedActions[name]?(element,oldValue,newValue)
    }
    
    public func setChangedAction(forAttributeName attributeName: String, action: @escaping (XElement,String?,String?)->()) {
        attributeValueChangedActions[attributeName] = action
    }
    
    public func removeChangedAction(forAttributeName attributeName: String) {
        attributeValueChangedActions[attributeName] = nil
    }
    
    // ------------------------------------------------------------------------
    // more precisely typed versions for methods from XBranch:
    
    @discardableResult public func add(skip: Bool = false, @XNodeBuilder builder: () -> [XContent]) -> XDocument {
        _ = (self as XBranch).add(skip: skip, builder: builder)
        return self
    }
    
    @discardableResult public func addFirst(skip: Bool = false, @XNodeBuilder builder: () -> [XContent]) -> XDocument {
        _ = (self as XBranch).add(skip: skip, builder: builder)
        return self
    }
    
    /**
     Set the contents of the document.
     If "forward", then detaching prefetches the next node in iterators.
     */
    @discardableResult public func setContent(forward: Bool = false, @XNodeBuilder builder: () -> [XContent]) -> XDocument {
        _ = (self as XBranch).setContent(forward: forward, builder: builder)
        return self
    }
    
    @discardableResult func clear(forward: Bool) -> XDocument {
        _ = (self as XBranch).clear(forward: forward)
        return self
    }
    
    // ------------------------------------------------------------------------
    
    public override func shallowClone(forwardref: Bool = false) -> XDocument {
        let theClone = XDocument()
        if forwardref {
            _r = theClone
        }
        else {
            theClone._r = self
        }
        theClone.xmlVersion = xmlVersion
        theClone.encoding = encoding
        theClone.standalone = standalone
        theClone.type = type
        theClone.publicID = publicID
        theClone.systemID = systemID
        theClone._sourcePath = _sourcePath
        internalEntityDeclarations.forEach { name, declaration in theClone.internalEntityDeclarations[name] = declaration.shallowClone() }
        parameterEntityDeclarations.forEach { name, declaration in theClone.parameterEntityDeclarations[name] = declaration.shallowClone() }
        externalEntityDeclarations.forEach { name, declaration in theClone.externalEntityDeclarations[name] = declaration.shallowClone() }
        unparsedEntityDeclarations.forEach { name, declaration in theClone.unparsedEntityDeclarations[name] = declaration.shallowClone() }
        notationDeclarations.forEach { name, declaration in theClone.notationDeclarations[name] = declaration.shallowClone() }
        elementDeclarations.forEach { name, declaration in theClone.elementDeclarations[name] = declaration.shallowClone() }
        attributeListDeclarations.forEach { name, declaration in theClone.attributeListDeclarations[name] = declaration.shallowClone() }
        return theClone
    }
    
    public override func clone(pointingFromClone: Bool = false) -> XDocument {
        let theClone = shallowClone(forwardref: pointingFromClone)
        theClone.addClones(from: self, forwardref: pointingFromClone)
        return theClone
    }
    
    public var declarationsInInternalSubset = [XDeclarationInInternalSubset]()
    
    var internalEntityDeclarations = [String:XInternalEntityDeclaration]()
    var parameterEntityDeclarations = [String:XParameterEntityDeclaration]()
    var externalEntityDeclarations = [String:XExternalEntityDeclaration]()
    var unparsedEntityDeclarations = [String:XUnparsedEntityDeclaration]()
    var notationDeclarations = [String:XNotationDeclaration]()
    var elementDeclarations = [String:XElementDeclaration]()
    var attributeListDeclarations = [String:XAttributeListDeclaration]()
    
    // -------------------------------------------------------------------------
    // elements of same name:
    // -------------------------------------------------------------------------
    
    var _elementsOfName_first = [String:XElement]()
    var _elementsOfName_last = [String:XElement]()
    
    func registerElement(element: XElement) {
        let name = element.name
        if let theLast = _elementsOfName_last[name] {
            theLast.nextWithSameName = element
            element.previousWithSameName = theLast
        }
        else {
            _elementsOfName_first[name] = element
        }
        _elementsOfName_last[name] = element
        
        // register attributes:
        element._attributes?.values.forEach { attribute in
            registerAttribute(attribute: attribute)
        }
    }
    
    func unregisterElement(element: XElement) {
        element._nameIterators.forEach { _ = $0.previous() }
        let name = element.name
        element.previousWithSameName?.nextWithSameName = element.nextWithSameName
        element.nextWithSameName?.previousWithSameName = element.previousWithSameName
        if _elementsOfName_first[name] === element {
            _elementsOfName_first[name] = element.nextWithSameName
        }
        if _elementsOfName_last[name] === element {
            _elementsOfName_last[name] = element.previousWithSameName
        }
        element.previousWithSameName = nil
        element.nextWithSameName = nil
        
        // unregister attributes:
        element._attributes?.values.forEach { attribute in
            unregisterAttribute(attribute: attribute)
        }
    }
    
    public func elements(ofName elementName: String) -> XElementSequence {
        return XElementsOfSameNameSequence(document: self, name: elementName)
    }
    
    // -------------------------------------------------------------------------
    // attributes of same name:
    // -------------------------------------------------------------------------
    
    var _attributesOfName_first = [String:XAttribute]()
    var _attributesOfName_last = [String:XAttribute]()
    
    deinit {
        
        // destroy lists of elements with same name:
        _elementsOfName_first.values.forEach { element in element.removeFollowingWithSameName() }
            
        // destroy lists of attributes with same name:
        _attributesOfName_first.values.forEach { attribute in attribute.removeFollowingWithSameName() }
        
    }
    
    func registerAttribute(attribute: XAttribute) {
        let name = attribute.name
        if let theLast = _attributesOfName_last[name] {
            theLast.nextWithSameName = attribute
            attribute.previousWithSameName = theLast
        }
        else {
            _attributesOfName_first[name] = attribute
        }
        _attributesOfName_last[name] = attribute
        attribute.nextWithSameName = nil
    }
    
    func unregisterAttribute(attribute: XAttribute) {
        attribute.attributeIterators.forEach { _ = $0.previous() }
        let name = attribute.name
        attribute.previousWithSameName?.nextWithSameName = attribute.nextWithSameName
        attribute.nextWithSameName?.previousWithSameName = attribute.previousWithSameName
        if _attributesOfName_first[name] === attribute {
            _attributesOfName_first[name] = attribute.nextWithSameName
        }
        if _attributesOfName_last[name] === attribute {
            _attributesOfName_last[name] = attribute.previousWithSameName
        }
        attribute.previousWithSameName = nil
        attribute.nextWithSameName = nil
    }
    
    public func attributes(ofName attributeName: String) -> XAttributeSequence {
        return XAttributesOfSameNameSequence(
            document: self,
            attributeName: attributeName
        )
    }
    
    // -------------------------------------------------------------------------
    
    public override init() {
        super.init()
        _document = self
        self._lastInTree = self
    }
    
    func getType() -> String? {
        var node = _firstContent
        while let theNode = node {
            if let element = node as? XElement {
                return element.name
            }
            node = theNode._next
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
    
    override func produceEntering(production: XProduction) throws {
        try production.writeDocumentStart(document: self)
        try production.writeXMLDeclaration(version: xmlVersion, encoding: encoding, standalone: standalone)
        let _hasInternalSubset = hasInternalSubset()
        try production.writeDocumentTypeDeclarationBeforeInternalSubset(type: getType() ?? "?", publicID: publicID, systemID: systemID, hasInternalSubset: _hasInternalSubset)
        if _hasInternalSubset {
            try production.writeDocumentTypeDeclarationInternalSubsetStart()
            try production.sortDeclarationsInInternalSubset(document: self).forEach { declaration in
                switch declaration {
                case let internalEntityDeclaration as XInternalEntityDeclaration: try production.writeInternalEntityDeclaration(internalEntityDeclaration: internalEntityDeclaration)
                case let parameterEntityDeclaration as XParameterEntityDeclaration: try production.writeParameterEntityDeclaration(parameterEntityDeclaration: parameterEntityDeclaration)
                case let externalEntityDeclaration as XExternalEntityDeclaration: try production.writeExternalEntityDeclaration(externalEntityDeclaration: externalEntityDeclaration)
                case let unparsedEntityDeclaration as XUnparsedEntityDeclaration: try production.writeUnparsedEntityDeclaration(unparsedEntityDeclaration: unparsedEntityDeclaration)
                case let notationDeclaration as XNotationDeclaration: try production.writeNotationDeclaration(notationDeclaration: notationDeclaration)
                case let elementDeclaration as XElementDeclaration: try production.writeElementDeclaration(elementDeclaration: elementDeclaration)
                case let attributeListDeclaration as XAttributeListDeclaration: try production.writeAttributeListDeclaration(attributeListDeclaration: attributeListDeclaration)
                default:
                    break
                }
            }
            try production.writeDocumentTypeDeclarationInternalSubsetEnd()
        }
        try production.writeDocumentTypeDeclarationAfterInternalSubset(hasInternalSubset: _hasInternalSubset)
    }

    func produceLeaving(production: XProduction) throws {
        try production.writeDocumentEnd(document: self)
    }
}
