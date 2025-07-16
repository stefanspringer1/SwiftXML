//===--- Parsing.swift ----------------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation
import SwiftXMLInterfaces
import SwiftXMLParser

public func parseXML(
    from documentSource: XDocumentSource,
    namespaceAware: Bool = false,
    silentEmptyRootPrefix: Bool = false,
    registeringAttributes: AttributeRegisterMode = .none,
    registeringAttributeValuesFor: AttributeRegisterMode = .none,
    registeringAttributesForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
    registeringAttributeValuesForForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
    sourceInfo: String? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    internalEntityAutoResolve: Bool = false,
    internalEntityResolver: InternalEntityResolver? = nil,
    internalEntityResolverHasToResolve: Bool = true,
    insertExternalParsedEntities: Bool = false,
    externalParsedEntitySystemResolver: ((String) -> URL?)? = nil,
    externalParsedEntityGetter: ((String) -> Data?)? = nil,
    externalWrapperElement: String? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    eventHandlers: [XEventHandler]? = nil,
    immediateTextHandlingNearEntities: ImmediateTextHandlingNearEntities = .atExternalEntities
) throws -> XDocument {
    
    let document = XDocument()
    
    switch documentSource {
    case .url(url: let url):
        document._sourcePath = url.path
    case .path(path: let path):
        document._sourcePath = path
    default:
        break
    }
    
    let parser = ConvenienceParser(
        parser: XParser(
            internalEntityAutoResolve: internalEntityAutoResolve,
            internalEntityResolver: internalEntityResolver,
            internalEntityResolverHasToResolve: internalEntityResolverHasToResolve,
            textAllowedInElementWithName: textAllowedInElementWithName,
            insertExternalParsedEntities: insertExternalParsedEntities,
            externalParsedEntitySystemResolver: externalParsedEntitySystemResolver,
            externalParsedEntityGetter: externalParsedEntityGetter
        ),
        mainEventHandler: XParseBuilder(
            document: document,
            namespaceAware: namespaceAware,
            silentEmptyRootPrefix: silentEmptyRootPrefix,
            keepComments: keepComments,
            keepCDATASections: keepCDATASections,
            externalWrapperElement: externalWrapperElement,
            registeringAttributes: registeringAttributes,
            registeringAttributeValuesFor: registeringAttributeValuesFor,
            registeringAttributesForNamespaces: registeringAttributesForNamespaces,
            registeringAttributeValuesForForNamespaces: registeringAttributeValuesForForNamespaces
        )
    )
    
    try parser.parse(from: documentSource, sourceInfo: sourceInfo, eventHandlers: eventHandlers, immediateTextHandlingNearEntities: immediateTextHandlingNearEntities)
    
    return document
}

public func parseXML(
    fromPath path: String,
    namespaceAware: Bool = false,
    silentEmptyRootPrefix: Bool = false,
    registeringAttributes: AttributeRegisterMode = .none,
    registeringAttributeValuesFor: AttributeRegisterMode = .none,
    registeringAttributesForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
    registeringAttributeValuesForForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
    sourceInfo: String? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    internalEntityAutoResolve: Bool = false,
    internalEntityResolver: InternalEntityResolver? = nil,
    internalEntityResolverHasToResolve: Bool = true,
    insertExternalParsedEntities: Bool = false,
    externalParsedEntitySystemResolver: ((String) -> URL?)? = nil,
    externalParsedEntityGetter: ((String) -> Data?)? = nil,
    externalWrapperElement: String? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    eventHandlers: [XEventHandler]? = nil,
    immediateTextHandlingNearEntities: ImmediateTextHandlingNearEntities = .atExternalEntities
) throws -> XDocument {
    try parseXML(
        from: .path(path),
        namespaceAware: namespaceAware,
        silentEmptyRootPrefix: silentEmptyRootPrefix,
        registeringAttributes: registeringAttributes,
        registeringAttributeValuesFor: registeringAttributeValuesFor,
        registeringAttributesForNamespaces: registeringAttributesForNamespaces,
        registeringAttributeValuesForForNamespaces: registeringAttributeValuesForForNamespaces,
        sourceInfo: sourceInfo,
        textAllowedInElementWithName: textAllowedInElementWithName,
        internalEntityAutoResolve: internalEntityAutoResolve,
        internalEntityResolver: internalEntityResolver,
        internalEntityResolverHasToResolve: internalEntityResolverHasToResolve,
        insertExternalParsedEntities: insertExternalParsedEntities,
        externalParsedEntitySystemResolver: externalParsedEntitySystemResolver,
        externalParsedEntityGetter: externalParsedEntityGetter,
        externalWrapperElement: externalWrapperElement,
        keepComments: keepComments,
        keepCDATASections: keepCDATASections,
        eventHandlers: eventHandlers,
        immediateTextHandlingNearEntities: immediateTextHandlingNearEntities
    )
}

public func parseXML(
    fromURL url: URL,
    namespaceAware: Bool = false,
    silentEmptyRootPrefix: Bool = false,
    registeringAttributes: AttributeRegisterMode = .none,
    registeringAttributeValuesFor: AttributeRegisterMode = .none,
    registeringAttributesForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
    registeringAttributeValuesForForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
    sourceInfo: String? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    internalEntityAutoResolve: Bool = false,
    internalEntityResolver: InternalEntityResolver? = nil,
    internalEntityResolverHasToResolve: Bool = true,
    insertExternalParsedEntities: Bool = false,
    externalParsedEntitySystemResolver: ((String) -> URL?)? = nil,
    externalParsedEntityGetter: ((String) -> Data?)? = nil,
    externalWrapperElement: String? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    eventHandlers: [XEventHandler]? = nil,
    immediateTextHandlingNearEntities: ImmediateTextHandlingNearEntities = .atExternalEntities
) throws -> XDocument {
    try parseXML(
        from: .url(url),
        namespaceAware: namespaceAware,
        silentEmptyRootPrefix: silentEmptyRootPrefix,
        registeringAttributes: registeringAttributes,
        registeringAttributeValuesFor: registeringAttributeValuesFor,
        registeringAttributesForNamespaces: registeringAttributesForNamespaces,
        registeringAttributeValuesForForNamespaces: registeringAttributeValuesForForNamespaces,
        sourceInfo: sourceInfo,
        textAllowedInElementWithName: textAllowedInElementWithName,
        internalEntityAutoResolve: internalEntityAutoResolve,
        internalEntityResolver: internalEntityResolver,
        internalEntityResolverHasToResolve: internalEntityResolverHasToResolve,
        insertExternalParsedEntities: insertExternalParsedEntities,
        externalParsedEntitySystemResolver: externalParsedEntitySystemResolver,
        externalParsedEntityGetter: externalParsedEntityGetter,
        externalWrapperElement: externalWrapperElement,
        keepComments: keepComments,
        keepCDATASections: keepCDATASections,
        eventHandlers: eventHandlers,
        immediateTextHandlingNearEntities: immediateTextHandlingNearEntities
    )
}

public func parseXML(
    fromText text: String,
    namespaceAware: Bool = false,
    silentEmptyRootPrefix: Bool = false,
    registeringAttributes: AttributeRegisterMode = .none,
    registeringAttributeValuesFor: AttributeRegisterMode = .none,
    registeringAttributesForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
    registeringAttributeValuesForForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
    sourceInfo: String? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    internalEntityAutoResolve: Bool = false,
    internalEntityResolver: InternalEntityResolver? = nil,
    internalEntityResolverHasToResolve: Bool = true,
    insertExternalParsedEntities: Bool = false,
    externalParsedEntitySystemResolver: ((String) -> URL?)? = nil,
    externalParsedEntityGetter: ((String) -> Data?)? = nil,
    externalWrapperElement: String? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    eventHandlers: [XEventHandler]? = nil,
    immediateTextHandlingNearEntities: ImmediateTextHandlingNearEntities = .atExternalEntities
) throws -> XDocument {
    try parseXML(
        from: .text(text),
        namespaceAware: namespaceAware,
        silentEmptyRootPrefix: silentEmptyRootPrefix,
        registeringAttributes: registeringAttributes,
        registeringAttributeValuesFor: registeringAttributeValuesFor,
        registeringAttributesForNamespaces: registeringAttributesForNamespaces,
        registeringAttributeValuesForForNamespaces: registeringAttributeValuesForForNamespaces,
        sourceInfo: sourceInfo,
        textAllowedInElementWithName: textAllowedInElementWithName,
        internalEntityAutoResolve: internalEntityAutoResolve,
        internalEntityResolver: internalEntityResolver,
        internalEntityResolverHasToResolve: internalEntityResolverHasToResolve,
        insertExternalParsedEntities: insertExternalParsedEntities,
        externalParsedEntitySystemResolver: externalParsedEntitySystemResolver,
        externalParsedEntityGetter: externalParsedEntityGetter,
        externalWrapperElement: externalWrapperElement,
        keepComments: keepComments,
        keepCDATASections: keepCDATASections,
        eventHandlers: eventHandlers,
        immediateTextHandlingNearEntities: immediateTextHandlingNearEntities
    )
}

public func parseXML(
    fromData data: Data,
    namespaceAware: Bool = false,
    silentEmptyRootPrefix: Bool = false,
    registeringAttributes: AttributeRegisterMode = .none,
    registeringAttributeValuesFor: AttributeRegisterMode = .none,
    registeringAttributesForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
    registeringAttributeValuesForForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
    sourceInfo: String? = nil,
    internalEntityAutoResolve: Bool = false,
    internalEntityResolver: InternalEntityResolver? = nil,
    internalEntityResolverHasToResolve: Bool = true,
    eventHandlers: [XEventHandler]? = nil,
    immediateTextHandlingNearEntities: ImmediateTextHandlingNearEntities = .atExternalEntities,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    insertExternalParsedEntities: Bool = false,
    externalParsedEntitySystemResolver: ((String) -> URL?)? = nil,
    externalParsedEntityGetter: ((String) -> Data?)? = nil,
    externalWrapperElement: String? = nil,
    externalWrapperNameAttribute: String? = nil,
    externalWrapperPathAttribute: String? = nil
) throws -> XDocument {
    try parseXML(
        from: .data(data),
        namespaceAware: namespaceAware,
        silentEmptyRootPrefix: silentEmptyRootPrefix,
        registeringAttributes: registeringAttributes,
        registeringAttributeValuesFor: registeringAttributeValuesFor,
        registeringAttributesForNamespaces: registeringAttributesForNamespaces,
        registeringAttributeValuesForForNamespaces: registeringAttributeValuesForForNamespaces,
        sourceInfo: sourceInfo,
        textAllowedInElementWithName: textAllowedInElementWithName,
        internalEntityAutoResolve: internalEntityAutoResolve,
        internalEntityResolver: internalEntityResolver,
        internalEntityResolverHasToResolve: internalEntityResolverHasToResolve,
        insertExternalParsedEntities: insertExternalParsedEntities,
        externalParsedEntitySystemResolver: externalParsedEntitySystemResolver,
        externalParsedEntityGetter: externalParsedEntityGetter,
        externalWrapperElement: externalWrapperElement,
        keepComments: keepComments,
        keepCDATASections: keepCDATASections,
        eventHandlers: eventHandlers,
        immediateTextHandlingNearEntities: immediateTextHandlingNearEntities
    )
}
