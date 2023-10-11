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
    sourceInfo: String? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    internalEntityAutoResolve: Bool = false,
    internalEntityResolver: InternalEntityResolver? = nil,
    insertExternalParsedEntities: Bool = false,
    externalParsedEntitySystemResolver: ((String) -> URL?)? = nil,
    externalParsedEntityGetter: ((String) -> Data?)? = nil,
    externalWrapperElement: String? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    eventHandlers: [XEventHandler]? = nil
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
            textAllowedInElementWithName: textAllowedInElementWithName,
            insertExternalParsedEntities: insertExternalParsedEntities,
            externalParsedEntitySystemResolver: externalParsedEntitySystemResolver,
            externalParsedEntityGetter: externalParsedEntityGetter
        ),
        mainEventHandler: XParseBuilder(
            document: document,
            keepComments: keepComments,
            keepCDATASections: keepCDATASections,
            externalWrapperElement: externalWrapperElement
        )
    )
    
    try parser.parse(from: documentSource, sourceInfo: sourceInfo, eventHandlers: eventHandlers)
    
    return document
}

public func parseXML(
    fromPath path: String,
    sourceInfo: String? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    internalEntityAutoResolve: Bool = false,
    internalEntityResolver: InternalEntityResolver? = nil,
    insertExternalParsedEntities: Bool = false,
    externalParsedEntitySystemResolver: ((String) -> URL?)? = nil,
    externalParsedEntityGetter: ((String) -> Data?)? = nil,
    externalWrapperElement: String? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    eventHandlers: [XEventHandler]? = nil
) throws -> XDocument {
    try parseXML(
        from: .path(path),
        sourceInfo: sourceInfo,
        textAllowedInElementWithName: textAllowedInElementWithName,
        internalEntityAutoResolve: internalEntityAutoResolve,
        internalEntityResolver: internalEntityResolver,
        insertExternalParsedEntities: insertExternalParsedEntities,
        externalParsedEntitySystemResolver: externalParsedEntitySystemResolver,
        externalParsedEntityGetter: externalParsedEntityGetter,
        externalWrapperElement: externalWrapperElement,
        keepComments: keepComments,
        keepCDATASections: keepCDATASections,
        eventHandlers: eventHandlers
    )
}

public func parseXML(
    fromURL url: URL,
    sourceInfo: String? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    internalEntityAutoResolve: Bool = false,
    internalEntityResolver: InternalEntityResolver? = nil,
    insertExternalParsedEntities: Bool = false,
    externalParsedEntitySystemResolver: ((String) -> URL?)? = nil,
    externalParsedEntityGetter: ((String) -> Data?)? = nil,
    externalWrapperElement: String? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    eventHandlers: [XEventHandler]? = nil
) throws -> XDocument {
    try parseXML(
        from: .url(url),
        sourceInfo: sourceInfo,
        textAllowedInElementWithName: textAllowedInElementWithName,
        internalEntityAutoResolve: internalEntityAutoResolve,
        internalEntityResolver: internalEntityResolver,
        insertExternalParsedEntities: insertExternalParsedEntities,
        externalParsedEntitySystemResolver: externalParsedEntitySystemResolver,
        externalParsedEntityGetter: externalParsedEntityGetter,
        externalWrapperElement: externalWrapperElement,
        keepComments: keepComments,
        keepCDATASections: keepCDATASections,
        eventHandlers: eventHandlers
    )
}

public func parseXML(
    fromText text: String,
    sourceInfo: String? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    internalEntityAutoResolve: Bool = false,
    internalEntityResolver: InternalEntityResolver? = nil,
    insertExternalParsedEntities: Bool = false,
    externalParsedEntitySystemResolver: ((String) -> URL?)? = nil,
    externalParsedEntityGetter: ((String) -> Data?)? = nil,
    externalWrapperElement: String? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    eventHandlers: [XEventHandler]? = nil
) throws -> XDocument {
    try parseXML(
        from: .text(text),
        sourceInfo: sourceInfo,
        textAllowedInElementWithName: textAllowedInElementWithName,
        internalEntityAutoResolve: internalEntityAutoResolve,
        internalEntityResolver: internalEntityResolver,
        insertExternalParsedEntities: insertExternalParsedEntities,
        externalParsedEntitySystemResolver: externalParsedEntitySystemResolver,
        externalParsedEntityGetter: externalParsedEntityGetter,
        externalWrapperElement: externalWrapperElement,
        keepComments: keepComments,
        keepCDATASections: keepCDATASections,
        eventHandlers: eventHandlers
    )
}

public func parseXML(
    fromData data: Data,
    sourceInfo: String? = nil,
    internalEntityAutoResolve: Bool = false,
    internalEntityResolver: InternalEntityResolver? = nil,
    eventHandlers: [XEventHandler]? = nil,
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
        sourceInfo: sourceInfo,
        textAllowedInElementWithName: textAllowedInElementWithName,
        internalEntityAutoResolve: internalEntityAutoResolve,
        internalEntityResolver: internalEntityResolver,
        insertExternalParsedEntities: insertExternalParsedEntities,
        externalParsedEntitySystemResolver: externalParsedEntitySystemResolver,
        externalParsedEntityGetter: externalParsedEntityGetter,
        externalWrapperElement: externalWrapperElement,
        keepComments: keepComments,
        keepCDATASections: keepCDATASections,
        eventHandlers: eventHandlers
    )
}
