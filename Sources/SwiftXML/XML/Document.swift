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
    
    public func firstChild(prefix: String?, _ name: String) -> XElement? {
        _firstChild(prefix: prefix, name)
    }
    
    public func firstChild(_ names: [String]) -> XElement? {
        _firstChild(names)
    }
    
    public func firstChild(prefix: String?, _ names: [String]) -> XElement? {
        _firstChild(prefix: prefix, names)
    }
    
    public func firstChild(_ names: String...) -> XElement? {
        _firstChild(names)
    }
    
    public func firstChild(prefix: String?, _ names: String...) -> XElement? {
        _firstChild(prefix: prefix, names)
    }
    
    public func firstChild(_ condition: (XElement) -> Bool) -> XElement? {
        _firstChild(condition)
    }
    
    public var xPath: String { "/" }
    
    var __firstContent: XContent? = nil
    
    var __lastContent: XContent? = nil
    
    var _registeringDocument: XDocument? { self }
    
    var _lastInTree: XNode!
    
    public override var top: XElement? {
        self.children.first
    }
    
    override func getLastInTree() -> XNode {
        return _lastInTree
    }
    
    var _sourcePath: String? = nil
    
    /// After cloning, this is the reference to the original node or to the cloned node respectively,
    /// acoording to the parameter used when cloning.
    ///
    /// Note that this is a weak reference, the clone must be contained by other means to exist.
    public override var backlink: XDocument? { super.backlink as? XDocument }
    
    /// Get the backlink or – if it is `nil` – the subject itself.
    public override var backlinkOrSelf: XDocument { self.backlink ?? self }
    
    /// Setting the backlink manually. The identical node is returned.
    public func setting(backlink: XDocument) -> XDocument {
        _backlink = backlink
        return self
    }
    
    /// Copying the backlink from another node. The identical node is returned.
    public func copyingBacklink(from node: XDocument) -> XDocument {
        _backlink = node._backlink
        return self
    }
    
    /// Here, the `backlink` reference are followed while they are non-nil.
    ///
    /// It is thhe oldest source or furthest target of cloning respectively, so to speak.
    public override var finalBacklink: XDocument? { get { super.finalBacklink as? XDocument } }
        
    public var sourcePath: String? {
        get {
            return _sourcePath
        }
    }
    
    private var _versions = [XDocument]()
    public var versions: [XDocument] { _versions }
    public var lastVersion: XDocument? { _versions.last }
    
    public func makeVersion(
        keepAttachments: Bool = false,
        registeringAttributes attributeRegisterMode: AttributeRegisterMode? = nil,
        registeringValuesForAttributes attributeValueRegisterMode: AttributeRegisterMode? = nil
    ) {
        let clone = _shallowClone(keepAttachments: keepAttachments, registeringAttributes: attributeRegisterMode, registeringValuesForAttributes: attributeValueRegisterMode, pointingToClone: true)
        _versions.append(clone)
        clone._addClones(from: self, pointingToClone: true, keepAttachments: keepAttachments)
    }
    
    /// Remove the last version.
    public func forgetLastVersion() {
        if _versions.count > 0 {
            _versions.removeLast()
        }
    }
    
    /// Remove versions but keep the last n ones.
    public func forgetVersions(keeping n: Int = 0) {
        if _versions.count > 0 {
            let oldVersions = _versions
            _versions = [XDocument]()
            if n > 0 {
                let startIndex = oldVersions.count - n
                if startIndex >= 0 {
                    let endIndex = oldVersions.count - 1
                    for index in startIndex...endIndex {
                        _versions.append(oldVersions[index])
                    }
                }
            }
            let lastVersion = _versions.first ?? self
            lastVersion._backlink = nil
            for content in lastVersion.allContent { content._backlink = nil }
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
    
    public override var shallowClone: XDocument {
        shallowClone()
    }
    
    public func shallowClone(
        keepAttachments: Bool = false,
        registeringAttributes attributeRegisterMode: AttributeRegisterMode? = nil,
        registeringValuesForAttributes attributeValueRegisterMode: AttributeRegisterMode? = nil
    ) -> XDocument {
        _shallowClone(
            keepAttachments: keepAttachments,
            registeringAttributes: attributeRegisterMode,
            registeringValuesForAttributes: attributeValueRegisterMode,
            pointingToClone: false
        )
    }
    
    private func _shallowClone(
        keepAttachments: Bool = false,
        registeringAttributes attributeRegisterMode: AttributeRegisterMode? = nil,
        registeringValuesForAttributes attributeValueRegisterMode: AttributeRegisterMode? = nil,
        pointingToClone: Bool
    ) -> XDocument {
        let theClone = XDocument(
            registeringAttributes: attributeRegisterMode ?? _attributeRegisterMode,
            registeringValuesForAttributes: attributeValueRegisterMode ?? _attributeValueRegisterMode
        )
        
        if pointingToClone {
            self._backlink = theClone
        } else {
            theClone._backlink = self
        }
        theClone.xmlVersion = xmlVersion
        theClone.encoding = encoding
        theClone.standalone = standalone
        theClone.type = type
        theClone.publicID = publicID
        theClone.systemID = systemID
        theClone._sourcePath = _sourcePath
        
        theClone._prefixToNamespaceURI = _prefixToNamespaceURI
        theClone._namespaceURIToPrefix = _namespaceURIToPrefix
        theClone._prefixes = _prefixes
        
        if keepAttachments { theClone.attached = attached }
        for (name, declaration) in internalEntityDeclarations { theClone.internalEntityDeclarations[name] = declaration.clone }
        for (name, declaration) in parameterEntityDeclarations { theClone.parameterEntityDeclarations[name] = declaration.clone }
        for (name, declaration) in externalEntityDeclarations { theClone.externalEntityDeclarations[name] = declaration.clone }
        for (name, declaration) in unparsedEntityDeclarations { theClone.unparsedEntityDeclarations[name] = declaration.clone }
        for (name, declaration) in notationDeclarations { theClone.notationDeclarations[name] = declaration.clone }
        for (name, declaration) in elementDeclarations { theClone.elementDeclarations[name] = declaration.clone }
        for (name, declaration) in attributeListDeclarations { theClone.attributeListDeclarations[name] = declaration.clone }
        return theClone
    }
    
    public override var clone: XDocument {
        clone()
    }
    
    public func clone(
        keepAttachments: Bool = false,
        registeringAttributes attributeRegisterMode: AttributeRegisterMode? = nil,
        registeringValuesForAttributes attributeValueRegisterMode: AttributeRegisterMode? = nil
    )  -> XDocument {
        _clone(
            keepAttachments: keepAttachments,
            registeringAttributes: attributeRegisterMode,
            registeringValuesForAttributes: attributeValueRegisterMode,
            pointingToClone: false
        )
    }
    
    private func _clone(
        keepAttachments: Bool = false,
        registeringAttributes attributeRegisterMode: AttributeRegisterMode? = nil,
        registeringValuesForAttributes attributeValueRegisterMode: AttributeRegisterMode? = nil,
        pointingToClone: Bool
    ) -> XDocument {
        let theClone = _shallowClone(
            keepAttachments: keepAttachments,
            registeringAttributes: attributeRegisterMode,
            registeringValuesForAttributes: attributeValueRegisterMode,
            pointingToClone: pointingToClone
        )
        theClone._addClones(from: self, pointingToClone: pointingToClone, keepAttachments: keepAttachments)
        if keepAttachments { theClone.attached = attached }
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
    
    var _elementsOfPrefixAndName_first = TieredDictionary<String,String,XElement>()
    var _elementsOfPrefixAndName_last = TieredDictionary<String,String,XElement>()
    
    var _namespaceURIToPrefix = [String:String]()
    var _prefixToNamespaceURI = [String:String]()
    var _prefixes = Set<String>()
    
    public func prefix(forNamespaceURI namespaceURI: String) -> String? { _namespaceURIToPrefix[namespaceURI] }
    public func namespaceURI(forPrefix prefix: String) -> String? { _prefixToNamespaceURI[prefix] }
    public var namespacePrefixesAndURIs: [(String,String)] { _prefixToNamespaceURI.sorted(by: <) }
    
    /// This method can be used to force-register a fixed prefix.
    /// Whenever possible, use `registerIndependentPrefix(withPrefixSuggestion:)` instead to avoid collisions.
    public func register(fixedPrefix prefix: String) {
        _prefixes.insert(prefix)
    }
    
    /// The function returns the actual prefix to be used to avoid collisions.
    /// This should be used whenever you need an independent prefix and you are not fixed on a specific value.
    public func registerIndependentPrefix(withPrefixSuggestion suggstedPrefix: String) -> String {
        var postfix = 1
        var prefix = suggstedPrefix
        while _prefixes.contains(prefix) {
            postfix += 1
            prefix = "\(suggstedPrefix)\(postfix)"
        }
        _prefixes.insert(prefix)
        return prefix
    }
    
    public func unregister(independentPrefix prefix: String) {
        if _prefixToNamespaceURI[prefix] == nil {
            _prefixes.remove(prefix)
        }
    }
    
    // returns the actual prefix
    public func register(namespaceURI: String, withPrefixSuggestion suggstedPrefix: String) -> String {
        if let existingPrefix = _namespaceURIToPrefix[namespaceURI] {
            return existingPrefix
        } else {
            let prefix: String
            var maybePrefix = suggstedPrefix
            var postfix = 1
            while _prefixes.contains(maybePrefix) {
                postfix += 1
                maybePrefix = "\(suggstedPrefix)\(postfix)"
            }
            prefix = maybePrefix
            _prefixes.insert(prefix)
            _namespaceURIToPrefix[namespaceURI] = prefix
            _prefixToNamespaceURI[prefix] = namespaceURI
            return prefix
        }
    }
    
    public func unregister(namespaceURI: String) {
        if let prefix = _namespaceURIToPrefix[namespaceURI] {
            _namespaceURIToPrefix[namespaceURI] = nil
            _prefixToNamespaceURI[prefix] = nil
            _prefixes.remove(prefix)
        }
    }
    
    public func unregister(namespacePrefix prefix: String) {
        if let namespaceURI = _prefixToNamespaceURI[prefix] {
            _namespaceURIToPrefix[namespaceURI] = nil
            _prefixToNamespaceURI[prefix] = nil
            _prefixes.remove(prefix)
        }
    }
    
    func registerElement(element: XElement) {
        
        // register via name:
        let name = element.name
        if let prefix = element.prefix {
            if let namespaceURI = element.namespaceURI {
                element._prefix = register(namespaceURI: namespaceURI, withPrefixSuggestion: prefix)
            } else {
                register(fixedPrefix: prefix)
            }
            if let theLast = _elementsOfPrefixAndName_last[prefix,name] {
                theLast.nextWithSameName = element
                element.previousWithSameName = theLast
            }
            else {
                _elementsOfPrefixAndName_first[prefix,name] = element
            }
            _elementsOfPrefixAndName_last[prefix,name] = element
        } else {
            if let colon = name.firstIndex(of: ":") {
                register(fixedPrefix: String(name[..<colon]))
            }
            if let theLast = _elementsOfName_last[name] {
                theLast.nextWithSameName = element
                element.previousWithSameName = theLast
            }
            else {
                _elementsOfName_first[name] = element
            }
            _elementsOfName_last[name] = element
        }
        
        // register according attributes:
        for (attributeName,attributeValue) in element._attributes {
            if attributeToBeRegistered(withName: attributeName) == true {
                let attributeProperties = AttributeProperties(value: attributeValue, element: element)
                element._registeredAttributes[attributeName] = attributeProperties
                registerAttribute(attributeProperties: attributeProperties, withName: attributeName)
            }
        }
        
        // register according attributes values:
        for (attributeName,attributeValue) in element._attributes {
            if attributeValueToBeRegistered(forAttributeName: attributeName) == true {
                let attributeProperties = AttributeProperties(value: attributeValue, element: element)
                element._registeredAttributeValues[attributeName] = attributeProperties
                registerAttributeValue(attributeProperties: attributeProperties, withName: attributeName)
            }
        }
        
        element._document = self
        element._registered = true
    }
    
    func unregisterElement(element: XElement) {
        element.gotoPreviousOnNameIterators()
        let name = element.name
        element.previousWithSameName?.nextWithSameName = element.nextWithSameName
        element.nextWithSameName?.previousWithSameName = element.previousWithSameName
        if let prefix = element.prefix {
            if _elementsOfPrefixAndName_first[prefix,name] === element {
                _elementsOfPrefixAndName_first[prefix,name] = element.nextWithSameName
            }
            if _elementsOfPrefixAndName_last[prefix,name] === element {
                _elementsOfPrefixAndName_last[prefix,name] = element.previousWithSameName
            }
        } else {
            if _elementsOfName_first[name] === element {
                _elementsOfName_first[name] = element.nextWithSameName
            }
            if _elementsOfName_last[name] === element {
                _elementsOfName_last[name] = element.previousWithSameName
            }
        }
        
        element.previousWithSameName = nil
        element.nextWithSameName = nil
        
        // unregister registered attributes:
        for (attributeName,attributeProperties) in element._registeredAttributes {
            unregisterAttribute(attributeProperties: attributeProperties, withName: attributeName)
        }
        element._registeredAttributes.removeAll()
        
        // unregister registered attribute values:
        for (attributeName,attributeProperties) in element._registeredAttributeValues {
            unregisterAttributeValue(attributeProperties: attributeProperties, withName: attributeName)
        }
        element._registeredAttributes.removeAll()
        
        element._registered = false // but keep element._document
    }
    
    public func elements(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementsOfSameNameSequence(document: self, prefix: prefix, name: name)
    }
    
    public func elements(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return elements(prefix: prefix, names)
    }
    
    public func elements(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementsOfNamesSequence(forPrefix: prefix, forNames: names, forDocument: self)
    }
    
    // -------------------------------------------------------------------------
    // attributes of same name or also same value:
    // -------------------------------------------------------------------------
    
    var _attributesOfName_first = [String:AttributeProperties]()
    var _attributesOfName_last = [String:AttributeProperties]()
    
    var _attributesOfValue_first = TieredDictionary<String,String,AttributeProperties>()
    var _attributesOfValue_last = TieredDictionary<String,String,AttributeProperties>()
    
    func registerAttribute(attributeProperties: AttributeProperties, withName name: String) {
        if let theLast = _attributesOfName_last[name] {
            theLast.nextWithCondition = attributeProperties
            attributeProperties.previousWithCondition = theLast
        }
        else {
            _attributesOfName_first[name] = attributeProperties
        }
        _attributesOfName_last[name] = attributeProperties
        attributeProperties.nextWithCondition = nil
    }
    
    func registerAttributeValue(attributeProperties: AttributeProperties, withName name: String) {
        if let theLast = _attributesOfValue_last[name,attributeProperties.value] {
            theLast.nextWithCondition = attributeProperties
            attributeProperties.previousWithCondition = theLast
        }
        else {
            _attributesOfValue_first[name,attributeProperties.value] = attributeProperties
        }
        _attributesOfValue_last[name,attributeProperties.value] = attributeProperties
        attributeProperties.nextWithCondition = nil
    }
    
    func unregisterAttribute(attributeProperties: AttributeProperties, withName name: String) {
        attributeProperties.gotoPreviousOnAttributeIterators()
        attributeProperties.previousWithCondition?.nextWithCondition = attributeProperties.nextWithCondition
        attributeProperties.nextWithCondition?.previousWithCondition = attributeProperties.previousWithCondition
        if _attributesOfName_first[name] === attributeProperties {
            _attributesOfName_first[name] = attributeProperties.nextWithCondition
        }
        if _attributesOfName_last[name] === attributeProperties {
            _attributesOfName_last[name] = attributeProperties.previousWithCondition
        }
        attributeProperties.previousWithCondition = nil
        attributeProperties.nextWithCondition = nil
    }
    
    func unregisterAttributeValue(attributeProperties: AttributeProperties, withName name: String) {
        attributeProperties.gotoPreviousOnAttributeIterators()
        attributeProperties.previousWithCondition?.nextWithCondition = attributeProperties.nextWithCondition
        attributeProperties.nextWithCondition?.previousWithCondition = attributeProperties.previousWithCondition
        if _attributesOfValue_first[name,attributeProperties.value] === attributeProperties {
            _attributesOfValue_first[name,attributeProperties.value] = attributeProperties.nextWithCondition
        }
        if _attributesOfValue_last[name,attributeProperties.value] === attributeProperties {
            _attributesOfValue_last[name,attributeProperties.value] = attributeProperties.previousWithCondition
        }
        attributeProperties.previousWithCondition = nil
        attributeProperties.nextWithCondition = nil
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
    
    public func registeredValues(_ value: String, forAttribute name: String) -> XAttributeSequence {
        return XAttributesOfSameValueSequence(document: self, attributeName: name, attributeValue: value)
    }
    
    deinit {
        
        // destroy lists of elements with same name:
        for element in _elementsOfName_first.values { element.removeFollowingWithSameName() }
        
        // destroy lists of attributes with same name:
        _attributesOfName_first.values.forEach { attribute in attribute.removeFollowingWithSameName() }
        
    }
    
    // -------------------------------------------------------------------------
    
    private let _attributeRegisterMode: AttributeRegisterMode
    private let _attributeValueRegisterMode: AttributeRegisterMode
    
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
    
    func attributeValueToBeRegistered(forAttributeName name: String) -> Bool {
        switch _attributeValueRegisterMode {
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
        registeringAttributes attributeRegisterMode: AttributeRegisterMode = .none,
        registeringValuesForAttributes attributeValueRegisterMode: AttributeRegisterMode = .none
    ) {
        self._attributeRegisterMode = attributeRegisterMode
        self._attributeValueRegisterMode = attributeValueRegisterMode
        super.init()
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
        registeringValuesForAttributes attributeValueRegisterMode: AttributeRegisterMode = .none,
        @XContentBuilder builder: () -> [XContent]
    ) {
        self.init(attached: attached, registeringAttributes: attributeRegisterMode, registeringValuesForAttributes: attributeValueRegisterMode)
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
