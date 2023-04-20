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
    let document = XDocument()
    document._sourcePath = path
    
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
    
    try parser.parse(fromPath: path, sourceInfo: sourceInfo, eventHandlers: eventHandlers)
    
    return document
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
    let document = XDocument()
    document._sourcePath = url.path
    
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
    
    try parser.parse(fromURL: url, sourceInfo: sourceInfo, eventHandlers: eventHandlers)
    
    return document
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
    let document = XDocument()
    
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
    
    try parser.parse(fromText: text, sourceInfo: sourceInfo, eventHandlers: eventHandlers)
    
    return document
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
    let document = XDocument()
    
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
    
    try parser.parse(fromData: data, sourceInfo: sourceInfo, eventHandlers: eventHandlers)
    
    return document
}
