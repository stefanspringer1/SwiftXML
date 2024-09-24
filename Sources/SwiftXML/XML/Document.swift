//===--- Document.swift ---------------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation

final class XValue {
    var value: String
    
    init(_ value: String) {
        self.value = value
    }
}

public enum AttributeRegisterMode {
    case none; case selected(_ attributeNames: [String]); case all
}

public final class XDocument: XNode, XBranchInternal {
    
    public var firstChild: XElement? { _firstChild }
    
    public func firstChild(_ name: String) -> XElement? {
        _firstChild(name)
    }
    
    public func firstChild(_ names: [String]) -> XElement? {
        _firstChild(names)
    }
    
    public func firstChild(_ names: String...) -> XElement? {
        _firstChild(names)
    }
    
    public var xPath: String { "/" }
    
    var __firstContent: XContent? = nil
    
    var __lastContent: XContent? = nil
    
    weak var _document: XDocument?
    
    var _lastInTree: XNode!
    
    public override var top: XElement? {
        self.children.first
    }
    
    override func getLastInTree() -> XNode {
        return _lastInTree
    }
    
    var _sourcePath: String? = nil
    
    public override var backLink: XDocument? { get { super.backLink as? XDocument } }
    public override var finalBackLink: XDocument? { get { super.finalBackLink as? XDocument } }
        
    public var sourcePath: String? {
        get {
            return _sourcePath
        }
    }
    
    private var versions = [XDocument]()
    
    public func makeVersion() {
        let clone = shallowClone()
        versions.append(clone)
        clone._addClones(from: self, pointingToClone: true)
    }
    
    /// Remove the last version.
    public func forgetLastVersion() {
        if versions.count > 0 {
            versions.removeLast()
        }
    }
    
    /// Remove versions but keep the last n ones.
    public func forgetVersions(keeping n: Int = 0) {
        if versions.count > 0 {
            let oldVersions = versions
            versions = [XDocument]()
            if n > 0 {
                let startIndex = oldVersions.count - n
                if startIndex >= 0 {
                    let endIndex = oldVersions.count - 1
                    for index in startIndex...endIndex {
                        versions.append(oldVersions[index])
                    }
                }
            }
            let lastVersion = versions.first ?? self
            lastVersion._backLink = nil
            for content in lastVersion.allContent { content._backLink = nil }
        }
    }
    
    public var xmlVersion = "1.0"
    public var encoding: String? = nil
    public var standalone: String? = nil
    
    var type: String? = nil
    public var publicID: String? = nil
    public var systemID: String? = nil
    
    // ------------------------------------------------------------------------
    // repeat methods from XBranchInternal:
    
    public var firstContent: XContent? { _firstContent }
    
    public func firstContent(_ condition: (XContent) -> Bool) -> XContent? {
        return _firstContent(condition)
    }
    
    public var lastContent: XContent? { _lastContent }
    
    public func lastContent(_ condition: (XContent) -> Bool) -> XContent? {
        return _lastContent(condition)
    }
    
    public var singleContent: XContent? { _singleContent }
    
    public var isEmpty: Bool { _isEmpty }
    
    public func add(@XContentBuilder builder: () -> [XContent]) {
        return _add(builder())
    }
    
    public func addFirst(@XContentBuilder builder: () -> [XContent]) {
        return _addFirst(builder())
    }
    
    public func setContent(@XContentBuilder builder: () -> [XContent]) {
        return _setContent(builder())
    }
    
    public func clear() {
        return _clear()
    }
    
    // ------------------------------------------------------------------------
    
    public override func shallowClone() -> XDocument {
        let theClone = XDocument()
        theClone._backLink = self
        theClone.xmlVersion = xmlVersion
        theClone.encoding = encoding
        theClone.standalone = standalone
        theClone.type = type
        theClone.publicID = publicID
        theClone.systemID = systemID
        theClone._sourcePath = _sourcePath
        for (name, declaration) in internalEntityDeclarations { theClone.internalEntityDeclarations[name] = declaration.clone() }
        for (name, declaration) in parameterEntityDeclarations { theClone.parameterEntityDeclarations[name] = declaration.clone() }
        for (name, declaration) in externalEntityDeclarations { theClone.externalEntityDeclarations[name] = declaration.clone() }
        for (name, declaration) in unparsedEntityDeclarations { theClone.unparsedEntityDeclarations[name] = declaration.clone() }
        for (name, declaration) in notationDeclarations { theClone.notationDeclarations[name] = declaration.clone() }
        for (name, declaration) in elementDeclarations { theClone.elementDeclarations[name] = declaration.clone() }
        for (name, declaration) in attributeListDeclarations { theClone.attributeListDeclarations[name] = declaration.clone() }
        return theClone
    }
    
    public override func clone() -> XDocument {
        let theClone = shallowClone()
        theClone._addClones(from: self)
        return theClone
    }
    
    public var internalEntityDeclarations = [String:XInternalEntityDeclaration]()
    public var parameterEntityDeclarations = [String:XParameterEntityDeclaration]()
    public var externalEntityDeclarations = [String:XExternalEntityDeclaration]()
    public var unparsedEntityDeclarations = [String:XUnparsedEntityDeclaration]()
    public var notationDeclarations = [String:XNotationDeclaration]()
    public var elementDeclarations = [String:XElementDeclaration]()
    public var attributeListDeclarations = [String:XAttributeListDeclaration]()
    
    // -------------------------------------------------------------------------
    // elements of same name:
    // -------------------------------------------------------------------------
    
    var _elementsOfName_first = [String:XElement]()
    var _elementsOfName_last = [String:XElement]()
    
    func registerElement(element: XElement) {
        
        // register via name:
        let name = element.name
        if let theLast = _elementsOfName_last[name] {
            theLast.nextWithSameName = element
            element.previousWithSameName = theLast
        }
        else {
            _elementsOfName_first[name] = element
        }
        _elementsOfName_last[name] = element
        
        // register according attributes:
        for (attributeName,attributeValue) in element._attributes {
            if _document?.attributeToBeRegistered(withName: attributeName) == true {
                let attributeProperties = AttributeProperties(value: attributeValue, element: element)
                element._registeredAttributes[attributeName] = attributeProperties
                registerAttribute(attributeProperties: attributeProperties, withName: attributeName)
            }
        }
        
        element._document = self
    }
    
    func unregisterElement(element: XElement) {
        element.gotoPreviousOnNameIterators()
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
        
        // unregister registered attributes:
        for (attributeName,attributeProperties) in element._registeredAttributes {
            unregisterAttribute(attributeProperties: attributeProperties, withName: attributeName)
        }
        element._registeredAttributes.removeAll()
        
        element._document = nil
    }
    
    public func elements(_ name: String) -> XElementSequence {
        return XElementsOfSameNameSequence(document: self, name: name)
    }
    
    public func elements(_ names: String...) -> XElementSequence {
        return elements(names)
    }
    
    public func elements(_ names: [String]) -> XElementSequence {
        return XElementsOfNamesSequence(forNames: names, forDocument: self)
    }
    
    // -------------------------------------------------------------------------
    // attributes of same name:
    // -------------------------------------------------------------------------
    
    var _attributesOfName_first = [String:AttributeProperties]()
    var _attributesOfName_last = [String:AttributeProperties]()
    
    func registerAttribute(attributeProperties: AttributeProperties, withName name: String) {
        if let theLast = _attributesOfName_last[name] {
            theLast.nextWithSameName = attributeProperties
            attributeProperties.previousWithSameName = theLast
        }
        else {
            _attributesOfName_first[name] = attributeProperties
        }
        _attributesOfName_last[name] = attributeProperties
        attributeProperties.nextWithSameName = nil
    }
    
    func unregisterAttribute(attributeProperties: AttributeProperties, withName name: String) {
        attributeProperties.gotoPreviousOnAttributeIterators()
        attributeProperties.previousWithSameName?.nextWithSameName = attributeProperties.nextWithSameName
        attributeProperties.nextWithSameName?.previousWithSameName = attributeProperties.previousWithSameName
        if _attributesOfName_first[name] === attributeProperties {
            _attributesOfName_first[name] = attributeProperties.nextWithSameName
        }
        if _attributesOfName_last[name] === attributeProperties {
            _attributesOfName_last[name] = attributeProperties.previousWithSameName
        }
        attributeProperties.previousWithSameName = nil
        attributeProperties.nextWithSameName = nil
    }
    
    public func registeredAttributes(_ name: String) -> XAttributeSequence {
        return XAttributesOfSameNameSequence(document: self, attributeName: name)
    }
    
    public func registeredAttributes(_ names: String...) -> XAttributeSequence {
        return registeredAttributes(names)
    }
    
    public func registeredAttributes(_ names: [String]) -> XAttributeSequence {
        return XAttributesOfNamesSequence(forNames: names, forDocument: self)
    }
    
    deinit {
        
        // destroy lists of elements with same name:
        for element in _elementsOfName_first.values { element.removeFollowingWithSameName() }
        
        // destroy lists of attributes with same name:
        _attributesOfName_first.values.forEach { attribute in attribute.removeFollowingWithSameName() }
        
    }
    
    // -------------------------------------------------------------------------
    
    private let _attributeRegisterMode: AttributeRegisterMode
    
    func attributeToBeRegistered(withName name: String) -> Bool {
        switch _attributeRegisterMode {
        case .none:
            false
        case .selected(let attributeNames):
            attributeNames.contains(name)
        case .all:
            true
        }
    }
    
    public init(
        attached: [String:Any?]? = nil,
        registeringAttributes attributeRegisterMode: AttributeRegisterMode = .none
    ) {
        self._attributeRegisterMode = attributeRegisterMode
        super.init()
        _document = self
        self._lastInTree = self
        if let attached {
            for (key,value) in attached {
                if let value {
                    self.attached[key] =  value
                }
            }
        }
    }
    
    public convenience init(
        attached: [String:Any?]? = nil,
        registeringAttributes attributeRegisterMode: AttributeRegisterMode = .none,
        @XContentBuilder builder: () -> [XContent]
    ) {
        self.init(attached: attached, registeringAttributes: attributeRegisterMode)
        for node in builder() {
            _add(node)
        }
    }
    
    func getType() -> String? {
        var node = __firstContent
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
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeDocumentStart(document: self)
        try activeProduction.writeXMLDeclaration(version: xmlVersion, encoding: encoding, standalone: standalone)
        let _hasInternalSubset = hasInternalSubset()
        try activeProduction.writeDocumentTypeDeclarationBeforeInternalSubset(type: getType() ?? "?", publicID: publicID, systemID: systemID, hasInternalSubset: _hasInternalSubset)
        if _hasInternalSubset {
            try activeProduction.writeDocumentTypeDeclarationInternalSubsetStart()
            for declaration in activeProduction.sortDeclarationsInInternalSubset(document: self) {
                switch declaration {
                case let internalEntityDeclaration as XInternalEntityDeclaration: try activeProduction.writeInternalEntityDeclaration(internalEntityDeclaration: internalEntityDeclaration)
                case let parameterEntityDeclaration as XParameterEntityDeclaration: try activeProduction.writeParameterEntityDeclaration(parameterEntityDeclaration: parameterEntityDeclaration)
                case let externalEntityDeclaration as XExternalEntityDeclaration: try activeProduction.writeExternalEntityDeclaration(externalEntityDeclaration: externalEntityDeclaration)
                case let unparsedEntityDeclaration as XUnparsedEntityDeclaration: try activeProduction.writeUnparsedEntityDeclaration(unparsedEntityDeclaration: unparsedEntityDeclaration)
                case let notationDeclaration as XNotationDeclaration: try activeProduction.writeNotationDeclaration(notationDeclaration: notationDeclaration)
                case let elementDeclaration as XElementDeclaration: try activeProduction.writeElementDeclaration(elementDeclaration: elementDeclaration)
                case let attributeListDeclaration as XAttributeListDeclaration: try activeProduction.writeAttributeListDeclaration(attributeListDeclaration: attributeListDeclaration)
                default:
                    break
                }
            }
            try activeProduction.writeDocumentTypeDeclarationInternalSubsetEnd()
        }
        try activeProduction.writeDocumentTypeDeclarationAfterInternalSubset(hasInternalSubset: _hasInternalSubset)
    }

    func produceLeaving(activeProduction: ActiveDefaultProduction) throws {
        try activeProduction.writeDocumentEnd(document: self)
    }
    
    public func trimWhiteSpace() {
        self._trimWhiteSpace()
    }
    
    public func trimmimgWhiteSpace() -> XDocument {
        self._trimWhiteSpace()
        return self
    }
}
