//
//  Parsing.swift
//
//  Created 2021 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation
import SwiftXMLInterfaces
import SwiftXMLParser

// XML:

public func parseXML(
    fromPath path: String,
    sourceInfo: String? = nil,
    internalEntityResolver: InternalEntityResolver? = nil,
    eventHandlers: [XEventHandler]? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    insertExternalParsedEntities: Bool = false,
    externalWrapperElement: String? = nil,
    externalWrapperNameAttribute: String? = nil,
    externalWrapperPathAttribute: String? = nil
) throws -> XDocument {
    let document = XDocument()
    document._sourcePath = path
    
    let parser = ConvenienceParser(
        parser: XParser(internalEntityResolver: internalEntityResolver, textAllowedInElementWithName: textAllowedInElementWithName),
        mainEventHandler: XParseBuilder(
            document: document,
            keepComments: keepComments,
            keepCDATASections: keepCDATASections,
            insertExternalParsedEntities: insertExternalParsedEntities,
            externalWrapperElement: externalWrapperElement,
            externalWrapperNameAttribute: externalWrapperNameAttribute,
            externalWrapperPathAttribute: externalWrapperPathAttribute
        )
    )
    
    try parser.parse(fromPath: path, sourceInfo: sourceInfo, eventHandlers: eventHandlers)
    
    return document
}

public func parseXML(
    fromURL url: URL,
    sourceInfo: String? = nil,
    internalEntityResolver: InternalEntityResolver? = nil,
    eventHandlers: [XEventHandler]? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    insertExternalParsedEntities: Bool = false,
    externalWrapperElement: String? = nil,
    externalWrapperNameAttribute: String? = nil,
    externalWrapperPathAttribute: String? = nil
) throws -> XDocument {
    let document = XDocument()
    document._sourcePath = url.path
    
    let parser = ConvenienceParser(
        parser: XParser(
            internalEntityResolver: internalEntityResolver,
            textAllowedInElementWithName: textAllowedInElementWithName
        ),
        mainEventHandler: XParseBuilder(
            document: document,
            keepComments: keepComments,
            keepCDATASections: keepCDATASections,
            insertExternalParsedEntities: insertExternalParsedEntities,
            externalWrapperElement: externalWrapperElement,
            externalWrapperNameAttribute: externalWrapperNameAttribute,
            externalWrapperPathAttribute: externalWrapperPathAttribute
        )
    )
    
    try parser.parse(
        fromURL: url,
        sourceInfo: sourceInfo,
        eventHandlers: eventHandlers)
    
    return document
}

public func parseXML(
    fromText text: String,
    sourceInfo: String? = nil,
    internalEntityResolver: InternalEntityResolver? = nil,
    eventHandlers: [XEventHandler]? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    insertExternalParsedEntities: Bool = false,
    externalWrapperElement: String? = nil,
    externalWrapperNameAttribute: String? = nil,
    externalWrapperPathAttribute: String? = nil
) throws -> XDocument {
    let document = XDocument()
    
    let parser = ConvenienceParser(
        parser: XParser(
            internalEntityResolver: internalEntityResolver,
            textAllowedInElementWithName: textAllowedInElementWithName
        ),
        mainEventHandler: XParseBuilder(
            document: document,
            keepComments: keepComments,
            keepCDATASections: keepCDATASections,
            insertExternalParsedEntities: insertExternalParsedEntities,
            externalWrapperElement: externalWrapperElement,
            externalWrapperNameAttribute: externalWrapperNameAttribute,
            externalWrapperPathAttribute: externalWrapperPathAttribute
        )
    )
    
    try parser.parse(fromText: text, sourceInfo: sourceInfo, eventHandlers: eventHandlers)
    
    return document
}

public func parseXML(
    fromData data: Data,
    sourceInfo: String? = nil,
    internalEntityResolver: InternalEntityResolver? = nil,
    eventHandlers: [XEventHandler]? = nil,
    textAllowedInElementWithName: ((String) -> Bool)? = nil,
    keepComments: Bool = false,
    keepCDATASections: Bool = false,
    insertExternalParsedEntities: Bool = false,
    externalWrapperElement: String? = nil,
    externalWrapperNameAttribute: String? = nil,
    externalWrapperPathAttribute: String? = nil
) throws -> XDocument {
    let document = XDocument()
    
    let parser = ConvenienceParser(
        parser: XParser(
            internalEntityResolver: internalEntityResolver,
            textAllowedInElementWithName: textAllowedInElementWithName
        ),
        mainEventHandler: XParseBuilder(
            document: document,
            keepComments: keepComments,
            keepCDATASections: keepCDATASections,
            insertExternalParsedEntities: insertExternalParsedEntities,
            externalWrapperElement: externalWrapperElement,
            externalWrapperNameAttribute: externalWrapperNameAttribute,
            externalWrapperPathAttribute: externalWrapperPathAttribute
        )
    )
    
    try parser.parse(fromData: data, sourceInfo: sourceInfo, eventHandlers: eventHandlers)
    
    return document
}

// JSON:

public func parseJSON(
    fromPath path: String,
    rootName: String? = nil,
    arrayItemName: String? = nil,
    eventHandlers: [XEventHandler]? = nil
) throws -> XDocument {
    let document = XDocument()
    
    let parser = ConvenienceParser(
        parser: JParser(rootName: rootName, arrayItemName: arrayItemName),
        mainEventHandler: XParseBuilder(document: document)
    )
    
    try parser.parse(fromPath: path, eventHandlers: eventHandlers)
    
    return document
}

public func parseJSON(
    fromURL url: URL,
    rootName: String? = nil,
    arrayItemName: String? = nil,
    eventHandlers: [XEventHandler]? = nil
) throws -> XDocument {
    let document = XDocument()
    
    let parser = ConvenienceParser(
        parser: JParser(rootName: rootName, arrayItemName: arrayItemName),
        mainEventHandler: XParseBuilder(document: document)
    )
    
    try parser.parse(fromURL: url, eventHandlers: eventHandlers)
    
    return document
}

public func parseJSON(
    fromText text: String,
    sourceInfo: String? = nil,
    rootName: String? = nil,
    arrayItemName: String? = nil,
    eventHandlers: [XEventHandler]? = nil
) throws -> XDocument {
    let document = XDocument()
    
    let parser = ConvenienceParser(
        parser: JParser(rootName: rootName, arrayItemName: arrayItemName),
        mainEventHandler: XParseBuilder(document: document)
    )
    
    try parser.parse(fromText: text, sourceInfo: sourceInfo, eventHandlers: eventHandlers)
    
    return document
}

public func parseJSON(
    fromData data: Data,
    sourceInfo: String? = nil,
    rootName: String? = nil,
    arrayItemName: String? = nil,
    eventHandlers: [XEventHandler]? = nil
) throws -> XDocument {
    let document = XDocument()
    
    let parser = ConvenienceParser(
        parser: JParser(rootName: rootName, arrayItemName: arrayItemName),
        mainEventHandler: XParseBuilder(document: document)
    )
    
    try parser.parse(fromData: data, sourceInfo: sourceInfo, eventHandlers: eventHandlers)
    
    return document
}
