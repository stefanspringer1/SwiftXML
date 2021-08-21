//
//  File.swift
//  
//
//  Created by Stefan Springer on 19.08.21.
//

import Foundation
import SwiftXMLInterfaces
import SwiftXMLParser

public func parseXML(
    path: String,
    internalEntityResolver: InternalEntityResolver
) throws -> XMLDocument {
    var document = XMLDocument()
    let eventHandler = XMLBuilder(document: &document)
    try SwiftXMLParser.parse(
        path: path,
        eventHandler: eventHandler,
        internalEntityResolver: internalEntityResolver
    )
    return document
}

public func parseXML(
    text: String,
    pathInfo: String? = nil,
    internalEntityResolver: InternalEntityResolver
) throws -> XMLDocument {
    var document = XMLDocument()
    let eventHandler = XMLBuilder(document: &document)
    try SwiftXMLParser.parse(
        text: text,
        pathInfo: pathInfo,
        eventHandler: eventHandler,
        internalEntityResolver: internalEntityResolver
    )
    return document
}

public func parseXML(
    data: Data,
    pathInfo: String? = nil,
    internalEntityResolver: InternalEntityResolver
) throws -> XMLDocument {
    var document = XMLDocument()
    let eventHandler = XMLBuilder(document: &document)
    try SwiftXMLParser.parse(
        data: data,
        pathInfo: pathInfo,
        eventHandler: eventHandler,
        internalEntityResolver: internalEntityResolver
    )
    return document
}
