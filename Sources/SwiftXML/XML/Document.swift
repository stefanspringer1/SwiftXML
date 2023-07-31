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

public final class XDocument: XNode, XBranchInternal {
    
    var __firstContent: XContent? = nil
    
    var __lastContent: XContent? = nil
    
    weak var _document: XDocument?
    
    var _lastInTree: XNode!
    
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
            lastVersion.allContent.forEach { $0._backLink = nil }
        }
    }
    
    public var xmlVersion = "1.0"
    public var encoding: String? = nil
    public var standalone: String? = nil
    
    /// Read the the full prefix for a namespace URL string from the root element.
    /// "Full" means that a closing ":" is added automatically.
    /// If no prefix is defined, an empty string is returned.
    public func fullPrefix(forNamespace namespace: String) -> String {
        self.children.first?.fullPrefix(forNamespace: namespace) ?? ""
    }
    
    /// Read a map from the namespace URL strings to the full prefixes from the root element.
    /// "Full" means that a closing ":" is added automatically.
    public var fullPrefixesForNamespaces: [String:String] {
        self.children.first?.fullPrefixesForNamespaces ?? [String:String]()
    }
    
    /// Add the according namespace declaration at the root element.
    /// The prefix might be a "full" prefix, i.e. it could contain a closing ":".
    /// An existing namespace declaration for the same namespace but with another prefix is not (!) removed.
    public func setNamespace(_ namespace: String, withPossiblyFullPrefix possiblyFullPrefix: String) {
        self.children.first?.setNamespace(namespace, withPossiblyFullPrefix: possiblyFullPrefix)
    }
    
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
    
    public override func applying(_ f: (XDocument) -> ()) -> XDocument {
        f(self)
        return self
    }
    
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
        internalEntityDeclarations.forEach { name, declaration in theClone.internalEntityDeclarations[name] = declaration.clone() }
        parameterEntityDeclarations.forEach { name, declaration in theClone.parameterEntityDeclarations[name] = declaration.clone() }
        externalEntityDeclarations.forEach { name, declaration in theClone.externalEntityDeclarations[name] = declaration.clone() }
        unparsedEntityDeclarations.forEach { name, declaration in theClone.unparsedEntityDeclarations[name] = declaration.clone() }
        notationDeclarations.forEach { name, declaration in theClone.notationDeclarations[name] = declaration.clone() }
        elementDeclarations.forEach { name, declaration in theClone.elementDeclarations[name] = declaration.clone() }
        attributeListDeclarations.forEach { name, declaration in theClone.attributeListDeclarations[name] = declaration.clone() }
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
        let name = element.name
        if let theLast = _elementsOfName_last[name] {
            theLast.nextWithSameName = element
            element.previousWithSameName = theLast
        }
        else {
            _elementsOfName_first[name] = element
        }
        _elementsOfName_last[name] = element
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
    }
    
    public func elements(ofName name: String) -> XElementSequence {
        return XElementsOfSameNameSequence(document: self, name: name)
    }
    
    public func elements(ofName names: String...) -> XElementSequence {
        return elements(ofName: names)
    }
    
    public func elements(ofName names: [String]) -> XElementSequence {
        return XElementsOfNamesSequence(forNames: names, forDocument: self)
    }
    
    deinit {
        // destroy lists of elements with same name:
        _elementsOfName_first.values.forEach { element in element.removeFollowingWithSameName() }
    }
    
    // -------------------------------------------------------------------------
    
    public init(
        attached: [String:Any?]? = nil
    ) {
        super.init()
        _document = self
        self._lastInTree = self
        attached?.forEach { (key,value) in
            if let value {
                self.attached[key] =  value
            }
        }
    }
    
    public convenience init(
        attached: [String:Any?]? = nil,
        elementNamesToRegister: Set<String>? = nil,
        attributeNamesToRegister: Set<String>? = nil,
        @XContentBuilder builder: () -> [XContent]
    ) {
        self.init(attached: attached)
        builder().forEach { node in
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
    
    public func trimWhiteSpace() {
        self._trimWhiteSpace()
    }
    
    public func trimmimgWhiteSpace() -> XDocument {
        self._trimWhiteSpace()
        return self
    }
}
