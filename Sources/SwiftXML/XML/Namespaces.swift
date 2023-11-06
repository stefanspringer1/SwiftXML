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

public enum NamespaceReference {
    
    case uri(_ uri: String)
    case fullPrefix(_ fullPrefix: String)
    
    public init(usingURI uri: String) {
        self = .uri(uri)
    }
    
    public init(usingPossiblyFullPrefix possiblyFullPrefix: String? = nil) {
        if let possiblyFullPrefix, !possiblyFullPrefix.isEmpty {
            self = .fullPrefix(possiblyFullPrefix.hasSuffix(":") ? possiblyFullPrefix : "\(possiblyFullPrefix):")
        } else {
            self = .fullPrefix("")
        }
    }
    
}

extension XDocument {
    
    /// Read the the full prefix for a namespace URL string from the root element.
    /// "Full" means that a closing ":" is added automatically.
    /// If no prefix is defined, an empty string is returned.
    public func fullPrefix(forNamespace namespace: String) -> String {
        self.children.first?.fullPrefix(forNamespace: namespace) ?? ""
    }
    
    /// Read the the full prefix for a namespace reference.
    public func fullPrefix(forNamespaceReference namespaceReference: NamespaceReference) -> String {
        switch namespaceReference {
        case .uri(uri: let uri):
            fullPrefix(forNamespace: uri)
        case .fullPrefix(fullPrefix: let fullPrefix):
            fullPrefix
        }
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
    
}

extension XElement {
    
    /// Read the the full prefix for a namespace URL string from the element.
    /// "Full" means that a closing ":" is added automatically.
    /// If no prefix is defined, an empty string is returned.
    public func fullPrefix(forNamespace namespace: String) -> String {
        var foundPrefix: String? = nil
        let namespaceDeclarationPrefix = "xmlns:"
        for attributeName in attributeNames {
            if attributeName.hasPrefix(namespaceDeclarationPrefix), let value = self[attributeName], value == namespace {
                foundPrefix = String(attributeName.dropFirst(namespaceDeclarationPrefix.count)) + ":"
                break
            }
        }
        return foundPrefix ?? ""
    }
    
    /// Read the the full prefix for a namespace reference.
    public func fullPrefix(forNamespaceReference namespaceReference: NamespaceReference) -> String {
        switch namespaceReference {
        case .uri(uri: let uri):
            fullPrefix(forNamespace: uri)
        case .fullPrefix(fullPrefix: let fullPrefix):
            fullPrefix
        }
    }
    
    /// Read a map from the namespace URL strings to the full prefixes from the element.
    /// "Full" means that a closing ":" is added automatically.
    public var fullPrefixesForNamespaces: [String:String] {
        var result = [String:String]()
        let namespaceDeclarationPrefix = "xmlns:"
        for attributeName in attributeNames {
            if attributeName.hasPrefix(namespaceDeclarationPrefix), let value = self[attributeName] {
                result[value] = String(attributeName.dropFirst(namespaceDeclarationPrefix.count)) + ":"
            }
        }
        return result
    }
    
    /// Add the according namespace declaration at the element.
    /// The prefix might be a "full" prefix, i.e. it could contain a closing ":".
    /// An existing namespace declaration for the same namespace but with another prefix is not (!) removed.
    public func setNamespace(_ namespace: String, withPossiblyFullPrefix possiblyFullPrefix: String) {
        if !possiblyFullPrefix.isEmpty {
            self["xmlns:\(possiblyFullPrefix.hasSuffix(":") ? String(possiblyFullPrefix.dropLast()) : possiblyFullPrefix)"] = namespace
        }
    }
    
}

extension XBranch {
    
    /// Read the the full prefix for a namespace URL string from the root element.
    /// "Full" means that a closing ":" is added automatically.
    /// If no prefix is defined, an empty string is returned.
    public func fullPrefix(forNamespace namespace: String) -> String {
        (self as? XDocument)?.fullPrefix(forNamespace: namespace) ?? (self as? XElement)?.fullPrefix(forNamespace: namespace) ?? ""
    }
    
    /// Read the the full prefix for a namespace reference.
    public func fullPrefix(forNamespaceReference namespaceReference: NamespaceReference) -> String {
        (self as? XDocument)?.fullPrefix(forNamespaceReference: namespaceReference) ?? (self as? XElement)?.fullPrefix(forNamespaceReference: namespaceReference) ?? ""
    }
    
    /// Read a map from the namespace URL strings to the full prefixes from the root element.
    /// "Full" means that a closing ":" is added automatically.
    public var fullPrefixesForNamespaces: [String:String] {
        (self as? XDocument)?.fullPrefixesForNamespaces ?? (self as? XElement)?.fullPrefixesForNamespaces ?? [String:String]()
    }
    
    /// Add the according namespace declaration at the root element.
    /// The prefix might be a "full" prefix, i.e. it could contain a closing ":".
    /// An existing namespace declaration for the same namespace but with another prefix is not (!) removed.
    public func setNamespace(_ namespace: String, withPossiblyFullPrefix possiblyFullPrefix: String) {
        (self as? XDocument)?.setNamespace(namespace, withPossiblyFullPrefix: possiblyFullPrefix) ?? (self as? XElement)?.setNamespace(namespace, withPossiblyFullPrefix: possiblyFullPrefix)
    }
    
}
