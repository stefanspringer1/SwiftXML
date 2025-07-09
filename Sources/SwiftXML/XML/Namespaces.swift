//===--- Namespaces.swift -------------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation

func getPrefixTranslations(fromPrefixesForNamespaceURIs prefixesForNamespaceURIs: [String:String]?, forNode node: XNode) -> [String:String]? {
    if let prefixesForNamespaceURIs, let document = node.document {
        var prefixTranslations = [String:String]()
        for (namespace,newPrefix) in prefixesForNamespaceURIs {
            print(namespace)
            print(newPrefix)
            if let prefix = document._namespaceURIToPrefix[namespace] {
                prefixTranslations[prefix] = newPrefix
            }
        }
        return prefixTranslations
    } else {
        return nil
    }
}

func getCompletePrefixTranslations(
    prefixTranslations: [String:String]? = nil,
    prefixesForNamespaceURIs: [String:String]? = nil,
    forNode node: XNode
) -> [String:String]? {
    var completePrefixTranslations: [String:String]?
    if let prefixTranslationsFromPrefixesForNamespaceURIs = getPrefixTranslations(fromPrefixesForNamespaceURIs: prefixesForNamespaceURIs, forNode: node) {
        if let prefixTranslations {
            completePrefixTranslations = prefixTranslationsFromPrefixesForNamespaceURIs.merging(prefixTranslations) { (current, _) in current }
        } else {
            completePrefixTranslations = prefixTranslationsFromPrefixesForNamespaceURIs
        }
    } else {
        completePrefixTranslations = prefixTranslations
    }
    return completePrefixTranslations
}
